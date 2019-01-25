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
"Plug 'ctrlpvim/ctrlp.vim'
"Plug 'FelikZ/ctrlp-py-matcher'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'joshdick/onedark.vim'

" File explorer
Plug 'scrooloose/nerdtree'

" Splash screen
Plug 'mhinz/vim-startify'

" Lang packs
Plug 'sheerun/vim-polyglot'

" Code assist
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdcommenter'

" Navigation
"Plug 'easymotion/vim-easymotion'

" colorscheme
Plug 'arcticicestudio/nord-vim', { 'tag': 'v0.9.0' }

" Analytics
Plug 'wakatime/vim-wakatime'

" Linter
" Lint engine
"Plug 'vim-syntastic/syntastic'
Plug 'w0rp/ale'

" For project-specific configuration
" Note: requires editorconfig-core-c package
" [see https://github.com/editorconfig/editorconfig-core-c#readme]
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
