#!/bin/bash

SETUPDIR=${PWD}
CLI_PROGRAMS=$(awk '{print $1}' $SETUPDIR/packages/cli-programs.packages.list)
GUI_PROGRAMS=$(awk '{print $1}' $SETUPDIR/packages/gui-programs.packages.list)
FONTS=$(awk '{print $1}' $SETUPDIR/packages/fonts.packages.list)
POWER_AND_BATTERY=$(awk '{print $1}' $SETUPDIR/packages/power-and-battery.packages.list)
SOUND=$(awk '{print $1}' $SETUPDIR/packages/sound.packages.list)
VIRTUALIZATION=$(awk '{print $1}' $SETUPDIR/packages/virtualization.packages.list)
DEV_ENVIRONMENT=$(awk '{print $1}' $SETUPDIR/packages/dev-environment.packages.list)
BLUETOOTH=$(awk '{print $1}' $SETUPDIR/packages/bluetooth.packages.list)

echo "Setting up clean arch linux installation (done with archinstall)"

echo
echo "Installing git and base-devel for setting up yay"
sudo pacman -S git base-devel --noconfirm

echo
echo "Updating certs to make git play nice"
sudo update-ca-trust

echo
echo "Setting up yay"
git clone https://aur.archlinux.org/yay.git /tmp/yay-clone
cd /tmp/yay-clone
makepkg -si

cd $SETUPDIR

echo
echo "Installing packages"
yay -S $CLI_PROGRAMS $GUI_PROGRAMS $FONTS $POWER_AND_BATTERY $SOUND $VIRTUALIZATION $DEV_ENVIRONMENT $BLUETOOTH --noconfirm

echo
echo "Configure ssh server"
sudo systemctl enable sshd
sudo systemctl start sshd

echo
echo "Add user thassiov to docker group"
sudo groupadd docker
sudo gpasswd -a thassiov docker

echo
echo "Add user thassiov to video group"
sudo gpasswd -a thassiov video

echo
echo "Enable vnstat"
sudo systemctl enable vnstat.service
sudo systemctl start vnstat.service

echo
echo "Enable bluetooth"
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

echo
echo "Enable tlp power management"
sudo systemctl enable tlp.service

echo
echo "Unblock antenas"
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
sudo systemctl enable rfkill-unblock@all

echo
echo "Configure thassiov user oh-my-zsh and set zsh as default shell"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo
echo "Clone dotfiles"
git clone https://github.com/thassiov/dotfiles .dotfiles

echo
echo "Ensure .config directory exists"
mkdir .config

echo
echo "Configure alacritty"
ln -s ~/.dotfiles/alacritty ~/.config

echo
echo "Configure tmux"
ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf

echo
echo "Configure zsh"
mv ~/.zshrc ~/.zshrc.old
ln -s ~/.dotfiles/.zshrc ~/
ln -s ~/.dotfiles/.envs ~/
ln -s ~/.dotfiles/.clialiases ~/
ln -s ~/.dotfiles/.cli-functions ~/
ln -s ~/.dotfiles/.zsh-keybindings ~/

echo
echo "Configure gitconfig"
ln -s ~/.dotfiles/.gitconfig ~/

echo
echo "Configure neovim"
ln -s ~/.dotfiles/nvim-configs/kickstart ~/.config/nvim

echo
echo "Echoing machine interfaces"
ip a

echo
echo "Manual tasks"
echo "1 - Don't forget to set `USB_AUTOSUSPEND=0` at `/etc/tlp.conf` or else usb charging won't work [https://linrunner.de/en/tlp/docs/tlp-configuration.html#usb]"
echo "2 - Check to see if the virtualbox daemon is enabled. You can enable it manually or simply restart the machine"
echo "3 - Make sure to link `70-synaptics.conf` file at `/etc/X11/xorg.conf.d` to make the touchpad work"
echo "4 - Make sure to link `.Xmodmap` at the $HOME directory if needed"
echo "5 - Run the `kb/symbols/replace-files.sh` script to make the 60% keyboard work properly"

echo
echo "Done. Happy hacking!"
