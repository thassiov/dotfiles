#!/bin/bash
#
# eww bar — install dependencies
#
# Installs eww and the tools needed by the bar scripts.
# Run once on a fresh machine.
#
# Usage:
#   ./install.sh              # Install everything
#   ./install.sh --check      # Only check what's missing
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CHECK_ONLY=false
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

log_ok()   { echo -e "${GREEN}[ok]${NC}    $1"; }
log_miss() { echo -e "${YELLOW}[miss]${NC}  $1"; }
log_info() { echo -e "${CYAN}[info]${NC}  $1"; }
log_err()  { echo -e "${RED}[err]${NC}   $1"; }

# --- Package lists ---

# Pacman packages (official repos)
PACMAN_DEPS=(
    jq              # JSON parsing in bar scripts
    curl            # Fetch metrics from Alloy
    gtk3            # eww dependency
    libdbusmenu-gtk3 # eww dependency
    gtk-layer-shell # eww dependency
    brightnessctl   # Screen brightness
    playerctl       # Media player info
    libpulse         # pactl for volume (works with PipeWire)
)

# AUR packages
AUR_DEPS=(
    eww             # The widget system itself
)

# --- Check what's installed ---

missing_pacman=()
missing_aur=()

echo ""
log_info "Checking dependencies..."
echo ""

for pkg in "${PACMAN_DEPS[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        log_ok "$pkg"
    else
        log_miss "$pkg"
        missing_pacman+=("$pkg")
    fi
done

for pkg in "${AUR_DEPS[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        log_ok "$pkg (AUR)"
    else
        log_miss "$pkg (AUR)"
        missing_aur+=("$pkg")
    fi
done

# Check for tools that might come from different packages
echo ""
log_info "Checking CLI tools..."
echo ""

check_tool() {
    local tool="$1"
    local note="${2:-}"
    if command -v "$tool" &>/dev/null; then
        log_ok "$tool$([ -n "$note" ] && echo " ($note)")"
    else
        log_miss "$tool$([ -n "$note" ] && echo " ($note)")"
    fi
}

check_tool setxkbmap "keyboard layout — part of xorg-setxkbmap"
check_tool pactl "volume control — part of pulseaudio-utils or pipewire-pulse"
check_tool brightnessctl "brightness"
check_tool playerctl "media controls"
check_tool jq "JSON parsing"
check_tool curl "HTTP requests"
check_tool eww "widget system"

# Check Alloy is running (the data source)
echo ""
log_info "Checking Alloy metrics endpoint..."
if curl -sf -o /dev/null --max-time 2 'http://localhost:12345/api/v0/component/prometheus.exporter.unix.node/metrics'; then
    log_ok "Alloy metrics endpoint reachable at localhost:12345"
else
    log_miss "Alloy metrics endpoint not reachable — bar will work but system metrics will be unavailable"
fi

# --- Install if not check-only ---

if $CHECK_ONLY; then
    echo ""
    if [[ ${#missing_pacman[@]} -eq 0 && ${#missing_aur[@]} -eq 0 ]]; then
        log_ok "All dependencies installed."
    else
        log_info "Missing packages: ${missing_pacman[*]:-} ${missing_aur[*]:-}"
        log_info "Run without --check to install."
    fi
    exit 0
fi

if [[ ${#missing_pacman[@]} -gt 0 ]]; then
    echo ""
    log_info "Installing pacman packages: ${missing_pacman[*]}"
    sudo pacman -S --needed "${missing_pacman[@]}"
fi

if [[ ${#missing_aur[@]} -gt 0 ]]; then
    echo ""
    # Detect AUR helper
    if command -v yay &>/dev/null; then
        AUR_HELPER=yay
    elif command -v paru &>/dev/null; then
        AUR_HELPER=paru
    else
        log_err "No AUR helper found (yay or paru). Install one first, or build eww manually."
        log_info "  yay -S eww"
        exit 1
    fi

    log_info "Installing AUR packages with $AUR_HELPER: ${missing_aur[*]}"
    $AUR_HELPER -S --needed --pgpfetch=false --mflags "--skippgpcheck" "${missing_aur[@]}"
fi

echo ""
log_ok "All dependencies installed."
log_info "Next: run dotfiles setup.sh to create symlinks, then 'eww open bar' to start."
