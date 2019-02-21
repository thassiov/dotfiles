#!/bin/sh
yay -S ffmpeg vlc geeqie dmenu2\
httpie python-pip exa xclip\
compton nitrogen arandr xcalib\
zathura zathura-pdf-poppler\
sublime-text-dev editorconfig-core-c parcellite\
docker nodejs\
ttf-ms-fonts otf-fira-mono oft-fira-sans otf-fontawesome\ 
pulseaudio pavucontrol pamixer\
acpi tlp tlp-rdw\
--noconfirm

pip install neovim

# git-branch-status is a must
git clone https://github.com/bill-auger/git-branch-status/ .gbs/ # change 'gbs'

# zsh-autosugestions (inside ~/.oh-my-zsh/custom/plugins/)
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/
