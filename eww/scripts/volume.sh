#!/bin/bash
#
# Debounced volume control.
# Usage: volume.sh up|down|toggle
#
# Uses a lockfile to debounce rapid scroll events (100ms cooldown).
#
LOCK="/tmp/eww-vol.lock"

if [ -f "$LOCK" ]; then
    age=$(( $(date +%s%N) / 1000000 - $(cat "$LOCK" 2>/dev/null || echo 0) ))
    [ "$age" -lt 100 ] && exit 0
fi
echo $(( $(date +%s%N) / 1000000 )) > "$LOCK"

case "$1" in
    up)     pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
    down)   pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
    toggle) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
esac
