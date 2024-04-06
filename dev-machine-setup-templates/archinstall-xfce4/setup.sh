#!/bin/bash

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

cd ~

echo
echo "Installing packages"
yay -S $(awk '{print $1}' /home/thassiov/shared/packages.list) --noconfirm

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
echo "Configure thassiov user default shell to zsh"
sudo chsh -s $(which zsh) 

echo
echo "Configure thassiov user oh-my-zsh"
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
echo "Done. Happy hacking!"
