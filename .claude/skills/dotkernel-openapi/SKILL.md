---
name: dotkernel-openapi
description: >
  Use when you document an endpoint in a Dotkernel project that publishes OpenAPI (usually
  the API). This includes: adding or editing a module's OpenAPI.php, describing request bodies,
  responses, parameters, security schemes or schemas, marking an operation deprecated, or
  regenerating the interactive documentation. Also use when an endpoint exists but is missing
  from the docs, or when checking whether this project publishes OpenAPI at all.
---

# OpenAPI documentation

```text
Applies to
  Projects:  - Dotkernel API
  Packages:  - none
```

**This skill applies only to projects that publish OpenAPI.**
First, confirm two things: `zircote/swagger-php` is in `composer.json`, and each module has a `src/<Module>/src/OpenAPI.php` file.
Of the stock projects, only the API publishes OpenAPI.
Admin, Frontend, Light and Queue have no OpenAPI surface.
In derived projects, a `documentation/` directory is not always present.
Check for it, and do not infer it.

Why OpenAPI is important:

- Front-end and back-end developers can work in parallel against mock servers.
- The documentation is generated automatically, not maintained by hand.
- Tools such as Postman and code generators use it.

## Where the attributes are

The attributes are not on the handler.
Each module has one dedicated file that contains no classes.
The file contains only a sequence of `#[OA\…]` attributes.
A docblock before each attribute points to the handler that the attribute documents:

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

- Keep the operations in the same order as the routes in `RoutesDelegator`.
  Then you can compare the two files by eye.
- Use one `tags` entry for each resource, and make it match the module.
- Put the security scheme on **each** authenticated endpoint.
  Without the scheme, the documentation tells clients that the endpoint is public.
  This is a documentation bug with security consequences.
- Use `StatusCodeInterface::STATUS_*` for status codes, not literals.
- Also document the failure responses: 400, 403, 404 and 409, where they apply.
  A request with a missing or invalid token runs as guest.
  Thus a protected operation answers 403, not 401.
  Only the operations that issue tokens can answer 401.
  Before you document an error, verify in the repository which operations return it.
- Give a deprecated operation `deprecated: true` and a description that names the replacement.
  Use them together with the deprecation attribute on the handler (see `dotkernel-evolution-pattern`).
- Use `OA\Schema` definitions again.
  Do not repeat inline shapes.

## Security constraints

- **Never** put a real credential, token, internal hostname, customer email or production identifier in an `example`.
  Use placeholders that are clearly not real.
- You should not enable the interactive documentation in production.

## Definition of done

An endpoint is not finished until its operation exists.
The route, the authorization entry and the documentation are three separate registrations.
It is easy to do only two of the three, so verify all three.
