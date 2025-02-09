#!/bin/sh

DUALUPMODE="DualUpMode"

if ! $(xrandr --current | grep -q $DUALUPMODE); then
  cvt 1920 2160 60 | sed -n '2p' | cut -d' ' -f3- | xargs xrandr --newmode $DUALUPMODE
  xrandr --addmode DP-1-2 $DUALUPMODE
fi

xrandr --verbose --output eDP-1 --off --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-1-1 --primary --mode 2560x1440 --pos 0x720 --rate 59.95 --rotate normal --output DP-1-2 --mode $DUALUPMODE --pos 2560x0 --rate 59.96 --rotate normal --output DP-1-3 --off
