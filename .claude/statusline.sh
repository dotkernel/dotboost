#!/usr/bin/env bash
# .claude/statusline.sh  —  pure bash + awk, no jq/python needed
#
# Output (design "Pills", two lines):
#    ~/parent/folder   Model · <level>   $ <cost>   ctx <6 segs> <pct>%
#   5h <20-cell bar> <pct>%  ↻ <1h 48m> (<hh:mm>)   7d <10 segs> <pct>%
#
# Every figure comes from the JSON Claude Code passes on stdin:
#   5h / 7d   rate_limits.{five_hour,seven_day}  — the official values /usage shows
#   $         cost.total_cost_usd                — estimated billed cost: growth while on Fable or past 100% of 5h/7d
#   ctx       context_window.used_percentage     — how full the context window is

input=$(cat)
NOW=$(date +%s)

# ---- tiny JSON extractors (good enough for Claude Code's payload) ----------
jstr()  { printf '%s' "$input" | grep -o "\"$1\":\"[^\"]*\"" | head -1 | sed 's/^[^:]*:"//; s/"$//'; }
jnum()  { printf '%s' "${2:-$input}" | grep -o "\"$1\":[0-9.]*" | head -1 | sed 's/^[^:]*://'; }
# float -> nearest int, clamped 0–100 (empty in, empty out)
round() { awk -v n="${1:-}" 'BEGIN{ if (n=="") { print ""; exit } r=int(n+0.5); print (r<0?0:(r>100?100:r)) }'; }

MODEL=$(jstr display_name); [[ -z "$MODEL" ]] && MODEL=Claude
MODEL=${MODEL% (*}          # drop suffixes like " (1M context)"
MODEL=${MODEL#Claude }      # drop a leading "Claude "
EFFORT=$(printf '%s' "$input" | grep -o '"effort":{[^}]*}' | grep -o '"level":"[^"]*"' | sed 's/^[^:]*:"//; s/"$//')
CWD=$(jstr current_dir); [[ -z "$CWD" ]] && CWD=$(jstr cwd); [[ -z "$CWD" ]] && CWD=$PWD
DIR=${CWD/#$HOME/\~}
if [[ $DIR == */* ]]; then PARENT=${DIR%/*}/ BASE=${DIR##*/}; else PARENT='' BASE=$DIR; fi
[[ -z "$BASE" ]] && BASE=/

# ---- official rate limits ---------------------------------------------------
FIVE=$(printf '%s'  "$input" | grep -o '"five_hour":{[^}]*}')
SEVEN=$(printf '%s' "$input" | grep -o '"seven_day":{[^}]*}')
FIVE_PCT=$(round "$(jnum used_percentage "$FIVE")")
SEVEN_PCT=$(round "$(jnum used_percentage "$SEVEN")")
FIVE_RESET=$(jnum resets_at "$FIVE"); FIVE_RESET=${FIVE_RESET%.*}
LEFT_STR='' CLOCK=''
if [[ -n "$FIVE_RESET" ]]; then
  MINS=$(( (FIVE_RESET - NOW) / 60 )); (( MINS < 0 )) && MINS=0
  if (( MINS >= 60 )); then LEFT_STR=$(printf '%dh %02dm' $(( MINS / 60 )) $(( MINS % 60 ))); else LEFT_STR="${MINS}m"; fi
  # Reset clock: GNU date takes -d @epoch, BSD/macOS date takes -r epoch.
  CLOCK=$(date -d "@$FIVE_RESET" +%H:%M 2>/dev/null || date -r "$FIVE_RESET" +%H:%M 2>/dev/null)
fi

# ---- session cost, duration, context ---------------------------------------
# Billed cost. The payload has no billed-credit field, only total_cost_usd (an estimate at
# API prices), so each render adds the growth since the previous render to a per-session
# total — but only while the model is Fable (always billed as extra usage) or either rate
# limit is at 100% or more. Below that the chip stays at 0.
TOTAL=$(jnum total_cost_usd); TOTAL=${TOTAL:-0}
MODEL_ID=$(printf '%s' "$input" | grep -o '"model":{[^}]*}' | grep -o '"id":"[^"]*"' | sed 's/^[^:]*:"//; s/"$//')
BILLING=$(awk -v f="$(jnum used_percentage "$FIVE")" -v s="$(jnum used_percentage "$SEVEN")" \
  'BEGIN{ print (f+0 >= 100 || s+0 >= 100) ? 1 : 0 }')
printf '%s' "$MODEL_ID" | grep -qi fable && BILLING=1
SID=$(jstr session_id)
STATE="${TMPDIR:-/tmp}/claude-statusline-${SID:-default}.cost"   # "<last total> <billed>"
LAST=0 BILLED=0
[[ -r "$STATE" ]] && read -r LAST BILLED < "$STATE"
BILLED=$(awk -v t="$TOTAL" -v l="${LAST:-0}" -v b="${BILLED:-0}" -v on="$BILLING" \
  'BEGIN{ d = (t+0 >= l+0) ? t-l : t+0; if (on == 1) b += d; printf "%.6f", b }')
printf '%s %s\n' "$TOTAL" "$BILLED" > "$STATE.$$" 2>/dev/null && mv -f "$STATE.$$" "$STATE" 2>/dev/null
COST=$(awk -v c="$BILLED" 'BEGIN{ printf (c+0<10 ? "%.2f" : "%.1f"), c+0 }')
# context_window.used_percentage is the one immediately followed by remaining_percentage
CTX_PCT=$(round "$(printf '%s' "$input" | grep -o '"used_percentage":[0-9.]*,"remaining_percentage"' | grep -o '[0-9.]*' | head -1)")

# ---- palette (truecolor) ----------------------------------------------------
RST=$'\033[0m'
BLD=$'\033[1m'
fg() { printf '\033[38;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
bg() { printf '\033[48;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }

C_BRIGHT=ecebe8 C_DIM=85827b C_MODEL=d97757 C_EFFORT=b4a0f5
C_TRACK=26282d C_OK=9ece6a C_WARN=e0af68 C_CRIT=f7768e C_COST=e6c384

DIM=$(fg $C_DIM)

pct_col() { if (( $1 < 50 )); then fg $C_OK; elif (( $1 < 80 )); then fg $C_WARN; else fg $C_CRIT; fi; }  # usage: high is bad

# Linear RGB mix of hex $1 → $2 at num/den ($3/$4), rounded half up.
mix() {
  local out='' k a b
  for k in 0 2 4; do
    a=$(( 0x${1:k:2} )) b=$(( 0x${2:k:2} ))
    out+=$(printf '%02x' $(( (2 * (a * $4 + (b - a) * $3) + $4) / (2 * $4) )))
  done
  printf '%s' "$out"
}

# 20-cell usage bar, 1/8-cell precision, heat gradient by cell position:
# cell i sits at t = (2i+1)/40; green → amber up to t = 0.55, amber → red after.
CELLS=20
EIGHTHS=('' '▏' '▎' '▍' '▌' '▋' '▊' '▉')
bar() {
  local units=$(( ($1 * 16 + 5) / 10 )) out i f n color
  out=$(bg $C_TRACK)
  for (( i = 0; i < CELLS; i++ )); do
    f=$(( units - i * 8 )); (( f < 0 )) && f=0; (( f > 8 )) && f=8
    if (( f == 0 )); then out+=' '; continue; fi
    n=$(( 2 * i + 1 ))
    if (( n < 22 )); then color=$(mix $C_OK $C_WARN $n 22)
    else                  color=$(mix $C_WARN $C_CRIT $(( n - 22 )) 18)
    fi
    out+=$(fg "$color")
    (( f == 8 )) && out+='█' || out+=${EIGHTHS[f]}
  done
  printf '%s' "$out$RST"
}

# seg_bar <pct> <segments> <hex> — ▰▱ gauge; any non-zero value lights one segment
seg_bar() {
  local on=$(( ($1 * $2 + 50) / 100 )) out i
  (( $1 > 0 && on == 0 )) && on=1
  out=$(fg "$3"); for (( i = 0; i < on; i++ )); do out+='▰'; done
  out+=$(fg 3b3e45); for (( ; i < $2; i++ )); do out+='▱'; done
  printf '%s' "$out$RST"
}

# pill <bg> <fg> <text> — a coloured chip
pill() { printf '%s%s %s %s' "$(bg "$1")" "$(fg "$2")" "$3" "$RST"; }

# ---- line 1: chips ----------------------------------------------------------
LINE1=$(pill 2f3340 $C_BRIGHT "$DIM$PARENT$(fg $C_BRIGHT)$BLD$BASE")
M="$BLD$MODEL"; [[ -n "$EFFORT" ]] && M+=" $RST$(bg d97757)$(fg 3a1d12)· $EFFORT"
LINE1+=" $(pill d97757 1a1b26 "$M")"
LINE1+=" $(pill 3a3326 $C_COST "\$ $COST")"
[[ -n "$CTX_PCT" ]] && LINE1+="  ${DIM}ctx$RST $(seg_bar "$CTX_PCT" 6 "$C_EFFORT") $(fg $C_EFFORT)$CTX_PCT%$RST"

# ---- line 2: gauges ---------------------------------------------------------
LINE2=''
if [[ -n "$FIVE_PCT" ]]; then
  LINE2+="${DIM}5h$RST $(bar "$FIVE_PCT") $BLD$(pct_col "$FIVE_PCT")$FIVE_PCT%$RST"
  if [[ -n "$LEFT_STR" ]]; then
    LINE2+="  $DIM↻$RST $LEFT_STR"
    [[ -n "$CLOCK" ]] && LINE2+=" $DIM($CLOCK)$RST"
  fi
fi
[[ -n "$SEVEN_PCT" ]] && LINE2+="   ${DIM}7d$RST $(seg_bar "$SEVEN_PCT" 10 "$C_OK") $(pct_col "$SEVEN_PCT")$SEVEN_PCT%$RST"
LINE2=${LINE2#   }

printf '%s\n' "$LINE1"
[[ -n "$LINE2" ]] && printf '%s\n' "$LINE2"
exit 0
