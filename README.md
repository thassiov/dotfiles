# Dotfiles

Personal configuration files for a productive Linux development environment.

**Philosophy:** Keyboard-driven, minimal, and efficient workflow with i3wm + tmux + Neovim.

## Overview

This repository contains configurations for:
- **Window Manager:** i3wm with Polybar
- **Terminal:** Alacritty + Tmux
- **Editor:** Neovim (extensively customized)
- **Shell:** Zsh with Zinit + Powerlevel10k
- **Launcher:** Rofi
- **Notifications:** Dunst
- **Extras:** Custom scripts, keyboard layouts, wallpapers

## Quick Start

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt install stow git i3 alacritty tmux zsh neovim rofi dunst polybar

# Arch Linux
sudo pacman -S stow git i3-wm alacritty tmux zsh neovim rofi dunst polybar
```

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Use stow to symlink configurations
stow zsh
stow i3
stow tmux
stow alacritty
stow nvim-new  # or nvim for legacy config
stow polybar
stow rofi
stow dunst
stow gitconfig

# Restart your shell or source zshrc
exec zsh
```

## Core Configurations

### i3 Window Manager

**Location:** `i3/.config/i3/config`

Tiling window manager with keyboard-centric workflow.

**Key Bindings:**
- **Mod key:** `Super` (Windows key)
- `Mod+t` - Open terminal with tmux
- `Mod+Shift+t` - Open terminal without tmux
- `Mod+k` - Kill focused window
- `Mod+l` - Lock screen
- `Mod+q` - Rofi run menu
- `Mod+o` - Rofi emoji picker
- `Mod+Backspace` - Toggle keyboard layout

**Features:**
- Custom font: FiraMono Medium + FontAwesome
- Floating window support
- Integration with Polybar status bar
- Multiple workspace support
- Custom keyboard layout switching

### Tmux

**Location:** `tmux/.config/tmux/tmux.conf`

Terminal multiplexer for managing multiple terminal sessions.

**Prefix:** `Ctrl+x` (instead of default Ctrl+b)

**Key Bindings:**
- `Prefix + r` - Reload tmux config
- `Prefix + |` - Split vertically (at $HOME)
- `Prefix + _` - Split horizontally (at $HOME)
- `Prefix + \` - Split vertically (current path)
- `Prefix + -` - Split horizontally (current path)
- `F2` - New window (current path)
- `Shift+F2` - New window ($HOME)
- `F3` / `F4` - Previous/Next window
- `Prefix + hjkl` - Navigate panes (Vim-style)
- `Alt+Arrow` - Navigate panes (Arrow keys)

**Features:**
- Mouse support enabled
- True color support for Alacritty
- 10,000 line history
- No ESC key delay
- Activity monitoring
- Base index starts at 1

### Alacritty

**Location:** `alacritty/.config/alacritty/`

GPU-accelerated terminal emulator.

**Files:**
- `alacritty.toml` - Main configuration (TOML format)
- `alacritty.yml` - Legacy configuration (YAML format)

**Features:**
- Optimized for performance
- True color support
- Integrates with tmux for multiplexing

### Neovim

**Location:** `nvim-new/.config/nvim/`

Extensively configured modern text editor. See `nvim-new/README.md` for complete documentation.

**Highlights:**
- **Plugin Manager:** Lazy.nvim
- **AI Assistant:** Claude Code integration
- **LSP:** Full language server support via Mason
- **Fuzzy Finding:** Telescope with ergonomic keybindings
- **Git Integration:** vim-fugitive + diffview + vgit
- **Theme:** Ayu colorscheme

**Quick Reference:**
- `<leader>` = `,` (comma)
- `<leader>f` - Find files
- `<leader>g` - Grep text
- `<leader>b` - Search buffers
- See full documentation: `nvim-new/README.md`

### Zsh

**Location:** `zsh/`

Shell configuration with modern features and plugins.

**Files:**
- `.zshrc` - Main configuration
- `.clialiases` - Custom aliases
- `.cli-functions` - Custom shell functions
- `.envs` - Environment variables
- `.envs.sensitive` - Sensitive env vars (gitignored)
- `.envs.sensitive.example` - Template for sensitive vars
- `.zsh-keybindings` - Custom keybindings

**Plugin Manager:** Zinit

**Theme:** Powerlevel10k with instant prompt

**Plugins (Oh-My-Zsh):**
- vi-mode - Vim keybindings in shell
- git - Git aliases and functions
- archlinux - Arch-specific helpers
- aws - AWS CLI completions
- kubectl - Kubernetes completions
- kubectx - Kubernetes context switching
- command-not-found - Suggest packages for missing commands
- fzf - Fuzzy finder integration

**Features:**
- 5,000 line history
- History deduplication
- Shared history across sessions
- Vi mode for command line editing

## Supporting Tools

### Polybar

**Location:** `polybar/.config/polybar/`

Status bar for i3wm showing system information.

**Configuration:** `config.ini`

### Rofi

**Location:** `rofi/.config/rofi/`

Application launcher and dmenu replacement.

**Usage:**
- `Mod+q` - Run menu
- `Mod+o` - Emoji picker

### Dunst

**Location:** `dunst/.config/dunst/`

Lightweight notification daemon.

### Git Config

**Location:** `gitconfig/.gitconfig`

Global git configuration and aliases.

## Utility Scripts

**Location:** `scripts/`

### Keyboard (`scripts/kb/`)
- `togglekblayouts` - Switch between keyboard layouts
- `useabntkb` - Use ABNT keyboard layout
- `useuskb` - Use US keyboard layout

### Utilities (`scripts/utilities/`)
- `create-live-usb.sh` - Create bootable USB drives
- `find-file.sh` - Quick file search
- `toggle-touchpad.sh` - Enable/disable touchpad
- `toggle-xbacklight-brightness.sh` - Adjust screen brightness
- `tj` - Quick journal/notes tool
- `versions` - Show installed tool versions
- `unbeep` - Disable system beep

## Directory Structure

```
.dotfiles/
├── i3/                    # i3 window manager
├── tmux/                  # Tmux multiplexer
├── alacritty/             # Alacritty terminal
├── nvim-new/              # Neovim (current)
├── nvim/                  # Neovim (legacy)
├── zsh/                   # Zsh shell
├── polybar/               # Status bar
├── rofi/                  # Application launcher
├── dunst/                 # Notifications
├── gitconfig/             # Git configuration
├── scripts/               # Utility scripts
│   ├── kb/               # Keyboard layout scripts
│   ├── utilities/        # General utilities
│   └── containers/       # Container-related scripts
├── xinit/                 # X initialization
├── xrandr-screenlayout/   # Screen layouts
├── autorandr-screenlayout/# Auto screen layouts
├── wallpaper/             # Wallpapers
├── firefox/               # Firefox config
└── README.md              # This file
```

## Workflow

### Typical Startup

1. **i3wm** starts with Polybar
2. **`Mod+t`** opens Alacritty with tmux
3. Inside tmux:
   - Create multiple windows (`F2`)
   - Split panes (`Prefix + \` or `Prefix + -`)
   - Navigate with `F3`/`F4` or Vim keys
4. Open Neovim for editing
5. Use Rofi (`Mod+q`) to launch applications

### Development Workflow

1. Open project in tmux window
2. Split panes:
   - Neovim (code editing)
   - Shell (running commands)
   - Tests/logs (monitoring)
3. Use Neovim's Telescope to navigate code
4. Git operations via vgit or fugitive
5. Claude Code for AI assistance

## External Dependencies

### Required
- **stow** - Symlink manager
- **git** - Version control
- **ripgrep** - Fast search (for Neovim/fzf)
- **build-essential** - C compiler (for Neovim plugins)

### Recommended
- **fzf** - Fuzzy finder
- **fd** - Fast find alternative
- **bat** - Better cat
- **exa** - Better ls
- **Node.js** - For Neovim LSP servers
- **Python** - For Neovim plugins
- **Go** - For various tools

See `nvim-new/README.md` for complete Neovim dependencies.

## Customization

### Adding Sensitive Environment Variables

1. Copy the example file:
```bash
cp zsh/.envs.sensitive.example zsh/.envs.sensitive
```

2. Edit `zsh/.envs.sensitive` with your API keys, tokens, etc.
3. This file is gitignored and won't be committed

### Modifying Keybindings

- **i3:** Edit `i3/.config/i3/config`
- **tmux:** Edit `tmux/.config/tmux/tmux.conf`
- **Neovim:** See `nvim-new/README.md`
- **Zsh:** Edit `zsh/.zsh-keybindings`

## Troubleshooting

### Stow conflicts
If stow reports conflicts, backup existing configs:
```bash
mkdir -p ~/.config-backup
mv ~/.config/nvim ~/.config-backup/
mv ~/.zshrc ~/.zshrc.backup
```

### Zsh plugins not loading
Zinit auto-installs on first run. If issues persist:
```bash
rm -rf ~/.local/share/zinit
exec zsh  # Zinit will reinstall
```

### Neovim plugins not working
```vim
:Lazy sync
:checkhealth
```

### Tmux true colors not working
Ensure `$TERM` is set correctly:
```bash
echo $TERM  # Should show 'alacritty'
```

## License

Personal dotfiles - use as you wish.

---

Made with ❤️ for a productive terminal-based workflow.
