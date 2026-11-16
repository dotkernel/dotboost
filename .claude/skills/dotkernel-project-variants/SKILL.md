---
name: dotkernel-project-variants
description: >
  Use at the start of any non-trivial task in a Dotkernel repository, and whenever a convention
  might differ between projects. It finds whether this is Dotkernel API, Admin,
  Frontend, Light, Queue or a derived project, and what that means for handler naming,
  authorization config, responses, forms, templates, documentation and tests. Also use when a
  skill's guidance does not match what the repo actually contains, or when the same feature has
  to be built in more than one Dotkernel project.
---

# Which project am I in, and what changes?

```text
Applies to
  Projects:  - all
  Packages:  - none
```

First, find the project variant.
Then apply its conventions.
If you guess, you can write wrong code that looks correct.

The tables below describe the default branches of the stock repositories on 2026-10-30.
The branches are API `7.0`, Admin `7.0`, Frontend `5.0`, Light `1.0` and Queue `2.0`.
Other branches and derived projects can be different.
When they are different, the repository that you work in has priority.

## Detection

Read `composer.json`:

```bash
grep -m1 '"name"' composer.json
grep -A 12 '"psr-4"' composer.json
grep -E 'mezzio-hal|laminas-form|dot-controller|dot-session|dot-rbac-guard|oauth2|swagger-php|dot-cli|messenger' composer.json
```

Then confirm with the filesystem:

```bash
ls src                                   # module names, and whether a Core layer exists
ls src/*/templates 2>/dev/null           # templates present → templated project
ls src/*/src/Controller 2>/dev/null      # controllers present → Frontend-style
ls config/autoload | grep -i authorization
ls src/*/src/OpenAPI.php 2>/dev/null     # documented API
```

| Variant | Root namespace | Distinctive packages | Distinctive files |
| --- | --- | --- | --- |
| **API** | `Api\` + `Core\` | `mezzio/mezzio-hal`, `mezzio-authentication-oauth2`, `zircote/swagger-php`, `mezzio/mezzio-cors` | `src/Core/`, `Collection/`, `OpenAPI.php`, `authorization.global.php`, `documentation/command/` |
| **Admin** | `Admin\` + `Core\` | `dot-session`, `dot-rbac-guard`, `dot-twigrenderer`, `dot-flashmessenger` | `src/Core/`, `templates/`, `Form/`, `authorization.global.php` + `authorization-guards.global.php` |
| **Frontend** | `Frontend\` | `dot-controller`, `laminas/laminas-form`, `dot-session`, `dot-rbac-guard` | `Controller/`, `templates/`, `Form/`, `Entity/` inside modules, `data/doctrine/migrations/` |
| **Light** | `Light\` | `mezzio-twigrenderer` and few other packages: no Doctrine, no session, no forms | `Handler/`, `templates/`, hand-written `Factory/` classes |
| **Queue** | `Queue\` (flat, `src/`) | `dot-cli`, `netglue/laminas-messenger`, `symfony/redis-messenger` | `src/Swoole/Command/`, `src/App/Message/`, no HTTP routes |

A project derived from one of these projects keeps the conventions of its parent.
Find the parent from the PSR-4 roots and the installed packages.

## What actually differs

| Concern | API | Admin | Frontend | Light | Queue |
| --- | --- | --- | --- | --- | --- |
| Request entry point | handler, `{Verb}{Resource}[{Sub}][{Action}]{Resource\|Collection}Handler` | handler, `{Verb}{Action}{Resource}[Form]Handler`, for example `GetCreateAdminFormHandler`, `PostCreateAdminHandler` | controller with an `{action}` route segment, for example `UserController` | handler, for example `GetPageViewHandler` | console command |
| Update verb | `PATCH` | `POST` (form submit) | `POST` (form submit) | n/a | n/a |
| Authorization | RBAC roles → route-name permissions, `authorization.global.php` | roles → permissions in `authorization.global.php`, and route name → permission in `authorization-guards.global.php` | the same two files, with guards keyed by route **and action** | none | none |
| Unlisted route | denied | **allowed**: guards use `POLICY_ALLOW` | **allowed**: guards use `POLICY_ALLOW` | n/a: each route is public | n/a |
| Input | `laminas-inputfilter` | `laminas-form` (wrapping an InputFilter) + CSRF | `laminas-form` + CSRF | none | message payloads |
| Response | HAL resource/collection, ProblemDetails errors | rendered template, redirect, flash message | rendered template, redirect, flash message | rendered template | exit codes, logs |
| Documentation | per-module `OpenAPI.php`, `documentation/command/*.md` | none | none | none | none |
| Sessions/CSRF | none: stateless tokens | required | required | none | n/a |
| Entities | `Core` layer | `Core` layer | inside each module | none | none |
| Migrations | `src/Core/src/App/src/Migration/` | `src/Core/src/App/src/Migration/` | `data/doctrine/migrations/` | none | none |
| DI | `#[Inject]` + `AttributedServiceFactory` | `#[Inject]` + `AttributedServiceFactory` | `#[Inject]` + `AttributedServiceFactory` | hand-written factories | `#[Inject]` + `AttributedServiceFactory` |
| Scaffolding | `dot-maker` | `dot-maker` | none | none | none |
| Tests | `test/Unit/`, `test/Functional/` | `test/Unit/`, `test/Functional/` | `test/Unit/` | `test/Unit/` | `test/App/`, `test/Swoole/` |

The `documentation/` directory is the least reliable row.
Derived projects add it or remove it freely.
Before you write docs there (`dotkernel-feature-docs`), make sure that the directory exists.
Do not infer that it exists.

## What is the same everywhere

- Mezzio is the base, with one `ConfigProvider` for each module, registered in `config/config.php`.
- Laminas Coding Standard, phpstan and phpunit, with `composer check`.
  Projects that render Twig templates also have `composer twig-cs-check`.
- Use evolution, not versioning, for anything that clients depend on.
- Secrets only in `*.local.php`.
- UTF-8, LF, `declare(strict_types=1)`.

## Working across two projects at once

In the stock repositories, only API and Admin share a `Core` layer.
Both contain the same `Core\` modules over one database.
For a feature in these two projects, put the entity, the repository and the shared service in `Core` **once**.
Each project gets its own handlers, routes, authorization entries and presentation.
When you change a `Core` signature, you change it for each project on that database.
Before you change it, examine the other projects, and tell the user about the change (see `dotkernel-core-submodule`).

Frontend keeps its own entities and migrations.
Thus, a feature in Frontend and API means two models of the same data.
Tell the user this, and do not assume a shared `Core`.

## Rule of thumb

Before you write a file, open the two nearest existing files of the same type **in this repo**.
Make your file match them.
This rule has priority over each table above, because the files show the version that you actually use.
When the repo contradicts a skill, follow the repo.
Tell the user that the skill needs an update.
