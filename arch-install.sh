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
i3-gaps i3status polybar compton nitrogen \
arandr xcalib rofi dunst \
networkmanager network-manager-applet notify-osd \
parcellite geeqie scrot \
spotify popcorntime-bin \
reaper-bin \
postman-bin \
gammy \ # blue light blocker
blueman \
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
nvm-git \
diff-so-fancy grv \
the_silver_searcher \
xclip \
docker-compose \
vagrant virtualbox virtualbox-host-modules-arch\
## file explorer
pcmanfm \
## office stuff\
libreoffice-fresh evince \
## file system stuff
mtools dosfstools ntfs-3g gvfs gparted \ 
## other stuff
gksu vnstat \
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
yay -S acpi --noconfirm

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

# Configure zsh-wakatime
# https://github.com/wbinglee/zsh-wakatime#zsh-plugin-for-wakatime

# git-branch-status is a must
# git clone https://github.com/bill-auger/git-branch-status/ .gbs/ # change 'gbs'

# IMPORTANT!!!!
# Don't forget to set the `/etc/locale.conf` file as `LANG=en_US.UTF-8` after
# generating the locales with locale-gen of else the default lang `C` will be
# set and a lot of characters will not render correctly.
