# Danfoss AK-SM800A: six flaws run code before login

**Last updated:** 2026-11-27 (America/New_York)

[Main Danfoss summary](../black-october-2026.md#danfoss-ak-sm800a-six-flaws-run-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

The AK-SM800A is a Danfoss system manager for supermarket and cold-storage refrigeration. Midnight Blue researcher Carlo Meijer reports six stack-based buffer overflows in it. A remote attacker who is not logged in can run code as root. The research covers every firmware through **5.3.2**, which was the latest build the researcher had when the post was written. One of the six is in the session-control process, so Strict mode does not close it. The controller does not use secure boot, and the researcher says an implant can survive a factory reset.

**CISA's [ICSA-26-328-03](https://www.cisa.gov/news-events/ics-advisories/icsa-26-328-03), released 2026-11-24, assigns [CVE-2026-129713](https://www.cve.org/CVERecord?id=CVE-2026-129713) to one of the overflows.** CISA says Danfoss rates it CVSS 3.1 9.8 Critical, `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`, and CVSS 4.0 9.3 Critical, `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The affected range in that advisory is **AK-SM 8xxA 5.4.0 and earlier**. The description is narrower than Midnight Blue's: a stack-based buffer overflow in an unauthenticated CGI handler, memory corruption, a web-server restart, and "hypothetically potential arbitrary code execution with webserver privileges." Danfoss says the fix is a future **5.5.x** release, which will also remove the option to disable Strict mode. Carlo Meijer of Midnight Blue is the reporter CISA names. The other five flaws in the November 12 post still have no CVE. Midnight Blue's post still withholds the endpoints.

**CISA KEV:** Listed — [CVE-2025-41450](https://www.cve.org/CVERecord?id=CVE-2025-41450), [CVE-2023-25914](https://www.cve.org/CVERecord?id=CVE-2023-25914), and [CVE-2023-25915](https://www.cve.org/CVERecord?id=CVE-2023-25915) were added 2026-11-25. CVE-2025-41450 is due 2026-12-09. Forensic triage is not required for it. The other two are due 2026-11-28 and forensic triage is required. Ransomware use is Unknown for all three. [CVE-2026-129713](https://www.cve.org/CVERecord?id=CVE-2026-129713) is not listed (catalog 2026.11.25, released 2026-11-25T19:48:12.4344Z, checked 2026-11-27). CISA says no known public exploitation of that vulnerability has been reported to it. [CVE-2023-25913](https://www.cve.org/CVERecord?id=CVE-2023-25913) is not listed. The five November 12 overflows that still have no CVE cannot be listed. BSI says it knows of no exploitation of those six. The refrigeration attacks that began on October 11 are a separate campaign, and no source ties those attacks to any of these flaws. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

These three are older than the November 12 research, and the fixes already shipped. Danfoss's [DSA-2025-03-01](https://www.danfoss.com/en/service-and-support/coordinated-vulnerability-disclosure/danfoss-security-advisories/dsa-2025-03-01) rates CVE-2025-41450 CVSS 3.1 **8.2 High**. Before release **4.2**, a datetime-based password generates a web report of internal IP addresses, usernames, and store names. CISA's [ICSA-25-140-03](https://www.cisa.gov/news-events/ics-advisories/icsa-25-140-03), last revised 2026-11-18, scores the same flaw 8.2 and CVSS 4.0 7.3, and says the affected range is before R4.2. NVD scores it 7.5. Danfoss's score is the one this guide uses for the patch decision.

Danfoss's [DSA-2023-08-01](https://www.danfoss.com/en/service-and-support/coordinated-vulnerability-disclosure/danfoss-security-advisories/dsa-2023-08-01), published 2023-08-21, covers every AK-SM 800A series build before **3.3**. Danfoss rates CVE-2023-25915 **9.8 Critical**: improper input validation lets a remote attacker run commands. The CVE record, from the Dutch Institute for Vulnerability Disclosure, scores it **9.9** and says the attacker is authenticated. Danfoss's advisory does not say that. Danfoss rates CVE-2023-25914 **7.5 High**: a path traversal through the XML interface reads files on the controller. The CVE record scores it **8.8** and also says authenticated. CVE-2023-25913 is the same 7.5, the same report flaw as CVE-2025-41450, and the same 3.3 fix. It is not in KEV. Install 3.3 or later for all three. Release 4.2 is later than 3.3, so a controller on 4.2 or later has both fixes. Neither release fixes CVE-2026-129713.

Germany's BSI said on November 13 that firmware through at least 5.3.2 is affected, and that it knows of no exploitation of these six. The same day, at 13:25, BSI withdrew an earlier sentence that said package **5.4.0** was not affected: BSI now says that cannot be ruled out. CISA's November 24 advisory now lists 5.4.0 and earlier as affected and names 5.5.x as the future fix, which matches that withdrawal. Danfoss's download page, reread 2026-11-27, again lists **AK-SM 800A 5.4.0.spk (November 2026)** as the latest software package. A read on 2026-11-17 had found only 5.3.x. CISA says 5.4.0 and earlier are affected by CVE-2026-129713 and that the fix is a future **5.5.x**, which is still not on the page. The 5.4.0 package is not that fix.

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [What 5.4.0 does not fix](#what-540-does-not-fix)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Refrigeration attacks begin | 2026-10-11; time unknown | Exposed Danfoss and Copeland controllers in Europe. Not attributed to these six flaws. [Midnight Blue][mb] |
| Research against 5.3.2 | by 2026-11-07 21:44:33 GMT | A lab request in the post is dated that evening. [Midnight Blue][mb] |
| **Public announcement** | **2026-11-12; time/TZ unknown** | Midnight Blue and the CCB. Six pre-authentication flaws, no CVE, no patch named. [Midnight Blue][mb] [CCB][ccb] |
| BSI names 5.4.0, then withdraws it | 2026-11-13; the withdrawal is 13:25, timezone not stated | Firmware through at least 5.3.2 is affected. An earlier version of the release said package 5.4.0 was not; BSI says that can no longer be ruled out. No known exploitation of these flaws. [BSI][bsi] |
| **CISA advisory** | **2026-11-24; time/TZ unknown** | ICSA-26-328-03, revision 1. CVE-2026-129713. Danfoss scores 9.8 and 9.3. Affected through 5.4.0. Fix is a future 5.5.x. [CISA][cisa] |
| **CISA KEV** | **2026-11-25; catalog released 19:48:12 UTC** | CVE-2025-41450 due 2026-12-09. CVE-2023-25914 and CVE-2023-25915 due 2026-11-28, forensic triage required. CVE-2026-129713 is not listed. [KEV][kev] |
| Download page offers 5.4.0 again | 2026-11-27; time/TZ unknown | 5.4.0.spk, dated November 2026. CISA says that build is affected. 5.5.x is still not listed. |
| **Last updated** | **2026-11-27 (America/New_York)** | The download page offers 5.4.0. It is not the fix. |

## Detection

1. Read the software package version on the controller, or from the management software that inventories it. A package at or below **5.3.2** is inside the range Midnight Blue tested.
2. Check whether the management interface is reachable from the internet, including through a 4G or 5G modem. A modem is not a firewall. The CCB says a controller whose management port answers from the public internet is exposed.
3. Strict session control does not take the controller out of scope. Midnight Blue shows a crash in the session-control process with Strict mode on.

There is no CVE to match in a scanner, and neither Midnight Blue nor Danfoss publishes a log line for these flaws.

## Remediation

1. Remove the management interface from the public internet. Put remote access behind a VPN or a private network, as the CCB and BSI both say. IP allow-listing of a refrigeration provider is a stopgap, not the fix.
2. Upgrade a controller below **3.3** to **3.3 or later**, and one below **4.2** to **4.2 or later**. Release 3.3 closes CVE-2023-25913, CVE-2023-25914, and CVE-2023-25915. Release 4.2 closes CVE-2025-41450 and is later than 3.3, so it covers all four. Neither release closes CVE-2026-129713. The upgrade does not show whether a report was already generated or a command already ran.
3. Do not treat an upgrade to 5.3.2, a password change, or Strict mode as the remedy. Midnight Blue found the six flaws in 5.3.2, and one of them is in the process that enforces Strict mode.
4. Do not install 5.4.0, or the 5.3.x package on the download page, as the remedy for CVE-2026-129713. CISA says Danfoss's fix is **5.5.x**, which is not released, and that 5.4.0 and earlier are affected. Keep the controller off the internet either way. The researcher says the codebase yields flaws of this kind quickly, and an implant can outlast a firmware update. The 5.5.x release, when it ships, still does not show whether the flash already holds an implant.
5. The AK-SM 800 and AK-SC 355 are older products, end of life, and are not these six flaws. Danfoss tells operators to replace them. This guide does not cover them.

### What 5.4.0 does not fix

CISA lists AK-SM 8xxA **5.4.0 and earlier** as affected by CVE-2026-129713. BSI had briefly called 5.4.0 unaffected and withdrew that on November 13. The download page, reread 2026-11-27, offers 5.4.0.spk and has no 5.5.x package. Installing 5.3.x or 5.4.0 does not close the CGI overflow, and it does not close the other five flaws, which still have no CVE.

## Verification

- From a network that is not the controller's own, the management port does not answer.
- The running package is the newest one Danfoss actually offers. If that is still 5.3.x, the controller is inside the researched range and the network check is the control that matters.
- Do not send a request built to overflow a field.

## Compromise response

The attacks since October 11 changed defrost and temperature settings on exposed controllers. Those attacks are not established as these six flaws. If a controller was reachable from the internet, check the configuration anyway: temperature setpoints, defrost schedules, user accounts, and remote-access settings.

Midnight Blue says the platform has no secure boot, so a factory reset and a firmware update do not show whether the flash already holds an implant. A controller that keeps misbehaving after a reset needs replacement, not another password change. Report a confirmed intrusion to the CCB if the site is in Belgium.

## Sources

- [Midnight Blue][mb] — November 2026. Six stack-based buffer overflows, pre-authentication, through firmware 5.3.2. One is in the session-control process, so Strict mode does not close it. CVEs pending. No numeric score. Endpoints withheld while disclosure with Danfoss is open.
- [CCB advisory][ccb] — published and last updated 2026-11-12. Same product, versions, and impact. Says no patch was available at publication, and that removing internet exposure comes before waiting for one.
- [BSI press release][bsi] — Bonn, 2026-11-13, updated the same day at 13:25. Firmware through at least 5.3.2 is affected. The first version said package 5.4.0 was not; the update says that can no longer be ruled out. No known exploitation of these flaws. Recommends a VPN when remote maintenance is required.
- [Danfoss AK-SM 800A downloads][dl] — reread 2026-11-27. The latest package is 5.4.0.spk, dated November 2026. No 5.5.x package. CISA says 5.4.0 is affected.
- [CISA KEV JSON][kev] — catalog 2026.11.25, released 2026-11-25T19:48:12.4344Z, checked 2026-11-26. CVE-2025-41450, CVE-2023-25914, and CVE-2023-25915 were added 2026-11-25. CVE-2026-129713 and CVE-2023-25913 are not listed.
- [DSA-2025-03-01][dsa2025] — published 2025-03-24. CVE-2025-41450, CVSS 3.1 8.2. AK-SM 8xxA before 4.2. Fix is release 4.2.
- [DSA-2023-08-01][dsa2023] — published 2023-08-21. CVE-2023-25913 and CVE-2023-25914 are 7.5. CVE-2023-25915 is 9.8. Every series build before 3.3. Fix is release 3.3.
- [ICSA-25-140-03][icsa25] — last revised 2026-11-18. CVE-2025-41450 is 8.2 and CVSS 4.0 7.3, before R4.2. The same advisory's CVE-2025-41451 is 7.6 and is not in KEV. CVE-2025-41452 is 5.4.

[mb]: https://www.midnightblue.nl/blog/multiple-rce-danfoss-aksm800a
[ccb]: https://ccb.belgium.be/advisories/warning-six-new-danfoss-vulnerabilities-refrigeration-controllers-risk-immediate-action
[bsi]: https://www.bsi.bund.de/DE/Service-Navi/Presse/Pressemitteilungen/Presse2026/261113_Kuehlgeraete-Danfoss.html
[dl]: https://www.danfoss.com/en/service-and-support/downloads/dcs/adap-kool-software/ak-sm-800a
- [CISA ICSA-26-328-03][cisa] — 2026-11-24. CVE-2026-129713, Danfoss CVSS 3.1 9.8 and CVSS 4.0 9.3. AK-SM 8xxA through 5.4.0. Fix planned for 5.5.x. No known exploitation reported to CISA.

[cisa]: https://www.cisa.gov/news-events/ics-advisories/icsa-26-328-03
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[dsa2025]: https://www.danfoss.com/en/service-and-support/coordinated-vulnerability-disclosure/danfoss-security-advisories/dsa-2025-03-01
[dsa2023]: https://www.danfoss.com/en/service-and-support/coordinated-vulnerability-disclosure/danfoss-security-advisories/dsa-2023-08-01
[icsa25]: https://www.cisa.gov/news-events/ics-advisories/icsa-25-140-03
