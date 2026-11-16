# Customization

The `ask` and `allow` tiers in [Reference](reference.md) are personal preferences, not fixed policy.
Override them for each machine in `.claude/settings.local.json`.
This file is a layer on top of `settings.json`, and git ignores it.
Never edit the shared file to make a rule less strict for yourself.

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
```

Do not make the `deny` tier (never read, never written, never run) less strict in this way.
It protects secrets and prevents destructive operations, for each person who runs the session.

## Session preferences

The shared `settings.json` sets no permission mode, theme, UI or spinner verbs.
`settings.local.json.example` has a sample of each.
The samples are `permissions.defaultMode: "auto"`, `theme: "dark"`, `tui: "fullscreen"` and a `spinnerVerbs` list with a Dotkernel theme.
Keep the samples that you want and delete the others.
The `defaultMode: "auto"` entry only shows the key.
It does not work from that file.
Claude Code does not apply `auto` from project or local settings.
The session starts without auto mode, and you get no error.
To use auto mode, set `permissions.defaultMode` in `~/.claude/settings.json`.
See [Permission modes](https://code.claude.com/docs/en/permission-modes).

## Status line placement

`settings.local.json.example` also has a different `statusLine.command`.
It points to `~/.claude/statusline.sh`, not to the copy in the project.
Use it if you want one shared status line for all projects, not one for each repo.
See [Status Line](../status-line.md).
