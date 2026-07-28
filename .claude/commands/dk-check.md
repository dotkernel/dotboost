---
description: Run the full QA gate and fix what it reports
allowed-tools: Read, Grep, Glob, Edit, Bash(composer cs-fix), Bash(composer cs-check), Bash(composer static-analysis), Bash(composer test), Bash(composer check), Bash(git status:*), Bash(git diff:*)
---

Load `dotkernel-qa-gate`. Confirm the script names in `composer.json` before running them.

1. `composer cs-fix`
2. `composer cs-check`
3. `composer static-analysis`
4. `composer test`

Fix every failure properly. No `phpcs.xml` exclusions, no `// phpcs:ignore`, no
`@phpstan-ignore-*`, no level reductions, no skipped tests, no deleted assertions — if you believe
a rule genuinely does not apply, stop and explain instead.

Re-run `composer check` at the end and paste the real output. If anything is still red, say so
plainly rather than summarising it away.

$ARGUMENTS
