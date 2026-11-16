---
description: Review the working tree against Dotkernel conventions before a PR
allowed-tools: Read, Grep, Glob, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(composer cs-check), Bash(composer static-analysis)
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

Review my uncommitted changes (`git diff HEAD` and the untracked files) before I open a PR.
$ARGUMENTS

You can use the `dotkernel-reviewer` agent if that keeps the context cleaner.
Load `dotkernel-project-variants` first.
Then load `dotkernel-handler-naming`, `dotkernel-module-structure`, `dotkernel-input-validation`, `dotkernel-responses`, `dotkernel-security`, `dotkernel-evolution-pattern`, `dotkernel-psr-standards`, `dotkernel-core-submodule`, `dotkernel-qa-gate`, `dotkernel-feature-docs` and `dotkernel-writing-style`.
In an API project, also load `dotkernel-api-endpoint`.

Put the findings in three groups: **Blocking / Should fix / Nit**.
Give each finding with file:line and a concrete replacement.
Check at minimum these items:

- Handler, route and authorization naming for the dialect of **this** project.
  The verb is correct for the variant.
  The folder mirrors the resource path.
- Registration is complete: factories, delegators, aliases, route, authorization entry, presentation, documentation.
- Entities and repositories are only in `Core` (API and Admin) or inside the module that owns them (Frontend).
  No project-namespace import is inside `Core`.
- Contract changes to existing routes.
  A breaking change without a sunset window is blocking.
- Each write path has validation.
  Each form has CSRF.
  Sort and filter values are whitelisted.
  No value is interpolated into raw SQL.
  User-owned resources have ownership checks.
- Secrets are outside `*.local.php`.
  Committed config and documentation examples contain no sensitive data.
- PSR-7 immutability, no injected `ContainerInterface`, interface type-hints.
- `declare(strict_types=1)`, imported functions, phpstan-clean types.
- No changes to the dependency manifest.
  No edits under vendored, generated or migration paths.
- Each file is UTF-8 without BOM, with LF endings, a trailing newline and no trailing whitespace.
  Exception: in `.md`, two trailing spaces are a hard line break, and they stay.
- Tests exist for new behaviour.
- A feature doc exists and is current for behaviour that users can see.
  New routes and handlers in the diff appear in the `routes:` / `handlers:` frontmatter of a doc.
  That frontmatter also shows a changed contract.
  A missing or stale doc is **Should fix**, not blocking.
  Do not write the doc here.
  Tell me to run `/dk-document`.
- Prose follows ASD-STE100, at the level from `dotkernel-writing-style`.
  Check only the lines that the diff adds or changes, and the commit messages on this branch that are not on the default branch.
  Prose includes comments, docblock descriptions, Markdown prose, exception and error messages, CLI output and OpenAPI descriptions.
  Look for instructions longer than 20 words, descriptions longer than 25 words, the passive voice, semicolons, phrasal verbs, and more than one instruction in a sentence.
  A finding is **Should fix**, with the rewritten sentence as the replacement.
  Do not report the code itself.

At the end, give a verdict of one line: ready / not ready, and the reason.
