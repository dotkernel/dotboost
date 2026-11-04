# Package Status

`dotkernel-package-status` governs every package decision in a Dotkernel project and answers whether a Dotkernel package is still maintained.
It holds the dependency policy and the lookup against the package listing dotkernel.com publishes, which is why it gets its own page rather than a row in [Reference](reference.md).

## The ladder

Stop at the first hit:

1. already in `composer.lock`
2. `dotkernel/*`
3. `laminas/*` / `mezzio/*`
4. a vetted `symfony`/`doctrine`/`psr`/`league` package
5. hand-rolled code

The rule this enforces: never name a package from memory.
A name is verified only when it appears in `composer.lock` or in the dotkernel.com listing (below).
Any other name is reported as unverified.

## The source of truth is dotkernel.com

Dotkernel publishes the support status of its open-source packages at <https://www.dotkernel.com/dotkernel-packages.json>, rebuilt daily from the GitHub organization, with a human-readable version at <https://www.dotkernel.com/dotkernel-packages-oss-lifecycle/>.
Each entry gives the package's `lifecycle` (`active`, `maintenance`, `security-only` or `archived`), its `php` constraint, and GitHub's `archived` flag.

The skill fetches the listing fresh for each question.
Nothing is generated, shipped or stored in the project, so there is nothing to refresh or git-ignore.
Fetching it needs network access and prompts the first time, being in neither `settings.json`'s `allow` nor `deny` list.
If the fetch fails, the skill calls `dotkernel/*` names that are not in `composer.lock` unverified rather than falling back to memory.

Nothing queries Packagist.
A `laminas/*`, `mezzio/*` or community package that is not already installed is reported as unverified, and confirming its maintenance status, PHP support and license is left to you.
The rule of thumb for "actively maintained" is a release in the last 12 months.

## It needs a `CLAUDE.md` block to be proactive

A skill's `description:` frontmatter only makes it *loadable* — it doesn't make Claude stop and think before naming a package unprompted.
That behavior has to be always-loaded, which means it lives in the *consuming project's* `CLAUDE.md`, not in Dotboost itself:

```markdown
## Dependency policy

Order of preference, stop at the first hit: **already in composer.lock** -> **`dotkernel/*`** ->
**`laminas/*` / `mezzio/*`** -> vetted `symfony|doctrine|psr|league` package -> hand-rolled code.

- Never name a package from memory. Verify against `composer.lock`, or the `dotkernel/*` listing
  published at <https://www.dotkernel.com/dotkernel-packages.json>. Any other name is unverified — say so.
- Never run `composer require` in an upstream Dotkernel repo. Present a proposal; the user decides.
- Consult the `dotkernel-package-status` skill before any package suggestion, including implicit
  ones ("how do I send mail from here?" is a package question).
```

Without this block pasted into the target project, the skill can still fire on an explicit package question, but a question with no package name in it (`"how do I send mail from here?"`) is much less likely to trigger it.

## When the listing is wrong

Report a wrong or stale entry against [`dotkernel/dotkernel.com`](https://github.com/dotkernel/dotkernel.com), and a wrong lifecycle value against the package's own repository, whose `OSSMETADATA` file declares it.
See [Maintaining This](../maintaining.md).
