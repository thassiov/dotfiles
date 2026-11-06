"""
Show a red alert when the CPU is pinned at 400 MHz.

Reads the state file written by freq-watch.sh (portus dock/EC throttle watcher):
  "ok"              -> nothing shown
  "stuck <epoch>"   -> red "⚠ 400MHz <minutes>m"
The watcher rewrites the file every few seconds; if it goes stale the module
assumes the watcher is dead and shows nothing.
"""
import os
import time


class Py3status:
    """
    Status bar alert for the CPU 400 MHz lock detected by freq-watch.
    """

    # Configuration
    format = "⚠ 400MHz {minutes}m"
    cache_timeout = 5
    stale_after = 60
    state_file = os.path.join(
        os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"),
        "freq-watch.state",
    )

    def cpu_pinned(self):
        """
        Display the alert while the watcher reports the CPU as stuck.
        """
        response = {
            "cached_until": self.py3.time_in(self.cache_timeout),
            "full_text": "",
        }

        since = self._stuck_since()
        if since is not None:
            minutes = max(0, int((time.time() - since) // 60))
            response["full_text"] = self.py3.safe_format(self.format, {"minutes": minutes})
            response["color"] = self.py3.COLOR_BAD

        return response

    def _stuck_since(self):
        """Return the epoch the lock started, or None when ok/unknown."""
        try:
            if time.time() - os.path.getmtime(self.state_file) > self.stale_after:
                return None
            with open(self.state_file, "r") as f:
                parts = f.read().split()
            if len(parts) == 2 and parts[0] == "stuck":
                return int(parts[1])
        except Exception:
            pass
        return None
