#!/bin/sh
sudo groupadd docker
sudo gpasswd -a ${USER} docker
sudo update-ca-trust

# tlp - power management
# http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html#arch
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service 
sudo systemctl enable NetworkManager-dispatcher.service 
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket 
