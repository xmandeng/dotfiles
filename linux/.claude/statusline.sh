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
# First 8 characters of the session id: enough for a prefix match, a third of the columns of the full id.
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
SESSION_LABEL="${SESSION_ID:0:8}"
# Absent when the model has no effort parameter; values are low, medium, high, xhigh, max.
EFFORT=$(echo "$INPUT" | jq -r '.effort.level // ""')

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
PEACH='\033[38;2;250;179;135m'  # #fab387 — raised effort (high, xhigh)
FADED='\033[2;38;2;110;115;135m' # dim + #6e7387 — barely-there text
GHOST='\033[2;38;2;88;91;112m'    # dim + #585b70 — background text (session id, empty gauge slots)
ITALIC='\033[3m'
RESET='\033[0m'

SEP=" "

# --- Build output ---
# Workspace (project, branch, git), then model, effort and id, all on the left. The context
# meter alone sits on the right, padded to the terminal width Claude Code reports in COLUMNS.
# When the width is unknown or too narrow, the meter joins the left group on one line.

LEFT=""
if [ -n "$PROJECT" ]; then
  LEFT="${CYAN}${PROJECT}${RESET}"
fi
if [ -n "$LOCATION" ]; then
  LEFT="${LEFT}${SEP}${YELLOW} ${LOCATION}${RESET}"
  if [ -n "$GIT_STATUS" ]; then
    LEFT="${LEFT} ${RED}${GIT_STATUS}${RESET}"
  fi
  if [ -n "$METRICS_ADDED" ]; then
    LEFT="${LEFT} ${GREEN}+${METRICS_ADDED}${RESET}"
  fi
  if [ -n "$METRICS_REMOVED" ]; then
    LEFT="${LEFT} ${RED}-${METRICS_REMOVED}${RESET}"
  fi
fi

RIGHT=""
if [ -n "$MODEL_DISPLAY" ]; then
  RIGHT="${GRAY}${MODEL_DISPLAY}${RESET}"
fi

# Effort: five dots, filled count by level; faded, gray, peach, red.
if [ -n "$EFFORT" ]; then
  case "$EFFORT" in
    low)    EFFORT_FILL=1; EFFORT_COLOR="$FADED" ;;
    medium) EFFORT_FILL=2; EFFORT_COLOR="$GRAY" ;;
    high)   EFFORT_FILL=3; EFFORT_COLOR="$PEACH" ;;
    xhigh)  EFFORT_FILL=4; EFFORT_COLOR="$PEACH" ;;
    max)    EFFORT_FILL=5; EFFORT_COLOR="$RED" ;;
    *)      EFFORT_FILL=0; EFFORT_COLOR="$GRAY" ;;
  esac
  EFFORT_GAUGE=""
  for ((i = 0; i < 5; i++)); do
    if [ "$i" -lt "$EFFORT_FILL" ]; then EFFORT_GAUGE+="●"; else EFFORT_GAUGE+="○"; fi
  done
  FILLED="${EFFORT_GAUGE:0:$EFFORT_FILL}"
  EMPTY="${EFFORT_GAUGE:$EFFORT_FILL}"
  [ -n "$RIGHT" ] && RIGHT="${RIGHT} " || true
  RIGHT="${RIGHT}${EFFORT_COLOR}${FILLED}${RESET}${GHOST}${EMPTY}${RESET}"
fi

# Context: hidden below 40% so its appearance is itself the warning that the 50% safe
# zone is near. Ten blocks plus percentage; faded from 40%, peach from 50%, red from 80%.
CTX_INT=${CTX_USED%.*}
CTX_INT=${CTX_INT:-0}
CTX_INFO=""
if [ "$CTX_INT" -ge 40 ] 2>/dev/null; then
  if [ "$CTX_INT" -ge 80 ]; then
    CTX_COLOR="$RED"
  elif [ "$CTX_INT" -ge 50 ]; then
    CTX_COLOR="$PEACH"
  else
    CTX_COLOR="$FADED"
  fi
  CTX_FILL=$(( (CTX_INT + 5) / 10 ))
  [ "$CTX_FILL" -gt 10 ] && CTX_FILL=10 || true
  CTX_BAR=""
  for ((i = 0; i < 10; i++)); do
    if [ "$i" -lt "$CTX_FILL" ]; then CTX_BAR+="▰"; else CTX_BAR+="▱"; fi
  done
  CTX_INFO="${CTX_COLOR}ctx ${CTX_BAR:0:$CTX_FILL}${RESET}${GHOST}${CTX_BAR:$CTX_FILL}${RESET} ${CTX_COLOR}${CTX_INT}%${RESET}"
fi

if [ -n "$SESSION_LABEL" ]; then
  [ -n "$RIGHT" ] && RIGHT="${RIGHT}${SEP}${FADED}·${RESET}${SEP}" || true
  RIGHT="${RIGHT}${GHOST}${SESSION_LABEL}${RESET}"
fi

if [ -n "$LEFT" ] && [ -n "$RIGHT" ]; then
  LEFT="${LEFT}${SEP}${FADED}·${RESET}${SEP}${RIGHT}"
else
  LEFT="${LEFT}${RIGHT}"
fi

# Visible width of a styled string: expand escapes, strip SGR sequences, count characters.
visible_width() {
  LC_ALL=C.UTF-8 printf '%b' "$1" | sed 's/\x1b\[[0-9;]*m//g' | LC_ALL=C.UTF-8 wc -m | xargs
}

# Columns Claude Code reserves around the status line for its own chrome. A value that is
# too small overruns the line and the meter clips to an ellipsis; too large leaves a gap
# before the right edge.
CHROME_MARGIN=6

GAP="${SEP}${FADED}·${RESET}${SEP}"
[ -z "$CTX_INFO" ] && GAP="" || true
if [ -n "$LEFT" ] && [ -n "$CTX_INFO" ] && [ "${COLUMNS:-0}" -gt 0 ] 2>/dev/null; then
  PAD=$(( COLUMNS - CHROME_MARGIN - $(visible_width "$LEFT") - $(visible_width "$CTX_INFO") ))
  if [ "$PAD" -ge 3 ]; then
    GAP=$(printf '%*s' "$PAD" '')
  fi
fi

OUT="${LEFT}${GAP}${CTX_INFO}"

echo -e "$OUT"
