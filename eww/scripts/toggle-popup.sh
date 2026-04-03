#!/bin/bash
#
# Toggle a popup, closing any other open popup first.
# Usage: toggle-popup.sh <popup-name>
#
TARGET="$1"
ALL_POPUPS="cpu-popup mem-popup temp-popup disk-popup net-popup bat-popup"

for p in $ALL_POPUPS; do
    if [[ "$p" != "$TARGET" ]]; then
        eww close "$p" 2>/dev/null
    fi
done

eww open --toggle "$TARGET"
