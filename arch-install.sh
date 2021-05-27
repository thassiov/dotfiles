#!/bin/bash

#echo "'sup"

# First: add the new user
useradd -m -G wheel -s /bin/bash thassiov
passwd thassiov

# Second: add the newly added user to the 'sudoers' file
# add 'thassiov' to the sudoers' file

# Third: install the first packages
pacman -S nvim git docker tmux zsh curl sudo which htop

# Forth: now login with the new user
su thassiov

# Turn zsh the default shell
chsh -s $(which zsh)

# Fifth: add the user to the docker group
sudo groupadd docker
sudo gpasswd -a ${USER} docker

# Make git work again
sudo update-ca-trust

# Sixth: get the configuration files
git clone https://github.com/thassiov/confs.git

# Seventh: now place AAALLL config files
mv .bashrc .bashrc.old
ln -s confs/.zshrc .
source .zshrc
mkdir ~/.config
ln -s confs/nvim ~/.config/
ln -s confs/termite ~/.config/
ln -s confs/dunst ~/.config/
ln -s confs/.gitconfig .
ln -s confs/.xinit .
ln -s confs/.Xmodmap .
ln -s confs/tmux.conf .tmux.conf
ln -s confs/compton.conf .compton.conf
ln -s confs/.envs .

# Install yay (you'll need base-devel)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

## Configure oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Lastly: install the packages
yay -S \
## desktop stuff
xorg xorg-server xorg-xinit xlockmore xautolock \
xf86-input-synaptics \ # make the touchpad work (also, see 70-synaptics.conf)
i3-gaps i3status polybar compton nitrogen feh \
arandr xcalib rofi dunst \
networkmanager network-manager-applet notify-osd \
parcellite geeqie scrot \
spotify popcorntime-bin \
reaper-bin \
postman-bin \
gammy \ # blue light blocker
# bluetooth
# [http://donjajo.com/bluetooth-fix-a2dp-source-profile-connect-failed-xx-protocol-not-available-linux/]
# If you don't have the pulseaudio-bluetooth package, bluetooth headsets won't work because it tries to
# use a protocol that is not there
# example -> "src/service.c:btd_service_connect() a2dp-sink profile connect failed for 5C:C6:E9:EF:89:13: Protocol not available"
# also pulseaudio-bluetooth installs sbc package, which is essential to make the bluetooth keyboard work
blueman pulseaudio-bluetooth \
## types stuff
ttf-ms-fonts otf-fira-mono otf-fira-sans nerd-fonts-complete \
noto-fonts-emoji \ # the emoji font
## browsers
firefox google-chrome \
## audio
pulseaudio pavucontrol pamixer \
## codecs
ffmpeg flashplugin vlc \
## terminal and text editor stuff
termite vim neovim \
editorconfig-core-c httpie \
exa xclip bat \
python-pip \
bpytop \
nvm-git \
diff-so-fancy grv \
the_silver_searcher \
xclip \
docker-compose \
vagrant virtualbox virtualbox-host-modules-arch \
robo3t-bin \
## file explorer
pcmanfm \
## office stuff\
libreoffice-fresh evince foliate \
## file system stuff
mtools dosfstools ntfs-3g gvfs gparted \
## other stuff
gksu vnstat \
openssh \
## kubernetes stuff
k3d kubectl kubectx \
--noconfirm

# python support for neovim
pip install neovim

# pulse audio needs to be a daemon
pulseaudio -D

# the bluetooth need to be enabled if `blueman` gets installed
# also we need to check if the rfkill is allowing the bluetooth device
# sudo rfkill unblock all (this commands solves some headaches)
sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service

# configure vnstat [https://wiki.archlinux.org/index.php/VnStat]
# sudo systemctl start vnstat.service
# sudo systemctl enable vnstat.service

# virtualbox modules need to be loaded! [https://wiki.archlinux.org/index.php/VirtualBox]
# if you don't want to be bothered, simply reboot and the modules will load at startup

# About Termite: remember to set the $TERM as "xterm-termite" or else colors and italics,
# for example, won't work properly.
# [https://github.com/thestinger/termite/blob/956556306869060efd2fa3a7d5cf98de2289d9aa/README.rst#terminfo]
# This configuration also need to be set on tmux conf at the "default-terminal" and "terminal-overrides"
# [https://sunaku.github.io/tmux-24bit-color.html#usage]

# Other things:
yay -S acpi acpilight --noconfirm
# acpilight replaces `xorg-xbacklight` installed with `xorg-server`
# add the user to the `video` group or else xbacklight command will not work due to permission issues
# [https://gitlab.com/wavexx/acpilight/-/issues/16]
usermod -a -G video thassiov

# Install the HP printer
# [https://unix.stackexchange.com/a/392629/10333]
# "hp-scan is the 'HPLIP Scan Utility'. If you need that tool, you will need to install `python-pillow`."
# [https://wiki.archlinux.org/index.php/SANE/Scanner-specific_problems#HP]

# tlp - power management
# http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html#arch
# don't forget to set `USB_AUTOSUSPEND=0` at `/etc/tlp.conf` or else usb charging
# won't work [https://linrunner.de/en/tlp/docs/tlp-configuration.html#usb]
sudo pacman -S tlp tlp-rdw
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service

sudo systemctl enable NetworkManager-dispatcher.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

# configure the clock (this is very important because windows keep messing with the hw clock)
# [https://unix.stackexchange.com/a/336598]
sudo systemctl start systemd-timesyncd
sudo systemctl enable systemd-timesyncd

# Configure zsh-wakatime
# https://github.com/wbinglee/zsh-wakatime#zsh-plugin-for-wakatime

# git-branch-status is a must
# git clone https://github.com/bill-auger/git-branch-status/ .gbs/ # change 'gbs'

# IMPORTANT!!!!
# Don't forget to set the `/etc/locale.conf` file as `LANG=en_US.UTF-8` after
# generating the locales with locale-gen of else the default lang `C` will be
# set and a lot of characters will not render correctly.

# android stuff for when react native is needed
# Important: remember to enable the multilib repository at pacman.conf
# [https://wiki.archlinux.org/index.php/Android]
# Also point JAVA_HOME to openjdk 8!!!
yay -S jdk jdk8-openjdk android-studio android-sdk android-sdk-platform-tools android-emulator --noconfirm
npm install expo-cli --global
