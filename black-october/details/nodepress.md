# NodePress: the default password and the default signing key are administrator

**Last updated:** 2026-11-16 (America/New_York)

[Main NodePress summary](../black-october-2026.md#nodepress-the-default-password-and-the-default-signing-key-are-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

NodePress is a Node.js blog API by surmon-china. Two flaws through **8.5.1** are rated Critical by VulnCheck, the CNA. The finder, Ikram-4, reported both in [GitHub issue 143](https://github.com/surmon-china/nodepress/issues/143) on November 16, and the issue is open with no maintainer reply.

[CVE-2026-129955](https://www.cve.org/CVERecord?id=CVE-2026-129955) is the administrator password. When `NP_ADMIN_DEFAULT_PASSWORD` is unset, the password is the hard-coded value `root`. A request with no login sends that value, base64-encoded, to `POST /admin/login` and gets an administrator token. VulnCheck rates it **CVSS 4.0 9.3 Critical** and **CVSS 3.1 9.8 Critical**. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`.

[CVE-2026-129952](https://www.cve.org/CVERecord?id=CVE-2026-129952) is the signing key. The JWT fallback is the hard-coded value `nodepress-secret`. Anyone can sign an HS256 token with the default issuer, audience, and role `admin`, and the administrator APIs accept it. VulnCheck rates it the same **9.3 and 9.8**. A deployment that sets both `NP_ADMIN_DEFAULT_PASSWORD` and the JWT secret does not use either fallback. The records do not name the variable for the JWT secret.

npm's `nodepress` package latest is 2.1.0-beta from 2020, which is not this application. The affected tree is the GitHub repository, and VulnCheck says 8.5.1 is the top of the affected range. No release newer than 8.5.1 was named by the record or the issue.

This is not [Prime](prime-cms.md).

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
| GitHub issue 143 opened | 2026-11-16; time/TZ unknown | Ikram-4. No maintainer reply. [Issue 143][issue] |
| **Public announcement** | **2026-11-16; NVD published 15:17 UTC** | VulnCheck published both CVE records. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. No fixed release. |

## Detection

Read the version the deployment runs. The record covers everything through 8.5.1, and 8.5.1 is the newest version the finder names. Then read the process environment: `NP_ADMIN_DEFAULT_PASSWORD` unset means the password is `root`. The record does not name the JWT variable, so a set password does not by itself clear the signing-key flaw.

## Remediation

No fixed release exists.

1. Take a public NodePress through 8.5.1 offline.
2. Set `NP_ADMIN_DEFAULT_PASSWORD` and replace the JWT signing secret with a long random value. That retires both fallbacks and signs out tokens forged with `nodepress-secret`. It is not a release, and the finder says the code still falls back when the variables are unset.
3. Watch issue 143 for a release that names both CVEs before putting it back.

## Verification

There is no patched version to confirm. Confirm the service is not reachable, and confirm both secrets are set in the environment the process runs with. Do not log in with `root` or forge a token to test it.

## Compromise response

No source reports exploitation. If the service was reachable with either fallback in use, treat every administrator session as untrusted: rotate both secrets, review articles, comments, options, and uploaded files changed on or after November 16, and rotate credentials the application stored. Changing the secrets does not undo a change that was already written.

## Sources

- [CVE-2026-129955](https://www.cve.org/CVERecord?id=CVE-2026-129955) — VulnCheck, published 2026-11-16. CVSS 4.0 9.3 and CVSS 3.1 9.8. Default password `root` through 8.5.1.
- [CVE-2026-129952](https://www.cve.org/CVERecord?id=CVE-2026-129952) — VulnCheck, published 2026-11-16. Same scores. Fallback signing key `nodepress-secret` through 8.5.1.
- [GitHub issue 143][issue] — opened 2026-11-16 by Ikram-4. Still open.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. Neither CVE is in it.

[issue]: https://github.com/surmon-china/nodepress/issues/143
