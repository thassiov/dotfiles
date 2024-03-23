echo "Linking legacy nvim config"
ln -s $(readlink -f ./legacy) $HOME/.config/nvim-legacy

echo "Linking kickstart nvim config"
ln -s $(readlink -f ./kickstart) $HOME/.config/nvim-kickstart

echo "Linking lazyvim nvim config"
ln -s $(readlink -f ./lazyvim-distro) $HOME/.config/nvim-lazyvim

echo "Done"
