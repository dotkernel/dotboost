#!/usr/bin/env bash
# PostToolUse normaliser for Dotkernel projects.
# Enforces: UTF-8 without BOM, LF line endings, no trailing whitespace,
# exactly one trailing newline. Pure bash + sed, no jq.
# Exit 0 always — this fixes silently rather than blocking.

set -u

payload=$(cat)

raw_path=$(printf '%s' "$payload" | tr -d '\n' \
  | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

[ -z "$raw_path" ] && exit 0

path=${raw_path//\\\\/\\}
path=${path//\\//}

[ -f "$path" ] || exit 0

lower=$(printf '%s' "$path" | tr '[:upper:]' '[:lower:]')

# Skip binaries and anything not ours.
case "$lower" in
  *.png|*.jpg|*.jpeg|*.gif|*.ico|*.svg|*.zip|*.phar|*.pdf|*.woff|*.woff2|*.ttf|*.eot|*.key|*.pem)
    exit 0 ;;
  */vendor/*|*/node_modules/*|*/.git/*|*/data/*|*/log/*)
    exit 0 ;;
esac

# Text files only.
case "$lower" in
  *.php|*.phtml|*.twig|*.md|*.json|*.xml|*.neon|*.yml|*.yaml|*.sh|*.txt|*.dist|*.html|*.css|*.js|*.sql|*.editorconfig|*.gitattributes|*.gitignore) ;;
  *) exit 0 ;;
esac

changed=""
tmp="${path}.dk-normalize.$$"

# 1. Strip UTF-8 BOM.
bom=$(printf '\357\273\277')
if [ "$(head -c 3 "$path" 2>/dev/null)" = "$bom" ]; then
  tail -c +4 "$path" > "$tmp" && mv "$tmp" "$path"
  changed="${changed} BOM-removed"
fi

# 2. CRLF/CR -> LF.
if LC_ALL=C grep -qU $'\r' "$path" 2>/dev/null; then
  tr -d '\r' < "$path" > "$tmp" && mv "$tmp" "$path"
  changed="${changed} CRLF->LF"
fi

# 3. Trailing whitespace (skip markdown: two trailing spaces are a hard line break).
case "$lower" in
  *.md) ;;
  *)
    if LC_ALL=C grep -q '[[:space:]]$' "$path"; then
      sed 's/[[:space:]]*$//' "$path" > "$tmp" && mv "$tmp" "$path"
      changed="${changed} trailing-ws-stripped"
    fi
    ;;
esac

# 4. Exactly one trailing newline.
if [ -s "$path" ] && [ "$(tail -c 1 "$path" | wc -l)" -eq 0 ]; then
  printf '\n' >> "$path"
  changed="${changed} newline-added"
fi

if [ -n "$changed" ]; then
  printf 'File hygiene applied to %s:%s\n' "$path" "$changed" >&2
fi

exit 0
