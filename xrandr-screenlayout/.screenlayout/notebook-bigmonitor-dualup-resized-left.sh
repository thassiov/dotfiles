#!/bin/sh

DUALUPMODE="DualUpMode"

if ! $(xrandr --current | grep -q $DUALUPMODE); then
  cvt 1920 2160 60 | sed -n '2p' | cut -d' ' -f3- | xargs xrandr --newmode $DUALUPMODE
  xrandr --addmode DP-3-2 $DUALUPMODE
fi

xrandr --verbose --output eDP-1 --mode 1920x1200 --rate 59.95 --pos 4480x434 --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-3-1 --primary --mode 2560x1440 --pos 1920x314 --rate 59.95 --rotate normal --output DP-3-2 --mode $DUALUPMODE --pos 0x0 --rate 59.96 --rotate normal --output DP-1-3 --off
