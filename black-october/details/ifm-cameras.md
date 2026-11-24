# ifm cameras: a request with no login installs firmware

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#ifm-cameras-a-request-with-no-login-installs-firmware) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-23 CERT@VDE published VDE-2026-148 for ifm 3D cameras. ifm electronic is the vendor. The advisory names one CVE.

**The advisory rates [CVE-2026-121613](https://www.cve.org/CVERecord?id=CVE-2026-121613) CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. An exposed interface does not check who is calling. A remote attacker who is not logged in can send commands to the camera, force a reboot, or upload firmware. The advisory says that can disrupt the camera, change what it does, or install malicious firmware.

The affected firmware is named per model, not as one range. O3D300, O3D302, O3D304, O3D310, O3D312, O3D314, and O3D354 include firmware **1.90.119**. O3D301, O3D303, O3D305, O3D311, O3D353, and O3D355 include **1.90.107**. Several of those also include **1.71.10735**. O3D361 is **1.20.6381**. O3DP01, O3DP03, O3DP21, and O3DP23 are **2.10.16**. O3X120 and O3X130 are **2.0.10412**.

**The advisory's remediation line is "No Remediation available."** There is no firmware to install. No source read for this entry reports exploitation.

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
| **Public announcement** | **2026-11-23 10:00** | VDE-2026-148, revision 1.0.0. The page does not name a timezone. CVE published 11/23/2026 10:02 on the same page. [Advisory][vde] |

## Detection

Read the model and the firmware version on the camera. A model and firmware pair in the advisory's table is inside the range. A camera that is not one of those models is outside it. Reading the version changes no state.

## Remediation

1. There is no firmware fix. Keep the camera's management interface off networks you do not trust.
2. Putting it behind a firewall does not close the missing authentication. It only limits who can reach it.
3. When ifm publishes a firmware, install that build. Nothing in this advisory names one.

## Verification

- The camera's management interface is not reachable from a network you do not trust.
- Do not upload a firmware image to test the missing check.

## Compromise response

No source read for this entry reports an incident. If the interface was reachable before you restricted it, treat the firmware as untrusted: the advisory says an upload can replace it. Restricting the network does not restore firmware that was already replaced.

## Sources

- [VDE-2026-148][vde] — CERT@VDE, published 2026-11-23 10:00, revision 1.0.0. CVE-2026-121613, CVSS 3.1 9.8. Remediation: none.
- [CVE-2026-121613](https://www.cve.org/CVERecord?id=CVE-2026-121613) — referenced by the advisory. CWE-306.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T19:43:55.7979Z, checked 2026-11-23. Not listed.

[vde]: https://certvde.com/en/advisories/VDE-2026-148
