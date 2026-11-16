---
name: dotkernel-module-structure
description: >
  Use when you create, move, rename or locate any file in a Dotkernel project. This includes:
  deciding whether code belongs in an application module or the shared Core layer, adding a
  Handler, Service, Collection, Form, InputFilter, Input, Entity, Repository, Enum, DBAL type,
  Command, Middleware, ConfigProvider or RoutesDelegator, registering a module in
  config/config.php and composer.json autoload, or answering "where does this go" and "why is
  this class not found".
---

# Module and file structure

```text
Applies to
  Projects:  - Dotkernel API
             - Dotkernel Admin
  Packages:  - none
```

First, identify the variant (`dotkernel-project-variants`).
The stock API and Admin use the two-layer split below.
The artefacts in a module are different between the API and the Admin.
Frontend keeps entities in its own modules.
Light has no persistence.
Queue is one flat `Queue\` namespace.
None of these three has a `Core` layer.

## The two layers

| Layer | Namespace | Path | Contains |
| --- | --- | --- | --- |
| Application module | `<App>\<Module>\` | `src/<Module>/src/` | Code for HTTP and CLI |
| Shared core module | `Core\<Module>\` | `src/Core/src/<Module>/src/` | Persistence and the shared domain |

`<App>` is the root namespace of the project: `Api` or `Admin`.
`Core` is designed as a git submodule that the projects on one database share (see `dotkernel-core-submodule`).
**No code in `Core` can depend on a project namespace.**

**Golden rule: only Core manages database entities.**

### Which layer?

| Artefact | Layer |
| --- | --- |
| Handler, RoutesDelegator, Collection, Form, InputFilter, Input, Service, ServiceInterface, OpenAPI | Application module |
| Entity, Repository, Enum, DBAL type, EventListener, Fixture, Migration, shared Message catalogue | `Core` |
| Middleware, Attribute, Exception, Guard, Template helper | The `App` module of the project (cross-cutting) |
| CLI Command | The application module if the command is for one feature. `Core\App\Command` if it is for the infrastructure. |
| ConfigProvider | **Both**: one for each module, in each layer |

A service imports `Core\<Module>\Entity\X`.
Never do the reverse.

## Canonical module layout

The shared skeleton:

```text
src/<Module>/src/
├── Handler/<Resource>/…            one folder for each resource, nested for sub-resources
├── InputFilter/
│   ├── Input/…Input.php
│   └── {Create,Update}<X>InputFilter.php
├── Service/
│   ├── <X>Service.php
│   └── <X>ServiceInterface.php
├── ConfigProvider.php
└── RoutesDelegator.php

src/Core/src/<Module>/src/
├── Entity/<X>.php
├── Repository/<X>Repository.php
├── Enum/<X>StatusEnum.php
├── DBAL/Types/<X>StatusEnumType.php
└── ConfigProvider.php
```

The variants add these files to the application module:

- **API**: `Collection/<X>Collection.php`, `OpenAPI.php`
- **Admin**: `Form/<X>Form.php`, and templates under `src/<Module>/templates/<module>/`

The handler folders follow the URL.
For example, the handler for the route `/user/{id}/avatar` is in `Handler/User/Avatar/`.

## Wiring a new module — do all four steps, or the module does nothing and gives no error

1. In `composer.json`, add to `autoload.psr-4`: `"<App>\\Book\\": "src/Book/src/"` and `"Core\\Book\\": "src/Core/src/Book/src/"`.
   **This is a change to composer.json, so ask the user first.**
   Then the user runs `composer dump-autoload`.
2. In `config/config.php`, add the two `ConfigProvider::class` entries to the Dotkernel modules block, in alphabetical order.
3. In the `ConfigProvider` of the module, fill `dependencies` (factories, delegators, aliases).
   Also add the other config that the variant needs.
   This is the HAL `MetadataMap` for the API, `templates` for templated projects, and `doctrine.types` for enum columns.
4. In the authorization config, add an entry for each new route name.
   API: `config/autoload/authorization.global.php`.
   When an entry is missing, the API denies the route.
   Admin: `config/autoload/authorization-guards.global.php`.
   When an entry is missing, the Admin route is **open to everyone**, because the guards use `POLICY_ALLOW`.

Production caches the config.
After a config change, run the cache-clear script of the repository (frequently `composer clear-config-cache`).

## ConfigProvider contract

```php
public function __invoke(): array
{
    return [
        'dependencies' => $this->getDependencies(),
        // API:    MetadataMap::class => $this->getHalConfig(),
        // Admin:  'templates'        => $this->getTemplates(),
    ];
}
```

- `delegators`: in the API, each handler maps to the handler delegator factory of the repository.
  Admin handlers have no delegator entry.
  In the Admin, `delegators` holds only `Application::class => [RoutesDelegator::class]` and the form delegators.
- `factories`: each handler and each concrete service maps to `AttributedServiceFactory::class`.
- `aliases`: `BookServiceInterface::class => BookService::class`.

Sort these arrays in alphabetical order, and align `=>`.
phpcs makes the alignment mandatory.

## Other paths

| Path | Purpose |
| --- | --- |
| `config/autoload/*.global.php` | Committed defaults |
| `config/autoload/*.local.php` | Secrets that git ignores. Only the `.dist` templates are committed. |
| `config/pipeline.php` | The order of the PSR-15 middleware |
| `config/routes.php` | Thin. The real routes are in the `RoutesDelegator` of each module. |
| `bin/` | CLI entry points |
| `test/Unit/`, `test/Functional/` | Namespaces as `autoload-dev` defines them |
| `documentation/` | Project docs (CLI command docs, a generated `openapi.json`, Postman collections), if the directory exists. The stock API has one. Derived projects are different, so check. |
| Any Doctrine migrations directory | **Generated**. Never edit these files by hand. |

## Checklist for a new artefact

- [ ] The namespace matches the directory exactly (PSR-4, case-sensitive).
- [ ] The Entity and the Repository are in `Core` (API and Admin) or in the module that owns them (Frontend).
  All code that faces the request is in the application module.
- [ ] The artefact is registered in the `ConfigProvider` of the module.
  API handlers need a factory **and** a delegator.
  Admin handlers need a factory.
- [ ] The route is declared in `RoutesDelegator`, and the authorization entry is added.
- [ ] The presentation is registered: HAL metadata (API) or the template path (templated project).
- [ ] The `OpenAPI.php` operation is added, if this project publishes OpenAPI.
- [ ] A test is added.
