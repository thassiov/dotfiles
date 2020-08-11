" IMPORTANT: all those "<Return>|" things are because of this [https://stackoverflow.com/a/24717020/931704]
" I wanted to show the commends when doing, for instance, `:map <leader>`, but it didn't work.
" I'll keep it this way for now because it is easier to read the comments like this

"" Map leader to ,
let mapleader=','

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

nnoremap <leader>w :write<Return>|                                              " Save file
nnoremap <leader>o :%bd\|e#<Return>|                                            " close all other buffers (different from :only)
                                                                                " [https://stackoverflow.com/a/42071865/931704] - the snippet
                                                                                " [https://vi.stackexchange.com/a/2288] - about the bar/pipe character

" Leader - plugin access

"" Git - vim-fugitive
nnoremap <Leader>gs :Gstatus<Return>|                                           " Git status
nnoremap <Leader>gb :Gblame<Return>|                                            " Git blame
nnoremap <Leader>vd :Gvdiff<Return>|                                            " Git diff

" Vista.vim
nnoremap <leader>1 :Vista!!<Return>|                                            " Open bar with current file's symbols"

" Clap.vim
nnoremap <leader>! :Clap tags<Return>|                                          " Open list current file's symbols"
nnoremap <leader>2 :Clap buffers<Return>|                                       " Open list of buffers"
nnoremap <leader>3 :Clap gfiles<Return>|                                        " Open list of files managed by git"
nnoremap <leader># :Clap files<Return>|                                         " Open list of files in the project"

" fzf.vim
" This is the default extra key bindings. They work inside fzf's pane
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

nnoremap <leader>4 :Ag!<Return>|                                                " Find text in project (the_silver_searcher)
nnoremap <leader>tl :Ag! @TODO\|@NOTE\|@FIXME<Return>|                          " Find special tokens (this can be useful)"

" COC mappings

" Managing CoC extension
nnoremap <leader>cex  :<C-u>CocList extensions<cr>                              " Manage extensions
nnoremap <leader>cmkt  :<C-u>CocList marketplace<cr>                            " Open marketplace list (depends on coc.marketplace being present)
nnoremap <leader>cc  :<C-u>CocList commands<cr>                                 " Show commands

" Code
nnoremap <leader>cd  :<C-u>CocList diagnostics<cr>                              " Show all diagnostics
nnoremap <leader>ff  <Plug>(coc-fix-current)                                    " Fix autofix problem of current line

" Go to definition (in a new tab [https://github.com/neoclide/coc.nvim/issues/1249])
" Maybe use this mappings
nnoremap <leader>gd :call CocAction('jumpDefinition', 'tabe')<Return>|          " Go to definition
nnoremap <leader>gr :call CocAction('jumpReferences')<Return>|                  " Go to references
nnoremap <leader>gy :call CocAction('jumpTypeDefinition')<Return>|              " Go to type definition

nnoremap <leader><Tab> :CocCommand explorer<Return>|                            " Open file explorer

"" Markdown focus mode - Goyo"
nnoremap <leader>5 :Goyo<Return>|
nnoremap <leader>% :Goyo 120<Return>|

"" Cool floating terminal - Floaterm"
nnoremap <leader>t :FloatermToggle<Return>|

"" A hack to wrap the current file into 78 char lines"
nnoremap <leader>T :set textwidth=78<Return>ggVGgq

"" BUFFER AND TAB NAVIGATION - Ctrl and Tab"

"" Navigate between tabs using Tab
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<Return>|

"" Switching windows
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

"" Close buffer
nnoremap <C-c> :bd<Return>|
"" Next buffer"
nnoremap <C-p> :bnext<Return>|
"" Previous buffer"
nnoremap <C-o> :bprevious<Return>|

"" MISC"

" Reaload my vim config (assuming it is in the correct directory)
nnoremap <leader>0 :so ~/.config/nvim/init.vim<Return>|

"" Print the current timestamp in cursor position"
nnoremap <leader><F5> "=strftime("%c")<Return>P

" Folds all blocks except current [https://stackoverflow.com/a/8735199/931704]
" 'cafe' stands for 'Close All Folds Except'
nnoremap <leader>fafe zMzvzz

" find selection [http://vim.wikia.com/wiki/Search_for_visually_selected_text]
vnoremap // y/<C-R>"<Return>|

"" Clean search (highlight)
" nnoremap <leader>/ :noh<cr>

" Replace in visual mode [http://stackoverflow.com/a/676619]
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>"

"" THINGS I RARELY USE - OF FORGOT HOW TO"

" Format file
" map <F7> mzgg=G`z

"" I think I used this when I didn't know how to share the system's
" clipboard with vim's
" noremap YY "+y<Return>|
" noremap <leader>p "+gP<Return>|
" noremap XX "+x<Return>|
