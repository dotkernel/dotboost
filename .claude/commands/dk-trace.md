---
description: Trace a request end to end through the pipeline, handler and response
argument-hint: <METHOD /path> or <HandlerClassName>
allowed-tools: Read, Grep, Glob, Bash(php bin/cli.php:*)
---

Trace: **$ARGUMENTS**

Read-only. Modify nothing. Produce a walkthrough I can use to understand or debug this route:

1. **Variant** — which Dotkernel application this is, briefly.
2. **Route** — find it in the module's `RoutesDelegator`: pattern, method, route name, handler.
3. **Authorization** — which roles hold that route name in this app's authorization config. Say so
   explicitly if it is missing.
4. **Pipeline** — the middleware from `config/pipeline.php` this request passes through, in order,
   noting the ones that actually act here: CORS, content negotiation, authentication,
   authorization, resource resolution, deprecation, session/CSRF.
5. **Handler** — constructor dependencies via `#[Inject]`, what `handle()` does, which exceptions
   it can throw and the status each maps to.
6. **Validation** — the InputFilter or Form, and each input's filters and validators.
7. **Service and persistence** — the service method, the repository query, the entities touched.
8. **Response** — the HAL metadata entry or the template rendered, what is exposed, the success
   status, and the error shape.
9. **Documentation** — the matching OpenAPI operation, or note that it is missing or not
   applicable.
10. **Tests** — which existing tests cover this, and which standard cases are not covered.

End with anything that looks wrong or unregistered.
