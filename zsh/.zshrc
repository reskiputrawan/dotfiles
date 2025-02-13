# Path to dotfiles
export DOTFILES="$HOME/.dotfiles"

# Setup Homebrew for the correct architecture
if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_EXPIRE_DUPS_FIRST # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS       # Ignore duplicated commands in history
setopt HIST_IGNORE_SPACE      # Ignore commands that start with space
setopt HIST_VERIFY           # Show command with history expansion before running it

# Basic auto/tab completion
autoload -U compinit
compinit

# Auto cd when entering just a path
setopt AUTO_CD

# Use colors in prompt
autoload -U colors && colors

# Custom prompt
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Load all alias files
for alias_file in $DOTFILES/zsh/aliases/*.zsh; do
    [ -r "$alias_file" ] && source "$alias_file"
done

# Useful aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Environment variables
export EDITOR='vim'
export VISUAL='vim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Node Version Manager (nvm) setup - if installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Command syntax highlighting
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Command auto-suggestions
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Custom functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
