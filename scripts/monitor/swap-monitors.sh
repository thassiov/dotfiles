#!/usr/bin/env bash
# requires jq
# [https://i3wm.org/docs/user-contributed/swapping-workspaces.html#:~:text=To%20do%20this%2C%20we%20can,workspace%20to%20the%20other%20monitor.&text=Now%20restart%20i3%20in%20place,be%20swapped%20among%20your%20monitors.

DISPLAY_CONFIG=($(i3-msg -t get_outputs | jq -r '.[]|"\(.name):\(.current_workspace)"'))

outputs=()
workspaces=()

moveWorkspace () {
  echo first value $1
  echo second value $2
  i3-msg -- workspace --no-auto-back-and-forth "$1"
  i3-msg -- move workspace to $2 
}

for ROW in "${DISPLAY_CONFIG[@]}"
do
    IFS=':'
    read -ra CONFIG <<< "${ROW}"
    if [ "${CONFIG[0]}" != "null" ] && [ "${CONFIG[1]}" != "null" ]; then
      outputs+=( ${CONFIG[0]} )
      workspaces+=( ${CONFIG[1]} )
    fi
done

echo "moving ${CONFIG[1]} left..."
echo ${outputs[@]}
echo ${workspaces[@]}

i3-msg -- rename workspace ${workspaces[0]} to 20
moveWorkspace ${workspaces[1]} ${outputs[0]}
moveWorkspace 20 ${outputs[1]}
i3-msg -- rename workspace 20 to ${workspaces[0]}

