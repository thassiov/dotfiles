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
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'tpope/vim-fugitive'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'sheerun/vim-polyglot' " ???
Plug 'vim-scripts/grep.vim'
Plug 'vim-scripts/CSApprox'
Plug 'bronson/vim-trailing-whitespace'
Plug 'majutsushi/tagbar'
"Plug 'scrooloose/syntastic'
Plug 'neomake/neomake'
Plug 'Yggdroot/indentLine'
Plug 'avelino/vim-bootstrap-updater' " ???
Plug 'junegunn/gv.vim'
" For project-specific configuration
" Note: requires editorconfig-core-c package
" [see https://github.com/editorconfig/editorconfig-core-c#readme]
Plug 'editorconfig/editorconfig-vim'

" Code assistance
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdcommenter'

" Markdown
Plug 'gabrielelana/vim-markdown'

let g:make = 'gmake'
if exists('make')
        let g:make = 'make'
endif
Plug 'Shougo/vimproc.vim', {'do': g:make} " ???

"" Vim-Session
Plug 'xolox/vim-misc' " ???
Plug 'xolox/vim-session' " Acho que não preciso por conta to startify

if v:version >= 703
  Plug 'Shougo/vimshell.vim'
endif

if v:version >= 704
  "" Snippets
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'FelikZ/ctrlp-py-matcher'
endif

Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'

"" Color
Plug 'tomasr/molokai'
Plug 'mhartington/oceanic-next'
Plug 'w0ng/vim-hybrid'
Plug 'josuegaleas/jay'
Plug 'morhetz/gruvbox'
Plug 'fxn/vim-monochrome'


"*****************************************************************************
"" Custom bundles
"*****************************************************************************

" javascript
Plug 'sheerun/vim-polyglot'
Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }

" I don't know what to call it
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/seoul256.vim'

" ViM's custom Slash Screen
Plug 'mhinz/vim-startify'

" VIM HARD MODE!!11!!
Plug 'wikitopian/hardmode'

" Analytics
Plug 'wakatime/vim-wakatime'

"*****************************************************************************
"*****************************************************************************

"" Include user's extra bundle
if filereadable(expand("~/.config/nvimrc.local.bundles"))
  source ~/.config/nvimrc.local.bundles
endif

call plug#end()

" Required:
filetype plugin indent on


