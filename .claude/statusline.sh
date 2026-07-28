#!/usr/bin/env bash
# ~/.claude/statusline.sh  —  pure bash, no jq/python needed
#
# Shows your REAL account usage, straight from the rate-limit data that
# Claude Code (>= 2.1) passes to the statusline on stdin — the same numbers
# `/usage` reports:
#
#   .rate_limits.five_hour.used_percentage   .resets_at   -> 5h session window
#   .rate_limits.seven_day.used_percentage   .resets_at   -> 7d weekly window
#
# No transcript scanning, no guessed token budgets. Output:
#   dir : Model ==> 5h:NN% Xh left, resets @HH:MM | 7d NN%

input=$(cat)
NOW=$(date +%s)

# --- extractors (regex over the payload; good enough for this JSON) ----------
# top-level (or nested) string field:  "key":"value"
jstr() {
  printf '%s' "$input" \
    | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 \
    | sed -E 's/.*:[[:space:]]*"//; s/"$//'
}
# the flat {...} object for a rate_limits sub-window (no nested braces inside)
rl_section() {
  printf '%s' "$input" \
    | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\{[^}]*\}" | head -1
}
# a number-or-string field out of a section chunk
rl_field() {
  printf '%s' "$1" \
    | grep -oE "\"$2\"[[:space:]]*:[[:space:]]*(\"[^\"]*\"|[0-9.]+)" | head -1 \
    | sed -E 's/.*:[[:space:]]*//; s/^"//; s/"$//'
}
round() { awk -v v="$1" 'BEGIN{ if (v=="") exit; printf "%.0f", v }'; }

MODEL=$(jstr display_name); [[ -z "$MODEL" ]] && MODEL=$(jstr model)
[[ -z "$MODEL" ]] && MODEL=Claude
CWD=$(jstr current_dir);    [[ -z "$CWD" ]] && CWD=$(jstr cwd)

# --- pull the official 5h / 7d figures --------------------------------------
FIVE=$(rl_section five_hour)
SEVEN=$(rl_section seven_day)

PCT=$(round "$(rl_field "$FIVE"  used_percentage)")
WPCT=$(round "$(rl_field "$SEVEN" used_percentage)")
RESET_5H=$(rl_field "$FIVE" resets_at)

# --- derive time-left / reset clock for the 5h window -----------------------
LEFT_STR='--' ; RESET_STR='--:--'
if [[ -n "$RESET_5H" ]]; then
  # resets_at is a Unix epoch (int) on this build; older docs show ISO 8601.
  if [[ "$RESET_5H" =~ ^[0-9]+$ ]]; then
    RESET_EPOCH=$RESET_5H
  else
    RESET_EPOCH=$(date -d "$RESET_5H" +%s 2>/dev/null)
  fi
  if [[ -n "$RESET_EPOCH" ]]; then
    LEFT=$(( RESET_EPOCH - NOW )); (( LEFT < 0 )) && LEFT=0
    LEFT_STR=$(printf '%dh%02dm' $(( LEFT / 3600 )) $(( LEFT % 3600 / 60 )))
    RESET_STR=$(date -d "@$RESET_EPOCH" +%H:%M)
  fi
fi

[[ -n "$PCT"  ]] && PCT_DISP="${PCT}%"   || PCT_DISP='--'
[[ -n "$WPCT" ]] && WPCT_DISP="${WPCT}%" || WPCT_DISP='--'

# --- colours ----------------------------------------------------------------
pct_col() {  # green < 50, yellow < 80, red otherwise, gray if unknown
  if   ! [[ "$1" =~ ^[0-9]+$ ]]; then printf '\033[90m'
  elif (( $1 < 50 )); then printf '\033[32m'
  elif (( $1 < 80 )); then printf '\033[33m'
  else                     printf '\033[31m'
  fi
}
COL=$(pct_col "$PCT")
WCOL=$(pct_col "$WPCT")
RST=$'\033[0m'
YLW=$'\033[93m'   # bright yellow
WHT=$'\033[97m'   # bright white
BLU=$'\033[94m'   # bright blue
GRY=$'\033[90m'   # gray

DIR=${CWD/#$HOME/\~}

printf '%s%s%s%s:%s %s%s%s %s==> 5h:%s %s%s%s %s%s left, resets @%s%s %s| 7d%s %s%s%s\n' \
  "$YLW" "$DIR" "$RST" \
  "$WHT" "$RST" \
  "$BLU" "$MODEL" "$RST" \
  "$WHT" "$RST" \
  "$COL" "$PCT_DISP" "$RST" \
  "$GRY" "$LEFT_STR" "$RESET_STR" "$RST" \
  "$WHT" "$RST" \
  "$WCOL" "$WPCT_DISP" "$RST"
