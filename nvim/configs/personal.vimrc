"*****************************************************************************
"" Basic Setup
"*****************************************************************************"
"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set bomb
set binary

"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overriten by autocmd rules
set tabstop=4
set softtabstop=0
set shiftwidth=4
set expandtab

"" Enable hidden buffers
set hidden

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

"" Directories for swp files
set nobackup
set noswapfile

set fileformats=unix,dos,mac
set showcmd
set shell=/usr/bin/zsh

"*****************************************************************************
"" Visual Settings
"*****************************************************************************
syntax on
set ruler
set number

let no_buffers_menu=1

" " Or if you have Neovim >= 0.1.5
if (has("termguicolors"))
 set termguicolors
endif

"Credit joshdick
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
"if (empty($TMUX))
  if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
"endif
"
" Theme
set background=dark
let g:gruvbox_contrast_dark="medium"
let g:gruvbox_improved_warnings=1
let g:gruvbox_italic=1
let g:gruvbox_italicize_comments=1
colorscheme gruvbox

set mousemodel=popup
set t_Co=256
set guioptions=egmrti
set gfn=Monospace\ 10
"
"" Disable the blinking cursor.
set gcr=a:blinkon0
set scrolloff=3

"" Status bar
set laststatus=2

"" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

"*****************************************************************************
"" Autocmd Rules
"*****************************************************************************
"
"" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Disable visualbell
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"" Copy/Paste/Cut
" IMPORTANT: install `xclip` or else it will try to use tmux and it won't
" work properly
if has('unnamedplus')
  set clipboard+=unnamedplus
endif

" folding
set foldenable
set foldmethod=indent

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" set cursor line and column color [https://stackoverflow.com/a/29167687/931704]
" '#34495e' is wet asphalt [https://flatuicolors.com/palette/defo]
set cursorcolumn
hi CursorColumn ctermfg=White ctermbg=Yellow cterm=bold guibg=#34495e gui=bold
set cursorline
hi CursorLine ctermfg=White ctermbg=Yellow cterm=bold guibg=#34495e gui=bold
set colorcolumn=80
hi ColorColumn ctermfg=White ctermbg=Yellow cterm=bold guibg=#e77f67 gui=bold
set number
hi LineNr guifg=#e5e5e5
set mouse=a
set backspace=indent,eol,start
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
set list

highlight Cursor guifg=white guibg=black
highlight iCursor guifg=white guibg=steelblue
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10

" change selection color to yellow (more readable)
" [http://vim.1045645.n5.nabble.com/Howto-change-selected-text-s-color-background-tp1192545p1192547.html]
hi Visual guifg=blue guibg=yellow

" In case NERDTREE is not available
let g:NetrwIsOpen=0

function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        silent Lexplore 20
    endif
endfunction
