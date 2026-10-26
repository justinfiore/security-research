# FortiMail: unauthenticated file write

**Last updated:** 2026-10-26 (America/New_York)

[Main FortiMail summary](../black-october-2026.md#fortimail-unauthenticated-file-write-cve-2026-104286) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-104286](https://www.cve.org/CVERecord?id=CVE-2026-104286) — Fortinet CVSS 3.1: 9.8 Critical (vendor temporal score 8.8); Fortinet severity: Critical; in CISA KEV.** A path traversal (CWE-22) combined with improper NULL-byte neutralization (CWE-158) lets an **unauthenticated** attacker write arbitrary files on the FortiMail appliance through crafted HTTP/HTTPS requests. Fortinet classifies the impact as "Execute unauthorized code or commands", and its workaround points at the **IBE (Identity-Based Encryption)** web feature reached through the webmail interface. Fortinet says the flaw was exploited before fixes shipped. NVD shows Fortinet's score as secondary and has not published its own CVSS score.

**CISA KEV:** Listed — added 2026-10-01, federal due date 2026-10-04. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and exposure](#inventory-and-exposure)
  - [Indicators published by Fortinet](#indicators-published-by-fortinet)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Fortinet says its Product Security team found the flaw internally (Gwendal Guégniaud) and lists the discovery as "Internal". No discovery date is given. [Advisory][fortinet] |
| Exploitation start | Unknown; before or by 2026-10-01 | At first publication, Fortinet said exploitation in the wild had been reported. No first-exploitation date was found. [Advisory][fortinet] |
| CVE reserved | 2026-10-01 19:12:54 UTC | CNA metadata. [CVE JSON][cve] |
| CVE record published | 2026-10-01 19:17:38 UTC | CNA metadata. NVD's published timestamp is 2026-10-01 20:17:24 (NVD API, UTC). [CVE JSON][cve] [NVD][nvd] |
| Fortinet public advisory FG-IR-26-175 | 2026-10-01; time/TZ unknown | Advisory timeline: "Initial publication". At that point Fortinet published workarounds and IoCs but no fixed builds. The CNA record still calls the fixes "upcoming", and secondary reports from October 2 (SecurityWeek, CERT-FR) say patches had not yet been released. [Advisory][fortinet] [CVE JSON][cve] [SecurityWeek][securityweek] |
| CISA KEV addition | 2026-10-01 (date only) | `dateAdded` 2026-10-01; due date 2026-10-04; forensic triage required under BOD 26-04: **Yes**; known ransomware use: Unknown. The KEV date is not when exploitation began. [KEV JSON][kev] |
| CISA ADP SSVC assessment | 2026-10-02 03:55:37 UTC | Exploitation: active; Automatable: yes; Technical impact: total. [CVE JSON][cve] |
| Fixed releases / solution update | 2026-10-05; time/TZ unknown | Advisory timeline: "Solution update". Fortinet says it fixed FortiMail Cloud on Oct 05 by moving all firmware to **7.6.7 GA or 8.0.2 GA**. The reviewed sources do not give the general-availability date of **7.4.9** for customer-managed units. [Advisory][fortinet] |
| FortiMail Cloud clarification | 2026-10-07; time/TZ unknown | Advisory timeline: "FortiMail Cloud fix clarification". CNA record updated 2026-10-07 17:59:34 UTC. [Advisory][fortinet] [CVE JSON][cve] |

## Detection

### Inventory and exposure

1. List every FortiMail appliance and VM, including HA members, and record each firmware build from the GUI dashboard or the read-only CLI command `get system status`. Run it from an administrator session on your own unit. It changes no state. It was not exercised on a real product for this guide.
2. Compare each build with Fortinet's advisory table:

   | Branch | Affected (Fortinet advisory) | Fixed |
   |---|---|---|
   | 8.0 | 8.0.0 through 8.0.1 | 8.0.2 or later |
   | 7.6 | 7.6.0 through 7.6.6 | 7.6.7 or later |
   | 7.4 | 7.4.0 through 7.4.8 | 7.4.9 or later |
   | 7.2 | 7.2.0 through 7.2.9 | No 7.2 fix; migrate to 7.4 or later |

   **Source inconsistency:** the CNA record's machine-readable `affected` list differs from the advisory and from its own description. It lists 8.0.0 only, 7.6.0–7.6.5, 7.4.0–7.4.6, and also **7.0.0–7.0.9**. Its `solutions` field names stale "upcoming" versions (8.0.1, 7.6.6, 7.4.8, 7.2.10) and unrelated FortiRecorder builds. NVD's configuration covers 7.2.0–7.4.8, 7.6.0–7.6.6, and 8.0.0–8.0.1. This guide follows the vendor advisory's table. Treat any **7.0.x** unit as **unknown, not cleared**, and ask Fortinet support.
3. Check whether IBE is enabled: GUI **Encryption → IBE → IBE Service**, or the read-only CLI `show system encryption ibe`. Also check whether the webmail/IBE web interface is reachable from the internet. If you cannot determine either, record the unit as exposed.

### Indicators published by Fortinet

Search retained FortiMail system-event and encryption logs, together with firewall, proxy, and WAF logs, for the following [Fortinet advisory][fortinet] indicators:

- Connections to or from `79[.]141.169.187` or `45[.]129.0.192`.
- A system event containing a cron command that runs `/bin/sh -c 'O=/migadmin ...` as root.
- A config event that adds an **archive account** such as `archive234`, with `destination[remote]`, `remote-ip[79.141.169.187]` and `remote-directory[/uploads]`. Any unexpected remote archive account warrants investigation because it can exfiltrate mail.
- An unexpected `User admin logged out from (null)` event.
- Encryption-log errors from `FortiMail::IBE::DecrypterMediaIn` containing `Invalid Base64 Encoding at pos 0. Character=0x2a`, or internal-user login failures for `*@domain.tld`.
- WAF or reverse-proxy logs showing POST requests to `/ibe` that contain `../` or encoded NUL bytes.

These indicators come from Fortinet's observed cases and are not exhaustive. A clean search does **not** prove the unit was not compromised, especially with short local log retention, log rotation, or attacker cleanup. Treat any unit that ran an affected build with internet-reachable webmail/IBE before patching or applying the workaround as a candidate for forensic triage. CISA's KEV entry requires forensic triage for federal agencies.

## Remediation

1. Upgrade to **8.0.2+, 7.6.7+ or 7.4.9+**. Move units on 7.2 to a fixed 7.4 or later build, following Fortinet's upgrade path and release notes. Download firmware only from Fortinet support. Back up the configuration first and expect a reboot.
2. Until you can upgrade, apply Fortinet's workaround: disable IBE (GUI **Encryption → IBE → IBE Service off**, or CLI `config system encryption ibe` / `set status disable` / `end`). This **changes state** and disables encrypted-mail pickup for recipients, so plan for the business impact. Fortinet's alternatives are to restrict webmail to trusted networks or to block, at a WAF, POST requests to `/ibe` that contain `../`.
3. FortiMail Cloud: Fortinet says no customer action is required after its 2026-10-05 update.
4. Mitigation and patching prevent new exploitation. Neither removes files, cron jobs, accounts, or archive destinations that an attacker already added. Preserve evidence before you upgrade or reboot a suspect unit.

## Verification

- Confirm that the running firmware version, from `get system status` or the dashboard, is at or above the fixed build on every node, including HA secondaries.
- If you rely on the workaround, confirm that `show system encryption ibe` shows the status as disabled, or that perimeter/WAF rules block internet access as intended. Then test normal mail flow and webmail from a trusted network.
- Do not send traversal or NUL-byte payloads to production systems to "test" the fix.

## Compromise response

- Preserve system-event, config, and encryption logs and a configuration backup before changes. Escalate to Fortinet support or an incident-response provider for appliance forensics. Root-level file writes can alter the system in ways that configuration review alone will not show.
- Remove unauthorized archive accounts, administrators, and cron entries only after evidence capture. If integrity cannot be established, rebuild or reimage the unit from trusted firmware and a reviewed configuration.
- Assume possible mail disclosure. Review archived and exfiltrated mail scope, rotate FortiMail admin credentials, LDAP/RADIUS bind credentials, SMTP relay credentials, and API keys stored on the unit, and replace TLS certificates and private keys held by the appliance if compromise is confirmed.
- Hunt downstream for lateral movement from the appliance's addresses into mail servers and directory services.

## Sources

- [Fortinet PSIRT FG-IR-26-175][fortinet] — affected and fixed versions, workaround, IoCs, internal discovery, timeline.
- [Fortinet CNA record][cve] — CVSS vector, publication metadata, inconsistent machine-readable ranges, CISA ADP SSVC.
- [NVD][nvd] — scoring attribution and configuration ranges.
- [CISA KEV JSON feed][kev] — dateAdded, dueDate, requiredAction, forensic-triage flag.
- [SecurityWeek (secondary)][securityweek] — October 2 report that patches had not yet been released.

[fortinet]: https://fortiguard.fortinet.com/psirt/FG-IR-26-175
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-104286
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-104286
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[securityweek]: https://www.securityweek.com/exploited-fortinet-fortimail-zero-day-calls-for-urgent-action
