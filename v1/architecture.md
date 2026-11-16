# Architecture Overview

The central file of Dotboost is `.claude/settings.json`.
It registers the hooks, sets the permission tiers, and configures the status line.
It does not set personal preferences (permission mode, theme, TUI, spinner verbs).
Each developer sets them in their own `settings.local.json`, and `settings.local.json.example` contains a sample.
Outside this file, the payload has no wiring.
Claude Code finds skills and commands from their directory location only.

## The four artifact types

| Type | Where it lives | How it activates |
| --- | --- | --- |
| Hook | `.claude/hooks/*.sh` | `settings.json` registers it for a lifecycle event (`SessionStart`, `PreToolUse`, `PostToolUse`). It always runs when its event and matcher fire. |
| Skill | `.claude/skills/*/SKILL.md` | Claude Code loads it automatically when its `description:` frontmatter matches the current task of the conversation. There is no routing table. |
| Command | `.claude/commands/*.md` | You start it explicitly by name, for example `/dk-review`. |
| Subagent | `.claude/agents/*.md` | A command starts it, or Claude starts it by its own decision. For example, the review flow delegates to `dotkernel-reviewer`. |

This is important because the four types fail in different ways.
When `settings.json` does not register a hook, the hook never runs.
A skill can be present but have a vague `description:`, and then Claude may never select it.
This is not an error: nothing happens, and you see no message.
A command only exists when you type its name.
To debug "why didn't Dotboost do X", first identify which of these four categories X belongs to.

## Two layers of guardrail

Dotboost protects the target repository at two independent layers:

1. **Permission tiers** (`permissions.deny` / `ask` / `allow` in `settings.json`): path-glob rules and command-prefix rules that Claude Code enforces natively.
2. **Hooks** (`guard-protected-paths.sh`, `guard-bash.sh`): bash scripts that examine the actual tool call.
   They also examine compound Bash commands (`cd src && composer require foo`), and a glob pattern cannot see inside these commands.

The two layers overlap intentionally, but they do not agree on all commands.
A hook blocks some commands that the tier list marks as `ask`.
For the specific list, see [Guardrails vs. Permissions](hooks/guardrails-vs-permissions.md).
This difference is the most frequent cause of the confusion "why did it refuse instead of prompting me".

## The `CLAUDE.md` contract

Three behaviors need a short block in the `CLAUDE.md` of the consuming project:

- the dependency policy in `dotkernel-package-status`
- the feature-docs check
- the ASD-STE100 writing style in `dotkernel-writing-style`

Until the project pastes the block into its own `CLAUDE.md`, these behaviors are only loadable.
After that, they become *proactive*.
The `description:` frontmatter of a skill decides whether the skill *can* load.
It does not decide whether Claude uses the skill when nobody asks for it.
Thus, when you install only `.claude/`, these three behaviors do not operate fully.
For more information, see [Getting Started](getting-started.md) and [Feature Documentation](feature-docs.md).

## What's next

- [Permissions](permissions/introduction.md) for the guardrail tiers.
- [Hooks](hooks/introduction.md) for the six lifecycle scripts.
- [Skills](skills/introduction.md) for how the nineteen skills are organized.
