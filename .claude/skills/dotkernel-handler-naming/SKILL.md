---
name: dotkernel-handler-naming
description: >
  Use when naming or reviewing a PSR-15 request handler class, a route URL, a route name, or an
  authorization key in any Dotkernel application — creating a new endpoint or page, renaming
  one, adding a route to a RoutesDelegator, wiring a handler into a ConfigProvider, or checking
  that a handler follows the Dotkernel naming pattern. Also use when a route returns 403 or 404
  unexpectedly, when choosing between PATCH and POST, or when deciding whether a handler needs
  a Form suffix.
---

# Handler, route and authorization naming

The naming pattern exists so that any developer can tell what a file does from its name alone.
It has **two dialects** — pick by variant (`dotkernel-application-variants`).

## Shared shape

```
{HttpVerb}{Resource}[{SubResource}][{Action}][Form]{Resource|Collection}Handler
```

Every dialect uses: the HTTP verb, the resource name, an optional sub-resource, an optional
action, and the literal `Handler`. CRUD wording is fixed across Dotkernel: **Create**,
**Get** (for read), **Edit** (for update), **Delete**.

## Dialect A — API (REST, no forms)

Suffix with `ResourceHandler` (a single entity) or `CollectionHandler` (a paginated list).
Non-CRUD actions that return a message rather than a resource end in `…{Action}Handler`.
**Updates use PATCH, never PUT.**

| Class | Route |
| --- | --- |
| `GetUserCollectionHandler` | `GET /user` |
| `PostUserResourceHandler` | `POST /user` |
| `GetUserResourceHandler` | `GET /user/{uuid}` |
| `PatchUserResourceHandler` | `PATCH /user/{uuid}` |
| `DeleteUserResourceHandler` | `DELETE /user/{uuid}` |
| `PatchUserActivateHandler` | `PATCH /user/{uuid}/activate` |
| `PostUserAvatarResourceHandler` | `POST /user/{uuid}/avatar` |
| `GetUserRoleCollectionHandler` | `GET /user/role` |

## Dialect B — Admin / Frontend / Light (templated, form-driven)

A `Form` in the name means the handler **returns a form** that will submit to another handler.
The pair is always: a `Get…FormHandler` that renders, and a `Post…Handler` that acts.
Listing handlers end in `ListHandler`.

| Class | Purpose |
| --- | --- |
| `GetProductCreateFormHandler` | renders the create form |
| `PostProductCreateHandler` | receives the submit, creates |
| `GetProductEditFormHandler` | renders the edit form |
| `PostProductEditHandler` | receives the submit, updates |
| `PostProductDeleteHandler` | deletes |
| `GetProductListHandler` | lists, with filtering |

Templated apps use **POST for updates** (browser form submit), not PATCH.

## Naming a new one — the one-minute method

1. Which HTTP verb? → prefix.
2. Which resource, and is it nested under another? → resource + sub-resource.
3. Is the action plain CRUD, or something else (`Activate`, `Recover`, `Deactivate`)? → action.
4. Does it return a form to be submitted later? → insert `Form` (dialect B only).
5. Does it return one thing or a list? → `Resource` / `Collection` (dialect A) or `List`
   (dialect B).
6. Append `Handler`.

## URL conventions

- Lowercase, `kebab-case` for multi-word segments: `/user/account/reset-password`.
- Singular resource segments: `/user`, not `/users` — collection-ness comes from verb and path.
- Identifiers use the repo's UUID regex constant, not a bare `{id}`, where the repo does so.
- Sub-resources nest: `/user/{uuid}/avatar`.

## Route name = authorization key

```
<module>::<action>-<resource>
```

Actions: `list`, `view`, `create`, `update`, `delete`, plus explicit verbs for non-CRUD
(`activate`, `deactivate`, `recover`, `check`).

| Handler | Route name |
| --- | --- |
| `GetUserCollectionHandler` / `GetUserListHandler` | `user::list-user` |
| `GetUserResourceHandler` | `user::view-user` |
| `PostUserResourceHandler` / `PostUserCreateHandler` | `user::create-user` |
| `PatchUserResourceHandler` / `PostUserEditHandler` | `user::update-user` |
| `DeleteUserResourceHandler` / `PostUserDeleteHandler` | `user::delete-user` |

That string is consumed by the authorization layer — RBAC permissions in
`authorization.global.php` (API) or guards in `authorization-guards.global.php`
(Admin / Frontend). **A route whose name is absent there is denied for every role**, which is
the usual cause of "my new route returns Forbidden".

## RoutesDelegator style

Group by path prefix; order methods alphabetically inside a group.

```php
$routeCollector->group('/book')
    ->get('', GetBookCollectionHandler::class, 'book::list-book')
    ->post('', PostBookResourceHandler::class, 'book::create-book');

$routeCollector->group('/book/' . $id)
    ->delete('', DeleteBookResourceHandler::class, 'book::delete-book')
    ->get('', GetBookResourceHandler::class, 'book::view-book')
    ->patch('', PatchBookResourceHandler::class, 'book::update-book');

return $callback();
```

## Handler body conventions (all variants)

Handlers hold **no business logic**: validate → call service → shape response. Extend the
application's abstract handler if it has one, take dependencies through `#[Inject]`, throw the
application's typed exceptions for errors, and never `echo` or hand-build a response object.

## Checklist for a new route

- [ ] Class name follows the dialect for **this** application.
- [ ] File under `src/<Module>/src/Handler/<Resource>[/<Sub>]/`.
- [ ] Extends the repo's abstract handler; deps via `#[Inject]`.
- [ ] Registered in `ConfigProvider` under both `factories` and `delegators`.
- [ ] Route in `RoutesDelegator` named `<module>::<action>-<resource>`.
- [ ] Authorization entry added for every role that should reach it.
- [ ] Presentation registered — HAL metadata (API) or template (templated app).
- [ ] Documented, if this application publishes OpenAPI.
- [ ] Test covering success and the denied path.
- [ ] The repo's route-listing command shows it as expected.
