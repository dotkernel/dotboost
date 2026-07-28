#!/usr/bin/env bash
# SessionStart: print a short briefing that becomes part of Claude's context.
# Detects which Dotkernel application this is and what is not set up yet.
# Everything here is read-only. Keep the output compact.

set -u
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

echo "## Project state"

# --- which Dotkernel application? ---
if [ -f composer.json ]; then
  pkg=$(sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' composer.json | head -1)
  ns=$(grep '": "src/' composer.json 2>/dev/null | grep -v '"Core' | head -1 \
    | sed 's/^[^"]*"\([A-Za-z]*\).*/\1/')
  variant="unknown"
  case "$pkg" in
    */api)      variant="API (REST/HAL)" ;;
    */admin)    variant="Admin (templated, forms)" ;;
    */frontend) variant="Frontend (templated, forms)" ;;
    */light)    variant="Light (minimal starter)" ;;
    */queue)    variant="Queue (CLI/worker)" ;;
  esac
  if [ "$variant" = "unknown" ]; then
    grep -q 'mezzio/mezzio-hal' composer.json && variant="API-style (has mezzio-hal)"
    grep -q 'laminas/laminas-form' composer.json && variant="templated-style (has laminas-form)"
  fi
  echo "- package: ${pkg:-unknown}  |  variant: ${variant}"
  [ -n "$ns" ] && echo "- root namespace: ${ns}"
  grep -q 'authorization-guards' -r config/autoload 2>/dev/null \
    && echo "- authorization: guards (authorization-guards.global.php)" \
    || { [ -f config/autoload/authorization.global.php ] && echo "- authorization: RBAC (authorization.global.php)"; }
fi

# --- git ---
if command -v git >/dev/null 2>&1 && [ -d .git ]; then
  branch=$(git branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch="(detached or no commits yet)"
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  echo "- branch: ${branch} (${dirty} uncommitted path(s))"
  eol_bad=$(git ls-files --eol 2>/dev/null | grep -c 'w/crlf' || true)
  [ "${eol_bad:-0}" -gt 0 ] && echo "- WARNING: ${eol_bad} tracked file(s) have CRLF in the worktree; run /dk-hygiene"
  [ -f .gitmodules ] && echo "- .gitmodules present: Core is a submodule; commit inside src/Core, then bump the pointer here"
fi

# --- setup completeness ---
[ -d vendor ] || echo "- vendor/ missing — dependencies are not installed (run /dk-bootstrap)"

for d in config/autoload/*.dist config/*.dist; do
  [ -e "$d" ] || continue
  target=${d%.dist}
  [ -f "$target" ] && continue
  case "$target" in
    config/development.config.php) continue ;;   # managed by development-mode, not copied by hand
  esac
  echo "- missing ${target} (copy from ${d})"
done

[ -f config/development.config.php ] && echo "- development mode is ENABLED"
[ -f data/cache/config-cache.php ] && echo "- config cache present; clear it after config edits"

echo "- Reminder: no dependency-manifest edits, no installs, no DB commands without asking."
exit 0
