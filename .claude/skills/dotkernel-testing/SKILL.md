---
name: dotkernel-testing
description: >
  Use when writing, running or fixing tests in a Dotkernel application — unit tests, functional
  route tests, mocking repositories and services, authenticating a test request, seeding data, or
  diagnosing failures inside setUp such as "test mode is NOT enabled" or "non in-memory
  database". Also use when deciding what coverage a new route needs.
---

# Testing

```bash
composer test
php ./vendor/bin/phpunit --testsuite UnitTests
php ./vendor/bin/phpunit --testsuite FunctionalTests
php ./vendor/bin/phpunit --filter BookTest
```

Dotkernel `phpunit.xml` files commonly set `stopOnError` and `stopOnFailure`, so the run halts at
the first red test. Fix them one at a time.

## Prerequisite: the test config

Functional tests need a test-specific local config — commonly
`config/autoload/local.test.php`, copied from its `.dist` — pointing Doctrine at an in-memory
SQLite database. Without it, the base test case aborts with a message like:

- *"test mode is NOT enabled"* → the test config file is missing.
- *"running tests in a non in-memory database"* → present but not configured for memory.

**Never "fix" either by pointing tests at a real database.** That is the guard working.

## Unit tests

`test/Unit/<Module>/<Layer>/<Class>Test.php`, namespace per `autoload-dev`.

Target services, middleware, attributes and helpers. Mock the repository; assert behaviour and
the exceptions:

```php
$repository = $this->createMock(BookRepository::class);
$repository->method('find')->willReturn(null);

$this->expectException(NotFoundException::class);
(new BookService($repository))->findBook('…');
```

Do not boot the container in a unit test. If you need the container, it is a functional test.

## Functional tests

`test/Functional/<Resource>Test.php`, extending the repo's abstract functional test case. That
base class typically boots the real container, pipeline and routes, builds a fresh schema from the
entity metadata and runs every fixture per test — isolated, but not free. Keep them purposeful.

**Read the abstract test case before writing anything.** It generally provides:

- Request helpers per verb, pre-setting the right `Accept` header and attaching auth when logged
  in.
- Named status assertions (ok, created, no-content, bad-request, unauthorized, forbidden,
  not-found, conflict, gone) — use these rather than raw status comparisons.
- Entity factories and valid/invalid data builders for the app's core entities.
- Credential builders for the app's auth mechanism, plus deliberately invalid twins.
- A service-replacement helper for swapping container services — **use it so tests never send
  real email or make real outbound calls.**
- Direct entity-manager access for persistence setup.

Shape:

```php
class BookTest extends AbstractFunctionalTest
{
    public function testAdminCanListBooks(): void
    {
        $this->createAdmin();
        $this->loginAsAdmin();

        $this->assertResponseOk($this->get('/book'));
    }

    public function testGuestCannotListBooks(): void
    {
        $this->assertResponseUnauthorized($this->get('/book'));
    }
}
```

## Required coverage for a new route

| Case | Expected |
| --- | --- |
| Happy path | 200 / 201 / 204 / rendered page — assert the payload or output, not just the status |
| Validation failure | 400 with the errors payload, or the form re-rendered with messages |
| Not authenticated | 401, or a redirect to login in a session app |
| Authenticated, wrong role | 403 — **the case people skip, and the one that catches a missing authorization entry** |
| Unknown identifier | 404 |
| Duplicate / conflicting write | 409 where applicable |

For a deprecated route, also assert the `Sunset` header. For a form, also assert that a missing or
invalid CSRF token is rejected.

## Conventions

- Test method names read as sentences: `testAdminCannotDeleteOwnAccount`.
- Assert with `StatusCodeInterface::STATUS_*`, never bare integers.
- `test/` is covered by phpcs and phpstan too — tests must pass the same style and type checks.
- Never `markTestSkipped()` a test you broke, and never weaken an assertion to get green.
