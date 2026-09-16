# Introduction

`settings.json` decides what Claude Code may read, write, and run in a Dotkernel repo before a single word of conversation happens.
The rules fall into four tiers:

- **Never read** — `Read` denies. The contents never enter the context window at all.
- **Never written** — `Edit`/`Write` denies.
- **Never run** — `Bash` denies.
- **Ask first** / **allowed outright** — everything else, split by risk.

The first three tiers exist to make a class of mistake structurally impossible rather than relying on Claude to remember not to do it: secrets never get read into context in the first place, dependency manifests never get silently edited, and destructive git or install commands never get silently run.
The full lists are in [Reference](reference.md).

This is deliberately blunter than a skill.
A skill can be out-argued by a sufficiently persuasive prompt; a `deny` rule in `settings.json` cannot.

## Personal overrides

The `ask` and `allow` tiers are opinionated defaults, not fixed policy — see [Customization](customization.md) for how to adjust them per machine without touching the shared file.

## Where this isn't the whole story

Some commands the `ask` tier implies should merely prompt are blocked outright by `guard-bash.sh`, because the hook can see into compound Bash commands that a permission glob cannot.
See [Guardrails vs. Permissions](../hooks/guardrails-vs-permissions.md).
