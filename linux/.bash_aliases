# Shell
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c="clear"
alias s="source ~/.bashrc"

# grep w/ PCRE search ("-P")
alias grep="/bin/grep --color=auto"
alias fgrep='/bin/fgrep --color=auto'
alias egrep='/bin/egrep --color=auto'

# DEV
alias python=python3
alias myjup="jupyter lab --no-browser --ip 0.0.0.0 --notebook-dir=${workspaceFolder}"
alias black="${HOME}/.vscode-env/${MY_ENV,,}/bin/black --config=${workspaceFolder}/pyproject.toml"

# GUIX build
export PACKAGES="
    python-ipykernel
    python-ipython
    guix-jupyter
    jupyter
    python-pylint
    graphviz
    gprof2dot
    python-graphviz
    python-dotenv
    python-tqdm
    btop
    bat
    pre-commit
    ripgrep
    fzf
    zoxide
    stow
    exa
    pgcli
"

alias moc1="guix shell -D moc1 $(for package in $PACKAGES; do echo -n "$package "; done)"
alias calc="guix shell -D calc $(for package in $PACKAGES; do echo -n "$package "; done)"

alias slapdash='guix shell -L ~/repo/slapdash -D ${MY_ENV,,} $(for package in $PACKAGES; do echo -n "$package "; done) awscliv2'
alias awslogin='aws sso login --profile ${AWS_PROFILE}'

# Git add incl dotfiles
alias ga="git add . -A"
alias gs="git status"
alias gc="git commit -m"
alias gpush="git push"
alias gpull="git pull"
alias gco="git branch -r | sed 's/^ *origin\///' | fzf --cycle --no-info --border=rounded --reverse | xargs git checkout"
alias gcd="git checkout develop"
alias gl="git log --oneline --graph --all --decorate --parents"
alias gstat="git diff --stat"
alias uncommit="git reset --soft HEAD~1"
alias forget="git reset --hard HEAD~1"
alias cleanup="git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D"

# TMUX
alias t="tmux"
alias ta="tmux a -t"
alias tls="tmux ls"
alias tn="tmux new -t"
alias tkill="tmux kill-server"

function take() {
    mkdir -p $1
    cd $1
}

# Monitor
alias watch_status='while true; do clear; echo -e "\nGIT STATUS: \033[1;34m${PWD##*/}\033[0m"; echo ""; git status; sleep 5; done'