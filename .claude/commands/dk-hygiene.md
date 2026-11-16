---
description: Find and fix encoding, line ending and whitespace problems in changed files
allowed-tools: Read, Edit, Bash(git status:*), Bash(git diff:*), Bash(git ls-files:*), Bash(file:*), Bash(grep -rlIU:*), Bash(sed:*), Bash(git config --get:*)
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

Examine the files that I changed (`git status --porcelain`) for these problems:

1. CRLF or CR line endings.
   Only LF is permitted.
2. A UTF-8 BOM (`EF BB BF`) at the start of the file.
   The BOM must not be there.
3. Bytes that are not UTF-8.
4. No newline at the end of the file.
5. Trailing whitespace on a line.
   Exception: in `.md` files, two trailing spaces are an intentional hard line break, and they must stay.
6. Hard tabs in PHP files.
   PHP files must use 4 spaces.

Find the problems without more tools:

```bash
git status --porcelain
git ls-files --eol            # expect i/lf w/lf for text files
grep -rlIU $'\r' -- src config test bin public
```

Also report my git settings, and tell me which settings are wrong for this repo:

```bash
git config --get core.autocrlf   # want false
git config --get core.eol        # want lf
git config --get core.safecrlf
```

Fix the problems that you find.
Then show me a summary of the diff.
Do not change vendored, generated or binary files (`.png`, `.jpg`, `.zip`, `.phar`, keys).

$ARGUMENTS
