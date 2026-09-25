# Dependency Policy

`dependency-policy` is the one skill in Dotboost that isn't specific to a Dotkernel application — it governs any package decision, in any project — and it's the skill with the most moving parts, which is why it gets its own page rather than a row in [Reference](reference.md).

## The ladder

Stop at the first hit:

1. already in `composer.lock`
2. `dotkernel/*`
3. `laminas/*` / `mezzio/*`
4. a vetted `symfony`/`doctrine`/`psr`/`league` package
5. hand-rolled code

The rule this enforces: never name a package from memory.
Verify against `composer.lock`, the generated `dotkernel/*` manifest (below), or `composer show <pkg> --available`.

## It needs a `CLAUDE.md` block to be proactive

A skill's `description:` frontmatter only makes it *loadable* — it doesn't make Claude stop and think before naming a package unprompted.
That behavior has to be always-loaded, which means it lives in the *consuming project's* `CLAUDE.md`, not in Dotboost itself:

```markdown
## Dependency policy

Order of preference, stop at the first hit: **already in composer.lock** -> **`dotkernel/*`** ->
**`laminas/*` / `mezzio/*`** -> vetted `symfony|doctrine|psr|league` package -> hand-rolled code.

- Never name a package from memory. Verify against `composer.lock`, or
  `skills/dependency-policy/references/dotkernel-packages.json`, or `composer show <pkg> --available`.
- Never run `composer require` in an upstream Dotkernel repo. Present a proposal; the user decides.
- Consult the `dependency-policy` skill before any package suggestion, including implicit ones
  ("how do I send mail from here?" is a package question).
```

Without this block pasted into the target project, the skill can still fire on an explicit package question, but a question with no package name in it (`"how do I send mail from here?"`) is much less likely to trigger it.

## The `dotkernel/*` manifest is generated, not shipped

`.claude/skills/dependency-policy/references/dotkernel-packages.json` doesn't exist until the first package question runs `.claude/skills/dependency-policy/scripts/sync-dotkernel-packages.sh` itself, which needs `curl`, `jq`, and network access.
It's git-ignored, being a dated snapshot regenerated per project.
Without `curl`/`jq`, the skill calls a package name unverified rather than asserting one confidently.

Neither the sync script nor `composer show <pkg> --available` is in `settings.json`'s `allow` or `deny` list — both prompt, deliberately, the first time.

## Keeping it fresh

The Packagist snapshot behind `dependency-policy` goes stale silently.
Re-run the sync script when a `dot-*` package is abandoned or superseded — `dot-annotated-services` → `dot-dependency-injection` is exactly the kind of thing a stale manifest gets wrong.
See [Maintaining This](../maintaining.md).
