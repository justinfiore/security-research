# Microsoft Edge: logic-only Pwn2Own chain from a web page to code execution

**Last updated:** 2026-10-30 (America/New_York)

[Main Edge summary](../black-october-2026.md#microsoft-edge-logic-only-pwn2own-chain-from-a-web-page-to-code-execution) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

At Pwn2Own Berlin 2026, Orange Tsai (DEVCORE) chained Edge logic bugs, with no memory corruption, to go from a malicious web page to code execution outside Edge's sandbox on Windows. Microsoft fixed the three Edge CVEs below in **Edge Stable 148.0.3967.70 on 2026-05-15**. Tsai published the full technical write-up on 2026-10-28. Any Edge build at or above 148.0.3967.70 includes these fixes; the current Stable release is well past it.

| CVE | What it is (ZDI title) | Microsoft (CNA) | ZDI | NVD |
|---|---|---|---|---|
| [CVE-2026-45495](https://www.cve.org/CVERecord?id=CVE-2026-45495) | Feedback log file handling directory traversal → remote code execution | CVSS 3.1 **8.8**, Important (RCE) | CVSS 3.0 **7.5** High | CVSS 3.1 **9.8** Critical (`AV:N/AC:L/PR:N/UI:N/…`) |
| [CVE-2026-45494](https://www.cve.org/CVERecord?id=CVE-2026-45494) | Navigation handling universal cross-site scripting | CVSS 3.1 5.4, Moderate (spoofing) | CVSS 3.0 5.0 | CVSS 3.1 6.1 Medium |
| [CVE-2026-45492](https://www.cve.org/CVERecord?id=CVE-2026-45492) | Origin validation error (cross-device managed sign-in) security bypass | CVSS 3.1 5.4, Moderate (security feature bypass) | CVSS 3.0 4.3 | No NVD score |

The item qualifies on CVE-2026-45495. The two Moderate CVEs are tracked because they are links in the same chain. Each score rates its bug alone, not the chain. Tsai describes the full chain as **five bugs plus two Windows features**. The steps in his write-up are:

- a cross-window origin-check bypass in Edge's Conditional Access navigation throttle;
- a hard-coded popup allowlist;
- automatic OneAuth sign-in;
- a CORS misconfiguration on `assets.msn.com` that leaked the signed-in email;
- an Immersive Reader `read://` page left off the JavaScript-URL blocklist, which exposed `edgeFeedbackPrivate.zipDiagnosticLogFiles()` as an arbitrary file write;
- an overwritten `protocols.json` that let any origin auto-launch protocol handlers;
- a `telnet://` handler that resolved `telnet.exe` from a user-writable `PATH` folder.

The reviewed sources map only the three Edge CVEs above. No identifier is established for the other links. Some of them, such as the Microsoft web-service CORS issue and the Windows behaviors, are not Edge client code.

**Worst case:** visiting a malicious page in an unpatched Edge on Windows could run attacker code as the current user, with no further click, according to the researcher's chain.

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). Microsoft's Security Update Guide records "Exploited: No" for all three, and CISA ADP SSVC records exploitation "none". The demonstration was a contest entry, and no reviewed source reports in-the-wild use. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | Tsai says the research took two months; no start date given. [Write-up][orange] |
| Pwn2Own Berlin demonstration (public announcement) | 2026-05-14; time/TZ unknown | ZDI confirmed a full win: four logic bugs, $175,000. [Write-up][orange] |
| Edge Stable fix | 2026-05-15 07:00 PDT (UTC−07:00) | Edge **148.0.3967.70** lists all three CVEs; MSRC release time. [Edge release notes][relnotes] [MSRC][msrc-95] |
| Edge for iOS fix listing | 2026-05-19; time/TZ unknown | Edge for iOS 148.0.3967.70 lists CVE-2026-45495 as an iOS-specific fix. [Edge release notes][relnotes] |
| Edge for Android fix listing | 2026-05-21; time/TZ unknown | Edge for Android 148.0.3967.70 lists CVE-2026-45495 as an Android-specific fix. [Edge release notes][relnotes] |
| ZDI "reported to vendor" date | 2026-05-20; time/TZ unknown | ZDI's formal case date. It falls after Microsoft's 2026-05-15 release; the sources do not explain the order. [ZDI-26-329][zdi-92] [ZDI-26-330][zdi-94] [ZDI-26-331][zdi-95] |
| ZDI advisories published | 2026-06-04; time/TZ unknown | ZDI-26-329, -330, -331. |
| Full technical write-up | 2026-10-28; time/TZ unknown | Orange Tsai blog. [Write-up][orange] |

## Detection

1. Use Edge's **edge://settings/help** page, Intune/Configuration Manager browser inventory, or the installed `msedge.exe` file version to record every Edge install's full version, including VDI images, kiosks and offline machines whose updates may have stalled.
2. Any Stable build **below 148.0.3967.70** is affected by all three CVEs. For Edge on iOS and Android, compare against 148.0.3967.70 as listed in the release notes.
3. No IOCs are published. In the write-up, the file-write step overwrites Edge's auto-launch `protocols.json` and drops a `telnet.exe` into a user-writable `PATH` directory (`%LOCALAPPDATA%\Microsoft\WindowsApps`). A `telnet.exe` in that folder is a hunting lead, not proof of exploitation. Finding nothing does not prove an old, unpatched browser was never attacked.

## Remediation

1. Update Edge through its normal managed update channel (Edge Update / WSUS / Intune) to the current Stable release, and at minimum to **148.0.3967.70**. Make sure users relaunch the browser.
2. Re-enable automatic updates anywhere policy has frozen Edge on an older version. These fixes are only available in Edge updates; Windows patches do not apply them.
3. Do not rely on disabling individual features as a substitute. The reviewed sources publish no supported workaround.

## Verification

- After the relaunch, confirm the full version on **edge://settings/help** or in the managed inventory report.
- Exercise ordinary browsing, sign-in and Conditional Access workflows. Do not run the published exploit or proof-of-concept code against production endpoints.

## Compromise response

If an endpoint ran an Edge build older than 148.0.3967.70 and you suspect exploitation, check `%LOCALAPPDATA%\Microsoft\WindowsApps` and other user-writable `PATH` directories for unexpected executables such as `telnet.exe`. Look for unexpected changes to the `protocols.json` file read by Edge's auto-launch protocols component, and look at process telemetry for processes launched by `msedge.exe` or through URL-protocol handlers. Rotate credentials and sessions used in that browser from a clean device, and follow your organization's endpoint incident-response procedure.

## Sources

- [Microsoft Edge security release notes][relnotes] — fixed versions and dates by platform.
- MSRC entries for [CVE-2026-45495][msrc-95], [CVE-2026-45494][msrc-94], [CVE-2026-45492][msrc-92] — Microsoft severity, CVSS, impact, "Exploited: No".
- ZDI advisories [ZDI-26-329][zdi-92], [ZDI-26-330][zdi-94], [ZDI-26-331][zdi-95] — Pwn2Own credit, bug classes, ZDI scores and disclosure dates.
- [Orange Tsai's write-up][orange] — chain composition, Windows features used and the Pwn2Own result.
- NVD entries for [CVE-2026-45495](https://nvd.nist.gov/vuln/detail/CVE-2026-45495) and [CVE-2026-45494](https://nvd.nist.gov/vuln/detail/CVE-2026-45494) — NVD's differing scores.
- [CISA KEV JSON feed][kev] — catalog 2026.10.29 status.

[relnotes]: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-relnotes-security
[msrc-95]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-45495
[msrc-94]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-45494
[msrc-92]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-45492
[zdi-92]: https://www.zerodayinitiative.com/advisories/ZDI-26-329/
[zdi-94]: https://www.zerodayinitiative.com/advisories/ZDI-26-330/
[zdi-95]: https://www.zerodayinitiative.com/advisories/ZDI-26-331/
[orange]: https://blog.orange.tw/posts/2026-10-the-last-proof-of-human-craft-browser-full-chain
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
