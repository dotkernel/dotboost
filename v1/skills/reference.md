# Reference

## Variant detection

| Skill | Fires on |
| --- | --- |
| `dotkernel-application-variants` | Working out whether a repo is API, Admin, Frontend, Light, Queue, or a derived project, and what that implies elsewhere |

## Structure and naming

| Skill | Fires on |
| --- | --- |
| `dotkernel-module-structure` | Deciding where a new file belongs — application module vs. the shared Core layer — and registering it |
| `dotkernel-handler-naming` | PSR-15 handler class names, route URLs and names, authorization keys, PATCH vs. POST |
| `dotkernel-dot-maker` | Scaffolding a module, entity, service, handler, form, or command with `composer make …` |
| `dotkernel-core-submodule` | Core-layer changes and git submodule mechanics for sharing code across applications |

## Data layer

| Skill | Fires on |
| --- | --- |
| `dotkernel-doctrine-entities` | Entities, columns, relations, indexes, repositories, backed enums with DBAL types, fixtures, migrations |
| `dotkernel-input-validation` | InputFilters, Input classes, laminas-form Forms, CSRF, upload validation |

## Request lifecycle and responses

| Skill | Fires on |
| --- | --- |
| `dotkernel-responses` | Shaping handler output — HAL resources/collections and the MetadataMap, or templates/redirects/flash messages; pagination and error bodies |
| `dotkernel-openapi` | Documenting an endpoint via swagger-php attributes, for applications that publish OpenAPI |
| `dotkernel-evolution-pattern` | Non-breaking API evolution — Sunset/Link headers and deprecation, instead of `/v2` or a version prefix |

## Quality, security, and process

| Skill | Fires on |
| --- | --- |
| `dotkernel-psr-standards` | Which PSR applies to a given piece of code, and Laminas Coding Standard style |
| `dotkernel-qa-gate` | Running or interpreting phpcs, phpcbf, phpstan, phpunit; refusing forbidden shortcuts like `@phpstan-ignore` |
| `dotkernel-testing` | Unit and functional tests, mocking repositories/services, authenticating test requests |
| `dotkernel-security` | Auth, authorization config, CORS, sessions/cookies, secrets, `*.local.php` vs. `*.global.php`, raw DQL/SQL |
| `dotkernel-troubleshooting` | Symptom-to-cause lookup for 403/404/406/415/500, container errors, config not taking effect |
| `dotkernel-feature-docs` | Writing and keeping feature docs current — see [Feature Documentation](../feature-docs.md) |
| `dotkernel-package-status` | Whether a Dotkernel package is still maintained and which PHP versions it supports |

## Dependency policy

| Skill | Fires on |
| --- | --- |
| `dependency-policy` | Any package decision — the order: already installed → `dotkernel/*` → `laminas`/`mezzio` → vetted community package → hand-rolled code. See [Dependency Policy](dependency-policy.md) |
