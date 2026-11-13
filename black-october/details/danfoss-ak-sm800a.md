# Danfoss AK-SM800A: six flaws run code before login

**Last updated:** 2026-11-13 (America/New_York)

[Main Danfoss summary](../black-october-2026.md#danfoss-ak-sm800a-six-flaws-run-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

The AK-SM800A is a Danfoss system manager for supermarket and cold-storage refrigeration. Midnight Blue researcher Carlo Meijer reports six stack-based buffer overflows in it. A remote attacker who is not logged in can run code as root. The research covers every firmware through **5.3.2**, which was the latest build the researcher had when the post was written. One of the six is in the session-control process, so Strict mode does not close it. The controller does not use secure boot, and the researcher says an implant can survive a factory reset.

No CVE is assigned. Midnight Blue says the identifiers are pending and that coordinated disclosure with Danfoss is still open, so the post withholds the endpoints. Neither Midnight Blue nor the Centre for Cybersecurity Belgium publishes a numeric score. Admission here rests on the researcher's report of unauthenticated remote code execution as root, not on a vendor or CNA score. Danfoss has published no advisory for these six.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. BSI says it knows of no exploitation of these six flaws. The refrigeration attacks that began on October 11 are a separate campaign against exposed controllers, and no source ties those attacks to these six flaws. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

Germany's BSI said on November 13 that firmware through 5.3.2 is affected and that software package **5.4.0**, dated November 2026, is not. Danfoss's own download page still offered only **5.3.x**, dated October 2026, when this was written, and Danfoss has not said that 5.4.0 fixes these flaws. Treat 5.4.0 as BSI's statement, not as a Danfoss fix, until Danfoss publishes the package or an advisory.

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
| Refrigeration attacks begin | 2026-10-11; time unknown | Exposed Danfoss and Copeland controllers in Europe. Not attributed to these six flaws. [Midnight Blue][mb] |
| Research against 5.3.2 | by 2026-11-07 21:44:33 GMT | A lab request in the post is dated that evening. [Midnight Blue][mb] |
| **Public announcement** | **2026-11-12; time/TZ unknown** | Midnight Blue and the CCB. Six pre-authentication flaws, no CVE, no patch named. [Midnight Blue][mb] [CCB][ccb] |
| BSI names 5.4.0 | 2026-11-13; time/TZ unknown | Firmware through 5.3.2 affected. Package 5.4.0 from November 2026 is not. No known exploitation of these flaws. [BSI][bsi] |
| **Last updated** | **2026-11-13 (America/New_York)** | New item. Take the controller off the internet. |

## Detection

1. Read the software package version on the controller, or from the management software that inventories it. A package at or below **5.3.2** is inside the range Midnight Blue tested.
2. Check whether the management interface is reachable from the internet, including through a 4G or 5G modem. A modem is not a firewall. The CCB says a controller whose management port answers from the public internet is exposed.
3. Strict session control does not take the controller out of scope. Midnight Blue shows a crash in the session-control process with Strict mode on.

There is no CVE to match in a scanner, and neither Midnight Blue nor Danfoss publishes a log line for these flaws.

## Remediation

1. Remove the management interface from the public internet. Put remote access behind a VPN or a private network, as the CCB and BSI both say. IP allow-listing of a refrigeration provider is a stopgap, not the fix.
2. Do not treat an upgrade to 5.3.2, a password change, or Strict mode as the remedy. Midnight Blue found the six flaws in 5.3.2, and one of them is in the process that enforces Strict mode.
3. BSI says package **5.4.0** is not affected. Danfoss had not published that package, or an advisory naming it, when this was written. If Danfoss offers 5.4.0, install it and still keep the controller off the internet: the researcher says the codebase yields flaws of this kind quickly, and an implant can outlast a firmware update.
4. The AK-SM 800 and AK-SC 355 are older products, end of life, and are not these six flaws. Danfoss tells operators to replace them. This guide does not cover them.

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
- [BSI press release][bsi] — Bonn, 2026-11-13. Firmware through 5.3.2 is affected. Software package 5.4.0 from November 2026 is not. No known exploitation of these flaws. Recommends a VPN when remote maintenance is required.
- [Danfoss AK-SM 800A downloads][dl] — read 2026-11-13. The listed package is still 5.3.x, dated October 2026. No 5.4.0 package and no advisory for these six flaws.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10, checked 2026-11-13. Not applicable: no CVE is assigned.

[mb]: https://www.midnightblue.nl/blog/multiple-rce-danfoss-aksm800a
[ccb]: https://ccb.belgium.be/advisories/warning-six-new-danfoss-vulnerabilities-refrigeration-controllers-risk-immediate-action
[bsi]: https://www.bsi.bund.de/DE/Service-Navi/Presse/Pressemitteilungen/Presse2026/261113_Kuehlgeraete-Danfoss.html
[dl]: https://www.danfoss.com/en/service-and-support/downloads/dcs/adap-kool-software/ak-sm-800a
