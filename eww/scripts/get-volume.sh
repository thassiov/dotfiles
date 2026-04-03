#!/bin/bash
# Get current volume percentage and mute state as JSON
mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -c 'yes')
vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+%' | head -1 | tr -d '%')
echo "{\"pct\":${vol:-0},\"muted\":${mute:-0}}"
