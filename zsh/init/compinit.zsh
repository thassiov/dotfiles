# Completion system initialization
#
# WHY THIS ORDER MATTERS:
# -----------------------
# Zsh plugins often register completions using `compdef`, which requires the
# completion system (compinit) to be loaded first. However, zinit buffers
# these compdef calls when plugins are loaded BEFORE compinit.
#
# This file should be sourced AFTER omz-plugins.zsh but BEFORE plugins.zsh
# so that plugins like cmdvault (which use compdef) work correctly.

autoload -Uz compinit && compinit

# Replay all compdef calls that zinit buffered from OMZ snippets
zinit cdreplay -q
