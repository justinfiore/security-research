# VeloCloud Orchestrator: authenticated SQL injection to superuser operator

**Last updated:** 2026-10-26 (America/New_York)

[Main VeloCloud summary](../black-october-2026.md#velocloud-orchestrator-authenticated-sql-injection-to-superuser-operator-cve-2026-114625) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**CVE-2026-114625: Arista CVSS 3.1 9.9 Critical (CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H); Arista CVSS 4.0 9.4 Critical (CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H). NVD has added no score of its own. Listed in CISA KEV on 2026-10-23, due 2026-10-26.** This is a SQL injection flaw (CWE-89) in **on-premises VeloCloud Orchestrator (VCO)**. **Any authenticated user**, down to the lowest built-in tenant role, *Enterprise Read Only*, can gain operator privileges, pose as a local "superuser operator", and reach internal-only functions that affect the VCO host. Arista detected the issue itself and says it is **actively exploited**. The orchestrator controls SD-WAN edges and gateways, so a compromise threatens the whole managed network. [Arista advisory][adv] [CNA][cve]

**SaaS vs on-premises:** Arista says that hosted VCO, **including Dedicated**, "were impacted and have already been patched". Hosted customers do not need to upgrade, but should still review tenant activity. **On-prem operators must upgrade.** VeloCloud Edge and Gateway are listed as **not affected**. [Arista advisory][adv]

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Discovery | Unknown date | "This issue was detected by Arista." Tracked as BUG2043622. [Arista advisory][adv] |
| Hosted and Dedicated VCO patched | Unknown; on or before 2026-10-22 | Stated in the advisory without a date. [Arista advisory][adv] |
| Exploitation begins | Unknown | Arista says the flaw is actively exploited and lists two attacking IPs. CISA's SSVC entry marks exploitation "active" as of 2026-10-22. [Arista advisory][adv] [CNA ADP][cve] |
| CVE ID reserved | 2026-10-21 20:35:35 UTC | CNA metadata. [CNA][cve] |
| Arista Security Advisory 0199 and on-prem fixed releases | 2026-10-22; time/TZ unknown | Revision 1.0, initial release. [Arista advisory][adv] |
| CVE record published | 2026-10-22 20:47:56 UTC | CNA metadata. NVD published 2026-10-22 21:17:16 UTC. [CNA][cve] [NVD][nvd] |
| CISA KEV addition | 2026-10-23 (date only) | Due **2026-10-26**. Forensic triage required under BOD 26-04: Yes. Ransomware use: Unknown. [KEV][kev] |
| Canadian Cyber Centre AV26-1080 | 2026-10-23 | Secondary government notice. [CCCS][cccs] |

## Detection

### Inventory

1. Identify every **on-prem VCO**, including lab, standby and disaster-recovery instances. Record the exact release from the VCO UI or your upgrade records.
2. Compare the release with the affected ranges. Arista says that if your release is not in the affected list, the deployment is not vulnerable. However, **end-of-support releases have not been assessed**, so treat them as unknown. [Arista advisory][adv]

| Train | Affected | Fixed |
|---|---|---|
| 5.2 | 5.2.x before 5.2.3.18 | **5.2.3.18** and later in 5.2 |
| 6.1 | 6.1.x before 6.1.3.10 | **6.1.3.10** and later in 6.1 |
| 6.4 | 6.4.x before 6.4.2.12 | **6.4.2.12** and later in 6.4 |

3. **Reachability:** Arista says VCO is exposed by default and "there is no configuration that can prevent the exposure". An attacker needs network access to the web UI and **any valid session**. Review who holds VCO accounts, including Enterprise Read Only users, partner and MSP users, and API tokens. Review where the UI can be reached from.

This is the third exploited VCO flaw listed in CISA KEV this year. The earlier ones are CVE-2026-16812 (KEV 2026-07-27, Advisory 0144) and CVE-2026-93952 (KEV 2026-09-22, Advisory 0183). [KEV][kev] The Hacker News reports that releases which fixed those earlier flaws are **still affected** by this one. Being patched for the July or September advisories does not clear CVE-2026-114625. Upgrade to the 0199 builds. [THN][thn]

### Log and IOC review (read-only)

Arista asks operators to review VCO web access logs for unusual URL-like path components, encoded characters, references to local or internal services, and high request rates. Block and search for the observed attacking IPs **74.82.197.86** and **38.54.50.151**. Monitor for unexpected outbound connections, backdoor daemons and webshells, and review recent administrator activity. [Arista advisory][adv]

The reviewed sources do not document where VCO keeps its web access logs. The command below takes a placeholder. Run it on the VCO host, or better, on an exported copy, as a user that can read the logs. Replace `VCO_LOG_PATHS` with your web and proxy access logs. It **only reads** files and has not been run on a real VCO.

```sh
grep -F -n -e '74.82.197.86' -e '38.54.50.151' VCO_LOG_PATHS
```

Also search firewall, NetFlow and SIEM data for the same IPs and for VCO outbound traffic to unexpected destinations. Two IPs do not make a complete IOC set, and the absence of matches does not prove the system was not exploited. A read-only tenant user who suddenly performs operator-level actions is a stronger signal.

## Remediation

1. **Upgrade on-prem VCO** to 5.2.3.18, 6.1.3.10 or 6.4.2.12 (or later on the same train) using Arista's supported upgrade procedure. Take a backup or snapshot first. If you run a release train that is not supported, **contact Arista TAC** for upgrade options. [Arista advisory][adv]
2. **Until you can upgrade,** limit the VCO web interface to trusted administrative networks. Block the two published IPs, watch for outbound traffic from the VCO and block outbound ports you do not need. Review administrator activity. These steps reduce risk but do not fix the flaw. Arista says no configuration prevents exposure, and any authenticated user can exploit it. [Arista advisory][adv]
3. **Preserve evidence before you upgrade** if you suspect compromise: VCO web access logs, backend application logs, system logs, database logs and file-system timestamps. [Arista advisory][adv]
4. CISA's due date (2026-10-26) and BOD 26-04 forensic-triage requirement apply to US federal agencies. Other organizations should still treat the flaw as urgent. [KEV][kev]

## Verification

- Confirm the running VCO release is a fixed build on its train, on every node including standby and disaster-recovery nodes.
- Confirm that edges and gateways still check in, and that normal configuration pushes work after the upgrade.
- Test the network restriction from an untrusted network segment you control, by attempting only a TCP connection to the UI. Do not send SQL injection payloads.

## Compromise response

- Treat the VCO host and its data as possibly compromised if it was on an affected release with low-privilege users and reachable UI access, especially if the published IPs or anomalous operator actions appear in the logs.
- Look for webshells, backdoor daemons, new operator or enterprise accounts, changed API tokens, and configuration changes pushed to edges and gateways. Examples include routing, firewall and VPN changes, and new or modified profiles.
- Rotate VCO local credentials, API tokens and any secrets the orchestrator stores or distributes. Review the edge activation and enrollment state.
- If you find a host-level compromise, rebuild the VCO from known-good media and restore configuration from a backup you have verified. Upgrading a compromised VCO does not remove persistence.
- Escalate to Arista TAC. Hosted customers should ask Arista about tenant-level activity during the window before the hosted patch.

## Sources

- [Arista Security Advisory 0199][adv]: scores, affected and fixed trains, required privileges, hosted status, IOCs, mitigations.
- [CVE record (Arista CNA)][cve] and [NVD][nvd]: timestamps and affected ranges.
- [CISA KEV feed][kev]: dateAdded 2026-10-23, due date 2026-10-26, earlier VCO KEV entries.
- Secondary: [The Hacker News][thn] (earlier fixes do not cover this flaw), [BleepingComputer][bc], [Canadian Cyber Centre AV26-1080][cccs].

[adv]: https://www.arista.com/en/support/advisories-notices/security-advisory/24838-security-advisory-0199
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-114625
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-114625
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[thn]: https://thehackernews.com/2026/10/arista-warns-of-critical-velocloud-sql.html
[bc]: https://www.bleepingcomputer.com/news/security/arista-patches-new-velocloud-orchestrator-zero-day-exploited-in-attacks/
[cccs]: https://www.cyber.gc.ca/en/alerts-advisories/arista-networks-security-advisory-av26-1080
