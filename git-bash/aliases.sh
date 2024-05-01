# NOTE: LSD-RS
# https://github.com/lsd-rs/lsd
alias ls='lsd'
alias l='ls -l'
alias ll='ls -la'
alias lt='ls --tree'

# NOTE: CD
alias .='cd .'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

# NOTE: HELPERS
alias bashclear='echo "" > ~/.bash_history'
alias cls='clear'
alias rm='rm -iv'
alias v='nvim'
alias vim='nvim'
alias clearshada='find /c/users/stefa/appdata/local/nvim-data/shada -type f -printf "%T+ %p\n" | sort -r | tail +20 | awk "{print \$2}" | xargs -r rm && echo "ShaDa files were cleared"'

# NOTE: CDs
alias cdvim='cd /x/CLI/terminal-config/nvim'
