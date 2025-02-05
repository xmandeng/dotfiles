# Dotfiles

This repository contains my personal dotfiles for both Linux and macOS environments. The configuration files are organized by operating system and are managed using GNU Stow for easy deployment.

## Overview

The repository is structured into two main directories:
- `linux/` - Configuration files for Linux systems
- `macos/` - Configuration files for macOS systems

### Key Features

- Shell configurations (Bash for Linux, Zsh for macOS)
- Terminal multiplexer setup (tmux)
- PostgreSQL configuration files
- Starship prompt customization
- Git aliases and configurations
- AWS CLI configuration
- VSCode settings
- Alacritty terminal configuration (macOS)

## Prerequisites

Before installing these dotfiles, ensure you have the following installed:

- GNU Stow
- Git
- tmux
- Starship (for custom shell prompt)
- Required fonts:
  - FiraCode Nerd Font (for proper icon rendering)

### Installing Prerequisites

#### Linux (Debian/Ubuntu)
```bash
sudo apt update
sudo apt install -y stow git tmux
```

#### macOS
```bash
brew install stow git tmux
```

### Installing Starship
```bash
curl -sS https://starship.rs/install.sh | sh
```

## Installation

1. Clone this repository to your home directory:
```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Use Stow to symlink the configurations:

For Linux:
```bash
cd ~/.dotfiles
stow -t ~ linux
```

For macOS:
```bash
cd ~/.dotfiles
stow -t ~ macos
```

### Optional: Installing tmux Plugin Manager (tpm)
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
After installation, open tmux and press `prefix + I` to install plugins.

## Post-Installation

### For macOS Users

1. Install Homebrew packages:
```bash
brew install zsh-autosuggestions zsh-syntax-highlighting fzf ripgrep zoxide
```

2. Install FiraCode Nerd Font:
```bash
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font
```

### For Linux Users

1. Set up PostgreSQL configuration:
```bash
chmod 600 ~/.pgpass
chmod 600 ~/.pg_service.conf
```

## Additional Configuration

### VSCode Setup
- Copy the settings from `.settings/` to your VSCode settings
- Install recommended extensions (list provided in vscode_dark_modern.json)

### AWS Configuration
- Update `.aws/config` with your AWS credentials and regions

## Updating

To update your dotfiles:

1. Pull the latest changes:
```bash
cd ~/.dotfiles
git pull
```

2. Restow the configurations:
```bash
stow -R -t ~ linux  # For Linux
# OR
stow -R -t ~ macos  # For macOS
```

## Uninstalling

To remove the symlinks:
```bash
cd ~/.dotfiles
stow -D linux  # For Linux
# OR
stow -D macos  # For macOS
```

## Contributing

Feel free to fork this repository and customize it for your own use. If you have any improvements or suggestions, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.