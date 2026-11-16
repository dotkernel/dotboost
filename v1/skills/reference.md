# Reference

## Variant detection

| Skill | Loads on |
| --- | --- |
| `dotkernel-project-variants` | Finding whether a repo is API, Admin, Frontend, Light, Queue, or a derived project, and what that means for other topics |

## Structure and naming

| Skill | Loads on |
| --- | --- |
| `dotkernel-module-structure` | Deciding where a new file belongs (application module vs. the shared Core layer), and registering the file |
| `dotkernel-handler-naming` | PSR-15 handler class names, route URLs and names, authorization keys, PATCH vs. POST |
| `dotkernel-api-endpoint` | API only. Adding or changing an endpoint: `/account` and action-segment URLs, `#[Resource]` loading, response helpers, `operationId`, guest grants, and the end-to-end checklist before you call the endpoint done |
| `dotkernel-dot-maker` | Scaffolding a module, entity, service, handler, form, or command with `composer make …` |
| `dotkernel-core-submodule` | Changes to the Core layer, and git submodule mechanics to share code between projects |

## Data layer

| Skill | Loads on |
| --- | --- |
| `dotkernel-doctrine-entities` | Entities, columns, relations, indexes, repositories, backed enums with DBAL types, fixtures, migrations |
| `dotkernel-input-validation` | InputFilters, Input classes, laminas-form Forms, CSRF, upload validation |

## Request lifecycle and responses

| Skill | Loads on |
| --- | --- |
| `dotkernel-responses` | Shaping handler output: HAL resources/collections and the MetadataMap, or templates/redirects/flash messages. Also pagination and error bodies |
| `dotkernel-openapi` | Documenting an endpoint with swagger-php attributes, for projects that publish OpenAPI |
| `dotkernel-evolution-pattern` | Non-breaking API evolution: Sunset/Link headers and deprecation, and `410 Gone` after the sunset date, instead of `/v2` or a version prefix |

## Quality, security, and process

| Skill | Loads on |
| --- | --- |
| `dotkernel-psr-standards` | Which PSR applies to a given piece of code, and Laminas Coding Standard style |
| `dotkernel-qa-gate` | Running or interpreting phpcs, phpcbf, phpstan, phpunit. Refusing forbidden shortcuts such as `@phpstan-ignore` |
| `dotkernel-testing` | Unit and functional tests, mocking repositories/services, authenticating test requests |
| `dotkernel-security` | Auth, authorization config, CORS, sessions/cookies, secrets, `*.local.php` vs. `*.global.php`, raw DQL/SQL |
| `dotkernel-troubleshooting` | Finding the cause of a symptom: 403/404/406/415/500, container errors, config that has no effect |
| `dotkernel-feature-docs` | Writing feature docs and keeping them current. See [Feature Documentation](../feature-docs.md) |

## Dependency policy

| Skill | Loads on |
| --- | --- |
| `dotkernel-package-status` | Any package decision, in this order: already installed → `dotkernel/*` → `laminas`/`mezzio` → vetted community package → hand-rolled code. Also whether a Dotkernel package is still maintained and which PHP versions it supports, from the dotkernel.com listing. See [Package Status](dotkernel-package-status.md) |

## Writing style

| Skill | Loads on |
| --- | --- |
| `dotkernel-writing-style` | Any prose, written in ASD-STE100 Simplified Technical English at a Strict or a Standard level: chat answers, commit and tag messages, MR/PR descriptions, Markdown files, code comments, docblock descriptions, exception messages, CLI output and OpenAPI descriptions. The skill does not apply to the code itself |
