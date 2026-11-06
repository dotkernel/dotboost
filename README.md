# dotboost — Claude Code configuration for Dotkernel projects

Drop-in configuration that teaches Claude Code the conventions of any Dotkernel project —
API, Admin, Frontend, Light, Queue, or a project derived from one of them. Every skill detects the
variant first and applies the matching dialect.

This repository is not itself a Dotkernel project. Its entire payload is the `.claude/`
directory: settings, hooks, a status line, a review subagent, ten `/dk-*` commands and nineteen
skills. You install it by copying that directory into the Dotkernel project you are working on.

Maintained by Borsan Sergiu.

## Add this to your project's CLAUDE.md

dotboost ships the `dotkernel-package-status` skill, which holds the dependency policy, but a skill
`description:` is only a hint — it decides whether the skill *can* load, not whether Claude stops to
think before naming a package. The rule that makes it reach for the skill has to be always loaded,
which means it lives in your project's own `CLAUDE.md`. Paste this block there:

```markdown
## Dependency policy

Order of preference, stop at the first hit: **already in composer.lock** -> **`dotkernel/*`** ->
**`laminas/*` / `mezzio/*`** -> vetted `symfony|doctrine|psr|league` package -> hand-rolled code.

- Never name a package from memory. Verify against `composer.lock`, or the `dotkernel/*` listing
  published at <https://www.dotkernel.com/dotkernel-packages.json>. Any other name is unverified — say so.
- Never run `composer require` in an upstream Dotkernel repo. Present a proposal; the user decides.
- Consult the `dotkernel-package-status` skill before any package suggestion, including implicit
  ones ("how do I send mail from here?" is a package question).
```

Dotkernel projects also write all prose in ASD-STE100 Simplified Technical English.
The `dotkernel-writing-style` skill holds the rules, but it loads only when its description matches the task.
Paste this block into the same `CLAUDE.md` to make the rule always active:

```markdown
## Writing style

Write all prose in ASD-STE100 Simplified Technical English.
This includes chat answers, commit and tag messages, MR/PR descriptions, Markdown files, code comments and docblock descriptions.
Do not apply it to the code itself: identifiers, keywords, syntax and docblock tags stay as they are.
Load the `dotkernel-writing-style` skill before you write any of this prose.
```

Three things worth knowing about how that behaves:

- The only source for `dotkernel/*` packages is the listing **dotkernel.com publishes**, rebuilt
  daily from the GitHub organization. Claude fetches it fresh for each question; nothing is
  generated, shipped or stored in the project. It needs network access; without it Claude is
  instructed to call a package name **unverified** rather than assert it.
- Nothing queries Packagist. A `laminas/*`, `mezzio/*` or community package that is not already in
  `composer.lock` is reported as **unverified**, and confirming its maintenance status, PHP support
  and license is left to you. The rule of thumb for "actively maintained" is a release in the last
  12 months.
- Fetching the listing is in neither the allow nor the deny list in `settings.json`, so it prompts.
  That is deliberate — expect a prompt the first time.

## Install

The payload is the `.claude/` directory and it has to sit at the root of your project. Two ways to
get it there — same files either way, pick whichever suits the machine you are on.

### Clone it inside the project

```bash
cd <project>
git clone --depth 1 https://github.com/dotkernel/dotboost.git .dotboost
mkdir -p .claude
cp -r .dotboost/.claude/. .claude/
rm -rf .dotboost
```

`--depth 1` because only the current state of `main` is of any use in a target project. The clone
goes away right after the copy, so nothing nested is left for a `git add .` to trip over.

### Download the zip

No git needed, which is the point:

```bash
cd <project>
curl -L -o dotboost.zip https://github.com/dotkernel/dotboost/archive/refs/heads/main.zip
unzip -q dotboost.zip
mkdir -p .claude
cp -r dotboost-main/.claude/. .claude/
rm -rf dotboost-main dotboost.zip
```

The archive unpacks to `dotboost-main/` and does carry the dotfiles, `.claude/` included. No `unzip`
— Git Bash on Windows ships without one — then take the ZIP from the green **Code** button on the
repo page, extract it anywhere, and copy the `.claude` folder into your project root by hand.

### Then, either way

```bash
chmod +x .claude/hooks/*.sh .claude/statusline.sh
echo '.claude/settings.local.json' >> .git/info/exclude
```

Nothing here is committed with an executable bit, and a zip extracted on Windows carries no
permission bits at all. `settings.json` invokes the hooks and the status line as `bash <path>`, so
they run regardless; the `chmod` only matters when you run one of them by hand.

What lands in the project:

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

Optionally, for personal overrides that stay out of git:

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
```

The trailing `/.` copies the *contents* of the payload's `.claude/`, so it merges into a `.claude/`
the project already has instead of nesting a second one at `.claude/.claude/`. Merging still
overwrites same-named files: if the project already has its own `.claude/settings.json` or its own
`.claude/commands/`, merge by hand rather than running the `cp -r` blind.

To update later, run the whole install again over the top. Anything you changed in the project's
copy is lost, which is the reason personal changes belong in `settings.local.json`.

### Optional: markdown linting

`.claude/hooks/markdown-lint.sh` checks every `.md` file Claude writes against
`.claude/markdownlint.jsonc`. It needs `markdownlint-cli2`, which is not bundled — install it once,
yourself:

```bash
npm install -g markdownlint-cli2
```

A project-local `devDependency` works too; the hook prefers `./node_modules/.bin/markdownlint-cli2`
and falls back to the global one. Claude cannot run either install for you — the `npm` install verbs
are in the `deny` tier. Until the binary is resolvable the hook exits silently, so `.claude/` stays
drop-in for projects with no Node toolchain at all.

## What `settings.json` decides for you

It is a committed file, so it carries only what the whole team should share. One setting beyond the
guardrails:

```text
env.COMPOSER_MEMORY_LIMIT: "-1"    Composer runs without a memory ceiling
```

Personal preferences — permission mode (`permissions.defaultMode`), `theme`, `tui` and
`spinnerVerbs` — are not set here. `settings.local.json.example` carries a sample of each; copy the
ones you want into your own `settings.local.json`. Its `defaultMode: "auto"` is only an example of the
key: Claude Code does not apply `auto` from project or local settings, so if you want auto mode, set
it in `~/.claude/settings.json` instead.

The permission rules fall into four groups.

**Never read.** These are `Read` denies, not just write protection — Claude's file tools, and the
Bash file commands Claude Code recognises (`cat`, `head`, `tail`, `sed`, `tee`), cannot open them:

- `.env`, every `*.local.php`, `config/autoload/local.php`, `config/autoload/local.test.php`,
  and `data/oauth/`.

That keeps your database credentials, your OAuth signing keys and your environment secrets out of
the transcript in normal work, but it is a rule, not a sandbox: a command that reads files without
naming them (`grep -r password config/`) or a script that opens a file itself gets past it. For an
OS-level guarantee, use the sandbox described in the
[Claude Code permissions docs](https://code.claude.com/docs/en/permissions).

**Never written.** `Edit` denies, which Claude Code applies to `Write` as well:

- dependency manifests (`composer.json`, `composer.lock`, `package.json`, `package-lock.json`),
  `vendor/`, `node_modules/`, `data/`, `log/`, `public/uploads/`, anything under
  `Migration/` or `Migrations/`, and every `*.local.php`, `config/autoload/local.php` and
  `config/autoload/local.test.php`.

**Never run.** Bash denies:

- `composer require`/`remove`/`update`/`install`/`global`, the `npm`/`yarn`/`pnpm` install and
  removal verbs, `git push`, `git reset --hard`, `git clean`, `git submodule`, `rm -rf`.

**Ask first**, and **allowed outright**:

- **ask** — `doctrine-migrations`, `bin/doctrine`, `bin/cli.php`, `mysql`/`mariadb`,
  `git commit`/`add`/`checkout`/`rebase`/`merge`, `config/pipeline.php`, `config/config.php`, the
  authorization config, `phpcs.xml`/`phpstan.neon`/`phpunit.xml`, `.github/`, `CHANGELOG.md`,
  `SECURITY.md`, and the project's own `README.md`.
- **allow** — the `composer` QA scripts (`check`, `cs-check`, `cs-fix`, `static-analysis`, `test`)
  plus `clear-config-cache`, `development-status` and `dump-autoload`;
  `php ./vendor/bin/{phpcs,phpcbf,phpstan,phpunit}` (only with the `php ./` prefix — a bare
  `vendor/bin/phpunit` prompts); `markdownlint-cli2` and `./node_modules/.bin/markdownlint-cli2`;
  `php -l`, `php -v`, `php -m`; `date +%F`; read-only git (`status`, `diff`, `log`, `show`,
  `branch`, `ls-files`, `config --get`); and edits under `docs/features/` and
  `documentation/features/`.

The `ask` and `allow` tiers are personal preference. Override any of them per machine in
`.claude/settings.local.json`, which layers on top and is git-ignored — never in the shared file.

### Where the hooks are stricter than the tiers

`guard-bash.sh` refuses outright some commands `settings.json` only marks **ask**. This is
deliberate — the hook sees compound commands the permission globs cannot — but it means the prompt
you would expect from the `ask` tier never appears. You get a refusal instead:

| Command | `settings.json` says | `guard-bash.sh` does |
| --- | --- | --- |
| `git rebase` | ask | blocks |
| `doctrine-migrations migrate` / `execute` | ask | blocks |
| `fixtures:execute`, `schema:drop`, `schema:update` | ask, via `bin/doctrine` | blocks |
| `git checkout --` | ask, via `git checkout` | blocks |
| `composer development-enable` / `-disable` | — | blocks |
| `pip install`, `git filter-branch` | — | blocks |

Everything else under `ask` — commits, `mysql`, the config and QA files — prompts as documented.
If you want one of the blocked commands back, edit the hook; relaxing `settings.local.json` will
not reach it.

## Status line

`.claude/statusline.sh` renders your real account and session usage, taken from the payload Claude
Code (≥ 2.1) passes to the status line on stdin — the rate limits are the same numbers `/usage` reports:

```text
 ~/project   Opus 5.5 · high   $ 0.45   ctx ▰▱▱▱▱▱ 6%
5h ███████▍             37%  ↻ 2h 14m (16:20)   7d ▰▰▰▰▰▰▱▱▱▱ 61%
```

Line 1: directory, model and effort, session cost (Claude Code's USD estimate), and context-window
fill. Line 2: the 5h window as a 20-cell heat gradient with its reset time, and the 7d window.
Colours are 24-bit, so the terminal needs truecolor support.

Pure bash and `awk`. No `jq`, no python, no transcript scanning or guessed token budgets, so it
works in Git Bash on Windows.

Two placements, and the shipped files disagree on purpose — pick one:

- `settings.json` points at `$CLAUDE_PROJECT_DIR/.claude/statusline.sh` — the per-project copy,
  which is what you get from the install above and needs nothing further.
- `settings.local.json.example` points at `~/.claude/statusline.sh` — one shared copy for every
  project. If you prefer that, `cp .claude/statusline.sh ~/.claude/` from a project that already has
  the install, or the status line comes up empty.

## Line endings on Windows

Dotkernel repos ship `.gitattributes` with `* text eol=lf`, which governs anything git checks out.
Belt and braces, configure your client so nothing converts:

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

Already committed CRLF? Renormalise once with `git add --renormalize .`.

In PhpStorm: *Editor → Code Style → Line separator = Unix (\n)*, and *File Encodings → UTF-8*,
*Create UTF-8 files: with NO BOM*.

## Verify

Start Claude Code in the project:

```text
/help        # commands: dk-bootstrap, dk-module, dk-route, dk-trace, dk-test, dk-document,
             #           dk-check, dk-deprecate, dk-review, dk-hygiene
```

The session-start hook should open with a short briefing: which variant it detected, the root
namespace, the authorization style (flagging a guard policy that leaves unlisted routes public), and
which config files are still missing.

Skills load from their own `description:` frontmatter — there is no routing table telling Claude
which to pick. Ask *"where does a new Doctrine entity go?"*; it should reach for
`dotkernel-module-structure` rather than answering from general framework knowledge.

With the `CLAUDE.md` block in place, ask *"how do I send mail from here?"* — a question with no
package in it. It should load `dotkernel-package-status` and walk the ladder, grepping
`composer.lock` first and then fetching the dotkernel.com listing, rather than replying `dot-mail`
from memory.

Test the guardrails: ask it to edit `vendor/autoload.php` (blocked by
`guard-protected-paths.sh`) and to add a package to `composer.json` (blocked by the same hook; it
should propose the change in chat instead). Then ask it to run `cd src && composer require foo` —
`guard-bash.sh` catches installs inside compound commands, which path-based permission rules
cannot see.

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

Every skill directory holds a `SKILL.md` and nothing else.

## Feature documentation

`/dk-document` writes one markdown file per feature into the project — what it does, why, the routes
and the roles that reach them, the data added, and how to exercise it. It is the part a cleared
session cannot reconstruct from `src/`, and the reason it is a file in the repo rather than a note
in a chat.

Where it lands is detected, not assumed. Many Dotkernel repositories already carry a
`documentation/` directory — command docs, a generated `openapi.json`, Postman collections — and
the stock API ships one while derived projects vary, so the skill checks rather than inferring: it
writes to `documentation/features/` when the repo has a `documentation/` directory and to
`docs/features/` otherwise, never
a second documentation root next to an existing one. Both paths are in the `allow` tier, prose in a
docs directory being the lowest-risk write in the tree.

The frontmatter is load-bearing: `/dk-review` greps each doc's `routes:` and `handlers:` to decide
whether a new route in the diff is documented, and reports a missing or stale doc as *Should fix*.
It never writes one — that command is read-only by design, and it tells you to run `/dk-document`
instead.

The generation half is a command, so it only runs when asked. To make Claude *read* the docs before
it rebuilds something that already exists, add this to your project's `CLAUDE.md` alongside the
dependency policy block:

```markdown
## Feature docs

Before adding or changing behaviour, check `docs/features/` (or `documentation/features/`) for a doc
covering that area and read it. After the change, update that doc or write a new one with
`/dk-document`. A doc that contradicts the code is a bug in the doc.
```

The session-start hook prints the directory and a doc count, so the files are at least discoverable
without the block. The block is what makes them read.

## A note on the PostToolUse hooks

`normalize-file.sh` rewrites the file Claude just wrote (whitespace only). `php-lint.sh` and
`markdown-lint.sh` are deliberately **report-only** — no `phpcbf`, no `markdownlint --fix` — because
reformatting a file immediately after Claude writes it invalidates its in-memory copy and can break
the next targeted edit. Bulk formatting belongs at the end of a task, via `composer cs-fix` or
`/dk-check`.

Both linters skip themselves out of the way rather than failing: `php-lint.sh` when `php` is not on
`PATH`, `markdown-lint.sh` when `markdownlint-cli2` is not resolvable or
`.claude/markdownlint.jsonc` is absent. A project that has not adopted the markdown rule set sees
nothing from the hook.

If you ever see "string not found" errors on consecutive edits to one file, move
`normalize-file.sh` from `PostToolUse` to the `Stop` event so it runs once per turn instead of once
per edit.

## Verify against current docs

Claude Code's `.claude/settings.json` schema and hook event names move faster than most things. If a
permission rule or hook does not take effect, check
<https://docs.claude.com/en/docs/claude-code/overview> — in particular the glob syntax accepted by
`permissions.deny` and whether `permissions.ask` exists in your version. The hooks are the stricter
layer, since they see inside compound commands where the permission globs cannot, but they match
command text rather than parsing the shell: an unusual spelling can still get past both.

## Maintaining this

Treat the skills as living documents. When a review turns up the same mistake twice, that is a
missing line in a skill, not a Claude problem. Skill **descriptions** drive loading — if a skill is
not triggering, make its description list the words you actually type, not the words the
documentation uses.

`dotkernel-package-status` has nothing to refresh: it reads the dotkernel.com listing live. If an
entry there is wrong, report it against `dotkernel/dotkernel.com`, or a wrong lifecycle value
against the package's own repository, whose `OSSMETADATA` file declares it.

Before adapting this to a new Dotkernel project, spend an hour reading that repo and correcting
the skills against what is actually there. A skill written from framework docs rather than the
codebase produces confident wrong answers, which is worse than no skill.
