# Prime: anyone can register an administrator

**Last updated:** 2026-11-16 (America/New_York)

[Main Prime summary](../black-october-2026.md#prime-anyone-can-register-an-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Prime is a GraphQL CMS, package `@primecms/core`, by birkir. [CVE-2026-129941](https://www.cve.org/CVERecord?id=CVE-2026-129941): the `createUser` mutation on `/prime/graphql` has no working login check. VulnCheck says the body of `isAuthenticated()` is commented out, and `createAbility()` hard-codes every role to admin, so a request with no login registers an account and that account is an administrator over content, users, webhooks, and settings. VulnCheck is the CNA and rates it **CVSS 4.0 9.3 Critical** and **CVSS 3.1 9.8 Critical**. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`.

Affected: every release through **0.4.0-beta.0**. The finder, Ikram-4, opened [GitHub issue 549](https://github.com/birkir/prime/issues/549) on November 16. It is open and has no maintainer reply. npm reports `@primecms/core` **0.3.4-beta.3** as the latest publish, from 2020-09-22, which is inside the affected range. No release fixes it.

A second flaw in the same report, [CVE-2026-129943](https://www.cve.org/CVERecord?id=CVE-2026-129943), is command injection in the `updateSystem` mutation. VulnCheck rates it **CVSS 4.0 8.6 High** and **CVSS 3.1 7.2 High**. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:H`, so it needs high privileges: the account the first flaw creates. The same range applies and there is no fix.

This is not [NodePress](nodepress.md).

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
| `@primecms/core` 0.3.4-beta.3 | 2020-09-22 14:01:43 UTC | Latest npm publish. Inside the affected range. [npm][npm] |
| GitHub issue 549 opened | 2026-11-16; time/TZ unknown | Ikram-4. No maintainer reply. [Issue 549][issue] |
| **Public announcement** | **2026-11-16; NVD published 15:17 UTC** | VulnCheck published both CVE records. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. No fixed release. |

## Detection

```sh
npm ls @primecms/core --all
```

Any published version is inside the affected range. The record gives no lower bound and no fixed release.

## Remediation

No fixed release exists. Take a public Prime deployment offline. Do not leave `/prime/graphql` reachable: that is the route the record names. Watch issue 549 for a release that names CVE-2026-129941 before putting it back.

## Verification

There is no patched version to confirm. Confirm the service is not reachable. Do not call `createUser` to test it.

## Compromise response

No source reports exploitation. If the service was reachable, review users created on or after November 16 and treat every one of them as an administrator until you can show otherwise. Remove the accounts you do not recognize, and rotate credentials and webhook secrets the application stored. Taking it offline does not remove an account already created.

## Sources

- [CVE-2026-129941](https://www.cve.org/CVERecord?id=CVE-2026-129941) — VulnCheck, published 2026-11-16. CVSS 4.0 9.3 and CVSS 3.1 9.8. `@primecms/core` through 0.4.0-beta.0.
- [CVE-2026-129943](https://www.cve.org/CVERecord?id=CVE-2026-129943) — VulnCheck, published and updated 2026-11-16. CVSS 4.0 8.6 and CVSS 3.1 7.2. Command injection in `updateSystem`, same range. The 3.1 vector requires high privileges.
- [GitHub issue 549][issue] — opened 2026-11-16 by Ikram-4. Still open.
- [npm, `@primecms/core`][npm] — latest 0.3.4-beta.3, published 2020-09-22.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. Neither CVE is in it.

[issue]: https://github.com/birkir/prime/issues/549
[npm]: https://www.npmjs.com/package/@primecms/core
