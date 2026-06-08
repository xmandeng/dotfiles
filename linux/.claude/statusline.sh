#!/usr/bin/env bash
# Claude Code status line — minimal, project-focused
# Reads JSON from stdin, outputs a single styled line

set -euo pipefail

INPUT=$(cat)

# --- Extract fields ---
PROJECT_DIR=$(echo "$INPUT" | jq -r '.workspace.project_dir // .cwd // ""')
# Strip " context" from the parenthetical size spec, e.g. "Opus 4.8 (1M context)" -> "Opus 4.8 (1M)".
# Matches any size token (1M, 200K, ...) so it applies to every context-tagged model.
MODEL_DISPLAY=$(echo "$INPUT" | jq -r '.model.display_name // ""' | sed 's/ context)/)/')
CTX_USED=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')

# --- Derive project name from git remote or folder ---
PROJECT=""
if [ -d "$PROJECT_DIR/.git" ] || [ -f "$PROJECT_DIR/.git" ]; then
  REMOTE=$(git -C "$PROJECT_DIR" remote get-url origin 2>/dev/null || true)
  if [ -n "$REMOTE" ]; then
    PROJECT=$(basename "$REMOTE" .git)
  fi
fi
if [ -z "$PROJECT" ]; then
  PROJECT=$(basename "$PROJECT_DIR")
fi

# --- Derive branch or worktree name ---
LOCATION=""
if [ -d "$PROJECT_DIR/.git" ] || [ -f "$PROJECT_DIR/.git" ]; then
  if [[ "$PROJECT_DIR" == */.claude/worktrees/* ]]; then
    LOCATION=$(basename "$PROJECT_DIR")
  else
    LOCATION=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || true)
  fi
fi

# --- Git status & metrics ---
GIT_STATUS=""
GIT_METRICS=""
if [ -d "$PROJECT_DIR/.git" ] || [ -f "$PROJECT_DIR/.git" ]; then
  # Porcelain status counts
  STAGED=0; MODIFIED=0; UNTRACKED=0; DELETED=0; CONFLICTED=0
  while IFS= read -r line; do
    X="${line:0:1}"
    Y="${line:1:1}"
    case "$X$Y" in
      "??") UNTRACKED=$((UNTRACKED + 1)) ;;
      "UU"|"AA"|"DD") CONFLICTED=$((CONFLICTED + 1)) ;;
      *)
        [[ "$X" =~ [MADRC] ]] && STAGED=$((STAGED + 1)) || true
        [[ "$Y" =~ [MD] ]] && MODIFIED=$((MODIFIED + 1)) || true
        [[ "$Y" == "D" ]] && DELETED=$((DELETED + 1)) || true
        ;;
    esac
  done < <(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null)

  # Ahead/behind
  AHEAD=0; BEHIND=0
  AB=$(git -C "$PROJECT_DIR" rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || true)
  if [ -n "$AB" ]; then
    AHEAD=$(echo "$AB" | awk '{print $1}')
    BEHIND=$(echo "$AB" | awk '{print $2}')
  fi

  # Stash count — pipe through xargs to strip leading whitespace from wc -l
  STASHED=$(git -C "$PROJECT_DIR" stash list 2>/dev/null | wc -l | xargs)

  # Build status string (matches starship git_status — symbols only, no counts)
  STATUS_PARTS=""
  [ "$CONFLICTED" -gt 0 ] && STATUS_PARTS+="=" || true
  [ "$STASHED" -gt 0 ] && STATUS_PARTS+="\$" || true
  [ "$STAGED" -gt 0 ] && STATUS_PARTS+="+" || true
  [ "$MODIFIED" -gt 0 ] && STATUS_PARTS+="!" || true
  [ "$DELETED" -gt 0 ] && STATUS_PARTS+="✘" || true
  [ "$UNTRACKED" -gt 0 ] && STATUS_PARTS+="?" || true
  if [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -gt 0 ]; then
    STATUS_PARTS+="↕"
  else
    [ "$AHEAD" -gt 0 ] && STATUS_PARTS+="⇡" || true
    [ "$BEHIND" -gt 0 ] && STATUS_PARTS+="⇣" || true
  fi

  if [ -n "$STATUS_PARTS" ]; then
    GIT_STATUS="${STATUS_PARTS}"
  fi

  # Git metrics (+added / -deleted lines)
  DIFF_STAT=$(git -C "$PROJECT_DIR" diff --shortstat HEAD 2>/dev/null || true)
  ADDED=$(echo "$DIFF_STAT" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || true)
  REMOVED=$(echo "$DIFF_STAT" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || true)
  ADDED=${ADDED:-0}
  REMOVED=${REMOVED:-0}

  METRICS_ADDED=""
  METRICS_REMOVED=""
  [ "$ADDED" -gt 0 ] && METRICS_ADDED="$ADDED" || true
  [ "$REMOVED" -gt 0 ] && METRICS_REMOVED="$REMOVED" || true
fi

# --- Colors (matched to starship.toml) ---
DIM='\033[2m'
CYAN='\033[96m'                   # bright cyan — project name
YELLOW='\033[33m'               # git_branch
RED='\033[31m'                   # git_status
GREEN='\033[32m'                 # git_metrics added
GRAY='\033[38;2;160;169;203m'   # #a0a9cb — time/secondary text
FADED='\033[2;38;2;110;115;135m' # dim + #6e7387 — barely-there text (session id)
ITALIC='\033[3m'
RESET='\033[0m'

SEP=" "

# --- Build output ---
OUT=""

# Project name (always shown)
if [ -n "$PROJECT" ]; then
  OUT="${CYAN}${PROJECT}${RESET}"
fi

# Branch or worktree name + git status + metrics
if [ -n "$LOCATION" ]; then
  OUT="${OUT}${SEP}${YELLOW}\uf418 ${LOCATION}${RESET}"
  if [ -n "$GIT_STATUS" ]; then
    OUT="${OUT} ${RED}${GIT_STATUS}${RESET}"
  fi
  if [ -n "$METRICS_ADDED" ]; then
    OUT="${OUT} ${GREEN}+${METRICS_ADDED}${RESET}"
  fi
  if [ -n "$METRICS_REMOVED" ]; then
    OUT="${OUT} ${RED}-${METRICS_REMOVED}${RESET}"
  fi
fi

# Context % — only when >= 60%
CTX_INT=${CTX_USED%.*}
CTX_INT=${CTX_INT:-0}
if [ "$CTX_INT" -ge 60 ] 2>/dev/null; then
  if [ "$CTX_INT" -ge 80 ]; then
    CTX_COLOR="$RED"
  else
    CTX_COLOR="$GRAY"
  fi
  [ -n "$OUT" ] && OUT="${OUT}${SEP}${FADED}·${RESET}${SEP}" || true
  OUT="${OUT}${CTX_COLOR}ctx ${CTX_INT}%${RESET}"
fi

# Model + session id, appended after the git info on the same line.
# Separator pipe uses the same muted gray as the model text.
MODEL_INFO=""
if [ -n "$MODEL_DISPLAY" ]; then
  MODEL_INFO="${GRAY}${MODEL_DISPLAY}${RESET}"
fi
if [ -n "$SESSION_ID" ]; then
  [ -n "$MODEL_INFO" ] && MODEL_INFO="${MODEL_INFO}${SEP}${FADED}·${RESET}${SEP}" || true
  MODEL_INFO="${MODEL_INFO}${FADED}${SESSION_ID}${RESET}"
fi
if [ -n "$MODEL_INFO" ]; then
  [ -n "$OUT" ] && OUT="${OUT}${SEP}${FADED}·${RESET}${SEP}" || true
  OUT="${OUT}${MODEL_INFO}"
fi

echo -e "$OUT"
