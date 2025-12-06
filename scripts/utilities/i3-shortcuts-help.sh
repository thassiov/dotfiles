#!/bin/bash
# i3 Interactive Shortcuts Palette

# Format: "Description | command"
SHORTCUTS=$(cat << 'EOF'
━━━ APPLICATIONS ━━━
Terminal with tmux | alacritty -e tmux
Terminal (plain) | alacritty
File manager | pcmanfm
Lock screen | xlock
Toggle keyboard layout | $HOME/.dotfiles/scripts/kb/togglekblayouts

━━━ LAUNCHERS ━━━
Run command | $HOME/.config/rofi/rofi-run
Application launcher | $HOME/.config/rofi/rofi-dmenu
Emoji picker | $HOME/.config/rofi/rofi-emoji
Window switcher | $HOME/.config/rofi/rofi-window
Display manager | $HOME/.dotfiles/scripts/utilities/rofi-autorandr.sh

━━━ WINDOW MANAGEMENT ━━━
Kill focused window | i3-msg kill
Split horizontal | i3-msg split h
Split vertical | i3-msg split v
Toggle fullscreen | i3-msg fullscreen toggle
Toggle floating | i3-msg floating toggle

━━━ LAYOUTS ━━━
Stacking layout | i3-msg layout stacking
Tabbed layout | i3-msg layout tabbed
Toggle split layout | i3-msg layout toggle split

━━━ WORKSPACES ━━━
Workspace 0 | i3-msg workspace 0:sec
Workspace 1 | i3-msg workspace 1:main
Workspace 2 | i3-msg workspace 2:sec
Workspace 3 | i3-msg workspace 3:sec
Workspace 4 | i3-msg workspace 4:sec
Workspace 5 | i3-msg workspace 5:sec
Workspace 6 | i3-msg workspace 6:sec

━━━ SYSTEM ━━━
Reload i3 config | i3-msg reload
Restart i3 | i3-msg restart
Enter resize mode | i3-msg mode resize

━━━ HELP ━━━
Show this help | $HOME/.dotfiles/scripts/utilities/i3-shortcuts-help.sh
EOF
)

# Show in rofi and get selection
SELECTED=$(echo "$SHORTCUTS" | rofi -dmenu -i -p "i3 Command Palette" -theme-str 'window {width: 50%;}' -format 's')

# If user selected something and it contains a command
if [[ -n "$SELECTED" ]] && [[ "$SELECTED" == *"|"* ]]; then
    # Extract command (everything after the |)
    COMMAND=$(echo "$SELECTED" | sed 's/.*| *//')

    # Execute the command
    eval "$COMMAND" &
fi
