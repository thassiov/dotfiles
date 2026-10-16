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
│       ├── db.lua              -- vim-dadbod + dadbod-ui (prod connection, workbench query logs)
│       ├── files.lua           -- nvim-tree
│       ├── http.lua            -- rest.nvim (.http client)
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
| `tree-sitter` CLI ≥ 0.26.1 | nvim-treesitter `main` parser installer; also builds the `http` parser for rest.nvim. **Not** the Ubuntu apt package (0.20.8 on 24.04, too old), and not npm (nvim-treesitter's README says so). Install the release binary from github.com/tree-sitter/tree-sitter/releases (`tree-sitter-linux-x64.gz`, check the SHA-256 shown on the release page) into `~/.local/bin`, or `cargo install tree-sitter-cli --locked` |
| `libreadline-dev` | lazy.nvim builds Lua 5.1 (hererocks) for rest.nvim's Lua dependencies; without it the build stops at `readline/readline.h: No such file or directory` |

| Optional | Why |
|---|---|
| `jq` | formats JSON responses in the rest.nvim result pane (and hurl.nvim) |
| `hurl` | hurl.nvim REST client |
| `psql` (postgresql-client) | vim-dadbod shells out to it |
| `docker` + the `mcp-vpn` container | dadbod's `prod` connection goes through the VPN container |
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

## rest.nvim (HTTP client)

Spec: `lua/plugins/http.lua`. Loads on `.http` files (JetBrains syntax). It sets **no key mappings**; use the commands:

| Command | Action |
|---|---|
| `:Rest run` | run the request under the cursor (`:Rest run {name}` for a named one) |
| `:Rest last` | run the last request again |
| `:Rest open` | open the result pane (`H` / `L` cycle result panes) |
| `:Rest env select` | choose the `.env` file for the current `.http` file |
| `:Rest logs`, `:Rest cookies` | open the logs / cookies file |

How it fits together, because three separate pieces have to line up:

1. lazy.nvim installs the plugin and builds its Lua dependencies (nvim-nio, mimetypes, xml2lua, fidget) with luarocks. That needs `libreadline-dev`.
2. The `http` tree-sitter parser must be in `~/.local/share/nvim/site/parser/`. It is installed by nvim-treesitter because `"http"` is in the list in
   `lua/plugins/treesitter.lua`, which needs the `tree-sitter` CLI. The copy that luarocks builds is not on Neovim's runtime path and is not used.
3. `curl`.

**Manual step on a fresh install.** lazy's rock build for rest.nvim fails with `Failed initializing build back-end for build type 'treesitter-parser'`
(reproduced on a clean rock tree, with `libreadline-dev` and the CLI present). The build backend gets installed into the plugin's rock tree, but luarocks
looks for it in its own tree. Install it there once, then rebuild:

```bash
~/.local/share/nvim/lazy-rocks/hererocks/bin/luarocks install luarocks-build-treesitter-parser
nvim --headless "+Lazy! build rest.nvim" +qa
```

The first command needs lazy to have created `lazy-rocks/hererocks` already: run the `Lazy! build` line once first (it fails), then the two in order. The
`tree-sitter` binary must be on `PATH` for the rebuild.

rest.nvim has no request history browser and no Postman import. Last release 3.13.0 (2025-06-11).

### Using it with the workbench

`tools/http/http-client [tray-dir]` opens nvim with nvim-tree on `workbench/tool-data/http/`: `collections/` (converted Postman collections, one `.http`
file per request) and `trays/` (a link per tray to its `requests/requests.http` log, written by `tools/http/http-request`). With a tray, that tray's log opens
at its last entry. It loads `~/.work-credentials/appfolio.env` into nvim's environment (`--env FILE` for others), so `{{APPFOLIO_CLIENT_ID}}` style
placeholders resolve (it loads `propexo-prod.env` and `propexo-sandbox.env` too, when they exist). Put the cursor anywhere in a request (the `###` line included)
and press `,S`: it runs the request, and it is the same key that runs a query in `.sql` files with dadbod. The mapping is buffer-local to `http` files
(`lua/plugins/http.lua`).

Response bodies are formatted and foldable. rest.nvim formats a body with the `formatprg` of its content type, so `lua/plugins/http.lua` gives scratch `json`
buffers `formatprg = tools/http/lib/json-format` (jq; if the body is not valid JSON it prints the original text instead of an error). The result pane folds by
indent, through your ufo setup: `za` toggles the fold under the cursor, `zM` closes all, `zR` opens all. Folds start open. Needs `jq`. A response of several hundred
KiB becomes thousands of lines, so narrow the request (a recent `LastUpdatedAtFrom`, a page size) before sending it.

The converted AppFolio requests fetch their own OAuth token when there is none or it is about to expire (it lasts 300 seconds), and ask for the AppFolio
database id once per nvim session. Run `Auth/Select-database` to change the database. Propexo requests ask for the integration id once per session. The Lua helpers
are in `tools/http/lib/`.

Known limits, all seen in testing:

- Multipart (`multipart/form-data`) bodies are not supported by rest.nvim 3.13.0. The converter marks those requests "NOT RUNNABLE".
- A variable with no value becomes an empty string without a warning. Check the request before sending.
- rest.nvim percent-encodes `[` and `]` in URLs (`filters%5bId%5d`). curl, and the `http-request` wrapper, send them as they are.
- Once in about ten starts the plugin raised `Invalid log level: 3` while loading, and ran fine on the next start. Cause not confirmed.
- Requests that write data (POST, PATCH, PUT, DELETE) hit the live API. Converted files carry a warning line at the top.

## dadbod (database client)

Spec: `lua/plugins/db.lua`. Open it with `:DBUI` (no mapping). Needs `psql` on the host.

- One connection, `prod`. The URL is read at `:DBUI` time from `~/.work-credentials/db.env` (`POSTGRES_URL`); the host is replaced by the VPN
  container's address, port 15432. The container is started on demand with `~/.work-credentials/vpn/vpn-ctl.sh ensure`. No secret is stored in this repo.
- Saved queries live in `workbench/tool-data/dadbod/prod/`: one link per tray to that tray's `queries/database/queries.sql`. The links are made by
  `tools/db/tray-sql`, and `tools/db/db-client [tray-dir]` opens nvim with a tray's log already open.
- `g:db_ui_execute_on_save = 0`: saving never runs the file. Select a query (`vip`) and run it with `<Leader>S` (leader is `,` here).
- Format-on-save is skipped for paths containing `/tool-data/dadbod/` or `/queries/database/` (see `conform.nvim` in `lua/plugins/lsp.lua`), so
  logged entries keep their layout.
- dadbod treats any `:word` as a bind parameter, even inside a comment, and prompts for a value. Avoid `:word` in query logs.
- Opening a query file directly (`:edit`) does not bind it to `prod`. Open it through the drawer, or use `tools/db/db-client`.

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
| `,S` | run the request under the cursor (`.http` files); runs a query in `.sql` files with dadbod |
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
| rest.nvim build: `readline/readline.h: No such file or directory` | `sudo apt install libreadline-dev`, then `nvim --headless "+Lazy! build rest.nvim" +qa` |
| `Failed to attach tree-sitter-http parser` / `No parser for language "http"` | `site/parser/http.so` is missing. Install the `tree-sitter` CLI (≥ 0.26.1), then `:TSInstall http` |
| rest.nvim build: `Failed initializing build back-end for build type 'treesitter-parser'` | install `luarocks-build-treesitter-parser` into the hererocks tree, then rebuild (see "rest.nvim" above) |
| `tree-sitter CLI is not installed` while building a rock or parser | put the `tree-sitter` binary on `PATH` (`~/.local/bin`), then retry |
| Every nvim start retries a failed plugin build | fix the cause, or disable the plugin spec until you can (rename `lua/plugins/<name>.lua` to `.lua.disabled`) |
| Telescope previewer crash | confirm `branch = "master"` (0.1.x branch is frozen) |
