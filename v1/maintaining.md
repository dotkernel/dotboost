# Maintaining This

Treat the skills as documents that change over time.
When a review finds the same mistake two times, a skill does not have a necessary line.
The cause is not a problem in Claude.

## Skill descriptions drive loading

If a skill does not load, make its `description:` include the words that developers actually type.
Do not use only the words from the official documentation.
See [Skills Introduction](skills/introduction.md#reading-a-trigger-description).

## Keep each skill's scope accurate

Each `SKILL.md` has an `Applies to` block immediately under its title.
The block names the projects and packages that the skill covers:

```text
Applies to
  Projects:  - Dotkernel API
             - Dotkernel Admin
  Packages:  - none
```

Use `all` or `none` when that is the full answer.
Put the block under the title, not above the frontmatter.
Claude Code reads the frontmatter only when it starts on the first line.
When you add a project to a skill or remove a project from it, update the block in the same change.

## Package status needs no refresh

`dotkernel-package-status` reads the dotkernel.com listing live, so you have no local snapshot to keep current.
If an entry is wrong, report it in `dotkernel/dotkernel.com`.
Report a wrong lifecycle value in the repository of the package, because its `OSSMETADATA` file declares the value.
See [Package Status](skills/dotkernel-package-status.md).

## Adapting Dotboost to a new Dotkernel project

You can adapt this configuration to a Dotkernel project where nobody used it before.
Before you do this, read that repo for an hour, and correct the skills to agree with the code in it.
Some skills come from the framework documentation and not from the real codebase.
Such a skill gives wrong answers that look correct.
This is worse than no skill, because the answers do not look uncertain.
