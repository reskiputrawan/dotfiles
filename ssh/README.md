# SSH Configuration

This module manages SSH keys and configuration across multiple machines.

## Features

- Automated SSH key generation
- Encrypted key backup and restoration
- Secure configuration defaults
- Easy cross-machine key synchronization

## Usage

The `setup-ssh.sh` script provides several commands:

```bash
# Full setup (generates keys if none exist, creates backup)
./setup-ssh.sh

# Restore keys from latest backup
./setup-ssh.sh --restore

# Restore keys from specific backup
./setup-ssh.sh --restore /path/to/backup.tar.gz.gpg

# Manual commands
./setup-ssh.sh backup    # Create new encrypted backup
./setup-ssh.sh restore   # Restore from latest backup
./setup-ssh.sh generate  # Generate new key pair
./setup-ssh.sh config    # Update SSH config only
```

## Cross-Machine Setup

### Initial Setup (Primary Machine)

1. Install GPG and create your key:

   ```bash
   # Create a new GPG key
   gpg --full-generate-key

   # Note your key ID/email for future use
   gpg --list-secret-keys
   ```

2. Set up dotfiles and SSH:

   ```bash
   # Install packages and configs
   scripts/install.sh --all

   # Generate and backup SSH keys
   ssh/setup-ssh.sh generate
   ssh/setup-ssh.sh backup
   ```

### New Machine Setup

1. Export GPG key from primary machine:

   ```bash
   # On primary machine
   gpg --export-secret-keys YOUR_EMAIL > gpg-secret.key
   ```

2. Import GPG key on new machine:

   ```bash
   # Copy gpg-secret.key to new machine and import
   gpg --import gpg-secret.key
   ```

3. Set up dotfiles:

   ```bash
   # Install packages and configs
   scripts/install.sh --all

   # Restore SSH keys
   ssh/setup-ssh.sh restore
   ```

## Security Notes

- Keys are encrypted using GPG before backup
- Backups use modern Ed25519 keys
- All files maintain secure permissions
- SSH config uses secure defaults

## Configuration

The SSH config template (`~/.dotfiles/ssh/.ssh_config`) can be customized with:

- Host-specific settings
- Key file locations
- Connection preferences
- Security options
