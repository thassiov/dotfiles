#!/bin/bash
#
# Start eww daemon (if not running) and open the bar.
#
# Called by:
#   - i3 config (on startup/reload)
#   - autorandr postswitch hook (on monitor change)
#

# Ensure daemon is running
eww ping 2>/dev/null || eww daemon &

# Wait for daemon
for i in $(seq 1 10); do
    eww ping 2>/dev/null && break
    sleep 0.2
done

# Close existing bar (if any) and reopen
eww close bar 2>/dev/null
sleep 0.1
eww open bar
