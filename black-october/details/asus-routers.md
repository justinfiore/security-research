# ASUS routers: AiCloud root command from the LAN, and a nearby denial of service

**Last updated:** 2026-11-04 (America/New_York)

[Main ASUS summary](../black-october-2026.md#asus-routers-aicloud-root-command-from-the-lan) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Two November 4, 2026 bulletins cover ASUSWRT firmware. Neither names a firmware build number. Both say to install the latest firmware for the model.

**[CVE-2026-84730](https://www.cve.org/CVERecord?id=CVE-2026-84730): ASUS (CNA) CVSS 4.0 8.7 High** (`AV:A/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`). A stack-based buffer overflow in the AiCloud feature lets an unauthenticated attacker on an adjacent network run commands as root through a crafted device name. ASUS's bulletin says the same flaw can cause a denial of service or execute arbitrary code. The record names ASUSWRT **3.0.0.4_386**, **3.0.0.4_388**, and **3.0.0.6_102**. The vector is adjacent, not internet-facing. NVD has not scored it. [Bulletin][aicloud] [CVE record][cve-aicloud]

**[CVE-2026-84729](https://www.cve.org/CVERecord?id=CVE-2026-84729): ASUS (CNA) CVSS 4.0 7.2 High** (`AV:A/AC:L/AT:N/PR:N/UI:N/VC:N/VI:H/VA:H/SC:N/SI:N/SA:N`). An out-of-bounds write in a network service lets an unauthenticated nearby attacker write past the buffer or cause a denial of service with a crafted packet. The same three firmware series are affected. The bulletin's workaround is to turn off USB sharing and printer sharing you do not use. [Bulletin][firmware] [CVE record][cve-dos]

A third bulletin the same morning, [CVE-2026-112116](https://www.cve.org/CVERecord?id=CVE-2026-112116), is ASUS System Control Interface **3.1.66.0 through 3.1.69.0**, CVSS 4.0 8.5 High. That one is local: a low-privileged user on the PC can read and write physical memory through the driver. It is not a router flaw. Update it from MyASUS, the ASUS support site, or Windows Update. This guide does not track it further.

**CISA KEV:** Not listed (catalog 2026.11.03, checked 2026-11-04) for [CVE-2026-84730](https://www.cve.org/CVERecord?id=CVE-2026-84730) or [CVE-2026-84729](https://www.cve.org/CVERecord?id=CVE-2026-84729). ASUS does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| CVE records published | 2026-11-04 02:02:52 UTC (84730); same morning for 84729 | ASUS CNA. Both reserved 2026-09-02. [CVE-2026-84730][cve-aicloud] |
| AiCloud bulletin | 2026-11-04 09:35 UTC (17:35 +0800) | "Security Update for ASUS Router AiCloud Feature." No firmware build number. [Bulletin][aicloud] |
| Denial-of-service bulletin | 2026-11-04 03:00 UTC (11:00 +0800) | "Security Update for ASUS Router Firmware," CVE-2026-84729. [Bulletin][firmware] |

## Detection

1. On the router, read the firmware version. The affected series are **3.0.0.4_386**, **3.0.0.4_388**, and **3.0.0.6_102**. ASUS does not publish the build that contains the fix, so a version string inside those series is not proof of either state. Compare it with the current file on the model's support page.
2. AiCloud is the feature CVE-2026-84730 names. A router with AiCloud off is outside the path that bulletin describes. The denial-of-service flaw is a separate network service; turning AiCloud off does not close it.
3. Both flaws need an attacker on an adjacent network: the LAN or the wireless LAN. A guest network that can still reach the router is adjacent. Remote WAN access is a separate exposure the bulletin tells you to turn off; the CVE records do not say the flaws are reachable from the internet.
4. ASUS publishes no indicators. A crash of a network service, or a new device name you did not set, is a lead, not proof.

## Remediation

1. Install the latest firmware for that model from the ASUS support page or the model's product page, then reboot. ASUS does not print a build number in either bulletin. A firmware file for a different model is not the fix.
2. Until that firmware is running, turn **AiCloud** off. ASUS states that as the interim step for CVE-2026-84730. Also turn off USB sharing and printer sharing you do not use; that is the interim step for CVE-2026-84729.
3. Keep the web administration page off the WAN, and do not let untrusted devices onto the LAN or the wireless LAN. ASUS lists both. Neither replaces the firmware update.
4. The System Control Interface driver on a PC is a different product. Update it from MyASUS or Windows Update. A router firmware update does not change it.

## Verification

- The running firmware matches the current file on that model's ASUS support page, and the router was rebooted after the update.
- AiCloud, USB sharing, and printer sharing are off if you did not mean to leave them on.
- WAN remote administration is off, and a guest client cannot open the router's administration page.
- Do not send a crafted device name or an overlong packet to a production router.

## Compromise response

If the LAN was shared with untrusted devices while an affected build was running, preserve the configuration before you reset anything. Look for a changed administrator password, new port forwards, a changed DNS setting, and VPN or remote-access features you did not turn on. Updating the firmware closes the overflow ASUS describes. It does not show whether a command already ran, and it does not undo a setting an attacker changed. Treat a router that may have been reached as a foothold into the LAN behind it.

## Sources

- [AiCloud bulletin][aicloud] — 2026-11-04 09:35 UTC. CVE-2026-84730, CVSS 4.0 8.7. Adjacent, unauthenticated, denial of service or code execution. No firmware build number. Interim step is to disable AiCloud.
- [Router firmware bulletin][firmware] — 2026-11-04 03:00 UTC. CVE-2026-84729, CVSS 4.0 7.2. Adjacent denial of service. Interim step is to disable unused USB and printer sharing.
- [CVE-2026-84730][cve-aicloud] — ASUS CNA, published 2026-11-04. Root commands through a crafted device name. Series 3.0.0.4_386, 3.0.0.4_388, and 3.0.0.6_102.
- [CVE-2026-84729][cve-dos] — ASUS CNA, published 2026-11-04. Out-of-bounds write, denial of service. Same three series.
- [CVE-2026-112116][cve-sci] — ASUS System Control Interface 3.1.66.0 through 3.1.69.0, local, CVSS 4.0 8.5. Not a router flaw.
- [CISA KEV JSON feed][kev] — neither router CVE listed (catalog 2026.11.03, checked 2026-11-04).

[aicloud]: https://www.asus.com/security-advisory
[firmware]: https://www.asus.com/security-advisory
[cve-aicloud]: https://www.cve.org/CVERecord?id=CVE-2026-84730
[cve-dos]: https://www.cve.org/CVERecord?id=CVE-2026-84729
[cve-sci]: https://www.cve.org/CVERecord?id=CVE-2026-112116
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
