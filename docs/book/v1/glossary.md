# Glossary

Applies to
: The block under each skill's title that names the projects and packages the skill covers — `all`, `none`, or a list such as `Dotkernel API`.


Command
: A `.md` file under `.claude/commands/` with frontmatter (`description`, optional `argument-hint`, `allowed-tools`) that defines a `/dk-*` slash command.
  Invoked explicitly by name, unlike a skill.

`dot-maker`
: `dotkernel/dot-maker`, a Composer tool (`composer make …`) that scaffolds new modules, entities, services, handlers and more to Dotkernel's file structure and naming pattern.

Feature doc
: A markdown file written by `/dk-document` describing what a feature does, why, and how to exercise it — the part of a change a cleared session can't reconstruct from `src/` alone.
  See [Feature Documentation](feature-docs.md).

Frontmatter
: The YAML block at the top of a `SKILL.md` or command `.md` file (`name`, `description`, etc.) that Claude Code reads to decide whether and how to load the file.

Guard
: A hook that blocks a tool call outright rather than just reporting on it — `guard-protected-paths.sh` and `guard-bash.sh`.

Hook
: A bash script registered in `settings.json` against a lifecycle event (`SessionStart`/`PreToolUse`/`PostToolUse`) that runs automatically when that event fires.
  See [Hooks](hooks/introduction.md).

Package
: A reusable `dotkernel/dot-*` Composer library — `dot-mail`, `dot-cli`, `dot-log` and so on — installed into projects rather than run on its own.

Permission tier
: One of `deny`, `ask`, or `allow` in `settings.json`'s `permissions` block, governing whether a path or command is blocked outright, prompted for approval, or runs without a prompt.
  See [Permissions](permissions/introduction.md).

Project
: A Dotkernel starter codebase you build on — API, Admin, Frontend, Light, or Queue — or a project derived from one of them.
  Dotkernel has projects and packages, not "applications"; where a skill says *application module* or *application layer*, it means a project's own modules under `src/<Module>/`, as opposed to the shared `Core` layer.

Project variant
: Which kind of Dotkernel project a repo is — API, Admin, Frontend, Light, or Queue — or a project derived from one of them.
  Detected by `dotkernel-project-variants` and by `session-start.sh`, since conventions differ by variant.

`SKILL.md`
: The file every skill directory must contain — frontmatter plus an instructional body — that Claude Code loads into context when the skill fires.

Skill
: A packaged set of instructions under `.claude/skills/` that Claude Code auto-loads based on its `description:` frontmatter matching the current task, with no central routing table.
  See [Skills](skills/introduction.md).

Subagent
: A separately-invoked agent defined under `.claude/agents/`, used to keep bulk review work out of the main conversation's context.
  Dotboost ships one: `dotkernel-reviewer`.
