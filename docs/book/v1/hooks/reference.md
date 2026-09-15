# Reference

| Hook | Event | What it does |
| --- | --- | --- |
| `guard-protected-paths.sh` | `PreToolUse` (Edit/Write) | Blocks writes to `vendor/`, `node_modules/`, migrations, `data/cache\|lock\|oauth/`, `log/`, `public/uploads/`, dependency manifests, tool caches, `.git/` internals, and binary or key material (`*.png`, `*.zip`, `*.phar`, `*.key`, `*.pem`). Redirects a blocked `*.local.php` edit to its `.dist` template instead of just refusing |
| `guard-bash.sh` | `PreToolUse` (Bash) | Blocks installs, destructive git, DB-mutating commands and development-mode toggles — including when they appear inside a compound command, which permission globs can't see into |
| `normalize-file.sh` | `PostToolUse` | Fixes BOM, CRLF, trailing whitespace, and final newline on the file just written. Skips whitespace-stripping on `.md`, where two trailing spaces are a deliberate hard line break |
| `php-lint.sh` | `PostToolUse` | Runs `php -l` on every edited PHP file. Report-only; skips itself if `php` isn't on `PATH` |
| `markdown-lint.sh` | `PostToolUse` | Runs `markdownlint-cli2` against `.claude/markdownlint.jsonc` on every edited `.md` file. Report-only; silent no-op if the binary isn't resolvable or the config is absent |
| `session-start.sh` | `SessionStart` | Prints a briefing: detected application variant, root namespace, authorization style, current branch, and which config files are still missing. Also warns about CRLF line endings |

See [Guardrails vs. Permissions](guardrails-vs-permissions.md) for commands where `guard-bash.sh` is stricter than the `ask` tier implies.
See [Introduction](introduction.md#failure-mode-consecutive-edits-to-one-file) for the one known `normalize-file.sh` failure mode.
