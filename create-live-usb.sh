#1/bin/sh
# sudo dd bs=4M if=/path/to/manjaro.iso of=/dev/sd[drive letter] 

MAKE_LIVE_USB="dd bs=4M"
OF="of=usb device"
IN="if=iso path"
STATUS="status=progress"

exec $MAKE_LIVE_USB $IN $OF $STATUS
