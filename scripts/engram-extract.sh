#!/bin/bash
#
# Extract engram observations from a Claude Code session log
#
# Three-pass chunked pipeline:
#   Pass 1 (local): Clean conversation, split into turn-based chunks with overlap
#   Pass 2 (ollama): Extract observations per chunk → SQLite staging DB
#   Pass 3 (local): Deduplicate overlapping observations → save to engram
#
# Usage:
#   ./engram-extract.sh <session-id>         # Extract and save
#   ./engram-extract.sh --latest             # Most recent session
#   ./engram-extract.sh --dry-run <id>       # Show results, don't save to engram
#   ./engram-extract.sh --dry-run --latest
#   ./engram-extract.sh --show-chunks <id>   # Show chunks only (debug pass 1)
#

set -euo pipefail

# Config
OLLAMA_URL="${OLLAMA_URL:-http://127.0.0.1:11434}"
OLLAMA_MODEL="${OLLAMA_MODEL:-phi4-mini}"
ENGRAM_URL="${ENGRAM_URL:-http://127.0.0.1:7437}"
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
TURNS_PER_CHUNK=8
OVERLAP_TURNS=3
STAGING_DIR="/tmp/engram-extract"

# Colors
C='\033[0;36m'
G='\033[0;32m'
Y='\033[0;33m'
R='\033[0;31m'
D='\033[0;90m'
B='\033[1m'
NC='\033[0m'

DRY_RUN=false
SHOW_CHUNKS=false
SESSION_ID=""

# --- Parse args ---

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)       DRY_RUN=true; shift ;;
        --show-chunks)   SHOW_CHUNKS=true; shift ;;
        --latest)        SESSION_ID="LATEST"; shift ;;
        --turns)         TURNS_PER_CHUNK="$2"; shift 2 ;;
        --overlap)       OVERLAP_TURNS="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS] [--latest | <session-id>]"
            echo ""
            echo "Options:"
            echo "  --dry-run        Show results, don't save to engram"
            echo "  --show-chunks    Show pass 1 output only (debug)"
            echo "  --turns N        Turns per chunk (default: 8)"
            echo "  --overlap N      Overlap turns between chunks (default: 3)"
            exit 0
            ;;
        *)  SESSION_ID="$1"; shift ;;
    esac
done

if [[ -z "$SESSION_ID" ]]; then
    echo -e "${R}Error: provide a session ID or --latest${NC}"
    exit 1
fi

# --- Find session log ---

find_session_log() {
    local id="$1"
    if [[ "$id" == "LATEST" ]]; then
        find "$CLAUDE_PROJECTS_DIR" -name '*.jsonl' -type f -printf '%T@ %p\n' 2>/dev/null \
            | sort -rn | head -1 | awk '{print $2}'
    else
        find "$CLAUDE_PROJECTS_DIR" -name "${id}.jsonl" -type f 2>/dev/null | head -1
    fi
}

SESSION_LOG=$(find_session_log "$SESSION_ID")

if [[ -z "$SESSION_LOG" || ! -f "$SESSION_LOG" ]]; then
    echo -e "${R}Error: session log not found${NC}"
    exit 1
fi

[[ "$SESSION_ID" == "LATEST" ]] && SESSION_ID=$(basename "$SESSION_LOG" .jsonl)

echo -e "${B}Extracting observations from session ${SESSION_ID}${NC}"
echo -e "${D}Log: ${SESSION_LOG}${NC}"

# --- Setup staging ---

mkdir -p "$STAGING_DIR"
STAGING_DB="${STAGING_DIR}/${SESSION_ID}.db"

# Create staging database
sqlite3 "$STAGING_DB" <<'SQL'
CREATE TABLE IF NOT EXISTS chunks (
    id INTEGER PRIMARY KEY,
    turn_start INTEGER,
    turn_end INTEGER,
    char_count INTEGER,
    status TEXT DEFAULT 'pending',
    created_at TEXT DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS observations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chunk_id INTEGER,
    type TEXT,
    title TEXT,
    content TEXT,
    scope TEXT,
    project TEXT,
    topic_key TEXT,
    dedupe_status TEXT DEFAULT 'pending',
    FOREIGN KEY (chunk_id) REFERENCES chunks(id)
);
SQL

# ============================================================
# PASS 1: Extract turns and create chunks
# ============================================================

echo -e "${C}[1/3]${NC} Splitting session into chunks..."

# Extract turns as a JSON array — each turn = user message + tool call names from that exchange
# We group by user messages: everything between two USER messages belongs to one turn
TURNS_FILE="${STAGING_DIR}/${SESSION_ID}_turns.json"

jq -s '
  # Collect all user and assistant messages
  [.[] | select(.type == "user" or .type == "assistant")] |

  # Build turns: each turn starts with a user message
  reduce .[] as $msg (
    {turns: [], current_user: null, current_tools: []};

    if $msg.type == "user" then
      # Save previous turn if we have one
      (if .current_user then
        .turns += [{
          user: .current_user,
          tools: .current_tools
        }]
      else . end) |
      # Start new turn
      .current_user = (
        $msg.message.content |
        if type == "array" then
          [.[] | select(.type == "text") | .text] | join("\n")
        elif type == "string" then .
        else ""
        end
      ) |
      .current_tools = []
    else
      # Assistant message — collect tool names
      .current_tools += [
        $msg.message.content[]? |
        select(.type == "tool_use") |
        .name
      ]
    end
  ) |
  # Capture the last turn
  (if .current_user then
    .turns += [{user: .current_user, tools: .current_tools}]
  else . end) |
  .turns |
  # Filter out empty user messages
  [.[] | select(.user | length > 0)]
' "$SESSION_LOG" > "$TURNS_FILE" 2>/dev/null

TOTAL_TURNS=$(jq 'length' "$TURNS_FILE")
echo -e "  ${D}Total turns: ${TOTAL_TURNS}${NC}"

if [[ "$TOTAL_TURNS" -eq 0 ]]; then
    echo -e "${Y}No user messages found in session${NC}"
    rm -f "$STAGING_DB" "$TURNS_FILE"
    exit 0
fi

# Create chunks with overlap
CHUNK_ID=0
START=0
while [[ $START -lt $TOTAL_TURNS ]]; do
    END=$(( START + TURNS_PER_CHUNK ))
    [[ $END -gt $TOTAL_TURNS ]] && END=$TOTAL_TURNS

    # Extract chunk text: user messages + tool summary
    CHUNK_TEXT=$(jq -r --argjson start "$START" --argjson end "$END" '
      .[$start:$end] |
      map(
        "USER: " + .user +
        (if (.tools | length) > 0 then
          "\n[Tools used: " + (.tools | join(", ")) + "]"
        else "" end)
      ) | join("\n\n")
    ' "$TURNS_FILE")

    CHUNK_CHARS=${#CHUNK_TEXT}
    CHUNK_ID=$(( CHUNK_ID + 1 ))

    # Store chunk metadata
    sqlite3 "$STAGING_DB" "INSERT INTO chunks (id, turn_start, turn_end, char_count) VALUES ($CHUNK_ID, $START, $END, $CHUNK_CHARS);"

    # Store chunk text as a file (SQLite blob would complicate things)
    echo "$CHUNK_TEXT" > "${STAGING_DIR}/${SESSION_ID}_chunk_${CHUNK_ID}.txt"

    echo -e "  ${D}Chunk ${CHUNK_ID}: turns ${START}-${END} (${CHUNK_CHARS} chars)${NC}"

    # Advance with overlap — if we reached the end, stop
    if [[ $END -ge $TOTAL_TURNS ]]; then
        break
    fi
    NEXT_START=$(( END - OVERLAP_TURNS ))
    # Make sure we always advance by at least 1 turn
    [[ $NEXT_START -le $START ]] && NEXT_START=$(( START + 1 ))
    START=$NEXT_START
done

TOTAL_CHUNKS=$CHUNK_ID
echo -e "  ${G}${TOTAL_CHUNKS} chunks created (${TURNS_PER_CHUNK} turns/chunk, ${OVERLAP_TURNS} overlap)${NC}"

# Debug mode
if $SHOW_CHUNKS; then
    for i in $(seq 1 "$TOTAL_CHUNKS"); do
        echo ""
        echo -e "${B}=== Chunk ${i} ===${NC}"
        cat "${STAGING_DIR}/${SESSION_ID}_chunk_${i}.txt"
    done
    rm -f "$TURNS_FILE"
    exit 0
fi

# ============================================================
# PASS 2: Extract observations per chunk via ollama
# ============================================================

echo -e "${C}[2/4]${NC} Extracting observations (${TOTAL_CHUNKS} chunks → ${OLLAMA_MODEL} at ${OLLAMA_URL})..."

SYSTEM_PROMPT='You extract structured observations from coding session transcripts. Output ONLY valid JSONL — one JSON object per line. No markdown, no code blocks, no commentary.

IMPORTANT: Be selective. Only extract SIGNIFICANT observations — things worth remembering in future sessions. Skip:
- Questions the user asked (unless the question reveals a preference or constraint)
- Minor actions (checking files, running diagnostic commands)
- Troubleshooting steps that led nowhere
- The user asking for explanations (unless they learned something non-obvious)

Focus on extracting:
- config: A configuration file was created or changed (include what file and what settings)
- decision: A choice was made between alternatives (include what was chosen and why)
- preference: The user stated how they want things done (include the constraint and reasoning)
- discovery: Something non-obvious was learned about the system (include what and why it matters)
- bugfix: A problem was identified and fixed (include root cause and fix)
- architecture: A system design choice was made (include the design and tradeoffs)
- pattern: A convention or approach was established (include the pattern and where it applies)

Each JSON object must have: type, title (short verb-phrase starting with a verb), content (2-4 sentences: what was done/decided, why, what files/systems affected), scope (personal or project), project (system name like portus, engram, grid.local, obs-studio, general), topic_key (lowercase area/subject like portus/va-api, workflow/radio-devices).

Examples:
{"type":"config","title":"Enabled VA-API hardware video decode for Chromium","content":"Created ~/.config/chromium-flags.conf with VaapiVideoDecodeLinuxGL, VaapiVideoEncoder, and related flags. Offloads video decode from CPU (18%) to Intel Iris Xe GPU (~1-2%). Requires Chromium restart.","scope":"project","project":"portus","topic_key":"portus/chromium-vaapi"}
{"type":"preference","title":"Never disable WiFi or Bluetooth via power management","content":"User has active SSH sessions over WiFi and uses Bluetooth headphones and mouse. TLP radio device wizard (tlp-rdw) rules must remain unconfigured so radios are never toggled.","scope":"personal","project":"general","topic_key":"workflow/radio-devices"}
{"type":"decision","title":"Chose TLP drop-in config over editing main tlp.conf","content":"Created /etc/tlp.d/01-portus.conf instead of modifying /etc/tlp.conf so the main config stays stock and pacman upgrades do not overwrite settings.","scope":"project","project":"portus","topic_key":"portus/tlp-config"}'

TOTAL_OBS=0

for i in $(seq 1 "$TOTAL_CHUNKS"); do
    CHUNK_TEXT=$(cat "${STAGING_DIR}/${SESSION_ID}_chunk_${i}.txt")

    echo -ne "  Chunk ${i}/${TOTAL_CHUNKS}: "

    # Build request file
    REQFILE="${STAGING_DIR}/${SESSION_ID}_req_${i}.json"
    jq -n \
        --arg model "$OLLAMA_MODEL" \
        --arg system "$SYSTEM_PROMPT" \
        --arg user "Extract observations from this conversation excerpt:\n\n${CHUNK_TEXT}" \
        '{
            model: $model, stream: false,
            options: {temperature: 0, num_predict: 2048},
            messages: [
                {role: "system", content: $system},
                {role: "user", content: $user}
            ]
        }' > "$REQFILE"

    # Call ollama
    RESPONSE=$(curl -sf "${OLLAMA_URL}/api/chat" \
        -H "Content-Type: application/json" \
        -d "@${REQFILE}" \
        --max-time 120 2>/dev/null)

    if [[ -z "$RESPONSE" ]]; then
        echo -e "${R}timeout/error${NC}"
        sqlite3 "$STAGING_DB" "UPDATE chunks SET status='error' WHERE id=$i;"
        continue
    fi

    GENERATED=$(echo "$RESPONSE" | jq -r '.message.content // empty')
    PROMPT_DUR=$(echo "$RESPONSE" | jq -r '.prompt_eval_duration // 0')
    EVAL_DUR=$(echo "$RESPONSE" | jq -r '.eval_duration // 0')
    PROMPT_S=$(( PROMPT_DUR / 1000000000 ))
    EVAL_S=$(( EVAL_DUR / 1000000000 ))

    if [[ -z "$GENERATED" ]]; then
        echo -e "${R}empty response${NC}"
        sqlite3 "$STAGING_DB" "UPDATE chunks SET status='empty' WHERE id=$i;"
        continue
    fi

    # Parse observations — handle both compact and pretty-printed JSON
    CHUNK_OBS=0
    while IFS= read -r obj; do
        [[ -z "$obj" ]] && continue

        type=$(echo "$obj" | jq -r '.type // empty')
        title=$(echo "$obj" | jq -r '.title // empty')
        content=$(echo "$obj" | jq -r '.content // empty')
        scope=$(echo "$obj" | jq -r '.scope // "project"')
        project=$(echo "$obj" | jq -r '.project // "general"')
        topic_key=$(echo "$obj" | jq -r '.topic_key // empty')

        [[ -z "$type" || -z "$title" ]] && continue

        # Escape single quotes for SQLite
        title_esc="${title//\'/\'\'}"
        content_esc="${content//\'/\'\'}"
        project_esc="${project//\'/\'\'}"
        topic_key_esc="${topic_key//\'/\'\'}"

        sqlite3 "$STAGING_DB" "INSERT INTO observations (chunk_id, type, title, content, scope, project, topic_key) VALUES ($i, '$type', '$title_esc', '$content_esc', '$scope', '$project_esc', '$topic_key_esc');"
        CHUNK_OBS=$(( CHUNK_OBS + 1 ))
    done < <(echo "$GENERATED" | tr '\n' ' ' | grep -oP '\{[^{}]*\}' | while IFS= read -r raw; do
        echo "$raw" | jq -c 'select(.type and .title)' 2>/dev/null || true
    done)

    TOTAL_OBS=$(( TOTAL_OBS + CHUNK_OBS ))
    sqlite3 "$STAGING_DB" "UPDATE chunks SET status='done' WHERE id=$i;"
    echo -e "${G}${CHUNK_OBS} observations${NC} ${D}(prompt:${PROMPT_S}s gen:${EVAL_S}s)${NC}"

    rm -f "$REQFILE"
done

echo -e "  ${G}Total: ${TOTAL_OBS} raw observations across ${TOTAL_CHUNKS} chunks${NC}"

if [[ "$TOTAL_OBS" -eq 0 ]]; then
    echo -e "${Y}No observations extracted from any chunk.${NC}"
    rm -f "$TURNS_FILE"
    exit 0
fi

# ============================================================
# PASS 3: Deduplicate and save
# ============================================================

echo -e "${C}[3/4]${NC} Deduplicating..."

# Simple dedup: group by topic_key, keep the one with longest content
# For observations without topic_key, group by similar title (exact match for now)
sqlite3 "$STAGING_DB" <<'SQL'
-- Mark duplicates: for each topic_key group, keep the row with longest content
UPDATE observations SET dedupe_status = 'duplicate'
WHERE topic_key != '' AND id NOT IN (
    SELECT id FROM observations
    WHERE topic_key != ''
    GROUP BY topic_key
    HAVING length(content) = MAX(length(content))
);

-- For empty topic_key, deduplicate by exact title match
UPDATE observations SET dedupe_status = 'duplicate'
WHERE topic_key = '' AND id NOT IN (
    SELECT MIN(id) FROM observations
    WHERE topic_key = ''
    GROUP BY title
);

-- Mark remaining as 'keep'
UPDATE observations SET dedupe_status = 'keep'
WHERE dedupe_status = 'pending';
SQL

KEPT=$(sqlite3 "$STAGING_DB" "SELECT COUNT(*) FROM observations WHERE dedupe_status='keep';")
DUPES=$(sqlite3 "$STAGING_DB" "SELECT COUNT(*) FROM observations WHERE dedupe_status='duplicate';")
echo -e "  ${D}Kept: ${KEPT}, duplicates removed: ${DUPES}${NC}"

# ============================================================
# PASS 4: Refinement — filter noise via model
# ============================================================

echo -e "${C}[4/4]${NC} Refining (filtering noise)..."

# Build a compact list of all kept observations for the model to review
ALL_OBS=$(sqlite3 -separator '|' "$STAGING_DB" \
    "SELECT id, type, title, content FROM observations WHERE dedupe_status='keep' ORDER BY id;")

REFINE_INPUT=""
while IFS='|' read -r id type title content; do
    [[ -z "$id" ]] && continue
    REFINE_INPUT="${REFINE_INPUT}
#${id} [${type}] ${title}: ${content}"
done <<< "$ALL_OBS"

REFINE_REQFILE="${STAGING_DIR}/${SESSION_ID}_refine.json"
jq -n \
    --arg model "$OLLAMA_MODEL" \
    --arg obs "$REFINE_INPUT" \
    '{
        model: $model, stream: false,
        options: {temperature: 0, num_predict: 1024},
        messages: [
            {role: "system", content: "You filter duplicate and trivial observations from a coding session. You will receive a numbered list. Identify IDs to REMOVE.\n\nREMOVE:\n- Duplicates: if two observations describe the same action or decision, remove the one with less detail\n- Verification steps (confirming something works is not a decision)\n- Observations that are just a question without a conclusion\n\nNEVER REMOVE:\n- User preferences or constraints (even minor ones)\n- Configuration changes (files created or modified)\n- Decisions where a choice was made between alternatives\n- Bug fixes\n- Architecture or design choices\n- Discoveries about system behavior\n\nWhen in doubt, KEEP. Output ONLY IDs to remove, one number per line. Nothing else."},
            {role: "user", content: ("Review these observations and list the IDs to remove:\n" + $obs)}
        ]
    }' > "$REFINE_REQFILE"

REFINE_RESPONSE=$(curl -sf "${OLLAMA_URL}/api/chat" \
    -H "Content-Type: application/json" \
    -d "@${REFINE_REQFILE}" \
    --max-time 60 2>/dev/null)

REMOVE_IDS=$(echo "$REFINE_RESPONSE" | jq -r '.message.content // empty' | grep -oP '\d+')

if [[ -n "$REMOVE_IDS" ]]; then
    REMOVE_COUNT=0
    while IFS= read -r rid; do
        [[ -z "$rid" ]] && continue
        sqlite3 "$STAGING_DB" "UPDATE observations SET dedupe_status='noise' WHERE id=$rid AND dedupe_status='keep';"
        REMOVE_COUNT=$(( REMOVE_COUNT + 1 ))
    done <<< "$REMOVE_IDS"
    echo -e "  ${D}Removed ${REMOVE_COUNT} noisy observations${NC}"
else
    echo -e "  ${D}No noise detected${NC}"
fi

FINAL_COUNT=$(sqlite3 "$STAGING_DB" "SELECT COUNT(*) FROM observations WHERE dedupe_status='keep';")
echo -e "  ${G}Final: ${FINAL_COUNT} observations${NC}"

rm -f "$REFINE_REQFILE"

# Display results
echo ""
echo -e "${B}Observations:${NC}"
echo ""

sqlite3 -separator '|' "$STAGING_DB" "SELECT type, title, content, scope, project, topic_key FROM observations WHERE dedupe_status='keep' ORDER BY id;" | while IFS='|' read -r type title content scope project topic_key; do
    echo -e "  ${B}[${type}]${NC} ${title}"
    echo -e "  ${D}${content}${NC}"
    echo -e "  ${D}project: ${project} | topic: ${topic_key:-n/a} | scope: ${scope}${NC}"
    echo ""
done

if $DRY_RUN; then
    echo -e "${Y}Dry run — nothing saved to engram.${NC}"
    echo -e "${D}Staging DB: ${STAGING_DB}${NC}"
    echo -e "${D}Inspect with: sqlite3 ${STAGING_DB} \"SELECT * FROM observations WHERE dedupe_status='keep';\"${NC}"
    rm -f "$TURNS_FILE" "${STAGING_DIR}/${SESSION_ID}_chunk_"*.txt
    exit 0
fi

# Save to engram
echo -e "${C}Saving to engram...${NC}"

sqlite3 -separator '|' "$STAGING_DB" "SELECT type, title, content, scope, project, topic_key FROM observations WHERE dedupe_status='keep' ORDER BY id;" | while IFS='|' read -r type title content scope project topic_key; do
    RESULT=$(curl -sf "${ENGRAM_URL}/observations" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$(jq -n \
            --arg session_id "$SESSION_ID" \
            --arg type "$type" \
            --arg title "$title" \
            --arg content "$content" \
            --arg scope "$scope" \
            --arg project "$project" \
            --arg topic_key "$topic_key" \
            --arg tool_name "engram-extract" \
            '{
                session_id: $session_id,
                type: $type,
                title: $title,
                content: $content,
                scope: $scope,
                project: $project,
                topic_key: $topic_key,
                tool_name: $tool_name
            }')" \
        2>/dev/null)

    if [[ -n "$RESULT" ]]; then
        echo -e "  ${G}Saved:${NC} ${title}"
    else
        echo -e "  ${R}Failed:${NC} ${title}"
    fi
done

# Cleanup
rm -f "$TURNS_FILE" "${STAGING_DIR}/${SESSION_ID}_chunk_"*.txt

echo ""
echo -e "${G}Done.${NC} Staging DB: ${STAGING_DB}"
