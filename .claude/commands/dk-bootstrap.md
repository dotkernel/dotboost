---
description: Bring a new Dotkernel clone to a local install that runs
allowed-tools: Read, Grep, Glob, Bash(ls:*), Bash(test:*), Bash(php -v), Bash(php -m), Bash(composer --version), Bash(git status:*), Bash(git config --get:*)
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

I cloned a Dotkernel project.
Show me each step from here to a local install that works.

Do not run installers, migrations, fixtures or key generation yourself.
Examine the current state.
Then give me the exact commands in sequence, and tell me what each command changes.

1. **Identify the project.** Load `dotkernel-project-variants`.
   Tell me which variant this is, and how the variant changes the steps below.
2. **Environment check.** Compare the PHP version with `composer.json`.
   Check the necessary extensions, also the extensions that only the tests need.
   Check that composer is available.
3. **Dependencies.** Run `composer install`.
   Examine `scripts.post-update-cmd` and tell me what it will run.
   Some Dotkernel projects generate OAuth keys and other artefacts there.
   Never commit these files.
4. **Config files.** List each `config/**/*.dist` and `config/*.dist` file.
   Tell me which related real file is missing.
   Tell me which keys I must fill in: database connection, mail, CORS origins, base URL, documentation URL.
   Identify the test-local config specially.
   Without it, the functional tests stop in `setUp`.
5. **Database.** Tell me which engine and collation the project expects.
   Then give the migration command, then the fixtures, in that sequence.
   Give a warning about what each command does.
6. **Verify.** Start the built-in server and send a request to the entry route.
   List the routes.
   Then run the QA suite.
7. **Windows line endings.** Report `core.autocrlf` and `core.eol`.
   Report if a tracked text file has CRLF in the worktree (`git ls-files --eol`).
   If a value is wrong, give me the fix.
8. **Security tasks for later.** Tell me which demo clients and credentials I must replace.
   Tell me which keys I must not commit.
   Tell me to disable development mode before I deploy.

At the end, give a numbered list of commands that I can paste one at a time.
Mark each command that is already done.

$ARGUMENTS
