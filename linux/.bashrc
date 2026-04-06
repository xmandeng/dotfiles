# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ── History ──────────────────────────────────────────────────────────────────
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# ── Shell options ────────────────────────────────────────────────────────────
shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# ── Color support ────────────────────────────────────────────────────────────
export TERM=xterm-256color

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# ── Aliases & functions ──────────────────────────────────────────────────────
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# ── PATH ─────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

# ── Completions ──────────────────────────────────────────────────────────────
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi
source '/home/mande/.bash_completions/comfy.sh'
alias c="source ~/comfy-env/bin/activate"

# ── Environment ──────────────────────────────────────────────────────────────
export EDITOR=vim
export VISUAL="$EDITOR"
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

# ── Machine-local overrides (secrets, keys, etc.) ───────────────────────────
[ -f ~/.bashrc.local ] && . ~/.bashrc.local

# ── Secure sensitive files ───────────────────────────────────────────────────
[ -f "$HOME/.pgpass" ] && chmod 600 "$HOME/.pgpass"
[ -f "$HOME/.pg_service.conf" ] && chmod 600 "$HOME/.pg_service.conf"
[ -d "$HOME/.ssh" ] && chmod 600 "$HOME/.ssh"/* 2>/dev/null

# ── Tool initialization ─────────────────────────────────────────────────────
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
eval "$(starship init bash)"
eval "$(zoxide init bash --cmd cd)"

# Local overrides (not tracked in dotfiles)
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
