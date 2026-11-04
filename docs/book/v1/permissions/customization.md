# Customization

The `ask` and `allow` tiers documented in [Reference](reference.md) are personal preference, not fixed policy.
Override them per machine in `.claude/settings.local.json`, which layers on top of `settings.json` and is git-ignored — never edit the shared file to loosen a rule for yourself.

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
```

The `deny` tier (never read / never written / never run) is not meant to be relaxed this way — it protects secrets and guards against destructive operations regardless of who's running the session.

## Session preferences

The shared `settings.json` sets no permission mode, theme, UI or spinner verbs.
`settings.local.json.example` carries a sample of each — `permissions.defaultMode: "auto"`, `theme: "dark"`, `tui: "fullscreen"` and a Dotkernel-flavoured `spinnerVerbs` list.
Keep the ones you want and delete the rest.
The `defaultMode: "auto"` entry is only an example of the key, not a setting that works from that file: Claude Code does not apply `auto` from project or local settings, and the session starts without it, with no error.
To use auto mode, set `permissions.defaultMode` in `~/.claude/settings.json` instead — see [Permission modes](https://code.claude.com/docs/en/permission-modes).

## Status line placement

`settings.local.json.example` also carries an alternate `statusLine.command` pointing at `~/.claude/statusline.sh` instead of the per-project copy, for anyone who wants one shared status line across every project rather than one per repo.
See [Status Line](../status-line.md).
