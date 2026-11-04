# Status Line

`.claude/statusline.sh` renders real account and session usage in the status bar, taken from the JSON payload Claude Code (≥ 2.1) passes to the status line on stdin — the rate limits are the same numbers `/usage` reports:

```text
 ~/project   Opus 5.5 · high   $ 0.45   ctx ▰▱▱▱▱▱ 6%
5h ███████▍             37%  ↻ 2h 14m (16:20)   7d ▰▰▰▰▰▰▱▱▱▱ 61%
```

The first line is a row of coloured chips followed by the context gauge:

- the working directory, the model and its effort level;
- `$` — the session's estimated billed cost. It stays at `0.00` while both rate limits are under 100%; once either reaches 100%, and for the whole time the model is Fable, it adds up how much Claude Code's USD estimate (`cost.total_cost_usd`) grows.
  The payload carries no billed-credit field, so this is an estimate at API prices, not an invoice.
  The running total is kept per session in `${TMPDIR:-/tmp}/claude-statusline-<session_id>.cost`, and growth is credited to whatever state holds when the status line redraws;
- `ctx` — how full the context window is (`context_window.used_percentage`).

The second line holds the rate-limit gauges: the 5-hour window as a 20-cell heat gradient with its reset time, and the 7-day window.
A field the payload does not carry is left out (for example, the rate limits under an API key).
Colours are 24-bit, so the terminal needs truecolor support.

Pure bash and `awk` — no `jq`, no Python, no transcript scanning or guessed token budgets, so it works in Git Bash on Windows too.

## Placement

The two shipped configs disagree on purpose — pick one:

- `settings.json` points at `$CLAUDE_PROJECT_DIR/.claude/statusline.sh`, the per-project copy.
  This is what the standard install gives you, and it needs nothing further.
- `settings.local.json.example` points at `~/.claude/statusline.sh`, one shared copy across every project.
  To use that instead, run `cp .claude/statusline.sh ~/.claude/` from a project that already has the install — otherwise the status line comes up empty.

See [Customization](permissions/customization.md) for how `settings.local.json` layers over the shared config.
