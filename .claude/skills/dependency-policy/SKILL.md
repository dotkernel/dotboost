---
name: dependency-policy
description: 'Choose, justify and verify PHP/Composer dependencies in Dotkernel projects. Use this skill ANY time you are about to suggest, add, evaluate or replace a package, edit composer.json, run `composer require`/`composer remove`, or answer "what should I use for X" — including when the user only asks how to implement something a library could solve (mail, queues, caching, logging, validation, pagination, auth, CLI, fixtures, uploads, GeoIP, error handling, HTTP client). Enforces this order — already installed, then dotkernel/*, then laminas & mezzio, then a vetted community package, then hand-rolled code. Also use whenever you catch yourself naming a package from memory.'
---

# Dependency Policy (Dotkernel)

Dotkernel is a Mezzio/Laminas ecosystem with its own first-party `dot-*` layer. Most
"I need a library for this" moments are already solved inside the stack. Reaching outside
it is a governance decision, not a convenience.

## The ladder — walk it in order, stop at the first hit

**0. Already installed.** Read `composer.json` and grep `composer.lock` before anything else.
Dotkernel API ships a large transitive tree (laminas-*, mezzio-*, doctrine/*, league/oauth2-server,
symfony components, psr/*). If a package is already in the lock file, use it — no new dependency.

```bash
jq -r '.require, .["require-dev"] | keys[]' composer.json | sort
jq -r '.packages[].name, .["packages-dev"][].name' composer.lock | sort   # full transitive tree
composer show | grep -i <keyword>
```

**1. A `dotkernel/*` package.** Search the local manifest (see *Lookup*, below). Prefer it even if
a more popular community package exists — consistency with the ecosystem and the maintainers'
expectations outweighs raw feature count.

**2. `laminas/*` or `mezzio/*`.** These are effectively first-party-adjacent: Dotkernel is built
on them, they are already in the tree, and `dot-*` packages are thin wrappers over them.

**3. A vetted community package.** Only when 0–2 genuinely cannot cover the need. Requires all of:
actively maintained (release in the last ~12 months), `php: ^8.4` compatible, not abandoned,
a real license, and no duplication of something already in the tree.
Prefer `symfony/*`, `doctrine/*`, `psr/*` and `league/*` — the stack already depends on them, so
you are widening an existing surface rather than opening a new one.

**4. Write it yourself.** For a small, well-understood need (a value object, a 40-line helper,
a single middleware), in-tree code beats a dependency. Say so explicitly instead of silently
picking a package.

## Lookup — never name a package from memory

Model memory of the `dot-*` catalogue is unreliable: names drift, packages get abandoned and
superseded (`dot-annotated-services` -> `dot-dependency-injection` is the classic case).

1. Read `references/dotkernel-packages.json` (regenerate with `scripts/sync-dotkernel-packages.sh`).
2. Match on `description` and `keywords`, not on a guessed name.
3. Check `abandoned` / `replacement` before proposing anything.
4. Confirm the name resolves before you write it into a file:

```bash
jq -r --arg q 'cache' '.packages[] | select((.description + " " + (.keywords|join(" "))) | ascii_downcase | contains($q)) | "\(.name)  \(.latest)  \(.description)"' references/dotkernel-packages.json
composer show dotkernel/dot-cache --available   # hard existence check
```

If the manifest is missing or stale, regenerate it. If you cannot (no network), say the name is
**unverified** rather than asserting it.

## Contributing to dotkernel/api specifically

This is someone else's repository. Adding a dependency changes the dependency surface of every
downstream Dotkernel application.

- **Do not run `composer require` on a contribution branch.** Solve the problem with what is
  installed. If that is impossible, produce a proposal (below) and let the maintainers decide —
  the right first step is an issue or discussion on the repo, not a commit.
- A new dependency in a PR that was not agreed in advance is the most common reason a Dotkernel PR
  stalls. Flag this to the user before writing any code that assumes a new package.
- `require-dev` is not a free pass — CI runs it.

## Output format when a dependency is genuinely needed

Always show the work. Never present a single option as if it were the only one.

```
Dependency proposal
Need:        <one line — the capability, not the package>
Installed?   <what you grepped, and why it does not cover the need>
Dotkernel:   <candidate or "none — searched keywords: x, y, z">
Laminas:     <candidate or "none">
Community:   <candidate> — last release <date>, php <constraint>, license <x>
Recommend:   <choice> + one-sentence why
Alternative: <hand-rolled sketch, ~n lines>
Decision:    yours — I have not modified composer.json
```

## Where to look first, by need

Verify each against the manifest and `composer.lock` — treat this as a search hint, not a source
of truth.

| Need | Look at |
|---|---|
| DI / factories via attributes | `dot-dependency-injection` |
| Routing, route groups | `dot-router` + `mezzio-router` |
| Errors, logging, error middleware | `dot-errorhandler`, `dot-log` |
| Mail | `dot-mail` (wraps symfony/mailer) |
| Caching | `dot-cache` |
| CLI commands | `dot-cli` + `laminas-cli` |
| Pagination / collections | `dot-paginator` |
| Input validation & filtering | `dot-inputfilter`, `dot-filter`, `dot-validator`, `laminas-inputfilter` |
| Authorization / RBAC / guards | `dot-authorization*`, `dot-rbac-guard` |
| API authentication | `league/oauth2-server` via `mezzio-authentication-oauth2` (already in API) |
| Doctrine fixtures | `dot-data-fixtures` |
| GeoIP | `dot-geoip` |
| Response headers | `dot-response-header` |
| Queues / async | `dotkernel/queue` + `symfony/messenger` |
| Scaffolding new code | `dot-maker` (generate, do not hand-write boilerplate) |
| HTTP client | whatever is in the lock file already — do not add guzzle if `symfony/http-client` is present |

## Red flags — stop and ask

- You are about to write a package name you did not read out of the manifest or the lock file.
- The package solves a problem you have not confirmed exists in this codebase.
- It duplicates something already in `composer.lock` under a different vendor.
- Its PHP constraint excludes 8.4, or its newest release predates PHP 8.2.
- It is `abandoned: true` in the manifest.
- You are adding it to make a test pass.
