---
name: dotkernel-dot-maker
description: >
  Use before hand-writing any new scaffolding in a Dotkernel project: a module, entity,
  repository, service, service interface, handler, collection, form, input, input filter,
  middleware or CLI command. dot-maker (dotkernel/dot-maker, "composer make …") generates these
  to the Dotkernel file structure and naming pattern. Also use when asked how to create a new
  module, what "composer make" can do, or why generated boilerplate looks a certain way.
---

# dot-maker: generate, then customise

```text
Applies to
  Projects:  - Dotkernel API
             - Dotkernel Admin
  Packages:  - none
```

`dotkernel/dot-maker` generates files that match the Dotkernel/Mezzio layout and the handler naming pattern.
It is similar to the Symfony Maker Bundle.
It has more fixed opinions than the CLI tools of Mezzio, because it targets the Dotkernel conventions.

**Always propose the `composer make …` command before you write boilerplate by hand.**
When you create files manually, you can easily forget a registration.

Not all projects have dot-maker.
The stock API and Admin have it in `require-dev`, with a `make` script alias.
The stock Frontend, Light and Queue do not have it.
Check `composer.json`.
If the project does not have dot-maker, tell the user.
Then copy the nearest existing module by hand.

## Running it

Run `composer make <thing>` or `./vendor/bin/dot-maker <thing>`.
The `composer make` form needs the script alias in `composer.json`.

dot-maker is **interactive**, and it asks a series of questions.
In an agent session, do not pipe answers into it without a check.
Give the user the exact command and the answers to give.
Then continue from the generated files.
Treat generation like an install: the user decides.

## Commands

| Command | Generates |
| --- | --- |
| `module` | A full module: entity, repository, service, one or more handlers, ConfigProvider, RoutesDelegator, and a documentation stub |
| `entity` | `Entity/X.php` and `Repository/XRepository.php` (it skips the file that exists) |
| `repository` | The same pair, from the repository side |
| `service` | `Service/XService.php` and `Service/XServiceInterface.php` |
| `service-interface` | The same pair, from the interface side |
| `handler` | A handler in an existing module |
| `collection` | A `…Collection` (API-style projects) |
| `form` | A Form (Admin, not used in the API) |
| `input` | One `Input/…Input.php` |
| `input-filter` | An InputFilter. It asks for `create`, `edit` or `replace`. |
| `middleware` | A PSR-15 middleware |
| `command` | A CLI command |

**dot-maker detects the Dotkernel project that it runs in**, and it generates the related files.
It generates collections in an API, and forms and templates in Admin.
This detection also helps you to confirm the variant that you think you are in.

## What it does *not* do — your tasks after generation

1. **Register the module.**
   dot-maker creates the `ConfigProvider` and shows what to add.
   You must still add the entry to `config/config.php`.
   You must also add the PSR-4 entries to `composer.json`, which needs user approval.
2. **Configure authorization.**
   Add each new route name to the authorization config of this project.
   API: `authorization.global.php`.
   When an entry is missing there, the API denies the route.
   Admin: `authorization-guards.global.php`.
   When an entry is missing there, the route is open to everyone.
3. **Migrations.**
   dot-maker tells you the command.
   Run `php ./vendor/bin/doctrine-migrations diff`, which asks for approval.
   Then give the user the `migrate` command to run.
   The `guard-bash.sh` hook refuses `migrate` for Claude, with or without approval.
   Never write a migration by hand.
4. **Real logic.**
   Generated services and handlers are skeletons.
   Add the validation, the ownership checks, the presentation metadata and the documentation details.
5. **Tests.**
   dot-maker generates nothing under `test/`.
6. **QA.**
   Run the `cs-fix` script of the repository, then `check`.
   Generated code must also pass phpcs and phpstan.

## Post-generation checklist

- [ ] `composer dump-autoload` is run after each new PSR-4 namespace.
- [ ] The two `ConfigProvider`s (application module and `Core`) are registered in `config/config.php`.
- [ ] The handlers are under `factories`, and in the API also under `delegators`.
- [ ] The service interface is aliased to the concrete service.
- [ ] The routes have names in the dialect of this project (`dotkernel-handler-naming`), and the authorization entries are added.
- [ ] The presentation is registered: HAL metadata or the template path.
- [ ] The documentation is complete with real request and response details, where the project publishes it.
- [ ] The migration is generated, reviewed and applied.
- [ ] The QA suite passes.
- [ ] The generated files are UTF-8 without BOM, with LF line endings.

## When not to use it

Do not use dot-maker to edit an existing class, to add a method, or for any change to one file.
dot-maker creates files.
It does not refactor them.
