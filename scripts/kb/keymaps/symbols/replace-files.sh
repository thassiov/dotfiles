#!/bin/bash

PC=/usr/share/X11/xkb/symbols/pc
US=/usr/share/X11/xkb/symbols/us

echo "Backing up original files"
mv $PC $PC.bkp
mv $US $US.bkp

echo "Copying modified files"
cp ./pc $PC
cp ./us $US

echo "Finished. Please check the results"
