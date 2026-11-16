# Introduction

Dotboost is a drop-in Claude Code configuration for Dotkernel projects.
It is not a Dotkernel project, not a library, and not a package for `composer require`.
This repository contains no `composer.json` and no PHP source at all.
Its full payload is a `.claude/` directory: settings, hooks, a status line, a review subagent, ten `/dk-*` slash commands and nineteen skills.
To install it, copy that directory into the root of the Dotkernel project that you actually work on.
This can be an API, Admin, Frontend, Light or Queue project, or a project derived from one of them.

## The problem it solves

Claude Code has no built-in knowledge of the Dotkernel conventions, for example:

- how to name a handler
- where an entity belongs (an application module or the shared Core submodule)
- which PSR applies where
- how authorization keys map to routes
- the difference between a HAL-based API response and a templated redirect

Without that knowledge, an agent in a Dotkernel repository asks too many questions.
Or it writes code with confidence, and that code does not match the house style.

Dotboost solves this problem in two ways:

- **Skills** teach the conventions: naming, structure, validation, responses, security, testing and PSR standards.
  Claude Code loads each skill automatically when its description matches your task.
- **Hooks and permissions** protect the repository while an agent works in it:
    - They block edits to `vendor/`, dependency manifests, migrations and secrets.
    - They block shell commands that are destructive or that install dependencies.
    - They normalize whitespace and line endings in each file that Claude changes.

## Who this is for

Dotboost is for each person who uses Claude Code in a Dotkernel repository.
This includes developers on a Dotkernel project, and maintainers of a project derived from one of the Dotkernel starter kits.
It is equally useful when you build a new feature, review a PR or bootstrap a fresh clone.

## What's next

- [Architecture Overview](architecture.md) explains how the parts work together.
- [Getting Started](getting-started.md) tells how to install Dotboost into a project.
