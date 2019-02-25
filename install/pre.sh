#!/bin/sh

# also go in /etc/makepkg.conf and change makeflags to 'j(number of processors - 1)'
# to compile things quickly

mv ~/.bashrc ~/.bashrc.old
ln -s ~/confs/.zshrc .
source ~/.zshrc
mkdir ~/.config
ln -s ~/confs/nvim ~/.config/
ln -s ~/confs/termite ~/.config/
ln -s ~/confs/.vimperatorrc ~/
ln -s ~/confs/.gitconfig ~/
ln -s ~/confs/.jshintrc ~/
ln -s ~/confs/.xscreensaver ~/
ln -s ~/confs/.xinit ~/
ln -s ~/confs/.Xmodmap ~/
ln -s ~/confs/tmux.conf ~/.tmux.conf
ln -s ~/confs/compton.conf ~/.compton.conf
ln -s ~/confs/.i3blocks.confs ~/.

# install yay
git clone https://aur.archlinux.org/yay.git /tmp
cd /tmp/yay
makepkg -si
