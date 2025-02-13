#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Help message
show_help() {
    cat << EOF
Usage: ${0##*/} [options]

Options:
    -h, --help      Show this help message
    --all           Full installation (default if no options provided)
    --links         Only create symlinks for dotfiles
    --brew          Only update Homebrew and install packages
    --ssh           Only setup SSH
    --force         Force reinstallation even if already installed
    --no-upgrade    Don't upgrade existing packages

By default (no options), the script runs in interactive mode.
EOF
}

# Parse arguments
INTERACTIVE=true
DO_LINKS=false
DO_BREW=false
DO_SSH=false
FORCE=false
NO_UPGRADE=false

for arg in "$@"; do
    case $arg in
        --all)
            DO_LINKS=true
            DO_BREW=true
            DO_SSH=true
            INTERACTIVE=false
            ;;
        --links)
            DO_LINKS=true
            INTERACTIVE=false
            ;;
        --brew)
            DO_BREW=true
            INTERACTIVE=false
            ;;
        --ssh)
            DO_SSH=true
            INTERACTIVE=false
            ;;
        --force)
            FORCE=true
            ;;
        --no-upgrade)
            NO_UPGRADE=true
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
    esac
done

# If no specific options provided, ask user interactively
if [ "$INTERACTIVE" = true ]; then
    echo -e "${BLUE}Welcome to the dotfiles installer${NC}"

    read -p "Create/update symlinks for configuration files? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && DO_LINKS=true

    read -p "Setup/update Homebrew and packages? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && DO_BREW=true

    read -p "Setup/update SSH configuration? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && DO_SSH=true

    if [ "$DO_BREW" = true ]; then
        read -p "Upgrade existing packages? (y/N) " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && NO_UPGRADE=true
    fi
fi

# Create backup directory only if needed
if [ "$DO_LINKS" = true ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Function to backup and symlink files
link_file() {
    local src="$1"
    local dst="$2"

    # Create backup if file exists
    if [ -f "$dst" ] || [ -d "$dst" ]; then
        echo "Backing up $dst to $BACKUP_DIR/"
        mv "$dst" "$BACKUP_DIR/"
    fi

    # Create symlink
    echo "Creating symlink: $dst -> $src"
    ln -sf "$src" "$dst"
}

# Function to create symlinks
setup_symlinks() {
    echo -e "${BLUE}Setting up configuration files...${NC}"

    # ZSH Setup
    echo "Setting up ZSH..."
    link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

    # Git Setup
    echo "Setting up Git..."
    link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

    # Vim Setup
    echo "Setting up Vim..."
    link_file "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"

    # VSCode Setup (platform specific)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Setting up VSCode for macOS..."
        VSCODE_DIR="$HOME/Library/Application Support/Code/User"
        mkdir -p "$VSCODE_DIR"
        link_file "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_DIR/settings.json"
        link_file "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_DIR/keybindings.json"
    fi

    echo -e "${GREEN}Configuration files setup completed${NC}"
}

# Homebrew Setup
setup_homebrew() {
    if [ ! -f "$DOTFILES_DIR/brew/Brewfile" ]; then
        echo "Brewfile not found at $DOTFILES_DIR/brew/Brewfile"
        return 1
    fi

    echo "Setting up Homebrew..."

    # Check if Homebrew needs to be installed
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            echo "Failed to install Homebrew"
            return 1
        }
    fi

    # Set up Homebrew PATH based on architecture
    if [[ "$(uname -m)" == "arm64" ]]; then
        # Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)" || {
            echo "Failed to set up Homebrew PATH for Apple Silicon"
            return 1
        }
        # Add to profile if not already present
        if ! grep -q "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" "$HOME/.zprofile"; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        fi
    else
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)" || {
            echo "Failed to set up Homebrew PATH for Intel Mac"
            return 1
        }
        # Add to profile if not already present
        if ! grep -q "eval \"\$(/usr/local/bin/brew shellenv)\"" "$HOME/.zprofile"; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
        fi
    fi

    # Update Homebrew
    echo "Updating Homebrew..."
    brew update || {
        echo "Failed to update Homebrew"
        return 1
    }

    # Install dependencies
    echo "Installing Homebrew packages..."
    if [ "$NO_UPGRADE" = true ]; then
        brew bundle --file="$DOTFILES_DIR/brew/Brewfile" --no-upgrade || {
            echo -e "${RED}Failed to install some Homebrew packages${NC}"
            echo "Please check the output above for details"
            return 1
        }
    else
        brew bundle --file="$DOTFILES_DIR/brew/Brewfile" || {
            echo -e "${RED}Failed to install some Homebrew packages${NC}"
            echo "Please check the output above for details"
            return 1
        }
    fi

    # Set up QuickLook plugins (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Setting up QuickLook plugins..."
        qlmanage -r &> /dev/null || {
            echo "Warning: Failed to reset QuickLook plugins"
        }
    fi

    echo "Homebrew setup completed successfully"
    return 0
}

# Main installation
if [ "$DO_BREW" = true ]; then
    setup_homebrew || {
        echo -e "${RED}Homebrew setup failed${NC}"
        exit 1
    }
fi

if [ "$DO_LINKS" = true ]; then
    setup_symlinks
fi

if [ "$DO_SSH" = true ]; then
    echo -e "${BLUE}Setting up SSH configuration...${NC}"
    chmod +x "$DOTFILES_DIR/ssh/setup-ssh.sh"
    "$DOTFILES_DIR/ssh/setup-ssh.sh" config
fi

# Print completion message
echo -e "${GREEN}Installation complete!${NC}"
if [ "$DO_LINKS" = true ] || [ "$DO_BREW" = true ]; then
    echo -e "${YELLOW}Note: Please restart your terminal to ensure all changes take effect.${NC}"
fi
