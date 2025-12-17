# i3 Window Manager Setup

Complete i3 setup with status bar, temperature monitoring, keyboard layouts, and custom shortcuts.

## Table of Contents

1. [Dependencies](#dependencies)
2. [Installation](#installation)
3. [Features](#features)
4. [Custom Status Bar](#custom-status-bar)
5. [Keyboard Layouts](#keyboard-layouts)
6. [Shortcuts Palette](#shortcuts-palette)
7. [Troubleshooting](#troubleshooting)

---

## Dependencies

### Core Requirements

#### Arch Linux
```bash
sudo pacman -S \
    i3-wm \
    i3status \
    i3blocks \
    python-py3status \
    rofi \
    alacritty \
    pcmanfm \
    xorg-xset \
    xorg-setxkbmap \
    xdotool \
    lm_sensors \
    dunst \
    libnotify \
    feh \
    xorg-xbacklight \
    xlock \
    pactl \
    playerctl \
    blueman \
    network-manager-applet \
    parcellite \
    ffmpeg
```

#### Ubuntu/Debian
```bash
sudo apt install \
    i3 \
    i3status \
    i3blocks \
    python3-pip \
    rofi \
    alacritty \
    pcmanfm \
    x11-xserver-utils \
    xdotool \
    lm-sensors \
    dunst \
    libnotify-bin \
    feh \
    xbacklight \
    xlockmore \
    pulseaudio-utils \
    playerctl \
    blueman \
    network-manager-gnome \
    parcellite \
    ffmpeg

# Install py3status via pip
pip3 install --user py3status
```

### Optional (Recommended)

**Fonts with emoji support:**
```bash
# Arch
sudo pacman -S ttf-font-awesome noto-fonts-emoji

# Ubuntu
sudo apt install fonts-font-awesome fonts-noto-color-emoji
```

**Detect sensors:**
```bash
# Run once to detect all hardware sensors
sudo sensors-detect --auto
```

---

## Installation

### 1. Link Configuration Files

Using GNU Stow (recommended):
```bash
cd ~/.dotfiles
stow i3
stow i3status      # Status bar config
stow py3status     # Custom py3status modules
stow rofi
stow scripts
```

Or manually:
```bash
ln -s ~/.dotfiles/i3/.config/i3 ~/.config/i3
ln -s ~/.dotfiles/i3status/.config/i3status ~/.config/i3status
ln -s ~/.dotfiles/py3status/.config/py3status ~/.config/py3status
ln -s ~/.dotfiles/rofi/.config/rofi ~/.config/rofi
```

### 2. Verify Custom Modules

```bash
# Check py3status custom modules are linked
ls -la ~/.config/py3status/modules/temps.py
ls -la ~/.config/py3status/modules/battery_notify.py

# Should show: ~/.config/py3status -> ~/.dotfiles/py3status/.config/py3status
```

### 3. Setup Battery Alert Sound

```bash
# Generate the custom alert sound
mkdir -p ~/.local/share/sounds
ffmpeg -y -f lavfi -i "sine=frequency=880:duration=0.5" -af "volume=0.6" ~/.local/share/sounds/battery-alert.wav
```

### 4. Setup Keyboard Layouts

The keyboard layout scripts support both X11 and TTY:
```bash
# Make scripts executable
chmod +x ~/.dotfiles/scripts/kb/togglekblayouts
chmod +x ~/.dotfiles/scripts/kb/useuskb
chmod +x ~/.dotfiles/scripts/kb/useabntkb

# For TTY support (optional), you may need sudo access for loadkeys
# Add to /etc/sudoers if you want passwordless layout switching in TTY:
# yourusername ALL=(ALL) NOPASSWD: /usr/bin/loadkeys
```

### 5. Reload i3

```bash
i3-msg reload
# or
i3-msg restart
```

---

## Features

### Custom Status Bar (py3status)

The status bar shows:
- Disk usage (/, /home, /storage) - percentage used
- Network status (WiFi/Ethernet)
- Volume with click-to-mute
- Keyboard layout (US/BR)
- CPU usage and temperature: `CPU 45% (79°C)`
- Chassis temperature and fan speed: `💻 52°C 🌀 6k`
- RAM usage - percentage
- Battery level and time remaining
- Date and time: `YYYY-MM-DD HH:MM:SS`

**Interactive features:**
- Click volume to toggle mute
- Scroll on volume to adjust
- Auto-updates on keyboard layout change

### Battery Notifications

Uses custom py3status module (`~/.config/py3status/modules/battery_notify.py`) to monitor battery level and alert when low.

**Thresholds and Actions:**

| Battery | Notification | Duration | Sound | Screen |
|---------|--------------|----------|-------|--------|
| 20% | Normal | 8 sec | 1x beep | - |
| 10% | Critical | 30 sec | 3x beep | Dims to minimum |
| 5% | Critical | 30 sec | 3x beep | - |

**Features:**
- Notifications via dunst with appropriate urgency levels
- Custom 3-beep alert sound (`~/.local/share/sounds/battery-alert.wav`)
- Screen dims to minimum brightness at 10% to save power
- Screen restores to 60% brightness when charger is plugged in
- Notifications reset when charging (will alert again next discharge cycle)

**Custom Alert Sound:**

The alert sound is generated with ffmpeg. To regenerate:
```bash
mkdir -p ~/.local/share/sounds
ffmpeg -y -f lavfi -i "sine=frequency=880:duration=0.5" -af "volume=0.6" ~/.local/share/sounds/battery-alert.wav
```

**Dependencies:**
- `notify-send` (libnotify) - for notifications
- `paplay` (pulseaudio) - for playing alert sounds
- `xbacklight` - for screen dimming

### Temperature Monitoring

Uses custom py3status module (`~/.config/py3status/modules/temps.py`) to display:
- **CPU temperature**: From coretemp sensor
- **Chassis temperature**: From Dell ambient sensor
- **Fan speed**: In "k" format (6000 RPM = 6k)

**Sensors used:**
- CPU: `coretemp-isa-0000`
- Chassis: `dell_ddv-virtual-0` (Ambient)
- Fan: `dell_ddv-virtual-0` (CPU Fan)

### Keyboard Layouts

**Features:**
- Toggle between US-DEV and BR-DEV layouts
- Works in both X11 and TTY/console
- Custom modifications:
  - **Caps Lock → Escape**
  - Esc key → apostrophe/quote/tilde
  - C key with cedilla (ç/Ç) in US layout
  - Dead keys for accents
  - AltGr as Mode_switch

**Toggle:**
- `Super + Backspace` - Switch between layouts
- Status bar shows current layout

**Files:**
- X11 scripts: `~/.dotfiles/scripts/kb/useuskb`, `useabntkb`
- Console keymaps: `~/.dotfiles/scripts/kb/keymaps/console/`
- Toggle script: `~/.dotfiles/scripts/kb/togglekblayouts`

### Shortcuts Palette

Press `Super + ?` (Super + Shift + /) to open an interactive command palette showing all i3 shortcuts.

**Features:**
- Browse all keybindings organized by category
- Search/filter shortcuts
- Execute commands directly by selecting and pressing Enter
- Categories: Applications, Window Management, Workspaces, System, Media

**File:** `~/.dotfiles/scripts/utilities/i3-shortcuts-help.sh`

---

## Custom Status Bar

### Configuration Files

- **i3 bar config**: `~/.config/i3/config` (lines 156-176)
- **i3status config**: `~/.config/i3status/config`
- **Custom module**: `~/.config/py3status/modules/temps.py`

### Module Details

#### Standard Modules

All from i3status/py3status:
- `disk` - Disk usage
- `wireless` / `ethernet` - Network
- `volume_status` - Volume control (py3status)
- `keyboard_layout` - Layout indicator (py3status)
- `cpu_usage` - CPU percentage
- `sysdata` - CPU temp and usage (py3status)
- `memory` - RAM usage
- `battery` - Battery status
- `tztime` - Date/time

#### Custom Module: battery_notify.py

**Location:** `~/.config/py3status/modules/battery_notify.py`

**What it does:**
- Monitors battery level every 30 seconds
- Sends dunst notifications at 20%, 10%, and 5%
- Plays alert sound (3x repeats for critical levels)
- Dims screen at 10%, restores brightness when charging

**Configuration in i3status config:**
```ini
battery_notify {
        cache_timeout = 30
}
```

#### Custom Module: temps.py

**Location:** `~/.config/py3status/modules/temps.py`

**What it does:**
- Reads chassis temperature from `sensors dell_ddv-virtual-0`
- Reads fan speed from same sensor
- Formats fan speed as "6k" for readability

**Configuration in i3status config:**
```ini
temps {
        format = "💻 {chassis}°C 🌀 {fan_speed}"
        cache_timeout = 5
}
```

**Dependencies:**
- `lm_sensors` package
- `sensors` command available in PATH

---

## Keyboard Layouts

### How It Works

The toggle script detects the environment:
- **X11**: Uses `setxkbmap` and `xmodmap`
- **TTY/Console**: Uses `loadkeys` with custom keymaps
- **Wayland**: Placeholder for future support

### Console Keymaps

Located in: `~/.dotfiles/scripts/kb/keymaps/console/`

Files:
- `us-dev.map` - US layout with customizations
- `br-dev.map` - Brazilian ABNT2 with customizations

Both include:
- Caps Lock → Escape mapping
- Custom dead keys
- Cedilla support

### Testing

```bash
# In X11
~/.dotfiles/scripts/kb/togglekblayouts

# In TTY (Ctrl+Alt+F2)
sudo ~/.dotfiles/scripts/kb/togglekblayouts
```

---

## Configuration Files

### Main i3 Config

`~/.dotfiles/i3/.config/i3/config`

Key sections:
- Lines 1-10: Variables and fonts
- Lines 13-33: Application launchers
- Lines 62-71: Window navigation
- Lines 99-114: Workspaces
- Lines 156-176: Status bar configuration
- Lines 177-186: Startup applications

### i3status Config

`~/.config/i3status/config`

**Important settings:**
- `cache_timeout` values control update frequency
- `keyboard_layout` has 0.5s timeout for responsiveness
- Battery uses `last_full_capacity = true` for accurate percentage

### Status Bar Colors

Defined in i3 config (lines 162-172):
```
background: #282A2E
statusline: #C5C8C6
separator: #C5C8C6

focused_workspace: #F0C674 / #373B41
inactive_workspace: #282A2E / #282A2E
urgent_workspace: #A54242 / #A54242
```

---

## Troubleshooting

### py3status errors

```bash
# Check py3status is running
pgrep -a py3status

# Reload py3status
pkill -SIGUSR1 py3status

# Restart i3
i3-msg restart
```

### Temperature not showing

```bash
# Check sensors are detected
sensors

# Re-detect sensors
sudo sensors-detect --auto

# Test custom module
python3 -c "import sys; sys.path.insert(0, '/home/thassiov/.config/py3status/modules'); import temps; t = temps.Py3status(); print('Chassis:', t._get_chassis_temp(), 'Fan:', t._get_fan_speed())"
```

### Keyboard layout not switching

```bash
# Check current layout (X11)
setxkbmap -query

# Check if scripts are executable
ls -la ~/.dotfiles/scripts/kb/togglekblayouts

# Test manually
~/.dotfiles/scripts/kb/togglekblayouts
```

### Volume control not working

```bash
# Check pulseaudio is running
pactl info

# Test volume command
pactl set-sink-volume @DEFAULT_SINK@ +5%

# Install py3status if missing
pip3 install --user py3status
```

### Shortcuts palette not opening

```bash
# Check script exists and is executable
ls -la ~/.dotfiles/scripts/utilities/i3-shortcuts-help.sh

# Test rofi
rofi -show run

# Check keybinding (Super + Shift + /)
grep "Shift+slash" ~/.config/i3/config
```

---

## Package List Summary

### Arch Linux - Complete Installation

```bash
# Core i3 and status bar
sudo pacman -S i3-wm i3status i3blocks python-py3status

# Applications
sudo pacman -S rofi alacritty pcmanfm

# X utilities
sudo pacman -S xorg-xset xorg-setxkbmap xdotool xorg-xbacklight

# System monitoring
sudo pacman -S lm_sensors

# Notifications and wallpaper
sudo pacman -S dunst libnotify feh

# Audio and media
sudo pacman -S pulseaudio pulseaudio-alsa playerctl

# Battery notification sound generation (optional)
sudo pacman -S ffmpeg

# System tray apps
sudo pacman -S blueman network-manager-applet parcellite

# Screen lock
sudo pacman -S xscreensaver  # or xlockmore

# Fonts (optional but recommended)
sudo pacman -S ttf-font-awesome noto-fonts-emoji
```

### Ubuntu - Complete Installation

```bash
sudo apt update

# Core i3 and status bar
sudo apt install i3 i3status i3blocks python3-pip
pip3 install --user py3status

# Applications
sudo apt install rofi alacritty pcmanfm

# X utilities
sudo apt install x11-xserver-utils xdotool xbacklight

# System monitoring
sudo apt install lm-sensors

# Notifications and wallpaper
sudo apt install dunst libnotify-bin feh

# Audio and media
sudo apt install pulseaudio-utils playerctl

# Battery notification sound generation (optional)
sudo apt install ffmpeg

# System tray apps
sudo apt install blueman network-manager-gnome parcellite

# Screen lock
sudo apt install xlockmore

# Fonts (optional but recommended)
sudo apt install fonts-font-awesome fonts-noto-color-emoji

# Detect hardware sensors
sudo sensors-detect --auto
```

---

## Quick Start

After installing dependencies:

```bash
# 1. Clone dotfiles (if not done)
git clone <your-repo> ~/.dotfiles

# 2. Link configs with stow
cd ~/.dotfiles
stow i3
stow i3status
stow py3status
stow rofi
stow scripts

# 5. Make scripts executable
chmod +x ~/.dotfiles/scripts/kb/togglekblayouts
chmod +x ~/.dotfiles/scripts/utilities/i3-shortcuts-help.sh

# 6. Detect sensors
sudo sensors-detect --auto

# 7. Start i3 or reload
i3-msg restart
```

---

## Credits

- Status bar: py3status (https://github.com/ultrabug/py3status)
- Temperature module: Custom implementation
- Keyboard layouts: Custom keymaps for X11 and console
- Icons: Font Awesome, Noto Emoji

---

## Additional Resources

- i3 User's Guide: https://i3wm.org/docs/userguide.html
- py3status Documentation: https://py3status.readthedocs.io/
- i3status Manual: `man i3status`
- Rofi Documentation: https://github.com/davatorium/rofi
