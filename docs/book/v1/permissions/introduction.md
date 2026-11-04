# Introduction

`settings.json` decides what Claude Code may read, write, and run in a Dotkernel repo before a single word of conversation happens.
The rules fall into four tiers:

- **Never read** — `Read` denies. Claude's file tools and the Bash file commands Claude Code recognises (`cat`, `head`, `tail`, `sed`, `tee`) cannot open these files.
- **Never written** — `Edit` denies, which also cover `Write`.
- **Never run** — `Bash` denies.
- **Ask first** / **allowed outright** — everything else, split by risk.

The first three tiers exist to stop a class of mistake by rule rather than relying on Claude to remember not to do it: secrets are not read into context through the normal tools, dependency manifests are not silently edited, and destructive git or install commands are not silently run.
They are rules, not a sandbox: a command that reads files without naming them (`grep -r password config/`) or a script that opens a file itself is not covered.
For an OS-level guarantee, use the sandbox described in the [Claude Code permissions docs](https://code.claude.com/docs/en/permissions).
The full lists are in [Reference](reference.md).

This is deliberately blunter than a skill.
A skill can be out-argued by a sufficiently persuasive prompt; a `deny` rule in `settings.json` cannot.

## Personal overrides

The `ask` and `allow` tiers are opinionated defaults, not fixed policy — see [Customization](customization.md) for how to adjust them per machine without touching the shared file.

## Where this isn't the whole story

Some commands the `ask` tier implies should merely prompt are blocked outright by `guard-bash.sh`, because the hook can see into compound Bash commands that a permission glob cannot.
See [Guardrails vs. Permissions](../hooks/guardrails-vs-permissions.md).
