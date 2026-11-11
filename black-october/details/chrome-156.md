# Google Chrome 156: Critical browser memory-safety fixes

**Last updated:** 2026-11-10 (America/New_York)

[Main summary](../black-october-2026.md#google-chrome-critical-browser-security-fixes) · [Main TOC](../black-october-2026.md#table-of-contents)

**CVEs:** [CVE-2026-118306](https://www.cve.org/CVERecord?id=CVE-2026-118306), [CVE-2026-118331](https://www.cve.org/CVERecord?id=CVE-2026-118331), [CVE-2026-118344](https://www.cve.org/CVERecord?id=CVE-2026-118344), [CVE-2026-118348](https://www.cve.org/CVERecord?id=CVE-2026-118348), [CVE-2026-76024](https://www.cve.org/CVERecord?id=CVE-2026-76024). Google identifies the first four as Critical in the October 27 Chrome 156 release, and [CVE-2026-76024](https://www.cve.org/CVERecord?id=CVE-2026-76024) as Critical (memory corruption in MediaStream) in the October 29 release. Google's notices restrict technical details while users update. The CVE record has no CNA numeric score; CISA's enrichment scores it CVSS 3.1 6.5 Medium, which is not Google's rating.

On 2026-11-03 Google promoted Chrome 157. The Linux build is **157.0.8103.38**. Windows and Mac are **157.0.8103.38/.39**. Google says the update includes 213 security fixes and restricts bug details until most users have it. Seven are rated Critical: [CVE-2026-121156](https://www.cve.org/CVERecord?id=CVE-2026-121156) (buffer overflow in Dawn), [CVE-2026-121229](https://www.cve.org/CVERecord?id=CVE-2026-121229) (memory corruption in ANGLE), [CVE-2026-121246](https://www.cve.org/CVERecord?id=CVE-2026-121246) (use after free in WebGL), [CVE-2026-121035](https://www.cve.org/CVERecord?id=CVE-2026-121035) (use after free in Prerender), [CVE-2026-121247](https://www.cve.org/CVERecord?id=CVE-2026-121247) (buffer overflow in Dawn), [CVE-2026-121203](https://www.cve.org/CVERecord?id=CVE-2026-121203) (use after free in Geometry), and [CVE-2026-121126](https://www.cve.org/CVERecord?id=CVE-2026-121126) (use after free in Core). A Chrome 156 build, including 156.0.8078.79/.80, does not contain these fixes.

On 2026-11-09 Google updated the Stable channel again. Windows and Mac are **157.0.8103.50/.51** and Linux is **157.0.8103.50**. The post lists nine security fixes, seven of them High and none Critical. [CVE-2026-125350](https://www.cve.org/CVERecord?id=CVE-2026-125350) is High, a use after free in XML, reported by an anonymous researcher on 2026-11-06. Google writes: "Google is aware that an exploit for CVE-2026-125350 exists in the wild." The same post lists six more High fixes and two Medium fixes, and it does not report exploitation for those. A Chrome 157 build from November 3, 157.0.8103.38/.39, does not contain these nine fixes. The same day's Extended Stable update for Windows and Mac, **156.0.8078.96**, lists CVE-2026-125350 among eleven fixes. Google does not publish a numeric CVSS score for any of them.

**CISA KEV:** Listed — [CVE-2026-125350](https://www.cve.org/CVERecord?id=CVE-2026-125350) added 2026-11-10, federal due date 2026-11-24. Ransomware use Unknown. The feed says a crafted page can run code inside the sandbox. The Chrome 156 CVEs and the seven Chrome 157 Critical CVEs from November 3 are not listed (catalog 2026.11.10, checked 2026-11-10). CISA-ADP scores CVE-2026-125350 CVSS 3.1 8.8 High, which is not Google's rating. Google publishes no numeric score. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Stable release announcement | 2026-10-27; time/TZ unknown | Google announced Chrome 156.0.8078.73 for Linux and 156.0.8078.73/.74 for Windows and macOS. |
| Later Stable and Extended Stable release | 2026-10-29; time/TZ unknown | Google announced 156.0.8078.79/.80 for Windows and Mac and 156.0.8078.79 for Linux, including Critical [CVE-2026-76024](https://www.cve.org/CVERecord?id=CVE-2026-76024). |
| Chrome 157 stable | 2026-11-03; time/TZ unknown | 157.0.8103.38 for Linux and 157.0.8103.38/.39 for Windows and Mac. Seven new Critical fixes. [Release][chrome157] |
| **Stable update** | **2026-11-09; time/TZ unknown** | 157.0.8103.50/.51 for Windows and Mac and 157.0.8103.50 for Linux. Nine fixes. Google says an exploit for High [CVE-2026-125350](https://www.cve.org/CVERecord?id=CVE-2026-125350) exists in the wild. [Release][chrome157b] |
| Extended Stable update | 2026-11-09; time/TZ unknown | 156.0.8078.96 for Windows and Mac, including CVE-2026-125350. [Release][chrome156ext] |
| CVE record | 2026-11-10 17:20 UTC | Published. Chromium severity High. No CNA numeric score. [CVE-2026-125350](https://www.cve.org/CVERecord?id=CVE-2026-125350) |
| **CISA KEV** | **2026-11-10; time/TZ unknown** | CVE-2026-125350 added. Federal due date 2026-11-24. CISA-ADP CVSS 3.1 8.8. [KEV][kev] |

## Detection

Use Chrome's **About Google Chrome** page or managed-browser inventory to identify the installed full version on every desktop. Do not treat the major version alone as fixed: a browser can be on Chrome 156 before the security update has installed. This advisory covers desktop Chrome; assess Android, iOS, ChromeOS and embedded Chromium products against their own vendor release channels.

## Remediation

Update Windows and macOS Chrome to **157.0.8103.50/.51 or later** and Linux Chrome to **157.0.8103.50 or later** through the supported update channel, then relaunch it. On the Extended Stable channel, update Windows and Mac to **156.0.8078.96 or later**. A Chrome 157 build from November 3, 157.0.8103.38/.39, does not include the November 9 fixes, including CVE-2026-125350. A Chrome 156 build, including 156.0.8078.79/.80, does not include the seven Critical fixes in the November 3 release. The October 27 builds (156.0.8078.73/.74) also lack CVE-2026-76024. Keep enterprise browser auto-update enabled. The source does not establish an alternative mitigation for an unpatched browser. Google says the November 9 update rolls out over the coming days and weeks, so a machine that has not received it yet is still on the older build. The update does not show whether a page already used the exploit.

## Verification

After relaunch, confirm the full version in **About Google Chrome** or the managed inventory record. Exercise ordinary managed-browser controls; do not load exploit samples or untrusted proof-of-concept pages.

## Compromise response

If browser compromise is suspected, preserve relevant endpoint/browser telemetry, isolate the device as appropriate, remove unapproved extensions and profiles, rotate credentials used in that browser from a known-clean device, and follow the organization's endpoint-response procedure. Updating Chrome does not by itself establish that prior browsing sessions were uncompromised.

## Sources

- [Google Chrome 156 desktop stable release, October 27](https://chromereleases.googleblog.com/2026/10/stable-channel-update-for-desktop_0562499947.html) — first Chrome 156 security builds.
- [Google Chrome desktop stable release, October 29](https://chromereleases.googleblog.com/2026/10/stable-channel-update-for-desktop_02107719452.html) — 156.0.8078.79/.80 and Critical CVE-2026-76024.
- [CVE-2026-76024](https://www.cve.org/CVERecord?id=CVE-2026-76024) — Google's Critical rating and affected range before 156.0.8078.79.
- [Google Chrome 157 desktop stable release, November 3](https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-desktop.html) — 157.0.8103.38/.39 and seven Critical fixes.
- [Google Chrome desktop stable release, November 9][chrome157b] — 157.0.8103.50/.51 for Windows and Mac and 157.0.8103.50 for Linux. Nine fixes. Google says an exploit for CVE-2026-125350 exists in the wild.
- [Google Chrome Extended Stable, November 9][chrome156ext] — 156.0.8078.96 for Windows and Mac, including CVE-2026-125350.
- [CVE-2026-125350](https://www.cve.org/CVERecord?id=CVE-2026-125350) — published 2026-11-10. Chromium severity High. Use after free in XML before 157.0.8103.50. CISA-ADP scores it CVSS 3.1 8.8 and marks exploitation active.
- [CISA KEV feed][kev] — catalog 2026.11.10. CVE-2026-125350 added 2026-11-10, due 2026-11-24. The Chrome 156 CVEs and the seven November 3 Critical CVEs are not listed.

[chrome157]: https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-desktop.html
[chrome157b]: https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-desktop_018223192.html
[chrome156ext]: https://chromereleases.googleblog.com/2026/11/extended-stable-update-for-desktop_0910980127.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
