---
name: dotkernel-package-status
description: 'Select, justify and verify PHP/Composer dependencies in Dotkernel projects, and tell whether a Dotkernel package is still maintained. Use this skill ANY time before you suggest, add, evaluate or replace a package, edit composer.json, run `composer require`/`composer remove`, or answer "what should I use for X". Also use it when the user only asks how to implement something that a library can solve (mail, queues, caching, logging, validation, pagination, auth, CLI, fixtures, uploads, GeoIP, error handling, HTTP client). Also use when asked whether a Dotkernel package is still maintained, what a package does, which PHP versions it supports, whether it is safe for a new project, or what the state of the Dotkernel open-source portfolio is. Enforces this order: already installed, then dotkernel/*, then laminas & mezzio, then a vetted community package, then hand-rolled code. Answers from the published dotkernel.com listing, not from memory. Also use each time that you find yourself naming a package from memory.'
---

# Dotkernel package status and dependency policy

```text
Applies to
  Projects:  - all
  Packages:  - all
```

Dotkernel is a Mezzio/Laminas ecosystem with its own first-party `dot-*` layer.
The stack usually already contains a solution when you think "I need a library for this".
A package from outside the stack is a governance decision, not a convenience.

## Source of truth

Dotkernel publishes the support status of its open-source packages as a machine-readable listing.
The site builds the listing again each day from the GitHub organization.
This skill uses only this source for `dotkernel/*` packages.
Use the listing, not your memory.
Names change, lifecycle states change, and a package that was active at training time can be security-only now.

- Data: <https://www.dotkernel.com/dotkernel-packages.json>
- Human-readable page: <https://www.dotkernel.com/dotkernel-packages-oss-lifecycle/>
- Site that publishes both, and the code that generates them:
  <https://github.com/dotkernel/dotkernel.com>

The dotkernel.com site makes the listing, not a single package.
Thus you do not install or generate anything to use it, and it works from all repositories.
Get a new copy of the listing for each question.
Do not save a copy into the project.
Report a wrong or old entry against `dotkernel/dotkernel.com`.
Report a wrong lifecycle value against the repository of the package, because the `OSSMETADATA` file that declares the value is in that repository.

### Shape

```json
{
    "generated_at": "2026-08-05T10:14:45+00:00",
    "org": "dotkernel",
    "packages": [
        {
            "name": "dot-cache",
            "url": "https://github.com/dotkernel/dot-cache",
            "description": "Dotkernel cache component",
            "lifecycle": "active",
            "php": "~8.3.0 || ~8.4.0",
            "archived": false
        }
    ]
}
```

- `name` - the repository name without the vendor.
  The Composer package is `dotkernel/<name>`.
- `description` - the GitHub repository description.
  The value is `null` when the repository has no description.
- `lifecycle` - see the table below.
  Values other than the four in the table are possible.
  Such a value means that the repository declared a value that the site does not know.
  Report it as undeclared, and do not guess.
- `php` - the `require.php` constraint from the `composer.json` of the package.
  The value is `null` when the package declares no constraint, or when the site could not read the file.
  A `null` is missing data, not "any PHP version."
- `archived` - the archived flag of GitHub, which is independent of `lifecycle`.
  A repository can be archived on GitHub and still declare an older lifecycle.
  The page shows that case as a separate "Archived on GitHub" note.

The listing has no keywords, release dates, download counts or successor field.
Do not say that any of those come from the listing.

### What each lifecycle means for a consumer

| Value | What to tell the user | As a new dependency |
| --- | --- | --- |
| `active` | The maintainers develop it actively, with new features and fixes. It is safe for a new project. | Yes |
| `maintenance` | The maintainers support it and release fixes, but no new features. You can stay on it, but expect no new capabilities. | Yes, and say so |
| `security-only` | The maintainers release only security fixes. Plan an upgrade or a replacement now. | No. This is a red flag, so ask first. |
| `archived` | Nobody maintains it. Do not use it in new projects. Migrate the existing projects. | No |

Apply the same rules to `archived: true` as to the `archived` lifecycle, whatever the value of `lifecycle` is.

### Querying it

```bash
curl -fsSL https://www.dotkernel.com/dotkernel-packages.json \
  | jq -r --arg q 'cache' '.generated_at, (.packages[]
      | select(((.name // "") + " " + (.description // "")) | ascii_downcase | contains($q))
      | "\(.name)  \(.lifecycle)  php=\(.php // "unknown")  archived=\(.archived)  \(.description // "")")'
```

Match on `name` and `description`, not on a name that you guess.
If the shell cannot connect to the site, load the human-readable page.

## The ladder: use it in sequence, and stop at the first match

**0. Already installed.** Read `composer.json` and grep `composer.lock` before you do other steps.
Dotkernel API has a large transitive tree (laminas-*, mezzio-*, doctrine/*, league/oauth2-server, symfony components, psr/*).
If the lock file already contains a package, use it.
This adds no new dependency.

```bash
jq -r '.require, .["require-dev"] | keys[]' composer.json | sort
jq -r '.packages[].name, .["packages-dev"][].name' composer.lock | sort   # full transitive tree
composer show | grep -i <keyword>                                         # installed packages only
```

**1. A `dotkernel/*` package.** Search the listing (see *Source of truth*).
Use it also when a more popular community package exists.
Consistency with the ecosystem and with the expectations of the maintainers is more important than the number of features.
Use only a package that agrees with all these conditions:

- The lifecycle is `active` or `maintenance`.
- The package is not archived on GitHub.
- The `php` constraint covers each PHP version that `require.php` in the `composer.json` of this project allows.

**2. `laminas/*` or `mezzio/*`.** These packages are almost first-party.
Dotkernel uses them as its base, the tree usually already contains them, and the `dot-*` packages are thin wrappers around them.

**3. A vetted community package.** Use one only when steps 0–2 cannot cover the need.
Use `symfony/*`, `doctrine/*`, `psr/*` and `league/*` first.
The stack already depends on them, so you make an existing surface larger and do not open a new one.
The package must agree with all these conditions:

- It is actively maintained.
- You can install it on each PHP version that `require.php` of this project allows.
- It is not abandoned.
- It has a real license.
- It does not duplicate a package that is already in the tree.

"Actively maintained" means a release in the last 12 months.
This is the approximate rule that the user applies when the user confirms the package.
This skill has no release dates, so it cannot check the rule itself.

**4. Write it yourself.** For a small need that is easy to understand (a value object, a 40-line helper, a single middleware), code in the tree is better than a dependency.
Say this clearly.
Do not select a package silently.

## Verifying a name

Never name a package from memory.
A name is **verified** only when you read it in one of these sources:

- the `composer.lock` of this project (any vendor), or
- the dotkernel.com listing (`dotkernel/*` only).

All other names are **unverified**, for example a `laminas/*`, `mezzio/*` or community package that is not already installed.
Use the word "unverified" for them.
Tell the user to confirm the maintenance status, the PHP support and the license, because this skill has no source for them.

If you cannot get the listing, say so.
Then call each `dotkernel/*` name that is not in `composer.lock` unverified.
Do not use the status that you remember, because the listing exists to replace that memory.

## Answering status questions

- Give the `generated_at` value.
  The listing is a daily snapshot, so say the date and time of the data.
- Absence does not mean that the package does not exist.
  The site lists a repository only when the repository has an `OSSMETADATA` file that declares its lifecycle.
  The site also excludes repositories that are not packages (documentation, skeleton projects, the site itself).
  If a name is missing, say that it is not in the published package listing.
  Then check <https://github.com/orgs/dotkernel/repositories>.
  Do not say that the package does not exist.
- For "is X maintained?", start with the lifecycle sentence from the table above.
  Then give the PHP constraint if the question is about an upgrade.
- For "what should I use instead?", remember that the listing has no successor field.
  Say that the package is archived or security-only.
  Use the ladder for the need that the package served.
  Give the GitHub `url` and the lifecycle page.
  Do not invent a replacement.

The site serves the JSON from the document root of dotkernel.com, so its URL follows the name of the deployed file.
If the request returns 404, load the human-readable page above and read the "View as JSON" link from it.
Alternatively, check the `dataFile` setting in `config/autoload/packages.global.php` in <https://github.com/dotkernel/dotkernel.com>.

## Contributing to dotkernel/api specifically

This repository belongs to other persons.
A new dependency changes the dependency surface of each downstream Dotkernel project.

- **Do not run `composer require` on a contribution branch.** Solve the problem with the installed packages.
  If that is not possible, write a proposal (see below) and let the maintainers decide.
  The correct first step is an issue or a discussion on the repository, not a commit.
- A new dependency in a PR without agreement before the PR is the most frequent cause of a stopped Dotkernel PR.
  Tell the user about this before you write code that needs a new package.
- `require-dev` does not make a dependency free of cost, because CI runs it.

## Output format when you really need a dependency

Always show the work.
Never show a single option as if it is the only option.

```text
Dependency proposal
Need:        <one line — the capability, not the package>
Installed?   <what you grepped, and why it does not cover the need>
Dotkernel:   <candidate — lifecycle, php, listing generated_at> or "none — searched: x, y, z"
Laminas:     <candidate, installed or unverified> or "none"
Community:   <candidate> — unverified: confirm a release in the last 12 months, PHP support and license
Recommend:   <choice> + one-sentence why
Alternative: <hand-rolled sketch, ~n lines>
Decision:    yours — I have not modified composer.json
```

## Where to look first, by need

Verify each entry against the listing and `composer.lock`.
Use this table as a search hint, not as a source of truth.

| Need | Look at |
| --- | --- |
| DI / factories through attributes | `dot-dependency-injection` |
| Routing, route groups | `dot-router` + `mezzio-router` |
| Errors, logging, error middleware | `dot-errorhandler`, `dot-log` |
| Mail | `dot-mail` (wraps symfony/mailer) |
| Caching | `dot-cache` |
| CLI commands | `dot-cli` + `laminas-cli` |
| Pagination / collections | `dot-paginator` |
| Input validation and filtering | `dot-inputfilter`, `dot-filter`, `dot-validator`, `laminas-inputfilter` |
| Authorization / RBAC / guards | `dot-authorization*`, `dot-rbac-guard` |
| API authentication | `league/oauth2-server` through `mezzio-authentication-oauth2` (already in API) |
| Doctrine fixtures | `dot-data-fixtures` |
| GeoIP | `dot-geoip` |
| Response headers | `dot-response-header` |
| Queues / async | `symfony/messenger`, connected as in the stock Queue: `netglue/laminas-messenger` and a transport such as `symfony/redis-messenger`. `dotkernel/queue` is a project skeleton to start a worker from. Never `composer require` it. |
| Scaffolding new code | `dot-maker` (generate boilerplate, do not write it by hand) |
| HTTP client | the client that is already in the lock file. Do not add guzzle if `symfony/http-client` is present. |

## Red flags: stop and ask

- You are about to write a package name that you did not read in the listing or in the lock file.
- The package solves a problem that you did not confirm in this codebase.
- It duplicates a package that is already in `composer.lock` under a different vendor.
- Its PHP constraint excludes a version that `require.php` of this project allows, or the `php` value in the listing is `null`.
- It is `security-only` or `archived` in the listing, or `archived: true` on GitHub.
- You want to add it to make a test pass.
