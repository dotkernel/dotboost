# Reference

## Bootstrap

| Command | Purpose |
| --- | --- |
| `/dk-bootstrap` | Take a fresh Dotkernel clone to a running local install |

## Build

| Command | Purpose |
| --- | --- |
| `/dk-module` | Plan a new module end to end (`dot-maker` first) |
| `/dk-route` | Add a fully wired route — an API endpoint or an admin/frontend page |
| `/dk-deprecate` | Apply the evolution pattern to a breaking change (sunset, not `/v2`) |

## Verify

| Command | Purpose |
| --- | --- |
| `/dk-test` | Write and run tests for a module, route, or class |
| `/dk-check` | Run the full QA gate and fix what it reports |
| `/dk-hygiene` | Verify and fix encoding, line endings, and whitespace across changed files |
| `/dk-trace` | Trace a request end to end through the pipeline, handler, and response |

## Document and review

| Command | Purpose |
| --- | --- |
| `/dk-document` | Write or update the feature doc for a change |
| `/dk-review` | Pre-PR review of the working tree against Dotkernel conventions |

`/dk-review` is read-only by design.
If it finds a missing or stale feature doc, it tells you to run `/dk-document` rather than writing one itself.
See [Feature Documentation](../feature-docs.md).
