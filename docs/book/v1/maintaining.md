# Maintaining This

Treat the skills as living documents.
When a review turns up the same mistake twice, that's a missing line in a skill, not a Claude problem.

## Skill descriptions drive loading

If a skill isn't triggering, make its `description:` list the words developers actually type, not the words the official documentation uses.
See [Skills Introduction](skills/introduction.md#reading-a-trigger-description).

## Keep each skill's scope accurate

Every `SKILL.md` carries an `Applies to` block directly under its title, naming the projects and packages it covers:

```text
Applies to
  Projects:  - Dotkernel API
             - Dotkernel Admin
  Packages:  - none
```

Use `all` or `none` when that is the whole answer.
The block goes under the title rather than above the frontmatter, because Claude Code only reads frontmatter that starts on the first line.
When a skill gains or loses a project, update the block in the same change.

## Keep the dependency manifest current

The Packagist snapshot behind `dependency-policy` goes stale silently — re-run `.claude/skills/dependency-policy/scripts/sync-dotkernel-packages.sh` when a `dot-*` package is abandoned or superseded.
`dot-annotated-services` → `dot-dependency-injection` is exactly the kind of thing a stale manifest gets wrong.
See [Dependency Policy](skills/dependency-policy.md).

## Adapting Dotboost to a new Dotkernel project

Before adapting this configuration to a Dotkernel project it hasn't been used against yet, spend an hour reading that repo and correcting the skills against what's actually there.
A skill written from framework documentation rather than the real codebase produces confident wrong answers — worse than no skill at all, because it doesn't look uncertain.
