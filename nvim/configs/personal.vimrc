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
set tabstop=2
set softtabstop=0
set shiftwidth=2
set expandtab

"" Enable hidden buffers
set hidden

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Formatting
" Set to force automatic comment insertion (I like it)
" [https://vim.fandom.com/wiki/Disable_automatic_comment_insertion]
set formatoptions=cro

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
let ayucolor="dark"
let g:ayu_italic_comment = 1 
let g:ayu_sign_contrast = 1 
colorscheme ayu

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

"" Make .tsx file work correctly with the .ts syntax
augroup SyntaxSettings
    autocmd!
    autocmd BufNewFile,BufRead *.tsx set filetype=typescript
    autocmd BufNewFile,BufRead Tiltfile set filetype=python
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
" '#182C61' is called ending navy blue [https://flatuicolors.com/palette/in]
set cursorcolumn
hi CursorColumn ctermfg=White ctermbg=Yellow cterm=bold guibg=#182C61 gui=bold
set cursorline
hi CursorLine ctermfg=White ctermbg=Yellow cterm=bold guibg=#182C61 gui=bold
" set colorcolumn=80
" hi ColorColumn ctermfg=White ctermbg=Yellow cterm=bold guibg=#e77f67 gui=bold
set number
set mouse=a
set backspace=indent,eol,start
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
set list

highlight LineNr guifg=grey

" '#FC427B' is called sasquatch socks
" [https://flatuicolors.com/palette/in]
highlight Cursor guifg=yellow guibg=#FC427B
highlight iCursor guifg=white guibg=steelblue
set guicursor=n-v-c:block-Cursor
" set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10

" change selection color to yellow (more readable)
" [http://vim.1045645.n5.nabble.com/Howto-change-selected-text-s-color-background-tp1192545p1192547.html]
hi Visual guibg=#404040

set conceallevel=2

function ToggleLightDarkTheme()
  if g:ayucolor == "dark"
    set background=dark
    let g:ayu_italic_comment = 1 
    let g:ayu_sign_contrast = 1 
    let g:ayucolor="mirage"
    let g:airline_theme="jay"
    colorscheme ayu
  elseif g:ayucolor == 'mirage'
    set background=light
    let g:ayu_italic_comment = 1 
    let g:ayu_sign_contrast = 1 
    let g:ayucolor="light"
    let g:airline_theme="jay"
    colorscheme ayu
  else
    set background=dark
    let g:ayu_italic_comment = 1 
    let g:ayu_sign_contrast = 1 
    let g:ayucolor="dark"
    let g:airline_theme="jay"
    colorscheme ayu
  endif
endfunction

" Goyo.vim
let g:goyo_width=100

" handles goyo_enter and goyo_leave events
function! s:goyo_enter()
  " if executable('tmux') && strlen($TMUX)
  "   silent !tmux set status off
  "   silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  " endif
  set noshowmode
  set noshowcmd
  set scrolloff=999
  set nu
endfunction

function! s:goyo_leave()
  " if executable('tmux') && strlen($TMUX)
  "   silent !tmux set status on
  "   silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  " endif
  set showmode
  set showcmd
  set scrolloff=5
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
