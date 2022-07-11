#!/bin/bash

file=$(fzf --preview 'bat --style=numbers --color=always {}')

if [[ ! -z "$file" ]]; then
  nvim $file
fi
