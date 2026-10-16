#!/usr/bin/env bash
#
# Neovim setup for Ubuntu / Debian.
#
# Installs:
#   - Neovim (PPA, unstable / nightly — needed for 0.12+)
#   - All required runtime deps (git, ripgrep, build-essential, cc, libreadline-dev for rest.nvim's Lua build,
#     postgresql-client for dadbod's psql)
#   - tree-sitter CLI >= 0.26.1 (official release binary in ~/.local/bin — needed by nvim-treesitter `main` branch
#     and by rest.nvim's `http` parser; apt's version is too old and nvim-treesitter says not to use npm)
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
  libreadline-dev \
  postgresql-client \
  curl \
  wget \
  nodejs \
  npm \
  python3 \
  python3-pip

info "Installing optional tools..."
sudo apt install -y jq hurl || warn "hurl unavailable on this Ubuntu version — skip"

install_tree_sitter_cli() {
  local dest="${TREE_SITTER_DEST:-$HOME/.local/bin}"
  if [[ "$(uname -m)" != "x86_64" ]]; then
    warn "tree-sitter CLI: only the x86_64 release is handled here. Install >= 0.26.1 yourself (see nvim/README.md)."
    return 0
  fi

  local tmp tag digest
  tmp="$(mktemp -d)"
  curl -fsSL "https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest" -o "$tmp/release.json"
  read -r tag digest < <(python3 -I - "$tmp/release.json" <<'PY'
import json, sys
release = json.load(open(sys.argv[1]))
asset = next(a for a in release["assets"] if a["name"] == "tree-sitter-linux-x64.gz")
print(release["tag_name"], asset["digest"].split(":", 1)[1])
PY
)
  curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/$tag/tree-sitter-linux-x64.gz" -o "$tmp/tree-sitter.gz"
  if ! echo "$digest  $tmp/tree-sitter.gz" | sha256sum -c - >/dev/null 2>&1; then
    error "tree-sitter $tag: checksum does not match the digest GitHub publishes — not installing."
    rm -rf "$tmp"
    exit 1
  fi
  mkdir -p "$dest"
  gunzip -c "$tmp/tree-sitter.gz" > "$dest/tree-sitter"
  chmod 755 "$dest/tree-sitter"
  rm -rf "$tmp"
  info "Installed tree-sitter $tag to $dest/tree-sitter"
  case ":$PATH:" in
    *":$dest:"*) ;;
    *) warn "$dest is not on PATH — add it before launching nvim." ;;
  esac
}

info "Installing tree-sitter CLI (nvim-treesitter main branch requirement)..."
install_tree_sitter_cli

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
