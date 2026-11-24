# ManageEngine DDI Central: a DHCP option runs a command

**Last updated:** 2026-11-24 (America/New_York)

[Main summary](../black-october-2026.md#manageengine-ddi-central-a-dhcp-option-runs-a-command) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

DDI Central is ManageEngine's console for DNS, DHCP, and IP addresses. Build 6500, dated September 17, is not the current floor.

**ManageEngine rates [CVE-2026-131964](https://www.cve.org/CVERecord?id=CVE-2026-131964) Critical and publishes no numeric score.** The CVE.org record was still reserved when checked on 2026-11-24. DDI Central 6.5.0, build 6500, did not check authorization on DHCP option management. A low-privileged operator changes a DHCP option definition that every ISC DHCP cluster shares. ManageEngine says a crafted change can be written into the generated DHCP configuration and run a command on a managed ISC DHCP server. The fix, build **6501**, removes create, update, and delete from that screen. ManageEngine says the options are migrated at install, so the screen no longer needs those operations. The page says fixed on November 19, 2026, and names no clock time.

**[CVE-2026-130508](https://www.cve.org/CVERecord?id=CVE-2026-130508) is High, and ManageEngine publishes no numeric score for it either.** Its record was reserved on the same check. Build 6500 did not sanitize a DHCPv6 pool update for Cisco IOS. An operator who already has DHCP configuration rights on one cluster runs a Cisco IOS command on a device in that cluster. The command runs as the Cisco account DDI Central uses. Build 6501 rejects the characters. ManageEngine credits Tuan Anh 91 for both and does not report attacks.

Build 6500 fixed four earlier flaws, including [CVE-2026-95651](https://www.cve.org/CVERecord?id=CVE-2026-95651). ManageEngine calls that one Critical on the security-updates index and High on the CVE record, which scores it CVSS 3.1 7.5. It is not what this guide tracks. A console still below 6500 is inside those older flaws and inside these two.

**CISA KEV:** Not listed (catalog 2026.11.23, checked 2026-11-24) for CVE-2026-131964 or CVE-2026-130508. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Build 6500 | 2026-09-17; time/TZ unknown | Fixes the four 6500 CVEs. This build is the affected version for the two below. [Release notes][readme] |
| **Fix** | **2026-11-19; time/TZ unknown** | Both pages say fixed on November 19, 2026. Build 6501. [131964][a964] [130508][a508] |
| **Public pages** | **2026-11-24; time/TZ unknown** | Both advisories were on the security-updates index when read on this date. The index prints no publication time. The CVE.org records were still reserved. |
| **Last updated** | **2026-11-24 (America/New_York)** | New item. Move the console to 6501. |

## Detection

Read the build in the DDI Central console. Build 6500 is inside both. Anything below 6500 is inside the September flaws as well. A console that does not manage ISC DHCP is outside the condition ManageEngine names for CVE-2026-131964, and one that does not push Cisco IOS DHCPv6 pools is outside CVE-2026-130508. The build is still the check.

## Remediation

Update the DDI Central console to **build 6501 or later**. ManageEngine says customers who manage ISC DHCP servers, and customers who manage Cisco IOS DHCPv6, should install that build. The page does not say the service pack restarts the console. It does not say a node agent has to move for these two. The September flaws did: a console still below 6500 updates the console and the Linux Node Agent and Windows DDI Agent.

There is no workaround on the advisory. Removing DHCP rights from operators who should not have them reduces who can reach the screen, and it is not the fix.

## Verification

The console reports build 6501 or later. Do not send a DHCP option or a DHCPv6 pool update to test either flaw.

## Compromise response

ManageEngine does not report attacks and publishes no indicator. The update does not show whether an option definition was changed, or whether a Cisco IOS command already ran. If an operator account you do not trust could reach DHCP option management on build 6500, review the ISC DHCP configuration for an option you did not set, and review the Cisco devices in that cluster for a configuration change you did not make.

## Sources

- [ManageEngine, CVE-2026-131964][a964] — Critical. Build 6500 only. Fixed in build 6501 on November 19, 2026. No numeric score.
- [ManageEngine, CVE-2026-130508][a508] — High. The same build and the same fix date. Cisco IOS DHCPv6 pool updates.
- [DDI Central security updates][index] — the index that lists both above the September build 6500 rows.
- [DDI Central release notes][readme] — build 6500 is dated September 17, 2026. The page's newest section is still 6500 and does not mention 6501.
- [CVE-2026-131964](https://www.cve.org/CVERecord?id=CVE-2026-131964) and [CVE-2026-130508](https://www.cve.org/CVERecord?id=CVE-2026-130508) — both reserved when checked on 2026-11-24. A generated CVE.org link is not a published record.
- [CISA KEV JSON][kev] — catalog 2026.11.23, checked 2026-11-24. Neither is listed.

[a964]: https://www.manageengine.com/dns-dhcp-ipam/security-updates/cve-2026-131964.html
[a508]: https://www.manageengine.com/dns-dhcp-ipam/security-updates/cve-2026-130508.html
[index]: https://www.manageengine.com/dns-dhcp-ipam/security-updates/security-updates.html
[readme]: https://www.manageengine.com/dns-dhcp-ipam/readme.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
