---
name: dotkernel-qa-gate
description: >
  Use when you finish a change in a Dotkernel project and before you say that it is done, when
  phpcs, phpcbf, phpstan or phpunit fails, when you interpret CI results, or when asked to "run
  the checks" or "fix the build". Also use when tempted to add a phpcs exclusion, a
  @phpstan-ignore, or to skip a test.
---

# QA gate

```text
Applies to
  Projects:  - all
  Packages:  - all
```

A change is not done until the suite of the repository passes.
Read `scripts` in `composer.json` for the exact names.
The Dotkernel convention is:

| Command | Tool | Config |
| --- | --- | --- |
| `composer check` | all of the tools below | — |
| `composer cs-check` | phpcs, Laminas Coding Standard | `phpcs.xml` |
| `composer cs-fix` | phpcbf | same |
| `composer static-analysis` | phpstan | `phpstan.neon` |
| `composer test` | phpunit | `phpunit.xml` |
| `composer twig-cs-check` / `twig-cs-fix` | Twig CS Fixer, only for Admin, Frontend and Light | `config/twig-cs-fixer.php` |

The checks (`check`, `cs-check`, `static-analysis`, `test`, `twig-cs-check`) are read-only.
The fixers (`cs-fix` and `twig-cs-fix`) change the files in place.
Run them only on a tree where you accept a new format for the changes.
You can run all of them without asking the user.
The `twig-cs-*` scripts are not in the `allow` tier, so Claude Code asks for approval for them.

The `guard-bash.sh` hook always refuses installers (`composer install`/`update`/`require`/`remove`), migrations (`migrate`, `execute`) and `fixtures:execute`, also with approval.
Never try to run them.
Give the user the exact command to run, and say what it will change.

## Sequence of steps after you edit PHP

1. `composer cs-fix`: mechanical formatting.
2. `composer cs-check`: the problems that phpcbf could not fix.
   These are usually import order, a missing `use function`, line length, or missing type declarations.
   Fix them by hand.
3. `composer static-analysis`: types.
4. `composer test`: behaviour.

At the end, run the full `composer check` again.
Formatting can move the lines that phpstan reports on.

## Frequent failures and the correct fix

| Symptom | Fix |
| --- | --- |
| `Function count() should not be referenced via a fully qualified name` | add `use function count;` after the class imports |
| `Expected 1 space after "!"` | write `! $foo` |
| `Missing declare(strict_types=1)` | add it after `<?php` and a blank line |
| `Line exceeds 120 characters` | put one argument on each line, with a trailing comma |
| phpstan `Cannot call method on X\|null` | add an `instanceof` guard, then throw the not-found exception of the project |
| phpstan `no value type specified in iterable type array` | add `@param array<non-empty-string, mixed>` / `@return X[]` |
| phpstan `expects non-empty-string, string given` | make the type narrower at the boundary, or give the validated shape a type with `@phpstan-type` |
| Route denied in a functional test | the authorization entry for that route name is missing |
| Assertion failure in the response helper of the abstract handler | the delegator registration of the handler is missing in `ConfigProvider` |
| Service not found in the container | the `factories` entry is missing, or the `aliases` entry for the interface is missing |
| Class not found after you add a namespace | run `composer dump-autoload`, then check the PSR-4 mapping and its case |

**Forbidden "fixes":**

- Make the phpstan level lower.
- Add `<exclude>` or `<exclude-pattern>` to `phpcs.xml`.
- Add `// phpcs:ignore` or `@phpstan-ignore-next-line`.
- Add `markTestSkipped()` to a test that you broke.
- Delete an assertion.

If a rule really does not apply, say so and let the user decide.

## CI

Dotkernel repositories usually run a laminas-ci matrix on the supported PHP versions.
They also run separate workflows for static analysis, coverage, code quality and schema validation.
Know these points:

- The matrix covers many PHP versions.
  A pass on one version on your computer is not a pass.
- Schema validation fails when the entities and the migrations are different.
  Generate a migration, and do not edit the entity to match an old one.
- An old local `.phpcs-cache` or `.phpunit.result.cache` can hide a failure that CI finds.

## Reporting

Copy the real failure lines, and do not summarize them.
If you did not run a check, say so clearly.
Never say that the suite passed if you did not run it.
