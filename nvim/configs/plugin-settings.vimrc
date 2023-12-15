" Plugin - Editor Config
" Added to work with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
" speeds up the startup time (see
" https://github.com/editorconfig/editorconfig-vim/issues/50#issuecomment-161892271
" )
" let g:EditorConfig_core_mode = 'external_command'

" NERDCommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" test-vim
let test#strategy = "floaterm"
