---
description: Verify and fix encoding, line endings and whitespace across changed files
allowed-tools: Read, Bash(git status:*), Bash(git diff:*), Bash(git ls-files:*), Bash(file:*), Bash(grep:*), Bash(sed:*), Bash(git config --get:*)
---

Check the files I have changed (`git status --porcelain`) for:

1. CRLF or CR line endings — must be LF only.
2. A UTF-8 BOM (`EF BB BF`) at the start of the file — must not be present.
3. Non-UTF-8 bytes.
4. Missing trailing newline at end of file.
5. Trailing whitespace on any line.
6. Hard tabs in PHP files (must be 4 spaces).

Detection without extra tooling:

```bash
git status --porcelain
git ls-files --eol            # expect i/lf w/lf for text files
grep -rlIU $'\r' -- src config test bin public
```

Also report my git settings and flag anything wrong for this repo:

```bash
git config --get core.autocrlf   # want false
git config --get core.eol        # want lf
git config --get core.safecrlf
```

Fix what you find, then show me a diff summary. Do not touch anything vendored, generated, or
binary (`.png`, `.jpg`, `.zip`, `.phar`, keys).

$ARGUMENTS
