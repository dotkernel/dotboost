# dotboost — Claude Code configuration for Dotkernel projects

dotboost is a drop-in configuration that teaches Claude Code the conventions of any Dotkernel project.
It supports API, Admin, Frontend, Light, Queue, and each project derived from one of them.
Each skill first detects the variant, then applies the matching dialect.

This repository is not a Dotkernel project.
Its full payload is the `.claude/` directory: settings, hooks, a status line, a review subagent, ten `/dk-*` commands and nineteen skills.
To install it, copy that directory into the Dotkernel project that you work on.

Maintained by Borsan Sergiu.

## Add this to your project's CLAUDE.md

dotboost ships the `dotkernel-package-status` skill, which holds the dependency policy.
But the `description:` of a skill is only a hint.
It decides whether the skill *can* load, not whether Claude stops to think before it names a package.
The rule that makes Claude use the skill must always be loaded, so it must be in the `CLAUDE.md` of your project.
Paste this block there:

```markdown
## Dependency policy

Use this order of preference, and stop at the first match: **already in composer.lock** -> **`dotkernel/*`** -> **`laminas/*` / `mezzio/*`** -> vetted `symfony|doctrine|psr|league` package -> hand-rolled code.

- Never name a package from memory.
  Verify it against `composer.lock`, or against the `dotkernel/*` listing published at <https://www.dotkernel.com/dotkernel-packages.json>.
  Say that any other name is unverified.
- Never run `composer require` in an upstream Dotkernel repository.
  Present a proposal.
  The user decides.
- Before you suggest a package, use the `dotkernel-package-status` skill.
  This also applies to implicit suggestions: "how do I send mail from here?" is a package question.
```

Dotkernel projects and packages also write all prose in ASD-STE100 Simplified Technical English.
The `dotkernel-writing-style` skill holds the rules, but it loads only when its description matches the task.
Paste this block into the same `CLAUDE.md` to make the rule always active:

```markdown
## Writing style

Write all prose in ASD-STE100 Simplified Technical English.
This includes chat answers, commit and tag messages, MR/PR descriptions, Markdown files, code comments, docblock descriptions, exception messages, CLI output and OpenAPI descriptions.
Do not apply it to the code itself: identifiers, keywords, syntax and docblock tags stay as they are.
Load the `dotkernel-writing-style` skill before you write any of this prose.
```

Note these three facts about the dependency policy:

- The only source for `dotkernel/*` packages is the listing that **dotkernel.com publishes**.
  The listing is rebuilt each day from the GitHub organization.
  Claude fetches a new copy of the listing for each question.
  dotboost does not generate, ship or store a copy in the project.
  The fetch needs network access.
  Without network access, the instructions tell Claude to call a package name **unverified**, and not to assert it.
- Nothing queries Packagist.
  When a `laminas/*`, `mezzio/*` or community package is not already in `composer.lock`, Claude reports it as **unverified**.
  Claude does not confirm its maintenance status, PHP support and license, so that task is yours.
  As a general rule, a package is "actively maintained" when it has a release in the last 12 months.
- Neither the allow list nor the deny list in `settings.json` contains the fetch of the listing, so Claude Code shows a prompt.
  This is intentional.
  Expect a prompt the first time.

## Install

The payload is the `.claude/` directory, and it must be at the root of your project.
There are two ways to put it there.
Both ways give the same files, so select the way that suits your machine.

### Clone it inside the project

```bash
cd <project>
git clone --depth 1 https://github.com/dotkernel/dotboost.git .dotboost
mkdir -p .claude
cp -r .dotboost/.claude/. .claude/
rm -rf .dotboost
```

The clone uses `--depth 1` because only the current state of `main` is useful in a target project.
The last command removes the clone immediately after the copy.
Thus, no nested clone stays in the project to cause a problem for `git add .`.

### Download the zip

This way does not need git, and that is its purpose:

```bash
cd <project>
curl -L -o dotboost.zip https://github.com/dotkernel/dotboost/archive/refs/heads/main.zip
unzip -q dotboost.zip
mkdir -p .claude
cp -r dotboost-main/.claude/. .claude/
rm -rf dotboost-main dotboost.zip
```

The archive extracts to `dotboost-main/`, and it contains the dotfiles, `.claude/` too.
Git Bash on Windows does not include `unzip`.
If you do not have `unzip`, download the ZIP from the green **Code** button on the repository page.
Extract it to any location.
Then copy the `.claude` folder into the root of your project manually.

### Then, either way

```bash
chmod +x .claude/hooks/*.sh .claude/statusline.sh
echo '.claude/settings.local.json' >> .git/info/exclude
```

This repository commits no file with an executable bit.
Also, a zip that you extract on Windows has no permission bits at all.
`settings.json` runs the hooks and the status line as `bash <path>`, so they run without the bits.
The `chmod` is necessary only when you run one of them manually.

These files go into the project:

```text
<project>/.claude/
├── settings.json                  permission guardrails, hook registration, status line
├── settings.local.json.example    template for personal, git-ignored overrides
├── statusline.sh                  usage, cost and context fill in the status bar
├── markdownlint.jsonc             the markdown rule set, passed to markdownlint-cli2 via --config
├── hooks/                         six bash hooks (guards, normaliser, php -l, markdownlint, briefing)
├── agents/                        the review subagent
├── commands/                      the ten /dk-* commands
└── skills/                        nineteen dotkernel-* skills
```

Optionally, make a file for personal overrides that stay out of git:

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
```

The trailing `/.` copies the *contents* of the `.claude/` directory in the payload.
Thus, the copy merges into a `.claude/` directory that the project already has.
It does not put a second directory at `.claude/.claude/`.
But the merge still overwrites the files that have the same name.
If the project already has its own `.claude/settings.json` or its own `.claude/commands/`, merge the files manually.
Do not run the `cp -r` without a check.

To update dotboost later, run the full installation again on top of the existing files.
You lose all the changes that you made in the copy in the project.
For this reason, put personal changes in `settings.local.json`.

### Optional: markdown linting

`.claude/hooks/markdown-lint.sh` checks each `.md` file that Claude writes against `.claude/markdownlint.jsonc`.
It needs `markdownlint-cli2`, which dotboost does not include.
Install it one time, yourself:

```bash
npm install -g markdownlint-cli2
```

A project-local `devDependency` also works.
The hook uses `./node_modules/.bin/markdownlint-cli2` first, and uses the global one when the local one is not available.
Claude cannot run these installations for you, because the `npm` install verbs are in the `deny` tier.
Until the hook can find the binary, it exits without output.
Thus, `.claude/` stays drop-in for projects that have no Node toolchain at all.

## What `settings.json` decides for you

`settings.json` is a committed file, so it contains only the settings that the full team should share.
It has one setting in addition to the guardrails:

```text
env.COMPOSER_MEMORY_LIMIT: "-1"    Composer runs without a memory ceiling
```

This file does not set the personal preferences: the permission mode (`permissions.defaultMode`), `theme`, `tui` and `spinnerVerbs`.
`settings.local.json.example` contains a sample of each.
Copy the samples that you want into your own `settings.local.json`.
Its `defaultMode: "auto"` is only an example of the key.
Claude Code does not apply `auto` from project settings or local settings.
If you want auto mode, set it in `~/.claude/settings.json` instead.

The permission rules have four groups.

**Never read.** These rules are `Read` denies, not only write protection.
Claude's file tools cannot open these files.
The Bash file commands that Claude Code recognises (`cat`, `head`, `tail`, `sed`, `tee`) also cannot open them:

- `.env`, every `*.local.php`, `config/autoload/local.php`, `config/autoload/local.test.php`, and `data/oauth/`.

In normal work, these rules keep your database credentials, your OAuth signing keys and your environment secrets out of the transcript.
But they are a rule, not a sandbox.
A command that reads files without their names (`grep -r password config/`) gets past the rule.
A script that opens a file itself also gets past the rule.
For a guarantee at the OS level, use the sandbox that the [Claude Code permissions docs](https://code.claude.com/docs/en/permissions) describe.

**Never written.** These rules are `Edit` denies, and Claude Code also applies them to `Write`:

- dependency manifests (`composer.json`, `composer.lock`, `package.json`, `package-lock.json`), `vendor/`, `node_modules/`, `data/`, `log/`, `public/uploads/`, anything under `Migration/` or `Migrations/`, and every `*.local.php`, `config/autoload/local.php` and `config/autoload/local.test.php`.

**Never run.** These rules are Bash denies:

- `composer require`/`remove`/`update`/`install`/`global`, the `npm`/`yarn`/`pnpm` install and removal verbs, `git push`, `git reset --hard`, `git clean`, `git submodule`, `rm -rf`.

**Ask first**, and **allowed outright**:

- **ask**: `doctrine-migrations`, `bin/doctrine`, `bin/cli.php`, `mysql`/`mariadb`, `git commit`/`add`/`checkout`/`rebase`/`merge`, `config/pipeline.php`, `config/config.php`, the authorization config, `phpcs.xml`/`phpstan.neon`/`phpunit.xml`, `.github/`, `CHANGELOG.md`, `SECURITY.md`, and the project's own `README.md`.
- **allow**:
    - the `composer` QA scripts (`check`, `cs-check`, `cs-fix`, `static-analysis`, `test`), and also `clear-config-cache`, `development-status` and `dump-autoload`
    - `php ./vendor/bin/{phpcs,phpcbf,phpstan,phpunit}`, only with the `php ./` prefix.
      A bare `vendor/bin/phpunit` prompts.
    - `markdownlint-cli2` and `./node_modules/.bin/markdownlint-cli2`
    - `php -l`, `php -v`, `php -m`
    - `date +%F`
    - read-only git (`status`, `diff`, `log`, `show`, `branch`, `ls-files`, `config --get`)
    - edits under `docs/features/` and `documentation/features/`

The `ask` and `allow` tiers are a personal preference.
To override one of them on a machine, use `.claude/settings.local.json`.
This file layers on top of the shared file, and git ignores it.
Never override the tiers in the shared file.

### Where the hooks are stricter than the tiers

`guard-bash.sh` refuses some commands that `settings.json` only marks as **ask**.
This is intentional, because the hook sees compound commands that the permission globs cannot see.
But as a result, the prompt that you expect from the `ask` tier never appears.
You get a refusal instead:

| Command | `settings.json` says | `guard-bash.sh` does |
| --- | --- | --- |
| `git rebase` | ask | blocks |
| `doctrine-migrations migrate` / `execute` | ask | blocks |
| `fixtures:execute`, `schema:drop`, `schema:update` | ask, via `bin/doctrine` | blocks |
| `git checkout --` | ask, via `git checkout` | blocks |
| `composer development-enable` / `-disable` | — | blocks |
| `pip install`, `git filter-branch` | — | blocks |

All other items under `ask` (commits, `mysql`, the config files and the QA files) prompt as documented.
To allow one of the blocked commands again, edit the hook.
A less strict `settings.local.json` does not change the behavior of the hook.

## Status line

`.claude/statusline.sh` shows your real account usage and session usage.
It reads this data from the payload that Claude Code (≥ 2.1) sends to the status line on stdin.
The rate limits are the same numbers that `/usage` reports:

```text
 ~/project   Opus 5.5 · high   $ 0.45   ctx ▰▱▱▱▱▱ 6%
5h ███████▍             37%  ↻ 2h 14m (16:20)   7d ▰▰▰▰▰▰▱▱▱▱ 61%
```

Line 1 shows the directory, the model and effort, the session cost (the USD estimate from Claude Code) and the fill of the context window.
Line 2 shows the 5h window as a 20-cell heat gradient with its reset time, and the 7d window.
The colours are 24-bit, so the terminal must support truecolor.

The script uses only bash and `awk`.
It does not use `jq` or python, it does not scan the transcript, and it does not guess token budgets.
Thus, it works in Git Bash on Windows.

There are two locations for the script, and the shipped files intentionally use different locations.
Select one:

- `settings.json` points at `$CLAUDE_PROJECT_DIR/.claude/statusline.sh`, the copy in each project.
  The installation above gives you this copy, and it needs no more steps.
- `settings.local.json.example` points at `~/.claude/statusline.sh`, one shared copy for all projects.
  If you prefer that location, run `cp .claude/statusline.sh ~/.claude/` from a project that already has the installation.
  If you do not, the status line is empty.

## Line endings on Windows

Dotkernel repositories ship `.gitattributes` with `* text eol=lf`.
This setting controls all the files that git checks out.
As an additional safety measure, configure your client so that it does not convert line endings:

```bash
git config core.autocrlf false
git config core.eol lf
git config core.safecrlf warn
```

Verify:

```bash
git config --get core.autocrlf              # false
git ls-files --eol | grep -v 'w/lf' | head  # nothing for text files
```

If you already committed CRLF line endings, renormalise them one time with `git add --renormalize .`.

In PhpStorm, set *Editor → Code Style → Line separator = Unix (\n)*, *File Encodings → UTF-8* and *Create UTF-8 files: with NO BOM*.

## Verify

Start Claude Code in the project:

```text
/help        # commands: dk-bootstrap, dk-module, dk-route, dk-trace, dk-test, dk-document,
             #           dk-check, dk-deprecate, dk-review, dk-hygiene
```

The session-start hook should start with a short briefing.
The briefing shows the detected variant, the root namespace and the authorization style.
It flags a guard policy that leaves unlisted routes public.
It also shows which config files are still missing.

Each skill loads because of its own `description:` frontmatter.
No routing table tells Claude which skill to select.
Ask *"where does a new Doctrine entity go?"*.
Claude should load `dotkernel-module-structure`, and not answer from general framework knowledge.

When the `CLAUDE.md` block is in place, ask *"how do I send mail from here?"*.
This question does not name a package.
Claude should load `dotkernel-package-status` and follow the ladder.
It should grep `composer.lock` first, and then fetch the dotkernel.com listing.
It should not reply `dot-mail` from memory.

Test the guardrails:

1. Ask Claude to edit `vendor/autoload.php`.
   `guard-protected-paths.sh` blocks the edit.
2. Ask Claude to add a package to `composer.json`.
   The same hook blocks the edit, and Claude should propose the change in chat instead.
3. Then ask Claude to run `cd src && composer require foo`.
   `guard-bash.sh` catches installs inside compound commands, which path-based permission rules cannot see.

## What's here

```text
README.md                                       this file
.gitignore                                      IDE directories and settings.local.json

.claude/settings.json                           permission guardrails + hook registration
.claude/settings.local.json.example             template for personal, git-ignored overrides
.claude/statusline.sh                           usage, cost and context fill in the status bar
.claude/markdownlint.jsonc                      markdown rule set for markdown-lint.sh (--config)

.claude/hooks/guard-protected-paths.sh          PreToolUse (Edit/Write): blocks vendor/, node_modules/,
                                                migrations, data/cache|lock|oauth/, log/,
                                                public/uploads/, dependency manifests, tool caches,
                                                .git/ internals, and binary or key material
                                                (*.png, *.zip, *.phar, *.key, *.pem). A blocked
                                                *.local.php edit is refused with a pointer to its
                                                .dist template
.claude/hooks/guard-bash.sh                     PreToolUse (Bash): blocks installs, destructive git,
                                                DB-mutating commands and development-mode toggles,
                                                including inside compound commands. Quoted
                                                arguments, comments and heredoc bodies count as data
.claude/hooks/normalize-file.sh                 PostToolUse: BOM, CRLF, trailing whitespace, final
                                                newline. Skips whitespace stripping on .md, where two
                                                trailing spaces are a hard line break
.claude/hooks/php-lint.sh                       PostToolUse: php -l on every edited PHP file
.claude/hooks/markdown-lint.sh                  PostToolUse: markdownlint-cli2 on every edited .md
                                                file. Silent no-op unless markdownlint-cli2 is
                                                installed
.claude/hooks/session-start.sh                  SessionStart: variant detection, setup gaps, CRLF warning

.claude/agents/dotkernel-reviewer.md            review subagent (keeps the main context clean)

.claude/commands/dk-bootstrap.md                fresh clone → running install
.claude/commands/dk-module.md                   plan a new module (dot-maker first)
.claude/commands/dk-route.md                    add a fully wired endpoint or page
.claude/commands/dk-trace.md                    trace a request through pipeline → handler → response
.claude/commands/dk-test.md                     write and run tests
.claude/commands/dk-document.md                 write or update a feature doc
.claude/commands/dk-check.md                    run and fix the QA gate
.claude/commands/dk-deprecate.md                evolution-pattern breaking change
.claude/commands/dk-review.md                   pre-PR convention review
.claude/commands/dk-hygiene.md                  encoding / line-ending audit

.claude/skills/dotkernel-project-variants/       detect API vs Admin vs Frontend vs Light vs Queue
.claude/skills/dotkernel-module-structure/       where code goes, application module vs Core, wiring
.claude/skills/dotkernel-handler-naming/         both naming dialects, routes, authorization keys
.claude/skills/dotkernel-api-endpoint/           API-only endpoint rules and the end-to-end checklist
.claude/skills/dotkernel-doctrine-entities/      entities, enums + DBAL types, repositories, migrations
.claude/skills/dotkernel-input-validation/       InputFilters, Inputs, forms, CSRF, query whitelisting
.claude/skills/dotkernel-responses/              HAL and collections, or templates and redirects; errors
.claude/skills/dotkernel-openapi/                swagger-php attributes, for projects that publish OpenAPI
.claude/skills/dotkernel-feature-docs/           feature docs: template, where they live, staleness
.claude/skills/dotkernel-testing/                unit + functional patterns, test config, coverage matrix
.claude/skills/dotkernel-evolution-pattern/      sunset headers instead of versioning
.claude/skills/dotkernel-security/               auth, authorization, secrets, CORS, dependencies
.claude/skills/dotkernel-dot-maker/              composer make … and the manual steps after it
.claude/skills/dotkernel-core-submodule/         Core layering rules and git submodule mechanics
.claude/skills/dotkernel-psr-standards/          PSR-1/3/4/6/7/11/12/15/16/17 as applied here
.claude/skills/dotkernel-qa-gate/                cs-check, static analysis, tests, forbidden "fixes"
.claude/skills/dotkernel-troubleshooting/        symptom → cause table
.claude/skills/dotkernel-package-status/         the dependency ladder (installed → dotkernel/* →
                                                 laminas → vetted community → hand-rolled), proposal
                                                 format, and dotkernel/* lifecycle + PHP support
                                                 from the dotkernel.com listing
```

Each skill directory contains a `SKILL.md` and nothing else.

## Feature documentation

`/dk-document` writes one markdown file for each feature into the project.
The file tells what the feature does and why.
It also gives the routes, the roles that can access them, the added data, and how to try the feature.
A cleared session cannot get this information again from `src/`.
For this reason, it is a file in the repository and not a note in a chat.

The skill detects the location of the file, and does not assume it.
Many Dotkernel repositories already have a `documentation/` directory, for example with command docs, a generated `openapi.json` and Postman collections.
The stock API ships one, but derived projects are different from each other.
Thus, the skill checks the repository and does not infer the location:

- When the repository has a `documentation/` directory, the skill writes to `documentation/features/`.
- Otherwise, it writes to `docs/features/`.
- It never makes a second documentation root next to an existing one.

Both paths are in the `allow` tier, because prose in a docs directory is the write with the lowest risk in the tree.

The frontmatter is necessary for the review.
`/dk-review` greps the `routes:` and `handlers:` of each doc to decide whether a doc covers a new route in the diff.
It reports a missing or stale doc as *Should fix*.
`/dk-review` never writes a doc, because that command is read-only by design.
It tells you to run `/dk-document` instead.

The part that writes the docs is a command, so it runs only when you ask for it.
You can also make Claude *read* the docs before it rebuilds something that already exists.
To do this, add this block to the `CLAUDE.md` of your project, next to the dependency policy block:

```markdown
## Feature docs

Before you add or change behaviour, examine `docs/features/` (or `documentation/features/`) for a doc about that area.
If a doc exists, read it.
After the change, update that doc, or write a new doc with `/dk-document`.
A doc that does not agree with the code is a bug in the doc.
```

The session-start hook shows the directory and the number of docs.
Thus, the files are at least easy to find without the block.
The block is what makes Claude read them.

## A note on the PostToolUse hooks

`normalize-file.sh` rewrites the file that Claude wrote last, and it changes only whitespace.
`php-lint.sh` and `markdown-lint.sh` are intentionally **report-only**.
They do not run `phpcbf` or `markdownlint --fix`.
The reason: when a hook reformats a file immediately after Claude writes it, the copy in Claude's memory no longer matches the file.
This can break the next targeted edit.
Do bulk formatting at the end of a task, with `composer cs-fix` or `/dk-check`.

When a linter cannot run, it skips its check and does not fail.
`php-lint.sh` skips its check when `php` is not on `PATH`.
`markdown-lint.sh` skips its check when it cannot find `markdownlint-cli2`, or when `.claude/markdownlint.jsonc` is absent.
A project that does not use the markdown rule set gets no output from the hook.

If you see "string not found" errors on consecutive edits to one file, move `normalize-file.sh` from `PostToolUse` to the `Stop` event.
Then it runs one time per turn, not one time per edit.

## Verify against current docs

The `.claude/settings.json` schema and the hook event names of Claude Code change more quickly than most things.
If a permission rule or a hook has no effect, check <https://docs.claude.com/en/docs/claude-code/overview>.
Specially, check the glob syntax that `permissions.deny` accepts, and whether your version has `permissions.ask`.
The hooks are the stricter layer, because they see inside compound commands and the permission globs cannot.
But the hooks match the command text, and they do not parse the shell.
Thus, an unusual spelling can still get past the two layers.

## Maintaining this

Treat the skills as documents that change over time.
When a review finds the same mistake two times, a skill is missing a line.
It is not a problem in Claude.
Skill **descriptions** control which skill loads.
If a skill does not trigger, write its description with the words that you actually type, not with the words of the documentation.

`dotkernel-package-status` has nothing to refresh, because it reads the dotkernel.com listing live.
If an entry in the listing is wrong, report it against `dotkernel/dotkernel.com`.
If a lifecycle value is wrong, report it against the repository of the package, because its `OSSMETADATA` file declares the value.

Before you adapt dotboost to a new Dotkernel project, use an hour to read that repository.
In that hour, correct the skills against what the repository actually contains.
A skill that comes from framework docs and not from the codebase gives wrong answers with confidence.
Such a skill is worse than no skill.
