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

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Status line
Plug 'vim-airline/vim-airline'

" File explorer
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Lang packs
"Plug 'sheerun/vim-polyglot'
" Now I'm using coc's plugin for it

" colorscheme
Plug 'w0ng/vim-hybrid'
Plug 'josuegaleas/jay'
Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
Plug 'rakr/vim-two-firewatch'
Plug 'arcticicestudio/nord-vim'
Plug 'ryanoasis/vim-devicons'

" Analytics
Plug 'wakatime/vim-wakatime'

" Code assist
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdcommenter'

" For my writting
Plug 'junegunn/goyo.vim'

" Linter
" Lint engine
" Plug 'w0rp/ale'
" coc already does that via plugin

"" Snippets and autocompletion
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" This hot new shiny stuff
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'liuchengxu/vista.vim'

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
