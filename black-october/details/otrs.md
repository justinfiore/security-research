# OTRS: a survey link reads the database

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#otrs-a-survey-link-reads-the-database) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-23 EasyVista-OTRS published [OSA-2026-19][osa] for [CVE-2026-93584](https://www.cve.org/CVERecord?id=CVE-2026-93584). OTRS is the CNA. The advisory rates it **CVSS 3.1 8.6 High** and **CVSS 4.0 8.7 High**. The CVE record carries only the CVSS 3.1 score. The CVSS 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:N/A:N`. The CVSS 4.0 vector on the advisory is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N/AU:Y/R:A/RE:M/U:Red`. NVD has not scored it.

The Survey add-on's `Kernel::System::Survey::Request::RequestGet()` puts the survey key from the request straight into an SQL statement. A request with no login, no valid key, and no existing survey request can read ticket data and run a blind SQL injection against whatever the OTRS database account can read. The external frontend has to be reachable. The advisory does not say the injection writes or deletes.

**2024.3.1**, the **2025.x** line, and **2026.x before 2026.8.2** are affected. **2026.8.2** is the fix. The advisory names the commercial OTRS product and does not mention ((OTRS)) Community Edition, so this entry does not claim that edition is affected or unaffected. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-23). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-23; time/TZ unknown** | OSA-2026-19. CVSS 3.1 8.6 and CVSS 4.0 8.7. Fixed in 2026.8.2. [Advisory][osa] |

## Detection

Read the OTRS version from the package or the installer screen. **2024.3.1**, any **2025** release, and **2026 before 2026.8.2** are inside the range the advisory names. The path needs the Survey endpoint on a reachable external frontend. Reading the version changes no state.

## Remediation

1. Upgrade to **OTRS 2026.8.2 or later**.
2. Until then, keep the external frontend off untrusted networks. That is a mitigation, not the fix.
3. The upgrade does not show whether a survey request already read ticket data.

## Verification

- The installed version is **2026.8.2 or later**.
- Do not send a survey key to test it.

## Compromise response

No source read for this entry reports an incident. The database account can read tickets, so review access to ticket data from the period a version inside the range was reachable. The upgrade does not undo a query that already ran.

## Sources

- [OSA-2026-19][osa] — EasyVista-OTRS, dated 2026-11-23. CVSS 3.1 8.6 and CVSS 4.0 8.7. Fixed in 2026.8.2. Affected 2024.3.1, 2025.x, and 2026.x before 2026.8.2.
- [CVE-2026-93584](https://www.cve.org/CVERecord?id=CVE-2026-93584) — EasyVista-OTRS, published 2026-11-23. CVSS 3.1 8.6 only. The record repeats the affected range.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-23. Not listed.

[osa]: https://otrs.com/release-notes/otrs-security-advisory-2026-19/
