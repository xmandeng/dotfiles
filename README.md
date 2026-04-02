# Dotfiles

Personal dotfiles for **Linux** (Bash) and **macOS** (Zsh), managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's Included

| Component | macOS | Linux | Notes |
|---|---|---|---|
| Shell config | `.zshrc`, `.zprofile`, `.zsh_aliases` | `.bashrc`, `.bash_aliases` | Zsh on macOS, Bash on Linux |
| Starship prompt | `.config/starship.toml` | `.config/starship.toml` | Custom powerline-style prompt with git metrics |
| tmux | `.tmux.conf` | `.tmux.conf` | Catppuccin Mocha theme, TPM plugins, `Ctrl+A` prefix |
| Git | `.gitconfig` | `.gitconfig` | Delta side-by-side diffs, LFS support |
| Alacritty | `.config/alacritty/alacritty.toml` | -- | Terminal with FiraCode Nerd Font |
| VSCode | `vscode/macos/` | `vscode/linux/` | Reference files (not stowed -- copy manually) |
| AWS CLI | -- | `.aws/config` | SSO profile template |
| PostgreSQL | -- | `.pgpass`, `.pg_service.conf` | Connection credentials (auto-secured to 600) |
| macOS key bindings | `DefaultKeyBinding.dict` | -- | Fix Home/End and Ctrl+Arrow keys (manual copy) |

## Dependencies

### Required (both platforms)

| Tool | Purpose |
|---|---|
| [Git](https://git-scm.com/) | Version control |
| [GNU Stow](https://www.gnu.org/software/stow/) | Symlink manager for dotfiles |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| [Starship](https://starship.rs/) | Cross-shell prompt |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (used in aliases and shell history) |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast search (fzf file source via `rg`) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` command |
| [delta](https://github.com/dandavidsern/delta) | Git diff viewer (used by `.gitconfig`) |
| [FiraCode Nerd Font](https://www.nerdfonts.com/) | Icons in Starship prompt and Alacritty |

### macOS only

| Tool | Purpose |
|---|---|
| [Homebrew](https://brew.sh/) | Package manager (everything below is installed via `brew`) |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like autosuggestions for Zsh |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Syntax highlighting for Zsh |
| [Alacritty](https://alacritty.org/) | GPU-accelerated terminal emulator |
| [pyenv](https://github.com/pyenv/pyenv) + [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv) | Python version management |
| [GNU grep](https://www.gnu.org/software/grep/) | Replaces BSD grep for PCRE support |

<details>
<summary>Full <code>brew leaves</code> list</summary>

btop, diff-so-fancy, entr, fzf, git, gprof2dot, grep, neovim, nmap, parallel,
pyenv-virtualenv, ripgrep, sha3sum, starship, stow, tmux, tree, watch, yq,
zoxide, zsh-autosuggestions, zsh-syntax-highlighting
</details>

### Linux only

| Tool | Purpose |
|---|---|
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted file preview (used in `open` alias) |
| [Rust/Cargo](https://rustup.rs/) | Some CLI tools installed via Cargo |

## Installation

### 1. Install dependencies

#### macOS

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Core tools
brew install git stow tmux starship fzf ripgrep zoxide delta

# Shell plugins
brew install zsh-autosuggestions zsh-syntax-highlighting

# Optional but recommended
brew install pyenv pyenv-virtualenv grep alacritty
brew install btop entr neovim tree watch yq

# Font
brew install --cask font-fira-code-nerd-font
```

#### Linux (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install -y git stow tmux fzf bat

# Install Starship
curl -sS https://starship.rs/install.sh | sh

# Install ripgrep, zoxide, delta (via package manager or cargo)
sudo apt install -y ripgrep
cargo install zoxide --locked
cargo install git-delta --locked

# Install FiraCode Nerd Font
# Download from https://www.nerdfonts.com/font-downloads and place in ~/.local/share/fonts/
```

### 2. Clone the repo

```bash
git clone https://github.com/xaviermandeng/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 3. Stow the configs

```bash
# macOS
stow -t ~ macos

# Linux
stow -t ~ linux
```

### 4. Set up tmux plugins

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then open tmux and press `Ctrl+A` then `I` (capital) to install all plugins.

### 5. Reload your shell

```bash
# macOS
source ~/.zshrc

# Linux
source ~/.bashrc
```

### 6. Manual steps (macOS)

Copy the macOS key bindings file to fix Home/End keys system-wide:

```bash
mkdir -p ~/Library/KeyBindings
cp ~/.dotfiles/macos/DefaultKeyBinding.dict ~/Library/KeyBindings/
```

### 7. VSCode settings (optional)

VSCode files are stored in `vscode/` as reference -- copy them to your VSCode config directory as needed:

```bash
# macOS
cp ~/.dotfiles/vscode/macos/settings.json ~/Library/Application\ Support/Code/User/
cp ~/.dotfiles/vscode/macos/keybindings.json ~/Library/Application\ Support/Code/User/

# Linux (or use the Remote SSH path if applicable)
cp ~/.dotfiles/vscode/linux/keybindings.json ~/.config/Code/User/
```

## tmux Key Bindings

The prefix key is remapped to `Ctrl+A` (instead of the default `Ctrl+B`).

| Binding | Action |
|---|---|
| `Prefix + \|` | Vertical split |
| `Prefix + -` | Horizontal split |
| `Prefix + r` | Reload tmux config |
| `Prefix + I` | Install plugins (TPM) |
| `Prefix + Tab` | Toggle file sidebar |
| `Prefix + Ctrl+s` | Save session (resurrect) |
| `Prefix + Ctrl+r` | Restore session (resurrect) |
| `Prefix + Shift+Left/Right` | Move window left/right |
| `Ctrl+P / Ctrl+N` | Previous / next command |
| `Ctrl+Left/Right` | Jump word |
| `Alt+Left/Right` | Jump to start/end of line |

### tmux Plugins

- **catppuccin/tmux** -- Mocha theme with rounded tabs
- **tmux-sensible** -- Sensible defaults
- **tmux-better-mouse-mode** -- Improved mouse support
- **tmux-sidebar** -- File tree sidebar
- **tmux-resurrect** -- Save/restore sessions across restarts
- **tmux-continuum** -- Auto-save sessions

## Shell Aliases (quick reference)

### Git

| Alias | Command |
|---|---|
| `ga` | `git add . -A` |
| `gs` | `git status` |
| `gc` | `git commit -m` |
| `gp` / `gpush` | `git push` |
| `gco` | Interactive branch checkout via fzf |
| `gl` | `git log --oneline --graph --all --decorate` |
| `gstat` | `git diff --stat` |

### tmux

| Alias | Command |
|---|---|
| `t` | `tmux` |
| `ta` | `tmux a -t` (attach to session) |
| `tls` | `tmux ls` |
| `tn` | `tmux new -t` |
| `tkill` | `tmux kill-server` |

## Updating

```bash
cd ~/.dotfiles
git pull
stow -R -t ~ macos   # or: stow -R -t ~ linux
```

## Uninstalling

```bash
cd ~/.dotfiles
stow -D macos   # or: stow -D linux
```

## License

MIT -- see [LICENSE](LICENSE) for details.
