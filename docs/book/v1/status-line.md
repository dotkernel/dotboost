# Status Line

`.claude/statusline.sh` shows the real account and session usage in the status bar.
It reads the data from the JSON payload that Claude Code (≥ 2.1) sends to the status line on stdin.
The rate limits are the same numbers that `/usage` reports:

```text
 ~/project   Opus 5.5 · high   $ 0.45   ctx ▰▱▱▱▱▱ 6%
5h ███████▍             37%  ↻ 2h 14m (16:20)   7d ▰▰▰▰▰▰▱▱▱▱ 61%
```

The first line is a row of coloured chips, then the context gauge:

- the working directory, the model and its effort level.
- `$`: the estimated billed cost of the session.
  It stays at `0.00` while both rate limits are less than 100%.
  When one of them reaches 100%, and for all the time that the model is Fable, it adds the increase of the USD estimate from Claude Code (`cost.total_cost_usd`).
  The payload has no field for billed credit, so this value is an estimate at API prices, not an invoice.
  The script keeps the running total for each session in `${TMPDIR:-/tmp}/claude-statusline-<session_id>.cost`.
  It assigns each increase to the state that is true when the status line redraws.
- `ctx`: how full the context window is (`context_window.used_percentage`).

The second line has the gauges for the rate limits.
The 5-hour window shows as a heat gradient of 20 cells with its reset time, then the 7-day window shows.
If the payload does not have a field, the status line does not show it (for example, the rate limits with an API key).
The colours are 24-bit, so the terminal must support truecolor.

The script uses only bash and `awk`.
It does not use `jq` or Python, it does not scan transcripts, and it does not guess token budgets.
Thus it also works in Git Bash on Windows.

## Placement

The two configs that Dotboost supplies are different on purpose.
Select one of them:

- `settings.json` points at `$CLAUDE_PROJECT_DIR/.claude/statusline.sh`, the per-project copy.
  The standard install gives you this config, and it needs no more steps.
- `settings.local.json.example` points at `~/.claude/statusline.sh`, one shared copy across every project.
  To use this config, run `cp .claude/statusline.sh ~/.claude/` from a project that already has the install.
  If you do not, the status line is empty.

See [Customization](permissions/customization.md) to learn how `settings.local.json` adds a layer on top of the shared config.
