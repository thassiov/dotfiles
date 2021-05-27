" Map leader to ,
let mapleader=','

"*****************************************************************************
" Abbreviations
"*****************************************************************************
" no one is really happy until you have this shortcuts
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


" Leader - special shortcuts"

" Save file
nnoremap <leader>w :write<CR>
" close all other buffers (different from :only)
"[https://stackoverflow.com/a/42071865/931704] - the snippet
"[https://vi.stackexchange.com/a/2288] - about the bar/pipe character
nnoremap <leader>o :%bd\|e#<CR>

" Leader - plugin access

" Git vim-fugitive
" Git status
nnoremap <Leader>gs :Gstatus<CR>
" Git blame
nnoremap <Leader>gb :Gblame<CR>
" Git diff
nnoremap <Leader>gd :Gvdiff<CR>

" GV - gv.vim
map <Leader>gv :GV<CR>
map <Leader>gfv :GV!<CR>

" Vista.vim
" Open bar with current file's symbols"
nnoremap <leader>4 :Vista!!<CR>

" Clap.vim
" Open list current file's symbols"
nnoremap <leader>$ :Clap tags<CR>
" Open list of buffers"
nnoremap <leader>3 :Clap buffers<CR>
" Open list of files managed by git"
nnoremap <leader>1 :Clap gfiles<CR>
" Open list of files in the project"
nnoremap <leader>! :Clap files<CR>

" fzf.vim
" This is the default extra key bindings. They work inside fzf's pane
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Find text in project (the_silver_searcher)
nnoremap <leader>2 :Ag!<CR>
" Find special tokens (this can be useful)"
nnoremap <leader>@ :Ag! @TODO\|@NOTE\|@FIXME<CR>

" COC mappings

" Managing CoC extension
" Manage extensions
nnoremap <leader>E  :<C-u>CocList extensions<CR>
" Open marketplace list (depends on coc.marketplace being present)
nnoremap <leader>M  :<C-u>CocList marketplace<CR>
" Show commands
nnoremap <leader>cl  :<C-u>CocList commands<CR>

" Code
" Show all diagnostics
nnoremap <leader>D  :<C-u>CocList diagnostics<CR>
" Fix autofix problem of current line
nnoremap <leader>ff  <Plug>(coc-fix-current)

" Go to definition (in a new tab [https://github.com/neoclide/coc.nvim/issues/1249])
" Maybe use this mappings
" Go to definition
nnoremap <leader>d :call CocAction('jumpDefinition')<CR>
" Go to references
nnoremap <leader>r :call CocAction('jumpReferences')<CR>
" Go to type definition
" nnoremap <leader>y :call CocAction('jumpTypeDefinition')<CR>
" Search under cursor, project wide
nnoremap <C-s> :CocSearch <C-R>=expand("<cword>")<CR><CR>
" Open file explorer
nnoremap <leader><Tab> :CocCommand explorer<CR>

nnoremap <leader>C :CocAction<CR>

" BUFFER AND TAB NAVIGATION - Ctrl and Tab"

" Navigate between buffers using Tab
" Next buffer"
nnoremap <Tab> :bnext<CR>
" Previous buffer"
nnoremap <S-Tab> :bprevious<CR>
" nnoremap <silent> <S-t> :tabnew<CR>

" Switching windows
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" Close buffer
nnoremap <C-c> :bd<CR>
" Next buffer"
" nnoremap <C-x> :bnext<CR>
" Previous buffer"
" nnoremap <C-z> :bprevious<CR>

" MISC"

" Reaload my vim config (assuming it is in the correct directory)
nnoremap <leader>0 :so ~/.config/nvim/init.vim<CR>

" Print the current timestamp in cursor position"
nnoremap <leader><F5> "=strftime("%c")<Return>P

" Folds all blocks except current [https://stackoverflow.com/a/8735199/931704]
" 'cafe' stands for 'Close All Folds Except'
nnoremap <leader>fafe zMzvzz

" find selection [http://vim.wikia.com/wiki/Search_for_visually_selected_text]
vnoremap // y/<C-R>"<CR>

" Clean search (highlight)
" nnoremap <leader>/ :noh<CR>

" Replace in visual mode [http://stackoverflow.com/a/676619]
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>"

" THINGS I RARELY USE - OR FORGOT HOW TO"

nnoremap <leader>/ :noh<Return>

" Format file
" map <F7> mzgg=G`z

" I think I used this when I didn't know how to share the system's
" clipboard with vim's
" noremap YY "+y<CR>
" noremap <leader>p "+gP<CR>
" noremap XX "+x<CR>
