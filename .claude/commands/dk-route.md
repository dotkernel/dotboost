---
description: Add a fully wired route (API endpoint or admin/frontend page)
argument-hint: <VERB> <path> (e.g. POST /book/{id}/review)
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(php bin/cli.php:*), Bash(composer cs-fix), Bash(composer cs-check), Bash(composer static-analysis), Bash(composer test)
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

Add the route: **$ARGUMENTS**

Load `dotkernel-project-variants` first.
Then load `dotkernel-handler-naming`, `dotkernel-module-structure`, `dotkernel-input-validation`, `dotkernel-responses` and `dotkernel-psr-standards`.
In an API project, also load `dotkernel-api-endpoint`.

Do the steps in this sequence.
Show me the plan before step 3.

1. **Locate.** Identify the variant and the module that owns the route.
   Read the two nearest existing handlers.
   Read their entries in `RoutesDelegator`, `ConfigProvider` and the authorization config.
   Match their style exactly.
   When the repo and a skill are different, follow the repo.
2. **Name.** Derive the handler class name, file path, route pattern and route name.
   Use the dialect of this project.
   Tell me the names, and identify each ambiguity.
3. **Implement.**
   - Put the handler under `src/<Module>/src/Handler/<Resource>[/<Sub>]/`.
     It extends the abstract handler of the project and gets its dependencies through `#[Inject]`.
   - Validation: an InputFilter, or a Form with CSRF for a templated project.
   - Service method: put the business logic there, not in the handler.
   - Change entities and repositories only in `Core` (API and Admin) or inside the module that owns them (Frontend).
     If a migration is necessary, tell me.
     Do not run one.
4. **Wire.** Add these items:
   - `ConfigProvider` factories, delegators and aliases
   - the route in `RoutesDelegator`
   - an authorization entry for each role
   - the presentation (HAL metadata or template path)
   - the OpenAPI operation, if this project publishes OpenAPI
5. **Test.** Cover success, validation failure, unauthenticated, wrong role and unknown identifier.
   For a form, also cover rejected CSRF.
6. **Verify.** Run `composer cs-fix`, then the full QA suite.
   Paste the real output.

Constraints:

- Do not edit `composer.json`.
- Do not install packages.
- Do not run database commands.
  Ask me instead.
- If the change will break existing clients, stop and load `dotkernel-evolution-pattern`.

At the end, give a checklist of what changed and what I must still do.
