# Neovim Configuration Documentation

Comprehensive guide for this Neovim setup with keybindings, dependencies, and plugin configurations.

## Table of Contents

1. [External Dependencies](#external-dependencies)
2. [Keybindings Reference](#keybindings-reference)
3. [Plugin Setup Guides](#plugin-setup-guides)
4. [Change History](#change-history)

---

## External Dependencies

### Required (Core Functionality)

These tools are essential for basic plugin functionality:

#### Git
**Required by:** vim-fugitive, gitsigns, diffview, nvim-tree, vgit
**Used for:** Git integration, version control features

```bash
# Ubuntu/Debian
sudo apt install git

# Arch
sudo pacman -S git
```

#### Ripgrep (rg)
**Required by:** Telescope (live_grep, grep_string)
**Used for:** Fast text searching across files

```bash
# Ubuntu/Debian
sudo apt install ripgrep

# Arch
sudo pacman -S ripgrep
```

#### Make
**Required by:** telescope-fzf-native.nvim
**Used for:** Building native FZF extension

```bash
# Ubuntu/Debian
sudo apt install build-essential

# Arch
sudo pacman -S base-devel
```

#### C Compiler (gcc/clang)
**Required by:** nvim-treesitter
**Used for:** Compiling Treesitter parsers

```bash
# Ubuntu/Debian
sudo apt install build-essential

# Arch
sudo pacman -S base-devel
```

#### Claude Code CLI
**Required by:** claudecode.nvim
**Used for:** AI-powered coding assistance

Follow the official guide at: https://docs.anthropic.com/en/docs/claude-code

Verify: `claude --version`

### Optional Dependencies

#### Code Formatters

**Lua (stylua)**
```bash
cargo install stylua
# Or let Mason install it automatically
```

**JavaScript/TypeScript/CSS/HTML/YAML/JSON (Prettier)**
```bash
npm install -g prettier
# Or let Mason install it automatically
```

**C/C++ (astyle)**
```bash
# Ubuntu/Debian
sudo apt install astyle

# Arch
sudo pacman -S astyle
```

**Go (goimports, gofumpt)**
```bash
go install golang.org/x/tools/cmd/goimports@latest
go install mvdan.cc/gofumpt@latest
```

#### REST Client Tools

**hurl** (for hurl.nvim)
```bash
# Ubuntu/Debian (22.04+)
sudo apt install hurl

# Arch
sudo pacman -S hurl

# Or via cargo
cargo install hurl
```

**jq** (JSON formatting)
```bash
# Ubuntu/Debian
sudo apt install jq

# Arch
sudo pacman -S jq
```

### Quick Setup Scripts

**Ubuntu/Debian:**
```bash
#!/bin/bash
sudo apt update
sudo apt install -y git ripgrep build-essential jq
sudo apt install -y nodejs npm python3 python3-pip clangd
npm install -g prettier markdownlint-cli
```

**Arch Linux:**
```bash
#!/bin/bash
sudo pacman -S git ripgrep base-devel jq
sudo pacman -S nodejs npm python python-pip clang
npm install -g prettier markdownlint-cli
```

### Verification

Run `:checkhealth` in Neovim to verify everything is working.

---

## Keybindings Reference

### Design Philosophy

This config uses **mnemonic prefixes** for organization:
- `<leader>f*` - **F**ind/Files operations
- `<leader>s*` - **S**earch operations
- `<leader>l*` - **L**SP operations
- `<leader>g*` - **G**it operations

Most common operations use single keys for speed (e.g., `<leader>f`, `<leader>g`, `<leader>b`).

### Telescope - Finding & Searching

#### Super Quick Access (Most Common)

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>f` | git_files | Find files (git tracked) |
| `<leader>F` | find_files | Find ALL files (including ignored) |
| `<leader>g` | live_grep | Grep/search text in project |
| `<leader>b` | buffers | Search open buffers |
| `<leader>/` | current_buffer_fuzzy_find | Search in current buffer |

#### File Operations (`f` prefix)

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>ff` | git_files | Find files (git tracked) |
| `<leader>fa` | find_files | Find all files |
| `<leader>fb` | buffers | Find buffers |
| `<leader>fn` | find_files (nvim config) | Find Neovim config files |

#### Search Operations (`s` prefix)

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>sg` | live_grep | Search by grep |
| `<leader>sw` | grep_string | Search word under cursor |
| `<leader>sb` | live_grep (open buffers) | Search in open buffers |
| `<leader>s/` | current_buffer_fuzzy_find | Search in current buffer |
| `<leader>sk` | keymaps | Search keymaps |
| `<leader>sc` | commands | Search commands |

#### LSP Operations (`l` prefix)

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>ld` | lsp_definitions | Go to definition |
| `<leader>lt` | lsp_type_definitions | Go to type definition |
| `<leader>lr` | lsp_references | Find references |
| `<leader>ls` | lsp_document_symbols | Search document symbols |
| `<leader>lw` | lsp_workspace_symbols | Search workspace symbols |
| `<leader>ln` | rename | Rename symbol |
| `<leader>la` | code_action | Code actions |
| `<leader>le` | diagnostic.open_float | Show errors (floating) |
| `<leader>lD` | diagnostics | Search all diagnostics |
| `K` | hover | Hover documentation |

#### Git Operations (Telescope)

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>gc` | git_commits | Search git commits |

### Git Operations

#### vim-fugitive & diffview

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>gs` | Git status | Git status interface |
| `<leader>gb` | Git blame | Git blame |
| `<leader>gd` | DiffviewFileHistory | Git diff current file |
| `<leader>gD` | DiffviewOpen | Git diff index |

#### VGit - Visual Git Integration

**Hunk Operations:**

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>ghp` | hunk_preview | Preview changes in current hunk |
| `<leader>ghs` | buffer_hunk_stage | Stage current hunk |
| `<leader>ghr` | buffer_hunk_reset | Reset/discard current hunk |
| `<leader>ghu` | buffer_reset | Reset entire buffer |
| `]h` | hunk_down | Jump to next hunk |
| `[h` | hunk_up | Jump to previous hunk |

**What is a Hunk?**
A hunk is a contiguous block of changes in a file. Git groups your edits into hunks - sections of consecutive lines that were modified. This lets you stage/commit specific changes instead of entire files.


**Buffer Operations:**

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>gf` | buffer_diff_preview | Show diff for current file |
| `<leader>gl` | buffer_blame_preview | Show blame/author info |
| `<leader>gt` | buffer_history_preview | Show file history over time |

**Project Operations:**

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>gp` | project_diff_preview | Show all changed files |
| `<leader>gP` | project_logs_preview | Show project commit logs |
| `<leader>gx` | toggle_diff_preference | Toggle unified/split diff view |

### File Navigation

| Key | Command | Description |
|-----|---------|-------------|
| `<leader><Tab>` | NvimTree toggle | Toggle file tree |
| `<leader><S-Tab>` | NvimTreeFindFileToggle | Toggle file tree and focus current file |

### General Keybindings

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>.` | nohlsearch | Clear search highlight |
| `<leader>w` | Write | Save buffer |
| `<C-c>` | Close buffer | Close current buffer |
| `<Tab>` | bnext | Next buffer |
| `<S-Tab>` | bprevious | Previous buffer |
| `<leader>o` | Close hidden buffers | Close all hidden buffers |
| `<leader>O` | Close other buffers | Close all except current |
| `<Esc>` | Close floating windows | Close all popup windows |

### Diagnostics

| Key | Command | Description |
|-----|---------|-------------|
| `[d` | goto_prev | Previous diagnostic |
| `]d` | goto_next | Next diagnostic |
| `<leader>e` | open_float | Show diagnostic error |
| `<leader>q` | setloclist | Open diagnostic quickfix |

### Window Navigation

| Key | Command | Description |
|-----|---------|-------------|
| `<C-h>` | Focus left | Move to left window |
| `<C-l>` | Focus right | Move to right window |
| `<C-j>` | Focus down | Move to lower window |
| `<C-k>` | Focus up | Move to upper window |

### Testing & Tools

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>t` | TestNearest | Run nearest test |
| `<leader>T` | TestFile | Run all tests in file |
| `<leader>H` | HurlRunner | Run all HTTP requests |
| `<leader>h` | HurlRunnerAt | Run HTTP request at cursor |

### Claude Code (AI Assistant)

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>ac` | ClaudeCode | Toggle Claude Code terminal |
| `<leader>af` | ClaudeCodeFocus | Focus Claude Code window |
| `<leader>ar` | Resume | Resume previous session |
| `<leader>aC` | Continue | Continue last conversation |
| `<leader>am` | Select model | Choose Claude model |
| `<leader>ab` | Add buffer | Add current file to context |
| `<leader>as` | Send (visual) | Send selection to Claude |
| `<leader>aa` | Accept diff | Accept changes |
| `<leader>ad` | Deny diff | Reject changes |

---

## Plugin Setup Guides

### Claude Code Setup

#### Prerequisites

1. **Install Claude Code CLI**

Follow the official installation guide from Anthropic:
- Visit: https://docs.anthropic.com/en/docs/claude-code
- Download and install the Claude Code CLI
- Make sure `claude` command is available in your PATH

Verify: `claude --version`

2. **Authentication**

The Claude Code CLI handles authentication. On first run, it will:
- Open a browser window for authentication
- Link your CLI session to your Anthropic account

#### Usage Examples

**Ask Claude to refactor code:**
1. Open the file you want to refactor
2. Press `<leader>ac` to open Claude
3. Type your request
4. Review proposed changes
5. Press `<leader>aa` to accept or `<leader>ad` to reject

**Send a specific code snippet:**
1. Select code in visual mode
2. Press `<leader>as` to send selection
3. Ask your question
4. Review and apply suggestions

**Add context from multiple files:**
1. Open first file
2. Press `<leader>ab` to add to context
3. Navigate to other files and repeat
4. Press `<leader>ac` and ask about relationships

**Resume previous conversation:**
1. Press `<leader>ar` to resume last session
2. Continue where you left off

#### Configuration

Plugin is configured in `lua/plugins/ai.lua`.

Settings:
- Terminal opens on the **right side**
- Uses **30% of screen width**
- Auto-closes when you exit Claude
- Runs on ports **10000-65535**

### VGit Setup

VGit provides visual git integration with inline diffs, blame, and history.

**Features enabled:**
- Live Gutter - Shows git changes in the gutter
- Live Blame - Shows author and commit info
- Unified Diff - Default diff view (toggle with `<leader>gx`)

**Common Workflows:**

*Review changes before committing:*
1. `<leader>gp` - See all changed files
2. Navigate to a file
3. `<leader>gf` - View file diff
4. `]h` / `[h` - Navigate between hunks
5. `<leader>ghs` - Stage hunks to commit

*Investigate who changed code:*
1. `<leader>gl` - View blame for current file
2. See author and commit info
3. `<leader>gt` - View full file history

*Quick hunk management:*
1. Make changes to a file
2. `]h` - Jump to next change
3. `<leader>ghp` - Preview the hunk
4. `<leader>ghs` - Stage it, or `<leader>ghr` - Discard it

---

## Change History

### Plugins Added
- **claudecode.nvim** - AI-powered coding with Claude Code CLI
- **vgit.nvim** - Visual git integration with inline diffs and blame

### Plugins Removed
- **avante.nvim** - Replaced with claudecode.nvim for better CLI integration
- **dooing** - Todo list manager (conflicted with LSP keybindings)
- **outline.nvim** - Code outline viewer (conflicted with buffer management, use Telescope LSP symbols instead)

### Keybinding Reorganization

**Telescope keybindings were completely reorganized** for better ergonomics:

**Before:**
- Used numbers and symbols requiring Shift: `<leader>1`, `<leader>!`, `<leader>@`, `<leader>$`, `<leader>%`
- Poor mnemonics: hard to remember what number does what
- Inconsistent grouping

**After:**
- Mnemonic prefixes: `f` (find), `s` (search), `l` (LSP), `g` (git)
- No Shift required: all lowercase letters
- Fast access: common operations on single keys
- Logical grouping: related commands share prefixes

**Migration Example:**
- `<leader>1` → `<leader>f` (find files)
- `<leader>!` → `<leader>F` (find all files) - no more Shift!
- `<leader>2` → `<leader>g` (grep)
- `<leader>@` → `<leader>sw` (search word) - no more Shift!

### Git Plugin Integration

Added comprehensive git workflow support:
- **vim-fugitive** - Git commands and status
- **diffview.nvim** - File history and diffs
- **gitsigns.nvim** - Gutter signs
- **vgit.nvim** - Visual previews and hunk management

All git operations organized under `<leader>g*` prefix for consistency.

---

## Tips & Best Practices

### Discovering Keybindings

Use `<leader>sk` (search keymaps) and type keywords like:
- "git" - See all git-related shortcuts
- "search" - See all search operations
- "lsp" - See all language server operations
- "hunk" - See git hunk operations

### Language Servers

Language servers are automatically managed by Mason. When you open a file, Mason will:
- Detect the language
- Install the appropriate LSP if not present
- Start the language server

You can manually manage servers with `:Mason`.

### Formatters

Code formatting happens automatically on save via `conform.nvim`. Formatters are configured in `lua/plugins/lsp.lua`.

If a formatter isn't installed, Mason will attempt to install it, or you can install it manually using the quick setup scripts above.

### Project-Specific Settings

For project-specific Neovim settings, create `.nvim.lua` or `.exrc` in your project root (you may need to enable this feature in settings).

---

## Troubleshooting

### Plugin not working?
```vim
:Lazy sync
:checkhealth
```

### LSP not starting?
```vim
:LspInfo
:Mason
```

### Formatter not working?
```vim
:ConformInfo
```

### Claude Code CLI not found?
```bash
which claude
# Should show path to claude binary
```

---

## Further Customization

All plugin configurations are in `lua/plugins/`:
- `ai.lua` - AI assistant (Claude Code)
- `telescope.lua` - Fuzzy finder and search
- `git.lua` - Git integration
- `lsp.lua` - Language servers and formatters
- `files.lua` - File explorer
- `ui.lua` - Theme and UI elements
- `editor.lua` - Editing enhancements
- `tools.lua` - Testing and REST client

General Neovim settings are in `lua/config/`:
- `settings.lua` - Vim options
- `keymaps.lua` - General keybindings
- `autocommands.lua` - Auto commands
