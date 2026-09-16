# Introduction

A hook is a bash script registered in `settings.json` against a Claude Code lifecycle event.
dotboost uses three events:

- **`SessionStart`** — runs once when a session begins.
- **`PreToolUse`** — runs before a tool call, matched against `Edit`/`Write`/`MultiEdit`/`NotebookEdit` or `Bash`; can block the call.
- **`PostToolUse`** — runs after a tool call, matched against `Edit`/`Write`/`MultiEdit`; cannot undo the call, only report on or normalize its result.

## Report-only vs. blocking

The two `PreToolUse` hooks (`guard-protected-paths.sh`, `guard-bash.sh`) are guards: they refuse the call outright.
The `PostToolUse` hooks split differently — `normalize-file.sh` silently fixes whitespace, while `php-lint.sh` and `markdown-lint.sh` are deliberately **report-only**.
Neither runs `phpcbf` nor `markdownlint --fix`, because reformatting a file immediately after Claude writes it invalidates its in-memory copy and can break the next targeted edit in the same turn.
Bulk formatting belongs at the end of a task, via `composer cs-fix` or `/dk-check`.

Full behavior of each hook is in [Reference](reference.md).
For the cases where a hook blocks something the permission tiers only mark `ask`, see [Guardrails vs. Permissions](guardrails-vs-permissions.md).

## Failure mode: consecutive edits to one file

If you see "string not found" errors on consecutive edits to the same file, it's usually `normalize-file.sh` rewriting the file between edits and invalidating Claude's in-memory copy.
Move it from `PostToolUse` to the `Stop` event so it runs once per turn instead of once per edit.
