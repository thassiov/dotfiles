call plug#begin()
" Add or remove your Bundles here:

" ViM's custom Slash Screen
Plug 'mhinz/vim-startify'

" VIM HARD MODE!!11!!
Plug 'wikitopian/hardmode'
" Snippets and autocompletion
"Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'Shougo/neocomplete.vim'

" Navigation
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'fholgado/minibufexpl.vim'

" Code assistance
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdcommenter'

" Git related
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Class and method outline
Plug 'majutsushi/tagbar'

" Analytics
Plug 'wakatime/vim-wakatime'

" Linter
Plug 'scrooloose/syntastic'

" Status bar
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" For project-specific configuration
" Note: requires editorconfig-core-c package
" [see https://github.com/editorconfig/editorconfig-core-c#readme]
Plug 'editorconfig/editorconfig-vim'

" Theme changer
Plug 'xolox/vim-misc'
Plug 'xolox/vim-colorscheme-switcher'

" Themes
Plug 'cdmedia/itg_flat_vim'
"Plug 'flazz/vim-colorschemes' " gigantic vim colorschemes set
Plug 'w0ng/vim-hybrid'
Plug 'morhetz/gruvbox'

" # LANGUAGE SPECIFIC PLUGINS
" ## JS Plugins
" ### Improved syntax highlight
Plug 'jelera/vim-javascript-syntax'

" ### Parses js files to better sugests completions to 'neocomplete'
" Note: NEEDS 'npm install' inside its directory
Plug 'marijnh/tern_for_vim'

" ## Python Plugins
" ### the ViM Python IDE(ish)
Plug 'klen/python-mode'

" ## Rust Plugins
" ### syntax highlighting, autoformatting
Plug 'rust-lang/rust.vim'

" ## Go plugins
" ### Go (golang) support for Vim
Plug 'fatih/vim-go'

" Add plugins to &runtimepath
call plug#end()

" Startify config

let g:startify_list_order = [
				\ ['   These are my sessions:'],
				\ 'sessions',
				\ ['   My most recently used files'],
				\ 'files',
				\ ['   My most recently used files in the current directory:'],
				\ 'dir',
				\ ['   These are my bookmarks:'],
				\ 'bookmarks',
				\ ['   These are my commands:'],
				\ 'commands',
				\ ]

let g:startify_change_to_dir = 1
let g:startify_change_to_vcs_root = 1

" airline config
set laststatus=2
"let g:airline_powerline_fonts = 1
let g:airline_theme = 'ubaryd'

" Usar python3
"let g:UltiSnipsUsePythonVersion = 3.5

" Trigger configuration.
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<c-b>"
"let g:UltiSnipsJumpBackwardTrigger="<c-z>"

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
nmap <Fr> :TagbarToggle<CR>
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

nmap <C-e> :tabedit %<CR>
nmap <C-y> :tabclose<CR>
nmap tn :tabnew<CR>

nmap <C-0> :<C-w>_<CR>

set cursorline
set cursorcolumn
set colorcolumn=78
set number
set mouse=a
set backspace=indent,eol,start
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
set list

set background=dark
colorscheme hybrid

noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" HARD MODE!!!11!!
nnoremap <leader>h <Esc>:call ToggleHardMode()<CR>
