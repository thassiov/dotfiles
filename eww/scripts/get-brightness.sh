#!/bin/bash
# Get brightness levels for all connected monitors as JSON array.
# Uses a cache for monitor detection (expensive), only queries brightness values live.

CACHE_FILE="/tmp/eww-brightness-monitors.cache"
CACHE_TTL=60  # seconds before re-detecting monitors

# --- Detect monitors (cached) ---
detect_monitors() {
  local result='[]'

  # Laptop
  if xbacklight -getf &>/dev/null; then
    result=$(echo "$result" | jq -c '. + [{"name":"Laptop","type":"xbacklight"}]')
  fi

  # ddcutil monitors
  while IFS='|' read -r display model; do
    [[ -z "$display" ]] && continue
    result=$(echo "$result" | jq -c --arg n "$model" --argjson d "$display" '. + [{"name":$n,"type":"ddcutil","display":$d}]')
  done < <(ddcutil detect 2>/dev/null | awk '
    /^Display [0-9]+/ { display = $2; model = "" }
    /Model:/ { gsub(/^[[:space:]]*Model:[[:space:]]*/, ""); model = $0 }
    /VCP version/ { if (display != "" && model != "") print display "|" model; display = ""; model = "" }
  ')

  # UltraGear via DPMST
  local ug_bus
  ug_bus=$(python3 - << 'PYEOF'
import os, fcntl, time, sys
I2C_SLAVE_FORCE = 0x0706
SKIP_PRODUCTS = {0x148, 0x2e4f}
i2c_base = "/sys/bus/i2c/devices"
for entry in sorted(os.listdir(i2c_base)):
    if not entry.startswith("i2c-"):
        continue
    try:
        with open(os.path.join(i2c_base, entry, "name")) as f:
            if f.read().strip() != "DPMST":
                continue
    except:
        continue
    bus_num = int(entry.split("-")[1])
    try:
        fd = os.open(f"/dev/i2c-{bus_num}", os.O_RDWR)
        fcntl.ioctl(fd, I2C_SLAVE_FORCE, 0x50)
        os.write(fd, bytes([0x00]))
        time.sleep(0.05)
        edid = os.read(fd, 128)
        os.close(fd)
        if len(edid) >= 10 and (edid[8] | (edid[9] << 8)) in SKIP_PRODUCTS:
            continue
    except:
        pass
    try:
        fd = os.open(f"/dev/i2c-{bus_num}", os.O_RDWR)
        fcntl.ioctl(fd, I2C_SLAVE_FORCE, 0x37)
        payload = [0x51, 0x82, 0x01, 0x10]
        checksum = 0x6E
        for b in payload: checksum ^= b
        os.write(fd, bytes(payload + [checksum]))
        time.sleep(0.05)
        r = os.read(fd, 12)
        os.close(fd)
        if len(r) >= 10 and r[0] == 0x6E:
            print(bus_num)
            sys.exit(0)
    except:
        pass
sys.exit(1)
PYEOF
  )
  if [[ -n "$ug_bus" ]]; then
    result=$(echo "$result" | jq -c --argjson b "$ug_bus" '. + [{"name":"UltraGear","type":"i2c","bus":$b}]')
  fi

  echo "$result"
}

# --- Get cached monitor list or refresh ---
monitor_list=""
if [[ -f "$CACHE_FILE" ]]; then
  cache_age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
  if [[ "$cache_age" -lt "$CACHE_TTL" ]]; then
    monitor_list=$(cat "$CACHE_FILE")
  fi
fi

if [[ -z "$monitor_list" || "$monitor_list" == "[]" ]]; then
  monitor_list=$(detect_monitors)
  echo "$monitor_list" > "$CACHE_FILE"
fi

# --- Query brightness for each known monitor (fast) ---
# Collect name|pct pairs, then build JSON at the end
pairs=""

count=$(echo "$monitor_list" | jq 'length')
for (( i=0; i<count; i++ )); do
  name=$(echo "$monitor_list" | jq -r ".[$i].name")
  type=$(echo "$monitor_list" | jq -r ".[$i].type")
  pct=""

  case "$type" in
    xbacklight)
      pct=$(xbacklight -getf 2>/dev/null | awk '{printf "%.0f", $1}')
      ;;
    ddcutil)
      display=$(echo "$monitor_list" | jq -r ".[$i].display")
      pct=$(ddcutil getvcp 10 --display "$display" --brief --noverify 2>/dev/null | awk '{print $4}')
      ;;
    i2c)
      bus=$(echo "$monitor_list" | jq -r ".[$i].bus")
      pct=$(python3 -c "
import os, fcntl, time
fd = os.open('/dev/i2c-${bus}', os.O_RDWR)
fcntl.ioctl(fd, 0x0706, 0x37)
p = [0x51, 0x82, 0x01, 0x10]
c = 0x6E
for b in p: c ^= b
os.write(fd, bytes(p + [c]))
time.sleep(0.05)
r = os.read(fd, 12)
os.close(fd)
print((r[8] << 8) | r[9])
" 2>/dev/null)
      ;;
  esac

  if [[ -n "$pct" ]]; then
    pairs+="${name}|${pct}"$'\n'
  fi
done

# Build final JSON
result='[]'
while IFS='|' read -r name pct; do
  [[ -z "$name" ]] && continue
  result=$(echo "$result" | jq -c --arg n "$name" --argjson p "$pct" '. + [{"name":$n,"pct":$p}]')
done <<< "$pairs"

echo "$result"
