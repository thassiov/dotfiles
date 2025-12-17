"""
Battery level notification module for py3status.
Sends dunst notifications when battery reaches 20%, 10%, and 5%.
"""
import subprocess
from pathlib import Path


class Py3status:
    """
    Monitor battery level and send notifications at critical thresholds.
    This module runs silently - it doesn't display anything in the status bar.
    """

    cache_timeout = 30
    thresholds = [20, 10, 5]
    battery_path = "/sys/class/power_supply/BAT0"

    def __init__(self):
        self._notified = set()

    def battery_notify(self):
        """
        Check battery level and send notifications if needed.
        """
        capacity = self._get_battery_capacity()
        status = self._get_battery_status()

        if capacity is not None and status == "Discharging":
            for threshold in self.thresholds:
                if capacity <= threshold and threshold not in self._notified:
                    self._send_notification(capacity, threshold)
                    self._notified.add(threshold)

            # Clear notifications when battery goes above threshold (charging)
            self._notified = {t for t in self._notified if capacity <= t}
        elif status == "Charging" or status == "Full":
            # Reset all notifications and restore brightness when charging
            if self._notified:
                self._restore_brightness()
            self._notified.clear()

        return {
            "cached_until": self.py3.time_in(self.cache_timeout),
            "full_text": "",
        }

    def _get_battery_capacity(self):
        """Get current battery percentage."""
        try:
            with open(f"{self.battery_path}/capacity", "r") as f:
                return int(f.read().strip())
        except Exception:
            return None

    def _get_battery_status(self):
        """Get battery status (Charging, Discharging, Full, etc.)."""
        try:
            with open(f"{self.battery_path}/status", "r") as f:
                return f.read().strip()
        except Exception:
            return None

    def _send_notification(self, capacity, threshold):
        """Send a dunst notification for low battery."""
        urgency = "normal"
        icon = "battery-low"
        timeout_ms = 8000  # default 8 seconds

        if threshold <= 5:
            urgency = "critical"
            icon = "battery-empty"
            title = "Battery Critical!"
            body = f"Battery at {capacity}%! Plug in NOW!"
            timeout_ms = 30000
            sound_repeats = 3
        elif threshold <= 10:
            urgency = "critical"
            icon = "battery-caution"
            title = "Battery Very Low!"
            body = f"Battery at {capacity}%! Please plug in soon."
            timeout_ms = 30000
            sound_repeats = 3
            self._dim_screen()
        else:
            urgency = "normal"
            icon = "battery-low"
            title = "Battery Low"
            body = f"Battery at {capacity}%."
            sound_repeats = 1

        try:
            subprocess.run(
                [
                    "notify-send",
                    "-u", urgency,
                    "-i", icon,
                    "-t", str(timeout_ms),
                    title,
                    body,
                ],
                timeout=5
            )
            self._play_alert_sound(sound_repeats)
        except Exception:
            pass

    def _play_alert_sound(self, repeats=1):
        """Play the alert sound a specified number of times."""
        import time
        sound_file = f"{Path.home()}/.local/share/sounds/battery-alert.wav"
        for i in range(repeats):
            subprocess.Popen(
                ["paplay", sound_file],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            ).wait()
            if i < repeats - 1:
                time.sleep(0.8)

    def _dim_screen(self):
        """Dim the screen to minimum brightness."""
        try:
            subprocess.run(
                ["xbacklight", "-set", "0.01", "-time", "200", "-steps", "10"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=5
            )
        except Exception:
            pass

    def _restore_brightness(self):
        """Restore screen to medium brightness."""
        try:
            subprocess.run(
                ["xbacklight", "-set", "60", "-time", "200", "-steps", "10"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=5
            )
        except Exception:
            pass
