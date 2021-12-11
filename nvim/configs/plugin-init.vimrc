"*****************************************************************************
"" Vim-PLug core
" originally from http://vim-bootstrap.com/
"*****************************************************************************
if has('vim_starting')
  set nocompatible               " Be iMproved
endif

let vimplug_exists=expand('~/.config/nvim/autoload/plug.vim')

let g:vim_bootstrap_langs = "javascript"
let g:vim_bootstrap_editor = "nvim"				" nvim or vim

if !filereadable(vimplug_exists)
  echo "Installing Vim-Plug..."
  echo ""
  silent !\curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif

" Required:
call plug#begin(expand('~/.config/nvim/plugged'))

"*****************************************************************************
"" Plug install packages
"*****************************************************************************

" Git
Plug 'airblade/vim-gitgutter'
" @TODO I need to use more the features of fugitive or else I need to get rid
" of it
Plug 'tpope/vim-fugitive'

" Status line
Plug 'vim-airline/vim-airline'

" colorscheme
Plug 'josuegaleas/jay'
Plug 'Luxed/ayu-vim'

" Analytics
Plug 'wakatime/vim-wakatime'

" Code assist
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'preservim/nerdcommenter'

" For project-specific configuration
Plug 'editorconfig/editorconfig-vim'

" Tree view
Plug 'kyazdani42/nvim-web-devicons' " for file icons - needs global configs
Plug 'kyazdani42/nvim-tree.lua'

" things I don't need but do need
Plug 'kazhala/close-buffers.nvim'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'

" diagnostics and stuff
Plug 'glepnir/lspsaga.nvim'
Plug 'folke/lsp-colors.nvim'

" Autocompletion
Plug 'hrsh7th/nvim-compe'

" Snippets
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'rafamadriz/friendly-snippets'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Telescope's stuff
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

"*****************************************************************************
"*****************************************************************************

"" Include user's extra bundle
if filereadable(expand("~/.config/nvimrc.local.bundles"))
  source ~/.config/nvimrc.local.bundles
endif

call plug#end()

set nocp
filetype plugin on
