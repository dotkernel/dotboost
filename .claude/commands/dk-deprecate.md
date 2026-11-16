---
description: Apply the evolution pattern to a breaking change (sunset, not /v2)
argument-hint: <handler, route or field> — what is changing and why
allowed-tools: Read, Grep, Glob, Edit, Bash(composer cs-check), Bash(composer test)
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

Breaking change to examine: **$ARGUMENTS**

Load `dotkernel-evolution-pattern`.

1. **Classify** the change with the decision table.
   Select one class:
   - Additive: make the change.
   - Payload-branchable: the old shape keeps the old behaviour.
   - Deprecable: use a sunset window.
   - Truly version-worthy.
     This class is rare.
     If you select it, say so explicitly.
2. **Propose the non-breaking route first.** Recommend deprecation only when no additive change can reach the goal.
3. If deprecation is the correct choice:
   - Propose a sunset date.
     Give the reason for the window.
     Do not select a window silently.
   - Keep the old behaviour working until that date.
     Add the new behaviour next to the old behaviour.
   - **API:** Add the deprecation attribute with that date to the handler.
     In the OpenAPI file of the module, mark the operation as deprecated, and point to the replacement.
     Add or extend a test that asserts the `Sunset` header.
   - **Templated project:** There is no header.
     When a page moves to a new URL, add a permanent redirect from the old URL now.
     That redirect keeps the old links working.
     Add a test that asserts the redirect.
     When you remove a page, keep it working until the sunset date.
     Only after that date, add a permanent redirect.
   - List the announcement channels that I must still use for clients: docs page, changelog, release notes.
4. Tell me exactly what to delete at the sunset date: handler, route, authorization entry, presentation metadata, documentation block.

Never add a version prefix, a `?version=` parameter or versioned media types.
The only exception: I explicitly agree that it is an architectural change.
