# Neovim configuration

Minimal, modern Neovim setup. Tested on Nvim 0.12 (Arch + Ubuntu).

## Layout

```
nvim/
├── init.lua                    -- entry point
├── lazy-lock.json              -- plugin commit pins
├── lua/
│   ├── config/
│   │   ├── lazy.lua            -- lazy.nvim bootstrap
│   │   ├── settings.lua        -- vim options
│   │   ├── keymaps.lua         -- global keybindings
│   │   └── autocommands.lua    -- event handlers
│   └── plugins/
│       ├── editor.lua          -- vim-sleuth, vim-surround, close-buffers
│       ├── files.lua           -- nvim-tree
│       ├── git.lua             -- gitsigns + vim-fugitive
│       ├── lsp.lua             -- lspconfig + mason + blink.cmp + conform + lazydev
│       ├── markdown.lua        -- render-markdown, bullets.vim
│       ├── telescope.lua       -- telescope (master) + fzf-native + ui-select
│       ├── tools.lua           -- vim-test, hurl.nvim
│       ├── treesitter.lua      -- nvim-treesitter (main branch)
│       └── ui.lua              -- ayu, lualine, zen-mode, todo-comments, mini.{ai,pairs}
├── install-ubuntu.sh           -- one-shot setup for Ubuntu/Debian
├── stylua.toml                 -- 2-space indent
├── selene.toml + vim.yml       -- lint config (vim global)
└── README.md
```

## Dependencies

| Required | Why |
|---|---|
| `nvim` ≥ 0.12 | min version for nvim-treesitter `main` branch and `vim.lsp.config` API |
| `git` | fugitive, gitsigns, lazy.nvim |
| `ripgrep` | telescope grep |
| `make` | telescope-fzf-native build |
| `cc` (gcc or clang) | treesitter parser compilation |
| `tree-sitter` CLI ≥ 0.26.1 | nvim-treesitter `main` parser installer |

| Optional | Why |
|---|---|
| `hurl`, `jq` | hurl.nvim REST client |
| node / npm | provider, mason packages |
| python3 + `pynvim` | optional python provider |

Formatters install automatically via Mason (`prettierd`, `gofumpt`,
`goimports`, `markdownlint`, `sqlfmt`, `stylua`).

## Install

### Ubuntu / Debian

```bash
git clone <dotfiles> ~/.dotfiles
~/.dotfiles/nvim/install-ubuntu.sh
nvim     # plugins install on first launch
```

### Arch

```bash
sudo pacman -S neovim git ripgrep base-devel tree-sitter-cli hurl jq
ln -s ~/.dotfiles/nvim ~/.config/nvim
nvim
```

## Keybindings

Leader is `,`.

### Pickers (numbered group)

| Key | Action |
|---|---|
| `,1` | grep tracked content (`.gitignore`-respecting) |
| `,!` | grep everywhere (no-ignore, hidden) |
| `,2` | list git-tracked files |
| `,@` | list all files |
| `,3` | list buffers |
| `,#` | LSP document symbols |
| `,,` | command palette |

### Pickers (search group, `s` prefix)

| Key | Action |
|---|---|
| `,sw` | grep word under cursor |
| `,sb` | grep open buffers only |
| `,s/` | fuzzy-find in current buffer |
| `,sk` | search keymaps |

### File ops

| Key | Action |
|---|---|
| `,fn` | nvim config files |
| `,ff` | LSP code action |
| `,<Tab>` | toggle file tree |
| `,<S-Tab>` | toggle file tree + focus current file |

### LSP / code (g prefix + diagnostics)

| Key | Action |
|---|---|
| `,gd` | LSP definitions |
| `,gy` | LSP type definitions |
| `,gr` | LSP references |
| `,lw` | LSP workspace symbols |
| `,le` | diagnostic float |
| `,cd` | diagnostics list |
| `K` | hover documentation |
| `[d` / `]d` | prev / next diagnostic |
| `,e` | open diagnostic float (global) |
| `,q` | diagnostic quickfix list |

The Nvim 0.11+ built-in LSP defaults (`grn`/`gra`/`grr`/`gri`) are
disabled — everything LSP lives behind leader.

### Git

| Key | Action |
|---|---|
| `,gs` | `:Git` status | (fugitive) |
| `,gb` | `:Git blame` (full file side-buffer) |
| `,gD` | `:Gdiffsplit` (current file vs HEAD) |
| `,gt` (n) | `:0Glog` file history → quickfix |
| `,gt` (v) | line-range history via `:Gclog -L` |
| `,gc` | telescope git commits |
| `,5` | gitsigns blame popup (commit + message + diff) |
| (auto) | gutter signs, current-line blame lens, branch/diff in lualine |

### Buffers / windows

| Key | Action |
|---|---|
| `,w` | save |
| `,o` | close hidden buffers (keep visible) |
| `,O` | close all other buffers |
| `<C-c>` | close current buffer |
| `<Tab>` / `<S-Tab>` | next / prev buffer |
| `<C-h/j/k/l>` | window focus |
| `<Esc>` | close floating windows |
| `,.` | clear search highlight |
| `,fafe` | fold all except current |

### Tools

| Key | Action |
|---|---|
| `,t` | vim-test run nearest |
| `,T` | vim-test run file |
| `,H` | hurl run all |
| `,h` | hurl run at cursor |
| `,vh` | hurl run verbose |
| `,z` | zen mode |

### Completion (blink.cmp, insert mode)

| Key | Action |
|---|---|
| `<Tab>` / `<S-Tab>` | cycle / cycle back (super-tab) |
| `<CR>` | accept |
| `<C-Space>` | show / toggle docs |
| `<C-b>` / `<C-f>` | scroll docs |
| `<C-l>` / `<C-h>` | snippet forward / back |

## Linting / formatting

- `stylua` — formats lua on save (config: `stylua.toml`, 2-space indent)
- `selene` — lints lua (config: `selene.toml` + `vim.yml`)
- `conform.nvim` — runs formatters on save per filetype

Run manually:

```
stylua --check lua/
selene lua/
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| Plugin not loaded | `:Lazy sync` |
| LSP not attaching | `:checkhealth vim.lsp` / `:LspInfo` |
| Formatter missing | `:Mason` install it, or `:ConformInfo` |
| Parser error in markdown | ensure `markdown` + `markdown_inline` installed via `:TSInstall` |
| Telescope previewer crash | confirm `branch = "master"` (0.1.x branch is frozen) |
