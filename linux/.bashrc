# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
# shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

######################################## MY STUFF ########################################

export EDITOR=vim
export VISUAL="$EDITOR"

export JUPYTER_CONFIG_DIR=${HOME}/jupyter/cfg
export JUPYTERLAB_DIR=${HOME}/jupyter/app

export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'

if [ ! -v VSCODE_GIT_ASKPASS_MAIN ] && [ ! -v GUIX_ENVIRONMENT ]
then
  export MOCONE_ENVIRONMENT=QA2
  if [[ -v PYTHONPATH ]]; then
      export PYTHONPATH=${HOME}/repo/${MY_ENV,,}/src:${HOME}/.vscode-env/${MY_ENV,,}/lib/python3.9/site-packages/:$PYTHONPATH
  else
      export PYTHONPATH=${HOME}/repo/moc1/src:${HOME}/.vscode-env/${MY_ENV,,}/lib/python3.9/site-packages/
  fi
fi

if [ -n "$VSCODE_GIT_ASKPASS_MAIN" ]; then
  CODE=$(find ~/.vscode-server/ -name "code" | sort -r | head -n 1)

  git config --global core.editor "${CODE} --wait"
else
  git config --global core.editor "vim"
fi

###################################### COLOR PALETTE #####################################

# Terminal colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; CYAN='\033[0;36m'; BROWN_ORANGE='\033[0;33m'
BLACK='\033[0;30m'; WHITE='\033[1;37m'; NC='\033[0m' # No Color
LT_RED='\033[1;31m'; LT_GREEN='\033[1;32m'; LT_BLUE='\033[1;34m'
LT_PURPLE='\033[1;35m'; LT_CYAN='\033[1;36m'; LT_MAGENTA='\033[0;95m'
LT_GRAY='\033[0;37m'; DK_GRAY='\033[1;30m'

################################# Standard GUIX Setup ####################################

# GUIX Configs
export GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
# export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

parse_git_branch() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    fi
}

# eval `keychain --agents ssh --eval id_rsa`
eval `keychain --agents ssh --eval id_ed25519`

GUIX_PROFILE="${HOME}/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"

# Set Bash Prompt (PS1)
UNDER_GUIX=${GUIX_ENVIRONMENT:+ [guix]}
export PS1="${LT_PURPLE} ${UNDER_GUIX} ${debian_chroot:+($debian_chroot)}${LT_GREEN}\u@\h${NC}:${LT_BLUE}\w${YELLOW}\$(parse_git_branch)${NC}\n$ "


######################################### VS CODE ########################################

# Start by checking if shell running within vscode
if [ -v VSCODE_GIT_ASKPASS_MAIN ]
then

  # Load environment variables from dotENV
  if [ -v ENV_FILE_PATH ]
  then

    # # Experimental - Enable VSCode Interactive mode
    # sed -i "s#workspaceFolder=.*#workspaceFolder=${workspaceFolder}#g" $ENV_FILE_PATH

    export $(echo $(cat $ENV_FILE_PATH | sed 's/#.*//g'| xargs) | envsubst)
  fi

  # GUIX environment
  if [ ! -v GUIX_ENVIRONMENT ] && [ -v MY_ENV ] && [ -v ENABLE_GUIX ]
  then
    echo -e " ${LT_GREEN}*${NC} Loading ${CYAN}${MY_ENV^^}${NC} environment\n"
    guix shell -D ${MY_ENV,,} $(for package in $PACKAGES; do echo -n "$package "; done)
  fi

  function code() {
    local latest=$(find ~/.vscode-server/ -name "code" | sort -r | head -n 1)
    $latest "$@"
  }

fi

# Create symlink for guix environment
if [ -v GUIX_ENVIRONMENT ] && [ -v VSCODE_GIT_ASKPASS_MAIN ]
then
  echo -e " ${LT_GREEN}*${NC} Your ${CYAN}${MY_ENV^^}${NC} profile ${DK_GRAY}${GUIX_ENVIRONMENT}${NC} -> ${LT_MAGENTA}${HOME}/.vscode-env/${MY_ENV,,}"

  if [ -L ${HOME}/.vscode-env ] && [ -e ${HOME}/.vscode-env ]
  then
    rm ${HOME}/.vscode-env
  fi

  mkdir -p ${HOME}/.vscode-env/
  ln -sfn $GUIX_ENVIRONMENT ${HOME}/.vscode-env/${MY_ENV,,}

fi

######################################## MY STUFF ########################################

# INSTALL STARSHIP
# curl -sS https://starship.rs/install.sh | sed 's|/usr/local/bin|${HOME}/.local/bin|g' | sh

# INSTALL BLE (Bash Line Editor)
# https://github.com/akinomyoga/ble.sh
# source ~/.local/share/blesh/ble.sh > /dev/null 2>&1

# ASSIGN STARSHIP CONFIG
export STARSHIP_CONFIG=$HOME/.config/starship.toml
if [ -f "$STARSHIP_CONFIG" ] && [ -v VSCODE_GIT_ASKPASS_MAIN ] && [ -n $(which starship) ]; then
    eval "$(starship init bash)"
fi

[ -n "$(which zoxide)" ] && eval "$(zoxide init --cmd cd bash)"

# Secure sensitive files
[ -f "$HOME/.pgpass" ] && chmod 600 $HOME/.pgpass
[ -f "$HOME/.pg_service.conf" ] && chmod 600 $HOME/.pg_service.conf
[ -d "$HOME/.ssh" ] && chmod 600 $HOME/.ssh/*

function open() {
    if [ -d "$HOME/.vscode-server" ]; then
        if [ $# -eq 0 ]; then
            # No arguments provided, use fzf
            fzf --cycle --layout=reverse-list --preview='bat --plain --color=always --line-range :500 {}' | while IFS= read -r file; do
                if [ -n "$file" ]; then
                    $(find $HOME/.vscode-server/ -name "code" | sort -r | head -n 1) "$file"
                fi
            done
        else
            # Argument provided, use it as the file
            local file=$1
            $(find $HOME/.vscode-server/ -name "code" | sort -r | head -n 1) "$file"
        fi
    fi
}

function pick_db() {
    echo -e "qa\nqa_ref\nredshift\nprod\nprod_ref\nprod_rw\nprod_ref_rw" | \
    fzf --cycle \
        --layout=reverse-list \
        --height 7 \
        --no-info \
        --prompt="" \
        --phony \
        --border=rounded \
        --reverse
}

function login_db() {
    local service=$(pick_db)
    if [ -n "$service" ]; then
        pgcli service="$service"
    else
        echo -e "\e[1m\e[31m\n  No database selected.\n\e[0m"
    fi
}

# QT Postgres
alias sql='clear;login_db'

# TODO - use key-bindings.bash
function hist() {
    CMD=$(history | awk '{$1=""; print substr($0, 2)}' | grep -Pv "^hist(ory)?$" | uniq | tail -n 100 | fzf --tac --cycle)
    echo -e "\n${CMD}\n"
    eval $CMD
}

tmux_select_session() {
    SESSION=$(tmux list-sessions -F "#S" | fzf --height=40%)
    if [ -n "$SESSION" ]; then
        tmux attach-session -t "$SESSION"
    else
        echo "No session selected."
    fi
}

alias ts=tmux_select_session