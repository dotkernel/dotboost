---
description: Plan a new Dotkernel module end to end (dot-maker first)
argument-hint: <ModuleName> [short description]
allowed-tools: Read, Grep, Glob, Edit, Write
---

Plan a new module: **$ARGUMENTS**

Load `dotkernel-application-variants` first, then `dotkernel-dot-maker`,
`dotkernel-module-structure` and `dotkernel-core-submodule`.

1. State which Dotkernel application this is, and therefore which artefacts the module needs
   (collections and OpenAPI, or forms and templates, or commands).
2. Give me the exact `composer make module` / `./vendor/bin/dot-maker module` invocation and the
   answers to give at each prompt. Do **not** run it — it is interactive and generation is my
   call.
3. Show the expected file tree for both layers, based on how an existing module in **this** repo
   is laid out.
4. Propose the route set with handler class names and route names, using this application's naming
   dialect.
5. Propose the entity fields, types, column lengths and indexes; note which need an enum plus a
   DBAL type.
6. List the manual wiring: PSR-4 entries in `composer.json` (needs my approval),
   `config/config.php`, the authorization config for this variant, presentation registration,
   documentation, migration command.
7. List the tests to write.

Output a numbered plan I can approve. Write no files until I say go.
