# dotboost — Claude Code configuration for Dotkernel projects

Drop-in configuration that teaches Claude Code the conventions of any Dotkernel application —
API, Admin, Frontend, Light, Queue, or a project derived from one of them. Every skill detects the
variant first and applies the matching dialect.

This repository is not itself a Dotkernel application. Its entire payload is the `.claude/`
directory: settings, hooks, a status line, a review subagent, ten `/dk-*` commands and seventeen
skills. You install it by copying that directory into the Dotkernel project you are working on.

Maintained by Borsan Sergiu.

## Add this to your project's CLAUDE.md

dotboost ships the `dependency-policy` skill, but a skill `description:` is only a hint — it decides
whether the skill *can* load, not whether Claude stops to think before naming a package. The rule
that makes it reach for the skill has to be always loaded, which means it lives in your project's
own `CLAUDE.md`. Paste this block there:

```markdown
## Dependency policy

Order of preference, stop at the first hit: **already in composer.lock** -> **`dotkernel/*`** ->
**`laminas/*` / `mezzio/*`** -> vetted `symfony|doctrine|psr|league` package -> hand-rolled code.

- Never name a package from memory. Verify against `composer.lock`, or
  `skills/dependency-policy/references/dotkernel-packages.json`, or `composer show <pkg> --available`.
- Never run `composer require` in an upstream Dotkernel repo. Present a proposal; the user decides.
- Consult the `dependency-policy` skill before any package suggestion, including implicit ones
  ("how do I send mail from here?" is a package question).
```

Three things worth knowing about how that behaves:

- The `dotkernel/*` manifest is **generated on first use, not shipped**. The skill tells Claude to
  regenerate it when missing, so the first package question runs
  `.claude/skills/dependency-policy/scripts/sync-dotkernel-packages.sh` itself. It needs `curl`, `jq`
  and network; without them Claude is instructed to call a package name **unverified** rather than
  assert it.
- Neither that script nor `composer show <pkg> --available` appears in the allow or the deny list in
  `settings.json`, so both prompt. That is deliberate — expect a prompt the first time.
- The paths in the block are relative to `.claude/`, which is how the skill resolves them.

## Install

The payload is the `.claude/` directory and it has to sit at the root of your project. Two ways to
get it there — same files either way, pick whichever suits the machine you are on.

### Clone it inside the project

```bash
cd <project>
git clone --depth 1 https://github.com/dotkernel/dotboost.git .dotboost
cp -r .dotboost/.claude .claude
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
cp -r dotboost-main/.claude .claude
rm -rf dotboost-main dotboost.zip
```

The archive unpacks to `dotboost-main/` and does carry the dotfiles, `.claude/` included. No `unzip`
— Git Bash on Windows ships without one — then take the ZIP from the green **Code** button on the
repo page, extract it anywhere, and copy the `.claude` folder into your project root by hand.

### Then, either way

```bash
chmod +x .claude/hooks/*.sh .claude/statusline.sh \
         .claude/skills/dependency-policy/scripts/*.sh
echo '.claude/settings.local.json' >> .git/info/exclude
```

Nothing here is committed with an executable bit, and a zip extracted on Windows carries no
permission bits at all. `settings.json` invokes the hooks and the status line as `bash <path>`, so
those run regardless; the `dependency-policy` sync script is the one called by its own name, so
`chmod` it and be done.

What lands in the project:

```
<project>/.claude/
├── settings.json                  permission guardrails, hook registration, status line
├── settings.local.json.example    template for personal, git-ignored overrides
├── statusline.sh                  5h / 7d account usage in the status bar
├── hooks/                         five bash hooks (guards, normaliser, php -l, briefing)
├── agents/                        the review subagent
├── commands/                      the nine /dk-* commands
└── skills/                        sixteen skills: fifteen dotkernel-* plus dependency-policy
```

Optionally, for personal overrides that stay out of git:

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
```

If the project already has its own `.claude/settings.json` or its own `.claude/commands/`, merge
by hand rather than running the `cp -r` blind — same-named files are overwritten.

To update later, run the whole install again over the top. Anything you changed in the project's
copy is lost, which is the reason personal changes belong in `settings.local.json`.

## What `settings.json` decides for you

It is a committed file carrying opinions, not just guardrails. Know what you are adopting:

```
permissions.defaultMode: "plan"    sessions start in plan mode — Claude proposes before it edits
tui: "fullscreen"                  full-screen terminal UI
theme: "dark"
env.COMPOSER_MEMORY_LIMIT: "-1"    Composer runs without a memory ceiling
```

The permission rules fall into four groups.

**Never read.** These are `Read` denies, not just write protection — the contents never enter the
context window at all:

- `.env`, every `*.local.php`, `config/autoload/local.php`, `config/autoload/local.test.php`,
  and `data/oauth/`.

That is the guarantee worth adopting the file for: your database credentials, your OAuth signing
keys and your environment secrets stay out of the transcript.

**Never written.** `Edit` and `Write` denies:

- dependency manifests (`composer.json`, `composer.lock`, `package.json`, `package-lock.json`),
  `vendor/`, `node_modules/`, `data/`, `log/`, `public/uploads/`, and anything under
  `Migration/` or `Migrations/`.

**Never run.** Bash denies:

- `composer require`/`remove`/`update`/`install`/`global`, the `npm`/`yarn`/`pnpm` install and
  removal verbs, `git push`, `git reset --hard`, `git clean`, `git submodule`, `rm -rf`.

**Ask first**, and **allowed outright**:

- **ask** — `doctrine-migrations`, `bin/doctrine`, `bin/cli.php`, `mysql`/`mariadb`,
  `git commit`/`add`/`checkout`/`rebase`/`merge`, `config/pipeline.php`, `config/config.php`, the
  authorization config, `phpcs.xml`/`phpstan.neon`/`phpunit.xml`, `.github/`, `CHANGELOG.md`,
  `SECURITY.md`, and this README.
- **allow** — the `composer` QA scripts (`check`, `cs-check`, `cs-fix`, `static-analysis`, `test`)
  plus `clear-config-cache`, `development-status` and `dump-autoload`; the `vendor/bin` tools;
  `php -l`, `php -v`, `php -m`; and read-only git (`status`, `diff`, `log`, `show`, `branch`,
  `ls-files`, `config --get`).

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
| `fixtures:execute`, `schema:drop`, `schema:update` | ask, via `bin/cli.php` | blocks |
| `composer development-enable` / `-disable` | — | blocks |
| `pip install`, `git checkout -- `, `git filter-branch` | — | blocks |

Everything else under `ask` — commits, `mysql`, the config and QA files — prompts as documented.
If you want one of the blocked commands back, edit the hook; relaxing `settings.local.json` will
not reach it.

## Status line

`.claude/statusline.sh` renders your real account usage, taken from the rate-limit payload Claude
Code (≥ 2.1) passes to the status line on stdin — the same numbers `/usage` reports:

```
~/project : Opus 5 ==> 5h:37% 2h14m left, resets @16:20 | 7d 61%
```

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

```
/help        # commands: dk-bootstrap, dk-module, dk-route, dk-trace, dk-test, dk-document,
             #           dk-check, dk-deprecate, dk-review, dk-hygiene
```

The session-start hook should open with a short briefing: which variant it detected, the root
namespace, the authorization style, the branch, and which config files are still missing.

Skills load from their own `description:` frontmatter — there is no routing table telling Claude
which to pick. Ask *"where does a new Doctrine entity go?"*; it should reach for
`dotkernel-module-structure` rather than answering from general framework knowledge.

With the `CLAUDE.md` block in place, ask *"how do I send mail from here?"* — a question with no
package in it. It should load `dependency-policy` and walk the ladder, grepping `composer.lock`
first and then the `dotkernel/*` manifest (generating it if absent), rather than replying `dot-mail`
from memory.

Test the guardrails: ask it to edit `vendor/autoload.php` (blocked by
`guard-protected-paths.sh`) and to add a package to `composer.json` (blocked by the same hook; it
should propose the change in chat instead). Then ask it to run `cd src && composer require foo` —
`guard-bash.sh` catches installs inside compound commands, which path-based permission rules
cannot see.

## What's here

```
README.md                                       this file
.gitignore                                      IDE directories and settings.local.json

.claude/settings.json                           permission guardrails + hook registration
.claude/settings.local.json.example             template for personal, git-ignored overrides
.claude/statusline.sh                           5h / 7d account usage in the status bar

.claude/hooks/guard-protected-paths.sh          PreToolUse (Edit/Write): blocks vendor/, node_modules/,
                                                migrations, data/cache|lock|oauth/, log/,
                                                public/uploads/, dependency manifests, tool caches,
                                                .git/ internals, and binary or key material
                                                (*.png, *.zip, *.phar, *.key, *.pem). A blocked
                                                *.local.php edit is redirected to its .dist template
.claude/hooks/guard-bash.sh                     PreToolUse (Bash): blocks installs, destructive git,
                                                DB-mutating commands and development-mode toggles,
                                                including inside compound commands
.claude/hooks/normalize-file.sh                 PostToolUse: BOM, CRLF, trailing whitespace, final
                                                newline. Skips whitespace stripping on .md, where two
                                                trailing spaces are a hard line break
.claude/hooks/php-lint.sh                       PostToolUse: php -l on every edited PHP file
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

.claude/skills/dotkernel-application-variants/   detect API vs Admin vs Frontend vs Light vs Queue
.claude/skills/dotkernel-module-structure/       where code goes, application module vs Core, wiring
.claude/skills/dotkernel-handler-naming/         both naming dialects, routes, authorization keys
.claude/skills/dotkernel-doctrine-entities/      entities, enums + DBAL types, repositories, migrations
.claude/skills/dotkernel-input-validation/       InputFilters, Inputs, forms, CSRF, query whitelisting
.claude/skills/dotkernel-responses/              HAL and collections, or templates and redirects; errors
.claude/skills/dotkernel-openapi/                swagger-php attributes, for apps that publish OpenAPI
.claude/skills/dotkernel-feature-docs/           feature docs: template, where they live, staleness
.claude/skills/dotkernel-testing/                unit + functional patterns, test config, coverage matrix
.claude/skills/dotkernel-evolution-pattern/      sunset headers instead of versioning
.claude/skills/dotkernel-security/               auth, authorization, secrets, CORS, dependencies
.claude/skills/dotkernel-dot-maker/              composer make … and the manual steps after it
.claude/skills/dotkernel-core-submodule/         Core layering rules and git submodule mechanics
.claude/skills/dotkernel-psr-standards/          PSR-1/3/4/6/7/11/12/15/16/17 as applied here
.claude/skills/dotkernel-qa-gate/                cs-check, static analysis, tests, forbidden "fixes"
.claude/skills/dotkernel-troubleshooting/        symptom → cause table
.claude/skills/dependency-policy/                the ladder: installed → dotkernel/* → laminas →
                                                 vetted community → hand-rolled; proposal format
.claude/skills/dependency-policy/scripts/        sync-dotkernel-packages.sh — regenerates the
                                                 dotkernel/* manifest from Packagist (curl + jq)
```

Every skill directory holds a `SKILL.md`. `dependency-policy` additionally carries `scripts/` and
the `references/dotkernel-packages.json` it generates — that manifest is git-ignored here, being a
dated snapshot, and is regenerated in the project where it is used.

## Feature documentation

`/dk-document` writes one markdown file per feature into the project — what it does, why, the routes
and the roles that reach them, the data added, and how to exercise it. It is the part a cleared
session cannot reconstruct from `src/`, and the reason it is a file in the repo rather than a note
in a chat.

Where it lands is detected, not assumed. Many Dotkernel repositories already carry a
`documentation/` directory — command docs, a generated `openapi.json`, Postman collections — and
which ones do is not predictable from the variant, so the skill checks rather than inferring: it
writes to `documentation/features/` when that directory exists and `docs/features/` otherwise, never
a second documentation root next to an existing one. Both paths are in the `allow` tier, prose in a
docs directory being the lowest-risk write in the tree.

The frontmatter is load-bearing: `/dk-review` greps each doc's `routes:` and `handlers:` to decide
whether a new route in the diff is documented, and reports a missing or stale doc as *Should fix*.
It never writes one — that command is read-only by design, and it tells you to run `/dk-document`
instead.

The generation half is a command, so it only runs when asked. To make Claude *read* the docs before
it rebuilds something that already exists, add this to your project's `CLAUDE.md` alongside the
dependency-policy block:

```markdown
## Feature docs

Before adding or changing behaviour, check `docs/features/` (or `documentation/features/`) for a doc
covering that area and read it. After the change, update that doc or write a new one with
`/dk-document`. A doc that contradicts the code is a bug in the doc.
```

The session-start hook prints the directory and a doc count, so the files are at least discoverable
without the block. The block is what makes them read.

## A note on the PostToolUse hooks

`normalize-file.sh` rewrites the file Claude just wrote (whitespace only). `php-lint.sh` is
deliberately **report-only** and does not run `phpcbf`, because reformatting a file immediately
after Claude writes it invalidates its in-memory copy and can break the next targeted edit. Bulk
formatting belongs at the end of a task, via `composer cs-fix` or `/dk-check`.

If you ever see "string not found" errors on consecutive edits to one file, move
`normalize-file.sh` from `PostToolUse` to the `Stop` event so it runs once per turn instead of once
per edit.

## Verify against current docs

Claude Code's `.claude/settings.json` schema and hook event names move faster than most things. If a
permission rule or hook does not take effect, check
<https://docs.claude.com/en/docs/claude-code/overview> — in particular the glob syntax accepted by
`permissions.deny` and whether `permissions.ask` exists in your version. The hooks are the reliable
layer; the permission rules are the convenient one.

## Maintaining this

Treat the skills as living documents. When a review turns up the same mistake twice, that is a
missing line in a skill, not a Claude problem. Skill **descriptions** drive loading — if a skill is
not triggering, make its description list the words you actually type, not the words the
documentation uses.

The Packagist snapshot behind `dependency-policy` goes stale silently, so re-run
`.claude/skills/dependency-policy/scripts/sync-dotkernel-packages.sh` when a `dot-*` package is
abandoned or superseded — `dot-annotated-services` → `dot-dependency-injection`, the case the skill
names, is exactly what a stale manifest gets wrong.

Before adapting this to a new Dotkernel application, spend an hour reading that repo and correcting
the skills against what is actually there. A skill written from framework docs rather than the
codebase produces confident wrong answers, which is worse than no skill.
