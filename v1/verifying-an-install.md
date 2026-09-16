# Verifying an Install

There is no CI in this repository — dotboost is configuration, not code with a build step — so this manual smoke test is the closest thing to a test suite.
Run it after installing into a project.

## Skill routing

Ask *"where does a new Doctrine entity go?"* — it should reach for `dotkernel-module-structure` rather than answering from general framework knowledge.

## The `CLAUDE.md` block

With the dependency-policy block in place (see [Getting Started](getting-started.md)), ask *"how do I send mail from here?"* — a question with no package name in it.
It should load `dependency-policy` and walk the ladder, grepping `composer.lock` first and then the `dotkernel/*` manifest (generating it if absent), rather than replying with a package name from memory.
See [Dependency Policy](skills/dependency-policy.md).

## Guardrails

- Ask it to edit `vendor/autoload.php` — blocked by `guard-protected-paths.sh`.
- Ask it to add a package to `composer.json` — blocked by the same hook; it should propose the change in chat instead of writing it.
- Ask it to run `cd src && composer require foo` — `guard-bash.sh` should catch the install even though it's inside a compound command, which path-based permission rules alone cannot see.
  See [Guardrails vs. Permissions](hooks/guardrails-vs-permissions.md).

## Verify against current docs

Claude Code's own `settings.json` schema and hook event names move faster than most things in this repo.
If a permission rule or hook doesn't take effect, check the current Claude Code docs — in particular the glob syntax accepted by `permissions.deny` and whether `permissions.ask` exists in your installed version.
Treat the hooks as the reliable layer and the permission rules as the convenient one when the two seem to disagree.
