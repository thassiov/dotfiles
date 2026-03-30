#!/bin/bash
#
# Setup ollama + model for engram observation extraction
#
# Usage:
#   ./engram-extractor-setup.sh
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info()  { echo -e "${CYAN}[info]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[ok]${NC}    $1"; }

# Install ollama
if command -v ollama &>/dev/null; then
    log_ok "ollama already installed"
else
    log_info "Installing ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    log_ok "ollama installed"
fi

# Start ollama if not running
if ! curl -sf http://127.0.0.1:11434/api/tags --max-time 2 > /dev/null 2>&1; then
    log_info "Starting ollama serve..."
    ollama serve &>/dev/null &
    sleep 2
fi

# Pull the model (qwen2.5:7b is the sweet spot for extraction)
log_info "Pulling qwen2.5:7b (Q4, ~5GB download)..."
ollama pull qwen2.5:7b

log_ok "Setup complete"
echo ""
echo -e "${BOLD}Test it:${NC}"
echo "  ollama run qwen2.5:7b 'Say hello in one sentence'"
echo ""
echo -e "${BOLD}Run the extractor on a session:${NC}"
echo "  ~/.dotfiles/scripts/engram-extract.sh <session-id>"
echo ""
echo -e "${BOLD}Or extract from the most recent session:${NC}"
echo "  ~/.dotfiles/scripts/engram-extract.sh --latest"
