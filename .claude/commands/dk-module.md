---
description: Plan a new Dotkernel module from start to end (dot-maker first)
argument-hint: <ModuleName> [short description]
allowed-tools: Read, Grep, Glob, Edit, Write
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

Plan a new module: **$ARGUMENTS**

Load `dotkernel-project-variants` first.
Then load `dotkernel-dot-maker`, `dotkernel-module-structure` and `dotkernel-core-submodule`.

1. Tell me which Dotkernel project this is.
   From that, tell me which artefacts the module needs: collections and OpenAPI, or forms and templates, or commands.
2. Give me the exact `composer make module` / `./vendor/bin/dot-maker module` invocation.
   Give me the answer for each prompt.
   Do **not** run it.
   It is interactive, and I decide when to generate the files.
3. Show the expected file tree for the two layers.
   Base it on the layout of an existing module in **this** repo.
4. Propose the route set, with handler class names and route names.
   Use the naming dialect of this project.
5. Propose the entity fields, types, column lengths and indexes.
   Identify the fields that need an enum and a DBAL type.
6. List the manual wiring:
   - PSR-4 entries in `composer.json` (I must approve them)
   - `config/config.php`
   - the authorization config for this variant
   - the presentation registration
   - the documentation
   - the migration command
7. List the tests to write.

Give a numbered plan that I can approve.
Do not write files until I tell you to start.
