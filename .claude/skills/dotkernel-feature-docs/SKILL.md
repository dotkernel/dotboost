---
name: dotkernel-feature-docs
description: >
  Use when you write down what a feature does and why in a Dotkernel project. This includes after
  building or changing a route, module, command or entity, and when asked to document a feature,
  write release notes, record a decision, explain an endpoint to another developer, or bring an
  existing feature doc back in line with the code. Also use when a feature exists but nothing
  outside the code explains it, when a doc still describes behaviour that has since changed, and
  before adding behaviour to an area that already has a feature doc.
---

# Feature documentation

```text
Applies to
  Projects:  - all
  Packages:  - none
```

The code records *what* a project does.
A feature doc records *why*.
It also records four things that are in four different files: the routes, the roles that can get access to them, the added data, and how to test the feature.
A new session cannot get this information from `src/`, and the information is lost when you clear a session.

Write one doc for each **feature**, never one for each commit and never one for each route.
When two routes have a purpose only together, put them in one doc.

## Where it goes

Do a check before you write.
Some Dotkernel repositories already have a `documentation/` directory.
It contains some combination of `command/*.md`, a generated `openapi.json` and Postman collections.
Of the stock projects, only the API has one, but derived projects can add or remove it.
Do the check, and do not decide from the project type:

```bash
ls -d documentation docs 2>/dev/null
```

| The repository already has | Write to |
| --- | --- |
| `documentation/` | `documentation/features/` |
| `docs/` | `docs/features/` |
| neither | create `docs/features/` |

Never create a second documentation root next to an existing one.
The filename is `YYYY-MM-DD-<kebab-slug>.md`, where the date is the day that you write the doc.
This format sorts correctly and shows the reading sequence clearly.
The directory also contains a `README.md` index, with one row for each doc.

## The template

```markdown
---
feature: Book reviews
date: 2026-08-05
variant: dotkernel/api
status: shipped
modules: [Book]
routes:
  - POST /book/{id}/review
handlers:
  - Api\Book\Handler\Book\Review\PostBookReviewResourceHandler
---

# Book reviews

## Why

Two or three sentences: the need, and the constraint that gave the approach its form.
This is the only section that you cannot get from the code.

## Surface

| Route | Name | Handler | Roles |
| --- | --- | --- | --- |
| `POST /book/{id}/review` | `book::create-review` | `PostBookReviewResourceHandler` | `user` |

## Data

The added or changed entities and columns: in `Core` for API and Admin, in the `Entity/` of the module for Frontend.
Migration necessary: yes / no. Give the command, but do not run it.

## Config

Authorization entries, ConfigProvider registrations, new config keys, and the location of their secrets (`*.local.php`, never committed).

## Testing

What the tests cover, and how to run only the tests of this feature.

## Follow-ups

Known gaps, decisions for later, and all items that a reviewer accepted without a full check.
```

The frontmatter is the machine-readable part.
`/dk-review` greps `routes:` and `handlers:` to decide whether the doc covers a change.
Keep both lists correct, or the check for old docs passes silently.
`status` is one of `planned`, `shipped` or `deprecated`.

## Write it from the code, not from memory

Read each claim in the doc from a source.
This table gives the source for each section:

| Section | Source of truth |
| --- | --- |
| Routes and route names | the `RoutesDelegator` of the module |
| Roles | `authorization.global.php` (API). Admin / Frontend: the permission in `authorization-guards.global.php`, then the roles that have it in `authorization.global.php` |
| Handler class and path | the filesystem under `src/<Module>/src/Handler/` |
| Registrations | the `ConfigProvider` of the module |
| Data and migration need | the changed entities under `src/Core/` (API, Admin). Frontend: the `Entity/` of the module. Light and Queue: none |
| Testing | the test files that really exist |

A gap that you do not document is better than a fact that you invent.
If you cannot verify a fact, write `unverified` and give the file to check.
Examples are a role mapping that is not clear, or a migration status that is not known.
Do not state the answer that seems probable.
Readers trust a wrong feature doc as much as a correct one.

## What a feature doc is not

- **Not an API reference.** In a project that publishes OpenAPI, `OpenAPI.php` is the contract (see `dotkernel-openapi`).
  Give the name of the operation, but do not write its schemas again.
  Two descriptions of one payload become different over time, and the generated description is the one that counts.
- **Not a changelog.** Do not write a history for each release, and do not write version changes.
  The doc describes the feature as it is now.
  `git log` contains the history of the changes.
- **Not a code dump.** Refer to `src/Book/src/Handler/…` by its path.
  Copied code bodies become old silently, and a grep finds the real code quickly.
- **Not a design proposal.** A doc with `status: planned` states the intention and says that it is planned.
  It does not describe the intention in the past tense.

## Keep it current

When the same feature changes, update the existing doc.
Examples are a new route on an existing resource, an added role, or a renamed field.
Add a new doc only when the feature is really new.
Update the row in the `README.md` index in the same edit.

A breaking change through `dotkernel-evolution-pattern` changes the doc two times:

1. When the deprecation is merged, change `status` to `deprecated`.
   Write the sunset date and the name of the replacement in Follow-ups.
2. Remove the doc only after the route is removed.

## Security constraints

- **Never** put a real credential, token, internal hostname, customer email or production identifier in an example.
  Use placeholders that are clearly placeholders.
  Of all the artefacts, people copy documentation most frequently into a ticket, a chat or a public repository.
- Name where a secret lives (`config/autoload/*.local.php`), never its value.
- Do not document an internal route in a way that makes it look like a public surface.

## Definition of done

- [ ] The doc is in the features directory that this repository already uses, not in a new one.
- [ ] The filename is `YYYY-MM-DD-<kebab-slug>.md`.
      The frontmatter parses.
      The `status` is correct.
- [ ] `routes:` and `handlers:` list each route and handler that the feature added.
- [ ] Each route name in the Surface table matches `RoutesDelegator`.
      Each role matches the authorization config of this variant.
- [ ] Each file path and class name in the doc exists.
- [ ] `Why` explains a constraint, not the mechanics.
      The mechanics are in the code.
- [ ] The doc states the migration need, and gives the command but does not run it.
- [ ] The doc contains no credential, token, internal hostname or real customer data.
- [ ] The `README.md` index row is added or updated.
