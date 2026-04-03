#!/bin/bash
#
# Polls Alloy's local metrics endpoint and outputs JSON for eww's deflisten.
# Outputs one compact JSON line every 2 seconds.
#
exec python3 ~/.config/eww/scripts/metrics-poller.py
