# Introduction

dotboost is a drop-in Claude Code configuration for Dotkernel projects.
It is not a Dotkernel application, a library, or something you `composer require` — there is no `composer.json` and no PHP source in this repository at all.
Its entire payload is a `.claude/` directory: settings, hooks, a status line, a review subagent, ten `/dk-*` slash commands and eighteen skills.
You install it by copying that directory into the root of the Dotkernel project you're actually working on (API, Admin, Frontend, Light, Queue, or a project derived from one of them).

## The problem it solves

Claude Code has no built-in knowledge of Dotkernel's conventions — handler naming, where an entity belongs (application module vs. the shared Core submodule), which PSR applies where, how authorization keys map to routes, or the difference between a HAL-based API response and a templated redirect.
Without that knowledge, an agent working in a Dotkernel repo either asks too many questions or confidently produces code that doesn't match house style.

dotboost closes that gap two ways:

- **Skills** teach the conventions themselves — naming, structure, validation, responses, security, testing, PSR standards — each loaded automatically when its description matches what you're doing.
- **Hooks and permissions** protect the repo while an agent works in it — blocking edits to `vendor/`, dependency manifests, migrations and secrets; blocking destructive or dependency-installing shell commands; and normalizing whitespace and line endings on every file Claude touches.

## Who this is for

Anyone using Claude Code inside a Dotkernel repository — application developers, and anyone maintaining a project derived from one of the Dotkernel starter kits.
It's equally useful whether you're building a new feature, reviewing a PR, or bootstrapping a fresh clone.

## What's next

- [Architecture Overview](architecture.md) for how the pieces fit together.
- [Getting Started](getting-started.md) to install it into a project.
