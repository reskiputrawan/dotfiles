# Dotfiles

This repository contains my personal dotfiles organized in a modular structure.

## Structure

```
.
├── zsh/           # ZSH shell configuration
│   ├── .zshrc    # Main ZSH config
│   └── aliases/   # Custom aliases
├── git/          # Git configuration
│   └── .gitconfig
├── vim/          # Vim configuration
│   └── .vimrc
├── vscode/       # VS Code settings
│   ├── settings.json
│   └── extensions.json
├── ssh/          # SSH management
│   ├── .ssh_config    # SSH configuration template
│   ├── setup-ssh.sh   # Key management script
│   └── backup/        # Encrypted key backups
├── brew/         # Homebrew packages
│   └── Brewfile
├── scripts/      # Utility scripts
│   └── install.sh
└── README.md
```

## Installation

1. Clone this repository:

```bash
git clone https://github.com/reskiputrawan/dotfiles.git ~/.dotfiles
```

2. Run the installation script:

```bash
cd ~/.dotfiles
./scripts/install.sh
```

The install script will create symbolic links from your home directory to these dotfiles.

## Modules

### ZSH

- Main shell configuration
- Custom aliases for common commands
- Theme and prompt customization

### Git

- Git configuration and aliases
- Global gitignore settings

### Vim

- Vim configuration with essential plugins
- Custom key mappings

### VS Code

- Editor settings
- Extensions list
- Keybindings

### Homebrew

- List of packages to install via Homebrew

### SSH

- Secure SSH key management across machines
- Automated key backup and restoration
- Encrypted key storage
- Secure configuration defaults
- Easy cross-machine synchronization

### Scripts

- Installation and setup scripts
- Utility functions

## Customization

Each module can be customized independently. Check the README in each directory for module-specific documentation.
