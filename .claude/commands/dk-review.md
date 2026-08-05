---
description: Pre-PR review of the working tree against Dotkernel conventions
allowed-tools: Read, Grep, Glob, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(composer cs-check), Bash(composer static-analysis)
---

Review my uncommitted changes (`git diff HEAD` plus untracked files) before I open a PR.
$ARGUMENTS

Use the `dotkernel-reviewer` agent if that keeps context cleaner. Load
`dotkernel-application-variants` first, then `dotkernel-handler-naming`,
`dotkernel-module-structure`, `dotkernel-input-validation`, `dotkernel-responses`,
`dotkernel-security`, `dotkernel-evolution-pattern`, `dotkernel-psr-standards`,
`dotkernel-core-submodule` and `dotkernel-feature-docs`.

Report findings grouped as **Blocking / Should fix / Nit**, each with file:line and a concrete
replacement. Check at minimum:

- Handler, route and authorization naming for **this** application's dialect; correct verb for the
  variant; folder mirrors the resource path.
- Registration completeness: factories, delegators, aliases, route, authorization entry,
  presentation, documentation.
- Entities and repositories only in `Core`; no application-namespace import inside `Core`.
- Contract changes to existing routes — breaking without a sunset window is blocking.
- Validation on every write path; CSRF on every form; whitelisted sort/filter; no raw SQL
  interpolation; ownership checks on user-owned resources.
- Secrets outside `*.local.php`; nothing sensitive in committed config or documentation examples.
- PSR-7 immutability, no injected `ContainerInterface`, interface type-hints.
- `declare(strict_types=1)`, imported functions, phpstan-clean types.
- No dependency-manifest changes; no edits under vendored, generated or migration paths.
- Every file UTF-8 without BOM, LF endings, trailing newline, no trailing whitespace.
- Tests present for new behaviour.
- A feature doc exists and is current for user-visible behaviour — new routes and handlers in the
  diff appear in some doc's `routes:` / `handlers:` frontmatter, and a changed contract is reflected
  there. Missing or stale is **Should fix**, not blocking. Do not write it here; tell me to run
  `/dk-document`.

End with a one-line verdict: ready / not ready, and why.
