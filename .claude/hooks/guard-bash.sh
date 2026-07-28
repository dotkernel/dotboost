#!/usr/bin/env bash
# PreToolUse guard for Bash commands in Dotkernel projects.
# Catches installs and destructive git even when hidden inside compound commands
# ("cd x && composer require y"), which path-based permission rules cannot see.
# Pure bash, no jq. Exit 0 = allow, exit 2 = block.

set -u

payload=$(cat)

cmd=$(printf '%s' "$payload" | tr -d '\n' \
  | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)"[[:space:]]*}[[:space:]]*}*[[:space:]]*$/\1/p')

if [ -z "$cmd" ]; then
  cmd=$(printf '%s' "$payload" | tr -d '\n' \
    | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi

[ -z "$cmd" ] && exit 0

cmd=${cmd//\\\"/\"}
cmd=${cmd//\\\\/\\}
norm=$(printf '%s' "$cmd" | tr '[:upper:]' '[:lower:]' | tr -s ' \t' '  ')

block() {
  printf 'BLOCKED command: %s\n%s\n' "$cmd" "$1" >&2
  exit 2
}

case " $norm " in
  *"composer require"*|*"composer remove"*|*"composer update"*|*"composer install"*)
    block "Dependency changes need my explicit approval. Tell me the package and why, and I will run it." ;;
esac

case " $norm " in
  *"npm install"*|*"npm i "*|*"npm uninstall"*|*"npm update"*|*"npm ci"*|\
  *"yarn add"*|*"yarn remove"*|*"pnpm add"*|*"pnpm remove"*|*"pip install"*)
    block "Package installs need my explicit approval." ;;
esac

case " $norm " in
  *"git push"*|*"git reset --hard"*|*"git clean -"*|*"git checkout -- "*|\
  *"git submodule"*|*"git filter-branch"*|*"git rebase"*)
    block "Destructive or publishing git operations are mine to run." ;;
esac

case " $norm " in
  *"rm -rf"*|*"rm -fr"*|*"mkfs"*|*"chmod -r 777"*)
    block "Refusing destructive filesystem command." ;;
esac

case " $norm " in
  *"doctrine-migrations migrate"*|*"doctrine-migrations execute"*|\
  *"fixtures:execute"*|*"schema:drop"*|*"schema:update"*)
    block "Database-mutating commands need my approval. Show me the command and what it will change." ;;
esac

case " $norm " in
  *"development-enable"*|*"development-disable"*)
    block "Toggling development mode changes committed config state. Ask me first." ;;
esac

exit 0
