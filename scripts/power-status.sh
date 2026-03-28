#!/bin/bash
#
# Power & thermal tuning status snapshot
#
# Shows every tuning knob and its current value in a readable table.
# No sudo required — reads directly from sysfs/procfs.
#
# Usage:
#   power-status          # Full snapshot
#   power-status --short  # One-line summary
#

set -euo pipefail

# Colors
C='\033[0;36m'    # cyan
G='\033[0;32m'    # green
Y='\033[0;33m'    # yellow
R='\033[0;31m'    # red
D='\033[0;90m'    # dim
B='\033[1m'       # bold
NC='\033[0m'      # reset

SHORT=false
[[ "${1:-}" == "--short" ]] && SHORT=true

# --- Helpers ---

read_sys() { cat "$1" 2>/dev/null || echo "n/a"; }

# Print a row: label, value, description
row() {
    local label="$1" value="$2" desc="$3"
    printf "  ${B}%-22s${NC} %-28s ${D}%s${NC}\n" "$label" "$value" "$desc"
}

section() {
    echo ""
    echo -e "${C}${B}$1${NC}"
    echo -e "${C}$(printf '%.0s─' {1..70})${NC}"
}

# Color a value based on a condition
color_val() {
    local val="$1" good="$2"
    if [[ "$val" == "$good" ]]; then
        echo -e "${G}${val}${NC}"
    else
        echo -e "${Y}${val}${NC}"
    fi
}

# --- Data collection ---

# Power source
ac_online=$(read_sys /sys/class/power_supply/AC/online)
if [[ "$ac_online" == "1" ]]; then
    power_source="AC"
    power_icon="${G}AC${NC}"
else
    power_source="battery"
    power_icon="${Y}Battery${NC}"
fi

# Platform profile
platform_profile=$(read_sys /sys/firmware/acpi/platform_profile)
platform_choices=$(read_sys /sys/firmware/acpi/platform_profile_choices)

# CPU
epp=$(read_sys /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)
governor=$(read_sys /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
turbo_disabled=$(read_sys /sys/devices/system/cpu/intel_pstate/no_turbo)
if [[ "$turbo_disabled" == "0" ]]; then turbo="on"; else turbo="off"; fi
max_perf=$(read_sys /sys/devices/system/cpu/intel_pstate/max_perf_pct)
hwp_dyn=$(read_sys /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost)
if [[ "$hwp_dyn" == "1" ]]; then hwp_boost="on"; else hwp_boost="off"; fi
pstate_status=$(read_sys /sys/devices/system/cpu/intel_pstate/status)
epp_choices=$(read_sys /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences)
gov_choices=$(read_sys /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)

# Current CPU freq (average across all cores)
freq_sum=0
freq_count=0
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
    [[ -f "$f" ]] || continue
    freq=$(cat "$f" 2>/dev/null || echo 0)
    freq_sum=$((freq_sum + freq))
    freq_count=$((freq_count + 1))
done
if [[ $freq_count -gt 0 ]]; then
    avg_freq_mhz=$(( freq_sum / freq_count / 1000 ))
else
    avg_freq_mhz="n/a"
fi

max_freq_mhz=$(( $(read_sys /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq) / 1000 ))
min_freq_mhz=$(( $(read_sys /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq) / 1000 ))

# Thermal
pkg_temp="n/a"
for hwmon in /sys/class/hwmon/hwmon*/; do
    name=$(cat "${hwmon}name" 2>/dev/null || echo "")
    if [[ "$name" == "coretemp" ]]; then
        raw=$(cat "${hwmon}temp1_input" 2>/dev/null || echo 0)
        pkg_temp="$((raw / 1000))°C"
        break
    fi
done

# Fans
fan1_rpm="n/a"
fan2_rpm="n/a"
for hwmon in /sys/class/hwmon/hwmon*/; do
    name=$(cat "${hwmon}name" 2>/dev/null || echo "")
    if [[ "$name" == "dell_smm" ]]; then
        fan1_rpm=$(cat "${hwmon}fan1_input" 2>/dev/null || echo "n/a")
        fan2_rpm=$(cat "${hwmon}fan2_input" 2>/dev/null || echo "n/a")
        break
    fi
done

# NVMe temp
nvme_temp="n/a"
for hwmon in /sys/class/hwmon/hwmon*/; do
    name=$(cat "${hwmon}name" 2>/dev/null || echo "")
    if [[ "$name" == "nvme" ]]; then
        raw=$(cat "${hwmon}temp1_input" 2>/dev/null || echo 0)
        nvme_temp="$((raw / 1000))°C"
        break
    fi
done

# thermald
if systemctl is-active --quiet thermald 2>/dev/null; then
    thermald_status="${G}active${NC}"
else
    thermald_status="${R}inactive${NC}"
fi

# ASPM
aspm_raw=$(read_sys /sys/module/pcie_aspm/parameters/policy)
# Extract the active policy (between brackets)
aspm_policy=$(echo "$aspm_raw" | grep -oP '\[\K[^\]]+' || echo "$aspm_raw")

# PCIe runtime PM
rpm_active=$(cat /sys/bus/pci/devices/*/power/runtime_status 2>/dev/null | grep -c "active" || echo 0)
rpm_suspended=$(cat /sys/bus/pci/devices/*/power/runtime_status 2>/dev/null | grep -c "suspended" || echo 0)

# WiFi
wifi_ps=$(iw dev wlan0 get power_save 2>/dev/null | awk '{print $NF}' || echo "n/a")

# Battery
bat_capacity=$(read_sys /sys/class/power_supply/BAT0/capacity)
bat_status=$(read_sys /sys/class/power_supply/BAT0/status)
bat_start=$(read_sys /sys/class/power_supply/BAT0/charge_control_start_threshold)
bat_stop=$(read_sys /sys/class/power_supply/BAT0/charge_control_end_threshold)

# Power draw (compute from voltage * current if power_now unavailable)
# Power draw (voltage * current, or power_now if available)
power_now=$(read_sys /sys/class/power_supply/BAT0/power_now)
if [[ "$power_now" != "n/a" && "$power_now" != "0" ]]; then
    power_mw=$(( power_now / 1000 ))
    power_draw="$(( power_mw / 1000 )).$(( power_mw % 1000 / 100 ))W"
else
    voltage=$(read_sys /sys/class/power_supply/BAT0/voltage_now)
    current=$(read_sys /sys/class/power_supply/BAT0/current_now)
    if [[ "$voltage" != "n/a" && "$current" != "n/a" && "$current" != "0" ]]; then
        # voltage in uV, current in uA -> watts = V * A
        power_mw=$(( (voltage / 1000) * (current / 1000) / 1000 ))
        power_draw="$(( power_mw / 1000 )).$(( power_mw % 1000 / 100 ))W"
    else
        power_draw="n/a"
    fi
fi

# USB autosuspend
usb_auto=$(cat /sys/bus/usb/devices/*/power/control 2>/dev/null | grep -c "auto" || echo 0)
usb_on=$(cat /sys/bus/usb/devices/*/power/control 2>/dev/null | grep -c "on" || echo 0)

# Audio power save
snd_ps=$(read_sys /sys/module/snd_hda_intel/parameters/power_save)
snd_ctrl=$(read_sys /sys/module/snd_hda_intel/parameters/power_save_controller)

# NMI watchdog
nmi=$(read_sys /proc/sys/kernel/nmi_watchdog)

# Intel GPU freq (if available)
gpu_cur="n/a"
gpu_min="n/a"
gpu_max="n/a"
for gt in /sys/class/drm/card*/gt/gt*/; do
    [[ -d "$gt" ]] || continue
    gpu_cur=$(read_sys "${gt}freq0/cur_freq")
    gpu_min=$(read_sys "${gt}freq0/min_freq")
    gpu_max=$(read_sys "${gt}freq0/max_freq")
    break
done
# Fallback to older sysfs path
if [[ "$gpu_cur" == "n/a" ]]; then
    for card in /sys/class/drm/card*; do
        [[ -f "${card}/gt_cur_freq_mhz" ]] || continue
        gpu_cur=$(read_sys "${card}/gt_cur_freq_mhz")
        gpu_min=$(read_sys "${card}/gt_min_freq_mhz")
        gpu_max=$(read_sys "${card}/gt_max_freq_mhz")
        break
    done
fi

# Dirty writeback
writeback_cs=$(read_sys /proc/sys/vm/dirty_writeback_centisecs)
if [[ "$writeback_cs" != "n/a" ]]; then
    writeback_s=$(( writeback_cs / 100 ))
else
    writeback_s="n/a"
fi

# VA-API
if command -v vainfo &>/dev/null; then
    vaapi_driver=$(vainfo 2>&1 | grep -oP 'Driver version: \K.*' || echo "n/a")
    vaapi_profiles=$(vainfo 2>&1 | grep -c 'VAProfile' || echo 0)
    vaapi_status="${G}${vaapi_profiles} profiles${NC} (${vaapi_driver})"
else
    vaapi_status="${Y}vainfo not found${NC}"
fi

# Chromium flags
if [[ -f "$HOME/.config/chromium-flags.conf" ]]; then
    chromium_vaapi="${G}configured${NC}"
else
    chromium_vaapi="${R}not configured${NC}"
fi

# --- Short mode ---

if $SHORT; then
    echo -e "Power: ${power_icon} | Profile: ${B}${platform_profile}${NC} | CPU: ${avg_freq_mhz}MHz EPP:${epp} Turbo:${turbo} | Temp: ${pkg_temp} | Fans: ${fan1_rpm}/${fan2_rpm} RPM | Bat: ${bat_capacity}% (${bat_status})"
    exit 0
fi

# --- Full output ---

echo -e "\n${B}Power & Thermal Status${NC}  ${D}$(date '+%H:%M:%S')${NC}"

section "Power source"
row "Source" "$(echo -e "$power_icon")" "AC adapter or battery"
row "Platform profile" "$platform_profile" "Dell thermal/fan mode [${platform_choices}]"

section "CPU"
row "Driver" "$pstate_status" "intel_pstate operating mode [active/passive]"
row "Governor" "$governor" "Frequency scaling strategy [${gov_choices}]"
row "EPP" "$epp" "Energy Performance Preference [${epp_choices}]"
row "Turbo boost" "$turbo" "Allow CPU to clock above base frequency"
row "HWP dynamic boost" "$hwp_boost" "Boost on I/O-bound tasks waking up"
row "Max perf %" "${max_perf}%" "Upper limit on P-state range"
row "Frequency" "${avg_freq_mhz}MHz avg" "Current average across all cores [${min_freq_mhz}-${max_freq_mhz}MHz]"

section "Thermal"
row "CPU package" "$pkg_temp" "Overall CPU temperature"
row "NVMe" "$nvme_temp" "SSD temperature"
row "Fan 1" "${fan1_rpm} RPM" "CPU fan speed"
row "Fan 2" "${fan2_rpm} RPM" "Secondary fan speed"
row "thermald" "$(echo -e "$thermald_status")" "Proactive thermal management daemon"

section "GPU (Intel)"
row "Current freq" "${gpu_cur} MHz" "Current GPU clock speed"
row "Min/Max freq" "${gpu_min}/${gpu_max} MHz" "GPU frequency range"
row "VA-API" "$(echo -e "$vaapi_status")" "Hardware video decode/encode"
row "Chromium VA-API" "$(echo -e "$chromium_vaapi")" "chromium-flags.conf with VA-API flags"

section "Battery"
row "Level" "${bat_capacity}%" "Current charge"
row "Status" "$bat_status" "State [Charging/Discharging/Full/Not charging]"
row "Power draw" "$power_draw" "Current consumption"
row "Charge start" "${bat_start}%" "Start charging below this level"
row "Charge stop" "${bat_stop}%" "Stop charging above this level (battery care)"

section "Power saving"
row "ASPM policy" "$aspm_policy" "PCIe link power state [default/powersave/powersupersave]"
row "PCIe runtime PM" "${rpm_suspended} suspended / ${rpm_active} active" "Devices in low-power vs awake"
row "WiFi power save" "$wifi_ps" "WiFi chip sleeps between transmissions [on/off]"
row "USB autosuspend" "${usb_auto} auto / ${usb_on} always-on" "Idle USB devices suspended vs awake"
row "Audio power save" "${snd_ps}s timeout" "HDA codec powers down after silence"
row "Audio controller" "$(if [[ "$snd_ctrl" == "Y" ]]; then echo "off when idle"; else echo "always on"; fi)" "HDA controller power gating [Y/N]"
row "NMI watchdog" "$(if [[ "$nmi" == "0" ]]; then echo "disabled"; else echo "enabled"; fi)" "Kernel debug interrupt (wastes power if on)"
row "Dirty writeback" "${writeback_s}s" "How often cached writes flush to disk"

echo ""
