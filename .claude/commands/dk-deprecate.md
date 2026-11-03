---
description: Apply the evolution pattern to a breaking change (sunset, not /v2)
argument-hint: <handler, route or field> — what is changing and why
allowed-tools: Read, Grep, Glob, Edit, Bash(composer cs-check), Bash(composer test)
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

Breaking change under consideration: **$ARGUMENTS**

Load `dotkernel-evolution-pattern`.

1. **Classify** the change against the decision table. Additive (just do it), payload-branchable
   (old shape keeps old behaviour), deprecable (sunset window), or genuinely version-worthy (rare —
   say so explicitly)?
2. **Propose the non-breaking route first.** Only recommend deprecation if there is no additive way
   to reach the goal.
3. If deprecation is right:
   - Propose a sunset date, and justify the window rather than picking one silently.
   - Keep the old behaviour working until that date; new behaviour goes alongside it.
   - **API:** add the deprecation attribute to the handler with that date, mark the operation
     deprecated in the module's OpenAPI file pointing at the replacement, and add or extend a test
     asserting the `Sunset` header.
   - **Templated project:** there is no header. A page moving to a new URL gets a permanent
     redirect from the old URL now — that redirect is how old links keep working — plus a test
     asserting it. A page being removed keeps working until the sunset date and only then
     permanently redirects.
   - List the announcement channels I still owe clients: docs page, changelog, release notes.
4. Tell me exactly what must be deleted at sunset: handler, route, authorization entry,
   presentation metadata, documentation block.

Never introduce a version prefix, a `?version=` parameter or versioned media types without me
explicitly agreeing it is an architectural change.
