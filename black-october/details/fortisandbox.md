# FortiSandbox: unauthenticated GUI authentication bypass

**Last updated:** 2026-10-26 (America/New_York)

[Main FortiSandbox summary](../black-october-2026.md#fortisandbox-unauthenticated-gui-authentication-bypass) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-107656](https://www.cve.org/CVERecord?id=CVE-2026-107656) (FG-IR-26-185, ZDI-26-771) — Fortinet CVSS 3.1: 9.6 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H/E:F/RL:O/RC:C); Fortinet severity: Critical; not in CISA KEV.** Fortinet describes an authentication bypass using an alternate path or channel (CWE-288) in the FortiSandbox **web GUI**. It says a **remote, unauthenticated** attacker can bypass authentication with crafted HTTP requests, and it classifies the impact as "Execute unauthorized code or commands". The flaw affects FortiSandbox appliances and VMs, and FortiSandbox PaaS. Fortinet's 9.6 score is the one it publishes with that vector. The vector's temporal metrics include `E:F` (functional exploit code exists), but the advisory also says "Known Exploited: No". NVD has not scored the CVE (status "Received"). It displays Fortinet's vector without the temporal metrics as a secondary score of **9.8 Critical**. The Zero Day Initiative, through which TrendAI researcher Jason McFadyen reported the flaw, scores it **CVSS 3.0 7.3 High** (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:L). ZDI describes the root cause as **hard-coded credentials** in the `login_user_profile` authentication mechanism. [Advisory][fortinet] [CNA][cve] [NVD][nvd] [ZDI][zdi]

**Worst case:** a remote, unauthenticated attacker who can reach the GUI gets administrative access to the sandbox and, according to Fortinet's impact classification, can execute unauthorized code or commands on it. FortiSandbox analyzes suspicious files submitted by other security products, so a compromised unit may also hide or alter verdicts for them. That consequence is an inference from the product's role, not a claim in the advisory. Exposure is highest when the GUI/administrative interface can be reached from the internet or from untrusted networks.

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Fortinet's advisory says "Known Exploited: No", CISA's ADP assessment in the CVE record says Exploitation "none", and no exploitation was reported in the reviewed sources through 2026-10-26; an unvetted GitHub repository created on 2026-10-25 claims to contain PoC and exploit code, but it was not reviewed or run for this guide. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and affected versions](#inventory-and-affected-versions)
  - [Exposure](#exposure)
  - [Log review](#log-review)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Fortinet internal date unknown; ZDI report to vendor 2026-06-19 (time/TZ unknown) | Fortinet lists the discovery as "Internal" and credits Adham El Karn of its Product Security team. It also thanks Jason McFadyen of TrendAI Research. ZDI's disclosure timeline says it reported the flaw to the vendor on 2026-06-19. [Advisory][fortinet] [ZDI][zdi] |
| FortiSandbox 5.0.7 released | 2026-08-10 (time/TZ unknown) | Change log in the 5.0.7 release notes: "Initial release". The release notes do not name CVE-2026-107656. Their GUI resolved-issues list includes bug 1210323, "Fixed an issue with improper session handling". This guide has not confirmed that bug 1210323 is this CVE. [5.0.7 change log][rn507] [5.0.7 resolved issues][ri507] |
| FortiSandbox 4.4.10 released | 2026-08-26 (time/TZ unknown) | Change log in the 4.4.10 release notes: "Initial release". The same bug 1210323 appears, and the CVE is not named. [4.4.10 change log][rn4410] [4.4.10 resolved issues][ri4410] |
| CVE reserved | 2026-10-08 14:34:01 UTC | CNA metadata. [CVE JSON][cve] |
| **Public announcement**: Fortinet advisory FG-IR-26-185 | 2026-10-13 (time/TZ unknown) | Advisory timeline: "Initial publication". The CSAF release date is `2026-10-13T00:00:00`, with no time zone. This guide treats that as a date only. [Advisory][fortinet] [CSAF][csaf] |
| ZDI advisory ZDI-26-771 | 2026-10-15 (time/TZ unknown) | "Coordinated public release of advisory", updated the same day. [ZDI][zdi] |
| Unvetted public exploit claim | 2026-10-25 18:34:17 UTC (repository creation) | GitHub repository `Ghost-Bx1/Fortinet-Exploits-CVE-2026-39808-106173-107656` claims PoC and exploit code for this CVE and two others. It was not reviewed or executed. Its README describes the bypass in generic terms that do not match ZDI's hard-coded-credentials root cause, and the README itself says no exploitation has been confirmed. Treat this repository as an unverified claim, not as proof of a working exploit or of attacks. |
| CVE record published | 2026-10-26 13:45:03 UTC | CNA (Fortinet) metadata, published 13 days after the advisory. NVD lists the record as published at 2026-10-26 14:16:24 (NVD API, UTC), status "Received". [CVE JSON][cve] [NVD][nvd] |
| CISA ADP SSVC assessment | 2026-10-26 14:42:58 UTC | Exploitation: none; Automatable: yes; Technical impact: total. [CVE JSON][cve] |
| CISA KEV | Not listed as of catalog 2026.10.23 (checked 2026-10-26) | [KEV JSON][kev] |

## Detection

### Inventory and affected versions

1. List every FortiSandbox appliance and VM, including cluster members, and every FortiSandbox PaaS instance. Record the firmware version from the GUI dashboard's System Information widget, or from the read-only CLI command `status`. Fortinet's CLI reference says that command shows the firmware version, serial number, and system status. Run it from an administrator session on your own unit. It changes no state. It was not exercised on a real product for this guide. [CLI reference][cli]
2. Compare each version with the sources below. **Fortinet's advisory and CSAF** list only these branches:

   | Product and branch | Affected (Fortinet advisory) | Fixed / action |
   |---|---|---|
   | FortiSandbox 5.2 | Not affected | None needed |
   | FortiSandbox 5.0 | 5.0.0 through 5.0.6 | 5.0.7 or later |
   | FortiSandbox 4.4 | 4.4.0 through 4.4.9 | 4.4.10 or later |
   | FortiSandbox PaaS 5.2 | Not affected | None needed |
   | FortiSandbox PaaS 5.0 | 5.0.0 through 5.0.6 | 5.0.7 or later |
   | FortiSandbox PaaS 4.4 | All versions | "Migrate to a fixed release" |

   **Source discrepancy, 4.2 branch:** the advisory and its CSAF file do not mention 4.2, either as affected or as not affected. Fortinet's own CNA record also comes from Fortinet, and NVD reproduces it. Its description says "FortiSandbox 4.2 all versions" and "FortiSandbox PaaS 4.2 all versions" are affected. Its machine-readable `affected` data lists **4.2.1 through 4.2.8** for both FortiSandbox and FortiSandbox PaaS, and its description lists PaaS 4.4 as "all versions". The machine-readable data does not list 4.2.0, even though the description says "all versions". The CNA record's `solutions` field lists only upgrades to **5.2.0+, 5.0.7+ or 4.4.10+** (PaaS: 5.0.7+). It names no 4.2 fix. Fortinet's documentation lists 4.2.8 as the latest 4.2 release. This guide therefore treats **every 4.2 unit, including 4.2.0, as affected with no fix on its branch**. Upgrade it to a fixed release. Confirm the supported upgrade path and the 4.2 position with Fortinet support. [CNA][cve] [CSAF][csaf] [4.2 documentation][doc42]
3. Units on branches that no source mentions, such as 4.0 or earlier, are **unknown, not cleared**. Move them to a supported, fixed release.
4. Version-based scanners can help with inventory. For example, Tenable's Nessus plugin 366094 flags 4.4.x before 4.4.10 and 5.0.x before 5.0.7, based on the version the product reports about itself. Tenable says the plugin does not test for the flaw itself, and its title does not cover 4.2. [Tenable][tenable]

### Exposure

- Determine which interfaces offer administrative GUI access (HTTP/HTTPS). By default that is port1, plus any port set with `set admin-port`. Check whether these interfaces are reachable from the internet or from untrusted internal segments. [CLI access][admin]
- Assume a unit is exposed if you cannot determine its reachability.

### Log review

Fortinet published **no indicators of compromise, request signatures or log patterns** for this CVE. ZDI names the `login_user_profile` authentication component but gives no request details. Without vendor indicators, look for evidence of unexpected administrative activity:

- In FortiSandbox event logs and any forwarded syslog/FortiAnalyzer copies, look for successful administrator logins from unfamiliar source IP addresses or at unusual times. Look especially for logins with no matching record in your identity provider or change system.
- Look for administrator accounts, profiles, trusted-host changes, API keys, or configuration changes that nobody can account for. Compare the current administrator list with a known-good backup.
- In firewall, reverse-proxy, or WAF logs, look for GUI access to the unit from sources outside the management network.

A clean review does **not** prove the unit was not accessed. There are no published indicators, logs on the appliance may be short-lived, and an attacker with administrative or command access can alter them. Treat any unit that ran an affected build with a reachable GUI as unknown until it has been reviewed.

## Remediation

1. Upgrade FortiSandbox to **5.0.7+** (5.0 branch) or **4.4.10+** (4.4 branch), or move to **5.2**, which Fortinet lists as not affected. Upgrade FortiSandbox PaaS 5.0 to **5.0.7+**. For PaaS 4.4, follow Fortinet's "migrate to a fixed release" instruction. Move 4.2 units (see the [discrepancy above](#inventory-and-affected-versions)) to a fixed release. Follow the upgrade path and cluster-upgrade steps in Fortinet's release notes, download firmware only from Fortinet support, back up the configuration first, and expect a reboot. [Advisory][fortinet] [4.4.10 release notes][rn4410]
2. Fortinet publishes **no workaround**, and its advisory lists "Virtual Patch: No". Until you can upgrade, general hardening reduces exposure. Use firewall rules or network segmentation so that only a management network can reach the administrative GUI, and disable HTTP/HTTPS administrative access on interfaces that do not need it. Fortinet's per-administrator trusted-hosts setting restricts where an administrator **login** is accepted from. Because this flaw bypasses authentication, do not assume that setting stops it; network-level restriction is the more reliable control. None of these measures is a vendor-validated fix for this CVE. [Administrators][admins] Changing interface access or trusted hosts **changes state** and can lock administrators out. Make sure you keep console or management-network access.
3. Patching prevents new exploitation through this flaw. It does not remove administrator accounts, configuration changes, or other footholds that an attacker may already have added. Preserve logs and a configuration backup before you upgrade or reboot a unit you suspect.
4. Separate FortiSandbox command-injection flaws [CVE-2026-39808](https://www.cve.org/CVERecord?id=CVE-2026-39808) (FG-IR-26-100) and [CVE-2026-25089](https://www.cve.org/CVERecord?id=CVE-2026-25089) (FG-IR-26-141) were added to CISA KEV on 2026-07-16, with forensic triage required. This guide does not track them. Check those advisories separately for units that were not updated after July. [KEV JSON][kev]

## Verification

- Confirm that the running firmware version, from `status` or the dashboard, is 5.0.7+, 4.4.10+ or 5.2.x on every node, including every cluster member and PaaS instance.
- Confirm from a host outside the management network that the administrative GUI cannot be reached where you restricted it, and from the management network that normal administrator login and file-submission flows still work.
- Do not send authentication-bypass or exploit requests to production units to "test" the fix, and do not run unvetted public exploit code.

## Compromise response

- If you find unexplained administrative activity, preserve event logs, forwarded syslog, and a configuration backup before you make changes. Escalate to Fortinet support or an incident-response provider for appliance forensics. Fortinet classifies the impact as code or command execution, and configuration review alone may not reveal changes at the operating-system level.
- Remove unauthorized administrators, API keys, and configuration changes only after you have captured evidence. If you cannot establish the unit's integrity, rebuild it from trusted firmware and a reviewed configuration.
- Rotate credentials that the unit stores or uses. These include administrator passwords, LDAP/RADIUS bind credentials, API keys and tokens for FortiGate, FortiMail, or other connected devices, and network-share credentials used for scanning.
- Review verdicts the unit issued while it may have been compromised. Re-scan files it cleared during that period with another engine, and hunt for lateral movement from the sandbox's addresses into connected security devices and file shares.

## Sources

- [Fortinet PSIRT FG-IR-26-185][fortinet] — affected and fixed versions, 5.2 not affected, CVSS score and vector, Known Exploited: No, Virtual Patch: No, credits, publication date.
- [Fortinet CSAF for FG-IR-26-185][csaf] — machine-readable affected and not-affected versions, and the release date.
- [Fortinet CNA record][cve] — description that includes 4.2, `affected` ranges 4.2.1–4.2.8, `solutions`, publication metadata, and CISA ADP SSVC.
- [NVD][nvd] — status "Received", and Fortinet's secondary score shown as 9.8.
- [ZDI-26-771][zdi] — ZDI CVSS 7.3, the hard-coded-credentials root cause, the `login_user_profile` component, and the 2026-06-19 report date.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.23), and the related FortiSandbox KEV entries.
- FortiSandbox release notes: [5.0.7 change log][rn507], [5.0.7 resolved issues][ri507], [4.4.10 change log][rn4410], [4.4.10 resolved issues][ri4410], and the [4.2 documentation index][doc42].
- [FortiSandbox CLI reference][cli], [CLI access page][admin] and [Administrators page][admins] — the `status` command, admin ports, and administrator trusted hosts.
- [Tenable Nessus plugin 366094][tenable] — version-based detection.
- [Cyber Security News (secondary), 2026-10-13][csn] — early report that repeats the advisory's details and its "Known Exploited: No" status.

[fortinet]: https://fortiguard.fortinet.com/psirt/FG-IR-26-185
[csaf]: https://filestore.fortinet.com/fortiguard/psirt/csaf_improper-access-control-and-session-management-in-the-web-management-interface_fg-ir-26-185.json
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-107656
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-107656
[zdi]: https://www.zerodayinitiative.com/advisories/ZDI-26-771
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[rn507]: https://docs.fortinet.com/document/fortisandbox/5.0.7/release-notes/860266/change-log
[ri507]: https://docs.fortinet.com/document/fortisandbox/5.0.7/release-notes/872228/resolved-issues
[rn4410]: https://docs.fortinet.com/document/fortisandbox/4.4.10/release-notes/860266/change-log
[ri4410]: https://docs.fortinet.com/document/fortisandbox/4.4.10/release-notes/872228/resolved-issues
[doc42]: https://docs.fortinet.com/product/fortisandbox/4.2
[cli]: https://docs.fortinet.com/document/fortisandbox/5.2.2/cli-reference/577541/system-commands
[admin]: https://docs.fortinet.com/document/fortisandbox/4.4.2/administration-guide/887264/cli
[admins]: https://docs.fortinet.com/document/fortisandbox/5.0.0/administration-guide/308655/administrators
[tenable]: https://www.tenable.com/plugins/nessus/366094
[csn]: https://cybersecuritynews.com/fortisandbox-gui-vulnerability/
