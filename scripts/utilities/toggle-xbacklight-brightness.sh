#!/bin/bash

current=$(xbacklight -getf | awk '{printf "%.2f", $1}')

fade() {
  xbacklight -set "$1" -time 200 -steps 10
}

if [[ "$current" == "0.01" ]]; then
  fade 30
elif [[ "$current" == "30.00" ]]; then
  fade 60
elif [[ "$current" == "60.00" ]]; then
  fade 90
elif [[ "$current" == "90.00" ]]; then
  fade 0.01
else
  fade 0.01
fi
