#!/usr/bin/env bash
#
# Neovim setup for Ubuntu / Debian.
#
# Installs:
#   - Neovim (PPA, unstable / nightly — needed for 0.12+)
#   - All required runtime deps (git, ripgrep, build-essential, cc)
#   - tree-sitter CLI (via npm — needed by nvim-treesitter `main` branch)
#   - Optional tools (hurl, jq)
#   - Provider packages (pynvim)
#
# Symlinks ~/.dotfiles/nvim → ~/.config/nvim (idempotent).
# Plugins, LSP servers, and formatters install automatically on first
# `nvim` launch via lazy.nvim + Mason.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

if ! command -v apt >/dev/null 2>&1; then
  error "apt not found — this script is for Ubuntu/Debian."
  exit 1
fi

DOTFILES_NVIM="${DOTFILES_NVIM:-$HOME/.dotfiles/nvim}"
NVIM_CONFIG_DIR="$HOME/.config/nvim"

if [[ ! -d "$DOTFILES_NVIM" ]]; then
  error "Dotfiles nvim dir not found at $DOTFILES_NVIM"
  error "Clone your dotfiles first, or set DOTFILES_NVIM=<path>."
  exit 1
fi

info "Installing Neovim unstable PPA..."
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update
sudo apt install -y neovim

info "Installing required runtime deps..."
sudo apt install -y \
  git \
  ripgrep \
  build-essential \
  curl \
  wget \
  nodejs \
  npm \
  python3 \
  python3-pip

info "Installing optional tools..."
sudo apt install -y jq hurl || warn "hurl unavailable on this Ubuntu version — skip"

info "Installing tree-sitter CLI (nvim-treesitter main branch requirement)..."
sudo npm install -g tree-sitter-cli

info "Installing pynvim (Python provider)..."
if command -v pipx >/dev/null 2>&1; then
  pipx install pynvim
else
  python3 -m pip install --user pynvim
fi

info "Linking config: $DOTFILES_NVIM -> $NVIM_CONFIG_DIR"
if [[ -e "$NVIM_CONFIG_DIR" && ! -L "$NVIM_CONFIG_DIR" ]]; then
  BACKUP="$NVIM_CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"
  warn "Existing $NVIM_CONFIG_DIR is not a symlink — moving to $BACKUP"
  mv "$NVIM_CONFIG_DIR" "$BACKUP"
fi
ln -sfn "$DOTFILES_NVIM" "$NVIM_CONFIG_DIR"

info "Done. Launch nvim — lazy.nvim and Mason will install the rest."
info "After first launch, run :checkhealth to verify."
