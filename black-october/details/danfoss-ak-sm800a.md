# Danfoss AK-SM800A: six flaws run code before login

**Last updated:** 2026-11-25 (America/New_York)

[Main Danfoss summary](../black-october-2026.md#danfoss-ak-sm800a-six-flaws-run-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

The AK-SM800A is a Danfoss system manager for supermarket and cold-storage refrigeration. Midnight Blue researcher Carlo Meijer reports six stack-based buffer overflows in it. A remote attacker who is not logged in can run code as root. The research covers every firmware through **5.3.2**, which was the latest build the researcher had when the post was written. One of the six is in the session-control process, so Strict mode does not close it. The controller does not use secure boot, and the researcher says an implant can survive a factory reset.

**CISA's [ICSA-26-328-03](https://www.cisa.gov/news-events/ics-advisories/icsa-26-328-03), released 2026-11-24, assigns [CVE-2026-129713](https://www.cve.org/CVERecord?id=CVE-2026-129713) to one of the overflows.** CISA says Danfoss rates it CVSS 3.1 9.8 Critical, `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`, and CVSS 4.0 9.3 Critical, `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The affected range in that advisory is **AK-SM 8xxA 5.4.0 and earlier**. The description is narrower than Midnight Blue's: a stack-based buffer overflow in an unauthenticated CGI handler, memory corruption, a web-server restart, and "hypothetically potential arbitrary code execution with webserver privileges." Danfoss says the fix is a future **5.5.x** release, which will also remove the option to disable Strict mode. Carlo Meijer of Midnight Blue is the reporter CISA names. The other five flaws in the November 12 post still have no CVE. Midnight Blue's post still withholds the endpoints.

**CISA KEV:** Not listed (catalog 2026.11.24, checked 2026-11-25) for CVE-2026-129713. CISA says no known public exploitation of this vulnerability has been reported to it. The other five have no CVE, so KEV cannot list them. BSI says it knows of no exploitation of the six. The refrigeration attacks that began on October 11 are a separate campaign, and no source ties those attacks to these flaws. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

Germany's BSI said on November 13 that firmware through at least 5.3.2 is affected, and that it knows of no exploitation of these six. The same day, at 13:25, BSI withdrew an earlier sentence that said package **5.4.0** was not affected: BSI now says that cannot be ruled out. CISA's November 24 advisory now lists 5.4.0 and earlier as affected and names 5.5.x as the future fix, which matches that withdrawal. Danfoss's download page, reread 2026-11-17, lists **AK-SM 800A 5.3.x.spk (October 2026)** and no 5.4.0 package. An earlier read of the same page on 2026-11-16 reported a 5.4.0 package; that listing is not there now. Danfoss's own advisory text is the CISA republication; the download page still has no 5.5.x package.

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
| **Last updated** | **2026-11-25 (America/New_York)** | One of the six now has a CVE. There is still no firmware. |

## Detection

1. Read the software package version on the controller, or from the management software that inventories it. A package at or below **5.3.2** is inside the range Midnight Blue tested.
2. Check whether the management interface is reachable from the internet, including through a 4G or 5G modem. A modem is not a firewall. The CCB says a controller whose management port answers from the public internet is exposed.
3. Strict session control does not take the controller out of scope. Midnight Blue shows a crash in the session-control process with Strict mode on.

There is no CVE to match in a scanner, and neither Midnight Blue nor Danfoss publishes a log line for these flaws.

## Remediation

1. Remove the management interface from the public internet. Put remote access behind a VPN or a private network, as the CCB and BSI both say. IP allow-listing of a refrigeration provider is a stopgap, not the fix.
2. Do not treat an upgrade to 5.3.2, a password change, or Strict mode as the remedy. Midnight Blue found the six flaws in 5.3.2, and one of them is in the process that enforces Strict mode.
3. Do not install 5.4.0, or the 5.3.x package on the download page, as the remedy. CISA says Danfoss's fix is **5.5.x**, which is not released, and that 5.4.0 and earlier are affected. Keep the controller off the internet either way. The researcher says the codebase yields flaws of this kind quickly, and an implant can outlast a firmware update. The 5.5.x release, when it ships, still does not show whether the flash already holds an implant.
4. The AK-SM 800 and AK-SC 355 are older products, end of life, and are not these six flaws. Danfoss tells operators to replace them. This guide does not cover them.

### What 5.4.0 does not fix

CISA lists AK-SM 8xxA **5.4.0 and earlier** as affected by CVE-2026-129713. BSI had briefly called 5.4.0 unaffected and withdrew that on November 13. The download page, last read 2026-11-17, still had no 5.4.0 package and has no 5.5.x package. Installing either 5.3.x or 5.4.0 does not close the CGI overflow, and it does not close the other five flaws, which still have no CVE.

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
- [Danfoss AK-SM 800A downloads][dl] — reread 2026-11-17. The listed package is 5.3.x, dated October 2026. No 5.4.0 package and no advisory for these six flaws. A 2026-11-16 read of the same page reported a 5.4.0 listing; it is not there now.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10, checked 2026-11-13. Not applicable: no CVE is assigned.

[mb]: https://www.midnightblue.nl/blog/multiple-rce-danfoss-aksm800a
[ccb]: https://ccb.belgium.be/advisories/warning-six-new-danfoss-vulnerabilities-refrigeration-controllers-risk-immediate-action
[bsi]: https://www.bsi.bund.de/DE/Service-Navi/Presse/Pressemitteilungen/Presse2026/261113_Kuehlgeraete-Danfoss.html
[dl]: https://www.danfoss.com/en/service-and-support/downloads/dcs/adap-kool-software/ak-sm-800a
- [CISA ICSA-26-328-03][cisa] — 2026-11-24. CVE-2026-129713, Danfoss CVSS 3.1 9.8 and CVSS 4.0 9.3. AK-SM 8xxA through 5.4.0. Fix planned for 5.5.x. No known exploitation reported to CISA.

[cisa]: https://www.cisa.gov/news-events/ics-advisories/icsa-26-328-03
