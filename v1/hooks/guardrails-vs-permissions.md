# Guardrails vs. Permissions

`guard-bash.sh` refuses some commands that the permission tiers in `settings.json` only mark `ask`.
This is on purpose.
The hook can see into compound Bash commands, and a path or prefix permission rule cannot.
But because of this, you do not get the approval prompt that the `ask` tier gives.
You get a refusal.

| Command | `settings.json` says | `guard-bash.sh` does |
| --- | --- | --- |
| `git rebase` | ask | blocks |
| `doctrine-migrations migrate` / `execute` | ask | blocks |
| `fixtures:execute`, `schema:drop`, `schema:update` (through `bin/doctrine`) | ask | blocks |
| `git checkout --` | ask, through `git checkout` | blocks |
| `composer development-enable` / `-disable` | — | blocks |
| `pip install`, `git filter-branch` | — | blocks |

All the other items in the `ask` tier show a prompt, as [Permissions Reference](../permissions/reference.md) describes.
These items include commits, `mysql`, and the config and QA files.

## Allow one of these commands again

A change in `settings.local.json` does not remove a block at the hook level.
That override layer changes only the permission tiers.
To allow one of these commands, edit `guard-bash.sh`.
Make this change on purpose, after you think about it.
Each command in this table does one of these operations:

- It changes the database.
- It writes the git history again.
- It discards work that is not committed (`git checkout --`).
- It installs packages (`pip install`).
- It changes the committed config state (`development-enable`/`-disable`).

For this reason, the hook layer blocks it.
A prompt is not sufficient, because a person can approve a prompt without attention.
