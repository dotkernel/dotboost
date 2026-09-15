# Architecture Overview

Everything in dotboost hangs off one file: `.claude/settings.json`.
It registers the hooks, sets the permission tiers, configures the status line, and sets session defaults (`defaultMode: "plan"`, dark theme, fullscreen TUI).
Nothing else in the payload is wired together outside of it — skills and commands are discovered by Claude Code from their directory location alone.

## The four artifact types

| Type | Where it lives | How it activates |
| --- | --- | --- |
| Hook | `.claude/hooks/*.sh` | Registered in `settings.json` against a lifecycle event (`SessionStart`, `PreToolUse`, `PostToolUse`); always runs when its event and matcher fire |
| Skill | `.claude/skills/*/SKILL.md` | Auto-loaded when its `description:` frontmatter matches what the conversation is doing — no routing table |
| Command | `.claude/commands/*.md` | Invoked explicitly by name, e.g. `/dk-review` |
| Subagent | `.claude/agents/*.md` | Invoked by a command or by Claude's own judgment, e.g. the review flow delegating to `dotkernel-reviewer` |

This matters because the four types fail differently.
A hook that isn't registered in `settings.json` never runs, full stop.
A skill that's technically present but has a vague `description:` may simply never be selected — it isn't an error, it's silence.
A command only exists when you type its name.
Debugging "why didn't dotboost do X" starts by identifying which of these four categories X falls into.

## Two layers of guardrail

dotboost protects the target repository at two independent layers:

1. **Permission tiers** (`permissions.deny` / `ask` / `allow` in `settings.json`) — path-glob and command-prefix rules Claude Code enforces natively.
2. **Hooks** (`guard-protected-paths.sh`, `guard-bash.sh`) — bash scripts that inspect the actual tool call, including compound Bash commands (`cd src && composer require foo`) that a glob pattern can't see into.

The two layers overlap on purpose but don't agree everywhere: some commands the tier list marks `ask` are blocked outright by a hook.
See [Guardrails vs. Permissions](hooks/guardrails-vs-permissions.md) for the specific list — it's the most common source of "why did it refuse instead of prompting me" confusion.

## The `CLAUDE.md` contract

Two skills — `dependency-policy` and the feature-docs check — only become *proactive* rather than merely loadable once the consuming project pastes a short block into its own `CLAUDE.md`.
A skill's `description:` frontmatter decides whether it *can* load; it doesn't decide whether Claude reaches for it unprompted.
This is why installing `.claude/` alone under-delivers on those two behaviors — see [Getting Started](getting-started.md) and [Feature Documentation](feature-docs.md).

## What's next

- [Permissions](permissions/introduction.md) for the guardrail tiers.
- [Hooks](hooks/introduction.md) for the six lifecycle scripts.
- [Skills](skills/introduction.md) for how the eighteen skills are organized.
