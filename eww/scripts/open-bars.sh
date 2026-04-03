#!/bin/bash
#
# Open an eww bar on every active monitor.
# Close bars on monitors that are no longer connected.
#
# Called by:
#   - i3 config (on startup)
#   - autorandr postswitch hook (on monitor change)
#
# eww window naming: bar-0, bar-1, bar-2, etc.
#

# Get list of active monitor indices
active_monitors=$(xrandr --query 2>/dev/null \
    | grep ' connected' \
    | grep -v ' off' \
    | awk '{print NR-1}')

num_monitors=$(echo "$active_monitors" | wc -w)

# Close all existing bar windows first
eww close-all 2>/dev/null

# Small delay to let eww clean up
sleep 0.2

# Open a bar on each monitor
for mon in $active_monitors; do
    eww open "bar" --id "bar-$mon" --arg monitor="$mon" 2>/dev/null &
done

wait
