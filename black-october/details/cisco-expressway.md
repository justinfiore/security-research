# Cisco Expressway: a cluster cookie runs commands as root

**Last updated:** 2026-11-20 (America/New_York)

[Main Expressway summary](../black-october-2026.md#cisco-expressway-a-cluster-cookie-runs-commands-as-root) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Cisco Expressway is the gateway that lets remote users reach an organization's video, voice, and messaging. Expressway Core (Expressway-C) sits inside. Expressway Edge (Expressway-E) sits at the edge. Both the appliance and the virtual machine are in scope, and only when the devices are in a cluster.

Cisco rates [CVE-2026-76466](https://www.cve.org/CVERecord?id=CVE-2026-76466) **Critical, CVSS 3.1 9.8**. Cisco is the CNA. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. The database service uses persistent cookies, and when clustering has **TLS Verify Mode** set to **Enabled** the device does not check the client certificate. Someone who has the cookies can connect to that service and run commands as root. Cisco says there is no workaround. The fix is **X15.5.20**. X14 and earlier have to move to a fixed release.

Cisco's advisory is still version 1.0, dated October 21, and still says the PSIRT is not aware of any public announcement or malicious use. That sentence is now behind the reports. A proof of concept is public. F6 says it investigated an attack on a company in Russia: two internet-facing Expressway **X15.5.3** devices were taken, and one of them was used to reach two more nodes of the same cluster on the internal network. After root, the attackers wrote Python scripts to scan the network, look for SMB shares, talk to SQL Server and WinRM, and search GitLab repositories. F6 says the scripts were edited during the attack and that the comments look like an AI assistant wrote them. F6 does not name the company or a threat actor. SecurityWeek's November 19 account of the same report says Cisco had not revised the advisory.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-20). F6's report is the exploitation evidence, and it is not a KEV listing. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-10-21 16:00 GMT** | Advisory version 1.0. Fixed in X15.5.20. [Cisco][cisco] |
| F6 investigation published | 2026-11-18; time/TZ unknown | F6 says this is the first exploitation it has seen. Two X15.5.3 devices, then two internal cluster nodes. [F6][f6] |
| SecurityWeek account | 2026-11-19 08:12 ET | Says the advisory still denies public announcements and malicious use, and that a proof of concept is on GitHub. [SecurityWeek][sw] |
| **Last updated** | **2026-11-20 (America/New_York)** | New item. Upgrade a clustered Expressway. |

## Detection

Read the release from the Expressway administration page, not from a purchase order. A device in a cluster on **X15.5.3 or earlier**, or on **X14 or earlier**, is inside the flaw. A device that is not in a cluster is outside the condition Cisco names. X15.5.20 or later is the build Cisco names.

F6's indicator is a line in the Erlang system log (`erlang.log`):

```text
nodeup,'wombat@127.0.0.1'
```

F6 says that line is a connection to an Erlang node whose name matches the known way this flaw is used. It is a lead. It is not, by itself, proof of what the attacker did next.

F6 also published two addresses and a path pattern from the attack it investigated:

- `66.179.31.32`
- `18.130.47.116`
- `/mnt/harddisk/i{0-9}{4}[a-zA-Z]?/*.py`

Those three belong to that investigation. A device that never logged them can still have been reached. Defanging the addresses is the right way to write them in a ticket; the log itself will have the dots.

## Remediation

| Release | What Cisco says | Source |
|---|---|---|
| X15.5.3 and earlier | First fixed release is **X15.5.20** | [Cisco][cisco] |
| X14 and earlier | No fix on that train. Move to a fixed release. | [Cisco][cisco] |
| Not in a cluster | Cisco says the flaw needs a cluster. | [Cisco][cisco] |

1. Upgrade every clustered Expressway-C and Expressway-E, appliance and virtual, to **X15.5.20 or later**. Cisco says the same fix is part of the October 2026 hardening release.
2. Cisco publishes no workaround. F6 says that if the upgrade has to wait, block TCP **4371** and **4372** at the firewall except from the addresses of the cluster nodes you trust. That is a reduction, and it is not Cisco's fix. A node you already trust is the path the attack F6 saw used to reach the inside of the cluster.
3. The upgrade does not remove a script already written under `/mnt/harddisk`, and it does not undo a command that already ran as root.

## Verification

- The administration page reports X15.5.20 or later on every node in the cluster, and each node was restarted onto that build.
- Calls and messaging between the nodes still work after the upgrade.
- Do not connect to the database service with the published cookies to test the flaw.

## Compromise response

Cisco's advisory still says the PSIRT knows of no malicious use. F6's report says otherwise for one organization. Treat a clustered Expressway that was on X15.5.3 or earlier, and reachable, as a host that may have run commands as root.

Start with `erlang.log` and the `nodeup,'wombat@127.0.0.1'` line, then look for Python files under `/mnt/harddisk` matching the path F6 published. Those scripts, in the attack F6 investigated, scanned the network, opened SMB shares, talked to SQL Server and WinRM, and searched GitLab. A credential those scripts could read should be rotated. The upgrade does not do that, and it does not end a session that was already opened inside the network.

## Sources

- [cisco-sa-vcs-static-cred-hr7EWZ8t][cisco] — Cisco PSIRT, version 1.0, first published 2026-10-21 16:00 GMT. Critical, CVSS 3.1 9.8. Clustered Expressway-C and Expressway-E. Fixed in X15.5.20. X14 and earlier migrate. No workaround. The exploitation section still says no public announcement and no malicious use known to Cisco. Reported by Stefan Aleksic of Jane Street.
- [F6 press release][f6] — dated 2026-11-18. Says a company in Russia was attacked on X15.5.3 shortly after a public proof of concept, that two internet-facing devices led to two internal cluster nodes, and that Python scripts were prepared for lateral movement. Names the Erlang log line, two IP addresses, and a path pattern.
- [SecurityWeek][sw] — Eduard Kovacs, 2026-11-19 08:12 ET. Reports the same F6 investigation and says Cisco's advisory had not been revised. Links a public proof of concept.
- [CVE-2026-76466](https://www.cve.org/CVERecord?id=CVE-2026-76466) — Cisco, published 2026-10-21. CVSS 3.1 9.8.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-20. CVE-2026-76466 is not listed.

[cisco]: https://sec.cloudapps.cisco.com/security/center/content/CiscoSecurityAdvisory/cisco-sa-vcs-static-cred-hr7EWZ8t
[f6]: https://www.f6.ru/media-center/press-releases/cisco-cve-2026-76466/
[sw]: https://www.securityweek.com/hackers-exploit-cisco-expressway-vulnerability-soon-after-poc-release/
