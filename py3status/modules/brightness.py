"""
Display current brightness level indicator.

Reads the laptop backlight level (via xbacklight) and maps it to
a named preset: dim, low, mid, high.
"""
import subprocess


class Py3status:
    """
    Show brightness level as a lamp icon with label.
    """

    format = "{icon} {level}"
    cache_timeout = 2

    # Laptop brightness -> level name mapping (must match toggle-brightness.sh)
    _level_map = {
        "0.01": "dim",
        "30.00": "low",
        "60.00": "mid",
        "90.00": "high",
    }

    _icon_map = {
        "dim": "🔅",
        "low": "🔅",
        "mid": "🔆",
        "high": "🔆",
    }

    def brightness(self):
        """
        Get current brightness level and display it.
        """
        current = self._get_laptop_brightness()
        level = self._level_map.get(current, "?")
        icon = self._icon_map.get(level, "💡")

        return {
            "cached_until": self.py3.time_in(self.cache_timeout),
            "full_text": self.py3.safe_format(
                self.format,
                {"icon": icon, "level": level}
            ),
        }

    def _get_laptop_brightness(self):
        """Get current laptop brightness as a formatted string."""
        try:
            result = subprocess.run(
                ["xbacklight", "-getf"],
                capture_output=True,
                text=True,
                timeout=2,
            )
            raw = result.stdout.strip()
            if raw:
                return f"{float(raw):.2f}"
        except Exception:
            pass
        return "0.00"
