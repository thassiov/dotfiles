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
NeoBundle 'SirVer/ultisnips'
NeoBundle 'honza/vim-snippets'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'tpope/vim-surround'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'wakatime/vim-wakatime'
NeoBundle 'fholgado/minibufexpl.vim'
NeoBundle 'jiangmiao/auto-pairs'
NeoBundle 'jelera/vim-javascript-syntax'
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'bling/vim-airline'
NeoBundle 'marijnh/tern_for_vim'
NeoBundle 'dradtke/VIP'
NeoBundle 'dkprice/vim-easygrep'

" Theme changer
NeoBundle 'xolox/vim-misc'
NeoBundle 'xolox/vim-colorscheme-switcher'

" Themes
NeoBundle 'cdmedia/itg_flat_vim'
NeoBundle 'flazz/vim-colorschemes' " gigantic vim colorschemes set
NeoBundle 'w0ng/vim-hybrid'


" You can specify revision/branch/tag.
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

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
"let g:UltiSnipsUsePythonVersion = 3

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

" " If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"

" Plugin - NerdCommenter
filetype plugin on

" Plugin - NerdTREE
nmap <F2> :NERDTreeToggle<CR>
nmap tre :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

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

set colorcolumn=78
set number
set mouse=a
set backspace=indent,eol,start
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
set list

colorscheme hybrid
