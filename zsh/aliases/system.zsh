# Navigation
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias docs="cd ~/Documents"
alias proj="cd ~/Projects"

# List operations
alias ls='ls -G'  # Colorize output
alias ll='ls -lh' # List with human-readable sizes
alias la='ls -lha' # List all files including hidden
alias lt='ls -lhtr' # List by time, most recent last
alias lsize='ls -lSrh' # List by size

# System operations
alias df='df -h' # Disk free with human-readable sizes
alias du='du -h' # Disk usage with human-readable sizes
alias free='top -l 1 | grep PhysMem' # Memory usage
alias top='top -o cpu' # Sort top by CPU usage
alias ps?='ps aux | grep' # Search processes

# Network
alias ip="ifconfig | grep 'inet ' | grep -v 127.0.0.1 | cut -d\\  -f2"
alias localip="ipconfig getifaddr en0"
alias pubip="curl -s https://api.ipify.org"
alias ports='netstat -tulanp'
alias listen='lsof -i -P | grep LISTEN'

# Quick edit common config files
alias zshrc="$EDITOR ~/.zshrc"
alias zshalias="$EDITOR ~/.dotfiles/zsh/aliases"
alias gitconfig="$EDITOR ~/.gitconfig"
alias vimrc="$EDITOR ~/.vimrc"

# System maintenance
alias flush_dns='sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder'
alias trim='sudo trimforce enable' # Enable TRIM for SSDs
alias update='softwareupdate -i -a' # Update macOS
alias cleanup='sudo periodic daily weekly monthly' # Run system maintenance scripts

# Directory operations
alias mkdir='mkdir -p' # Create parent directories if needed
alias rmrf='rm -rf'
alias cp='cp -iv' # Interactive and verbose
alias mv='mv -iv' # Interactive and verbose

# Quick functions
function size() {
    du -sh "$@" 2>/dev/null
}

function mkcd() {
    mkdir -p "$1" && cd "$1"
}

function server() {
    local port="${1:-8000}"
    python -m SimpleHTTPServer "$port"
}

function killport() {
    lsof -i tcp:"$1" | awk 'NR!=1 {print $2}' | xargs kill
}

function compress() {
    tar -czf "$1.tar.gz" "$1"
}

function extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar)     tar xf "$1"  ;;
            *.tgz)     tar xzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1"  ;;
            *.zip)     unzip "$1"   ;;
            *.Z)       uncompress "$1" ;;
            *)         echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# System info
function sysinfo() {
    echo "OS: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "Shell: $SHELL"
    echo "Terminal: $TERM"
    echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
    echo "Memory: $(top -l 1 | grep PhysMem)"
    echo "Disk Space: $(df -h /)"
}

# Weather in terminal
function weather() {
    local city="${1:-}"
    if [ -z "$city" ]; then
        curl "wttr.in"
    else
        curl "wttr.in/$city"
    fi
}