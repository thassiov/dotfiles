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

" Switching windows
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" Leader - special shortcuts"
" Save file
nnoremap <leader>w :write<CR>

" close the current buffer (does not handle unsaved buffers)
nnoremap <leader>Q :q<CR>
" close all other buffers (different from :only)
"[https://stackoverflow.com/a/42071865/931704] - the snippet
"[https://vi.stackexchange.com/a/2288] - about the bar/pipe character
nnoremap <leader>o <cmd>lua require('close_buffers').delete({ type = 'hidden', force = true })<CR>
nnoremap <leader>O <cmd>lua require('close_buffers').delete({ type = 'other' })<CR>

" Leader - plugin access

" Git vim-fugitive
" Git status
nnoremap <Leader>gs <cmd>lua require('telescope.builtin').git_status()<CR>
" builtin.git_status
" Git blame
nnoremap <Leader>gb :Git blame<CR>
" Git diff
nnoremap <Leader>gd :Gdiffsplit<CR>


" Lazygit
" Open for current working directory
nnoremap <leader>gg :LazyGit<CR>
" Open for the current buffer
nnoremap <leader>G :LazyGitCurrentFile<CR>

" symbols
" symbols fuzzy search on current buffer's 
nnoremap <leader>4 <cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>

" finder
" Open list of buffers
nnoremap <leader>3 <cmd>lua require('telescope.builtin').buffers()<CR>
" Open list of files managed by git"
nnoremap <leader>1 <cmd>lua require('telescope.builtin').git_files()<CR>
" Open list of files in the project"
nnoremap <leader>! <cmd>lua require('telescope.builtin').find_files()<CR>

" Search commits
nnoremap <leader>5 <cmd>lua require('telescope.builtin').git_commits()<CR>
" Search commits for the current buffer
nnoremap <leader>% <cmd>lua require('telescope.builtin').git_bcommits()<CR>

" Find text in project (the_silver_searcher)
nnoremap <leader>2 <cmd>lua require('telescope.builtin').live_grep()<CR>
" Search selected text
"noremap <leader>@  y : Ag! <C-R>=getreg('"')<CR><CR>
" Find text under cursor
nnoremap <leader>@ <cmd>lua require('telescope.builtin').grep_string()<CR>

" Code
" show diagnostics for the current buffer
nnoremap <leader>' <cmd>lua vim.diagnostic.open_float()<CR>
" show diagnostics for the current workspace
nnoremap <leader>D :Telescope diagnostics<CR>
" Fix autofix problem of current line
" nnoremap <leader>ff  <Plug>(coc-fix-current)

" Test runner
nmap <silent> <leader>T :TestNearest<CR>
nmap <silent> <leader>t :TestFile<CR>

" Maybe use this mappings
" Go to definition
nnoremap <leader>d <cmd>lua require('telescope.builtin').lsp_definitions()<CR>
" Go to references
nnoremap <leader>r <cmd>lua require('telescope.builtin').lsp_references()<CR>
" Get documentation on hovered word
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>

" Open file explorer
nnoremap <leader><Tab> :NvimTreeToggle<CR>

" lsp actions
nnoremap <leader>a <cmd>lua require('telescope.builtin').lsp_code_actions()<CR>
nnoremap <leader>A <cmd>lua require('telescope.builtin').lsp_range_code_actions()<CR>

" vim commands
nnoremap <leader><leader> <cmd>lua require('telescope.builtin').commands(require('telescope.themes').get_ivy({}))<CR>

" Get help
nnoremap <leader>? <cmd>lua require('telescope.builtin').help_tags(require('telescope.themes').get_ivy({}))<cr>

" BUFFER AND TAB NAVIGATION - Ctrl and Tab"

" Navigate between buffers using Tab
" Next buffer"
nnoremap <Tab> :bnext<CR>
" Previous buffer"
nnoremap <S-Tab> :bprevious<CR>
" nnoremap <silent> <S-t> :tabnew<CR>

" ToggleLightDarkTheme
" nnoremap <leader>T :call ToggleLightDarkTheme()<CR>

" Close buffer
nnoremap <C-c> :bd<CR>

" MISC"

" Toggle Goyo | focused buffer 
nnoremap <leader>z :Goyo<CR>

" Reaload my vim config (assuming it is in the correct directory)
nnoremap <leader>0 :so ~/.config/nvim/init.vim<CR>

" Folds all blocks except current [https://stackoverflow.com/a/8735199/931704]
" 'cafe' stands for 'Close All Folds Except'
nnoremap <leader>fafe zMzvzz

" find selection [http://vim.wikia.com/wiki/Search_for_visually_selected_text]
vnoremap // y/<C-R>"<CR>

" Clean search (highlight)
nnoremap <leader>. :noh<Return>

" Replace in visual mode [http://stackoverflow.com/a/676619]
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>"

" Toggle colorscheme dark/light mode
" nnoremap <leader><ESC> :call ToggleLightDarkTheme()<CR>

" THINGS I RARELY USE - OR FORGOT HOW TO"

" Print the current timestamp in cursor position"
nnoremap <leader><F5> "=strftime("%c")<Return>P

" Format file
" map <F7> mzgg=G`z

" I think I used this when I didn't know how to share the system's
" clipboard with vim's
" noremap YY "+y<CR>
" noremap <leader>p "+gP<CR>
" noremap XX "+x<CR>
