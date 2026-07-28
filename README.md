# Claude Code configuration for Dotkernel projects

Drop-in configuration that teaches Claude Code the conventions of any Dotkernel application —
API, Admin, Frontend, Light, Queue, or a project derived from one of them. Every skill detects the
variant first and applies the matching dialect.

Maintained by Borsan Sergiu.

## Install

Unzip at the project root. That is the whole install:

```
<project>/
├── CLAUDE.md          ← always-loaded rules and skill routing
├── .editorconfig      ← UTF-8 / LF / 4-space / 120 cols
└── .claude/           ← everything else
```

Then:

```bash
chmod +x .claude/hooks/*.sh
echo '.claude/settings.local.json' >> .git/info/exclude
```

Optionally, for personal overrides that stay out of git:

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
```

If the project already had a `CLAUDE.md` or `.editorconfig`, merge rather than overwrite —
unzipping replaces them.

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
*Create UTF-8 files: with NO BOM*. `.editorconfig` covers most of it if EditorConfig support is on.

## Verify

Start Claude Code in the project:

```
/help        # commands: dk-bootstrap, dk-module, dk-route, dk-trace, dk-test, dk-check,
             #           dk-deprecate, dk-review, dk-hygiene
/context     # CLAUDE.md loaded
```

The session-start hook should print which variant it detected and which config files are still
missing. Ask *"where does a new Doctrine entity go?"* — it should reach for
`dotkernel-module-structure` rather than guessing.

Test the guardrails: ask it to edit `vendor/autoload.php` (blocked by hook) and to add a package to
`composer.json` (blocked; it should propose the change in chat instead).

## What's here

```
CLAUDE.md                                       always-loaded rules + skill routing table
.editorconfig                                   encoding and formatting for humans and IDEs

.claude/settings.json                           permission guardrails + hook registration
.claude/settings.local.json.example             template for personal, git-ignored overrides
.claude/README.md                               this file

.claude/hooks/guard-protected-paths.sh          PreToolUse (Edit/Write): blocks vendored, generated,
                                                secret and dependency-manifest paths
.claude/hooks/guard-bash.sh                     PreToolUse (Bash): blocks installs, destructive git and
                                                DB-mutating commands, including inside compound commands
.claude/hooks/normalize-file.sh                 PostToolUse: BOM, CRLF, trailing whitespace, final newline
.claude/hooks/php-lint.sh                       PostToolUse: php -l on every edited PHP file
.claude/hooks/session-start.sh                  SessionStart: variant detection, setup gaps, CRLF warning

.claude/agents/dotkernel-reviewer.md            review subagent (keeps the main context clean)

.claude/commands/dk-bootstrap.md                fresh clone → running install
.claude/commands/dk-module.md                   plan a new module (dot-maker first)
.claude/commands/dk-route.md                    add a fully wired endpoint or page
.claude/commands/dk-trace.md                    trace a request through pipeline → handler → response
.claude/commands/dk-test.md                     write and run tests
.claude/commands/dk-check.md                    run and fix the QA gate
.claude/commands/dk-deprecate.md                evolution-pattern breaking change
.claude/commands/dk-review.md                   pre-PR convention review
.claude/commands/dk-hygiene.md                  encoding / line-ending audit

.claude/skills/dotkernel-application-variants/  detect API vs Admin vs Frontend vs Light vs Queue
.claude/skills/dotkernel-module-structure/       where code goes, application module vs Core, wiring
.claude/skills/dotkernel-handler-naming/         both naming dialects, routes, authorization keys
.claude/skills/dotkernel-doctrine-entities/      entities, enums + DBAL types, repositories, migrations
.claude/skills/dotkernel-input-validation/       InputFilters, Inputs, forms, CSRF, query whitelisting
.claude/skills/dotkernel-responses/              HAL and collections, or templates and redirects; errors
.claude/skills/dotkernel-openapi/                swagger-php attributes, for apps that publish OpenAPI
.claude/skills/dotkernel-testing/                unit + functional patterns, test config, coverage matrix
.claude/skills/dotkernel-evolution-pattern/      sunset headers instead of versioning
.claude/skills/dotkernel-security/               auth, authorization, secrets, CORS, dependencies
.claude/skills/dotkernel-dot-maker/              composer make … and the manual steps after it
.claude/skills/dotkernel-core-submodule/         Core layering rules and git submodule mechanics
.claude/skills/dotkernel-psr-standards/          PSR-1/3/4/6/7/11/12/15/16/17 as applied here
.claude/skills/dotkernel-qa-gate/                cs-check, static analysis, tests, forbidden "fixes"
.claude/skills/dotkernel-troubleshooting/        symptom → cause table
```

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

Before adapting this to a new Dotkernel application, spend an hour reading that repo and correcting
the skills against what is actually there. A skill written from framework docs rather than the
codebase produces confident wrong answers, which is worse than no skill.
