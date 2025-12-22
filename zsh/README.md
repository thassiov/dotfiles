# ZSH Configuration

Modular zsh configuration using [zinit](https://github.com/zdharma-continuum/zinit) as the plugin manager.

## Setup

Symlink the `.zshrc` to your home directory:

```bash
ln -s ~/.dotfiles/zsh/.zshrc ~/.zshrc
```

That's it. The config references all modules via `$ZDOTDIR` which defaults to `~/.dotfiles/zsh`.

## Structure

```
zsh/
├── .zshrc                    # Main entry point
├── .envs.sensitive           # API keys, tokens (gitignored)
├── .envs.sensitive.example   # Template for sensitive vars
│
├── init/
│   ├── instant-prompt.zsh    # P10k instant prompt (must be first)
│   ├── zinit.zsh             # Plugin manager bootstrap
│   ├── nvm.zsh               # Node version manager
│   └── compinit.zsh          # Completion system init
│
├── env/
│   └── exports.zsh           # Environment variables, PATH, sensitive vars
│
├── plugins/
│   ├── omz-plugins.zsh       # Oh-My-Zsh plugins (includes fzf keybindings)
│   └── plugins.zsh           # Zinit plugins (p10k, fzf-tab, syntax, etc.)
│
├── config/
│   ├── history.zsh           # History settings
│   ├── completion.zsh        # Completion styling (zstyles)
│   └── theme.zsh             # Theme config (p10k)
│
└── shell/
    ├── aliases.zsh           # Aliases
    └── functions.zsh         # Custom functions
```

## Load Order

The load order matters for completions and fzf-tab:

1. **instant-prompt** - P10k instant prompt (must be first)
2. **zinit** - Plugin manager initialization
3. **nvm** - Node version manager
4. **exports** - Environment variables and PATH
5. **aliases/functions** - Shell customizations
6. **omz-plugins** - OMZ snippets including fzf keybindings
7. **compinit** - Initialize completion system + replay compdefs
8. **plugins** - Zinit plugins (fzf-tab loaded here, last)
9. **config** - History, completion styling, theme

### FZF Integration

Two plugins work together for fzf:
- **OMZP::fzf** (in omz-plugins.zsh) - Provides keybindings (Ctrl+R, Ctrl+T, Alt+C)
- **fzf-tab** (in plugins.zsh) - Replaces tab completion with fzf interface

Do NOT load `/usr/share/fzf/completion.zsh` separately as it conflicts with fzf-tab.

## Sensitive Variables

Copy the example file and fill in your values:

```bash
cp ~/.dotfiles/zsh/.envs.sensitive.example ~/.dotfiles/zsh/.envs.sensitive
```

This file is gitignored.
