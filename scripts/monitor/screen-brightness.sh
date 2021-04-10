#!/bin/bash

active_monitors=(`xrandr --listmonitors | tail -n +2 | rev | cut -d ' ' -f 1 | rev`)
current_brightness=(`xrandr --listmonitors --verbose | grep Brightness | rev | cut -d ' ' -f 1 | rev`)

function brighten() {
  for (( i=0; i<=${#active_monitors[@]}; i++ )); do
    if [ -z ${active_monitors[$i]} ]; then
      break;
    fi
    echo "${active_monitors[$i]} = ${current_brightness[$i]}"
    if [ ${current_brightness[$i]} == "1.0" ]; then
      echo "max brightness"
    elif [ ${current_brightness[$i]} == "0.99" ]; then
      xrandr --output ${active_monitors[$i]} --brightness 1.0
      echo "99"
    else
      newbrightness=`awk "BEGIN {print ${current_brightness[$i]}+0.05}"`
      xrandr --output ${active_monitors[$i]} --brightness $newbrightness
      echo $newbrightness
    fi
  done
}

function darken() {
  for (( i=0; i<=${#active_monitors[@]}; i++ )); do
    if [ -z ${active_monitors[$i]} ]; then
      break;
    fi
    echo "${active_monitors[$i]} = ${current_brightness[$i]}"
    if [ ${current_brightness[$i]} == "0.0" ]; then
      echo "min brightness"
    elif [ ${current_brightness[$i]} == "0.01" ]; then
      xrandr --output ${active_monitors[$i]} --brightness 0.0
      echo "0.01"
    else
      newbrightness=`awk "BEGIN {print ${current_brightness[$i]}-0.05}"`
      xrandr --output ${active_monitors[$i]} --brightness $newbrightness
      echo $newbrightness
    fi
  done
}

if [ -z $1 ]; then
  echo "Valid arguments: inc (brighten screen by 1%) and dec (darken screen by 5%)"
elif [ $1 == "inc" ]; then
  brighten
elif [ $1 == "dec" ]; then
  darken
else
  echo "Valid arguments: inc (brighten screen by 1%) and dec (darken screen by 5%)"
fi
