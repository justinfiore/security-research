# Fortinet FortiOS, FortiManager, FortiAnalyzer, FortiMail and FortiAuthenticator: October 2026 hardening release and SQL injection fixes

**Last updated:** 2026-10-26 (America/New_York)

[Main Fortinet October summary](../black-october-2026.md#fortinet-fortios-fortimanager-fortianalyzer-fortimail-and-fortiauthenticator-october-2026-hardening-release-and-sql-injection-fixes) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

This guide groups three related Fortinet October 2026 fix sets. They have different severities, affected versions and fixed builds, so check each one separately.

| Part | What it is | Severity and attribution | CVEs |
|---|---|---|---|
| **A. Security Hardening Release** | Undisclosed vulnerabilities in FortiOS, FortiManager, FortiAnalyzer, FortiMail and FortiAuthenticator, found through Fortinet's AI-assisted testing | Fortinet: the releases "include critical and high-severity fixes". No per-issue scores. ASD's ACSC: Alert Status **Critical**. | None published yet. Fortinet will publish advisories on **2026-11-10**. |
| **B. FG-IR-26-178** | SQL injection in FortiAnalyzer and FortiManager (on-prem and Cloud) letting a low-privileged user execute arbitrary commands; advisory title "Multiple Arbitrary File Read/Write via SQL Injection" | Fortinet advisory: **High, CVSSv3 7.9**. Per-CVE scores differ (below). | [CVE-2025-46773](https://www.cve.org/CVERecord?id=CVE-2025-46773), [CVE-2026-23705](https://www.cve.org/CVERecord?id=CVE-2026-23705), [CVE-2026-23706](https://www.cve.org/CVERecord?id=CVE-2026-23706), [CVE-2026-23707](https://www.cve.org/CVERecord?id=CVE-2026-23707) |
| **C. FG-IR-26-184** | SQL injection in FortiMail webmail letting an authenticated attacker execute unauthorized code or commands | Fortinet advisory: **High, CVSSv3 7.7** | [CVE-2025-57739](https://www.cve.org/CVERecord?id=CVE-2025-57739) |

**Per-CVE scores (all CVSS 3.1, Fortinet as CNA).** Fortinet's CNA scores include temporal metrics; NVD displays a Fortinet base-only vector as a secondary score. NVD has added no score of its own. [CNA records][cve-46773] [NVD][nvd-46773]

| CVE | Fortinet CNA score (with temporal metrics) | Fortinet base score shown by NVD | Privileges required |
|---|---|---|---|
| CVE-2025-46773 | 7.9 High (`E:P/RL:O/RC:C`) | 8.8 High | Low |
| CVE-2026-23705 | 6.5 Medium | 7.2 High | High |
| CVE-2026-23706 | 5.9 Medium (confidentiality only) | 6.5 Medium | Low |
| CVE-2026-23707 | 6.5 Medium | 7.2 High | High |
| CVE-2025-57739 | 7.7 High (`E:U/RL:O/RC:C`) | 8.8 High | Low |

**Worst case:** For part A, unknown until Fortinet publishes the advisories; Fortinet rates some fixes critical and warns that attackers can diff patches quickly. For part B, a low-privileged FortiAnalyzer or FortiManager user can execute commands and read or write files on a central management or logging system that holds device configurations and credentials. For part C, an authenticated webmail user can execute code or commands on the mail gateway.

**Out of scope here:** The exploited FortiMail file write is tracked in [fortimail.md](fortimail.md), FortiSandbox in [fortisandbox.md](fortisandbox.md) and FortiSIEM in [fortisiem.md](fortisiem.md). The FortiOS path traversal [CVE-2025-61624](https://www.cve.org/CVERecord?id=CVE-2025-61624) was added to KEV on 2026-10-16 after Unit 42 tied it to PEERSTITCH intrusions, but it is not admitted as an item because its scores are below High (Fortinet CNA 5.4 with temporal metrics, Fortinet base 6.0, NVD 6.5 Medium). Patch it with [FG-IR-26-122][fg122] anyway. [KEV JSON][kev] [Unit 42][unit42]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). None of [CVE-2025-46773](https://www.cve.org/CVERecord?id=CVE-2025-46773), [CVE-2026-23705](https://www.cve.org/CVERecord?id=CVE-2026-23705), [CVE-2026-23706](https://www.cve.org/CVERecord?id=CVE-2026-23706), [CVE-2026-23707](https://www.cve.org/CVERecord?id=CVE-2026-23707) or [CVE-2025-57739](https://www.cve.org/CVERecord?id=CVE-2025-57739) is listed, and the hardening-release fixes have no CVE yet, so KEV cannot list them. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and affected versions](#inventory-and-affected-versions)
  - [Exposure](#exposure)
  - [Log review (read-only)](#log-review-read-only)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | FG-IR-26-178 and FG-IR-26-184 were found internally (Fortinet Burnaby Infosec and Product Security teams). The hardening-release flaws came from Fortinet's frontier-AI-assisted testing. No discovery dates are published. [FG-IR-26-178][fg178] [FG-IR-26-184][fg184] [Fortinet blog][blog] |
| FG-IR-26-184 fixed FortiMail Cloud | 2026-Q1 (exact date not established) | "Fortinet in Q1/26 has remediated this issue in FortiMail Cloud". [FG-IR-26-184][fg184] |
| FG-IR-26-178 and FG-IR-26-184 published | 2026-10-13; time/TZ unknown | Advisory timelines: "Initial publication". Fixed releases are listed in both advisories; their release dates are not given. [FG-IR-26-178][fg178] [FG-IR-26-184][fg184] |
| CVE records published | 2026-10-13 17:37:11–17:37:14 UTC | CVE-2025-57739 17:37:11, CVE-2025-46773 17:37:14, CVE-2026-23705/23706/23707 17:37:14. NVD published each at 18:17 UTC. [CNA records][cve-46773] |
| CISA ADP SSVC | 2026-10-14 ~04:00 UTC | Exploitation: none for all five CVEs. [CNA records][cve-46773] |
| Hardening release announced; FortiMail and FortiAuthenticator fixes | 2026-10-21; time/TZ unknown | Fortinet CISO blog. The table marks FortiMail 8.0.2/7.6.7/7.4.9 and FortiAuthenticator 8.0.4/6.6.11 as available "Today". The same FortiMail build numbers were already the fixed builds in FG-IR-26-175 on 2026-10-05 (see [fortimail.md](fortimail.md)), so the exact first availability date of these builds is unclear. [Fortinet blog][blog] |
| FortiOS, FortiManager and FortiAnalyzer fixes | 2026-10-22; time/TZ unknown | Planned date in the blog. The FortiOS 7.6.8 release notes change log shows "2026-10-22 Initial release". FortiOS 8.0.2, FortiManager 7.6.8 and FortiAnalyzer 7.2.13 release-note pages exist; their dates were not individually confirmed here. [Fortinet blog][blog] [FortiOS 7.6.8 notes][fos768] |
| Canadian Cyber Centre AV26-1081 | 2026-10-23 | Lists the affected and fixed versions. [AV26-1081][cccs] |
| ASD's ACSC alert | 2026-10-23 | Alert Status Critical; ACSC is "currently not aware of active exploitation related to these vulnerabilities in Australia". [ACSC][acsc] |
| Hardening-release advisories and CVEs | Planned 2026-11-10 | Fortinet's next Patch Tuesday. [Fortinet blog][blog] |
| Exploitation evidence | None found | Fortinet lists "Known Exploited: No" on FG-IR-26-178 and FG-IR-26-184; no exploitation reports for parts A–C were found. |
| CISA KEV | Not listed (catalog 2026.10.23) | Checked 2026-10-26. [KEV JSON][kev] |

## Detection

### Inventory and affected versions

Find every FortiGate (FortiOS), FortiManager, FortiAnalyzer, FortiMail and FortiAuthenticator, including VMs, HA members, cloud marketplace instances and lab units. On FortiOS, FortiManager, FortiAnalyzer and FortiMail, the CLI command `get system status` shows the firmware version. Run it from an administrator session on your own unit; it only reads status. It was not exercised on a real product for this guide. For FortiAuthenticator, use the GUI dashboard or your asset inventory.

**A. Hardening release (Fortinet blog, 2026-10-21):** [Fortinet blog][blog]

| Product | Affected | Fixed |
|---|---|---|
| FortiOS | 8.0.0–8.0.1, 7.6.0–7.6.7, 7.4.0–7.4.12, 7.2.0–7.2.13 | 8.0.2, 7.6.8, 7.4.13, 7.2.14 |
| FortiManager | 8.0.0–8.0.1, 7.6.0–7.6.7, 7.4.0–7.4.11, 7.2.0–7.2.12 | 8.0.2, 7.6.8, 7.4.12, 7.2.13 |
| FortiAnalyzer | 8.0.0–8.0.1, 7.6.0–7.6.7, 7.4.0–7.4.11, 7.2.0–7.2.12 | 8.0.2, 7.6.8, 7.4.12, 7.2.13 |
| FortiMail | 8.0.0–8.0.1, 7.6.0–7.6.6, 7.4.0–7.4.8, 7.2.0–7.2.9 | 8.0.2, 7.6.7, 7.4.9; **7.2: move to 7.4 or later** |
| FortiAuthenticator | 8.0.0–8.0.3, 6.6.0–6.6.10 | 8.0.4, 6.6.11 |

Fortinet says FortiSASE is updated automatically, FortiManager Cloud updates may need a manual update, and public cloud images are being pushed through cloud partners. Older branches (for example FortiOS 7.0) are not listed in the blog; their status is **unknown**, not unaffected.

**B. FG-IR-26-178, FortiAnalyzer and FortiManager SQL injection:** [FG-IR-26-178][fg178]

| Product | Affected | Fixed |
|---|---|---|
| FortiAnalyzer 8.0 / FortiManager 8.0 | Not affected | — |
| FortiAnalyzer 7.6 / FortiManager 7.6 | 7.6.0–7.6.4 | 7.6.5 or above |
| FortiAnalyzer 7.4 | 7.4.0–7.4.7 | 7.4.8 or above |
| FortiManager 7.4 | 7.4.0–7.4.6 | 7.4.7 or above |
| FortiAnalyzer 7.2 / FortiManager 7.2 | All versions | **Migrate to a fixed release** |
| FortiAnalyzer Cloud | 7.6.2–7.6.4, 7.4.1–7.4.7, 7.2.1–7.2.11 | 7.6.5, 7.4.8, 7.2.12 |
| FortiManager Cloud | 7.6.2–7.6.4 (8.0, 7.4 and 7.2 not affected) | 7.6.5 |

The four CVE records do not match the advisory table exactly. CVE-2025-46773 names only FortiAnalyzer and FortiAnalyzer Cloud, references a different advisory ID (FG-IR-25-246, which could not be retrieved), and its machine-readable range includes FortiAnalyzer Cloud 7.2.12, which the advisory lists as fixed. CVE-2026-23705 lists FortiManager 7.2 through 7.2.13. Follow the advisory table and treat 7.2 as having no fix. [CNA records][cve-46773]

**C. FG-IR-26-184, FortiMail webmail SQL injection:** 7.6.0–7.6.3 (fix 7.6.4+), 7.4.0–7.4.5 (fix 7.4.6+), 7.2.0–7.2.8 (fix 7.2.9+). FortiMail 8.0 is not affected. FortiMail Cloud was remediated in 2026-Q1. [FG-IR-26-184][fg184]

### Exposure

- **Management interfaces:** Note which FortiGate administrative interfaces (HTTPS, SSH) and FortiManager/FortiAnalyzer GUIs are reachable from the internet or untrusted networks. Fortinet's interim advice focuses on these, which suggests (but does not confirm) that some hardening fixes concern management access.
- **Low-privileged accounts (part B):** List every FortiAnalyzer and FortiManager administrator account, including restricted profiles, API users and accounts for MSP or partner staff. CVE-2025-46773 and CVE-2026-23706 need only low privileges.
- **Webmail users (part C):** FortiMail webmail is reachable by ordinary mail users, so any user account or stolen mail credential is enough.

### Log review (read-only)

Fortinet has published **no IoCs** for these fixes. Review the following, preferably on exported logs or in your SIEM:

- FortiGate, FortiManager and FortiAnalyzer event logs for administrator logins from unexpected sources, new administrator accounts, and configuration changes nobody approved. Fortinet's blog asks customers to watch for "unusual administrative access or unapproved configuration changes before and after patching". [Fortinet blog][blog]
- FortiManager and FortiAnalyzer activity by low-privileged administrators that does not fit their role, such as unexpected file downloads or script runs.
- FortiMail webmail access from unexpected sources and accounts that log in to webmail but do not normally use it.

The command below only reads files and has not been run on a real product. Run it as any user that can read an exported log file; replace `EXPORTED_EVENT_LOGS` with your export and `ADMIN_SUBNET_PREFIX` with the start of your expected management network (for example `10.20.`). It lists login lines whose text does not contain that prefix, for manual review:

```sh
grep -i -n 'login' EXPORTED_EVENT_LOGS | grep -v -F 'ADMIN_SUBNET_PREFIX'
```

No matches does not prove a device is clean: the undisclosed flaws may not leave these traces.

## Remediation

1. **Upgrade to the hardening-release builds** for each product (table A), prioritizing internet-facing devices. Back up configurations first. Fortinet asks customers to treat this as a priority change, not routine maintenance. [Fortinet blog][blog]
2. **FortiManager and FortiAnalyzer 7.2:** the hardening release lists 7.2.13 as fixed, but FG-IR-26-178 says 7.2 has **no fix** and requires migration. To cover both, move to **7.4.12 or later** (FortiManager and FortiAnalyzer) or **7.6.8 or later**. On 7.4 and 7.6, the hardening builds (7.4.12, 7.6.8) are above the FG-IR-26-178 fixes (FortiManager 7.4.7, FortiAnalyzer 7.4.8, both 7.6.5). [FG-IR-26-178][fg178] [Fortinet blog][blog]
3. **FortiMail:** 8.0.2, 7.6.7 or 7.4.9 covers both the hardening release and FG-IR-26-184 (fixes 7.6.4, 7.4.6). FortiMail 7.2.9 fixes FG-IR-26-184 only; the hardening release has no 7.2 fix, so move to 7.4 or later. The same builds also fix the exploited file-write flaw in [fortimail.md](fortimail.md). [FG-IR-26-184][fg184] [Fortinet blog][blog]
4. **FortiAuthenticator:** 8.0.4 or 6.6.11.
5. **Until you can upgrade,** follow Fortinet's interim advice: restrict HTTPS and SSH administrative access to trusted IPs or disable it on external interfaces, keep FortiManager administration off the internet, manage devices out of band or behind VPN/SASE, use strong unique credentials and MFA for administrators. For part B, reduce and review low-privileged FortiManager/FortiAnalyzer accounts. These steps reduce risk but do not replace the upgrade. [Fortinet blog][blog] [ACSC][acsc]
6. **Watch for 2026-11-10.** Fortinet will publish the hardening-release advisories then. Re-check affected products, branches and any IoCs when they appear.

## Verification

- Confirm with `get system status` (read-only) or the GUI that each unit, including every HA member and standby, runs a fixed build, and that FortiManager-managed devices show the expected versions.
- Confirm administrative interfaces are reachable only from intended networks by attempting a TCP connection from an untrusted segment you control. Send no exploit payloads.
- Confirm normal operation after upgrading: FortiManager can still manage and push to its devices, FortiAnalyzer still receives logs, FortiMail delivers mail and webmail works, and FortiAuthenticator still authenticates users.

## Compromise response

- If you find unexpected administrator logins, new accounts or unapproved configuration changes, preserve configuration backups and logs before upgrading, and open a case with Fortinet TAC.
- On FortiManager or FortiAnalyzer, assume stored device credentials and configurations may be exposed if compromise is suspected. Rotate administrator passwords, API keys and any credentials stored for managed devices, and review policies pushed to managed FortiGates.
- On FortiMail, review mail routing, archive accounts and policies, and rotate administrator and LDAP/bind credentials.
- On FortiGate, compare the running configuration with a known-good backup, and review VPN users, local administrators and automation stitches. A device-level compromise (for example by the separately exploited CVE-2025-61624) may need Fortinet's guidance for memory-resident implants; upgrading alone may not remove persistence. [Unit 42][unit42]

## Sources

- [Fortinet: Security Hardening Release for Multiple Products (2026-10-21)][blog]: affected and fixed versions, availability, interim mitigations, 2026-11-10 advisory date.
- [FortiOS 7.6.8 release notes][fos768]: 2026-10-22 initial release.
- [FG-IR-26-178][fg178] and [FG-IR-26-184][fg184]: severity, scores, affected and fixed versions, discovery, "Known Exploited: No".
- CNA records: [CVE-2025-46773][cve-46773], [CVE-2026-23705][cve-23705], [CVE-2026-23706][cve-23706], [CVE-2026-23707][cve-23707], [CVE-2025-57739][cve-57739]; [NVD][nvd-46773] for Fortinet base scores and timestamps.
- [ASD's ACSC alert][acsc] and [Canadian Cyber Centre AV26-1081][cccs]: government notices.
- [CISA KEV JSON feed][kev]: none of the five CVEs listed; CVE-2025-61624 added 2026-10-16, due 2026-10-19.
- [Unit 42 PEERSTITCH report][unit42] and [FG-IR-26-122][fg122]: context for CVE-2025-61624.

[blog]: https://www.fortinet.com/blog/ciso-collective/fortinet-releases-security-hardening-release-for-multiple-products
[fos768]: https://docs.fortinet.com/document/fortigate/7.6.8/fortios-release-notes/4/change-log
[fg178]: https://fortiguard.fortinet.com/psirt/FG-IR-26-178
[fg184]: https://fortiguard.fortinet.com/psirt/FG-IR-26-184
[fg122]: https://fortiguard.fortinet.com/psirt/FG-IR-26-122
[cve-46773]: https://cveawg.mitre.org/api/cve/CVE-2025-46773
[cve-23705]: https://cveawg.mitre.org/api/cve/CVE-2026-23705
[cve-23706]: https://cveawg.mitre.org/api/cve/CVE-2026-23706
[cve-23707]: https://cveawg.mitre.org/api/cve/CVE-2026-23707
[cve-57739]: https://cveawg.mitre.org/api/cve/CVE-2025-57739
[nvd-46773]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2025-46773
[acsc]: https://www.cyber.gov.au/alert/critical-vulnerabilities-in-fortinet-products
[cccs]: https://www.cyber.gc.ca/en/alerts-advisories/fortinet-security-advisory-av26-1081
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[unit42]: https://unit42.paloaltonetworks.com/fortimanager-cve-2024-47575-peerstitch-malware
