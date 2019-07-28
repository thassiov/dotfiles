"" Map leader to ,
let mapleader=','

"
"*****************************************************************************
"" Abbreviations
"*****************************************************************************
"" no one is really happy until you have this shortcuts
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall

" Save
noremap <leader>w :w<CR>

" Jump and insert
nnoremap <leader>a A

"" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Gcommit<CR>
noremap <Leader>gsh :Gpush<CR>
noremap <Leader>gll :Gpull<CR>
noremap <Leader>gs :Gstatus<CR>
noremap <Leader>gb :Gblame<CR>
noremap <Leader>gd :Gvdiff<CR>
noremap <Leader>gr :Gremove<CR>

" nerdtree
"noremap <leader><Tab> :NERDTreeToggle<CR>
"noremap <leader>f<Tab> :NERDTreeFind<CR>
noremap <leader><Tab> :Lex 20<CR>
noremap <leader>f<Tab> :Lex 20<CR>

"" Tabs
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

"" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>

"" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

noremap YY "+y<CR>
noremap <leader>p "+gP<CR>
noremap XX "+x<CR>

"" Buffer nav
noremap <leader>z :bp<CR>
noremap <leader>x :bn<CR>

"" Open fzf
map <leader>q :GFiles<CR>
map <leader>fq :Files<CR>

"" Open buffer"
noremap <leader>b :Buffers<CR>

"" Close buffer
noremap <leader>c :bd<CR>

"" find text in project (the_silver_searcher)
map <leader>s :Ag!<CR>

map <leader>tl :Ag! @TODO\|@NOTE\|@FIXME<CR>

"" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>

"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

" To view the graph log
map gv :GV<CR>
map gfv :GV!<CR>

" Replace in visual mode [http://stackoverflow.com/a/676619]
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>"

" Folds all blocks except current [https://stackoverflow.com/a/8735199/931704]
" 'cafe' stands for 'Close All Folds Except'
nnoremap <silent> <leader>fafe zMzvzz

noremap <leader>- :split term://zsh<CR>
noremap <leader>\ :vsplit term://zsh<CR>

" find selection [http://vim.wikia.com/wiki/Search_for_visually_selected_text]
vnoremap // y/<C-R>"<CR>

" Format file
map <F7> mzgg=G`z

noremap <leader>cbd :set background=dark<CR>
noremap <leader>cbl :set background=light<CR>

noremap <leader>mm :Goyo<CR>

nnoremap <F5> "=strftime("%c")<CR>P
