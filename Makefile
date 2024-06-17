homeDir=${HOME}
currentDir=${PWD}
packages=alacritty autorandr-screenlayout dunst gitconfig i3 nvim polybar rofi tmux xinit xrandr-screenlayout zsh

config:
	stow -S --verbose=2 $(packages)

dry.run.config:
	stow -Sn --verbose=2 $(packages)

reconfig:
	stow -R --verbose=2 $(packages)

dry.run.reconfig:
	stow -Rn --verbose=2 $(packages)

clean:
	stow -D --verbose=2 $(packages)

dry.run.clean: 
	stow -Dn --verbose=2 $(packages)
