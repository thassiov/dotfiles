lua << END
local lsp_status = require('lsp-status')
lsp_status.register_progress()
END

" Statusline
function! LspStatus() abort
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    " return luaeval("require('lsp-status').status()")
    return "⚙️"
  endif

  return ''
endfunction

" vim-airline
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

"" vim-airline
let g:airline_theme = "jay"
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline_powerline_fonts = 1

if !exists('g:airline_powerline_fonts')
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline_left_sep          = '|'
  let g:airline_left_alt_sep      = '»'
  let g:airline_right_sep         = '|'
  let g:airline_right_alt_sep     = '«'
  let g:airline#extensions#branch#prefix     = '⤴' "➔, ➥, ⎇
  let g:airline#extensions#readonly#symbol   = '⊘'
  let g:airline#extensions#linecolumn#prefix = '¶'
  let g:airline#extensions#paste#symbol      = 'ρ'
  let g:airline_symbols.linenr    = '␊'
  let g:airline_symbols.branch    = '⎇'
  let g:airline_symbols.paste     = 'ρ'
  let g:airline_symbols.paste     = 'Þ'
  let g:airline_symbols.paste     = '∥'
  let g:airline_symbols.whitespace = 'Ξ'
else
  let g:airline#extensions#tabline#left_sep =""
  let g:airline#extensions#tabline#left_alt_sep =""

  " powerline symbols
  let g:airline_left_sep =""
  let g:airline_right_sep =""
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''
endif

let g:airline_symbols.dirty=""

function! AccentDemo()
  " Due to some potential rendering issues, the use of the `space` variable is
  " recommended.
  let s:spc = g:airline_symbols.space
  let g:airline_section_c .= '%{LspStatus()}'
endfunction
autocmd VimEnter * call AccentDemo()
