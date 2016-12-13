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
yaourt -S i3-gaps i3lock i3lock-fancy i3bar i3status i3blocks xorg xorg-server \
xorg-xinit vim firefox xscreensaver termite thunar thunar-volman \
gvfs ffmpeg vlc mpd ncmpcpp scrot gscreenshot geeqie httpie dmenu2\
compton flashplugin otf-fira-mono oft-fira-sans otf-fontawesome --noconfirm

# The audio: 
yaourt -S pulseaudio pavucontrol pamixer --noconfirm

# pulse audio needs to be a daemon

# Other things: 
yaourt -S acpi --noconfirm

