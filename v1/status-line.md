# Status Line

`.claude/statusline.sh` renders real account usage in the status bar, taken from the rate-limit payload Claude Code (≥ 2.1) passes to the status line on stdin — the same numbers `/usage` reports:

```text
~/project : Opus 5 ==> 5h:37% 2h14m left, resets @16:20 | 7d 61%
```

Pure bash and `awk` — no `jq`, no Python, no transcript scanning or guessed token budgets, so it works in Git Bash on Windows too.

## Placement

The two shipped configs disagree on purpose — pick one:

- `settings.json` points at `$CLAUDE_PROJECT_DIR/.claude/statusline.sh`, the per-project copy.
  This is what the standard install gives you, and it needs nothing further.
- `settings.local.json.example` points at `~/.claude/statusline.sh`, one shared copy across every project.
  To use that instead, run `cp .claude/statusline.sh ~/.claude/` from a project that already has the install — otherwise the status line comes up empty.

See [Customization](permissions/customization.md) for how `settings.local.json` layers over the shared config.
