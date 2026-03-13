# Dotfiles Audit

Comprehensive audit of the repository state, performed 2026-03-13.

---

## Program Configs (12 active)

| Directory | Program | Notes |
|-----------|---------|-------|
| `i3/` | i3 window manager | Core WM. Split configs in `config.d/`. Bar uses py3status. |
| `zsh/` | Zsh shell | Modular: `config/`, `env/`, `init/`, `plugins/`, `shell/`. Zinit + Powerlevel10k. |
| `tmux/` | Tmux | Tokyo Night theme. Prefix `C-x`. Plugins via tpm. |
| `alacritty/` | Alacritty terminal | Kanagawa theme. TOML config only. |
| `nvim-new/` | Neovim | Lazy.nvim, modular plugins, Claude Code integration. |
| `rofi/` | Rofi launcher | Arc-Dark theme. Four launcher scripts (run, dmenu, window, emoji). |
| `dunst/` | Dunst notifications | Referenced in i3 startup and battery_notify.py. |
| `gitconfig/` | Git | Uses delta for diffs, lazygit, nvim as editor. |
| `xinit/` | X11 init | Starts i3. |
| `autorandr-screenlayout/` | autorandr | 10 display profiles. Postswitch hook resets wallpaper. |
| `xrandr-screenlayout/` | xrandr | 15 manual monitor layout scripts. |
| `i3status/` | i3status / py3status | Config consumed by py3status. Required for the status bar. |
| `py3status/` | py3status modules | Custom modules: `temps.py`, `brightness.py`, `battery_notify.py`. |
| `cmdvault/` | cmdvault snippets | Symlinked to `~/.config/cmdvault/commands`. |

---

## Scripts

### Active

| Script | Purpose | Referenced By |
|--------|---------|---------------|
| `scripts/kb/togglekblayouts` | Toggle US/BR keyboard layout | i3 config (`$mod+Backspace`) |
| `scripts/kb/useuskb` | Set US keyboard with xmodmap | togglekblayouts |
| `scripts/kb/useabntkb` | Set ABNT2 keyboard with xmodmap | togglekblayouts |
| `scripts/utilities/set-wallpaper.sh` | Set wallpaper on all monitors via feh | i3 startup, autorandr postswitch |
| `scripts/utilities/toggle-brightness.sh` | Unified brightness (xbacklight + DDC/CI for external) | i3 config (`$mod+space`) |
| `scripts/utilities/rofi-autorandr.sh` | Rofi menu for autorandr profiles | i3 config (`$mod+m`) |
| `scripts/utilities/i3-shortcuts-help.sh` | Interactive i3 keybindings via rofi | i3 config (`$mod+Shift+/`) |
| `scripts/utilities/setup-ddc-brightness.sh` | One-time DDC/CI setup (ddcutil, i2c-dev) | Manual, one-time |
| `scripts/lid-grace/` | Lid close grace period handler | systemd service (to be installed) |

### To Revisit

| Script | Notes |
|--------|-------|
| `scripts/containers/` (6 files) | Docker run scripts for dns, logging, pgadmin, httpd. Pre-dates grid.local. Needs review and modernization. |

---

## Non-Config Content

| Item | Status | Notes |
|------|--------|-------|
| `wallpaper/` (3 images) | Active | Referenced by `set-wallpaper.sh`. |
| `.claude/settings.local.json` | Active | Machine-specific Claude Code permissions. |
| `README.md` | Severely outdated | Needs rewrite to match current state. |
| `LICENSE.md` | Active | MIT, Copyright 2016. |
| `AUDIT.md` | Active | This file. |

---

## Remaining Issues

### Stale References in Active Configs

These need review -- some content is still useful.

| Config | Reference | Issue |
|--------|-----------|-------|
| `zsh/env/exports.zsh` | `RUBY_PATH=~/.local/share/gem/ruby/2.7.0/bin` | Ruby 2.7 is EOL |
| `zsh/env/exports.zsh` | `BROWSER=brave` | May not be installed everywhere |
| `zsh/shell/functions.zsh` | `exa` | Renamed to `eza` upstream |
| `zsh/shell/aliases.zsh` | `VBoxManage` | VirtualBox may not be installed |
| `zsh/plugins/omz-plugins.zsh` | `kubectl`, `kubectx` | May not be relevant on all machines |

### Stow / Makefile Decision

Stow is not actively used. The `Makefile` and `.stow-local-ignore` remain but are outdated. Decision pending on whether to remove stow entirely and replace with an install script or manual symlinks.

### README.md

Severely outdated. Needs a full rewrite to reflect the current state of the repo.

---

## Cleanup Performed (2026-03-13)

### Deleted Directories
- `grafatui/` -- unused Grafana TUI config
- `firefox/` -- rarely used userChrome.css
- `nvim/` -- legacy kickstart.nvim config, superseded by `nvim-new/`
- `polybar/` -- disabled in i3 config, dead
- `old/` -- entire archive directory (bashrc, vimrc, Xresources, byobu, mpd, ncmpcpp, nvim-legacy-configs, old polybar, termite, terminator, tablet_screen, tmux-scripts, vscode)
- `dev-machine-setup-templates/` -- outdated Arch install templates
- `txt/` -- single stale nvim.md file
- `scripts/new-scripts-to-test/` -- abandoned Logseq experiment

### Deleted Scripts
- `scripts/utilities/toggle-touchpad.sh` -- unused
- `scripts/utilities/find-file.sh` -- unused
- `scripts/utilities/unbeep` -- unused
- `scripts/utilities/tj` -- pre-vault journal tool
- `scripts/utilities/versions` -- half broken
- `scripts/utilities/create-live-usb.sh` -- broken shebang, stale
- `scripts/utilities/install-printer.sh` -- one-time, stale
- `scripts/utilities/watch-tmp-apps-source-storage.sh` -- niche, stale
- `scripts/utilities/toggle-xbacklight-brightness.sh` -- superseded by `toggle-brightness.sh`
- `scripts/kb/togglekblayouts.backup` -- old backup

### Deleted Files
- `alacritty/.config/alacritty/alacritty.yml` -- legacy YAML format
- `ROADMAP.md` -- backed up to `~/.local/share/grid/pending-docs/` for vault sync

### Removed Tracked Junk
- `zsh/.zcompdump` -- generated completion cache
- `py3status/.config/py3status/modules/__pycache__/` -- compiled Python cache
- `tmux/.config/tmux/plugins/tmux/` -- unused catppuccin theme
- `tmux/.config/tmux/plugins/tmux2k/` -- unused theme
- `tmux/.config/tmux/plugins/tokyo-night-tmux.old/` -- old version of active theme

### Updated .gitignore
- Added `*.pyc`, `__pycache__/`, `zsh/.zcompdump`
- Removed stale mpd and nvim entries

### Added
- `scripts/lid-grace/` -- laptop lid close grace period handler (new)
