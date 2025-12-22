# Zinit plugins

# Theme - Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Custom command fuzzy finder
zinit snippet https://raw.githubusercontent.com/thassiov/cmdvault/refs/heads/main/shell/cmdvault.zsh

# Syntax highlighting, completions, and suggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# FZF tab completion (loaded last, after compinit and other plugins)
zinit light Aloxaf/fzf-tab
