#!/bin/bash
#
# Extract engram observations from a Claude Code session log
#
# Two-pass pipeline:
#   Pass 1 (local, no model): Extract and clean conversation text
#     - User messages kept in full
#     - Assistant messages: strip code blocks, tables, HTML; keep prose
#     - Collapse empty lines and whitespace
#     - Summarize tool calls
#   Pass 2 (ollama, remote): Extract structured observations via chat API
#
# Usage:
#   ./engram-extract.sh <session-id>       # Extract and save
#   ./engram-extract.sh --latest           # Most recent session
#   ./engram-extract.sh --dry-run <id>     # Show results, don't save
#   ./engram-extract.sh --dry-run --latest
#   ./engram-extract.sh --show-cleaned <id> # Show pass 1 output only (debug)
#

set -euo pipefail

# Config
OLLAMA_URL="${OLLAMA_URL:-http://127.0.0.1:11434}"
OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5:7b}"
ENGRAM_URL="${ENGRAM_URL:-http://127.0.0.1:7437}"
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
MAX_CHARS=10000

# Colors
C='\033[0;36m'
G='\033[0;32m'
Y='\033[0;33m'
R='\033[0;31m'
D='\033[0;90m'
B='\033[1m'
NC='\033[0m'

DRY_RUN=false
SHOW_CLEANED=false
SESSION_ID=""

# --- Parse args ---

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)       DRY_RUN=true; shift ;;
        --show-cleaned)  SHOW_CLEANED=true; shift ;;
        --latest)        SESSION_ID="LATEST"; shift ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--show-cleaned] [--latest | <session-id>]"
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

# ============================================================
# PASS 1: Clean and prepare conversation text (no model needed)
# ============================================================

echo -e "${C}[1/3]${NC} Cleaning conversation text..."

# Extract USER messages only — these carry the decisions and preferences
# Assistant messages confused the 7B model into acting as a coding assistant
CLEANED=$(jq -r '
  select(.type == "user") |
  .message.content |
  if type == "array" then
    map(select(.type == "text") | .text) | join("\n")
  elif type == "string" then .
  else ""
  end
' "$SESSION_LOG" 2>/dev/null | \
  # Collapse multiple empty lines into one
  sed '/^$/N;/^\n$/d' | \
  # Trim trailing whitespace
  sed 's/[[:space:]]*$//' | \
  # Remove lines that are only whitespace
  sed '/^[[:space:]]*$/d'
)

# Tool call summary (compact)
TOOLS=$(jq -r '
  select(.type == "assistant") |
  .message.content[]? |
  select(.type == "tool_use") |
  .name + " → " + (
    .input |
    if .file_path then .file_path
    elif .command then (.command | split("\n")[0][:80])
    elif .name then .name
    elif .description then (.description[:60])
    elif .project_id then "project"
    else (keys[:3] | join(","))
    end
  )
' "$SESSION_LOG" 2>/dev/null)

CLEANED_SIZE=$(echo "$CLEANED" | wc -c)
TOOL_COUNT=$(echo "$TOOLS" | grep -c '.' || echo 0)
echo -e "  ${D}Cleaned: $(( CLEANED_SIZE / 1024 ))KB (from $(du -k "$SESSION_LOG" | cut -f1)KB log), ${TOOL_COUNT} tool calls${NC}"

# Truncate if still too long
if [[ ${#CLEANED} -gt $MAX_CHARS ]]; then
    CLEANED="${CLEANED:0:$MAX_CHARS}

[... rest of conversation truncated ...]"
    echo -e "  ${Y}Truncated to ~${MAX_CHARS} chars${NC}"
fi

# Debug mode: just show cleaned text
if $SHOW_CLEANED; then
    echo ""
    echo "$CLEANED"
    echo ""
    echo -e "${D}--- Tool calls ---${NC}"
    echo "$TOOLS"
    exit 0
fi

# ============================================================
# PASS 2: Send to model for extraction (chat API)
# ============================================================

echo -e "${C}[2/3]${NC} Sending to ${OLLAMA_MODEL} at ${OLLAMA_URL}..."

# Write request to file to avoid shell escaping issues with large payloads
REQFILE="/tmp/engram-extract-$$.json"
OUTFILE="/tmp/engram-extract-$$.txt"
> "$OUTFILE"

jq -n \
    --arg model "$OLLAMA_MODEL" \
    --arg tools "$TOOLS" \
    --arg conversation "$CLEANED" \
    '{
        model: $model,
        stream: true,
        options: {temperature: 0.1, num_predict: 2048},
        messages: [
            {
                role: "system",
                content: "You extract structured observations from coding session transcripts. Output ONLY valid JSONL — one JSON object per line. No markdown, no code blocks, no commentary, no explanations.\n\nEach JSON object must have these fields:\n- type: decision|bugfix|discovery|config|preference|pattern|architecture\n- title: short verb-phrase summary\n- content: 2-4 sentences explaining what was done, why, and what files/systems were affected\n- scope: personal (user preferences/workflow) or project (technical decisions/configs)\n- project: system name (e.g. portus, engram, grid.local, obs-studio, general)\n- topic_key: lowercase hierarchical key like area/subject (e.g. portus/tlp-config, workflow/radio-devices)\n\nExample output:\n{\"type\":\"config\",\"title\":\"Enabled VA-API for Chromium\",\"content\":\"Created chromium-flags.conf with hardware video decode flags. Reduces video CPU from 18% to 1-2%. File: ~/.config/chromium-flags.conf\",\"scope\":\"project\",\"project\":\"portus\",\"topic_key\":\"portus/chromium-vaapi\"}\n{\"type\":\"preference\",\"title\":\"User wants WiFi and Bluetooth always on\",\"content\":\"User has SSH over WiFi and BT headphones/mouse. Power management must never disable radios.\",\"scope\":\"personal\",\"project\":\"general\",\"topic_key\":\"workflow/radio-devices\"}"
            },
            {
                role: "user",
                content: ("Extract all observations from this coding session transcript.\n\nTool calls made during session:\n" + $tools + "\n\nConversation:\n" + $conversation)
            }
        ]
    }' > "$REQFILE"

echo -e "  ${D}Processing prompt...${NC}"

curl -sf "${OLLAMA_URL}/api/chat" \
    -H "Content-Type: application/json" \
    -d "@${REQFILE}" \
    --max-time 300 2>/dev/null | {
    FIRST_TOKEN=true
    while IFS= read -r line; do
        token=$(echo "$line" | jq -r '.message.content // empty' 2>/dev/null)
        done_flag=$(echo "$line" | jq -r '.done // false' 2>/dev/null)

        if [[ -n "$token" ]]; then
            if $FIRST_TOKEN; then
                echo ""
                echo -e "  ${D}Generating:${NC}"
                echo -n "  "
                FIRST_TOKEN=false
            fi
            echo -n "$token"
            echo -n "$token" >> "$OUTFILE"
        fi

        if [[ "$done_flag" == "true" ]]; then
            echo ""
            total_dur=$(echo "$line" | jq -r '.total_duration // 0' 2>/dev/null)
            prompt_dur=$(echo "$line" | jq -r '.prompt_eval_duration // 0' 2>/dev/null)
            eval_count=$(echo "$line" | jq -r '.eval_count // 0' 2>/dev/null)
            if [[ "$total_dur" -gt 0 ]]; then
                total_s=$(( total_dur / 1000000000 ))
                prompt_s=$(( prompt_dur / 1000000000 ))
                gen_s=$(( total_s - prompt_s ))
                echo -e "  ${D}Prompt: ${prompt_s}s | Generation: ${gen_s}s (${eval_count} tokens) | Total: ${total_s}s${NC}"
            fi
        fi
    done
}

GENERATED=$(cat "$OUTFILE")
rm -f "$OUTFILE" "$REQFILE"

if [[ -z "$GENERATED" ]]; then
    echo -e "${R}Error: no response from ollama at ${OLLAMA_URL}${NC}"
    echo "Is ollama running? Try: ollama serve"
    exit 1
fi

# Parse JSONL — handle both compact and pretty-printed JSON
# Collapse multi-line JSON objects into single lines, then validate
OBSERVATIONS=$(echo "$GENERATED" | \
    tr '\n' ' ' | \
    grep -oP '\{[^{}]*\}' | \
    while IFS= read -r obj; do
        echo "$obj" | jq -c 'select(.type and .title and .content)' 2>/dev/null || true
    done)

OBS_COUNT=$(echo "$OBSERVATIONS" | grep -c '{' || true)
echo -e "  ${G}Extracted ${OBS_COUNT} observations${NC}"

# ============================================================
# PASS 3: Display and optionally save
# ============================================================

if [[ "$OBS_COUNT" -eq 0 ]]; then
    echo -e "${Y}No observations extracted. Raw model output:${NC}"
    echo "$GENERATED"
    exit 0
fi

echo -e "\n${C}[3/3]${NC} Observations:"
echo ""

echo "$OBSERVATIONS" | while IFS= read -r obs; do
    [[ -z "$obs" ]] && continue
    type=$(echo "$obs" | jq -r '.type')
    title=$(echo "$obs" | jq -r '.title')
    content=$(echo "$obs" | jq -r '.content')
    scope=$(echo "$obs" | jq -r '.scope // "project"')
    project=$(echo "$obs" | jq -r '.project // "general"')
    topic_key=$(echo "$obs" | jq -r '.topic_key // empty')

    echo -e "  ${B}[${type}]${NC} ${title}"
    echo -e "  ${D}${content}${NC}"
    echo -e "  ${D}project: ${project} | topic: ${topic_key:-n/a} | scope: ${scope}${NC}"
    echo ""
done

if $DRY_RUN; then
    echo -e "${Y}Dry run — nothing saved.${NC}"
    echo -e "Raw JSONL:"
    echo "$OBSERVATIONS"
    exit 0
fi

# Save to engram
echo -e "${C}Saving to engram...${NC}"

echo "$OBSERVATIONS" | while IFS= read -r obs; do
    [[ -z "$obs" ]] && continue

    type=$(echo "$obs" | jq -r '.type')
    title=$(echo "$obs" | jq -r '.title')
    content=$(echo "$obs" | jq -r '.content')
    scope=$(echo "$obs" | jq -r '.scope // "project"')
    project=$(echo "$obs" | jq -r '.project // "general"')
    topic_key=$(echo "$obs" | jq -r '.topic_key // empty')

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

echo ""
echo -e "${G}Done.${NC}"
