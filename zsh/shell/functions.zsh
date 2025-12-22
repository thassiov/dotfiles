# Custom shell functions

# ls wrapper - use exa if available
function ls () {
    if exa &> /dev/null
    then
        exa "$@" --color always
    else
        command ls "$@"
    fi
}

# Find in files - fuzzy search file contents
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}
