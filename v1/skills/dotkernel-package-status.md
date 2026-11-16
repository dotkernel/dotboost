# Package Status

`dotkernel-package-status` controls each package decision in a Dotkernel project.
It also tells whether a Dotkernel package is still maintained.
It contains the dependency policy and the lookup in the package listing that dotkernel.com publishes.
For this reason, it has its own page and not a row in [Reference](reference.md).

## The ladder

Stop at the first hit:

1. already in `composer.lock`
2. `dotkernel/*`
3. `laminas/*` / `mezzio/*`
4. a vetted `symfony`/`doctrine`/`psr`/`league` package
5. hand-rolled code

The skill enforces this rule: never name a package from memory.
A name is verified only when it is in `composer.lock` or in the dotkernel.com listing (below).
The skill reports each other name as unverified.

## The source of truth is dotkernel.com

Dotkernel publishes the support status of its open-source packages at <https://www.dotkernel.com/dotkernel-packages.json>.
Dotkernel builds this file again each day from the GitHub organization.
A version for human readers is at <https://www.dotkernel.com/dotkernel-packages-oss-lifecycle/>.
Each entry gives the `lifecycle` of the package (`active`, `maintenance`, `security-only` or `archived`), its `php` constraint, and the `archived` flag from GitHub.

The skill fetches a new copy of the listing for each question.
The skill does not generate, ship or store a file in the project, so you have nothing to refresh or git-ignore.
The fetch needs network access.
The fetch is not in the `allow` list or the `deny` list of `settings.json`, so it shows a prompt the first time.
If the fetch fails, the skill calls `dotkernel/*` names that are not in `composer.lock` unverified.
It does not use its memory as a fallback.

No part of the skill queries Packagist.
The skill reports a `laminas/*`, `mezzio/*` or community package that is not already installed as unverified.
You must then confirm its maintenance status, its PHP support and its license.
A general rule: an "actively maintained" package has a release in the last 12 months.

## It needs a `CLAUDE.md` block to be proactive

The `description:` frontmatter of a skill only makes the skill *loadable*.
It does not make Claude stop and think before Claude names a package that nobody asked for.
That behavior must always be loaded.
Thus it goes in the `CLAUDE.md` of the *project that uses Dotboost*, not in Dotboost:

```markdown
## Dependency policy

Use this order of preference, and stop at the first match: **already in composer.lock** -> **`dotkernel/*`** -> **`laminas/*` / `mezzio/*`** -> vetted `symfony|doctrine|psr|league` package -> hand-rolled code.

- Never name a package from memory.
  Verify it against `composer.lock`, or against the `dotkernel/*` listing published at <https://www.dotkernel.com/dotkernel-packages.json>.
  Say that any other name is unverified.
- Never run `composer require` in an upstream Dotkernel repository.
  Present a proposal.
  The user decides.
- Before you suggest a package, use the `dotkernel-package-status` skill.
  This also applies to implicit suggestions: "how do I send mail from here?" is a package question.
```

If the target project does not have this block, the skill can still load on an explicit package question.
But a question with no package name in it (`"how do I send mail from here?"`) is much less likely to load the skill.

## When the listing is wrong

Report a wrong or out-of-date entry in [`dotkernel/dotkernel.com`](https://github.com/dotkernel/dotkernel.com).
Report a wrong lifecycle value in the repository of the package, because its `OSSMETADATA` file declares the value.
See [Maintaining This](../maintaining.md).
