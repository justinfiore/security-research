# SurrealDB: a script skips the function check

**Last updated:** 2026-11-22 (America/New_York)

[Main plugin summary](../black-october-2026.md#surrealdb-a-script-skips-the-function-check) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-21 VulnCheck published [CVE-2026-134292](https://www.cve.org/CVERecord?id=CVE-2026-134292) for SurrealDB. VulnCheck is the CNA and rates it **CVSS 4.0 9.3 Critical** and **CVSS 3.1 9.8 Critical**. The CVSS 4.0 vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The CVSS 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Both vectors say no privileges are required. The description says the caller is authenticated and has been denied the function in SurrealQL. NVD has not scored it.

The embedded JavaScript engine's `surrealdb.functions` bridge calls the internal function dispatchers directly, so it never runs the capability check that SurrealQL runs. A user who was denied a built-in function can still call it from a script. GitHub's advisory [GHSA-5w6j-qm42-4rc2][ghsa], published 2026-11-03 by a SurrealDB maintainer, rates the same issue **High** and names no CVE. The two scores disagree, and both stay visible.

Every version from **1.0.0 before 4.0.0** is affected. **4.0.0** is the fix, commit `0b8be14543`. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-22). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| GitHub advisory | 2026-11-03; time/TZ unknown | GHSA-5w6j-qm42-4rc2, rated High. No CVE on that page. [GHSA][ghsa] |
| **Public announcement** | **2026-11-21 16:35:13 UTC** | VulnCheck published the CVE record. CVSS 4.0 9.3 and CVSS 3.1 9.8. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-134292) |

## Detection

Read the running SurrealDB version. **1.0.0 through anything before 4.0.0** is inside the range the record names. A server that does not allow embedded JavaScript is outside the path the advisory describes; the record does not say the version is unaffected. Reading the version changes no state.

## Remediation

1. Upgrade to **4.0.0 or later** and restart the server.
2. The upgrade does not show whether a script already called a function it was denied.

## Verification

- `surreal version` reports **4.0.0 or later**.
- Do not run a script that calls a denied function to test it.

## Compromise response

No source read for this entry reports an incident. The upgrade does not undo a statement a script already ran. Review changes made by accounts that were supposed to be denied those functions.

## Sources

- [CVE-2026-134292](https://www.cve.org/CVERecord?id=CVE-2026-134292) — VulnCheck, published 2026-11-21T16:35:13.610Z. CVSS 4.0 9.3 and CVSS 3.1 9.8. Affected from 1.0.0 before 4.0.0.
- [GHSA-5w6j-qm42-4rc2][ghsa] — published 2026-11-03, rated High. Patched in 4.0.0, commit `0b8be14543`. Names no CVE.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-22. Not listed.

[ghsa]: https://github.com/surrealdb/surrealdb/security/advisories/GHSA-5w6j-qm42-4rc2
