#!/bin/bash
# Unified brightness toggle for laptop + external LG monitors.
#
# Laptop (eDP-1):      xbacklight (cycles 0.01 -> 30 -> 60 -> 90 -> 0.01)
# LG DualUp (SDQHD):   ddcutil via DDC/CI (cycles 1 -> 5 -> 15 -> 40 -> 1)
# LG UltraGear:        raw i2c DDC/CI (same levels as DualUp)
#
# The UltraGear is on a DPMST bus that ddcutil can't detect (known bug),
# so we talk to it directly via Python/i2c.
#
# Monitors that aren't connected are silently skipped.

set -euo pipefail

# --- Brightness presets ---
# Laptop levels (xbacklight percentage)
LAPTOP_LEVELS=(0.01 30 60 90)

# LG monitor levels (DDC/CI 0-100)
LG_LEVELS=(1 5 15 40)

# --- Helper: get current laptop brightness level index ---
get_laptop_level_index() {
  local current
  current=$(xbacklight -getf 2>/dev/null | awk '{printf "%.2f", $1}')

  case "$current" in
    0.01)  echo 0 ;;
    30.00) echo 1 ;;
    60.00) echo 2 ;;
    90.00) echo 3 ;;
    *)     echo -1 ;;  # unknown, will reset to 0
  esac
}

# --- Helper: set laptop brightness ---
set_laptop_brightness() {
  local level="$1"
  xbacklight -set "$level" -time 200 -steps 10 2>/dev/null || true
}

# --- Helper: find the ddcutil display number for the DualUp ---
# Returns the display number, or empty string if not found.
find_dualup_display() {
  ddcutil detect 2>/dev/null | awk '
    /^Display [0-9]+/ { display = $2 }
    /LG SDQHD/        { print display; exit }
  '
}

# --- Helper: get DualUp brightness via ddcutil ---
get_dualup_brightness() {
  local display="$1"
  ddcutil getvcp 10 --display "$display" --brief 2>/dev/null | awk '{print $4}'
}

# --- Helper: set DualUp brightness via ddcutil ---
set_dualup_brightness() {
  local display="$1"
  local value="$2"
  ddcutil setvcp 10 "$value" --display "$display" 2>/dev/null || true
}

# --- Helper: find the DPMST i2c bus for the UltraGear ---
# Looks for DPMST buses, excludes the one used by the DualUp (matched via EDID),
# and returns the remaining one.
find_ultragear_bus() {
  python3 - "$@" << 'PYEOF'
import os, sys, fcntl, time

I2C_SLAVE_FORCE = 0x0706
DDC_ADDR = 0x37

def get_dpmst_buses():
    """Find all DPMST i2c buses."""
    buses = []
    i2c_base = "/sys/bus/i2c/devices"
    if not os.path.isdir(i2c_base):
        return buses
    for entry in os.listdir(i2c_base):
        if not entry.startswith("i2c-"):
            continue
        name_path = os.path.join(i2c_base, entry, "name")
        try:
            with open(name_path) as f:
                name = f.read().strip()
            if name == "DPMST":
                bus_num = int(entry.split("-")[1])
                buses.append(bus_num)
        except:
            pass
    return sorted(buses)

def read_edid_bytes(bus_num):
    """Read first 16 bytes of EDID from i2c bus."""
    try:
        fd = os.open(f"/dev/i2c-{bus_num}", os.O_RDWR)
        fcntl.ioctl(fd, I2C_SLAVE_FORCE, 0x50)
        os.write(fd, bytes([0x00]))
        time.sleep(0.05)
        edid = os.read(fd, 128)
        os.close(fd)
        return edid
    except:
        return None

def is_dualup_edid(edid):
    """Check if EDID matches the LG SDQHD (DualUp)."""
    if edid is None or len(edid) < 16:
        return False
    # Valid EDID starts with 00 FF FF FF FF FF FF 00
    # and manufacturer bytes for LG SDQHD contain 0x5bf5
    if edid[0:8] != b'\x00\xff\xff\xff\xff\xff\xff\x00':
        return False
    # Product code 0x5bf5 at bytes 8-9 (little-endian)
    product = edid[8] | (edid[9] << 8)
    return product == 0x5bf5

def can_ddc(bus_num):
    """Check if DDC/CI responds on this bus."""
    try:
        fd = os.open(f"/dev/i2c-{bus_num}", os.O_RDWR)
        fcntl.ioctl(fd, I2C_SLAVE_FORCE, DDC_ADDR)
        payload = [0x51, 0x82, 0x01, 0x10]
        checksum = 0x6E
        for b in payload:
            checksum ^= b
        os.write(fd, bytes(payload + [checksum]))
        time.sleep(0.05)
        response = os.read(fd, 12)
        os.close(fd)
        # Valid response starts with 0x6e 0x88 0x02
        return len(response) >= 3 and response[0] == 0x6E and response[1] == 0x88
    except:
        return False

buses = get_dpmst_buses()
for bus in buses:
    edid = read_edid_bytes(bus)
    if is_dualup_edid(edid):
        continue  # skip DualUp, handled by ddcutil
    if can_ddc(bus):
        print(bus)
        sys.exit(0)

sys.exit(1)
PYEOF
}

# --- Helper: get UltraGear brightness via raw i2c ---
get_ultragear_brightness() {
  local bus="$1"
  python3 -c "
import os, fcntl, time
fd = os.open('/dev/i2c-${bus}', os.O_RDWR)
fcntl.ioctl(fd, 0x0706, 0x37)
payload = [0x51, 0x82, 0x01, 0x10]
checksum = 0x6E
for b in payload: checksum ^= b
os.write(fd, bytes(payload + [checksum]))
time.sleep(0.05)
r = os.read(fd, 12)
os.close(fd)
print((r[8] << 8) | r[9])
" 2>/dev/null
}

# --- Helper: set UltraGear brightness via raw i2c ---
set_ultragear_brightness() {
  local bus="$1"
  local value="$2"
  python3 -c "
import os, fcntl
fd = os.open('/dev/i2c-${bus}', os.O_RDWR)
fcntl.ioctl(fd, 0x0706, 0x37)
hi = (${value} >> 8) & 0xFF
lo = ${value} & 0xFF
payload = [0x51, 0x84, 0x03, 0x10, hi, lo]
checksum = 0x6E
for b in payload: checksum ^= b
os.write(fd, bytes(payload + [checksum]))
os.close(fd)
" 2>/dev/null || true
}

# --- Helper: map a DDC brightness value to a level index ---
ddc_to_level_index() {
  local current="$1"
  local i
  for i in "${!LG_LEVELS[@]}"; do
    if [[ "$current" -eq "${LG_LEVELS[$i]}" ]]; then
      echo "$i"
      return
    fi
  done
  echo -1
}

# --- Main ---

# Determine current level from laptop brightness
level_index=$(get_laptop_level_index)

# Advance to next level (wrap around)
num_levels=${#LAPTOP_LEVELS[@]}
next_index=$(( (level_index + 1) % num_levels ))

# Set laptop brightness
set_laptop_brightness "${LAPTOP_LEVELS[$next_index]}"

# Set DualUp brightness (if connected)
dualup_display=$(find_dualup_display)
if [[ -n "$dualup_display" ]]; then
  set_dualup_brightness "$dualup_display" "${LG_LEVELS[$next_index]}" &
fi

# Set UltraGear brightness (if connected)
ultragear_bus=$(find_ultragear_bus 2>/dev/null || true)
if [[ -n "$ultragear_bus" ]]; then
  set_ultragear_brightness "$ultragear_bus" "${LG_LEVELS[$next_index]}" &
fi

# Wait for background jobs
wait
