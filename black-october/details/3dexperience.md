# 3DEXPERIENCE: the Station Launcher runs a command

**Last updated:** 2026-11-16 (America/New_York)

[Main 3DEXPERIENCE summary](../black-october-2026.md#3dexperience-the-station-launcher-runs-a-command) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

The Station Launcher App in Dassault Systèmes 3DEXPERIENCE has three flaws, published the same day, over the same four release ranges. Dassault Systèmes is the CNA.

[CVE-2026-93664](https://www.cve.org/CVERecord?id=CVE-2026-93664) is deserialization of untrusted data. Dassault rates it **CVSS 3.1 10.0 Critical**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`. Dassault says it can lead to unauthenticated remote code execution. The record does not name the request.

[CVE-2026-77033](https://www.cve.org/CVERecord?id=CVE-2026-77033) and [CVE-2026-19732](https://www.cve.org/CVERecord?id=CVE-2026-19732) are OS command injection. Dassault rates each **CVSS 3.1 9.9 Critical**. The vector on both is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`. A logged-in attacker can run commands on the server. The records do not name the request, the parameter, or how the two differ.

All three list the same ranges: R2023x Golden through R2023x.FP.CFA.2613, R2024x Golden through R2024x.FP.CFA.2632, R2025x Golden through R2025x.FP.CFA.2637, and R2026x Golden through R2026x.FP.CFA.2635. None names a fixed release. Dassault's public advisory pages repeat the range as "R2023x through R2026x" and link remediation to support articles that require a Dassault login. Those articles were not read. The command-injection pages both point at QA00000522688. The deserialization page was blocked by Dassault's edge on the read.

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
| **Public announcement** | **2026-11-16; NVD published 13:17 UTC** | Dassault published both CVE records and both advisory pages. The advisory pages show the date and no time. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. No fixed release is named in a public source. |

## Detection

Read the installed 3DEXPERIENCE release and fix pack from the platform's own about page, and compare it with the four ranges above. A release inside any of those ranges is affected. A release newer than the named ceiling on that line is not named as fixed, because Dassault has not published the fixed level outside the support article.

The flaw is in the Station Launcher App. The records do not say whether a platform that has never enabled that app is safe, so do not treat a disabled app as a fix unless the support article says so.

## Remediation

1. Take the fixed level from Dassault support article QA00000522688 and install it. The public records do not name it.
2. Until that level is installed, restrict the Station Launcher to the accounts that need it. Dassault publishes no workaround.
3. The update does not show whether a command already ran.

## Verification

The installed release is newer than the affected ceiling Dassault names for that line, and the support article lists that build. Do not send the request the records describe. They do not name it.

## Compromise response

No source reports exploitation. If the Station Launcher was reachable by accounts you do not trust, review the server for commands and new accounts created on or after November 16. A new account is a lead, not proof.

## Sources

- [CVE-2026-93664](https://www.cve.org/CVERecord?id=CVE-2026-93664) — Dassault Systèmes, published 2026-11-16. CVSS 3.1 10.0. Unauthenticated. Same four ranges, no fixed release named.
- [CVE-2026-77033](https://www.cve.org/CVERecord?id=CVE-2026-77033) — Dassault Systèmes, published 2026-11-16. CVSS 3.1 9.9. Four affected ranges, no fixed release named.
- [CVE-2026-19732](https://www.cve.org/CVERecord?id=CVE-2026-19732) — Dassault Systèmes, published 2026-11-16. Same score, same ranges, same description.
- [Dassault advisory, CVE-2026-77033](https://www.3ds.com/trust-center/security/security-advisories/cve-2026-77033) — published 2026-11-16. Remediation link points at support article QA00000522688.
- [Dassault advisory, CVE-2026-19732](https://www.3ds.com/trust-center/security/security-advisories/cve-2026-19732) — published 2026-11-16. Same remediation link.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. Neither CVE is in it.
