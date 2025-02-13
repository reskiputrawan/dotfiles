#!/bin/bash

set -e  # Exit on error

SSH_DIR="$HOME/.ssh"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="$DOTFILES_DIR/ssh/backup"
KEY_NAME="id_ed25519"  # Using modern Ed25519 keys
GPG_RECIPIENT="$USER@$(hostname -s)"  # Use short hostname

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check required commands and GPG setup
check_requirements() {
    local cmds=("ssh-keygen" "gpg" "tar")
    for cmd in "${cmds[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${RED}Error: $cmd is not installed${NC}"
            exit 1
        fi
    done

    # Check for GPG key when backing up
    if [ "$1" = "backup" ]; then
        if ! gpg --list-secret-keys "$GPG_RECIPIENT" >/dev/null 2>&1; then
            echo -e "${RED}No GPG key found for $GPG_RECIPIENT${NC}"
            echo -e "Please create a GPG key first:"
            echo -e "  gpg --full-generate-key"
            echo -e "Then try backup again"
            exit 1
        fi
    fi
}

# Create necessary directories
create_directories() {
    echo -e "${BLUE}Creating necessary directories...${NC}"
    mkdir -p "$SSH_DIR"
    mkdir -p "$BACKUP_DIR"
    chmod 700 "$SSH_DIR"
    chmod 700 "$BACKUP_DIR"

    # Validate directory permissions
    if [ "$(stat -f %Lp "$SSH_DIR")" != "700" ] || [ "$(stat -f %Lp "$BACKUP_DIR")" != "700" ]; then
        echo -e "${RED}Failed to set correct directory permissions${NC}"
        return 1
    fi
}

# Generate new SSH key
generate_keys() {
    if [ ! -f "$SSH_DIR/$KEY_NAME" ]; then
        echo -e "${BLUE}Generating new SSH key pair...${NC}"
        ssh-keygen -t ed25519 -f "$SSH_DIR/$KEY_NAME" -C "$USER@$(hostname)"
        chmod 600 "$SSH_DIR/$KEY_NAME"
        chmod 644 "$SSH_DIR/$KEY_NAME.pub"
        echo -e "${GREEN}SSH key pair generated successfully${NC}"
    else
        echo -e "${BLUE}SSH key pair already exists${NC}"
    fi
}

# Backup SSH keys
backup_keys() {
    if [ ! -f "$SSH_DIR/$KEY_NAME" ]; then
        echo -e "${RED}No SSH keys found to backup${NC}"
        return 1
    fi

    echo -e "${BLUE}Backing up SSH keys...${NC}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/ssh_keys_$timestamp.tar.gz.gpg"

    # Create temporary directory for tarball
    local temp_dir=$(mktemp -d)
    cp "$SSH_DIR/$KEY_NAME"* "$temp_dir/"

    # Create encrypted backup
    if ! tar -czf - -C "$temp_dir" . | gpg --encrypt --recipient "$GPG_RECIPIENT" > "$backup_file"; then
        echo -e "${RED}Failed to create encrypted backup${NC}"
        rm -rf "$temp_dir"
        return 1
    fi

    # Cleanup
    rm -rf "$temp_dir"

    echo -e "${GREEN}Backup created at: $backup_file${NC}"
}

# Restore SSH keys
restore_keys() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Backup directory $BACKUP_DIR does not exist${NC}"
        return 1
    fi

    local backup_file="$1"
    if [ -z "$backup_file" ]; then
        # Get latest backup if none specified
        backup_file=$(ls -t "$BACKUP_DIR"/*.tar.gz.gpg 2>/dev/null | head -n1)
    fi

    if [ -z "$backup_file" ] || [ ! -f "$backup_file" ]; then
        echo -e "${RED}No backup file found${NC}"
        return 1
    fi

    echo -e "${BLUE}Restoring SSH keys from backup...${NC}"

    # Create temporary directory for restoration
    local temp_dir=$(mktemp -d)

    # Decrypt and extract backup
    if ! gpg --decrypt "$backup_file" | tar -xzf - -C "$temp_dir"; then
        echo -e "${RED}Failed to decrypt or extract backup${NC}"
        rm -rf "$temp_dir"
        return 1
    fi

    # Validate restored files
    if [ ! -f "$temp_dir/$KEY_NAME" ] || [ ! -f "$temp_dir/$KEY_NAME.pub" ]; then
        echo -e "${RED}Backup appears to be incomplete${NC}"
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy keys to SSH directory
    cp "$temp_dir"/* "$SSH_DIR/"

    # Set correct permissions
    chmod 600 "$SSH_DIR/$KEY_NAME"
    chmod 644 "$SSH_DIR/$KEY_NAME.pub"

    # Cleanup
    rm -rf "$temp_dir"

    echo -e "${GREEN}SSH keys restored successfully${NC}"
}

# Setup SSH config
setup_config() {
    echo -e "${BLUE}Setting up SSH config...${NC}"

    # Backup existing config if it exists
    if [ -f "$SSH_DIR/config" ]; then
        mv "$SSH_DIR/config" "$SSH_DIR/config.bak"
        echo "Existing SSH config backed up to: $SSH_DIR/config.bak"
    fi

    # Create symlink to our config
    if [ ! -f "$DOTFILES_DIR/ssh/.ssh_config" ]; then
        echo -e "${RED}SSH config not found at $DOTFILES_DIR/ssh/.ssh_config${NC}"
        return 1
    fi
    ln -sf "$DOTFILES_DIR/ssh/.ssh_config" "$SSH_DIR/config"
    chmod 600 "$SSH_DIR/config"

    echo -e "${GREEN}SSH config setup complete${NC}"
}

# Main setup function
main() {
    echo -e "${BLUE}Starting SSH setup...${NC}"

    check_requirements
    create_directories || exit 1

    # Check for existing backup to restore
    if [ "$1" = "--restore" ]; then
        restore_keys "$2"
    else
        generate_keys
        backup_keys
    fi

    setup_config

    echo -e "${GREEN}SSH setup completed successfully!${NC}"
    echo -e "${BLUE}Your public key:${NC}"
    cat "$SSH_DIR/$KEY_NAME.pub"
}

# Verify GPG is installed
if ! command -v gpg >/dev/null 2>&1; then
    echo -e "${RED}GPG is not installed. Please install GPG first.${NC}"
    exit 1
fi

# Parse command line arguments
case "$1" in
    backup)
        check_requirements "backup"
        backup_keys || exit 1
        ;;
    restore)
        check_requirements
        restore_keys "$2" || exit 1
        ;;
    generate)
        check_requirements
        generate_keys || exit 1
        ;;
    config)
        check_requirements
        setup_config || exit 1
        ;;
    *)
        main "$@"
        ;;
esac
