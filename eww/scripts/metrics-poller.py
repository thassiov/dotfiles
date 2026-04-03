#!/usr/bin/env python3
"""
Polls Alloy's local metrics endpoint and outputs one compact JSON line
every INTERVAL seconds for eww's deflisten.

All rate calculations (CPU %, network throughput) are done here using
deltas between polls. Battery and WiFi info come from sysfs/iwconfig
since those aren't in Alloy.
"""

import json
import os
import re
import subprocess
import sys
import time
import urllib.request

ALLOY_URL = "http://localhost:12345/api/v0/component/prometheus.exporter.unix.node/metrics"
INTERVAL = 2

# State for rate calculations
prev_cpu_idle = {}    # per-core
prev_cpu_total = {}   # per-core
prev_cpu_idle_all = 0
prev_cpu_total_all = 0
prev_net = {}  # dev -> {rx, tx}
prev_throttles = 0
first_run = True


def fetch_metrics():
    try:
        with urllib.request.urlopen(ALLOY_URL, timeout=2) as resp:
            return resp.read().decode()
    except Exception:
        return None


def parse(raw):
    """Parse Prometheus text format into a lookup structure."""
    metrics = {}  # name -> list of (labels_dict, value)
    for line in raw.splitlines():
        if line.startswith("#") or not line:
            continue
        # Split "metric_name{labels} value" or "metric_name value"
        if "{" in line:
            name_end = line.index("{")
            name = line[:name_end]
            labels_end = line.index("}")
            labels_str = line[name_end + 1:labels_end]
            val_str = line[labels_end + 2:]
            # Parse labels
            labels = {}
            for m in re.finditer(r'(\w+)="([^"]*)"', labels_str):
                labels[m.group(1)] = m.group(2)
        else:
            parts = line.split()
            if len(parts) < 2:
                continue
            name = parts[0]
            val_str = parts[1]
            labels = {}
        try:
            val = float(val_str)
        except ValueError:
            continue
        metrics.setdefault(name, []).append((labels, val))
    return metrics


def get(metrics, name, labels=None):
    """Get a single metric value."""
    for lbl, val in metrics.get(name, []):
        if labels:
            if all(lbl.get(k) == v for k, v in labels.items()):
                return val
        else:
            return val
    return 0.0


def get_all(metrics, name):
    """Get all series for a metric."""
    return metrics.get(name, [])


def build_output(metrics):
    global prev_cpu_idle, prev_cpu_total, prev_cpu_idle_all, prev_cpu_total_all
    global prev_net, prev_throttles, first_run

    # --- CPU ---
    cpu_by_core = {}
    for lbl, val in get_all(metrics, "node_cpu_seconds_total"):
        cid = lbl.get("cpu", "0")
        mode = lbl.get("mode", "")
        cpu_by_core.setdefault(cid, {})[mode] = val

    cores = []
    total_idle_all = 0
    total_all = 0
    for cid in sorted(cpu_by_core.keys(), key=int):
        modes = cpu_by_core[cid]
        idle = modes.get("idle", 0)
        total = sum(modes.values())
        total_idle_all += idle
        total_all += total

        # Per-core rate
        pct = 0
        if not first_run and cid in prev_cpu_idle:
            d_idle = idle - prev_cpu_idle[cid]
            d_total = total - prev_cpu_total[cid]
            if d_total > 0:
                pct = (1 - d_idle / d_total) * 100
        prev_cpu_idle[cid] = idle
        prev_cpu_total[cid] = total
        cores.append({"id": int(cid), "pct": round(pct, 1)})

    # Overall CPU rate
    cpu_total_pct = 0
    if not first_run and prev_cpu_total_all > 0:
        d_idle = total_idle_all - prev_cpu_idle_all
        d_total = total_all - prev_cpu_total_all
        if d_total > 0:
            cpu_total_pct = (1 - d_idle / d_total) * 100
    prev_cpu_idle_all = total_idle_all
    prev_cpu_total_all = total_all

    cpu_freq = get(metrics, "node_cpu_scaling_frequency_hertz", {"cpu": "0"})

    # P-core vs E-core: P-cores have max freq > 4GHz, E-cores <= 3.4GHz
    for core in cores:
        cid = str(core["id"])
        max_freq = get(metrics, "node_cpu_scaling_frequency_max_hertz", {"cpu": cid})
        core["type"] = "P" if max_freq > 4e9 else "E"
        core["temp"] = 0  # Will be filled from coretemp below

    throttles_total = sum(val for _, val in get_all(metrics, "node_cpu_core_throttles_total"))
    throttles_active = False
    if not first_run and throttles_total > prev_throttles:
        throttles_active = True
    prev_throttles = throttles_total

    # --- Memory ---
    mem_total = get(metrics, "node_memory_MemTotal_bytes")
    mem_avail = get(metrics, "node_memory_MemAvailable_bytes")
    mem_used = mem_total - mem_avail
    mem_cached = get(metrics, "node_memory_Cached_bytes")
    mem_buffers = get(metrics, "node_memory_Buffers_bytes")
    swap_total = get(metrics, "node_memory_SwapTotal_bytes")
    swap_free = get(metrics, "node_memory_SwapFree_bytes")
    mem_pct = (mem_used / mem_total * 100) if mem_total > 0 else 0

    # --- Temps ---
    # Build sensor label lookup from Alloy's node_hwmon_sensor_label metric
    sensor_labels = {}  # (chip, sensor) -> label
    for lbl, _ in get_all(metrics, "node_hwmon_sensor_label"):
        chip = lbl.get("chip", "")
        sensor = lbl.get("sensor", "")
        label = lbl.get("label", "")
        if label:
            sensor_labels[(chip, sensor)] = label

    # Logical CPU -> physical core mapping (Alder Lake 12th gen)
    # Logical 0,1 -> phys 0; 2,3 -> phys 1 (shares core 0 sensor); etc.
    # P-cores: phys 0-3 (logical 0-7, hyperthreaded pairs)
    # E-cores: phys 4-11 (logical 8-15, no HT)
    logical_to_phys_core = {
        0: 0, 1: 0, 2: 4, 3: 4, 4: 8, 5: 8, 6: 12, 7: 12,
        8: 16, 9: 17, 10: 18, 11: 19, 12: 20, 13: 21, 14: 22, 15: 23,
    }

    # Collect coretemp per physical core
    core_temps = {}  # physical core id -> temp
    package_temp = 0
    zones = []
    seen_temps = set()

    for lbl, val in get_all(metrics, "node_hwmon_temp_celsius"):
        chip = lbl.get("chip", "")
        sensor = lbl.get("sensor", "")
        name = sensor or chip
        if "coretemp" in chip:
            hw_label = sensor_labels.get((chip, sensor), "")
            if "Package" in hw_label:
                package_temp = val
                # Package temp goes to the temp popup, not per-core
                zones.append({"name": "CPU Package", "temp": round(val, 1)})
                continue
            elif hw_label.startswith("Core "):
                core_num = int(hw_label.split()[-1])
                core_temps[core_num] = val
                continue  # Core temps go to CPU popup, not temp popup
            else:
                continue
        elif "dell_ddv" in chip:
            name_map = {
                "temp1": "CPU", "temp2": "Ambient", "temp3": "SODIMM",
                "temp4": "Ambient 2", "temp5": "Ambient 3",
                "temp6": "Ambient 4", "temp7": "Unknown"
            }
            name = name_map.get(sensor, sensor)
        elif "nvme" in chip:
            # NVMe has temp1 (composite) and temp2 (sensor 1) — same value, skip dupe
            if sensor != "temp1":
                continue
            name = "NVMe"
        elif "iwlwifi" in chip:
            name = "WiFi"
        elif "bat0" in chip.lower() or "power_supply_bat" in chip:
            # temp0 is raw voltage reading (0.3°C = nonsense), temp1 is actual temp
            if sensor == "temp0":
                continue
            name = "Battery"
        elif "thermal_thermal_zone" in chip:
            # Deduplicate: thermal zone often mirrors WMI sensors
            if sensor != "temp0":
                continue
            name = "Chassis"
        elif "wmi_bus" in chip:
            # Use sensor_label if available, fall back to sensor name
            hw_label = sensor_labels.get((chip, sensor), "")
            if hw_label:
                name = hw_label
                if name == "CPU":
                    continue  # Already have CPU Package from coretemp
                if name == "Unknown":
                    continue
            else:
                continue  # Skip unlabeled WMI sensors (duplicates)
        else:
            continue

        # Deduplicate by value (two WMI chips report identical sensors)
        rounded = round(val, 1)
        key = (name, rounded)
        if key in seen_temps:
            continue
        seen_temps.add(key)
        zones.append({"name": name, "temp": rounded})

    # Number duplicate names (e.g., Ambient 1, Ambient 2, ...)
    name_counts = {}
    for z in zones:
        name_counts[z["name"]] = name_counts.get(z["name"], 0) + 1
    name_idx = {}
    for z in zones:
        if name_counts[z["name"]] > 1:
            idx = name_idx.get(z["name"], 0) + 1
            name_idx[z["name"]] = idx
            z["name"] = f"{z['name']} {idx}"

    # Assign temps to logical cores from physical core sensors
    for core in cores:
        phys_core = logical_to_phys_core.get(core["id"])
        if phys_core is not None and phys_core in core_temps:
            core["temp"] = round(core_temps[phys_core], 0)
        elif package_temp:
            core["temp"] = round(package_temp, 0)  # Fallback to package

    if not package_temp:
        for lbl, val in get_all(metrics, "node_thermal_zone_temp"):
            zid = lbl.get("zone", "?")
            zones.append({"name": f"zone{zid}", "temp": round(val, 1)})
            if zid == "0":
                package_temp = val

    # Fans — this Dell has 2 physical fans, but multiple hwmon chips report them.
    # Only use the labeled WMI chip (has sensor_labels), skip unlabeled duplicates.
    fans = []
    seen_fan_keys = set()
    for lbl, val in get_all(metrics, "node_hwmon_fan_rpm"):
        chip = lbl.get("chip", "")
        sensor = lbl.get("sensor", "")
        hw_label = sensor_labels.get((chip, sensor), "")
        if not hw_label:
            continue  # Skip unlabeled chips (duplicates)
        key = (chip, sensor)  # Unique per chip+sensor
        if key in seen_fan_keys:
            continue
        seen_fan_keys.add(key)
        name = f"Fan {len(fans) + 1}"
        fans.append({"name": name, "rpm": round(val)})

    # --- Disk ---
    mounts = []
    seen = set()
    for lbl, val in get_all(metrics, "node_filesystem_size_bytes"):
        mp = lbl.get("mountpoint", "")
        fs = lbl.get("fstype", "")
        if fs not in ("ext4", "btrfs", "xfs", "zfs", "ntfs", "vfat", "f2fs"):
            continue
        if mp in seen:
            continue
        seen.add(mp)
        total = val
        avail = get(metrics, "node_filesystem_avail_bytes", {"mountpoint": mp})
        used = total - avail
        pct = (used / total * 100) if total > 0 else 0
        mounts.append({"mount": mp, "total": total, "used": used, "avail": avail, "pct": round(pct, 1)})
    mounts.sort(key=lambda x: x["mount"])
    worst_pct = max((m["pct"] for m in mounts), default=0)

    # --- Network ---
    # Collect all interfaces with their bytes
    ifaces_raw = {}
    for lbl, val in get_all(metrics, "node_network_receive_bytes_total"):
        dev = lbl.get("device", "")
        if dev == "lo" or dev.startswith("veth") or dev.startswith("docker") or dev.startswith("br-"):
            continue
        ifaces_raw[dev] = {"rx": val, "tx": 0, "up": False}

    for lbl, val in get_all(metrics, "node_network_transmit_bytes_total"):
        dev = lbl.get("device", "")
        if dev in ifaces_raw:
            ifaces_raw[dev]["tx"] = val

    for lbl, val in get_all(metrics, "node_network_up"):
        dev = lbl.get("device", "")
        if dev in ifaces_raw and val == 1:
            ifaces_raw[dev]["up"] = True

    # Build list of active interfaces with details
    net_ifaces = []
    has_wifi = False
    has_wired = False

    # WiFi info (shared across wifi interfaces)
    essid = ""
    signal = 0
    try:
        iw = subprocess.check_output(["iwconfig"], stderr=subprocess.DEVNULL, timeout=1).decode()
        m = re.search(r'ESSID:"([^"]+)"', iw)
        if m:
            essid = m.group(1)
        m = re.search(r'Signal level=-(\d+)', iw)
        if m:
            dbm = int(m.group(1))
            signal = max(0, min(100, (90 - dbm) * 100 // 60))
    except Exception:
        pass

    for dev, info in sorted(ifaces_raw.items()):
        if not info["up"]:
            continue

        is_wifi = dev.startswith("wlan")
        is_wired = not is_wifi

        # IP address
        ip_addr = ""
        try:
            out = subprocess.check_output(
                ["ip", "-4", "addr", "show", dev], stderr=subprocess.DEVNULL, timeout=1
            ).decode()
            m = re.search(r'inet (\S+?)/', out)
            if m:
                ip_addr = m.group(1)
        except Exception:
            pass

        # Rate calc per interface
        rx_bytes = info["rx"]
        tx_bytes = info["tx"]
        rx_rate = 0
        tx_rate = 0
        if not first_run and dev in prev_net:
            rx_rate = max(0, (rx_bytes - prev_net[dev]["rx"]) / INTERVAL)
            tx_rate = max(0, (tx_bytes - prev_net[dev]["tx"]) / INTERVAL)
        prev_net[dev] = {"rx": rx_bytes, "tx": tx_bytes}

        iface_data = {
            "iface": dev,
            "type": "wifi" if is_wifi else "wired",
            "ip": ip_addr,
            "rx_rate": round(rx_rate, 1),
            "tx_rate": round(tx_rate, 1),
        }
        if is_wifi:
            iface_data["essid"] = essid
            iface_data["signal"] = signal
            has_wifi = True
        else:
            has_wired = True

        net_ifaces.append(iface_data)

    # --- Battery (from sysfs) ---
    bat_pct = 0
    bat_status = "Unknown"
    bat_remaining = ""
    bat_watts = 0

    bat_path = "/sys/class/power_supply/BAT0"
    if os.path.isdir(bat_path):
        try:
            bat_pct = int(open(f"{bat_path}/capacity").read().strip())
        except Exception:
            pass
        try:
            bat_status = open(f"{bat_path}/status").read().strip()
        except Exception:
            pass
        try:
            power_now = int(open(f"{bat_path}/power_now").read().strip())
            energy_now = int(open(f"{bat_path}/energy_now").read().strip())
            bat_watts = power_now / 1e6
            if power_now > 0:
                if bat_status == "Discharging":
                    hours = energy_now / power_now
                elif bat_status == "Charging":
                    energy_full = int(open(f"{bat_path}/energy_full").read().strip())
                    hours = (energy_full - energy_now) / power_now
                else:
                    hours = 0
                if hours > 0:
                    h = int(hours)
                    m = int((hours - h) * 60)
                    bat_remaining = f"{h}h{m:02d}m"
        except Exception:
            pass

    # Also get battery watts from hwmon if available
    if bat_watts == 0:
        bat_v = get(metrics, "node_hwmon_in_volts", {"chip": "power_supply_bat0"})
        bat_a = get(metrics, "node_hwmon_curr_amps", {"chip": "power_supply_bat0"})
        bat_watts = bat_v * bat_a

    first_run = False

    return {
        "cpu": {
            "total": round(cpu_total_pct, 1),
            "cores": cores,
            "freq": cpu_freq,
            "throttles_active": throttles_active,
        },
        "mem": {
            "used": mem_used,
            "total": mem_total,
            "cached": mem_cached,
            "buffers": mem_buffers,
            "swap_used": swap_total - swap_free,
            "swap_total": swap_total,
            "pct": round(mem_pct, 1),
        },
        "temps": {
            "package": round(package_temp, 1),
            "zones": zones[:12],
            "fans": fans,
            "fan_rpm": round(fans[0]["rpm"]) if fans else 0,
        },
        "disk": {
            "mounts": mounts,
            "worst_pct": round(worst_pct, 1),
        },
        "net": {
            "ifaces": net_ifaces,
            "has_wifi": has_wifi,
            "has_wired": has_wired,
        },
        "bat": {
            "pct": bat_pct,
            "status": bat_status,
            "remaining": bat_remaining,
            "watts": round(bat_watts, 1),
        },
    }


def main():
    global first_run
    while True:
        raw = fetch_metrics()
        if raw:
            metrics = parse(raw)
            out = build_output(metrics)
            print(json.dumps(out, separators=(",", ":")), flush=True)
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
