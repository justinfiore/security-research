# Tensei: a missing secret signs in as any user

**Last updated:** 2026-11-16 (America/New_York)

[Main Tensei summary](../black-october-2026.md#tensei-a-missing-secret-signs-in-as-any-user) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Tensei is a Node.js CMS kit published as the `@tensei/*` packages. Two flaws in `@tensei/auth` through **0.11.5** are rated Critical by VulnCheck, the CNA.

[CVE-2026-129552](https://www.cve.org/CVERecord?id=CVE-2026-129552) is an authentication bypass. VulnCheck rates it **CVSS 4.0 9.3 Critical** and **CVSS 3.1 9.8 Critical**. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. When `JWT_SECRET` is unset, the package signs tokens with the hard-coded key `auth-secret-key`. Anyone can sign a token for any user id, including an administrator. A deployment that sets `JWT_SECRET` does not use that fallback.

[CVE-2026-129550](https://www.cve.org/CVERecord?id=CVE-2026-129550) is a privilege escalation. VulnCheck rates it **CVSS 4.0 9.3 Critical** and **CVSS 3.1 9.1 Critical**. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. The User Roles field is exposed, so a registration, a POST to the users route, or a PATCH of the caller's own record can carry a roles array and grant administrator. The record says this works unauthenticated or authenticated.

The finder, Ikram-4, opened [GitHub issue 398](https://github.com/tenseijs/tensei/issues/398) on November 15 and reported six issues, including these two. The issue is still open and has no maintainer reply. npm reports `@tensei/auth` **0.11.5** as the latest release, published 2022-01-06, and the package was last modified 2022-04-07. No release fixes either flaw.

The same issue describes four more problems that have no CVE and no vendor score: unauthenticated file upload, a CSRF check that swallows an invalid token, operator injection in filters, and an open redirect in social login. Those are noted here and are not scored High or Critical by a CNA.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-16). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| `@tensei/auth` 0.11.5 | 2022-01-06 09:46:48 UTC | The current release, and the top of both affected ranges. [npm][npm] |
| GitHub issue 398 opened | 2026-11-15; time/TZ unknown | Six issues, no exploit steps. No maintainer reply. [Issue 398][issue] |
| **Public announcement** | **2026-11-16; NVD published 12:17 UTC** | VulnCheck published both CVE records. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. No fixed release. |

## Detection

In the application directory:

```sh
npm ls @tensei/auth --all
```

A tree that contains `@tensei/auth` at 0.11.5 or earlier is affected. Also check whether the process environment sets `JWT_SECRET`. Unset means the hard-coded key is in use. Set means CVE-2026-129552's fallback is not the one serving tokens; CVE-2026-129550 does not depend on that variable.

## Remediation

No fixed release exists. 0.11.5 is the newest npm release, and it is inside both affected ranges.

1. Do not expose a Tensei deployment that is still on 0.11.5. Take it off the internet.
2. Set `JWT_SECRET` to a long random value even though you are taking it offline. That retires the hard-coded key and signs out tokens forged with it. It does not fix the role assignment.
3. Watch issue 398 for a release that names both CVEs before putting the service back.

## Verification

There is no patched version to confirm. Confirm the service is not reachable, and confirm `JWT_SECRET` is set in the environment the process actually runs with. Do not forge a token to test it.

## Compromise response

No source reports exploitation. If the service was reachable with `JWT_SECRET` unset, treat every session as untrusted: rotate `JWT_SECRET`, review administrator roles added on or after November 15, and rotate credentials the application stored. A new administrator is a lead, not proof. Changing the secret does not remove a role that was already written.

## Sources

- [CVE-2026-129552](https://www.cve.org/CVERecord?id=CVE-2026-129552) — VulnCheck, published 2026-11-16. CVSS 4.0 9.3 and CVSS 3.1 9.8. `@tensei/auth` through 0.11.5. Fallback key `auth-secret-key`.
- [CVE-2026-129550](https://www.cve.org/CVERecord?id=CVE-2026-129550) — VulnCheck, published 2026-11-16. CVSS 4.0 9.3 and CVSS 3.1 9.1. Roles accepted on registration, POST, and PATCH.
- [VulnCheck advisory, CVE-2026-129552](https://www.vulncheck.com/advisories/tensei-through-0.11.5-authentication-bypass-via-hard-coded-jwt-secret-in-tensei-auth) — dated 2026-11-16. Credit Ikram-4.
- [GitHub issue 398][issue] — opened 2026-11-15 by Ikram-4. Still open. Names the fallback at `packages/auth/src/index.ts`.
- [npm, `@tensei/auth`][npm] — latest 0.11.5, published 2022-01-06, package last modified 2022-04-07.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. Neither CVE is in it.

[issue]: https://github.com/tenseijs/tensei/issues/398
[npm]: https://www.npmjs.com/package/@tensei/auth
