# Introduction

A hook is a bash script that `settings.json` registers for a Claude Code lifecycle event.
Dotboost uses three events:

- **`SessionStart`**: runs when a session starts or resumes, and again after `/clear` or compaction.
- **`PreToolUse`**: runs before a tool call that matches `Edit`/`Write`/`MultiEdit`/`NotebookEdit` or `Bash`.
  It can block the call.
- **`PostToolUse`**: runs after a tool call that matches `Edit`/`Write`/`MultiEdit`.
  It cannot undo the call.
  It can only report on the result or normalize the result.

## Report-only vs. blocking

The two `PreToolUse` hooks (`guard-protected-paths.sh`, `guard-bash.sh`) are guards.
They refuse the call.
The `PostToolUse` hooks are different.
`normalize-file.sh` fixes whitespace and does not show a message.
`php-lint.sh` and `markdown-lint.sh` are **report-only** on purpose.
They do not run `phpcbf` or `markdownlint --fix`.
When a hook formats a file immediately after Claude writes it, Claude's copy of the file in memory becomes incorrect.
Then the next targeted edit in the same turn can fail.
Do the bulk formatting at the end of a task, with `composer cs-fix` or `/dk-check`.

[Reference](reference.md) gives the full behavior of each hook.
In some cases, a hook blocks a command that the permission tiers only mark `ask`.
For these cases, see [Guardrails vs. Permissions](guardrails-vs-permissions.md).

## Failure mode: consecutive edits to one file

You can see "string not found" errors on consecutive edits to the same file.
The usual cause is `normalize-file.sh`.
It writes the file again between edits, and Claude's copy in memory becomes incorrect.
Move the hook from `PostToolUse` to the `Stop` event.
Then it runs one time for each turn, not one time for each edit.
