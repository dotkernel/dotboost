---
name: dotkernel-openapi
description: >
  Use when documenting an endpoint in a Dotkernel application that publishes OpenAPI (typically
  the API) — adding or editing a module's OpenAPI.php, describing request bodies, responses,
  parameters, security schemes or schemas, marking an operation deprecated, or regenerating the
  interactive documentation. Also use when an endpoint exists but is missing from the docs, or
  when checking whether this application publishes OpenAPI at all.
---

# OpenAPI documentation

**Applies only to applications that publish OpenAPI.** Confirm first: `zircote/swagger-php` in
`composer.json` and per-module `src/<Module>/src/OpenAPI.php` files. A templated Admin or Frontend
documents CLI commands under `documentation/` instead, and has no OpenAPI surface.

Why it matters: it lets front-end and back-end developers work in parallel against mock servers,
it makes documentation auto-generated rather than hand-maintained, and tooling like Postman and
codegen consumes it.

## Where the attributes live

Not on the handler. Each module has one dedicated file containing no classes — only a sequence of
`#[OA\…]` attributes, each preceded by a docblock pointing at the handler it documents:

```php
/**
 * @see GetBookCollectionHandler::handle()
 */
#[OA\Get(
    path: '/book',
    description: 'Authenticated admin fetches a list of books',
    summary: 'Admin lists books',
    security: [['AuthToken' => []]],
    tags: ['Book'],
    parameters: [
        new OA\Parameter(
            name: 'page',
            description: 'Page number',
            in: 'query',
            required: false,
            schema: new OA\Schema(type: 'integer'),
            example: 1,
        ),
    ],
    responses: [
        new OA\Response(
            response: StatusCodeInterface::STATUS_OK,
            description: 'Returns a paginated list of books',
        ),
    ],
)]
```

## Rules

- Keep operations in the same order as the routes in `RoutesDelegator`, so the two files diff by
  eye.
- One `tags` entry per resource, matching the module.
- The security scheme on **every** authenticated endpoint. Omitting it tells clients the endpoint
  is public — a documentation bug with security consequences.
- Status codes via `StatusCodeInterface::STATUS_*`, not literals.
- Document failure responses too: at minimum 400, 401, 403 and 404 where they apply.
- Deprecated operations get `deprecated: true` plus a description naming the replacement, paired
  with the deprecation attribute on the handler (see `dotkernel-evolution-pattern`).
- Reuse `OA\Schema` definitions rather than repeating inline shapes.

## Security constraints

- **Never** put a real credential, token, internal hostname, customer email or production
  identifier in an `example`. Use obvious placeholders.
- Interactive documentation should not be enabled in production.

## Definition of done

An endpoint is not finished until its operation exists. The route, the authorization entry and the
documentation are three separate registrations, and it is easy to do two of the three — verify all
of them.
