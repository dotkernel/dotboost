---
description: Add a fully wired route (API endpoint or admin/frontend page)
argument-hint: <VERB> <path> (e.g. POST /book/{uuid}/review)
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(php bin/cli.php:*), Bash(composer cs-fix), Bash(composer cs-check), Bash(composer static-analysis), Bash(composer test)
---

Add the route: **$ARGUMENTS**

Load `dotkernel-application-variants` first, then `dotkernel-handler-naming`,
`dotkernel-module-structure`, `dotkernel-input-validation`, `dotkernel-responses` and
`dotkernel-psr-standards`.

Work in this order and show me the plan before step 3:

1. **Locate.** Identify the variant and the owning module. Read the two closest existing handlers
   and their entries in `RoutesDelegator`, `ConfigProvider` and the authorization config. Match
   their style exactly — the repo beats any skill.
2. **Name.** Derive the handler class name, file path, route pattern and route name using this
   application's dialect. State them and flag any ambiguity.
3. **Implement.**
   - Handler under `src/<Module>/src/Handler/<Resource>[/<Sub>]/`, extending the app's abstract
     handler, deps via `#[Inject]`.
   - Validation: an InputFilter, or a Form with CSRF for a templated app.
   - Service method — business logic lives there, not in the handler.
   - Entity/repository changes only in `Core`, and tell me if a migration is needed rather than
     running one.
4. **Wire.** `ConfigProvider` factories, delegators and aliases; route in `RoutesDelegator`;
   authorization entry per role; presentation (HAL metadata or template path); OpenAPI operation if
   this app publishes it.
5. **Test.** Cover success, validation failure, unauthenticated, wrong role, unknown identifier —
   plus rejected CSRF for a form.
6. **Verify.** `composer cs-fix`, then the full QA suite. Paste real output.

Constraints: no `composer.json` edits, no installs, no database commands — ask me instead. If the
change would break existing clients, stop and load `dotkernel-evolution-pattern`.

Finish with a checklist of what changed and what is left for me.
