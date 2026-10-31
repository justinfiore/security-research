# Veeam Backup & Replication and Agent for Linux: authorization bypass and local privilege escalation

**Last updated:** 2026-10-30 (America/New_York)

[Main Veeam summary](../black-october-2026.md#veeam-backup--replication-and-agent-for-linux-authorization-bypass-and-local-privilege-escalation) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-108142](https://www.cve.org/CVERecord?id=CVE-2026-108142) — Veeam CVSS 4.0 9.1 Critical; [CVE-2026-105477](https://www.cve.org/CVERecord?id=CVE-2026-105477) — Veeam CVSS 4.0 7.3 High.** CVE-2026-108142 allows an unauthenticated attacker to bypass authorization on the CDP Coordinator Service in affected Windows-based Veeam Backup & Replication and Veeam Software Appliance deployments. CVE-2026-105477 allows a local privilege escalation only on Veeam Agent for Linux installations managed by Backup & Replication. The same bulletin also fixes [CVE-2026-108140](https://www.cve.org/CVERecord?id=CVE-2026-108140) and [CVE-2026-108141](https://www.cve.org/CVERecord?id=CVE-2026-108141), both Veeam/HackerOne CVSS 4.0 5.9 Medium: a Restore Operator who controls a NAS share can write files on the backup server through a relative path traversal. Those two are below this guide's High threshold and do not change the fixed builds.

**CISA KEV:** Not listed (catalog 2026.10.27, checked 2026-10-28) for either CVE. Veeam's bulletin does not report active exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | Veeam's bulletin identifies HackerOne as the report source but does not establish a private-report date. |
| Public bulletin and fixed releases | 2026-10-27; time/TZ unknown | Veeam published KB4948 with affected ranges and fixed builds. [Veeam KB4948][veeam] |

## Detection

1. Inventory Windows-based Veeam Backup & Replication and Veeam Software Appliance deployments, including isolated backup-management hosts. For CVE-2026-108142, treat 13.1 through **13.1.1.18** and 13.0 through **13.0.2.29** as affected. Veeam states 12.x is not affected.
2. Inventory Veeam Agent for Linux only where it is managed by a Backup & Replication instance. For CVE-2026-105477, treat 13.1 through **13.1.1.4** as affected; Veeam states 13.0.x and 6.x are not affected.
3. Confirm the running product build through trusted management inventory or the product's supported version reporting, not merely an installer already downloaded to a host. Missing inventory or an unsupported deployment is **unknown**, not safe.
4. Record which networks can reach Backup & Replication management services and which accounts have Restore Operator roles. The Medium path-traversal issues require a Restore Operator and an attacker-controlled NAS share; they affect 13.0 before 13.0.3 and 13.1 before 13.1.2, and Veeam states 12.x is not affected. The bulletin supplies no indicators of compromise and does not establish that any of these flaws has been exploited.

## Remediation

1. Update affected Backup & Replication and Veeam Software Appliance installations to **13.1.2 (build 13.1.2.57)** or **13.0.3 (build 13.0.3.63)**, following Veeam's supported maintenance procedure.
2. Update managed Veeam Agent for Linux installations to **13.1.2 (build 13.1.2.11)**.
3. Restrict Backup & Replication management access to trusted administrative networks during rollout. This reduces exposure to the unauthenticated CDP Coordinator authorization bypass but does not replace installing the fixed build.
4. Plan and validate the update through normal backup/change-management procedures. Ensure the management plane and protected backup/recovery workflows remain available; do not assume updating one server updates managed Linux agents.

## Verification

- Confirm each Backup & Replication or appliance deployment reports 13.1.2/13.0.3 or a later supported build, and each managed Linux agent reports 13.1.2 or later.
- Exercise a normal authorized backup and recovery workflow in the approved maintenance window. Verify management-service exposure remains limited to intended administrative networks.
- Do not attempt authorization bypass or privilege-escalation proof-of-concept requests against production systems.

## Compromise response

Preserve Backup & Replication audit logs, Windows event/process telemetry, service configuration, agent-management records and network-flow evidence before cleanup. Investigate unexpected authorization changes, backup-job modifications, recovery activity, administrative accounts and changes to protected data. Rotate credentials and rebuild affected systems where the investigation establishes compromise; patching prevents the documented flaws but cannot prove prior management-plane activity was benign.

## Sources

- [Veeam KB4948][veeam] — CVSS scores, affected deployment types, affected ranges and fixed builds.
- [CVE-2026-108142][cve108142] and [CVE-2026-105477][cve105477] — CVE records.
- [CISA KEV JSON feed][kev] — catalog 2026.10.27 status.

[veeam]: https://www.veeam.com/kb4948
[cve108142]: https://www.cve.org/CVERecord?id=CVE-2026-108142
[cve105477]: https://www.cve.org/CVERecord?id=CVE-2026-105477
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
