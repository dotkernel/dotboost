---
name: dotkernel-application-variants
description: >
  Use at the start of any non-trivial task in a Dotkernel repository, and whenever a convention
  might differ between applications — to work out whether this is Dotkernel API, Admin,
  Frontend, Light, Queue or a derived project, and what that implies for handler naming,
  authorization config, responses, forms, templates, documentation and tests. Also use when a
  skill's guidance does not match what the repo actually contains, or when the same feature has
  to be built in more than one Dotkernel application.
---

# Which application am I in, and what changes?

Detect first, then apply. Guessing produces confidently wrong code that looks plausible.

## Detection

Read `composer.json`:

```bash
grep -m1 '"name"' composer.json
grep -A 12 '"psr-4"' composer.json
grep -E 'mezzio-hal|laminas-form|laminas-session|oauth2|swagger-php|dot-cli' composer.json
```

Then confirm with the filesystem:

```bash
ls src                                   # module names and the Core layer
ls src/*/templates 2>/dev/null           # templates present → templated app
ls config/autoload | grep -i authorization
ls src/*/src/OpenAPI.php 2>/dev/null     # documented API
```

| Variant | Root namespace | Distinctive packages | Distinctive files |
| --- | --- | --- | --- |
| **API** | `Api\` | `mezzio/mezzio-hal`, `mezzio-authentication-oauth2`, `zircote/swagger-php`, `mezzio/mezzio-cors` | `Collection/`, `OpenAPI.php`, `authorization.global.php` |
| **Admin** | `Admin\` | `laminas/laminas-form`, session auth | `templates/`, `Form/`, `authorization-guards.global.php` |
| **Frontend** | `Frontend\` | `laminas/laminas-form`, session auth | `templates/`, `Form/`, `authorization-guards.global.php` |
| **Light** | `Light\` | minimal set | verify against the repo — Light is a starter and carries less |
| **Queue** | `Queue\` | `dotkernel/dot-cli`, queue transport | `Command/`, little or no HTTP surface |

A project derived from one of these keeps its parent's conventions. Infer the parent from the
PSR-4 roots and installed packages.

## What actually differs

| Concern | API | Admin / Frontend | Queue |
| --- | --- | --- | --- |
| Handler naming | `{Verb}{Resource}[{Sub}][{Action}]{Resource\|Collection}Handler` | `{Verb}{Resource}{Action}[Form]Handler` — e.g. `GetProductCreateFormHandler`, `PostProductCreateHandler` | mostly Commands, not handlers |
| Update verb | `PATCH` | `POST` (form submit) | n/a |
| Authorization | RBAC, `config/autoload/authorization.global.php` | guards, `config/autoload/authorization-guards.global.php` | n/a or CLI-gated |
| Input | `laminas-inputfilter` | `laminas-form` (which wraps an InputFilter) + CSRF | InputFilter or command options |
| Response | HAL resource/collection, ProblemDetails errors | rendered template, redirect, flash message | exit codes, logs |
| Pagination | `…Collection` + HAL `_links` | paginated template partial | n/a |
| Documentation | per-module `OpenAPI.php` | none | `documentation/command/*.md` |
| Sessions/CSRF | none — stateless tokens | required | n/a |
| CORS | configured | usually not | n/a |
| Entities | `Core` layer | `Core` layer | `Core` layer |

## What is the same everywhere

- The `Core` layer owns every Doctrine entity, repository, enum and DBAL type.
- PSR-4 layout: `<App>\<Module>\` → `src/<Module>/src/`, `Core\<Module>\` → `src/Core/src/<Module>/src/`.
- Attribute DI: `#[Inject]` + `AttributedServiceFactory`.
- Per-module `ConfigProvider` registered in `config/config.php`; routes in `RoutesDelegator`.
- Route name = authorization key.
- `dot-maker` for scaffolding, adapting its output to the detected variant.
- Laminas Coding Standard, phpstan, phpunit; `composer check`.
- Evolution over versioning for anything clients depend on.
- Secrets only in `*.local.php`.
- UTF-8, LF, `declare(strict_types=1)`.

## Working across two applications at once

A feature spanning, say, API and Admin means: the entity, repository and shared service go in
`Core` **once**; each application gets its own handlers, routes, authorization entries and
presentation. Change a `Core` signature and you have changed it for every application on that
database — check the others before you do, and mention it (see `dotkernel-core-submodule`).

## Rule of thumb

Before writing a file, open the two closest existing files of the same kind **in this repo** and
match them. That beats every table above, because it reflects the version you are actually on.
When the repo contradicts a skill, follow the repo and tell the user the skill needs updating.
