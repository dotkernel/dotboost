---
name: dotkernel-api-endpoint
description: >
  Use when you add or change an endpoint in a Dotkernel API project (or a project derived
  from it): a new route, handler, request or response contract, resource loading by id, a
  caller-scoped /account route, an action segment like /activate, an upload, a guest grant, or
  an operationId. Also use it as the end-to-end checklist before you call an API endpoint done.
  Not for Admin, Frontend, Light or Queue projects.
---

# API endpoint conventions

```text
Applies to
  Projects:  - Dotkernel API
  Packages:  - none
```

**API only.**
First, use `dotkernel-project-variants` to confirm the variant.
This skill does not apply to a templated project.
In a templated project, use `dotkernel-handler-naming` dialect B.

This skill gives the checklist and the API rules that no other skill gives.
For all other topics, it refers to the skill that owns the topic.
When the repository is different from the stock skeleton, follow the repository.
Then tell the user that this skill needs an update.

## Where each topic lives

| Concern | Skill |
| --- | --- |
| Location of files, ConfigProvider wiring, registration of a new module | `dotkernel-module-structure` |
| Handler class name, URL shape, route name, RoutesDelegator style | `dotkernel-handler-naming` |
| InputFilters, Inputs, whitelist for sort and filter | `dotkernel-input-validation` |
| HAL resources and collections, pagination, errors | `dotkernel-responses` |
| Authorization config, ownership, guest access | `dotkernel-security` |
| `OpenAPI.php` operations | `dotkernel-openapi` |
| Coverage matrix and test helpers | `dotkernel-testing` |
| Change to a live contract, deprecation | `dotkernel-evolution-pattern` |
| Scaffolding before you write code by hand | `dotkernel-dot-maker` |

## URLs and methods

- The resource of the caller is under `account`, never under an id: `/user/account`, `/user/account/avatar`.
  Its handlers are in `Handler/Account/`.
- An action on an item is a verb segment at the end of the path, with `PATCH`: `PATCH /user/{id}/activate`.
- A process that creates no resource is a `POST`.
  For example, `POST /user/account/recover` sends an e-mail.
- A one-time token from an e-mail link is a path placeholder: `/user/account/reset-password/{hash}`.
- A related list with no parent item is a fixed segment: `/user/role`.
- Do not use `PUT`.
  Do not use a version prefix by default.
  `dotkernel-evolution-pattern` gives the rare exceptions and tells how to propose one.

## The caller and the item in the path

- The caller is `$request->getAttribute(IdentityInterface::class)`.
  Never take the id of the caller from the path, the query or the body.
- To load the item in the path, put `#[Resource(entity: X::class)]` on `handle()`.
  The resource provider middleware finds the item by `{id}`.
  When the item is missing or `isDeleted()`, the middleware throws `NotFoundException`.
  Otherwise, it puts the item on the request as `$request->getAttribute(X::class)`.
  The handler does not do that check again.
- `identifier:` and `placeholder:` find an item by a different column.
- `guard:` takes an invokable `ResourceGuardInterface` class that refuses access with an exception.
  This is one method to enforce ownership.
  For the alternatives, see `dotkernel-security`.

## Request and response shape

- Request and response fields are `camelCase`: `passwordConfirm`, `firstName`.
- Validate an upload from `$request->getUploadedFiles()`.
  Give its route a `multipart/form-data` entry in `config/autoload/content-negotiation.global.php`, with the route name as the key.
- Return responses only through the `AbstractHandler` helpers:

| Helper | Status | Use |
| --- | --- | --- |
| `createResponse($request, $entityOrCollection)` | 200 | read, update |
| `createdResponse($request, $entity)` | 201 | create |
| `noContentResponse()` | 204 | delete |
| `infoResponse($message)` | 200 | an action with no resource. The body is `{"info": {"messages": [...]}}` |

- `getArrayCopy()` never shows a password hash, a token, a one-time hash or an internal numeric id.
  The stock `User::getArrayCopy()` returns the activation `hash`.
  Do not copy that into new entities.
- An action that is already done is a `ConflictException`, for example the activation of an active account.

## Lists

`Paginator::getParams($params, '<default sort>')` sets `limit` to 10 by default, but it accepts all positive values.
The value `all` returns a maximum of 1,000 rows.
In the service, limit `limit` to a documented maximum, next to the `sort` whitelist.

## Authorization

- A request without a token runs as guest.
  A route that is not granted to guest answers 403, not 401.
- A new guest grant makes an endpoint public.
  State that decision clearly in the merge request.
  Never add it as a side effect.

## OpenAPI

- `operationId` is the handler class name without `Handler`, in lowerCamelCase: `getUserCollection`, `postUserResource`, `patchUserActivate`.
- Authenticated operations declare `security: [['AuthToken' => []]]`.
  Public operations do not declare it.

## Tests beyond the standard matrix

In addition to the coverage table in `dotkernel-testing`, test these cases:

- A caller without a token: 403, unless the route is granted to guest.
- An item of a different user, where a guard or an ownership check applies.
- A conflict, where the endpoint can cause one.

## Checklist for a new endpoint

- [ ] Path, method, handler class, route name and `operationId` follow the naming rules.
- [ ] The handler extends `AbstractHandler`, gets dependencies through `#[Inject]` and contains no business logic.
- [ ] `#[Resource]` loads an item in the path.
  When the item belongs to a user, ownership is enforced.
- [ ] An InputFilter of Input classes validates the input, with catalogue messages and lengths that match the columns.
- [ ] The service whitelists `sort` and limits `limit`.
- [ ] A helper returns the response, and the entity or collection is registered in the HAL `MetadataMap`.
- [ ] `getArrayCopy()` shows only the intended fields.
- [ ] Errors are typed exceptions with catalogue messages.
- [ ] The handler is under `delegators` and `factories` in the module `ConfigProvider`.
- [ ] `authorization.global.php` grants the route name to each role that needs it.
  It grants the route name to guest only after a clear decision.
- [ ] A request body that is not JSON has its content-negotiation entry.
- [ ] The operation is in the `OpenAPI.php` of the module, with its failure responses.
- [ ] Tests cover the matrix and the cases above, and `composer check` passes.
