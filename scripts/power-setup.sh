#!/bin/bash
#
# Portus hardware acceleration & power optimization setup
#
# Configures VA-API (hardware video decode/encode), TLP power profiles,
# and thermald for a Dell laptop with i7-1260P and Iris Xe graphics.
#
# Usage:
#   ./power-setup.sh              # Apply all configs
#   ./power-setup.sh --dry-run    # Show what would be done
#   ./power-setup.sh --uninstall  # Reverse all changes
#   ./power-setup.sh --verify     # Run verification checks only
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

DRY_RUN=false
UNINSTALL=false
VERIFY_ONLY=false
BACKUP_SUFFIX=".bak.power-setup.$(date +%Y%m%d%H%M%S)"

log_info()  { echo -e "${CYAN}[info]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[ok]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[warn]${NC}  $1"; }
log_err()   { echo -e "${RED}[error]${NC} $1"; }
log_dry()   { echo -e "${YELLOW}[dry]${NC}   $1"; }
log_step()  { echo -e "\n${BOLD}${CYAN}=== $1 ===${NC}"; }

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run     Show what would be done without doing it"
    echo "  --uninstall   Reverse all changes made by this script"
    echo "  --verify      Run verification checks only"
    echo "  -h, --help    Show this help"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)    DRY_RUN=true; shift ;;
            --uninstall)  UNINSTALL=true; shift ;;
            --verify)     VERIFY_ONLY=true; shift ;;
            -h|--help)    usage; exit 0 ;;
            *)            log_err "Unknown option: $1"; usage; exit 1 ;;
        esac
    done
}

# --- Helpers ---

check_machine() {
    local cpu_model
    cpu_model=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null || echo "")
    if [[ "$cpu_model" != *"i7-1260P"* ]]; then
        log_warn "Expected i7-1260P, got: ${cpu_model##*: }"
        log_warn "This script is designed for Portus. Continue anyway? [y/N]"
        read -r response
        [[ "$response" =~ ^[Yy]$ ]] || exit 1
    fi
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        if $DRY_RUN; then
            log_dry "Would back up $file"
        else
            cp "$file" "${file}${BACKUP_SUFFIX}"
            log_info "Backed up $file"
        fi
    fi
}

write_file() {
    local file="$1"
    local content="$2"
    local needs_sudo="${3:-false}"

    if $DRY_RUN; then
        log_dry "Would write $file"
        return
    fi

    backup_file "$file"

    local dir
    dir=$(dirname "$file")
    if [[ "$needs_sudo" == "true" ]]; then
        sudo mkdir -p "$dir"
        echo "$content" | sudo tee "$file" > /dev/null
    else
        mkdir -p "$dir"
        echo "$content" > "$file"
    fi
    log_ok "Wrote $file"
}

remove_file() {
    local file="$1"
    local needs_sudo="${2:-false}"

    if $DRY_RUN; then
        log_dry "Would remove $file"
        return
    fi

    if [[ -f "$file" ]]; then
        if [[ "$needs_sudo" == "true" ]]; then
            sudo rm "$file"
        else
            rm "$file"
        fi
        log_ok "Removed $file"
    else
        log_info "Already absent: $file"
    fi
}

# --- Package installation ---

install_packages() {
    log_step "Packages"

    local packages=(
        libva-utils
        intel-media-driver
        vulkan-intel
        thermald
        tlp
        tlp-rdw
    )

    if $DRY_RUN; then
        log_dry "Would install: ${packages[*]}"
        return
    fi

    sudo pacman -S --needed --noconfirm "${packages[@]}"
    log_ok "All packages installed"
}

uninstall_packages() {
    log_step "Packages"
    log_info "Packages installed by this script: libva-utils, thermald"
    log_info "Other packages (intel-media-driver, vulkan-intel, tlp, tlp-rdw) were pre-existing"

    if $DRY_RUN; then
        log_dry "Would remove: thermald libva-utils"
        return
    fi

    log_warn "Remove thermald and libva-utils? [y/N]"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo pacman -R --noconfirm thermald libva-utils 2>/dev/null || true
        log_ok "Removed thermald and libva-utils"
    else
        log_info "Skipped package removal"
    fi
}

# --- Chromium VA-API ---

setup_chromium() {
    log_step "Chromium VA-API + GPU acceleration"

    local file="$HOME/.config/chromium-flags.conf"
    local content
    read -r -d '' content <<'CONF' || true
--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,VaapiIgnoreDriverChecks
--disable-features=UseChromeOSDirectVideoDecoder
--enable-gpu-rasterization
--enable-zero-copy
--ignore-gpu-blocklist
CONF

    write_file "$file" "$content"
}

# --- Firefox VA-API ---

setup_firefox() {
    log_step "Firefox VA-API"

    local pref='user_pref("media.ffmpeg.vaapi.enabled", true);'
    local profiles_found=0

    for profile_dir in "$HOME"/.mozilla/firefox/*.default-release "$HOME"/.mozilla/firefox/*.default "$HOME"/.mozilla/firefox/*.dev-edition-default; do
        [[ -d "$profile_dir" ]] || continue
        profiles_found=$((profiles_found + 1))

        local user_js="$profile_dir/user.js"

        # Check if pref already exists
        if [[ -f "$user_js" ]] && grep -q 'media.ffmpeg.vaapi.enabled' "$user_js"; then
            log_ok "Already configured in $user_js"
            continue
        fi

        if $DRY_RUN; then
            log_dry "Would add VA-API pref to $user_js"
            continue
        fi

        backup_file "$user_js"
        echo "$pref" >> "$user_js"
        log_ok "Added VA-API pref to $user_js"
    done

    if [[ $profiles_found -eq 0 ]]; then
        log_warn "No Firefox profiles found"
    fi
}

# --- mpv ---

setup_mpv() {
    log_step "mpv hardware decode"

    local file="$HOME/.config/mpv/mpv.conf"
    local content="hwdec=auto"

    # If mpv.conf exists and already has hwdec, skip
    if [[ -f "$file" ]] && grep -q '^hwdec=' "$file"; then
        log_ok "Already configured in $file"
        return
    fi

    if [[ -f "$file" ]]; then
        # Append to existing config
        if $DRY_RUN; then
            log_dry "Would append hwdec=auto to $file"
            return
        fi
        backup_file "$file"
        echo "$content" >> "$file"
        log_ok "Appended hwdec=auto to $file"
    else
        write_file "$file" "$content"
    fi
}

# --- TLP ---

setup_tlp() {
    log_step "TLP power profiles"

    local file="/etc/tlp.d/01-portus.conf"
    local content
    read -r -d '' content <<'CONF' || true
# Portus power optimization — managed by power-setup.sh
# Dell i7-1260P / Iris Xe / Arch Linux
#
# Profiles:
#   AC (performance) — plugged in, full power
#   BAT (balanced)   — on battery, save power
#   SAV (power-saver)— manual trigger: tlp power-saver

# === CPU ===
# AC: full power, no restrictions
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_BOOST_ON_AC=1
CPU_HWP_DYN_BOOST_ON_AC=1

# BAT: save power, disable turbo
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
CPU_BOOST_ON_BAT=0
CPU_HWP_DYN_BOOST_ON_BAT=0

# SAV: max savings (manual trigger)
CPU_ENERGY_PERF_POLICY_ON_SAV=power
CPU_BOOST_ON_SAV=0
CPU_HWP_DYN_BOOST_ON_SAV=0

# === Platform profile (Dell thermal/fan management) ===
PLATFORM_PROFILE_ON_AC=performance
PLATFORM_PROFILE_ON_BAT=balanced
PLATFORM_PROFILE_ON_SAV=quiet

# === PCIe ASPM ===
PCIE_ASPM_ON_AC=default
PCIE_ASPM_ON_BAT=powersupersave

# === Runtime PM for PCIe devices ===
RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=auto

# === WiFi ===
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# === USB ===
USB_AUTOSUSPEND=1
USB_EXCLUDE_BTUSB=1

# === Audio ===
SOUND_POWER_SAVE_ON_AC=1
SOUND_POWER_SAVE_ON_BAT=1
SOUND_POWER_SAVE_CONTROLLER=Y

# === NMI watchdog ===
NMI_WATCHDOG=0

# === Battery care (Dell) ===
START_CHARGE_THRESH_BAT0=50
STOP_CHARGE_THRESH_BAT0=80

# === Disk ===
AHCI_RUNTIME_PM_ON_AC=on
AHCI_RUNTIME_PM_ON_BAT=auto

# === Intel GPU (battery only) ===
INTEL_GPU_MIN_FREQ_ON_BAT=100
INTEL_GPU_MAX_FREQ_ON_BAT=900
INTEL_GPU_BOOST_FREQ_ON_BAT=1100
CONF

    write_file "$file" "$content" "true"

    if ! $DRY_RUN; then
        log_info "Reloading TLP config..."
        sudo tlp start > /dev/null 2>&1
        log_ok "TLP config reloaded"
    fi
}

# --- thermald ---

setup_thermald() {
    log_step "thermald"

    if $DRY_RUN; then
        log_dry "Would enable thermald.service"
        return
    fi

    sudo systemctl enable --now thermald
    log_ok "thermald enabled and started"
}

# --- Uninstall ---

do_uninstall() {
    log_step "Uninstalling power-setup configs"

    log_info "Removing config files..."
    remove_file "$HOME/.config/chromium-flags.conf"
    remove_file "$HOME/.config/mpv/mpv.conf"
    remove_file "/etc/tlp.d/01-portus.conf" "true"

    # Firefox: remove VA-API pref from user.js
    for profile_dir in "$HOME"/.mozilla/firefox/*.default-release "$HOME"/.mozilla/firefox/*.default "$HOME"/.mozilla/firefox/*.dev-edition-default; do
        [[ -d "$profile_dir" ]] || continue
        local user_js="$profile_dir/user.js"
        if [[ -f "$user_js" ]]; then
            if $DRY_RUN; then
                log_dry "Would remove VA-API pref from $user_js"
            else
                sed -i '/media\.ffmpeg\.vaapi\.enabled/d' "$user_js"
                # Remove file if empty
                [[ -s "$user_js" ]] || rm "$user_js"
                log_ok "Cleaned $user_js"
            fi
        fi
    done

    # Disable thermald
    if systemctl is-active --quiet thermald 2>/dev/null; then
        if $DRY_RUN; then
            log_dry "Would disable thermald"
        else
            sudo systemctl disable --now thermald
            log_ok "thermald disabled"
        fi
    fi

    # Reload TLP to clear drop-in
    if ! $DRY_RUN; then
        sudo tlp start > /dev/null 2>&1 || true
        log_ok "TLP config reloaded (drop-in removed)"
    fi

    uninstall_packages

    log_step "Uninstall complete"
    log_info "Restart Chromium and Firefox to revert to software video decode"
    log_info "Battery threshold will revert on next TLP reload or reboot"
}

# --- Verification ---

do_verify() {
    log_step "VA-API"
    if command -v vainfo &>/dev/null; then
        vainfo 2>&1 | grep -E '(Driver|Profile)' | head -15
    else
        log_err "vainfo not found — install libva-utils"
    fi

    log_step "TLP"
    if command -v tlp-stat &>/dev/null; then
        echo ""
        log_info "TLP status:"
        sudo tlp-stat -s 2>/dev/null | grep -E '(State|Mode|Config)' || true
        echo ""
        log_info "CPU settings:"
        sudo tlp-stat -p 2>/dev/null | grep -E '(energy_perf|boost|platform_profile)' || true
    else
        log_err "tlp-stat not found"
    fi

    log_step "thermald"
    if systemctl is-active --quiet thermald 2>/dev/null; then
        log_ok "thermald is running"
    else
        log_err "thermald is not running"
    fi

    log_step "Platform profile"
    local profile
    profile=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo "unknown")
    local ac
    ac=$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo "?")
    if [[ "$ac" == "1" ]]; then
        log_info "On AC — profile: $profile (expected: performance)"
    else
        log_info "On battery — profile: $profile (expected: balanced)"
    fi

    log_step "Battery care"
    local start_thresh stop_thresh
    start_thresh=$(cat /sys/class/power_supply/BAT0/charge_control_start_threshold 2>/dev/null || echo "?")
    stop_thresh=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || echo "?")
    log_info "Charge thresholds: start=$start_thresh%, stop=$stop_thresh%"

    log_step "Config files"
    for f in \
        "$HOME/.config/chromium-flags.conf" \
        "$HOME/.config/mpv/mpv.conf" \
        "/etc/tlp.d/01-portus.conf"; do
        if [[ -f "$f" ]]; then
            log_ok "$f"
        else
            log_warn "$f — missing"
        fi
    done

    # Check Firefox profiles
    for profile_dir in "$HOME"/.mozilla/firefox/*.default-release "$HOME"/.mozilla/firefox/*.default "$HOME"/.mozilla/firefox/*.dev-edition-default; do
        [[ -d "$profile_dir" ]] || continue
        local user_js="$profile_dir/user.js"
        if [[ -f "$user_js" ]] && grep -q 'media.ffmpeg.vaapi.enabled' "$user_js"; then
            log_ok "$user_js (VA-API enabled)"
        else
            log_warn "$user_js — VA-API pref missing"
        fi
    done

    log_step "Manual steps"
    echo -e "${YELLOW}Chromium:${NC} Restart browser, then check:"
    echo "  chrome://gpu         — 'Video Decode: Hardware accelerated'"
    echo "  chrome://media-internals — play a video, look for hardware decoder"
    echo ""
    echo -e "${YELLOW}OBS:${NC} Settings > Output > Recording > Encoder:"
    echo "  Change from 'x264' to 'Hardware (QSV, H.264)'"
    echo "  The obs-qsv11.so plugin is already installed."
}

# --- Main ---

main() {
    parse_args "$@"

    echo -e "${BOLD}Portus power optimization setup${NC}"
    echo ""

    if $VERIFY_ONLY; then
        do_verify
        exit 0
    fi

    if $UNINSTALL; then
        do_uninstall
        exit 0
    fi

    if $DRY_RUN; then
        log_info "Dry run — no changes will be made"
        echo ""
    fi

    check_machine

    install_packages
    setup_chromium
    setup_firefox
    setup_mpv
    setup_tlp
    setup_thermald

    echo ""
    do_verify
}

main "$@"
