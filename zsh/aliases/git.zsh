# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias gl='git pull'
alias gp='git push'
alias gst='git status'
alias glo='git log --oneline --decorate'
alias grb='git rebase'
alias gsb='git status -sb'
alias grs='git restore'
alias grst='git restore --staged'

# Git functions
function gcb() {
    git checkout -b "$1"
}

function gbd() {
    git branch -D "$1"
}

function gclean() {
    git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d
}