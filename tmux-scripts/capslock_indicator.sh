#!/bin/bash

CAPS=`xset q | awk '/Caps\ Lock/ {print $4}'`

if [[ $CAPS == 'on' ]]; then
    echo ' CAPSLOCK '
fi
