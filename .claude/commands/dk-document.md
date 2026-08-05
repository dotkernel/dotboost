---
description: Write or update the feature doc for a change
argument-hint: <feature name or route> [--update]
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(date +%F)
---

Document the feature: **$ARGUMENTS**

Load `dotkernel-application-variants` first, then `dotkernel-feature-docs`, plus
`dotkernel-handler-naming` and `dotkernel-responses` so the surface is read correctly for this
application's dialect.

1. **Scope.** `git status --porcelain` and `git diff HEAD`, untracked files included, to establish
   what the feature actually touched. If it is already committed, find the range with `git log` and
   diff that instead. Tell me if the argument does not match anything you can find.
2. **Locate.** Decide the features directory by what the repo already has — `documentation/` before
   `docs/`, neither means create `docs/features/`. Read the two most recent existing feature docs
   and match them; the repo beats the template.
3. **Derive.** Routes and route names from the module's `RoutesDelegator`, roles from this variant's
   authorization config, handler classes from the filesystem, registrations from the
   `ConfigProvider`, data and migration impact from changed entities under `src/Core/`. Assert
   nothing you did not read — write `unverified` and name the file to check.
4. **Write.** A new doc at `YYYY-MM-DD-<kebab-slug>.md` using `date +%F`, or edit the existing one
   in place when I passed `--update`. Update the `README.md` index row in the same pass.
5. **Verify.** Every path and class name resolves; every route in the Surface table appears in both
   `RoutesDelegator` and the authorization config; frontmatter `routes:` and `handlers:` are
   complete, because `/dk-review` greps them; no credential, token, internal hostname or real
   customer data anywhere in it.

Constraints: write only inside the features directory — no source, config or manifest edits from
this command, and no commit or branch. If the feature is not finished, write it with
`status: planned` and say so rather than describing intent as shipped. If documenting it turns up a
route with no authorization entry, or a contract change with no sunset window, stop and tell me —
that is a `/dk-review` finding, not a documentation problem.

Finish with the doc path and a one-line summary of what it now claims.
