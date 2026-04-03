#!/bin/bash
#
# Outputs workspace state as JSON for eww's deflisten.
# Subscribes to i3 workspace events — updates instantly on switch/create/close.
#

get_workspaces() {
    i3-msg -t get_workspaces 2>/dev/null | jq -c '[.[] | {name: .name, num: .num, focused: .focused, visible: .visible, output: .output}] | sort_by(.num)'
}

# Emit current state immediately
get_workspaces

# Subscribe to workspace events, emit state on each change
i3-msg -t subscribe -m '["workspace"]' 2>/dev/null | while read -r _event; do
    get_workspaces
done
