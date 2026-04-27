#!/bin/bash
# Set wallpaper(s) on connected monitors. Multi-screen layouts get per-monitor
# wallpapers; otherwise a single wallpaper is applied to all outputs.

WALLPAPER_DIR="$HOME/.dotfiles/wallpaper"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/Dark-Wallpapers-HD-Free-download.jpg"

mapfile -t ACTIVE < <(xrandr --listmonitors | tail -n +2 | awk '{print $NF}')

has_output() {
    local target="$1" out
    for out in "${ACTIVE[@]}"; do
        [[ "$out" == "$target" ]] && return 0
    done
    return 1
}

# Triple-screen layout (smallmonitor-bigmonitor-dualup-resized-left-port):
# DP-1-3 = portable monitor on the left (portrait),
# DP-1-1 = big monitor in the center (primary, landscape),
# DP-1-2 = dualup monitor on the right (square/portrait).
if has_output DP-1-1 && has_output DP-1-2 && has_output DP-1-3; then
    declare -A MAP=(
        [DP-1-1]="$WALLPAPER_DIR/wallpaper-triple-screen-center.png"
        [DP-1-2]="$WALLPAPER_DIR/wallpaper-triple-screen-right.png"
        [DP-1-3]="$WALLPAPER_DIR/wallpaper-triple-screen-left.png"
    )
    # feh consumes positional args in `xrandr --listmonitors` order, so build
    # the arg list from ACTIVE to stay correct regardless of listing order.
    args=()
    for out in "${ACTIVE[@]}"; do
        [[ -n "${MAP[$out]:-}" && -f "${MAP[$out]}" ]] && args+=("${MAP[$out]}")
    done
    if [[ ${#args[@]} -eq 3 ]]; then
        feh --no-fehbg --bg-max "${args[@]}"
        exit 0
    fi
fi

if [[ -f "$DEFAULT_WALLPAPER" ]]; then
    feh --no-fehbg --bg-scale "$DEFAULT_WALLPAPER"
else
    echo "Error: Wallpaper file not found at $DEFAULT_WALLPAPER" >&2
    exit 1
fi
