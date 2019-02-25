#!/bin/sh
yay -S ffmpeg vlc geeqie dmenu2 \
httpie python-pip exa xclip \
compton nitrogen arandr xcalib \
zathura zathura-pdf-poppler \
sublime-text-dev editorconfig-core-c parcellite \
docker nodejs npm \
ttf-ms-fonts otf-fira-mono oft-fira-sans otf-fontawesome \
pulseaudio pavucontrol pamixer \
acpi tlp tlp-rdw \
--noconfirm

# add neovim`s python support
# pip install neovim

# git-branch-status is a must
#git clone https://github.com/bill-auger/git-branch-status/ .gbs/ # change 'gbs'

# zsh-autosugestions (inside ~/.oh-my-zsh/custom/plugins/) - remember to change back the zshrc (oh my zsh creates a new one
#git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/
