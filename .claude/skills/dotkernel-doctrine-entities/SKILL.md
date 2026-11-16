---
name: dotkernel-doctrine-entities
description: >
  Use when you add or change anything persisted in a Dotkernel project: a Doctrine
  entity, column, relation, index, repository, backed enum with its DBAL type, fixture, or
  migration. Also use for questions about UUID versus numeric identifiers, timestamps, the
  table prefix, why doctrine-migrations diff produces an unexpected diff, or why a
  schema-validation CI job is failing.
---

# Entities, repositories and migrations

```text
Applies to
  Projects:  - Dotkernel API
             - Dotkernel Admin
             - Dotkernel Frontend
  Packages:  - none
```

In the stock API and Admin, all the code in this skill is in the `Core` layer, in `src/Core/src/<Module>/src/`.
The migrations are in `src/Core/src/App/src/Migration/` (see `dotkernel-core-submodule`).
The stock Frontend also uses Doctrine.
But it keeps entities in its own modules and migrations in `data/doctrine/migrations/`.
In the Frontend, use its layout, not the paths in this skill.

## Entity anatomy

```php
#[ORM\Entity(repositoryClass: BookRepository::class)]
#[ORM\Table(name: 'book')]
#[ORM\HasLifecycleCallbacks]
class Book extends AbstractEntity
{
    use TimestampsTrait;
    use UuidIdentifierTrait;

    #[ORM\Column(name: 'title', type: 'string', length: 191)]
    protected string $title;

    #[ORM\Column(
        type: 'book_status_enum',
        enumType: BookStatusEnum::class,
        options: ['default' => BookStatusEnum::Draft]
    )]
    protected BookStatusEnum $status = BookStatusEnum::Draft;

    /** @var Collection<int, Review> */
    #[ORM\OneToMany(targetEntity: Review::class, mappedBy: 'book', cascade: ['persist', 'remove'])]
    protected Collection $reviews;
}
```

Rules:

- Extend the `Core` abstract entity.
  It implements `ArraySerializableInterface`, and the hydrators and serialisers need this interface.
- Use the UUID identifier trait for each entity that a URL shows.
  Use the numeric trait only for internal join and lookup tables.
  Public identifiers are UUIDs, never auto-increment ids.
- Use the timestamps trait and `#[ORM\HasLifecycleCallbacks]` for the created and updated times.
- Use the password trait for each entity with a password.
  The trait hashes the password.
  Never hash a password by hand.
- In the constructor, initialise each `Collection` property with `new ArrayCollection()`.
  Also call `parent::__construct()`.
- `length: 191` is the house default for indexed strings, because it is safe for utf8mb4.
  Keep the related `StringLength` validator in sync.
- Put reserved words in the table name between backticks.
- Annotate collections (`@var Collection<int, X>`), or phpstan fails.
- Write fluent setters that return `self`, as the rest of the codebase does.

## Backed enums need three pieces

A column with an enum type needs these three pieces:

1. `Core\<Module>\Enum\BookStatusEnum`, a string-backed enum.
2. `Core\<Module>\DBAL\Types\BookStatusEnumType`.
   It extends the `Core` abstract enum type and implements `getEnumClass()` and `getName()`.
   The name is the string in the `type:` of the column.
3. A registration under `doctrine.types` in the `ConfigProvider` of the module.

The abstract enum type writes the correct SQL for each platform.
It writes a native enum on MySQL/MariaDB and PostgreSQL, and `TEXT` on SQLite.
Because of the SQLite case, in-memory functional tests work.
A hand-written type that ignores SQLite passes locally and fails in CI.

## Repositories

Extend the `Core` abstract repository.
Put query builders in the repository.
Do not put business rules in it.
Return `QueryBuilder` from list methods, so that the caller can paginate.

The shared paginator helper normalises the pagination parameters.
The service **must whitelist** the sort column before the column gets to the query builder.

## Migrations

```bash
php ./vendor/bin/doctrine-migrations diff      # generate — ASK FIRST, it reads the live DB
php ./vendor/bin/doctrine-migrations migrate   # apply    — the user runs it, see below
php ./vendor/bin/doctrine-migrations status
```

`diff` and `status` ask for approval.
The `guard-bash.sh` hook always refuses `migrate` and `execute`, with or without approval.
Never try to run them.
Give the user the exact command to run, and tell what it changes.

- The migrations are generated into the configured migrations path.
  **Never edit them by hand.**
  A wrong diff means that the entity is wrong.
  Fix the entity and generate the migration again.
- Before you apply the generated SQL, review it.
  `diff` can propose to drop a column and gives no warning.
- Put one logical schema change in each migration.
- When the project supports a table prefix, an event listener applies it.
  Never hardcode prefixes into table names.
- **Each project that shares the database must apply the same migration.**
- When the entities and the migrations are not in sync, a schema-validation CI job fails.
  If the job fails, a migration is missing.
  Do not edit the entity to match an old migration.

## Fixtures

Seed the data with the data-fixtures package.
The order is important: load the roles before the records that refer to them.

```bash
php ./bin/doctrine fixtures:list
php ./bin/doctrine fixtures:execute                      # the user runs it
php ./bin/doctrine fixtures:execute --class=BookLoader   # the user runs it
```

`fixtures:list` asks for approval.
`fixtures:execute` writes to the database, and the `guard-bash.sh` hook always refuses it.
Give the user the command to run.

Functional tests usually build a new schema and load all the fixtures for each test.
Thus a new fixture has an immediate effect on all the tests.
Keep fixtures small and deterministic.

## Checklist

- [ ] The Entity and the Repository are in `Core`.
- [ ] Each enum column has an enum, a DBAL type and a `doctrine.types` registration.
- [ ] The collections are initialised and annotated.
- [ ] The validators use the same column lengths.
- [ ] The migration is generated (not written by hand), reviewed and applied.
- [ ] A fixture is added if the table needs seed data.
- [ ] All the other projects on this database are taken into account.
- [ ] Static analysis passes.
  The Doctrine phpstan extension is strict.
