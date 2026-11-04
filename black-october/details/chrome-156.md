# Google Chrome 156: Critical browser memory-safety fixes

**Last updated:** 2026-11-03 (America/New_York)

[Main summary](../black-october-2026.md#google-chrome-critical-browser-security-fixes) · [Main TOC](../black-october-2026.md#table-of-contents)

**CVEs:** [CVE-2026-118306](https://www.cve.org/CVERecord?id=CVE-2026-118306), [CVE-2026-118331](https://www.cve.org/CVERecord?id=CVE-2026-118331), [CVE-2026-118344](https://www.cve.org/CVERecord?id=CVE-2026-118344), [CVE-2026-118348](https://www.cve.org/CVERecord?id=CVE-2026-118348), [CVE-2026-76024](https://www.cve.org/CVERecord?id=CVE-2026-76024). Google identifies the first four as Critical in the October 27 Chrome 156 release, and [CVE-2026-76024](https://www.cve.org/CVERecord?id=CVE-2026-76024) as Critical (memory corruption in MediaStream) in the October 29 release. Google's notices restrict technical details while users update. The CVE record has no CNA numeric score; CISA's enrichment scores it CVSS 3.1 6.5 Medium, which is not Google's rating.

On 2026-11-03 Google promoted Chrome 157. The Linux build is **157.0.8103.38**. Windows and Mac are **157.0.8103.38/.39**. Google says the update includes 213 security fixes and restricts bug details until most users have it. Seven are rated Critical: [CVE-2026-121156](https://www.cve.org/CVERecord?id=CVE-2026-121156) (buffer overflow in Dawn), [CVE-2026-121229](https://www.cve.org/CVERecord?id=CVE-2026-121229) (memory corruption in ANGLE), [CVE-2026-121246](https://www.cve.org/CVERecord?id=CVE-2026-121246) (use after free in WebGL), [CVE-2026-121035](https://www.cve.org/CVERecord?id=CVE-2026-121035) (use after free in Prerender), [CVE-2026-121247](https://www.cve.org/CVERecord?id=CVE-2026-121247) (buffer overflow in Dawn), [CVE-2026-121203](https://www.cve.org/CVERecord?id=CVE-2026-121203) (use after free in Geometry), and [CVE-2026-121126](https://www.cve.org/CVERecord?id=CVE-2026-121126) (use after free in Core). A Chrome 156 build, including 156.0.8078.79/.80, does not contain these fixes.

**CISA KEV:** Not listed (catalog 2026.11.03, checked 2026-11-03) for the Chrome 156 CVEs or these seven. Google's release notes do not report active exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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

## Detection

Use Chrome's **About Google Chrome** page or managed-browser inventory to identify the installed full version on every desktop. Do not treat the major version alone as fixed: a browser can be on Chrome 156 before the security update has installed. This advisory covers desktop Chrome; assess Android, iOS, ChromeOS and embedded Chromium products against their own vendor release channels.

## Remediation

Update Windows and macOS Chrome to **157.0.8103.38/.39 or later** and Linux Chrome to **157.0.8103.38 or later** through the supported update channel, then relaunch it. A Chrome 156 build, including 156.0.8078.79/.80, does not include the seven Critical fixes in the November 3 release. The October 27 builds (156.0.8078.73/.74) also lack CVE-2026-76024. Keep enterprise browser auto-update enabled. The source does not establish an alternative mitigation for an unpatched browser. Google says the 157 update rolls out over the coming days and weeks, so a machine that has not received it yet is still on the older build.

## Verification

After relaunch, confirm the full version in **About Google Chrome** or the managed inventory record. Exercise ordinary managed-browser controls; do not load exploit samples or untrusted proof-of-concept pages.

## Compromise response

If browser compromise is suspected, preserve relevant endpoint/browser telemetry, isolate the device as appropriate, remove unapproved extensions and profiles, rotate credentials used in that browser from a known-clean device, and follow the organization's endpoint-response procedure. Updating Chrome does not by itself establish that prior browsing sessions were uncompromised.

## Sources

- [Google Chrome 156 desktop stable release, October 27](https://chromereleases.googleblog.com/2026/10/stable-channel-update-for-desktop_0562499947.html) — first Chrome 156 security builds.
- [Google Chrome desktop stable release, October 29](https://chromereleases.googleblog.com/2026/10/stable-channel-update-for-desktop_02107719452.html) — 156.0.8078.79/.80 and Critical CVE-2026-76024.
- [CVE-2026-76024](https://www.cve.org/CVERecord?id=CVE-2026-76024) — Google's Critical rating and affected range before 156.0.8078.79.
- [Google Chrome 157 desktop stable release, November 3](https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-desktop.html) — 157.0.8103.38/.39 and seven Critical fixes.
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.03. None of these CVEs is listed.

[chrome157]: https://chromereleases.googleblog.com/2026/11/stable-channel-update-for-desktop.html
