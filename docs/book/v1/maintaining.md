# Maintaining This

Treat the skills as living documents.
When a review turns up the same mistake twice, that's a missing line in a skill, not a Claude problem.

## Skill descriptions drive loading

If a skill isn't triggering, make its `description:` list the words developers actually type, not the words the official documentation uses.
See [Skills Introduction](skills/introduction.md#reading-a-trigger-description).

## Keep the dependency manifest current

The Packagist snapshot behind `dependency-policy` goes stale silently — re-run `.claude/skills/dependency-policy/scripts/sync-dotkernel-packages.sh` when a `dot-*` package is abandoned or superseded.
`dot-annotated-services` → `dot-dependency-injection` is exactly the kind of thing a stale manifest gets wrong.
See [Dependency Policy](skills/dependency-policy.md).

## Adapting dotboost to a new Dotkernel application

Before adapting this configuration to a Dotkernel application it hasn't been used against yet, spend an hour reading that repo and correcting the skills against what's actually there.
A skill written from framework documentation rather than the real codebase produces confident wrong answers — worse than no skill at all, because it doesn't look uncertain.
