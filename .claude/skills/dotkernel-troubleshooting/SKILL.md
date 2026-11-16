---
name: dotkernel-troubleshooting
description: >
  Use when something in a Dotkernel project does not work and the cause is not clear: a route
  returns 403, 404, 406, 415 or 500 unexpectedly, a service is not found in the container, a
  handler throws while building a response, config changes have no effect, routes are missing,
  tests fail in setUp, autoloading fails, a form silently rejects a submit, or CORS preflight
  fails. Start here before reading code at random.
---

# Symptom → cause

```text
Applies to
  Projects:  - all
  Packages:  - none
```

Read the sections from the top down.
Usually, the first section that matches gives the cause.

## 403 / access denied on a route you just added

API: the RBAC permissions in `authorization.global.php` do not contain the route name.
Route names **are** authorization keys.
Add the route name for each role that must get access to the route.
Read the comment about the role hierarchy at the top of the file.
The direction of inheritance is not always the direction that people expect.

Admin / Frontend: a *missing* guard entry does not cause a 403.
The guards use `POLICY_ALLOW`, so a route that is not in the list is open to all users.
In these projects, a 403 means that `authorization-guards.global.php` has a guard rule for the route.
It also means that the role of the caller does not have that permission in `authorization.global.php`.
The opposite symptom is a new page that a logged-out user can open.
That symptom comes from the missing entry.

## 404 on a route you just added

1. `config/config.php` does not list the `ConfigProvider` of the module.
2. That ConfigProvider does not register `RoutesDelegator` as a delegator on `Application::class`.
3. The config cache is stale.
   Run the cache-clear script of the repository.
4. Use the route-listing command to make sure.
   If the route is not in the list, the cause is 1, 2 or 3.
   If the route is in the list, your URL or method is different from the route that you call.
   API updates use PATCH.
   Templated projects submit with POST.

## 404 on an existing route with a valid identifier

The resource-resolution attribute did not find the entity.
The cause is one of these:

- The identifier and the placeholder do not match.
- The record really does not exist.

## "Service not found" / container exception

One of these two causes applies:

- The `factories` entry is missing.
- You type-hinted an interface, and no `aliases` entry maps it to the concrete class.

Both entries are in the `ConfigProvider` of the module.

## Handler throws while building a response

The delegator registration of the handler is missing.
In the API, this is the handler delegator that injects the HAL response factory and the resource generator.
The constructor does not inject these two services.

## `#[Inject]` appears to be ignored

The class uses the wrong factory.
It must use `AttributedServiceFactory::class`.
Do not use `InvokableFactory` or a hand-written factory.

## Config change has no effect

The config cache is stale.
Run `composer clear-config-cache`.
Also check the load order: `*.local.php` overrides `*.global.php`.
Under tests, the test-local file overrides both.

## 406 Not Acceptable

The `Accept` header does not match the values that content negotiation allows for that route.

## 415 Unsupported Media Type

The `Content-Type` header of a write request is missing or wrong.

## Empty or malformed body on a write

One of these two causes applies:

- The malformed-body middleware rejected the body.
- You read the raw stream after the body-params middleware consumed it.

Use `getParsedBody()`.

## A form submit is silently rejected (templated projects)

The CSRF token is missing, stale or not validated.
Make sure that the form has the CSRF element.
Make sure that the handler validates the token.
When the session rotates, the forms that are open in the browser become invalid.

## CORS preflight fails

Pipe the CORS middleware **before** the routing middleware.
The CORS local config must list the origin.
This config file does not exist until you copy it from the `.dist` file.

## 403 with a token that "should" work

In stock Dotkernel API, a token that fails validation does not cause a 401.
The authentication middleware changes each request that it cannot authenticate into a guest request.
Thus, a route that the guest role cannot use returns 403.
The possible causes are:

- The token expired.
- The client id or the scope is wrong.
- Somebody generated the OAuth keys again after the server issued the token.

When the 403 continues with a newly issued token, the cause is an authorization problem.
Read "403 / access denied on a route you just added" above.

A 401 comes only from the operations that issue tokens.
It can also come from a project that pipes Mezzio's own `AuthenticationMiddleware` instead of the stock middleware.
That middleware returns 401 when authentication fails.
Find which middleware `config/pipeline.php` or the middleware list of the route uses.

## Class not found after adding a namespace

Run `composer dump-autoload`.
Then examine the PSR-4 mapping.
The mapping is case-sensitive, also when the local filesystem is not case-sensitive.

## Tests fail in `setUp()`

- *"test mode is NOT enabled"* → the test-local config file is missing.
- *"non in-memory database"* → the file exists, but it does not configure an in-memory database.
  Do not point the tests at a real database.
- Errors about the column type occur only under test → an enum DBAL type has no SQLite branch.

## Schema-validation CI job is red

The entities and the migrations are not in sync.
Generate a migration.
Do not edit the entity to match an old migration.
Do not edit the migration by hand.

## Passes locally, fails in CI (or the reverse)

One of these causes applies:

- The CI matrix uses a different PHP version.
- The local `.phpcs-cache` or `.phpunit.result.cache` is stale.

## Diagnostic commands

All these commands only read data, except `composer clear-config-cache`.
That command deletes the cached merged config.
It is safe, and it changes no committed file, but it writes data.

```bash
php bin/cli.php route:list          # API / Admin, or the equivalent command of the repository
php bin/cli.php                     # console commands: API, Admin, Queue (Frontend and Light have no bin/cli.php)
composer clear-config-cache
php -l <file>
composer cs-check
composer static-analysis
php ./vendor/bin/doctrine-migrations status
php ./bin/doctrine fixtures:list
```

If no section above matches, tell the user and ask.
Do not edit config files to see what occurs.
