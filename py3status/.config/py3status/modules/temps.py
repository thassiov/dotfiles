"""
Display chassis and battery temperatures.
"""
import subprocess


class Py3status:
    """
    Display system temperatures from sensors.
    """

    # Configuration
    format = "💻 {chassis}°C 🌀 {fan_speed}"
    cache_timeout = 5

    def temps(self):
        """
        Get chassis temperature and fan speed.
        """
        chassis_temp = self._get_chassis_temp()
        fan_speed = self._get_fan_speed()

        return {
            "cached_until": self.py3.time_in(self.cache_timeout),
            "full_text": self.py3.safe_format(
                self.format,
                {"chassis": chassis_temp, "fan_speed": fan_speed}
            ),
        }

    def _get_chassis_temp(self):
        """Get chassis/ambient temperature from sensors."""
        try:
            # Use subprocess to run sensors command
            result = subprocess.run(
                ["sensors", "dell_ddv-virtual-0"],
                capture_output=True,
                text=True,
                timeout=2
            )
            for line in result.stdout.split('\n'):
                if 'Ambient:' in line and '+' in line:
                    # Extract temperature like "+52.0°C"
                    temp_str = line.split()[1]
                    temp_val = temp_str.replace('+', '').replace('°C', '')
                    return int(float(temp_val))
        except Exception:
            pass
        return "N/A"

    def _get_battery_temp(self):
        """Get battery temperature."""
        try:
            # Read from /sys/class/power_supply/BAT0/temp (in decidegrees)
            with open("/sys/class/power_supply/BAT0/temp", "r") as f:
                temp_decidegrees = int(f.read().strip())
                return int(temp_decidegrees / 10)
        except Exception:
            pass
        return "N/A"

    def _get_fan_speed(self):
        """Get fan speed from sensors."""
        try:
            # Use subprocess to run sensors command
            result = subprocess.run(
                ["sensors", "dell_ddv-virtual-0"],
                capture_output=True,
                text=True,
                timeout=2
            )
            for line in result.stdout.split('\n'):
                if 'CPU Fan:' in line and 'RPM' in line:
                    # Extract RPM like "6153 RPM"
                    rpm_str = line.split()[2]
                    rpm = int(rpm_str)
                    # Convert to k format (2000 -> 2k)
                    if rpm >= 1000:
                        return f"{rpm // 1000}k"
                    else:
                        return str(rpm)
        except Exception:
            pass
        return ""
