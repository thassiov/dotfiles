#!/bin/bash

#echo "hello, motherfucker!"

# First: add the new user
# adduser -m -G wheel -s /bin/bash thassiov
# passwd thassiov

# Second: add the newly added user to the 'sudoers' file
# add 'thassiov' to the sudoers' file

# Third: install AALLL THE PACKAGEEEZZ
pacman -S xorg xorg-server xorg-xinit xfce4 xfce4-goodies vim git firefox\
terminator xscreensaver docker 

# Forth: now login with the new user
# su thassiov

# Fifth: add the user to the docker group
# sudo groupadd docker
# sudo gpasswd -a ${USER} docker

# Sixth: Place the xinitrc to the right place
# cp /etc/X11/xinit/xinitrc ~/.xinitrc
#echo "Comment the end of the '.xinitrc' file and append 'exec xfce4-session'"

# Seventh: update the ca. Without it, git can't clone anything :(
# update-ca-trust

# Eigth: get the configuration files
# git clone https://github.com/thassiov/confs.git

# Nineth: get the bash-git-prompt program (because it's awesome)
# git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1

# Tenth: now place AAALLL config files
# mv .bashrc .bashrc.old
# ln -s confs/.bashrc .
# source .bashrc
# mv .bash_profile .bash_profile.old
# ln -s confs/.bash_profile .
# ln -s confs/.vimrc .
# ln -s confs/.vimperatorrc .
# ln -s confs/.gitconfig .
# ln -s confs/.jshintrc .
# ln -s confs/.xscreensaver .
# ln -s confs/.byobu .
# cp -r confs/terminator .config/

# Eleventh: prepare and place neobundle for vim
# mkdir -p .vim/bundle
# cd .vim/bundle
# git clone https://github.com/Shougo/neobundle.vim.git .
# cd ~



