#!/bin/bash
# Script to set wallpaper on all connected monitors
# Automatically handles multiple monitor setups

WALLPAPER_DIR="$HOME/.dotfiles/wallpaper"
WALLPAPER="$WALLPAPER_DIR/Dark-Wallpapers-HD-Free-download.jpg"

# Check if the wallpaper file exists
if [ ! -f "$WALLPAPER" ]; then
    echo "Error: Wallpaper file not found at $WALLPAPER"
    exit 1
fi

# Use feh to set the wallpaper on all monitors
# --bg-scale scales the image to fit the screen while maintaining aspect ratio
# feh automatically handles multiple monitors
feh --bg-scale "$WALLPAPER"
