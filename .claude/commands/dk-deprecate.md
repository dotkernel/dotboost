---
description: Apply the evolution pattern to a breaking change (sunset, not /v2)
argument-hint: <handler, route or field> — what is changing and why
allowed-tools: Read, Grep, Glob, Edit, Bash(composer cs-check), Bash(composer test)
---

Breaking change under consideration: **$ARGUMENTS**

Load `dotkernel-evolution-pattern`.

1. **Classify** the change against the decision table. Additive (just do it), payload-branchable
   (old shape keeps old behaviour), deprecable (sunset window), or genuinely version-worthy (rare —
   say so explicitly)?
2. **Propose the non-breaking route first.** Only recommend deprecation if there is no additive way
   to reach the goal.
3. If deprecation is right:
   - Add the deprecation attribute to the handler with a proposed sunset date, and justify the
     window rather than picking one silently.
   - Keep the old behaviour intact until that date; new behaviour goes alongside it.
   - Mark the operation deprecated in the module's OpenAPI file, pointing at the replacement (API
     apps). For a templated app, add a permanent redirect from the old URL instead.
   - Add or extend a test asserting the deprecation signal.
   - List the announcement channels I still owe clients: docs page, changelog, release notes.
4. Tell me exactly what must be deleted at sunset: handler, route, authorization entry,
   presentation metadata, documentation block.

Never introduce a version prefix, a `?version=` parameter or versioned media types without me
explicitly agreeing it is an architectural change.
