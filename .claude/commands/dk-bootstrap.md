---
description: Take a fresh Dotkernel clone to a running local install
allowed-tools: Read, Grep, Glob, Bash(ls:*), Bash(test:*), Bash(php -v), Bash(php -m), Bash(composer --version), Bash(git status:*), Bash(git config --get:*)
---

I have just cloned a Dotkernel project. Walk me from here to a working local install.

Do not run installers, migrations, fixtures or key generation yourself — inspect state, then give
me the exact commands in order and say what each one changes.

1. **Identify the application.** Load `dotkernel-application-variants` and tell me which variant
   this is and what that implies for the steps below.
2. **Environment check.** PHP version against `composer.json`, required extensions (including any
   needed only by tests), composer availability.
3. **Dependencies.** `composer install`. Check `scripts.post-update-cmd` and tell me what it will
   run — some Dotkernel apps generate OAuth keys and other artefacts there, which must never be
   committed.
4. **Config files.** List every `config/**/*.dist` and `config/*.dist`, report which corresponding
   real file is missing, and tell me which keys I need to fill in — database connection, mail,
   CORS origins, base URL, documentation URL. Flag the test-local config specifically: without it
   the functional tests abort in `setUp`.
5. **Database.** Which engine and collation the project expects, then the migration command, then
   fixtures, in that order, with a warning about what each does.
6. **Verify.** Start the built-in server, hit the entry route, list the routes, then run the QA
   suite.
7. **Windows line endings.** Report `core.autocrlf` and `core.eol`, and whether any tracked text
   file has CRLF in the worktree (`git ls-files --eol`). Give me the fix if it is wrong.
8. **Security follow-ups for later.** Demo clients and credentials to replace, keys not to commit,
   development mode to disable before deploying.

Finish with a numbered command list I can paste one at a time, marking anything already done.

$ARGUMENTS
