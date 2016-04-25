# Software list:
# - rofi
# - git
# - vim
# - byobu
# - terminator
# - git-bash-prompt


#terminal
export PS1="(\[\e[01;31m\]\t\[\e[0m\])\[\e[01;32m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[01;31m\]\h\[\e[0m\]:\[\e[01;31m\]\w\[\e[0m\]\[\e[01;37m\]\$\[\e[0m\]\[\e[00;37m\] \[\e[0m\]"

#ls aliases
alias ls='ls --color'
alias l='ls --color'
alias ll='ls -l --color'
alias lla='ls -la --color'
alias ltr='ls -ltr --color'

#huehue
alias huebr='sudo'

#anoying thing
alias pacman='yaourt'

alias ..='cd ..'
alias ...='cd ../..'
alias dev='cd ~/dev'

# gitprompt configuration

# Set config variables first
GIT_PROMPT_ONLY_IN_REPO=1

# GIT_PROMPT_FETCH_REMOTE_STATUS=0   # uncomment to avoid fetching remote status

# GIT_PROMPT_SHOW_UPSTREAM=1 # uncomment to show upstream tracking branch
# GIT_PROMPT_SHOW_UNTRACKED_FILES=all # can be no, normal or all; determines counting of untracked files

# GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh # uncomment to support Git older than 1.7.10

# GIT_PROMPT_START=...    # uncomment for custom prompt start sequence
# GIT_PROMPT_END=...      # uncomment for custom prompt end sequence

# as last entry source the gitprompt script
# GIT_PROMPT_THEME=Custom # use custom .git-prompt-colors.sh
# GIT_PROMPT_THEME=Solarized # use theme optimized for solarized color scheme
source ~/.bash-git-prompt/gitprompt.sh

#path
PATH=$PATH:~/.composer/vendor/bin

#bin directory
PATH=$PATH:~/bin

export GOPATH=~/.go
export PATH=$PATH:~/.go/bin

