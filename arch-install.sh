#!/bin/bash

#echo "hello, motherfucker!"

# First: add the new user
useradd -m -G wheel -s /bin/bash thassiov
passwd thassiov

# Second: add the newly added user to the 'sudoers' file
# add 'thassiov' to the sudoers' file

# Third: install AALLL THE PACKAGEEEZZ
pacman -S nvim git docker tmux zsh curl

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
ln -s confs/.vimperatorrc .
ln -s confs/.gitconfig .
ln -s confs/.jshintrc .
ln -s confs/.xscreensaver .
ln -s confs/.xinit .
ln -s confs/.Xmodmap .
ln -s confs/tmux.conf .tmux.conf
ln -s confs/compton.conf .compton.conf
ln -s confs/mpd .mpd
ln -s confs/ncmpcpp .ncmpcpp
ln -s confs/.i3blocks.confs .

# Install yaourt
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -si
cd ..
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -si
cd ..

# Clone vimperator theme
mkdir .vimperator
https://github.com/vimpr/vimperator-colors.git ~/.vimperator/colors

## Configure oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Lastly: install the GUI packages
yaourt -S i3-gaps i3lock i3lock-fancy i3bar i3status i3blocks polybar xorg xorg-server \
xorg-xinit vim firefox xscreensaver termite pcmanfm\
gvfs ffmpeg vlc mpd ncmpcpp lightscreen gpodder geeqie httpie dmenu2\
compton flashplugin nitrogen arandr xcalib\
networkmanager network-manager-applet notify-osd\
sublime-text-dev editorconfig-core-c parcellite tomate-gtk --noconfirm

# screencast tools
yaourt -S screenkey simplescreenrecorder --noconfirm

# fonts
yaourt -S ttf-ms-fonts otf-fira-mono oft-fira-sans otf-fontawesome --noconfirm

# The audio: 
yaourt -S pulseaudio pavucontrol pamixer --noconfirm

# pulse audio needs to be a daemon

# Other things: 
yaourt -S acpi --noconfirm

# Now, for development
# For node
yaourt -S nodejs npm --noconfirm

# For Ionic
npm install -g cordova ionic
# See <http://cordova.apache.org/docs/en/latest/guide/platforms/android/index.html>
# It walks through the java/android environment configuration
# Important: for android-sdk to work on x86_64, you need to uncomment the multilib repo in pacman.conf
# Android needs 32 bit libs.
# See <https://wiki.archlinux.org/index.php/android#Android_development> for more info
yaourt -S jdk jre android-sdk android-sdk-platform-tools android-sdk-build-tools --noconfirm
# Configure android stuff (as root)
groupadd sdkusers
gpasswd -a <user> sdkusers
chown -R :sdkusers /opt/android-sdk/
chmod -R g+w /opt/android-sdk/
newgrp sdkusers

# Configure zsh-wakatime
# https://github.com/wbinglee/zsh-wakatime#zsh-plugin-for-wakatime

# Todoist
# yaourt -S nwjs-sdk --noconfirm
# git clone https://github.com/kamhix/todoist-linux.git /opt/todoist

# git-branch-status is a must
git clone https://github.com/bill-auger/git-branch-status/ .gbs/ # change 'gbs'


