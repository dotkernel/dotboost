---
name: dotkernel-handler-naming
description: >
  Use when you name or review a PSR-15 request handler class, a route URL, a route name, or an
  authorization key in any Dotkernel project. This includes when you create a new endpoint or page,
  rename one, add a route to a RoutesDelegator, wire a handler into a ConfigProvider, or check
  that a handler follows the Dotkernel naming pattern. Also use when a route returns 403 or 404
  unexpectedly, when choosing between PATCH and POST, or when deciding whether a handler needs
  a Form suffix.
---

# Handler, route and authorization naming

```text
Applies to
  Projects:  - Dotkernel API
             - Dotkernel Admin
             - Dotkernel Light
  Packages:  - none
```

The naming pattern lets each developer know what a file does from its name only.
The pattern has **two dialects**, and the sequence of the words is different in each dialect.
Select the dialect from the variant (`dotkernel-project-variants`).
Frontend has no handlers.
It routes to controllers with an `{action}` segment, so this skill does not apply to Frontend.

## Dialect A: API (REST, no forms)

```text
{HttpVerb}{Resource}[{SubResource}][{Action}]{Resource|Collection}Handler
```

Put the resource first, then the optional action.
Add the suffix `ResourceHandler` (a single entity) or `CollectionHandler` (a paginated list).
A non-CRUD action that returns a message, not a resource, ends in `…{Action}Handler`.
Do not put a CRUD word in the class name, because the HTTP verb gives that information.
**Use PATCH for updates, never PUT.**

| Class | Route |
| --- | --- |
| `GetUserCollectionHandler` | `GET /user` |
| `PostUserResourceHandler` | `POST /user` |
| `GetUserResourceHandler` | `GET /user/{id}` |
| `PatchUserResourceHandler` | `PATCH /user/{id}` |
| `DeleteUserResourceHandler` | `DELETE /user/{id}` |
| `PatchUserActivateHandler` | `PATCH /user/{id}/activate` |
| `PostUserAvatarResourceHandler` | `POST /user/{id}/avatar` |
| `GetUserRoleCollectionHandler` | `GET /user/role` |

## Dialect B: Admin (templated, with forms)

```text
{HttpVerb}{Action}{Resource}[{SubResource}][Form]Handler
```

Put the action first, then the resource.
This is the opposite sequence of the API.
A `Form` suffix means that the handler **renders a form** that submits to a different handler.
The handlers are always a pair: a `Get…FormHandler` that renders and a `Post…Handler` that does the action.
This also applies to deletes, which get a confirmation form.

| Class | Route | Route name |
| --- | --- | --- |
| `GetCreateAdminFormHandler` | `GET /admin/create-admin` | `admin::create-admin-form` |
| `PostCreateAdminHandler` | `POST /admin/create-admin` | `admin::create-admin` |
| `GetEditAdminFormHandler` | `GET /admin/edit-admin/{id}` | `admin::edit-admin-form` |
| `PostEditAdminHandler` | `POST /admin/edit-admin/{id}` | `admin::edit-admin` |
| `GetDeleteAdminFormHandler` | `GET /admin/delete-admin/{id}` | `admin::delete-admin-form` |
| `PostDeleteAdminHandler` | `POST /admin/delete-admin/{id}` | `admin::delete-admin` |
| `GetListAdminHandler` | `GET /admin/list-admin` | `admin::list-admin` |
| `PostEditUserAvatarHandler` | `POST /user/edit-user-avatar/{id}` | `user::edit-user-avatar` |
| `GetListUserHandler` | `GET /user/list-user` | `user::list-user` |

The action words are `Create`, `Edit`, `Delete`, `List` and `View`, and also explicit verbs (`ChangeAccountPassword`, `Logout`, `Store`).
Admin uses **POST for updates** (a browser form submit), never PATCH.
Admin puts the action in the URL.

Light is a starter with two handlers, `GetIndexViewHandler` and `GetPageViewHandler`.
The second handler registers one `GET` route for each template in the config, with the name `<prefix>::<template>`.
The Light names put the resource first.
When you add to Light, use the same pattern as these two files, not one of the two dialects.

## Name a new handler: the one-minute method

1. Find the HTTP verb.
   This gives the prefix.
2. API: write the resource, then the sub-resource, then a non-CRUD action.
   Admin: write the action, then the resource.
3. Admin only: if the handler renders a form that the user submits later, add `Form`.
4. API only: for one item, add `Resource`.
   For a list, add `Collection`.
5. Add `Handler`.

## URL conventions

API:

- Use lowercase, and `kebab-case` for segments with more than one word: `/user/account/reset-password`.
- Use the singular for resource segments: `/user`, not `/users`.
  The verb and the path show that the route is a collection.
- Item identifiers are UUIDs.
  The `REGEXP_UUID` constant in the `App` `ConfigProvider` of Core matches them, and its placeholder is `{id}`.
  Never declare a placeholder without a constraint.
  The UUID pattern prevents a conflict between fixed segments such as `/user/role` and `/user/{id}`.
- Put sub-resources under their parent: `/user/{id}/avatar`.

Admin: `/<module>/<action>-<resource>[/{id}]`, grouped by module prefix, for example `/admin/edit-admin/{id}`.

## Route names

```text
<module>::<action>-<resource>
```

| | API | Admin |
| --- | --- | --- |
| Actions | `list`, `view`, `create`, `update`, `delete`, and also `activate`, `recover`… | `list`, `view`, `create`, `edit`, `delete`, and also `store`, `change`… |
| Route that renders a form | n/a | add `-form`: `admin::edit-admin-form` |
| Example | `PatchUserResourceHandler` → `user::update-user` | `PostEditUserHandler` → `user::edit-user` |

## The route name is the authorization key, but the default is different

- **API**: RBAC permissions are in `authorization.global.php`.
  **If a route name is not in that file, the API denies it for all roles.**
  This is the usual cause of "my new route returns Forbidden".
- **Admin**: `authorization.global.php` maps roles to permissions (`authenticated`, `unauthenticated`, …).
  `authorization-guards.global.php` maps route names to those permissions.
  The guards use `POLICY_ALLOW`, so **a route name that is not in the guards is open to all users, also to guests**.
  A missing entry never causes a 403.
  It causes a page without protection.

## RoutesDelegator style

Group the routes by path prefix.
Sort the routes alphabetically in each group.

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

Handlers contain **no business logic**.
A handler validates the input, calls a service and shapes the response.

- If the project has an abstract handler, extend it.
- If the project uses `dot-dependency-injection`, get the dependencies through `#[Inject]`.
- For errors, throw the typed exceptions of the project.
- Never use `echo`, and never build a response object by hand.

## Checklist for a new route

- [ ] The class name follows the dialect for **this** project.
- [ ] The file is under `src/<Module>/src/Handler/<Resource>[/<Sub>]/`.
- [ ] The class extends the abstract handler of the repository, and gets dependencies through `#[Inject]`.
- [ ] The class is registered in `ConfigProvider` under `factories` (and `delegators` in the API).
- [ ] The route is in `RoutesDelegator`, with a name for this dialect.
- [ ] The authorization entry is added.
      API: add each role that must get access.
      Admin: add a guard rule, because without it the route is public.
- [ ] The presentation is registered: HAL metadata (API) or a template (templated project).
- [ ] The route is documented, if this project publishes OpenAPI.
- [ ] A test covers the success path and the denied path.
- [ ] The route-listing command of the repository shows the route as expected.
