#!/bin/bash
#
# Dotfiles setup script
#
# Reads setup.json to create symlinks and run post-install hooks.
#
# Usage:
#   ./setup.sh              # Create symlinks + run hooks
#   ./setup.sh --links      # Only create symlinks
#   ./setup.sh --hooks      # Only run hooks
#   ./setup.sh --dry-run    # Show what would be done
#   ./setup.sh --uninstall  # Remove all symlinks
#

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$DOTFILES_DIR/setup.json"
DRY_RUN=false
DO_LINKS=true
DO_HOOKS=true
UNINSTALL=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${CYAN}[info]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[ok]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[warn]${NC}  $1"; }
log_err()   { echo -e "${RED}[error]${NC} $1"; }
log_dry()   { echo -e "${YELLOW}[dry]${NC}   $1"; }

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --links       Only create symlinks (skip hooks)"
    echo "  --hooks       Only run hooks (skip links)"
    echo "  --dry-run     Show what would be done without doing it"
    echo "  --uninstall   Remove all managed symlinks"
    echo "  -h, --help    Show this help"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --links)     DO_HOOKS=false ;;
            --hooks)     DO_LINKS=false ;;
            --dry-run)   DRY_RUN=true ;;
            --uninstall) UNINSTALL=true ;;
            -h|--help)   usage; exit 0 ;;
            *)           log_err "Unknown option: $1"; usage; exit 1 ;;
        esac
        shift
    done
}

expand_path() {
    echo "${1/#\~/$HOME}"
}

# Read JSON config using python3 (available on any modern system)
read_config() {
    python3 -c "
import json, sys

with open('$CONFIG') as f:
    config = json.load(f)

section = sys.argv[1]
if section == 'links':
    for link in config.get('links', []):
        print(link['source'] + '|' + link['target'])
elif section == 'hooks':
    for hook in config.get('hooks', []):
        check = hook.get('check', '')
        print(hook['name'] + '|' + hook['description'] + '|' + hook['run'] + '|' + check)
" "$1"
}

create_link() {
    local source="$1"
    local target="$2"

    local abs_source="$DOTFILES_DIR/$source"
    local abs_target
    abs_target="$(expand_path "$target")"

    # Verify source exists
    if [[ ! -e "$abs_source" ]]; then
        log_err "Source not found: $source"
        return 1
    fi

    # Create parent directory if needed
    local parent_dir
    parent_dir="$(dirname "$abs_target")"
    if [[ ! -d "$parent_dir" ]]; then
        if $DRY_RUN; then
            log_dry "mkdir -p $parent_dir"
        else
            mkdir -p "$parent_dir"
            log_info "Created directory: $parent_dir"
        fi
    fi

    # Handle existing target
    if [[ -L "$abs_target" ]]; then
        local current_link
        current_link="$(readlink "$abs_target")"
        if [[ "$current_link" == "$abs_source" ]]; then
            log_ok "$source -> $target (already linked)"
            return 0
        else
            # Symlink exists but points elsewhere
            if $DRY_RUN; then
                log_dry "Would replace symlink: $abs_target (currently -> $current_link)"
            else
                rm "$abs_target"
                log_warn "Replaced existing symlink: $abs_target (was -> $current_link)"
            fi
        fi
    elif [[ -e "$abs_target" ]]; then
        # Real file/directory exists at target
        local backup="${abs_target}.backup.$(date +%Y%m%d%H%M%S)"
        if $DRY_RUN; then
            log_dry "Would backup $abs_target -> $backup"
        else
            mv "$abs_target" "$backup"
            log_warn "Backed up existing: $abs_target -> $backup"
        fi
    fi

    # Create the symlink
    if $DRY_RUN; then
        log_dry "ln -s $abs_source $abs_target"
    else
        ln -s "$abs_source" "$abs_target"
        log_ok "$source -> $target"
    fi
}

remove_link() {
    local source="$1"
    local target="$2"

    local abs_source="$DOTFILES_DIR/$source"
    local abs_target
    abs_target="$(expand_path "$target")"

    if [[ -L "$abs_target" ]]; then
        local current_link
        current_link="$(readlink "$abs_target")"
        if [[ "$current_link" == "$abs_source" ]]; then
            if $DRY_RUN; then
                log_dry "Would remove: $abs_target"
            else
                rm "$abs_target"
                log_ok "Removed: $abs_target"
            fi
        else
            log_warn "Skipping $abs_target (points to $current_link, not managed by us)"
        fi
    else
        log_info "Not a symlink, skipping: $abs_target"
    fi
}

run_hooks() {
    echo ""
    log_info "Running post-install hooks..."
    echo ""

    while IFS='|' read -r name description run check; do
        # If check command succeeds, skip
        if [[ -n "$check" ]] && eval "$check" 2>/dev/null; then
            log_ok "$name: $description (already done)"
            continue
        fi

        if $DRY_RUN; then
            log_dry "$name: would run: $run"
        else
            log_info "$name: $description..."
            if eval "$run"; then
                log_ok "$name: done"
            else
                log_warn "$name: hook returned non-zero (may be fine for first run)"
            fi
        fi
    done < <(read_config hooks)
}

main() {
    parse_args "$@"

    if [[ ! -f "$CONFIG" ]]; then
        log_err "Config not found: $CONFIG"
        exit 1
    fi

    if ! command -v python3 &>/dev/null; then
        log_err "python3 is required to parse setup.json"
        exit 1
    fi

    echo ""
    echo "dotfiles setup"
    echo "=============="
    echo "  repo: $DOTFILES_DIR"
    $DRY_RUN && echo "  mode: DRY RUN"
    $UNINSTALL && echo "  mode: UNINSTALL"
    echo ""

    if $UNINSTALL; then
        log_info "Removing symlinks..."
        echo ""
        while IFS='|' read -r source target; do
            remove_link "$source" "$target"
        done < <(read_config links)
        echo ""
        log_ok "Uninstall complete."
        return 0
    fi

    if $DO_LINKS; then
        log_info "Creating symlinks..."
        echo ""
        while IFS='|' read -r source target; do
            create_link "$source" "$target"
        done < <(read_config links)
    fi

    if $DO_HOOKS; then
        run_hooks
    fi

    echo ""
    log_ok "Setup complete."
}

main "$@"
