# Verifying an Install

This repository has no test CI.
The only workflow, `.github/workflows/docs-build.yml`, builds this documentation.
Dotboost is configuration, not code with a build step.
Thus this manual smoke test is the nearest thing to a test suite.
Run it after you install Dotboost into a project.

## Skill routing

Ask *"where does a new Doctrine entity go?"*.
Claude should use `dotkernel-module-structure`, and not answer from general framework knowledge.

## The `CLAUDE.md` block

Make sure that the project has the dependency policy block (see [Getting Started](getting-started.md)).
Then ask *"how do I send mail from here?"*, a question with no package name in it.
Claude should load `dotkernel-package-status` and go through the ladder.
It should first grep `composer.lock`, then fetch the dotkernel.com listing.
It should not reply with a package name from memory.
See [Package Status](skills/dotkernel-package-status.md).

## Guardrails

- Ask Claude to edit `vendor/autoload.php`.
  `guard-protected-paths.sh` blocks the edit.
- Ask Claude to add a package to `composer.json`.
  The same hook blocks the edit.
  Claude should propose the change in chat and not write it.
- Ask Claude to run `cd src && composer require foo`.
  `guard-bash.sh` should stop the install, although it is inside a compound command.
  Path-based permission rules alone cannot see this.
  See [Guardrails vs. Permissions](hooks/guardrails-vs-permissions.md).

## Verify against current docs

The `settings.json` schema and the hook event names of Claude Code change faster than most things in this repo.
If a permission rule or a hook has no effect, read the current Claude Code docs.
In particular, check the glob syntax that `permissions.deny` accepts, and whether your installed version has `permissions.ask`.
When the two layers seem to disagree, the hooks are the stricter layer.
But neither layer is a sandbox.
The hooks match the command text and do not parse the shell, so an unusual spelling can still get past them.
