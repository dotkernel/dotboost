---
name: dotkernel-core-submodule
description: >
  Use whenever a change touches the Core layer of a Dotkernel project: adding or editing a
  Doctrine entity, repository, enum, DBAL type, fixture, migration or shared service. Also use
  when you decide whether code belongs in Core versus an application module. Also use for git
  submodule mechanics (.gitmodules, git submodule add/init/update, committing from inside
  src/Core) and for questions about sharing code between Dotkernel projects on one database.
---

# The shared Core layer

```text
Applies to
  Projects:  - Dotkernel API
             - Dotkernel Admin
  Packages:  - none
```

The headless platform of Dotkernel is a set of projects on one database.
An API is the root, and an Admin for management is optional.
The arrangement is flexible.
For example, two APIs and one Admin is also a valid arrangement.

`src/Core` is the codebase that these projects share.
Thus, one change to a shared entity or service goes to all projects, and you do not copy it into each project.
The stock API and Admin include the same `Core` modules: `Admin`, `App`, `Security`, `Setting`, `User`.

The stock Frontend, Light and Queue have no `Core`.
Frontend keeps its entities in its own modules.
Light and Queue have no persistence.
A derived project can use `Core`, but do not assume that it does.

In API and Admin, `src/Core` is an ordinary module.
Its design makes it the start point for an extraction into a git submodule.
**Use it as if it is a submodule already.**

## Rules for Core code

1. **Only Core manages database entities.**
   All Doctrine entities, repositories, enums and DBAL types are under `src/Core/src/<Module>/src/`.
2. **Core must never depend on a project namespace.**
   Do not import `Api\…`, `Admin\…` or `Frontend\…`.
   Do not put HTTP request structures, HAL or forms in Core.
   If a Core service must report a failure, throw a Core exception or return null.
   Then let the application layer translate it.
3. **All other projects can use anything in Core.**
   Before you change a Core signature, find out if the change breaks the other projects.
   Prefer changes that only add.
   Deprecate, do not rename.
4. **Not all code that looks shared belongs in Core.**
   When only one project uses some logic, keep it in the module of that project.
   Core is for code that is really common.
5. Tools **generate** the migration directories under Core.
   Never edit them by hand.

## Splitting a change

A typical feature is in the two layers:

```text
src/Core/src/Book/src/Entity/Book.php               ← schema, invariants, accessors
src/Core/src/Book/src/Repository/BookRepository.php ← query builders
src/Book/src/Service/BookService.php                ← use-case orchestration
src/Book/src/Handler/Book/…Handler.php              ← HTTP / presentation
```

Each layer has its own `ConfigProvider`, and `config/config.php` registers the two layers.

## Creating the submodule

Create a new git repository for the Core code.
Then, from the project root, run:

```bash
git submodule add <url> src/Core
```

Git writes `.gitmodules`.
This file maps the URL to the local path, so that git can clone, update and track the submodule.
**Before you add the submodule to a second project, delete the existing `src/Core` directory.**

No Dotkernel project includes `.gitmodules` by default.
The file exists only after you move Core into its own repository.

## Day-to-day mechanics

To clone a project that has a submodule:

```bash
git submodule init
git submodule update
# or: git clone --recurse-submodules <url>
```

To commit Core changes, work **from inside the submodule directory**, because it is its own repository:

```bash
cd src/Core
git add .
git commit -m "…"
git push
```

Then, in the parent repository, commit the updated submodule pointer:

```bash
cd ../..
git add src/Core
git commit -m "Bump Core submodule"
```

The usual failure is to skip that second step.
Then other developers pull and still get the old Core.

## Working rules for an agent

- Before you edit Core, state that the change affects more than one project.
  Name the projects that probably use the changed code.
- `git submodule` and `git push` are in the deny tier.
  The `guard-bash.sh` hook refuses them, with or without approval.
  Never try to run them.
  Give the user the exact commands to run.
- `git add` and `git commit` ask for approval.
  Run them only when the user asks for the commit.
- If `.gitmodules` exists, do not stage changes to Core content from the parent repository.
  These changes belong to the history of the submodule.
- A schema change needs a migration.
  Generate the migration, do not write it.
  **Every project on that database must apply it.**
- A schema-validation CI job finds differences between entities and migrations.

## Why this design

- The projects stay consistent.
- You fix a bug in one place.
- Developers can share the work without many merge conflicts.
- New developers learn the platform more easily.
- The platform grows when you add projects that all use the same model from Core.
