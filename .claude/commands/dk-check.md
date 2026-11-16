---
description: Run the full QA gate and fix the problems that it reports
allowed-tools: Read, Grep, Glob, Edit, Bash(composer cs-fix), Bash(composer cs-check), Bash(composer static-analysis), Bash(composer test), Bash(composer check), Bash(git status:*), Bash(git diff:*)
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

Load `dotkernel-qa-gate`.
Before you run the scripts, make sure that their names in `composer.json` are correct.

1. `composer cs-fix`
2. `composer cs-check`
3. `composer static-analysis`
4. `composer test`

Fix each failure correctly.
Do not add `phpcs.xml` exclusions or `// phpcs:ignore`.
Do not add `@phpstan-ignore-*`.
Do not decrease the level.
Do not skip tests, and do not delete assertions.
If you think that a rule really does not apply, stop and explain why.

At the end, run `composer check` again and paste the real output.
If a check still fails, say so clearly.
Do not hide the failure in a summary.

$ARGUMENTS
