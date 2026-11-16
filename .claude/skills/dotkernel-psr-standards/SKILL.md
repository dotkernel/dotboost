---
name: dotkernel-psr-standards
description: >
  Use when you write or review any PHP in a Dotkernel project. It tells which PSR applies, how to
  type handlers and middleware (PSR-7/PSR-15), how to obtain services (PSR-11, no service
  locator), logging (PSR-3), caching (PSR-6/PSR-16), building responses (PSR-17), autoloading
  (PSR-4), and coding style (PSR-1/PSR-12 via the Laminas Coding Standard). Also use when phpcs
  or phpstan complains, or when you are tempted to type-hint a concrete framework class instead
  of an interface.
---

# PSR compliance

```text
Applies to
  Projects:  - all
  Packages:  - all
```

Write the code against PSR interfaces.
Type-hint the interface.
Inject the implementation.
This rule is the same in each Dotkernel project.

## PSR-4 — autoloading

The namespace is the same as the directory, and the match is case-sensitive.
Put one class in each file, and give the file the name of the class.

```text
<App>\User\Handler\User\GetUserResourceHandler → src/User/src/Handler/User/GetUserResourceHandler.php
Core\User\Entity\User                          → src/Core/src/User/src/Entity/User.php
```

The mappings are in `composer.json` under `autoload.psr-4`, and under `autoload-dev` for tests.
A new mapping is a change to `composer.json`, so you must get approval from the user.
Then run `composer dump-autoload`.

## PSR-7 — HTTP messages

Messages are **immutable**.
A `with*()` method returns a new instance.

```php
$response = $response->withHeader('sunset', $date);   // correct
$response->withHeader('sunset', $date);               // has no effect and gives no error
```

Type-hint `Psr\Http\Message\ServerRequestInterface` or `ResponseInterface`.
Never type-hint a concrete Diactoros class.
Read the body one time with `(array) $request->getParsedBody()`.
The body-params middleware already parsed the body.
If you read the raw stream again, you must call `rewind()` first.

## PSR-15 — handlers and middleware

```php
final class XMiddleware implements MiddlewareInterface
{
    public function process(
        ServerRequestInterface $request,
        RequestHandlerInterface $handler
    ): ResponseInterface {
        // Work before the handler.
        $response = $handler->handle($request);
        // Work after the handler.
        return $response;
    }
}
```

- Handlers implement `RequestHandlerInterface`.
  Extend the abstract handler of the project to use its response helpers.
- Give each middleware one responsibility.
  `config/pipeline.php` declares the order of the middleware.
  A change to the order has an effect on each request, so give a reason for each change.
- When a middleware only adds data to the request, it gives the data with `$request->withAttribute(...)`.

## PSR-11 — container

Get services through constructor injection.
The container resolves them.

```php
#[Inject(BookServiceInterface::class, CreateBookInputFilter::class)]
public function __construct(
    protected BookServiceInterface $bookService,
    protected CreateBookInputFilter $inputFilter,
) {
}
```

`dot-dependency-injection` reads `#[Inject]`.
Register the class with `AttributedServiceFactory::class` in the `ConfigProvider` of the module.
The stock Light does not install `dot-dependency-injection`.
It uses hand-written factories, so use hand-written factories there too.
`#[Inject]` can also get config values by a dotted key.

**Do not inject `ContainerInterface` and call `get()` in a class.**
That is the service-locator anti-pattern.
Use `$container->get()` only in factories and delegators.
There, also declare `ContainerExceptionInterface` and `NotFoundExceptionInterface`.

## PSR-3 — logging

Type-hint `Psr\Log\LoggerInterface`.
Select each level on purpose:

- Use `error` for failures that need an action.
- Use `warning` for failures that the code can recover from.
- Use `info` for lifecycle events.

Give the context as an array.
Do not concatenate it into the message.
**Never log credentials, tokens, password hashes, auth request bodies, or PII other than an identifier.**

## PSR-6 / PSR-16 — caching

Type-hint `Psr\Cache\CacheItemPoolInterface` (PSR-6) or `Psr\SimpleCache\CacheInterface` (PSR-16).

- Always set an explicit TTL.
- Never cache data with per-user authorization under a global key.
- Give a way to invalidate the cache when the related entity changes.

## PSR-17 — HTTP factories

Type-hint `ResponseFactoryInterface` or `StreamFactoryInterface`.
Do not create a concrete response object.
The exception is the abstract handler, because it already wraps the response factory of the project.
Prefer the helpers of the abstract handler to responses that you build yourself.

## PSR-1 / PSR-12 — style, enforced by the Laminas Coding Standard

`phpcs.xml` applies `LaminasCodingStandard`, which contains PSR-12 and adds more rules.
It fails the check on these rules:

- Put `declare(strict_types=1);` after `<?php` and one blank line.
- Use a 4-space indent, LF line endings, one trailing newline, and no trailing whitespace.
  Keep lines to approximately 120 characters.
- Sort the `use` statements.
  Put class imports first, then a blank line, then `use function` and `use const`.
  You **must** import global functions.
  Do not call them as `\count()`.
- Use the short array syntax.
  Use short closures where they apply.
- Write `! $foo`, not `!$foo`.
- Align `=>` in array literals.
  Align `=` in consecutive assignments.
- Put one class in each file.
  Use `final` when the class is not designed for extension.
- Declare a type on each parameter, property and return.
  Write a nullable type as `?Type`.

Run the `cs-fix` script of the repository for the mechanical fixes.
Never add sniff exclusions to `phpcs.xml`.
Never add `// phpcs:ignore` comments to make the check pass.

## phpstan expectations

Dotkernel projects run phpstan at a high level, frequently 8, with the Doctrine and PHPUnit extensions:

- Do not let `mixed` go further into the code.
  Cast or narrow it at the boundary.
- Document array shapes: `@param array<non-empty-string, mixed>`, `@return X[]`.
  Use `@phpstan-type` and `@phpstan-import-type` for shapes that more than one class uses.
- Put generics on collections: `@var Collection<int, UserRole>`.
- Do an `instanceof` check before you use a nullable result from a repository.
  The services in these projects use this check to raise not-found errors.
- Do not silence phpstan with `@phpstan-ignore-*`.
  Fix the type.

## Framework-specific rules that you must obey

- Use `Fig\Http\Message\StatusCodeInterface::STATUS_*` for status codes.
  Do not use integer literals.
- Throw the typed exceptions of the project with their static `::create(...)` constructors.
  Get the messages from the shared message catalogue.
- When the project gives a resource-resolution attribute on `handle()`, use it.
  Do not get the entity manually.
