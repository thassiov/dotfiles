# Dotfiles

Personal configuration files for a keyboard-driven Linux development environment.

i3wm + Alacritty + tmux + Neovim + Zsh.

## Setup

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

The setup script creates symlinks for all configs and initializes plugin managers (Zinit, TPM, Lazy.nvim).

```bash
./setup.sh              # Symlinks + hooks
./setup.sh --links      # Only symlinks
./setup.sh --hooks      # Only hooks
./setup.sh --dry-run    # Preview changes
./setup.sh --uninstall  # Remove symlinks
```

Symlink mappings are defined in `setup.json`.

## What's Inside

### Configs

| Directory | Target | What |
|-----------|--------|------|
| `i3/` | `~/.config/i3` | i3wm with modular configs in `config.d/`. py3status bar. |
| `zsh/` | `~/.zshrc` | Zinit + Powerlevel10k. Modular: `env/`, `plugins/`, `shell/`, `config/`. |
| `tmux/` | `~/.config/tmux` | Tokyo Night theme. Prefix `Ctrl+x`. TPM for plugins. |
| `nvim/` | `~/.config/nvim` | Lazy.nvim, LSP via Mason, Telescope, Claude Code integration. |
| `alacritty/` | `~/.config/alacritty` | Kanagawa theme. FiraMono Nerd Font. |
| `rofi/` | `~/.config/rofi` | Arc-Dark theme. Launchers for run, dmenu, window, emoji. |
| `dunst/` | `~/.config/dunst` | Notification daemon. |
| `gitconfig/` | `~/.gitconfig` | Delta diffs, lazygit, nvim as editor. |
| `autorandr/` | `~/.config/autorandr` | 10 display profiles with auto-detection. |
| `xrandr/` | `~/.screenlayout` | 15 manual monitor layout scripts. |
| `i3status/` | `~/.config/i3status` | Config consumed by py3status. |
| `py3status/` | `~/.config/py3status` | Custom modules: temps, brightness, battery notifications. |
| `cmdvault/` | `~/.config/cmdvault/commands` | Searchable command snippets. |
| `xinit/` | `~/.xinitrc` | Starts i3. |
| `wallpaper/` | (referenced by path) | Desktop wallpapers. |

### Scripts

| Script | Purpose |
|--------|---------|
| `scripts/kb/togglekblayouts` | Toggle US/BR keyboard layout (`Mod+Backspace`) |
| `scripts/utilities/set-wallpaper.sh` | Set wallpaper on all monitors |
| `scripts/utilities/toggle-brightness.sh` | Brightness control for laptop + external monitors (DDC/CI) |
| `scripts/utilities/rofi-autorandr.sh` | Rofi menu for display profiles (`Mod+m`) |
| `scripts/utilities/i3-shortcuts-help.sh` | i3 keybindings cheatsheet via rofi (`Mod+Shift+/`) |
| `scripts/utilities/setup-ddc-brightness.sh` | One-time DDC/CI setup for external monitors |
| `scripts/lid-grace/` | Lid close grace period handler (systemd service, install separately) |

## Key Bindings

### i3

| Key | Action |
|-----|--------|
| `Mod+t` | Terminal (Alacritty + tmux) |
| `Mod+Shift+t` | Terminal (no tmux) |
| `Mod+k` | Kill window |
| `Mod+l` | Lock screen |
| `Mod+q` | Rofi run menu |
| `Mod+o` | Rofi emoji picker |
| `Mod+m` | Display profile picker |
| `Mod+space` | Toggle brightness |
| `Mod+Backspace` | Toggle keyboard layout |

### tmux (Prefix: `Ctrl+x`)

| Key | Action |
|-----|--------|
| `Prefix + r` | Reload config |
| `Prefix + \` | Split vertical (current path) |
| `Prefix + -` | Split horizontal (current path) |
| `F2` | New window |
| `F3` / `F4` | Previous / Next window |
| `Prefix + hjkl` | Navigate panes |

### Neovim (Leader: `,`)

| Key | Action |
|-----|--------|
| `<leader>f` | Find files |
| `<leader>g` | Grep text |
| `<leader>b` | Search buffers |

See `nvim/README.md` for full documentation.

## Post-Setup

### Sensitive environment variables

```bash
cp zsh/.envs.sensitive.example zsh/.envs.sensitive
# Edit with your API keys, tokens, etc.
```

### Lid grace handler (optional)

For laptop lid-close grace period when docking/undocking:

```bash
cd scripts/lid-grace
sudo bash install.sh
```

## Troubleshooting

**Zsh plugins not loading:**
```bash
rm -rf ~/.local/share/zinit
exec zsh
```

**Neovim plugins broken:**
```vim
:Lazy sync
:checkhealth
```

**Tmux theme not loading:**
Press `Prefix + I` (Ctrl+x, then Shift+i) to install plugins via TPM.

## License

MIT
