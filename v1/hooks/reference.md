# Reference

| Hook | Event | What it does |
| --- | --- | --- |
| `guard-protected-paths.sh` | `PreToolUse` (Edit/Write) | Blocks writes to `vendor/`, `node_modules/`, migrations, `data/cache\|lock\|oauth/`, `log/`, `public/uploads/`, dependency manifests, tool caches, `.git/` internals, and binary or key material (`*.png`, `*.zip`, `*.phar`, `*.key`, `*.pem`). Refuses a `*.local.php` edit with a message that points to its `.dist` template. Claude can edit the template, and the user applies it |
| `guard-bash.sh` | `PreToolUse` (Bash) | Blocks installs, destructive git commands, commands that change the database, and development-mode toggles. It also blocks them inside a compound command, which permission globs cannot see into. Quoted arguments, comments and heredoc bodies are data, so `grep "rm -rf" docs/` runs. The hook still checks the script after a `-c` option, the arguments of `eval`, `ssh` and `watch`, and a heredoc that goes to a shell. It matches the command text and does not parse the shell, so an unusual spelling can still get past it |
| `normalize-file.sh` | `PostToolUse` | Fixes BOM, CRLF, trailing whitespace, and the final newline in the file that Claude wrote. Does not remove whitespace in `.md` files, where two trailing spaces are an intentional hard line break |
| `php-lint.sh` | `PostToolUse` | Runs `php -l` on each edited PHP file. Report-only. Does nothing if `php` is not on `PATH` |
| `markdown-lint.sh` | `PostToolUse` | Runs `markdownlint-cli2` with `.claude/markdownlint.jsonc` on each edited `.md` file. Report-only. Does nothing and shows no message if it cannot find the binary or the config |
| `session-start.sh` | `SessionStart` | Prints a briefing: the detected project variant, the root namespace, the authorization style, and the config files that are still missing. It flags a guard policy that makes unlisted routes public. It also warns about CRLF line endings |

See [Guardrails vs. Permissions](guardrails-vs-permissions.md) for commands where `guard-bash.sh` is stricter than the `ask` tier.
See [Introduction](introduction.md#failure-mode-consecutive-edits-to-one-file) for the one known failure mode of `normalize-file.sh`.
