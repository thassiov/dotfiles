#!/bin/sh


DUALUPMODE="DualUpMode"

if ! $(xrandr --current | grep -q $DUALUPMODE); then
  cvt 1920 2160 60 | sed -n '2p' | cut -d' ' -f3- | xargs xrandr --newmode $DUALUPMODE
  xrandr --addmode DP-1-2 $DUALUPMODE
fi


# xrandr --output eDP-1 --off --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-3-1 --off --output DP-3-2 --off --output DP-3-3 --off --output DP-1-1 --primary --mode 2560x1440 --pos 3000x760 --rotate normal --output DP-1-2 --mode $DUALUPMODE --pos 5560x0 --rotate normal --output DP-1-3 --mode 1920x1080 --pos 1920x593 --rotate right

xrandr --output eDP-1 --off --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-3-1 --off --output DP-3-2 --off --output DP-3-3 --off --output DP-1-1 --primary --mode 2560x1440 --pos 3000x760 --rotate normal --output DP-1-2 --mode 2560x2880 --pos 5560x0 --rotate normal --output DP-1-3 --mode 1920x1080 --pos 1920x593 --rotate right
