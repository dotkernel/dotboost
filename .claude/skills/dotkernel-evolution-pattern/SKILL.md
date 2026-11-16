---
name: dotkernel-evolution-pattern
description: >
  Use whenever a change would break something that a client already depends on in a Dotkernel
  project: renaming or removing a field, parameter, route or template variable, changing a
  type, status code or response shape, making an optional field required, deprecating or
  deleting an endpoint. Also use when someone proposes a /v2, a version prefix, a version header,
  or "versioning the API". Also use when you work with ResourceDeprecation, Sunset and Link
  headers, or the deprecation middleware.
---

# Evolution pattern, not versioning

```text
Applies to
  Projects:  - Dotkernel API
             - Dotkernel Admin
             - Dotkernel Frontend
             - Dotkernel Light
  Packages:  - none
```

Dotkernel prefers to change one codebase step by step, not to keep parallel versions.
Dotkernel announces breaking changes early and removes them on a published date.
Full rewrites and `/v2/` prefixes are a last option, only for an architectural change.

**The default answer to "should we add /v2?" is no.**
First, propose an evolution path.
Use versioning only for a change that is really architectural, for example a different protocol or response paradigm.
Then say clearly that you recommend an exception.

Scope: the mechanics below (Sunset headers) are for an API.
In a templated project, the same *principle* applies to route URLs and query parameters.
It also applies to all items that a bookmark, an integration or an email link uses.
But there, a redirect and a changelog entry announce the change, not a header.

## Decision table

| Change | Approach |
| --- | --- |
| Fix a typo in a parameter name | Accept the two names for a period, and deprecate the old name. Versioning is too much. |
| Add a response field | Add it. A change that only adds does not break clients. |
| Add a request parameter | Make it **optional**, with a safe default. |
| More behaviour for more input | Select the behaviour from the payload: old shape → old behaviour, new shape → new behaviour. |
| Remove a field, change a type, make validation stricter | Breaking. Deprecate with a sunset date, and keep the old path until that date. |
| Remove an endpoint or route | Deprecate with a sunset date. After that date, it answers 410 Gone (API) or redirects permanently (templated). After you remove it, it answers 404. |
| Move a page to a new URL (templated) | Serve the page at the new URL, and redirect the old URL permanently at once. The redirect keeps bookmarks and email links working. |
| Change one endpoint fundamentally | A `v2` for **that endpoint only**, never for the whole project. |
| A fully different response paradigm | Real versioning. |

The old and the new versions exist together for a reasonable period.
The sunset date is a promise.
Do not make it earlier without an announcement.

## Marking a deprecation (API-style projects)

Put a class-level attribute on the handler:

```php
#[ResourceDeprecation(
    sunset: '2099-01-01', // placeholder: use the real future date that the team agreed for this period
    link: 'https://docs.dotkernel.org/…/api-evolution/',
    deprecationReason: 'Replaced by GET /book/{id}/detail.',
    rel: 'sunset',
    type: 'text/html',
)]
class GetBookResourceHandler extends AbstractHandler
```

Mechanics:

- After dispatch, the deprecation middleware reads the handler through reflection.
  Then it adds the `Sunset:` and `Link:` response headers.
- After the sunset date, the middleware throws `ExpiredException` before the handler runs.
  The endpoint then answers `410 Gone` as problem details.
- `sunset` must be a valid date, or the attribute constructor throws an exception.
  The date must also be in the future.
  A past date deprecates the endpoint and stops it in the same change.
- If you do not give `link`, the middleware uses the documentation URL in the `application.versioning` config.

The response:

```http
HTTP/1.1 200 OK
Sunset: 2099-01-01
Link: https://docs.dotkernel.org/…;rel="sunset";type="text/html"
```

## Obligations that come with a deprecation

When the attribute compiles, the work is not "done".
Also do these steps:

1. In the `OpenAPI.php` of the module, mark the operation `deprecated: true` and name the replacement.
2. Update the documentation page that describes the change and the recommended client update.
3. Write a note in `CHANGELOG.md`, but only if the user asks you to change the changelog.
4. Add or extend a test that asserts the `Sunset` header.
5. Keep the old path working until the sunset date.
   **Do not delete it in the same change.**
6. Announce the change through the channels that the project really uses: headers, docs, release notes, newsletter.
   Announce it early, so that third-party developers can plan.

After the sunset date, the endpoint already answers 410.
Thus the removal is a clean-up, not an emergency.
In one later change, remove the handler, its route, its authorization entry, its presentation metadata and its documentation block.
A removed endpoint must answer 404, not 500.

## Anti-patterns to flag

- `/v2/...` route groups, `?version=2`, or versioned media types in a codebase that uses evolution.
- A response field renamed in place "because the old name was wrong".
- An existing optional field made required.
- An enum made smaller or a validator made stricter on a live route, with no sunset period.
- A success status code changed (200 → 204) on a live endpoint.
- A route URL changed in a templated project, with no permanent redirect from the old URL.

If a user asks you to do one of these, first state the breaking-change result.
Then offer the evolution alternative.
Do the change only after these two steps.
