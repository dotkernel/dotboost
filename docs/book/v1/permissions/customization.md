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
Note that `defaultMode: "auto"` lets the session edit files without proposing a plan first; it is an opt-in, not a team default.

## Status line placement

`settings.local.json.example` also carries an alternate `statusLine.command` pointing at `~/.claude/statusline.sh` instead of the per-project copy, for anyone who wants one shared status line across every project rather than one per repo.
See [Status Line](../status-line.md).
