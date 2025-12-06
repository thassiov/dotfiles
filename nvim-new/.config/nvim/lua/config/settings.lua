-- Neovim Settings
-- All vim options and settings

-- Leader keys - Must be set before plugins load
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Disable swap files
vim.opt.swapfile = false

-- Nerd Font support
vim.g.have_nerd_font = true

-- Line numbers
vim.opt.number = true
-- vim.opt.relativenumber = true  -- Uncomment if you want relative line numbers

-- Mouse support
vim.opt.mouse = "a"

-- Don't show mode (already in statusline)
vim.opt.showmode = false

-- Clipboard sync with OS
vim.opt.clipboard = "unnamedplus"

-- Indentation
vim.opt.breakindent = true
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- Folding
vim.opt.foldmethod = "indent"

-- True color support
vim.opt.termguicolors = true

-- Undo history
vim.opt.undofile = true

-- Search
vim.opt.ignorecase = true  -- Case-insensitive searching
vim.opt.smartcase = true   -- Unless \C or capital in search
vim.opt.hlsearch = true    -- Highlight search results
vim.opt.inccommand = "split"  -- Preview substitutions live

-- Sign column
vim.opt.signcolumn = "yes"

-- Update time
vim.opt.updatetime = 250

-- Split behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = ">·", trail = "~", space = "␣", eol = "¬" }

-- Cursor
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.guicursor = "n-v-c:block-Cursor,n-v-c:blinkon0,i:blinkwait10"

-- Scroll offset
vim.opt.scrolloff = 10
