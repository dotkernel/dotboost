# Introduction

A command is a `.md` file under `.claude/commands/` with YAML frontmatter — `description`, an optional `argument-hint`, and `allowed-tools` scoping what the command may use.
Unlike a skill, a command never loads itself: you invoke it explicitly by typing its name, e.g. `/dk-review`.

dotboost ships ten, covering the lifecycle of a change from a fresh clone through to a PR-ready diff.
See [Reference](reference.md) for the full list, grouped by workflow stage.

## Commands vs. skills

Use a command when you want a specific, repeatable procedure to run on demand — bootstrapping a clone, running the QA gate, writing a feature doc.
Use a skill when you want Claude to *know* something automatically while it works on unrelated tasks — a naming convention, a validation pattern, a security rule.
Several commands lean on skills internally; `/dk-module`, for instance, is built on top of `dotkernel-dot-maker` and `dotkernel-module-structure` rather than duplicating their guidance.
