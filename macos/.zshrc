# Set up the PATH
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# History settings
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# Key bindings
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Setup autosuggestions and syntax highlighting
if [ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [ -f $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Enable Zsh completions
autoload -Uz compinit
compinit

# Load aliases
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# Set up Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# GNU grep
if [ -d "$(brew --prefix grep)/libexec/gnubin" ]; then
    export PATH="$(brew --prefix grep)/libexec/gnubin:$PATH"
fi

# Set up fzf key bindings and fuzzy completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'

# Set up Zoxide
if command -v zoxide 1>/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Use Starship with specific terminals
case "$TERM_PROGRAM$TERM" in
    vscode*|alacritty*|screen-256color*)
        if command -v starship 1>/dev/null 2>&1; then
            eval "$(starship init zsh)"
        fi
        ;;
esac

# Occasionally, you may need to run the following command to fix completions:
# rm ~/.zcompdump*; compinit

# ❯ brew leaves
# btop
# diff-so-fancy
# entr
# fzf
# git
# gprof2dot
# grep
# neovim
# nmap
# parallel
# pyenv-virtualenv
# ripgrep
# sha3sum
# starship
# stow
# tmux
# tree
# watch
# yq
# zoxide
# zsh-autosuggestions
# zsh-syntax-highlighting
