# Introduction

A skill is a directory under `.claude/skills/` holding a `SKILL.md` — frontmatter (`name`, `description`) plus an instructional body.
There is no central routing table: Claude Code auto-loads a skill when its `description:` matches what the current conversation is doing.
That makes the description the entire activation mechanism — a skill with a vague or narrow description simply never fires, silently, with no error to debug.

Dotboost ships eighteen skills.
Seventeen are `dotkernel-*`, each covering one slice of Dotkernel convention; the eighteenth, `dependency-policy`, is generic to any package decision and detailed enough to warrant [its own page](dependency-policy.md).

## Reading a trigger description

Each skill's description is written to include the words a developer would actually type — "where does this go", "403", "InputFilter" — not just the framework term for the concept.
If a skill isn't triggering when you expect it to, the fix is almost always to add the phrase you used to its description, not to rewrite its instructions.
See [Maintaining This](../maintaining.md).

## Full list

[Reference](reference.md) groups all eighteen by theme with a one-line trigger description each.
