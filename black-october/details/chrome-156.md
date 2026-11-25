# Google Chrome 156: Critical browser memory-safety fixes

**Last updated:** 2026-11-25 (America/New_York)

[Main summary](../black-october-2026.md#google-chrome-critical-browser-security-fixes) · [Main TOC](../black-october-2026.md#table-of-contents)

**CVEs:** [CVE-2026-118306](https://www.cve.org/CVERecord?id=CVE-2026-118306), [CVE-2026-118331](https://www.cve.org/CVERecord?id=CVE-2026-118331), [CVE-2026-118344](https://www.cve.org/CVERecord?id=CVE-2026-118344), [CVE-2026-118348](https://www.cve.org/CVERecord?id=CVE-2026-118348), [CVE-2026-76024](https://www.cve.org/CVERecord?id=CVE-2026-76024). Google identifies the first four as Critical in the October 27 Chrome 156 release, and [CVE-2026-76024](https://www.cve.org/CVERecord?id=CVE-2026-76024) as Critical (memory corruption in MediaStream) in the October 29 release. Google's notices restrict technical details while users update. The CVE record has no CNA numeric score; CISA's enrichment scores it CVSS 3.1 6.5 Medium, which is not Google's rating.

On 2026-11-03 Google promoted Chrome 157. The Linux build is **157.0.8103.38**. Windows and Mac are **157.0.8103.38/.39**. Google says the update includes 213 security fixes and restricts bug details until most users have it. Seven are rated Critical: [CVE-2026-121156](https://www.cve.org/CVERecord?id=CVE-2026-121156) (buffer overflow in Dawn), [CVE-2026-121229](https://www.cve.org/CVERecord?id=CVE-2026-121229) (memory corruption in ANGLE), [CVE-2026-121246](https://www.cve.org/CVERecord?id=CVE-2026-121246) (use after free in WebGL), [CVE-2026-121035](https://www.cve.org/CVERecord?id=CVE-2026-121035) (use after free in Prerender), [CVE-2026-121247](https://www.cve.org/CVERecord?id=CVE-2026-121247) (buffer overflow in Dawn), [CVE-2026-121203](https://www.cve.org/CVERecord?id=CVE-2026-121203) (use after free in Geometry), and [CVE-2026-121126](https://www.cve.org/CVERecord?id=CVE-2026-121126) (use after free in Core). A Chrome 156 build, including 156.0.8078.79/.80, does not contain these fixes.

On 2026-11-09 Google updated the Stable channel again. Windows and Mac are **157.0.8103.50/.51** and Linux is **157.0.8103.50**. The post lists nine security fixes, seven of them High and none Critical. [CVE-2026-125350](https://www.cve.org/CVERecord?id=CVE-2026-125350) is High, a use after free in XML, reported by an anonymous researcher on 2026-11-06. Google writes: "Google is aware that an exploit for CVE-2026-125350 exists in the wild." The same post lists six more High fixes and two Medium fixes, and it does not report exploitation for those. A Chrome 157 build from November 3, 157.0.8103.38/.39, does not contain these nine fixes. The same day's Extended Stable update for Windows and Mac, **156.0.8078.96**, lists CVE-2026-125350 among eleven fixes. Google does not publish a numeric CVSS score for any of them.

On 2026-11-11 Google updated Stable again, to **157.0.8103.78/.79** for Windows and Mac and **157.0.8103.78** for Linux. The post says the update includes 83 security fixes, five of them Critical: [CVE-2026-126885](https://www.cve.org/CVERecord?id=CVE-2026-126885), [CVE-2026-126895](https://www.cve.org/CVERecord?id=CVE-2026-126895), [CVE-2026-126879](https://www.cve.org/CVERecord?id=CVE-2026-126879), [CVE-2026-126846](https://www.cve.org/CVERecord?id=CVE-2026-126846), and [CVE-2026-126911](https://www.cve.org/CVERecord?id=CVE-2026-126911). The same day's Extended Stable update is **156.0.8078.100** for Windows and Mac, with 72 security fixes and four of those Critical CVEs. Neither post reports exploitation. The November 9 builds, 157.0.8103.50/.51 and 156.0.8078.96, do not contain these fixes.

On 2026-11-17 Google promoted Chrome 158. Linux is **158.0.8127.36**. Windows and Mac are **158.0.8127.36/.37**. Google says the update includes 204 security fixes. Six are rated Critical: [CVE-2026-130963](https://www.cve.org/CVERecord?id=CVE-2026-130963) (use after free in WebView), [CVE-2026-131031](https://www.cve.org/CVERecord?id=CVE-2026-131031) (out of bounds write in GPU), [CVE-2026-131060](https://www.cve.org/CVERecord?id=CVE-2026-131060) (buffer overflow in Media), [CVE-2026-131008](https://www.cve.org/CVERecord?id=CVE-2026-131008) (use after free in GarbageCollection), [CVE-2026-131054](https://www.cve.org/CVERecord?id=CVE-2026-131054) (out of bounds write in ANGLE), and [CVE-2026-130975](https://www.cve.org/CVERecord?id=CVE-2026-130975) (use after free in WebAudio). The post lists 62 High, 82 Medium, and 54 Low. It does not say an exploit exists for any of them. Google publishes no numeric score. A Chrome 157 build, including 157.0.8103.78/.79, does not contain these fixes. The same day's Android release, **158.0.8127.42**, says Android carries the same security fixes as that desktop release unless otherwise noted. The same day's Extended Stable update is **156.0.8078.108/.109** for Windows and Mac, with 79 security fixes. It lists three Critical CVEs from the October 27 set, [CVE-2026-118331](https://www.cve.org/CVERecord?id=CVE-2026-118331), [CVE-2026-118344](https://www.cve.org/CVERecord?id=CVE-2026-118344), and [CVE-2026-118348](https://www.cve.org/CVERecord?id=CVE-2026-118348), and it does not list the six Chrome 158 Critical CVEs. 156.0.8078.100 does not contain those 79 fixes.

On 2026-11-23 Google updated the Stable channel again. Windows and Mac are **158.0.8127.88/.89** and Linux is **158.0.8127.88**. The post lists one security fix, rated Critical: [CVE-2026-134401](https://www.cve.org/CVERecord?id=CVE-2026-134401), improper input validation in Variations, reported by Google on 2026-08-28. The CVE record says a crafted HTML page can run code outside the sandbox, in Chrome before 158.0.8127.88. Google publishes no numeric score. The record's CISA-ADP enrichment scores it CVSS 3.1 9.6, which is not Google's rating, and marks exploitation none. The post does not say an exploit exists. The November 17 builds, 158.0.8127.36/.37, do not contain it. The same day's Extended Stable update is **156.0.8078.114** for Windows and Mac, and the post says that one fix is CVE-2026-134401. 156.0.8078.108/.109 does not contain it.

On 2026-11-18 Google updated ChromeOS Stable to OS **16868.24.0**, browser **158.0.8127.65**, for most devices. The post's browser list rates twelve flaws Critical. Eleven of them are in the desktop 157 and 158 posts. It does not list [CVE-2026-130963](https://www.cve.org/CVERecord?id=CVE-2026-130963), the WebView flaw from the desktop 158 post. It does list High [CVE-2026-125350](https://www.cve.org/CVERecord?id=CVE-2026-125350). The post does not say an exploit exists. A ChromeOS browser older than 158.0.8127.65 does not contain that list. Desktop 158.0.8127.36 is a different build.

**CISA KEV:** Listed — [CVE-2026-125350](https://www.cve.org/CVERecord?id=CVE-2026-125350) added 2026-11-10, federal due date 2026-11-24. Ransomware use Unknown. The feed says a crafted page can run code inside the sandbox. The Chrome 156 CVEs, the seven Chrome 157 Critical CVEs from November 3, the six Chrome 158 Critical CVEs, and CVE-2026-134401 are not listed (catalog 2026.11.23, checked 2026-11-24). CISA-ADP scores CVE-2026-125350 CVSS 3.1 8.8 High, which is not Google's rating. Google publishes no numeric score. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Stable update** | **2026-11-11; time/TZ unknown** | 157.0.8103.78/.79 for Windows and Mac and 157.0.8103.78 for Linux. 83 fixes, five Critical. Extended Stable 156.0.8078.100. No exploitation reported. [Release][chrome157c] |
| **Chrome 158 stable** | **2026-11-17; time/TZ unknown** | 158.0.8127.36 for Linux and 158.0.8127.36/.37 for Windows and Mac. 204 fixes, six Critical. Android 158.0.8127.42 the same day. No exploitation reported. [Release][chrome158] |
| **Extended Stable** | **2026-11-17; time/TZ unknown** | 156.0.8078.108/.109 for Windows and Mac. 79 fixes, including three Critical CVEs from October 27. [Release][chrome156d] |
| **ChromeOS Stable** | **2026-11-18 21:16 PST (UTC−08:00)** | OS 16868.24.0, browser 158.0.8127.65. Twelve Critical browser fixes. CVE-2026-130963 is not in the list. [Release][chromeos158] |
| Extended Stable update | 2026-11-09; time/TZ unknown | 156.0.8078.96 for Windows and Mac, including CVE-2026-125350. [Release][chrome156ext] |
| CVE record | 2026-11-10 17:20 UTC | Published. Chromium severity High. No CNA numeric score. [CVE-2026-125350](https://www.cve.org/CVERecord?id=CVE-2026-125350) |
| **CISA KEV** | **2026-11-10; time/TZ unknown** | CVE-2026-125350 added. Federal due date 2026-11-24. CISA-ADP CVSS 3.1 8.8. [KEV][kev] |
| **Stable update** | **2026-11-23; time/TZ unknown** | 158.0.8127.88/.89 for Windows and Mac and 158.0.8127.88 for Linux. One fix, Critical CVE-2026-134401. Extended Stable 156.0.8078.114. No exploitation reported. [Release][chrome158b] |

## Detection

Use Chrome's **About Google Chrome** page or managed-browser inventory to identify the installed full version on every desktop. Do not treat the major version alone as fixed: a browser can be on Chrome 158 before 158.0.8127.88 has installed. On Android, the Play listing is **158.0.8127.42**. ChromeOS Stable of November 18 is OS **16868.24.0** and browser **158.0.8127.65**. iOS is a separate channel. The iOS post of November 12 is Chrome Stable 158 (**158.0.8127.35**) and lists no security fixes.

## Remediation

Update Windows and macOS Chrome to **158.0.8127.88/.89 or later** and Linux Chrome to **158.0.8127.88 or later** through the supported update channel, then relaunch it. On Android, update to **158.0.8127.92 or later**. Google's November 23 Android post says that build carries the same security fixes as desktop 158.0.8127.88/.89. 158.0.8127.42 is the November 17 build and does not contain CVE-2026-134401. On the Extended Stable channel, update Windows and Mac to **156.0.8078.114 or later**. The November 17 builds, 158.0.8127.36/.37 and 156.0.8078.108/.109, do not contain CVE-2026-134401. A Chrome 157 build, including 157.0.8103.78/.79, does not include the November 17 fixes. The November 11 builds do not include them either. 156.0.8078.100 does not include the November 17 Extended Stable fixes. The November 9 builds, 157.0.8103.50/.51 and 156.0.8078.96, do not include the November 11 fixes. A Chrome 157 build from November 3, 157.0.8103.38/.39, does not include the November 9 fixes, including CVE-2026-125350. A Chrome 156 build, including 156.0.8078.79/.80, does not include the seven Critical fixes in the November 3 release. The October 27 builds (156.0.8078.73/.74) also lack CVE-2026-76024. Keep enterprise browser auto-update enabled. The source does not establish an alternative mitigation for an unpatched browser. Google says the November 17 update rolls out over the coming days and weeks, so a machine that has not received it yet is still on the older build. The update does not show whether a page already used an exploit.

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
- [Google Chrome desktop stable release, November 11][chrome157c] — 157.0.8103.78/.79 for Windows and Mac and 157.0.8103.78 for Linux. 83 fixes, five Critical. The post does not report exploitation.
- [Google Chrome Extended Stable, November 11][chrome156b] — 156.0.8078.100 for Windows and Mac. 72 fixes, four Critical.
- [Google Chrome Extended Stable, November 9][chrome156ext] — 156.0.8078.96 for Windows and Mac, including CVE-2026-125350.
- [CVE-2026-125350](https://www.cve.org/CVERecord?id=CVE-2026-125350) — published 2026-11-10. Chromium severity High. Use after free in XML before 157.0.8103.50. CISA-ADP scores it CVSS 3.1 8.8 and marks exploitation active.
- [Google Chrome 158 desktop stable release, November 17][chrome158] — 158.0.8127.36 for Linux and 158.0.8127.36/.37 for Windows and Mac. 204 fixes: six Critical, 62 High, 82 Medium, 54 Low. The post does not report exploitation.
- [Google Chrome for Android, November 17][chrome158a] — 158.0.8127.42. Same security fixes as the desktop release unless otherwise noted.
- [Google Chrome Extended Stable, November 17][chrome156d] — 156.0.8078.108/.109 for Windows and Mac. 79 fixes, including CVE-2026-118331, CVE-2026-118344, and CVE-2026-118348.
- [ChromeOS Stable, November 18][chromeos158] — posted 2026-11-18 21:16 PST. OS 16868.24.0, browser 158.0.8127.65. Twelve Critical browser fixes. CVE-2026-130963 is not in that list. CVE-2026-125350 is, as High. The post does not report an exploit.
- [Google Chrome desktop stable release, November 23][chrome158b] — 158.0.8127.88/.89 for Windows and Mac and 158.0.8127.88 for Linux. One fix: Critical CVE-2026-134401, improper input validation in Variations. The post does not report exploitation.
- [Google Chrome Extended Stable, November 23](https://chromereleases.googleblog.com/2026/11/extended-stable-update-for-desktop_01590513949.html) — 156.0.8078.114 for Windows and Mac. The one fix is CVE-2026-134401.
- [CVE-2026-134401](https://www.cve.org/CVERecord?id=CVE-2026-134401) — published 2026-11-23. Chromium severity Critical. A crafted page runs code outside the sandbox, before 158.0.8127.88. Google publishes no numeric score. CISA-ADP scores it CVSS 3.1 9.6 and marks exploitation none.
- [CISA KEV feed][kev] — catalog 2026.11.23, checked 2026-11-24. CVE-2026-125350 added 2026-11-10, due 2026-11-24. CVE-2026-134401 is not listed. The Chrome 156 CVEs, the seven November 3 Critical CVEs, and the six Chrome 158 Critical CVEs are not listed.

[chrome157]: https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-desktop.html
[chrome157b]: https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-desktop_018223192.html
[chrome157c]: https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-desktop_01744469280.html
[chrome156b]: https://chromereleases.googleblog.com/2026/11/extended-stable-update-for-desktop_01570615041.html
[chrome156ext]: https://chromereleases.googleblog.com/2026/11/extended-stable-update-for-desktop_0910980127.html
[chrome158]: https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-desktop_01699533288.html
[chrome158a]: https://chromereleases.googleblog.com/2026/11/chrome-for-android-update_0281314271.html
[chrome156d]: https://chromereleases.googleblog.com/2026/11/extended-stable-update-for-desktop_01061812727.html
[chromeos158]: https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-chromeos_01891834105.html
[chrome158b]: https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-desktop_01734282054.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
