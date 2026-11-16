---
description: Trace a request from start to end through the pipeline, handler and response
argument-hint: <METHOD /path> or <HandlerClassName>
allowed-tools: Read, Grep, Glob, Bash(php bin/cli.php:*)
---

<!-- markdownlint-disable-file MD041 --><!-- command format is frontmatter then prose; no heading -->

Trace: **$ARGUMENTS**

This command is read-only.
Do not change anything.
Write a walkthrough that I can use to understand or debug this route:

1. **Variant**: tell me briefly which Dotkernel project this is.
2. **Route**: find it in the `RoutesDelegator` of the module.
   Give the pattern, method, route name and handler.
3. **Authorization**: tell me which roles have that route name in the authorization config of this project.
   If the route name is missing, say so explicitly.
4. **Pipeline**: list the middleware from `config/pipeline.php` that this request goes through, in sequence.
   Identify the middleware that really acts here: CORS, content negotiation, authentication, authorization, resource resolution, deprecation, session/CSRF.
5. **Handler**: give the constructor dependencies through `#[Inject]` and what `handle()` does.
   Give the exceptions that it can throw, and the status for each exception.
6. **Validation**: give the InputFilter or Form, and the filters and validators of each input.
7. **Service and persistence**: give the service method, the repository query and the entities that the request uses.
8. **Response**: give the HAL metadata entry or the rendered template.
   Tell me which data the response shows, the success status and the error shape.
9. **Documentation**: give the related OpenAPI operation.
   If it is missing or not applicable, say so.
10. **Tests**: tell me which existing tests cover this route.
    Tell me which standard cases have no tests.

At the end, list each thing that looks wrong or is not registered.
