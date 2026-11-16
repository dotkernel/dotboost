---
description: Write and run tests for a module, route or class
argument-hint: <class, route or module>
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(composer test), Bash(php ./vendor/bin/phpunit:*), Bash(composer cs-fix), Bash(composer cs-check), Bash(composer static-analysis)
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

Add test coverage for: **$ARGUMENTS**

Load `dotkernel-project-variants` and `dotkernel-testing`.

1. Do this step if the repo has a functional suite and ships `config/autoload/local.test.php.dist` (stock API and Admin).
   Make sure that the copy `local.test.php` exists.
   If it does not exist, stop and tell me to copy the `.dist` file.
   I do not want tests that point to a real database.
   The stock Frontend also ships the `.dist` file, but its unit tests do not need the copy.
   Light and Queue have no test-local config.
   For these projects, skip this step, unless the repo added functional tests.
2. Read the nearest existing test.
   If the repo has a functional base class, read it too:
   - API: `test/Functional/AbstractFunctionalTest.php`.
   - Admin: `test/Functional/FunctionalTest.php`.
     It has only a `get()` helper, container and entity-manager access, and `runMigrations()`.
     It has no status assertions, no fixtures and no login helper.

   Frontend, Light and Queue ship only unit tests.
   Use the same structure and helpers as the code that you find.
   The helpers are different in each Dotkernel project.
   Do not guess method names.
   Read them.
3. Select unit or functional tests:
   - Business logic and exception paths: unit tests with mocked repositories.
   - Anything that needs routing, auth or the container: functional tests.
4. For a route, cover the full matrix: success, validation failure, unauthenticated, wrong role, unknown identifier, and conflict where applicable.
   For a form, also cover rejected CSRF.
   Assert the output, not only the status.
5. Use the helpers of the base class.
   Do not write them again.
   Also use the helper that replaces a service, so that tests never send real email or make outbound calls.
6. Run the tests.
   The config probably stops at the first failure, so fix one failure at a time.
7. At the end, run `composer cs-check` and `composer static-analysis`.
   Both of them examine `test/`.

Never use `markTestSkipped()` on a failing test.
Never make an assertion weaker to make the tests pass.
