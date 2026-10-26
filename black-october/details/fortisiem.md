# FortiSIEM: unauthenticated gRPC path traversal to remote code execution

**Last updated:** 2026-10-26 (America/New_York)

[Main FortiSIEM summary](../black-october-2026.md#fortisiem-unauthenticated-grpc-path-traversal-to-remote-code-execution) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-106173](https://www.cve.org/CVERecord?id=CVE-2026-106173) — Fortinet CVSS 3.1: 9.4 Critical (vector `AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H/E:H/RL:O/RC:C`); Fortinet severity: Critical.** A path traversal (CWE-22) in the **phQueryMaster** gRPC service lets an **unauthenticated** attacker who can reach **TCP 27918** write files on a FortiSIEM appliance. Fortinet classifies the impact as "Execute unauthorized code or commands". Horizon3.ai published a technical analysis and a working proof of concept on 2026-10-20. It shows how to overwrite a script that cron runs every 60 seconds, which turns the file write into command execution. Fortinet's advisory lists only **FortiSIEM 7.5.0** as affected. The Fortinet-assigned CVE record also lists **7.0.0 through 7.4.2** (see [the version discrepancy](#which-versions-are-affected)).

**Scoring attribution:** Fortinet's advisory and CNA record give 9.4 for a vector that includes temporal metrics (`E:H/RL:O/RC:C`). The record labels 9.4 the `baseScore`. However, the vector's base metrics alone score **9.8**, and 9.4 is what CVSS 3.1 yields after applying those temporal metrics (9.8 × 0.95 for `RL:O`, rounded up; this guide's calculation). NVD shows Fortinet as a secondary source with **9.8** for the base vector without temporal metrics. As of 2026-10-26, NVD has not published its own score (status "Awaiting Analysis"). CISA's ADP SSVC entry records Exploitation: poc, Automatable: yes, Technical impact: total.

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Canada's Cyber Centre said on 2026-10-23 that open-source reporting indicates [CVE-2026-106173](https://www.cve.org/CVERecord?id=CVE-2026-106173) is being exploited in the wild, while Fortinet's advisory still shows "Known Exploited: No". Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Which versions are affected](#which-versions-are-affected)
  - [Inventory and exposure](#inventory-and-exposure)
  - [Compromise indicators](#compromise-indicators)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Fortinet credits Gwendal Guégniaud of its Product Security team and lists discovery as "Internal". No date is given. [Advisory][fortinet] |
| CVE reserved | 2026-10-06 16:19:45 UTC | CNA metadata. [CVE JSON][cve] |
| Fortinet public advisory FG-IR-26-180 | 2026-10-13; time/TZ unknown | Advisory timeline: "Initial publication". It names 7.5.1 as the fix and restricting TCP 27918 as the workaround. The CSAF file gives `2026-10-13T00:00:00` without a timezone. [Advisory][fortinet] [CSAF][csaf] |
| CVE record published | 2026-10-13 17:37:09 UTC | CNA metadata. NVD's published timestamp is 2026-10-13 18:17:14 (NVD API, UTC). [CVE JSON][cve] [NVD][nvd] |
| Fixed release 7.5.1 | Named as the fix by 2026-10-13; release date not established | The reviewed sources do not give a general-availability date for 7.5.1. [Advisory][fortinet] |
| Canada Cyber Centre AV26-1037 | 2026-10-13 (date only) | Lists FortiSIEM "prior to 7.5.1" among several Fortinet products. [Cyber Centre][cccs] |
| Horizon3.ai analysis and public PoC | 2026-10-20 (date only) | Blog post by Zach Hanley and the PoC repository on GitHub. [Horizon3][horizon3] [PoC][h3poc] [The Hacker News][thn] |
| CISA ADP update to CVE record | 2026-10-21 03:56:09 UTC | Adds the Horizon3 GitHub repository as an "exploit" reference. The SSVC assessment itself carries timestamp 2026-10-13 and records Exploitation: poc. [CVE JSON][cve] |
| Cyber Security Agency of Singapore alert AL-2026-153 | 2026-10-22 (date only) | Says a PoC is public. It reports no exploitation. [CSA][csa] |
| Canada Cyber Centre AV26-1037 Update 1 | 2026-10-23 (date only) | "Open-source reporting indicates that CVE-2026-106173 is being exploited in the wild." The centre does not name the reporting or give indicators. [Cyber Centre][cccs] |
| Exploitation start | Unknown; reported by 2026-10-23 | Only the Cyber Centre's update reports exploitation. No vendor, honeypot or scanning-service report was found (see [Compromise indicators](#compromise-indicators)). |
| Fortinet advisory status | As checked 2026-10-26 | The advisory still shows only "Initial publication" and "Known Exploited: No". [Advisory][fortinet] |
| CISA KEV | Not listed; checked 2026-10-26 | Catalog 2026.10.23. [KEV JSON][kev] |

## Detection

### Which versions are affected

The vendor sources disagree:

| Source | Affected | Fixed / not affected |
|---|---|---|
| [Fortinet advisory FG-IR-26-180][fortinet] and [CSAF][csaf] | 7.5.0 only | 7.5.1 or later; 7.6 not affected; "FortiSIEM Cloud is NOT affected". No other branch is listed. |
| [Fortinet CNA record][cve], `affected` list (also shown by [NVD][nvd]) | 7.5.0, 7.4.0–7.4.2, 7.3.0–7.3.5, 7.2.0–7.2.7, 7.1.0–7.1.9, 7.0.0–7.0.4 | `solutions` text: "Upgrade to FortiSIEM version 7.6.0 or above", "7.5.1 or above", "upcoming FortiSIEMCloud version 25.4.1 or above" and "FortiSOC version 26.2.2 or above". |
| CNA record description | "FortiSIEM 7.5.0" | — |

The disagreement is not resolved by any reviewed source. Fortinet has not updated the advisory since publication. The CNA record conflicts with its own description, and its mention of FortiSIEMCloud and FortiSOC fixes conflicts with the advisory's statement that FortiSIEM Cloud is not affected. Horizon3's analysis does not state which versions it tested. This guide therefore treats **7.5.0 as affected**, and **7.0.x through 7.4.x as unknown, not cleared**, until Fortinet clarifies. Ask Fortinet support about any unit on those branches. If you use FortiSIEM Cloud or FortiSOC, ask Fortinet to confirm whether your tenant is affected and when it was updated.

### Inventory and exposure

1. List every FortiSIEM installation, including supervisors, workers, collectors, disaster-recovery and test systems. Record each node's exact version from the GUI or Fortinet's documented method for your release. Which node roles run phQueryMaster was not established from the reviewed sources, so check every node.
2. Compare each version with the [table above](#which-versions-are-affected).
3. Check whether TCP 27918 is reachable from anywhere other than your other FortiSIEM nodes. Horizon3 found that phQueryMaster binds `[::]:27918`, which means all interfaces. It uses TLS but does not request a client certificate, so any client that can connect can call the vulnerable method. If you have shell access to a node, the read-only command `ss -ltnp | grep 27918` shows whether the port is listening. It changes no state, and it was not exercised on a real FortiSIEM for this guide. Review firewall rules, cloud security groups and internal segmentation for the port. Which peers legitimately need TCP 27918 was not established from the reviewed sources, so confirm with Fortinet before blocking inter-node traffic.

Treat a node as exposed if you cannot establish who could reach TCP 27918 while it ran an affected or unknown version.

### Compromise indicators

Fortinet has published no IoCs for this CVE. Horizon3 [reports][horizon3] that it found **no application logs** that explicitly reveal exploitation. Its guidance is to inspect the modification timestamps of files an attacker is likely to overwrite and to look for any that do not match the surrounding files. It names two files:

- `/opt/charting/redishb.sh`, the Redis health-check script that cron runs every 60 seconds. Horizon3's PoC overwrites this file.
- `/opt/phoenix/bin/phLicenseTool`

On a node you control, `stat` and `ls -l --time-style=full-iso` on these files and their directories are read-only. Compare the results with files from the same release and with a clean installation of the same version, and inspect the script's contents. The following checks are based on Horizon3's description of the bug and are not published IoCs:

- Without the NUL-byte trick, writes land in files named `result-<src-ip>-<start>-<end>-<id>.dat` in a directory the attacker chooses. A file or directory with this pattern outside FortiSIEM's normal query-result location is suspicious. Fortinet has not documented that location for this CVE, so compare with a clean system.
- Firewall or flow logs showing inbound TCP 27918 connections from sources that are not FortiSIEM nodes. The traffic is TLS, so flow records show only that a connection happened, not what it carried.

These checks have limits. An overwrite keeps the file's original owner and permissions. An attacker with code execution can restore the original file or reset its timestamps. Only the two named files are covered, and other writable files that cron or services execute could be used instead. A clean result does **not** prove that a node was not compromised. Treat any node that ran an affected or unknown version with TCP 27918 reachable from untrusted networks as a candidate for forensic triage.

Exploitation evidence outside the Cyber Centre's statement: searches through 2026-10-26 found no Fortinet, honeypot, Shadowserver or other scanning-service report of attacks on this CVE. Secondary coverage, including [SecurityOnline][securityonline] and The Hacker News's update to its [article][thn], repeats the Cyber Centre's statement without adding a source.

## Remediation

1. **7.5.0:** Upgrade to **7.5.1 or later**, or to a 7.6 release, which Fortinet lists as not affected. Follow Fortinet's upgrade guide and release notes for your topology. Download firmware only from Fortinet support, back up the configuration first, and expect service interruption while nodes upgrade.
2. **7.0.x through 7.4.x:** Fortinet's advisory does not cover these branches, but the CNA record lists them as affected, and its only fixed versions are 7.5.1 and 7.6.0. Restrict TCP 27918 now. Then ask Fortinet support whether your version is affected and plan a supported upgrade to a fixed release.
3. **Workaround until upgraded:** Fortinet says "Restricting access on tcp port 27918 prevents the issue." Allow the port only from the FortiSIEM nodes that need it, and test collection, correlation and queries after the change, because a rule that blocks legitimate inter-node traffic can break them. Keeping the restriction after patching reduces exposure to future bugs in this service.
4. **FortiSIEM Cloud / FortiSOC:** Fortinet's advisory says FortiSIEM Cloud is not affected. The CNA record nevertheless names FortiSIEMCloud 25.4.1 and FortiSOC 26.2.2 as fixed versions. Get a tenant-specific answer from Fortinet.
5. Upgrading and restricting the port prevent new exploitation. They do not restore files that an attacker already overwrote. If a node may be compromised, preserve evidence before you upgrade or reboot it.

## Verification

- Confirm that every node reports 7.5.1 or later, or a 7.6 release, after the upgrade.
- From a host on an untrusted network segment that you are authorized to test from, confirm that a plain TCP connection to the node's port 27918 fails. For example, `nc -vz -w 3 <fortisiem-host> 27918` should not report success. This sends only a TCP handshake.
- Confirm normal operation: event ingestion, rule evaluation, searches and inter-node health.
- Do not run Horizon3's PoC or send traversal or NUL-byte metadata to production systems to "test" the fix. The PoC overwrites a system script.

## Compromise response

- Before changing anything, preserve the node's logs, cron configuration, the files named [above](#compromise-indicators) and a configuration backup. A disk or VM snapshot is better if you can take one. Escalate to Fortinet support or an incident-response provider for appliance forensics.
- If integrity cannot be established, rebuild the node from trusted Fortinet media on a fixed version and restore a reviewed configuration.
- A SIEM holds sensitive data. Assume possible disclosure of collected events and of the credentials FortiSIEM stores for discovering and polling monitored devices, and rotate them. Also rotate administrator credentials, API keys and integration secrets held on the node.
- Review whether detection rules, notification settings or stored events were changed, and hunt in other telemetry for lateral movement from the SIEM's addresses. An attacker in control of the SIEM can hide activity from it.

## Sources

- [Fortinet PSIRT FG-IR-26-180][fortinet] — affected and fixed versions, workaround, FortiSIEM Cloud statement, internal discovery, "Known Exploited: No", score and vector.
- [Fortinet CSAF for FG-IR-26-180][csaf] — machine-readable product status matching the advisory.
- [Fortinet CNA record][cve] — broader affected ranges, solution text, publication metadata, CISA ADP SSVC and exploit reference.
- [NVD][nvd] — scoring attribution and analysis status.
- [Horizon3.ai analysis][horizon3] and [PoC repository][h3poc] — root cause, TCP 27918 binding, exploitation chain, files to inspect.
- [Canadian Centre for Cyber Security AV26-1037][cccs] — Update 1 report of in-the-wild exploitation.
- [Cyber Security Agency of Singapore AL-2026-153][csa] — PoC availability.
- [CISA KEV JSON feed][kev] — catalog 2026.10.23, not listed.
- [The Hacker News (secondary)][thn] and [SecurityOnline (secondary)][securityonline] — coverage of the PoC and the Cyber Centre update.

[fortinet]: https://fortiguard.fortinet.com/psirt/FG-IR-26-180
[csaf]: https://fortiguard.fortinet.com/psirt/csaf/FG-IR-26-180?csaf_url=https://filestore.fortinet.com/fortiguard/psirt/csaf_arbitrary-file-write-in-grpc-phquerymaster_fg-ir-26-180.json
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-106173
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-106173
[horizon3]: https://horizon3.ai/attack-research/cve-2026-106173-deep-dive-fortisiem-grpc-path-traversal-file-write-rce/
[h3poc]: https://github.com/horizon3ai/CVE-2026-106173
[cccs]: https://www.cyber.gc.ca/en/alerts-advisories/fortinet-security-advisory-av26-1037
[csa]: https://www.csa.gov.sg/alerts-and-advisories/alerts/al-2026-153/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[thn]: https://thehackernews.com/2026/10/critical-fortisiem-flaw-gets-public.html
[securityonline]: https://securityonline.info/fortisiem-cve-2026-106173-exploited-poc/
