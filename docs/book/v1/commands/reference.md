# Reference

## Bootstrap

| Command | Purpose |
| --- | --- |
| `/dk-bootstrap` | Bring a new Dotkernel clone to a local install that runs |

## Build

| Command | Purpose |
| --- | --- |
| `/dk-module` | Plan a new Dotkernel module from start to end (`dot-maker` first) |
| `/dk-route` | Add a fully wired route: an API endpoint (checked against `dotkernel-api-endpoint`) or an admin/frontend page, for example `/dk-route POST /book/{id}/review` |
| `/dk-deprecate` | Apply the evolution pattern to a breaking change (sunset, not `/v2`) |

## Verify

| Command | Purpose |
| --- | --- |
| `/dk-test` | Write and run tests for a module, route or class |
| `/dk-check` | Run the full QA gate and fix the problems that it reports |
| `/dk-hygiene` | Find and fix encoding, line ending and whitespace problems in changed files |
| `/dk-trace` | Trace a request from start to end through the pipeline, handler and response |

## Document and review

| Command | Purpose |
| --- | --- |
| `/dk-document` | Write or update the feature doc for a change |
| `/dk-review` | Review the working tree against Dotkernel conventions before a PR |

`/dk-review` is read-only by design.
If it finds a feature doc that is missing or out of date, it tells you to run `/dk-document`.
It does not write the doc.
See [Feature Documentation](../feature-docs.md).

`/dk-review` also checks that new and changed prose obeys ASD-STE100, with the rules from `dotkernel-writing-style`.
The check covers comments, docblock descriptions, Markdown prose, messages, CLI output, OpenAPI descriptions and the commit messages on the branch.
A finding is *Should fix*, not *Blocking*.
