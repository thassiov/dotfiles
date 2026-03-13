#!/bin/sh

DUALUPMODE="DualUpMode"

if ! $(xrandr --current | grep -q $DUALUPMODE); then
  cvt 1920 2160 60 | sed -n '2p' | cut -d' ' -f3- | xargs xrandr --newmode $DUALUPMODE
  xrandr --addmode DP-3-2 $DUALUPMODE
fi

xrandr --verbose --output eDP-1 --mode 1920x1200 --pos 0x434 --rotate normal --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-3-1 --primary --mode 2560x1440 --pos 1920x314 --rotate normal --output DP-3-2 --mode $DUALUPMODE --pos 4480x0 --rotate normal --output DP-3-3 --off
