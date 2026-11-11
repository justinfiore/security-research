# Zoom Workplace for Windows: a network request raises privileges

**Last updated:** 2026-11-11 (America/New_York)

[Main Zoom summary](../black-october-2026.md#zoom-workplace-for-windows-a-network-request-raises-privileges) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Zoom rates [CVE-2026-108186](https://www.cve.org/CVERecord?id=CVE-2026-108186) CVSS 3.1 9.6 Critical** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:H`). Improper input validation in Zoom Workplace for Windows lets a user who is not logged in raise privileges over the network. The person at the computer has to take an action. The bulletin, ZSB-26023, says versions starting at **7.1.0** and before **7.1.8** are affected. The CVE record says the same range, from 7.1 before 7.1.8.

The same day Zoom published [CVE-2026-108187](https://www.cve.org/CVERecord?id=CVE-2026-108187), CVSS 3.1 8.1 High (`CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:N`). An origin-validation error in the same product lets a user who is not logged in raise privileges over the network, and that one also needs a user action. ZSB-26024 says Zoom Workplace for Windows before **7.1.5** is affected. The CVE record says from 0 before 7.1.5. A build at 7.1.5 or 7.1.6 or 7.1.7 is outside the second flaw and still inside the first.

Zoom does not say what privilege the attacker reaches, and it does not name a workaround. Both bulletins say to install the latest update from the download page. Zoom Offensive Security reported the 9.6 flaw. The 8.1 flaw is credited to shmoul.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-11) for either CVE. The bulletins do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-11-10; time/TZ unknown** | ZSB-26023 and ZSB-26024, revision 1.0, dated 11/10/2026. Zoom gives no time. [ZSB-26023][zsb23] |
| CVE records | 2026-11-10; time unknown | Both published and updated that day. [CVE-2026-108186][cve186] |
| CISA KEV | Not listed (catalog 2026.11.10, checked 2026-11-11) | [KEV][kev] |
| **Last updated** | **2026-11-11 (America/New_York)** | New item. |

## Detection

This only reads the installed version.

On Windows, open Zoom, then the profile picture, then **Help**, then **About Zoom**. The About window prints the client version. A Workplace for Windows build from **7.1.0** through **7.1.7** is inside CVE-2026-108186. A build below **7.1.5** is also inside CVE-2026-108187. A build at **7.1.8** or later is outside both ranges the bulletins name.

The bulletins name Zoom Workplace for Windows only. They do not say the macOS, Linux, mobile, or VDI clients are affected. A version string from one of those clients does not answer this item.

Do not send a request to the client to test either flaw.

## Remediation

1. Update Zoom Workplace for Windows to **7.1.8 or later**. That build is the first one outside both ranges. Install it from [Zoom's download page](https://zoom.us/download), or from the update the client offers, then relaunch it.
2. A build at 7.1.5, 7.1.6, or 7.1.7 is outside CVE-2026-108187 and is still inside CVE-2026-108186. Do not stop at 7.1.5.
3. Zoom lists no workaround. The update does not show whether a request already raised privileges.

## Verification

- Help, About Zoom reports **7.1.8** or later, and that window is the client that is running.
- A meeting you already use still connects. Do not send a crafted request.

## Compromise response

Zoom's bulletins do not publish an indicator. If a Windows client below 7.1.8 was running while it could receive network requests, treat a privilege change as possible.

- Preserve the client logs from before the update.
- Review new local administrator accounts and new services created while that build was installed.
- If you find evidence a command ran as a higher privilege, rebuild the PC and rotate credentials that account could read. The update does not remove that.

## Sources

- [ZSB-26023][zsb23] — Zoom, revision 1.0 dated 11/10/2026. CVE-2026-108186, CVSS 3.1 9.6 Critical. Workplace for Windows from 7.1.0 before 7.1.8. Reported by Zoom Offensive Security.
- [ZSB-26024][zsb24] — Zoom, revision 1.0 dated 11/10/2026. CVE-2026-108187, CVSS 3.1 8.1 High. Workplace for Windows before 7.1.5. Reported by shmoul.
- [CVE-2026-108186][cve186] — Zoom CNA, published 2026-11-10. Same score. Affected from 7.1 before 7.1.8.
- [CVE-2026-108187][cve187] — Zoom CNA, published 2026-11-10. Same score. Affected from 0 before 7.1.5.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-11. Neither CVE is listed.

[zsb23]: https://www.zoom.com/en/trust/security-bulletin/zsb-26023
[zsb24]: https://www.zoom.com/en/trust/security-bulletin/zsb-26024
[cve186]: https://www.cve.org/CVERecord?id=CVE-2026-108186
[cve187]: https://www.cve.org/CVERecord?id=CVE-2026-108187
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
