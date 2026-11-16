# Glossary

Applies to
: The block under the title of each skill.
  It names the projects and packages that the skill covers: `all`, `none`, or a list such as `Dotkernel API`.

Command
: A `.md` file under `.claude/commands/` with frontmatter (`description`, optional `argument-hint`, `allowed-tools`) that defines a `/dk-*` slash command.
  You start it explicitly by its name, which is different from a skill.

`dot-maker`
: `dotkernel/dot-maker`, a Composer tool (`composer make …`).
  It scaffolds new modules, entities, services, handlers and more, to the Dotkernel file structure and naming pattern.

Feature doc
: A markdown file that `/dk-document` writes.
  It tells what a feature does, why, and how to try it.
  A cleared session cannot find this part of a change again from `src/` alone.
  See [Feature Documentation](feature-docs.md).

Frontmatter
: The YAML block at the top of a `SKILL.md` file or a command `.md` file (`name`, `description`, and other keys).
  Claude Code reads it to decide whether and how to load the file.

Guard
: A hook that blocks a tool call, and does not only report on it: `guard-protected-paths.sh` and `guard-bash.sh`.

Hook
: A bash script that `settings.json` registers for a lifecycle event (`SessionStart`/`PreToolUse`/`PostToolUse`).
  The script runs automatically when that event occurs.
  See [Hooks](hooks/introduction.md).

Package
: A reusable `dotkernel/dot-*` Composer library, for example `dot-mail`, `dot-cli` or `dot-log`.
  You install it into projects, and you do not run it alone.

Permission tier
: One of `deny`, `ask`, or `allow` in the `permissions` block of `settings.json`.
  It controls whether Claude Code blocks a path or command, asks for approval, or lets it run without a prompt.
  See [Permissions](permissions/introduction.md).

Project
: A Dotkernel starter codebase that you build on (API, Admin, Frontend, Light, or Queue), or a project derived from one of them.
  Dotkernel has projects and packages, not "applications".
  When a skill says *application module* or *application layer*, it means the modules of a project under `src/<Module>/`, not the shared `Core` layer.

Project variant
: The type of Dotkernel project that a repo is: API, Admin, Frontend, Light, or Queue, or a project derived from one of them.
  `dotkernel-project-variants` and `session-start.sh` find the variant, because the conventions are different for each variant.

`SKILL.md`
: The file that each skill directory must contain, with frontmatter and a body with instructions.
  Claude Code loads it into the context when it selects the skill.

Skill
: A packaged set of instructions under `.claude/skills/`.
  Claude Code loads it automatically when its `description:` frontmatter matches the current task.
  There is no central routing table.
  See [Skills](skills/introduction.md).

Subagent
: An agent, defined under `.claude/agents/`, that you or Claude start separately.
  It keeps bulk review work out of the context of the main conversation.
  Dotboost ships one: `dotkernel-reviewer`.
