---
name: dotkernel-qa-gate
description: >
  Use when finishing a change in a Dotkernel application and before claiming it is done, when
  phpcs, phpcbf, phpstan or phpunit fails, when interpreting CI results, or when asked to "run
  the checks" or "fix the build". Also use when tempted to add a phpcs exclusion, a
  @phpstan-ignore, or to skip a test.
---

# QA gate

Nothing is done until the repo's own suite passes. Read `composer.json` `scripts` for the exact
names; the Dotkernel convention is:

| Command | Tool | Config |
| --- | --- | --- |
| `composer check` | all of the below | — |
| `composer cs-check` | phpcs, Laminas Coding Standard | `phpcs.xml` |
| `composer cs-fix` | phpcbf | same |
| `composer static-analysis` | phpstan | `phpstan.neon` |
| `composer test` | phpunit | `phpunit.xml` |

All read-only; safe to run unasked. Installers, migrations and fixtures are **not** — ask first.

## Order of operations after editing PHP

1. `composer cs-fix` — mechanical formatting.
2. `composer cs-check` — what phpcbf could not fix (usually import order, missing
   `use function`, line length, missing type declarations). Fix by hand.
3. `composer static-analysis` — types.
4. `composer test` — behaviour.

Rerun the full `composer check` at the end; formatting can shift the lines phpstan reports on.

## Common failures and the correct fix

| Symptom | Fix |
| --- | --- |
| `Function count() should not be referenced via a fully qualified name` | add `use function count;` after the class imports |
| `Expected 1 space after "!"` | write `! $foo` |
| `Missing declare(strict_types=1)` | add it after `<?php` and a blank line |
| `Line exceeds 120 characters` | one argument per line, trailing comma |
| phpstan `Cannot call method on X\|null` | `instanceof` guard, then throw the app's not-found exception |
| phpstan `no value type specified in iterable type array` | add `@param array<non-empty-string, mixed>` / `@return X[]` |
| phpstan `expects non-empty-string, string given` | narrow at the boundary, or type the validated shape with `@phpstan-type` |
| Route denied in a functional test | authorization entry missing for that route name |
| Assertion failure inside the abstract handler's response helper | handler missing its delegator registration in `ConfigProvider` |
| Service not found in the container | missing `factories` entry, or missing `aliases` entry for the interface |
| Class not found after adding a namespace | `composer dump-autoload`; check the PSR-4 mapping and its case |

**Forbidden "fixes":** lowering the phpstan level, adding `<exclude>` or `<exclude-pattern>` to
`phpcs.xml`, `// phpcs:ignore`, `@phpstan-ignore-next-line`, `markTestSkipped()` on a test you
broke, deleting an assertion. If a rule genuinely does not apply, say so and let the user decide.

## CI

Dotkernel repos typically run a laminas-ci matrix across supported PHP versions plus dedicated
static-analysis, coverage, code-quality and schema-validation workflows. Points worth knowing:

- The matrix covers several PHP versions — passing locally on one is not passing.
- Schema validation fails on entity/migration drift; generate a migration rather than editing the
  entity to match an old one.
- A stale local `.phpcs-cache` or `.phpunit.result.cache` can mask a failure that CI catches.

## Reporting

Paste the actual failure lines rather than summarising them, and state plainly if a check was not
run. Never claim the suite passed without having run it.
