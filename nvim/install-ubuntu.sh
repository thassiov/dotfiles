#!/bin/bash
#
# Neovim Setup Script for Ubuntu
# Installs Neovim and all dependencies for nvim-new config
#

set -e  # Exit on error

echo "=================================="
echo "Neovim Complete Setup for Ubuntu"
echo "=================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    error "This script is for Ubuntu/Debian systems only"
    exit 1
fi

# 1. Install Prerequisites for PPA
info "Installing prerequisites..."
sudo apt update
sudo apt install -y software-properties-common

# 2. Install Neovim
info "Installing Neovim..."
if ! command -v nvim &> /dev/null; then
    # Add Neovim PPA for latest unstable version
    info "Adding Neovim PPA (unstable)..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt update
    sudo apt install -y neovim
    info "Neovim installed!"
else
    info "Neovim already installed ($(nvim --version | head -1))"
fi

# 3. Install Python provider support
info "Installing Python provider for Neovim..."
sudo apt install -y \
    python3-dev \
    python3-pip \
    python3-neovim
info "Python support installed!"

# 4. Install Core Dependencies
info "Installing core dependencies..."
sudo apt install -y \
    git \
    ripgrep \
    build-essential \
    curl \
    wget

info "Core dependencies installed!"

# 5. Install Language Dependencies
info "Installing language support..."
sudo apt install -y \
    nodejs \
    npm \
    clangd

info "Language dependencies installed!"

# 6. Install Optional but Recommended Tools
info "Installing optional tools..."
sudo apt install -y \
    jq \
    astyle \
    fd-find

# Install global npm packages
info "Installing global npm packages..."
npm install -g \
    prettier \
    markdownlint-cli

info "Optional tools installed!"

# 7. Setup config
info "Setting up Neovim config..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
DOTFILES_NVIM="$HOME/.dotfiles/nvim-new/.config/nvim"

if [ -d "$NVIM_CONFIG_DIR" ]; then
    warn "Existing Neovim config found at $NVIM_CONFIG_DIR"
    read -p "Backup and replace? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"
        info "Backed up existing config"
    else
        warn "Skipping config setup"
        exit 0
    fi
fi

# Create symlink or copy
if [ -d "$DOTFILES_NVIM" ]; then
    ln -s "$DOTFILES_NVIM" "$NVIM_CONFIG_DIR"
    info "Linked nvim-new config to ~/.config/nvim"
else
    error "Could not find nvim-new config at $DOTFILES_NVIM"
    exit 1
fi

# 8. Install Lazy.nvim plugin manager
info "Setting up Lazy.nvim..."
LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_PATH" ]; then
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_PATH"
    info "Lazy.nvim installed!"
else
    info "Lazy.nvim already installed"
fi

# 9. Install plugins
info "Installing Neovim plugins..."
info "This will happen automatically when you first open Neovim"

echo
echo "=================================="
echo "Installation Complete! 🎉"
echo "=================================="
echo
info "Next steps:"
echo "  1. Run: nvim"
echo "  2. Plugins will auto-install on first launch"
echo "  3. Run :checkhealth to verify everything works"
echo "  4. Read the README: ~/.dotfiles/nvim-new/README.md"
echo
warn "Note: Claude Code CLI must be installed separately"
echo "      Visit: https://docs.anthropic.com/en/docs/claude-code"
echo
