---
name: dotkernel-testing
description: >
  Use when you write, run or fix tests in a Dotkernel project: unit tests, functional
  route tests, mocking repositories and services, authenticating a test request, seeding data, or
  diagnosing failures inside setUp such as "test mode is NOT enabled" or "non in-memory
  database". Also use when you decide what coverage a new route needs.
---

# Testing

```text
Applies to
  Projects:  - all
  Packages:  - none
```

```bash
composer test
php ./vendor/bin/phpunit --testsuite UnitTests
php ./vendor/bin/phpunit --testsuite FunctionalTests
php ./vendor/bin/phpunit --filter BookTest
```

Dotkernel `phpunit.xml` files usually set `stopOnError` and `stopOnFailure`.
Thus the run stops at the first test that fails.
Fix the failed tests one at a time.

## Prerequisite: the test config

Functional tests need a local config for tests.
This file is usually `config/autoload/local.test.php`, which you copy from its `.dist` file.
It sets Doctrine to use an in-memory SQLite database.
If the file is not correct, the base test case stops with a message such as:

- *"test mode is NOT enabled"* → the test config file is missing.
- *"running tests in a non in-memory database"* → the file exists, but it does not configure an in-memory database.

**Never "fix" either error with a real database for the tests.**
The error shows that the guard works.

The stock Frontend also includes `local.test.php.dist`, but it has no functional suite.
Also, no base class in its `test/Common/` enforces test mode.
Thus its unit tests do not need the copy.

## Unit tests

Put a unit test in `test/Unit/<Module>/<Layer>/<Class>Test.php`, with the namespace from `autoload-dev`.

Test services, middleware, attributes and helpers.
Mock the repository.
Assert the behaviour and the exceptions:

```php
$repository = $this->createMock(BookRepository::class);
$repository->method('find')->willReturn(null);

$this->expectException(NotFoundException::class);
(new BookService($repository))->findBook('…');
```

Do not start the container in a unit test.
If you need the container, write a functional test.

## Functional tests

Only the stock API and Admin include a functional suite.
Frontend and Light have only unit tests.
Queue keeps its tests in `test/App/` and `test/Swoole/`.
Do not add a functional suite to those projects without asking.
A functional suite needs new base classes and a test config.

Put a functional test in `test/Functional/<Module>Test.php`, and extend the functional base class of the repository.
**Read the base class before you write anything.**
The two stock base classes are very different.

**Admin** (`test/Functional/FunctionalTest.php` on the stock `7.0` branch) starts the container and the pipeline.
It gives only a `get()` request helper, `getContainer()`, `getEntityManager()` and `runMigrations()`.
`runMigrations()` builds the schema from the entity metadata.
It has no status assertions, entity factories, fixtures, login helper or service-replacement helper.
Assert on the response directly, and create data through the entity manager.
Ask before you add helpers to the base class.

**API** (`test/Functional/AbstractFunctionalTest.php` on the stock `7.0` branch) starts the real container, pipeline and routes.
Then, in `setUp()`, it builds the schema and loads all fixtures.
This isolates each test, but it costs time.
Write only tests that have a purpose.
The base class gives:

- Request helpers for each verb.
  They set the correct `Accept` header and add authentication when you are logged in.
- Named status assertions (ok, created, no-content, bad-request, unauthorized, forbidden, not-found, conflict, gone).
  Use these, not raw status comparisons.
- Entity factories and builders of valid and invalid data for the core entities of the project.
- Credential builders for the authentication mechanism of the project, and versions of them that are invalid on purpose.
- A service-replacement helper that replaces container services.
  **Use it, so that tests never send real email or make real outbound calls.**
- Direct access to the entity manager, to prepare persisted data.

Shape:

```php
class BookTest extends AbstractFunctionalTest
{
    public function testUserCanListBooks(): void
    {
        $identity = $this->createUser()->getIdentity();
        $this->loginAs($identity, self::DEFAULT_PASSWORD);

        $this->assertResponseOk($this->get('/book'));
    }

    public function testGuestCannotListBooks(): void
    {
        $this->assertResponseForbidden($this->get('/book'));
    }
}
```

## Required coverage for a new route

| Case | Expected |
| --- | --- |
| Happy path | 200 / 201 / 204 / rendered page. Assert the payload or the output, not only the status |
| Validation failure | 400 with the errors payload, or the form shown again with messages |
| Not authenticated | API: 403. A request without a token runs as guest, and the API refuses it unless the route is granted to guest. Session-based project: a redirect to login |
| Authenticated, wrong role | 403. **People often do not write this test.** Admin / Frontend: this test finds a missing guard rule, because a route that is not in the list is open to all users. API: a missing entry denies all roles, so the happy path fails instead. This test finds a route that is granted to too many roles |
| Unknown identifier | 404 |
| Duplicate or conflicting write | 409 where applicable |

For a deprecated API route, also assert the `Sunset` header.
For a templated page that moved to a new URL, assert the permanent redirect from the old URL.
For a form, also assert that the project refuses a missing or invalid CSRF token.

## Conventions

- A test method name is a sentence: `testAdminCannotDeleteOwnAccount`.
- Assert with `StatusCodeInterface::STATUS_*`, never with bare integers.
- phpcs and phpstan also check `test/`.
  Tests must pass the same style and type checks.
- Never use `markTestSkipped()` on a test that you broke.
  Never make an assertion weaker to make the run pass.
