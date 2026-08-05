---
name: dotkernel-package-status
description: Use when asked whether a Dotkernel package is still maintained, what a package does, which PHP versions it supports, whether it is safe for a new project, or what the state of the Dotkernel open-source portfolio is.
  Answer from the published listing rather than from memory.
---

# Dotkernel package status

Dotkernel publishes the support status of its open-source packages as a machine-readable listing, rebuilt daily from the GitHub organization.
Prefer it over recollection: lifecycle states change, and a package that was active at training time may be security-only now.

- Data: <https://www.dotkernel.com/dotkernel-packages.json>
- Human-readable page: <https://www.dotkernel.com/dotkernel-packages-oss-lifecycle/>
- Site that publishes both, and the code that generates them: <https://github.com/dotkernel/dotkernel.com>

The listing is a product of the dotkernel.com site rather than of any single package, so nothing needs to be installed to use it and it works from any repository.
Report a wrong or stale entry against `dotkernel/dotkernel.com`, and a wrong lifecycle value against the package's own repository, which is where the `OSSMETADATA` file that declares it lives.

## Shape

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

- `name` - the bare repository name. The Composer package is `dotkernel/<name>`.
- `description` - the GitHub repository description; `null` when the repository has none.
- `lifecycle` - see below.
Values outside the four listed are possible and mean the repository declared something unrecognized; report it as undeclared rather than guessing.
- `php` - the `require.php` constraint from the package's `composer.json`, or `null` when it declares none or the file could not be read.
A `null` is missing data, not "any PHP version."
- `archived` - GitHub's own archived flag, which is independent of `lifecycle`.
A repository can be archived on GitHub while still declaring an older lifecycle, and the page surfaces that as a separate "Archived on GitHub" note.

## What each lifecycle means for a consumer

| Value           | What to tell someone                                                                               |
|-----------------|----------------------------------------------------------------------------------------------------|
| `active`        | Actively developed, new features and fixes. Safe for a new project.                                |
| `maintenance`   | Still supported, receiving fixes but no new features. Safe to stay on; expect no new capabilities. |
| `security-only` | Only security fixes are released. Plan an upgrade or replacement now.                              |
| `archived`      | No longer maintained. Do not use in new projects; migrate existing ones.                           |

## Answering well

- Cite `generated_at`.
The listing is a daily snapshot, so say what it was current as of.
- Absence is not non-existence.
A repository is only listed when it carries an `OSSMETADATA` file declaring its lifecycle, and the site excludes non-package repositories (documentation, skeleton apps, the site itself).
If a name is missing, say it is not in the published package listing and check <https://github.com/orgs/dotkernel/repositories> - do not say it does not exist.
- For "is X maintained?", lead with the lifecycle sentence above, then the PHP constraint if the question is about upgrading.
- For "what should I use instead?", the listing gives no successor field.
Say the package is archived or security-only and point at the GitHub `url` and the lifecycle page rather than inventing a replacement.
- If the fetch fails, say so.
Do not fall back to remembered status, which is exactly what this listing exists to replace.

The JSON is served from the document root of dotkernel.com, so its URL tracks the deployed file name.
If the request 404s, load the human-readable page above and read the "View as JSON" link from it, or check the `dataFile` setting in `config/autoload/packages.global.php` in <https://github.com/dotkernel/dotkernel.com>.
