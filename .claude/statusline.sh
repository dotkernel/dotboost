#!/usr/bin/env bash
# .claude/statusline.sh  —  pure bash, no jq/python needed
#
# Output (design "Statusline Final" / 1e, two lines, column 2 aligned at cell 30):
#   ~/parent/folder               Model  <level>
#   5h <20-cell bar> <pct>%       resets in <1h 48m> (<hh:mm>)  7d <pct>%
#
# The 5h / 7d figures are the OFFICIAL rate-limit values Claude Code passes
# in on stdin under `rate_limits` (used_percentage + resets_at epoch). These
# match what /usage and your account show — no estimation involved.

input=$(cat)
NOW=$(date +%s)

# ---- tiny JSON extractors (good enough for Claude Code's payload) ----------
# string value of a top-level-ish "key":"value"
jstr() { printf '%s' "$input" | grep -o "\"$1\":\"[^\"]*\"" | head -1 | sed 's/^[^:]*:"//; s/"$//'; }

# Pull "key":<number> from a given JSON fragment. Handles ints and floats.
jnum() { printf '%s' "$2" | grep -o "\"$1\":[0-9.]*" | head -1 | sed 's/^[^:]*://'; }

MODEL=$(jstr display_name); [[ -z "$MODEL" ]] && MODEL=Claude
MODEL=${MODEL% (*}          # drop suffixes like " (1M context)"
MODEL=${MODEL#Claude }      # drop a leading "Claude "
EFFORT=$(printf '%s' "$input" | grep -o '"effort":{[^}]*}' | grep -o '"level":"[^"]*"' | sed 's/^[^:]*:"//; s/"$//')
CWD=$(jstr current_dir);    [[ -z "$CWD"   ]] && CWD=$(jstr cwd)
[[ -z "$CWD" ]] && CWD=$PWD

# ---- official rate limits ---------------------------------------------------
# Isolate each window's { ... } object, then read its two fields.
FIVE=$(printf '%s'  "$input" | grep -o '"five_hour":{[^}]*}')
SEVEN=$(printf '%s' "$input" | grep -o '"seven_day":{[^}]*}')

# used_percentage may be a float (e.g. 56.9999) -> round to nearest int, clamp 0–100.
round() { awk -v n="${1:-}" 'BEGIN{ if (n=="") { print ""; exit } r=int(n+0.5); print (r<0?0:(r>100?100:r)) }'; }

FIVE_PCT=$(round "$(jnum used_percentage "$FIVE")")
SEVEN_PCT=$(round "$(jnum used_percentage "$SEVEN")")
FIVE_RESET=$(jnum resets_at "$FIVE"); FIVE_RESET=${FIVE_RESET%.*}

# ---- palette (truecolor) ----------------------------------------------------
RST=$'\033[0m'
BLD=$'\033[1m'
fg() { printf '\033[38;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
bg() { printf '\033[48;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }

C_BRIGHT=ecebe8 C_DIM=85827b C_MODEL=d97757 C_EFFORT=b4a0f5
C_TRACK=26282d C_OK=9ece6a C_WARN=e0af68 C_CRIT=f7768e

DIM=$(fg $C_DIM)

pct_col() {  # ok < 50, warn < 80, crit otherwise
  if   (( $1 < 50 )); then fg $C_OK
  elif (( $1 < 80 )); then fg $C_WARN
  else                     fg $C_CRIT
  fi
}

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

# ---- layout ----------------------------------------------------------------
DIR=${CWD/#$HOME/\~}
if [[ $DIR == */* ]]; then PARENT=${DIR%/*}/ BASE=${DIR##*/}; else PARENT='' BASE=$DIR; fi
[[ -z "$BASE" ]] && BASE=/

W1=$(( ${#PARENT} + ${#BASE} ))
W2=0; [[ -n "$FIVE_PCT" ]] && W2=$(( 2 + 1 + CELLS + 1 + ${#FIVE_PCT} + 1 ))
COL=30
(( W1 + 2 > COL )) && COL=$(( W1 + 2 ))
(( W2 + 2 > COL )) && COL=$(( W2 + 2 ))

LINE1="$DIM$PARENT$RST$BLD$(fg $C_BRIGHT)$BASE$RST$(printf '%*s' $(( COL - W1 )) '')"
LINE1+="$BLD$(fg $C_MODEL)$MODEL$RST"
[[ -n "$EFFORT" ]] && LINE1+="  $(fg $C_EFFORT)$EFFORT$RST"

if [[ -z "$FIVE_PCT" && -z "$SEVEN_PCT" ]]; then
  printf '%s\n' "$LINE1"
  exit 0
fi

LINE2=''
if [[ -n "$FIVE_PCT" ]]; then
  LINE2+="${DIM}5h$RST $(bar "$FIVE_PCT") $BLD$(pct_col "$FIVE_PCT")$FIVE_PCT%$RST$(printf '%*s' $(( COL - W2 )) '')"
  if [[ -n "$FIVE_RESET" ]]; then
    MINS=$(( (FIVE_RESET - NOW) / 60 )); (( MINS < 0 )) && MINS=0
    if (( MINS >= 60 )); then LEFT_STR=$(printf '%dh %02dm' $(( MINS / 60 )) $(( MINS % 60 )))
    else                      LEFT_STR="${MINS}m"
    fi
    LINE2+="${DIM}resets in$RST $LEFT_STR $DIM($(date -d "@$FIVE_RESET" +%H:%M))$RST"
  fi
else
  LINE2+=$(printf '%*s' $COL '')
fi
[[ -n "$SEVEN_PCT" ]] && LINE2+="  ${DIM}7d$RST $(pct_col "$SEVEN_PCT")$SEVEN_PCT%$RST"

printf '%s\n%s\n' "$LINE1" "$LINE2"
