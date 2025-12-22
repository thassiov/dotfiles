ZDOTDIR="${ZDOTDIR:-$HOME/.dotfiles/zsh}"

# Init
source $ZDOTDIR/init/instant-prompt.zsh
source $ZDOTDIR/init/zinit.zsh

# my exported variables
source $ZDOTDIR/env/exports.zsh

# nvm
source $ZDOTDIR/init/nvm.zsh

# custom aliases
source $ZDOTDIR/shell/aliases.zsh

# custom functions
source $ZDOTDIR/shell/functions.zsh

# snippets
source $ZDOTDIR/plugins/omz-plugins.zsh

# Load completions
source $ZDOTDIR/init/compinit.zsh

# History
source $ZDOTDIR/config/history.zsh

## Plugins
source $ZDOTDIR/plugins/plugins.zsh

# Theme
source $ZDOTDIR/config/theme.zsh

# Completion styling
source $ZDOTDIR/config/completion.zsh
