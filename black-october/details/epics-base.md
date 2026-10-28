# EPICS Base: network request handling can corrupt memory

**Last updated:** 2026-10-28 (America/New_York)

[Main EPICS Base summary](../black-october-2026.md#epics-base-network-request-handling-can-corrupt-memory) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-114595](https://www.cve.org/CVERecord?id=CVE-2026-114595) — CISA ICS-CERT (CNA) CVSS 3.1: 9.8 Critical; CVSS 4.0: 9.3 Critical.** In EPICS Base 7.0.10 and earlier, integer overflow during network-request processing can allocate an incorrectly sized buffer; subsequent handling of attacker-controlled data can corrupt memory, deny service, or potentially execute code. CISA's advisory covers related CVEs separately; this guide tracks the Critical CVE-2026-114595.

**CISA KEV:** Not listed (catalog 2026.10.27, checked 2026-10-28). CISA reports no known public exploitation specifically targeting these vulnerabilities at publication. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery/report | Unknown | CISA credits Shubham Raj of Cipher / Causal Security; no private-report date is established in the reviewed sources. [CVE record][cve] |
| Fixed release | 2026-10-27; time/TZ unknown | CISA and the CNA direct affected users to EPICS Base **7.0.11**. [CISA advisory][cisa] |
| Public announcement | 2026-10-27; time/TZ unknown | CISA published ICSA-26-300-01. [CISA advisory][cisa] |
| CVE record published | 2026-10-27 16:48:37 UTC | ICS-CERT CNA metadata. [CVE record][cve] |

## Detection

1. Inventory every control-system host, engineering workstation, container, and appliance that packages **EPICS Base**. Check both system packages and application/vendor bundles; one updated host does not establish the version deployed on controllers or isolated segments.
2. Record the exact EPICS Base release and compare it with **7.0.11**. Releases **7.0.10 and earlier** are affected by the CNA's stated range.
3. Determine whether EPICS network services are reachable from networks where untrusted systems can send requests. Preserve segmentation and firewall information as reachability evidence; a version check alone does not prove an attacker can reach the processing path.
4. Do not send malformed or oversized network requests to production control systems. Missing inventory, inaccessible devices, or unknown bundled versions mean **unknown**, not unaffected.

## Remediation

1. Upgrade affected EPICS Base deployments to **7.0.11** using the system owner's validated change-management path. CISA and the CNA identify that release as the update for affected users.
2. Before changing an operational technology environment, coordinate with process owners, validate dependencies and maintenance windows, and retain a tested rollback plan. A rushed control-system update can create safety and availability risks independent of this CVE.
3. Until the update is deployed, restrict EPICS network services to the intended control network, remove unnecessary routes from enterprise/user networks, and apply vendor/site-approved monitoring. Segmentation reduces exposure but is not a patch.

## Verification

- Confirm the deployed artifacts on each intended host report EPICS Base 7.0.11 or a vendor-supported backport explicitly identified as containing the fix.
- In a representative non-production environment, run ordinary approved control-system functions and verify expected process communication after the update.
- Confirm firewall and segmentation controls still permit required peers only. Do not exercise malformed network inputs or researcher proof-of-concept code against production.

## Compromise response

For suspected exploitation or unexpected control-system instability, prioritize operational safety: follow the site's incident and safety procedures, preserve controller/application logs and network captures where safe, and engage the equipment/vendor support path. Investigate unexpected process restarts, memory faults, configuration changes, and unauthorized network peers. Updating or segmenting the service cannot show whether previous memory corruption resulted in code execution; rebuild affected hosts from trusted artifacts where integrity is uncertain.

## Sources

- [CISA ICSA-26-300-01][cisa] — affected releases, impact, 7.0.11 remediation, and exploitation statement.
- [ICS-CERT CNA CVE record][cve] — CVSS 3.1/4.0 scores, affected range, exact publication time, and solution links.
- [CISA KEV JSON feed][kev] — catalog 2026.10.27 status.

[cisa]: https://www.cisa.gov/news-events/ics-advisories/icsa-26-300-01
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-114595
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
