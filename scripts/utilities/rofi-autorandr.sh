#!/bin/bash

# Get list of available autorandr profiles
profiles=$(autorandr --list)

# Show rofi menu and get selected profile
selected=$(echo "$profiles" | rofi -dmenu -i -p "Display Profile")

# Apply the selected profile if one was chosen
if [ -n "$selected" ]; then
    autorandr --load "$selected"
fi
