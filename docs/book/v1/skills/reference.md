# Reference

## Variant detection

| Skill | Fires on |
| --- | --- |
| `dotkernel-project-variants` | Working out whether a repo is API, Admin, Frontend, Light, Queue, or a derived project, and what that implies elsewhere |

## Structure and naming

| Skill | Fires on |
| --- | --- |
| `dotkernel-module-structure` | Deciding where a new file belongs — application module vs. the shared Core layer — and registering it |
| `dotkernel-handler-naming` | PSR-15 handler class names, route URLs and names, authorization keys, PATCH vs. POST |
| `dotkernel-api-endpoint` | API only — adding or changing an endpoint: `/account` and action-segment URLs, `#[Resource]` loading, response helpers, `operationId`, guest grants, and the end-to-end checklist before calling it done |
| `dotkernel-dot-maker` | Scaffolding a module, entity, service, handler, form, or command with `composer make …` |
| `dotkernel-core-submodule` | Core-layer changes and git submodule mechanics for sharing code across projects |

## Data layer

| Skill | Fires on |
| --- | --- |
| `dotkernel-doctrine-entities` | Entities, columns, relations, indexes, repositories, backed enums with DBAL types, fixtures, migrations |
| `dotkernel-input-validation` | InputFilters, Input classes, laminas-form Forms, CSRF, upload validation |

## Request lifecycle and responses

| Skill | Fires on |
| --- | --- |
| `dotkernel-responses` | Shaping handler output — HAL resources/collections and the MetadataMap, or templates/redirects/flash messages; pagination and error bodies |
| `dotkernel-openapi` | Documenting an endpoint via swagger-php attributes, for projects that publish OpenAPI |
| `dotkernel-evolution-pattern` | Non-breaking API evolution — Sunset/Link headers and deprecation, `410 Gone` after the sunset date, instead of `/v2` or a version prefix |

## Quality, security, and process

| Skill | Fires on |
| --- | --- |
| `dotkernel-psr-standards` | Which PSR applies to a given piece of code, and Laminas Coding Standard style |
| `dotkernel-qa-gate` | Running or interpreting phpcs, phpcbf, phpstan, phpunit; refusing forbidden shortcuts like `@phpstan-ignore` |
| `dotkernel-testing` | Unit and functional tests, mocking repositories/services, authenticating test requests |
| `dotkernel-security` | Auth, authorization config, CORS, sessions/cookies, secrets, `*.local.php` vs. `*.global.php`, raw DQL/SQL |
| `dotkernel-troubleshooting` | Symptom-to-cause lookup for 403/404/406/415/500, container errors, config not taking effect |
| `dotkernel-feature-docs` | Writing and keeping feature docs current — see [Feature Documentation](../feature-docs.md) |

## Dependency policy

| Skill | Fires on |
| --- | --- |
| `dotkernel-package-status` | Any package decision — the order: already installed → `dotkernel/*` → `laminas`/`mezzio` → vetted community package → hand-rolled code — and whether a Dotkernel package is still maintained and which PHP versions it supports, from the dotkernel.com listing. See [Package Status](dotkernel-package-status.md) |

## Writing style

| Skill | Fires on |
| --- | --- |
| `dotkernel-writing-style` | Any prose — chat answers, commit and tag messages, MR/PR descriptions, Markdown files, code comments, docblock descriptions, exception messages, CLI output and OpenAPI descriptions — written in ASD-STE100 Simplified Technical English, at a Strict or a Standard level. The code itself is out of scope |
