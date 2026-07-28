---
description: Write and run tests for a module, route or class
argument-hint: <class, route or module>
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(composer test), Bash(php ./vendor/bin/phpunit:*), Bash(composer cs-fix), Bash(composer cs-check), Bash(composer static-analysis)
---

Add test coverage for: **$ARGUMENTS**

Load `dotkernel-testing`.

1. Check the test-local config file exists (commonly `config/autoload/local.test.php`). If not,
   stop and tell me to copy the `.dist` — I do not want tests repointed at a real database.
2. Read the repo's abstract functional test case and the closest existing test, and match their
   structure and helper usage. The helpers vary between Dotkernel applications, so do not assume
   method names — read them.
3. Decide unit versus functional: business logic and exception paths → unit with mocked
   repositories; anything needing routing, auth or the container → functional.
4. For a route, cover the full matrix: success, validation failure, unauthenticated, wrong role,
   unknown identifier, conflict where applicable — plus rejected CSRF for a form. Assert output,
   not just status.
5. Use the base-class helpers rather than reinventing them, including the service-replacement
   helper so tests never send real email or make outbound calls.
6. Run the tests. The config likely stops on first failure, so iterate one at a time.
7. Finish with `composer cs-check` and `composer static-analysis` — `test/` is covered by both.

Never `markTestSkipped()` a failing test or weaken an assertion to get green.
