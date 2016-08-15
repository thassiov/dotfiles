#!/bin/bash

#echo "hello, motherfucker!"

# First: add the new user
adduser -m -G wheel -s /bin/bash thassiov
passwd thassiov

# Second: add the newly added user to the 'sudoers' file
# add 'thassiov' to the sudoers' file

# Third: install AALLL THE PACKAGEEEZZ
pacman -S vim git docker tmux zsh curl

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
ln -s confs/.vimrc .
ln -s confs/.vimperatorrc .
ln -s confs/.gitconfig .
ln -s confs/.jshintrc .
ln -s confs/.xscreensaver .
ln -s confg/.xinit .

# Eigth: prepare and place neobundle for vim
mkdir -p .vim/bundle
cd .vim/bundle
git clone https://github.com/Shougo/neobundle.vim.git .
cd ~

# Install yaourt
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -si
cd ..
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -si
cd ..

# Eleventh: prepare and place neobundle for vim
mkdir -p .vim/bundle
cd .vim/bundle
git clone https://github.com/Shougo/neobundle.vim.git .
cd ~

# Lastly: install the GUI packages
yaourt -S i3-gaps i3lock i3lock-fancy i3bar i3status xorg xorg-server \
xorg-xinit vim git firefox xscreensaver rxvt-unicode-256xresources \
urxvt-resize-font-git rxvt-unicode-terminfo urxvt-fullscreen ttf-fira-mono \
ffmpeg vlc --noconfirm

# The audio: alsa, pulse-audio and pavucontrol
# Other things: acpi

