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

" Fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" thing
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary!' }

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" Splash screen
Plug 'hardcoreplayers/dashboard-nvim'

" Special Syntax
Plug 'MaxMEllon/vim-jsx-pretty'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" awesome floating terminal
Plug 'voldikss/vim-floaterm'

" zoom split (?)
Plug 'dhruvasagar/vim-zoom'

" colorscheme
Plug 'morhetz/gruvbox'
Plug 'josuegaleas/jay'
Plug 'ryanoasis/vim-devicons'
Plug 'ghifarit53/tokyonight-vim'
Plug 'logico/typewriter-vim'
Plug 'joshdick/onedark.vim'
Plug 'dikiaap/minimalist'

" Analytics
Plug 'wakatime/vim-wakatime'

" Code assist
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdcommenter'

" For my writting
Plug 'junegunn/goyo.vim'
Plug 'xolox/vim-notes'
Plug 'xolox/vim-misc'

" tags
Plug 'liuchengxu/vista.vim'

" This hot new shiny stuff
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" coc extensions
let g:coc_global_extensions = [
            \'coc-css',
            \'coc-eslint',
            \'coc-explorer',
            \'coc-go',
            \'coc-html',
            \'coc-json',
            \'coc-markdownlint',
            \'coc-marketplace',
            \'coc-snippets',
            \'coc-tslint-plugin',
            \'coc-tsserver',
            \'coc-ultisnips',
            \'coc-yaml',
            \]

" For project-specific configuration
" NOTE: requires npm install -g editorconfig !!!!
Plug 'editorconfig/editorconfig-vim'

"*****************************************************************************
"*****************************************************************************

"" Include user's extra bundle
if filereadable(expand("~/.config/nvimrc.local.bundles"))
  source ~/.config/nvimrc.local.bundles
endif

call plug#end()

set nocp
filetype plugin on 
