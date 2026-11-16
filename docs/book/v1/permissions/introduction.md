# Introduction

`settings.json` controls what Claude Code can read, write and run in a Dotkernel repo, before the conversation starts.
The rules are in four tiers:

- **Never read**: `Read` denies.
  Claude's file tools and the Bash file commands that Claude Code recognises (`cat`, `head`, `tail`, `sed`, `tee`) cannot open these files.
- **Never written**: `Edit` denies, which also apply to `Write`.
- **Never run**: `Bash` denies.
- **Ask first** / **allowed outright**: all the other rules, in groups by risk.

The first three tiers prevent a type of mistake with a rule.
They do not rely on Claude to remember not to do the action.
With these tiers, the normal tools do not read secrets into the context.
Claude does not silently edit dependency manifests.
Claude does not silently run destructive git or install commands.
They are rules, not a sandbox.
They do not cover a command that reads files without their names (`grep -r password config/`), or a script that opens a file itself.
For a guarantee at the OS level, use the sandbox in the [Claude Code permissions docs](https://code.claude.com/docs/en/permissions).
[Reference](reference.md) gives the full lists.

This is intentionally less flexible than a skill.
A prompt with a sufficiently strong argument can make Claude ignore a skill.
It cannot make Claude ignore a `deny` rule in `settings.json`.

## Personal overrides

The `ask` and `allow` tiers are default values that we selected, not fixed policy.
To change them for each machine without a change to the shared file, see [Customization](customization.md).

## Other controls: the hooks

For some commands, the `ask` tier suggests a prompt only, but `guard-bash.sh` blocks them.
The hook can see into compound Bash commands, and a permission glob cannot.
See [Guardrails vs. Permissions](../hooks/guardrails-vs-permissions.md).
