# OpenPLC: a race creates an administrator before login

**Last updated:** 2026-11-19 (America/New_York)

[Main OpenPLC summary](../black-october-2026.md#openplc-a-race-creates-an-administrator-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-19 CISA published [ICSA-26-323-01][icsa] for Autonomy Logic OpenPLC Runtime. CISA rates [CVE-2026-126088](https://www.cve.org/CVERecord?id=CVE-2026-126088) **CVSS 4.0 9.2 Critical** and **CVSS 3.1 8.1 High**. The 4.0 vector is `CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The 3.1 vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`. CISA is the CNA.

OpenPLC Runtime **4.2.4 and earlier** checks whether a user exists and then creates one. Two requests at the same time both pass the check, and the runtime creates administrator accounts with no login. The fix is **4.3.0 or later**. CISA says no known public exploitation has been reported to CISA. Critical manufacturing, energy, transportation, and water systems are the sectors CISA names.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-19). CISA's advisory is not a KEV listing. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-11-19; time/TZ unknown** | ICSA-26-323-01, initial release. Fixed in 4.3.0. [ICSA][icsa] |

## Detection

Read the runtime version from the host, not from a plan. **4.2.4 and earlier** are inside the flaw. 4.3.0 or later is the build CISA names.

An administrator account the owner did not create is the artifact the race leaves. Not seeing one does not show that the race did not run.

## Remediation

1. Update OpenPLC Runtime to **4.3.0 or later** and restart it.
2. Until the update, CISA says to keep the runtime off the internet and off the business network. That is not the fix.
3. The update does not remove an administrator account the race already created. Review the user list and delete one you cannot account for.

## Verification

- The running runtime is 4.3.0 or later.
- The program still scans. Do not send concurrent registration requests to test the race.

## Compromise response

CISA does not report exploitation. A runtime that was reachable before the update should be reviewed for an administrator account, a program, or a configuration change the owner did not make. The update does not undo one.

## Sources

- [ICSA-26-323-01][icsa] — CISA, released 2026-11-19. OpenPLC Runtime 4.2.4 and earlier. Fixed in 4.3.0. CVSS 4.0 9.2 and CVSS 3.1 8.1. No known exploitation reported to CISA.
- [CVE-2026-126088](https://www.cve.org/CVERecord?id=CVE-2026-126088) — the CVE record.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-19. Not listed.

[icsa]: https://www.cisa.gov/news-events/ics-advisories/icsa-26-323-01
