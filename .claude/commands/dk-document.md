---
description: Write or update the feature doc for a change
argument-hint: <feature name or route> [--update]
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(date +%F)
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

Document the feature: **$ARGUMENTS**

Load `dotkernel-project-variants` first.
Then load `dotkernel-feature-docs`, `dotkernel-handler-naming` and `dotkernel-responses`.
These skills let you read the surface correctly for the dialect of this project.

1. **Scope.** Run `git status --porcelain` and `git diff HEAD`, and include the untracked files.
   Use them to find what the feature really changed.
   If the feature is already committed, find the range with `git log` and use the diff of that range.
   If the argument does not match a thing that you can find, tell me.
2. **Locate.** Select the features directory from what the repo already has.
   Use `documentation/` before `docs/`.
   If neither directory exists, create `docs/features/`.
   Read the two most recent feature docs and match them.
   When the repo and the template are different, follow the repo.
3. **Derive.** Get each item from its source:
   - Routes and route names: from the `RoutesDelegator` of the module.
   - Roles: from the authorization config of this variant.
   - Handler classes: from the filesystem.
   - Registrations: from the `ConfigProvider`.
   - Data and migration impact: from the changed entities.
     In API and Admin, the entities are under `src/Core/`.
     In Frontend, they are in the `Entity/` directory of the module.

   Light has no database and no authorization config.
   Queue has no routes.
   For an item that the variant does not have, write `none`.
   Do not state a thing that you did not read.
   Write `unverified` and give the name of the file to check.
4. **Write.** Create a new doc at `YYYY-MM-DD-<kebab-slug>.md`, and use `date +%F` for the date.
   When I give `--update`, edit the existing doc in place.
   In the same step, update the row of the `README.md` index.
5. **Verify.** Make sure of these conditions:
   - Each path and class name resolves.
   - Each route in the Surface table appears in `RoutesDelegator`.
     It also appears in the authorization config, where the variant has one.
   - The frontmatter `routes:` and `handlers:` are complete, because `/dk-review` uses grep on them.
   - The doc contains no credential, token, internal hostname or real customer data.

Constraints:

- Write only inside the features directory.
  This command must not edit source, config or manifest files.
  It must not make a commit or a branch.
- If the feature is not finished, write the doc with `status: planned`, and tell me.
  Do not describe a plan as a shipped feature.
- If you find a route with no authorization entry, stop and tell me.
  Also stop and tell me if you find a contract change with no sunset window.
  That is a `/dk-review` finding, not a documentation problem.

At the end, give the doc path and a summary of one line about what the doc now states.
