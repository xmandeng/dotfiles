# ── Core ─────────────────────────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'
alias s='source ~/.bashrc'
alias python=python3

alias grep='/bin/grep --color=auto'
alias fgrep='/bin/fgrep --color=auto'
alias egrep='/bin/egrep --color=auto'

# ── Git ──────────────────────────────────────────────────────────────────────
alias ga='git add . -A'
alias gs='git status'
alias gc='git commit -m'
alias gp='git log -p'
alias g1='git log --oneline'
alias gpush='git push'
alias gpull='git pull'
alias gco="git branch -r | sed 's/^ *origin\///' | fzf --cycle --no-info --border=rounded --reverse | xargs git checkout"
alias gcd='git checkout develop'
alias gl='git log --oneline --graph --all --decorate --parents'
alias gstat='git diff --stat'
alias uncommit='git reset --soft HEAD~1'
alias forget='git reset --hard HEAD~1'
alias cleanup="git branch -vv | grep 'origin/.*: gone]' | awk '{print \$1}' | xargs git branch -D"

# ── Tmux ─────────────────────────────────────────────────────────────────────
alias t='tmux'
alias ta='tmux a -t'
alias tls='tmux ls'
alias tn='tmux new -t'
alias tkill='tmux kill-server'

# ── Tools ────────────────────────────────────────────────────────────────────
alias claudeyolo='claude --dangerously-skip-permissions'
alias watch_status='while true; do clear; echo -e "\nGIT STATUS: \033[1;34m${PWD##*/}\033[0m"; echo ""; git status; sleep 5; done'

# ── Functions ────────────────────────────────────────────────────────────────
take() {
    mkdir -p "$1" && cd "$1"
}

hist() {
    local cmd
    cmd=$(history | awk '{$1=""; print substr($0, 2)}' | grep -Pv '^hist(ory)?$' | uniq | tail -n 100 | fzf --tac --cycle)
    [ -n "$cmd" ] && echo -e "\n${cmd}\n" && eval "$cmd"
}

open() {
    if [ -d "$HOME/.vscode-server" ]; then
        local code_bin
        code_bin=$(find "$HOME/.vscode-server/" -name "code" | sort -r | head -n 1)
        [ -z "$code_bin" ] && return 1
        if [ $# -eq 0 ]; then
            fzf --cycle --layout=reverse-list --preview='bat --plain --color=always --line-range :500 {}' | while IFS= read -r file; do
                [ -n "$file" ] && "$code_bin" "$file"
            done
        else
            "$code_bin" "$@"
        fi
    fi
}

tmux_select_session() {
    local session
    session=$(tmux list-sessions -F "#S" 2>/dev/null | fzf --height=40%)
    if [ -n "$session" ]; then
        tmux attach-session -t "$session"
    else
        echo "No session selected."
    fi
}
alias ts='tmux_select_session'
