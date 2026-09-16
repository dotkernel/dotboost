# Guardrails vs. Permissions

`guard-bash.sh` refuses some commands outright that `settings.json`'s permission tiers only mark `ask`.
This is deliberate — the hook can see into compound Bash commands that a path/prefix permission rule cannot — but it means the approval prompt you'd expect from the `ask` tier never appears.
You get a flat refusal instead.

| Command | `settings.json` says | `guard-bash.sh` does |
| --- | --- | --- |
| `git rebase` | ask | blocks |
| `doctrine-migrations migrate` / `execute` | ask | blocks |
| `fixtures:execute`, `schema:drop`, `schema:update` (via `bin/cli.php`) | ask | blocks |
| `composer development-enable` / `-disable` | — | blocks |
| `pip install`, `git checkout --`, `git filter-branch` | — | blocks |

Everything else under `ask` — commits, `mysql`, the config and QA files — prompts as documented in [Permissions Reference](../permissions/reference.md).

## If you want one of these back

Editing `settings.local.json` will not reach a hook-level block — that override layer only affects the permission tiers.
To allow one of these commands, edit `guard-bash.sh` itself, and do so deliberately: every command in this table is either a schema-mutating or history-rewriting operation, which is why it's blocked at the hook layer instead of left to a prompt someone could approve on autopilot.
