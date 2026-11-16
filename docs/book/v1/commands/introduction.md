# Introduction

A command is a `.md` file under `.claude/commands/` with YAML frontmatter.
The frontmatter has a `description`, an optional `argument-hint`, and `allowed-tools`, which limits the tools that the command can use.
A command is different from a skill: it never loads automatically.
You start it explicitly when you type its name, for example `/dk-review`.

Dotboost has ten commands.
They cover the lifecycle of a change, from a new clone to a diff that is ready for a PR.
See [Reference](reference.md) for the full list, in groups for each stage of the workflow.

## Commands vs. skills

Use a command when you want a specific procedure that you can run again on request.
Examples are to bootstrap a clone, to run the QA gate, or to write a feature doc.
Use a skill when you want Claude to *know* something automatically while it works on other tasks.
Examples are a naming convention, a validation pattern, or a security rule.
Some commands use skills internally.
For example, `/dk-module` uses `dotkernel-dot-maker` and `dotkernel-module-structure`, and does not copy their guidance.
When the repo is an API project, `/dk-route` and `/dk-review` also load `dotkernel-api-endpoint`.
Thus Claude builds and reviews a new endpoint against the same checklist.
