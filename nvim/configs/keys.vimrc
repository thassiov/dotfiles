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


"" Leader - special shortcuts"

" Save file
nnoremap <leader>w :write<CR>
" close all other buffers (different from :only)
" [https://stackoverflow.com/a/42071865/931704] - the snippet
" [https://vi.stackexchange.com/a/2288] - about the bar/pipe character
nnoremap <leader>o :%bd\|e#<CR>

"" Leader - plugin access

"" Git - vim-fugitive
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gb :Gblame<CR>
nnoremap <Leader>vd :Gvdiff<CR>

"" NERDTree
noremap <leader><Tab> :NERDTreeToggle<CR>
noremap <leader>f<Tab> :NERDTreeFind<CR>

"" Fuzzy finder -  fzf
nnoremap <leader>q :GFiles<CR>
nnoremap <leader>fq :Files<CR>
" This is the default extra key bindings. They work inside fzf's pane
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

"" Find text in project (the_silver_searcher)
nnoremap <leader>s :Ag!<CR>

"" Find special tokens (this can be useful)"
nnoremap <leader>tl :Ag! @TODO\|@NOTE\|@FIXME<CR>

" COC mappings

" Managing CoC extension
" Manage extensions
nnoremap <leader>cex  :<C-u>CocList extensions<cr> " Manage extensions
" Open marketplace list (depends on coc.marketplace being present)
nnoremap <leader>cmkt  :<C-u>CocList marketplace<cr> " Open marketplace list (depends on coc.marketplace being present)
" Show commands
nnoremap <leader>cc  :<C-u>CocList commands<cr> " Show commands

" Code
" Show all diagnostics
nnoremap <leader>cd  :<C-u>CocList diagnostics<cr> " Show all diagnostics
" Fix autofix problem of current line
nnoremap <leader>ff  <Plug>(coc-fix-current)  " Fix autofix problem of current line
" Find symbol of current document
nnoremap <leader>ol  :<C-u>CocList outline<cr> " Find symbol of current document

" Go to definition (in a new tab [https://github.com/neoclide/coc.nvim/issues/1249])
" Maybe use this mappings
nnoremap <leader>gd :call CocAction('jumpDefinition', 'tabe')<CR> " Go to definition
" Go to references
nnoremap <leader>gr :call CocAction('jumpReferences')<CR> " Go to references
" Go to type definition
nnoremap <leader>gy :call CocAction('jumpTypeDefinition')<CR> " Go to type definition
" Go to implementation
"nnoremap <leader>ci <Plug>(coc-implementation)

"" Markdown focus mode - Goyo"
nnoremap <leader>G :Goyo<CR>
nnoremap <leader>120 :Goyo 120<CR>

"" Cool floating terminal - Floaterm"
nnoremap <leader>t :FloatermToggle<CR>

"" A hack to wrap the current file into 78 char lines"
nnoremap <leader>T :set textwidth=78<CR>ggVGgq

"" BUFFER AND TAB NAVIGATION - Ctrl and Tab"

"" Navigate between tabs using Tab
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

"" Switching windows
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

"" Open buffer"
nnoremap <C-b> :Buffers<CR>
"" Close buffer
nnoremap <C-c> :bd<CR>
"" Next buffer"
nnoremap <C-p> :bnext<CR>
"" Previous buffer"
nnoremap <C-o> :bprevious<CR>

"" MISC"

" Reaload my vim config (assuming it is in the correct directory)
nnoremap <leader>0 :so ~/.config/nvim/init.vim<CR>

"" Print the current timestamp in cursor position"
nnoremap <leader><F5> "=strftime("%c")<CR>P

" Folds all blocks except current [https://stackoverflow.com/a/8735199/931704]
" 'cafe' stands for 'Close All Folds Except'
nnoremap <leader>fafe zMzvzz

" find selection [http://vim.wikia.com/wiki/Search_for_visually_selected_text]
vnoremap // y/<C-R>"<CR>

"" Clean search (highlight)
nnoremap <leader><space> :noh<cr>

" Replace in visual mode [http://stackoverflow.com/a/676619]
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>"

"" THINGS I RARELY USE - OF FORGOT HOW TO"

" Format file
map <F7> mzgg=G`z

"" I think I used this when I didn't know how to share the system's
" clipboard with vim's
noremap YY "+y<CR>
noremap <leader>p "+gP<CR>
noremap XX "+x<CR>
