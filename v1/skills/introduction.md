# Introduction

A skill is a directory under `.claude/skills/` that contains a `SKILL.md` file.
The file has frontmatter (`name`, `description`) and a body with instructions.
There is no central routing table.
Claude Code loads a skill automatically when its `description:` matches the work in the current conversation.
Thus the description is the only activation mechanism.
A skill with a vague or narrow description never loads, and you get no message and no error to debug.

Dotboost has nineteen skills, all `dotkernel-*`.
Each skill covers one part of the Dotkernel conventions.
One of them, `dotkernel-package-status`, controls each package decision.
It has sufficient detail for [its own page](dotkernel-package-status.md).
Each skill gives its scope in an `Applies to` block under its title.
The block names the Dotkernel projects (API, Admin, Frontend, Light, Queue) and the packages that the skill covers.
For example, `dotkernel-api-endpoint` applies only in an API project.
There, it is the end-to-end checklist for a new or changed endpoint, and it points to the skill for each topic.

## Reading a trigger description

The description of each skill includes the words that a developer actually types, for example "where does this go", "403" or "InputFilter".
It does not include only the framework term for the concept.
If a skill does not load when you expect it, the fix is almost always to add your phrase to its description.
The fix is almost never to write its instructions again.
See [Maintaining This](../maintaining.md).

## Full list

[Reference](reference.md) puts all nineteen skills in groups by theme, with a one-line trigger description for each skill.
