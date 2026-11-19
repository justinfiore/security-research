# SmarterMail: an application password is guessable

**Last updated:** 2026-11-19 (America/New_York)

[Main SmarterMail summary](../black-october-2026.md#smartermail-an-application-password-is-guessable) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

The Zero Day Initiative rates three flaws in SmarterTools SmarterMail at 7.0 or higher. ZDI is the CNA. All three are fixed in **Build 9735**, which SmarterTools released on August 27, 2026. ZDI's coordinated publication was November 13, 2026. A fourth, [CVE-2026-126968](https://www.cve.org/CVERecord?id=CVE-2026-126968), is 6.5 and does not change the upgrade.

| CVE | Score | Who | Result |
| --- | --- | --- | --- |
| [CVE-2026-126969](https://www.cve.org/CVERecord?id=CVE-2026-126969) | ZDI CVSS 3.0 **9.1 Critical**. `CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N` | No login. | Application passwords were generated with too little entropy, so an attacker can produce one and sign in. |
| [CVE-2026-126967](https://www.cve.org/CVERecord?id=CVE-2026-126967) | ZDI CVSS 3.0 **8.8 High**. | A signed-in user. | The file API takes a path and runs code as SYSTEM. |
| [CVE-2026-126966](https://www.cve.org/CVERecord?id=CVE-2026-126966) | ZDI CVSS 3.0 **8.8 High**. | A signed-in user. | `svcDomainAdmin.asmx` does not check authorization, and the user reaches functions that account should not have. |

ZDI does not publish an affected range. The CVE record for the 9.1 flaw names build **100.0.9693.29286** as affected and names no other build. Current builds are past 9735: Build 9817 is dated November 17, 2026, and its only security note is a separate mail-relay check. Do not downgrade to 9735.

Canada's Cyber Centre published AV26-1177 on November 18, 2026, and says SmarterMail before Build 9817 is affected. It does not name a CVE. ZDI's fixed build for these three is 9735.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-19) for any of the three. ZDI does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to the vendor | 2026-08-20; time/TZ unknown | ZDI's timeline, the same date on all three. |
| Build 9735 | 2026-08-27; time/TZ unknown | SmarterTools regenerated application passwords. [Release notes][notes] |
| **Public announcement** | **2026-11-13; time/TZ unknown** | ZDI-26-997, ZDI-26-995, and ZDI-26-994. [ZDI-26-997][zdi997] |
| CVE records | 2026-11-17; time unknown | The 9.1 record names build 100.0.9693.29286. |
| Canadian notice | 2026-11-18; time/TZ unknown | AV26-1177 says before Build 9817 and names no CVE. [AV26-1177][ccc] |

## Detection

The build number is in the SmarterMail web administration page. A build below 9735 is inside the range ZDI says it fixed. A build ZDI does not name is not proven unaffected by the CVE record, which lists one build and leaves the rest unknown.

## Remediation

1. Upgrade to a current build. **9817**, dated November 17, 2026, is the current installer. 9735 is the build ZDI names as the fix, and it is not the build to install now.
2. Build 9735 regenerated application passwords. Anyone using an application password created before that build has to enter a new one for a desktop or mobile client on an account that uses two-factor authentication. Keep two-factor authentication on.
3. ZDI publishes no workaround.

## Verification

- The administration page shows 9735 or a later build, and a current installer is 9817.
- A desktop client that used an old application password fails until it gets a new one. That failure is the password change, not an outage.

## Compromise response

ZDI does not report exploitation. An application password that signs in and that nobody created is the thing to look for, and finding none does not clear the server. The upgrade does not show whether a password was already guessed. Rotate the application passwords rather than reusing the values from before Build 9735.

## Sources

- [ZDI-26-997][zdi997] — November 13, 2026. CVE-2026-126969, CVSS 3.0 9.1. Fixed in Build 9735.
- [ZDI-26-994](https://www.zerodayinitiative.com/advisories/ZDI-26-994) — CVE-2026-126967, CVSS 3.0 8.8. File API, code execution as SYSTEM. Fixed in Build 9735.
- [ZDI-26-995](https://www.zerodayinitiative.com/advisories/ZDI-26-995) — CVE-2026-126966, CVSS 3.0 8.8. Fixed in Build 9735.
- [CVE-2026-126969](https://www.cve.org/CVERecord?id=CVE-2026-126969) — published 2026-11-17. Affected build 100.0.9693.29286.
- [SmarterMail release notes][notes] — Build 9735, August 27, 2026, regenerated application passwords. Build 9817, November 17, 2026.
- [Canadian Centre AV26-1177][ccc] — November 18, 2026. SmarterMail prior to Build 9817. No CVE named.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-19. None of the three is listed.

[zdi997]: https://www.zerodayinitiative.com/advisories/ZDI-26-997
[notes]: https://www.smartertools.com/smartermail/release-notes/current
[ccc]: https://www.cyber.gc.ca/en/alerts-advisories/smartertools-security-advisory-av26-1177
