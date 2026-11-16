---
name: dotkernel-responses
description: >
  Use when you shape what a Dotkernel handler returns: HAL resources and collections and the
  MetadataMap for API-style projects, or templates, redirects and flash messages for templated
  projects, plus pagination, content negotiation, and the error body. Also use when a response
  is missing links, a list is not paginated, a resource exposes the wrong fields, or an error
  leaks internal detail.
---

# Responses

```text
Applies to
  Projects:  - Dotkernel API
             - Dotkernel Admin
             - Dotkernel Frontend
             - Dotkernel Light
  Packages:  - none
```

First, identify the variant (`dotkernel-project-variants`).
The two dialects share one rule: **handlers do not build response payloads by hand.**
They give an object to the presentation layer.

## API-style: HAL

### Single resource

1. The entity extends the `Core` abstract entity, which implements `ArraySerializableInterface`.
   **`getArrayCopy()` is your serialisation boundary.**
   It decides what a client receives.
   Never expose password hashes, internal numeric ids, tokens, or relations that you did not intend to expose.
2. Register the entity in the HAL config of the module `ConfigProvider`:

   ```php
   AppConfigProvider::getResource(Book::class, 'book::view-book')
   ```

   This call maps to route-based resource metadata with an array-serialisable hydrator.
   It generates the `self` link from the named route.
   Optional arguments override the identifier property and the route placeholder.

3. The handler returns the `createResponse(...)` of the repository.
   For 201, it returns the created-response helper of the repository.

### Collections

1. `<App>\<Module>\Collection\BookCollection` extends the resource collection class of the project.
   That class is a Doctrine `Paginator`.
   Usually, the collection class body is empty.
2. Register the collection, and give the name of the embedded relation (plural, lowercase):

   ```php
   AppConfigProvider::getCollection(BookCollection::class, 'book::list-book', 'books')
   ```

3. The service returns a `QueryBuilder`.
   The handler wraps it:

   ```php
   return $this->createResponse(
       $request,
       new BookCollection($this->bookService->getBooks($request->getQueryParams()))
   );
   ```

The pagination links (`first`, `prev`, `self`, `next`, `last`) come from the route.
Do not build them.

### Content negotiation

The content-negotiation middleware selects the representation from `Accept`.
The usual values are `application/json` and `application/hal+json`.
Never hardcode a `Content-Type` in a handler.

## Templated: views, redirects, flash

- The handler renders a named template through the renderer and returns an HTML response.
  In Frontend, the controller action does this work.
  The module `ConfigProvider` registers the template paths under `templates`.
- Give view models or plain arrays to the template.
  **Escaping occurs in the view.**
  Never build HTML in a handler or a service.
- After a successful write, redirect to a `GET` route, and do not render a template.
  This is the post/redirect/get pattern.
  Put the result in a flash message.
- After a failed write, render the same template again with the bound form.
  Then the input and the messages stay (see `dotkernel-input-validation`).
- Build URLs with the URL helper and the route name.
  Never use string concatenation.

## Pagination (both dialects)

The shared paginator helper normalises the query string:

| Param | Behaviour |
| --- | --- |
| `page` | 1-based, and it gives the `offset` |
| `offset` | alternative to `page` |
| `limit` | has a default, so clamp the maximum |
| `sort` | **must be whitelisted** against an explicit column list |
| `dir` | `asc` \| `desc` |

The whitelist is in the service.
If you skip it, you cause a security issue, not a style issue.

## Errors

Throw an exception.
Do not build error responses.
The error-handling middleware renders them in the same way each time.
In the API, it renders RFC 7807 problem details.
In a templated project, it renders an error page or a flash message.

```php
throw BadRequestException::create(
    detail: Message::VALIDATOR_INVALID_DATA,
    additional: ['errors' => $this->inputFilter->getMessages()]
);
```

The exception namespace of the project maps exceptions to status codes:

- bad request: 400
- unauthorized: 401
- forbidden: 403
- not found: 404
- not acceptable: 406
- conflict: 409
- unsupported media type: 415
- plus project-specific exceptions

Messages come from the shared catalogue.
**Never show SQL, stack traces, file paths or internal class names** in a message that the user can see.

The stock API has one known exception to this rule.
`AuthorizationMiddleware` answers a refusal with `{"error": {"messages": [...]}}` and status 403, not with problem details.
Do not copy that pattern.
New code throws an exception.

Successes that are not resources also have helpers: empty or no-content, an info-message envelope, and plain JSON.
Use the existing helper, not a new shape, so that clients see one consistent envelope.

## Checklist

- [ ] `getArrayCopy()` (or the view model) exposes exactly the intended fields.
- [ ] The resource or collection is registered in the HAL config, or the template path is registered.
- [ ] The collection class exists, and its embedded relation has a name (API).
- [ ] The redirect after a write and the flash message are wired (templated).
- [ ] The service has the sort whitelist and the limit clamp.
- [ ] Errors are thrown as typed exceptions with catalogue messages.
- [ ] The test asserts the body or the rendered output, not only the status code.
