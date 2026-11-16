---
name: dotkernel-security
description: >
  Use when you touch anything security-relevant in a Dotkernel project: authentication,
  OAuth2 or session login, authorization config and role permissions or guards, CORS, content
  negotiation, session and cookie settings, error handling and error-reporting endpoints,
  documentation exposure, secrets and *.local.php versus *.global.php, demo credentials,
  ownership checks, raw DQL or SQL, or adding a dependency. Also use when you review a diff for
  security problems, or when the user asks whether something is safe to commit.
---

# Security

```text
Applies to
  Projects:  - all
  Packages:  - none
```

Think that each request is hostile.
If you ignore security, the cost is low today and high later.
The later cost can be lost data, a GDPR fine or lost client trust.
Each item below has a real location in the codebase.
Examine that location, and do not write a new solution.

Input validation has its own skill (`dotkernel-input-validation`).
Input validation is the first line of defence, and developers skip it most frequently.

## Authentication

| Variant | Mechanism |
| --- | --- |
| API | OAuth 2.0 (`mezzio/mezzio-authentication-oauth2`): access tokens and refresh tokens |
| Admin / Frontend | session-based login |
| Light / Queue | none in the stock repositories |

For OAuth2 projects:

- Replace or update the default clients before production.
- Compare the token lifetimes with the requirements.
  The usual lifetimes are one day for an access token and one month for a refresh token.
  Do not make a lifetime longer without a discussion.
- The key-generation script of the repository generates the keys into a data directory.
  **Never commit the keys, never edit them, and never read them into context.**

For session-based projects, keep `cookie_httponly`, `cookie_samesite` and `cookie_secure` hardened in the session config.
Each form must have CSRF protection.

## Authorization

| Variant | Where |
| --- | --- |
| API | RBAC roles and route-name permissions in `config/autoload/authorization.global.php` |
| Admin | roles → permissions in `authorization.global.php`, and route name → permission in `authorization-guards.global.php` |
| Frontend | the same two files, with guards keyed by route **and controller action** |
| Light / Queue | none |

- **The default is different, and this difference is the dangerous part.**
  The API denies a route that has no permission entry.
  The Admin and Frontend guards use `POLICY_ALLOW`.
  There, a route or action with no guard rule is **open to all users, guests included**.
  If you forget the entry there, you never see a 403.
  You get a page with no protection.
- **Each new route needs an explicit entry.**
  In the API, add an entry for each role.
  In Admin and Frontend, add a guard rule.
- Do not give a guest role access to anything, unless the route is really public.
  Examples of public routes are registration, activation and password recovery.
- Examine the role hierarchy.
  In these config files, the direction of inheritance is not always the direction that people expect.
  Read the comment at the top of the file.
- **Access to a route is not access to an object.**
  A user with permission to view "an account" must see only their own account.
  Where the project has a resource guard mechanism, use it.
  If not, add an explicit ownership check in the service.
  This is the most frequent real vulnerability in CRUD code.

## Configuration and secrets

| File | Committed? | May contain secrets? |
| --- | --- | --- |
| `*.global.php` | yes | **no** |
| `*.php.dist` | yes | **no**: placeholders only |
| `*.local.php` | no (git-ignored) | yes |

Never write a credential, a key, a token, a DSN that contains a password or an SMTP password into a committed file.
If you need a new setting, add the placeholder to the `.dist` file.
Then read the setting through config.

Development mode enables debug output and error details, and it disables config caching.
You must disable development mode in production.

## HTTP-layer protections

`config/pipeline.php` and `config/autoload/` configure these protections.
Keep the order.
If you change the order, give the reason.

- **CORS** (where present): pipe it **before** the routing middleware.
  Never widen the origins to `*` in a committed file.
- **Content negotiation**: it obeys `Content-Type` and `Accept`.
  Do not bypass it.
- **Malformed body handling**: it rejects payloads that it cannot parse, and it rejects them early.
- **Error handling**: it is the outermost layer, and it renders a safe error body.
  Throw typed exceptions.
  Never show stack traces, SQL, paths or internal class names.
- **Response headers**: one central location sets the security headers, not each handler.

## Persistence

Use the query builder with bound parameters.
**Never concatenate or interpolate strings into DQL or SQL.**
Whitelist the sort and filter values from the user against an explicit column list.
If you think that you need raw SQL, give the reason and ask.

## Error-reporting endpoints

Where the project exposes such an endpoint, a token and a permission middleware protect it.
Do not disable the token check in a committed file.
Do not widen the allowed IPs in a committed file.

## Documentation exposure

Never document a real credential, an internal hostname, or an example payload that contains production data.
Interactive documentation should not be enabled in production.

## Dependencies and supply chain

- **You must get explicit approval from the user before you add, remove or upgrade a Composer or npm package.**
  Propose the change and name the maintainer.
  Tell why the current stack cannot satisfy the need.
- The security-advisories dev dependency refuses versions with known vulnerabilities.
  If it blocks an install, treat this as a warning.
  Do not try to go around it.
- Let the automated dependency bot do the routine version updates.
- Attackers actively target the JavaScript supply chain, and they compromised widely used npm packages in the past.
  Use `npm audit`, and prefer packages from reliable sources.
- Transitive dependencies are also important.

## Review checklist for a diff

- [ ] Each write path validates before business logic.
- [ ] Each new route has an explicit authorization entry, with no accidental guest access.
- [ ] Object-level ownership is checked where a resource belongs to a user.
- [ ] CSRF is present and validated on each form (templated projects).
- [ ] Secrets are only in `*.local.php`.
- [ ] No key is in a commit.
- [ ] No interpolation into raw SQL or DQL, and all parameters are bound.
- [ ] Sort and filter values are whitelisted, and `limit` is clamped.
- [ ] Uploads are validated and stored outside executable paths.
- [ ] Errors are thrown as typed exceptions with no internal detail.
- [ ] No new dependency without approval.
- [ ] The pipeline order is the same, or the change has a reason.
