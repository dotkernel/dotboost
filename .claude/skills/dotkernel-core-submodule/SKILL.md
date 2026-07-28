---
name: dotkernel-core-submodule
description: >
  Use whenever a change touches the Core layer of a Dotkernel application — adding or editing a
  Doctrine entity, repository, enum, DBAL type, fixture, migration or shared service — or when
  deciding whether code belongs in Core versus an application module. Also use for git submodule
  mechanics (.gitmodules, git submodule add/init/update, committing from inside src/Core) and for
  questions about sharing code between Dotkernel applications on one database.
---

# The shared Core layer

Dotkernel's headless platform is a set of applications over one database: an API as the root, and
optionally an Admin for management, a Frontend, a Queue worker. The arrangement is flexible — two
APIs, one Admin and three Frontends is equally valid.

`src/Core` is the codebase they share, so one change to a shared entity or service propagates
rather than being copy-pasted into each application.

In most Dotkernel repositories `src/Core` ships as an ordinary module, designed as the starting
point for extraction into a git submodule. **Treat it as if it already were one.**

## Rules for Core code

1. **Core is the only place that manages database entities.** All Doctrine entities,
   repositories, enums and DBAL types live under `src/Core/src/<Module>/src/`.
2. **Core must never depend on an application namespace.** No `Api\…`, `Admin\…`, `Frontend\…`
   imports; nothing HTTP-request-shaped, no HAL, no forms. If a Core service must signal failure,
   throw a Core-level exception or return null and let the application layer translate it.
3. **Anything in Core is potentially consumed by every other application.** Before changing a
   Core signature, ask whether it breaks the siblings. Prefer additive changes; deprecate rather
   than rename.
4. **Not everything shared-looking belongs in Core.** Logic used by exactly one application stays
   in that application's module. Core is for genuinely common code.
5. Migration directories under Core are **generated** — never hand-edit.

## Splitting a change

A typical feature spans both layers:

```
src/Core/src/Book/src/Entity/Book.php               ← schema, invariants, accessors
src/Core/src/Book/src/Repository/BookRepository.php ← query builders
src/Book/src/Service/BookService.php                ← use-case orchestration
src/Book/src/Handler/Book/…Handler.php              ← HTTP / presentation
```

Both layers get their own `ConfigProvider`, and both are registered in `config/config.php`.

## Creating the submodule

Create a new git repository for the Core code, then from the application root:

```bash
git submodule add <url> src/Core
```

Git writes `.gitmodules`, mapping the URL to the local path so it can clone, update and track it.
**Delete the existing `src/Core` directory before adding the submodule** to a second application.

No Dotkernel application ships `.gitmodules` out of the box — it only exists once you have
isolated Core into its own repository.

## Day-to-day mechanics

Cloning a project that has one:

```bash
git submodule init
git submodule update
# or: git clone --recurse-submodules <url>
```

Committing Core changes — **from inside the submodule directory**, which is its own repository:

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

Skipping that second step is the classic failure: teammates pull and still get the old Core.

## Working rules for an agent

- Before editing Core, state that the change is cross-application and name the likely consumers.
- Never run `git submodule`, `git commit` or `git push` without explicit approval.
- If `.gitmodules` exists, do not stage Core content changes from the parent repo — they belong
  to the submodule's own history.
- Schema changes need a migration, generated not written, and **applied by every application on
  that database**.
- A schema-validation CI job will catch entity/migration drift.

## Why this design

Consistency across applications, one place to fix a bug, work splittable across developers
without merge storms, easier onboarding, and a platform that scales by adding applications that
all speak to the same Core-defined model.
