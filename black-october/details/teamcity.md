# TeamCity: a signed-in user runs code on the server

**Last updated:** 2026-11-19 (America/New_York)

[Main TeamCity summary](../black-october-2026.md#teamcity-a-signed-in-user-runs-code-on-the-server) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

JetBrains published a new set of TeamCity On-Premises fixes on November 18, 2026. The fixes are in **2026.1.3** and **2025.11.7**. JetBrains is the CNA. This is not the unauthenticated flaw from July, [CVE-2026-63077](https://www.cve.org/CVERecord?id=CVE-2026-63077), which those same two builds already fixed. TeamCity Cloud is JetBrains' to patch.

| CVE | Score | Fixed in | What a signed-in user can do |
| --- | --- | --- | --- |
| [CVE-2026-132234](https://www.cve.org/CVERecord?id=CVE-2026-132234) | CVSS 3.1 **9.9 Critical**. `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H` | 2026.1.3 and 2025.11.7 | Argument injection in a Mercurial VCS root runs code on the server. |
| [CVE-2026-132237](https://www.cve.org/CVERecord?id=CVE-2026-132237) | 8.8 High | both | A path through the external artifact cache runs code. |
| [CVE-2026-132238](https://www.cve.org/CVERecord?id=CVE-2026-132238) | 7.7 High | 2026.1.3 and **2025.11.8** | A project viewer can read password parameter values. 2025.11.7 does not fix this one. |
| [CVE-2026-132240](https://www.cve.org/CVERecord?id=CVE-2026-132240) | 7.7 High | both | A Maven settings upload is parsed as XML with external entities. |
| [CVE-2026-132239](https://www.cve.org/CVERecord?id=CVE-2026-132239) | 7.6 High | both | A project viewer can use credentials stored for the Kubernetes integration. |
| [CVE-2026-132242](https://www.cve.org/CVERecord?id=CVE-2026-132242) and [CVE-2026-132243](https://www.cve.org/CVERecord?id=CVE-2026-132243) | 7.6 High | both | Stored script, in the Promote build dialog and on the Docker Container Info tab. |
| [CVE-2026-132244](https://www.cve.org/CVERecord?id=CVE-2026-132244) | 8.1 High | both | Stored script on the Disk Usage and Build Time pages. |
| [CVE-2026-132245](https://www.cve.org/CVERecord?id=CVE-2026-132245) | 7.5 High | both | An agent command result can stop the server answering. |

The records were published 2026-11-18. Several more from the same publication are below 7.0, including privilege escalation through a restricted token at 3.1, and they do not change the upgrade. NVD has not scored them separately from the CNA.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-19) for any CVE in this table. JetBrains does not report exploitation of this set. CVE-2026-63077 is a different record and is not in this table. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-18; time unknown** | The CVE records. Fixed before 2026.1.3 and 2025.11.7. [CVE-2026-132234][cve] |
| Canadian notice | 2026-11-18; time/TZ unknown | AV26-1176 names 2025.11.7 and 2026.1.3 and does not name a CVE. [AV26-1176][ccc] |

## Detection

The build is on the server's Administration page. A 2026.1 build before 2026.1.3, or a 2025.11 build before 2025.11.7, is inside the 9.9 flaw. A 2025.11 build that stops at 2025.11.7 is still inside CVE-2026-132238, which needs 2025.11.8.

## Remediation

1. Upgrade TeamCity On-Premises to **2026.1.3 or later**. On the 2025.11 line, upgrade to **2025.11.8 or later** so the password-parameter flaw is included. 2025.11.7 fixes the 9.9 flaw and leaves that one.
2. TeamCity Cloud needs nothing from you.
3. JetBrains publishes no workaround for this set.

## Verification

- The Administration page shows 2026.1.3 or later, or 2025.11.8 or later.
- A project still builds. Do not send a Mercurial root built to inject an argument.

## Compromise response

JetBrains does not report exploitation. A VCS root or an artifact-cache setting that nobody added is a lead, and finding none does not clear the server. The upgrade does not show whether a request already ran code.

## Sources

- [CVE-2026-132234][cve] — JetBrains, published 2026-11-18. CVSS 3.1 9.9. Fixed before 2026.1.3 and 2025.11.7.
- [JetBrains, fixed security issues](https://www.jetbrains.com/privacy-security/issues-fixed/) — the vendor's list of resolved issues and versions.
- [Canadian Centre AV26-1176][ccc] — November 18, 2026. TeamCity before 2025.11.7 and before 2026.1.3.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-19. None of this set is listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-132234
[ccc]: https://www.cyber.gc.ca/en/alerts-advisories/jetbrains-security-advisory-av26-1176
