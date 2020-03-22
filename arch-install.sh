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
ln -s confs/.gitconfig .
ln -s confs/.xscreensaver .
ln -s confs/.xinit .
ln -s confs/.Xmodmap .
ln -s confs/tmux.conf .tmux.conf
ln -s confs/compton.conf .compton.conf

# Install yay (you'll need base-devel)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

## Configure oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Lastly: install the packages
yay -S \
## desktop stuff
i3-gaps i3lock i3lock-fancy-dualmonitors-git i3status i3blocks \
polybar xorg xorg-server xorg-xinit xscreensaver \
compton nitrogen arandr xcalib rofi \
networkmanager network-manager-applet notify-osd \
parcellite geeqie \
## types stuff
ttf-ms-fonts otf-fira-mono otf-fira-sans nerd-fonts-complete
## browsers
firefox google-chrome \
## audio
pulseaudio pavucontrol pamixer \
## codecs
ffmpeg flashplugin vlc \
## terminal and text editor stuff
termite vim neovim \
editorconfig-core-c httpie \
exa xclip \
python-pip \
nvm-git \
diff-so-fancy grv \
## file explorer
pcmanfm \
## office stuff\
libreoffice-fresh evince \
## file system stuff
mtools dosfstools gvfs gparted \ 
## other stuff
gksu \
--noconfirm

# python support for neovim
pip install neovim

# pulse audio needs to be a daemon
pulseaudio -D

# Other things: 
yay -S acpi --noconfirm

# tlp - power management
# http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html#arch
sudo pacman -S tlp tlp-rdw 
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service 
sudo systemctl enable NetworkManager-dispatcher.service 
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket 

# Configure zsh-wakatime
# https://github.com/wbinglee/zsh-wakatime#zsh-plugin-for-wakatime

# git-branch-status is a must
# git clone https://github.com/bill-auger/git-branch-status/ .gbs/ # change 'gbs'
