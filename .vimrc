"NeoBundle Scripts-----------------------------
if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=/home/thassiov/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('/home/thassiov/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Add or remove your Bundles here:

" Snippets and autocompletion
NeoBundle 'SirVer/ultisnips'
NeoBundle 'honza/vim-snippets'
NeoBundle 'Shougo/neocomplete.vim'

" Navigation
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'fholgado/minibufexpl.vim'

" Code assistance
NeoBundle 'tpope/vim-surround'
NeoBundle 'jiangmiao/auto-pairs'
NeoBundle 'scrooloose/nerdcommenter'

" Git related
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'Xuyuanp/nerdtree-git-plugin'

" Class and method outline
NeoBundle 'majutsushi/tagbar'

" Analytics
NeoBundle 'wakatime/vim-wakatime'

" Linter
NeoBundle 'scrooloose/syntastic'

" Status bar
NeoBundle 'bling/vim-airline'
NeoBundle 'vim-airline/vim-airline-themes'

" For project-specific configuration
" Note: requires editorconfig-core-c package
" [see https://github.com/editorconfig/editorconfig-core-c#readme]
NeoBundle 'editorconfig/editorconfig-vim'

" Theme changer
NeoBundle 'xolox/vim-misc'
NeoBundle 'xolox/vim-colorscheme-switcher'

" Themes
NeoBundle 'cdmedia/itg_flat_vim'
NeoBundle 'flazz/vim-colorschemes' " gigantic vim colorschemes set
NeoBundle 'w0ng/vim-hybrid'

" # LANGUAGE SPECIFIC PLUGINS
" ## JS Plugins
" ### Improved syntax highlight
NeoBundle 'jelera/vim-javascript-syntax'

" ### Parses js files to better sugests completions to 'neocomplete'
" Note: NEEDS 'npm install' inside its directory
NeoBundle 'marijnh/tern_for_vim'

" ## Python Plugins
" ### the ViM Python IDE(ish)
NeoBundle 'klen/python-mode'

" ## Rust Plugins
" ### syntax highlighting, autoformatting
NeoBundle 'rust-lang/rust.vim'

" ## Go plugins
" ### Go (golang) support for Vim
NeoBundle 'fatih/vim-go'

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-------------------------

" airline config
set laststatus=2
"let g:airline_powerline_fonts = 1
let g:airline_theme = 'ubaryd'

" Usar python3
"let g:UltiSnipsUsePythonVersion = 2.7

" Trigger configuration.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" plugin - Git Gutter
let g:gitgutter_max_signs = 3000

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_javascript_checkers = ['jshint']
nmap syn :SyntasticCheck<CR>
" " If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"

" Plugin - NerdCommenter
filetype plugin on

" Plugin - Editor Config
let g:EditorConfig_exec_path = '/usr/bin/editorconfig'
" Added to work with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" Plugin - NERDTree
nmap <F2> :NERDTreeToggle<CR>
nmap tre :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Plugin - NERDTree git
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
  \}

" Plugin - TagBar
nmap <F3> :TagbarToggle<CR>
nmap tag :TagbarToggle<CR>

" Plugin -  MiniBufExpl (Colors)
hi MBENormal               guifg=#808080 guibg=fg
hi MBEChanged              guifg=#CD5907 guibg=fg
hi MBEVisibleNormal        guifg=#5DC2D6 guibg=fg
hi MBEVisibleChanged       guifg=#F1266F guibg=fg
hi MBEVisibleActiveNormal  guifg=#A6DB29 guibg=fg
hi MBEVisibleActiveChanged guifg=#F1266F guibg=fg

map <C-t> :MBEToggle<cr>

" Plugin - vim colors solarized
syntax on

" Plugin - ctrl-p
let g:ctrlp_custom_ignore = '\v[\/]\.(git)$'
let g:ctrlp_custom_ignore = '\v[\/]node_modules$'

" Habilita 256 cores no tema do vim
set t_Co=256

" tabs e indents
filetype plugin indent on
set tabstop=2 " softtab
set shiftwidth=2 " folding em softtab
set fdm=indent
set fdl=1

nmap t% :tabedit %<CR>
nmap td :tabclose<CR>
nmap tn :tabnew<CR>

nmap <C-0> :<C-w>_<CR>

set colorcolumn=78
set number
set mouse=a
set backspace=indent,eol,start
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
set list

set background=dark
colorscheme hybrid
