# ZoneAlarm: a local user becomes SYSTEM

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#zonealarm-a-local-user-becomes-system) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-23 Check Point published [sk1000415](https://support.checkpoint.com/results/sk/sk1000415) for the ZoneAlarm client for Windows. Check Point rates [CVE-2026-132856](https://www.cve.org/CVERecord?id=CVE-2026-132856) **High, CVSS 3.1 7.8**. The vector is `CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. Check Point is the CNA. NVD has not scored it.

A person who can already run code on the computer as a local user can run code as `SYSTEM`. Check Point says the quarantine restore function does not correctly validate directory junctions, and the internal service does not correctly verify the signatures of programs that connect to it. The person has to be on the computer first. A remote request is not this flaw.

**ZoneAlarm before 4.4.217.20710** is affected. **4.4.217.20710** is the fix. The article was created 2026-11-22 and last modified 2026-11-23. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.23, checked 2026-11-23). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Article created | 2026-11-22; time/TZ unknown | sk1000415. [Article][sk] |
| **Public announcement** | **2026-11-23; time/TZ unknown** | CVE record published. CVSS 3.1 7.8. The article's last modified date is the same day. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-132856) |

## Detection

Read the ZoneAlarm client version on the Windows computer. **Anything lower than 4.4.217.20710** is inside the range Check Point names. A computer without the ZoneAlarm client is outside it. Reading the version changes no state.

## Remediation

1. Update the ZoneAlarm client to **4.4.217.20710 or later**.
2. The update does not show whether a local user already ran code as `SYSTEM`.

## Verification

- The installed ZoneAlarm client is **4.4.217.20710 or later**.
- Do not plant a directory junction to test the restore function.

## Compromise response

No source read for this entry reports an incident. If a low-privileged account on the computer was not trusted before the update, review what that account could start. The update does not undo a process that already ran as `SYSTEM`.

## Sources

- [sk1000415][sk] — Check Point, created 2026-11-22, last modified 2026-11-23. CVSS 3.1 7.8. Affected below 4.4.217.20710. Fixed in 4.4.217.20710 and higher.
- [CVE-2026-132856](https://www.cve.org/CVERecord?id=CVE-2026-132856) — Check Point Software Ltd., published 2026-11-23. CVSS 3.1 7.8. CWE-59 and CWE-347.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T12:54:37.9646Z, checked 2026-11-23. Not listed.

[sk]: https://support.checkpoint.com/results/sk/sk1000415
