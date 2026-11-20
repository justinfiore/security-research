# Splunk: an empty secret runs a search before login

**Last updated:** 2026-11-19 (America/New_York)

[Main Splunk summary](../black-october-2026.md#splunk-an-empty-secret-runs-a-search-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-18 Splunk published three advisories. Splunk is the CNA. The highest scores are in Splunk Enterprise and Splunk SOAR, and both need a login only in the sense the product accepts an empty secret or a low-privileged role.

[SVD-2026-1103][ent] covers Splunk Enterprise. Splunk rates [CVE-2026-76536](https://www.cve.org/CVERecord?id=CVE-2026-76536) **CVSS 3.1 9.4 Critical**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:H/A:H`. On a standalone instance with clustering turned off, an empty clustering shared secret is accepted, and a request with no login can read and change the cluster configuration. [CVE-2026-76535](https://www.cve.org/CVERecord?id=CVE-2026-76535) is **9.1**: the same empty secret lets a request with no login run arbitrary searches through RapidDiag. The fixes are **10.6.1, 10.4.5, 10.2.9, 10.0.12, and 9.4.17**. CVE-2026-76536 is not in the 10.6 row. Until the upgrade, set a non-empty `pass4SymmKey` of at least 12 characters in the `[clustering]` stanza of `server.conf`, including on a standalone instance, and restart.

[SVD-2026-1108][soar] covers Splunk SOAR below **8.8.0**. Splunk rates [CVE-2026-131253](https://www.cve.org/CVERecord?id=CVE-2026-131253) **9.9 Critical**: a user with Apps edit, Containers edit, and Playbooks execute runs code through the App Wizard. The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`. [CVE-2026-131287](https://www.cve.org/CVERecord?id=CVE-2026-131287) is **9.6**: a user who can view, edit, run, and delete playbooks makes an existing cross-repository reference run attacker-controlled code. The fix is **8.8.0**. Splunk publishes no workaround for either.

[SVD-2026-1106][es] covers Splunk Enterprise Security and the PCI Compliance app below **8.7.0**. The highest is [CVE-2026-131202](https://www.cve.org/CVERecord?id=CVE-2026-131202) at **9.1**: an `ess_admin` user runs code on the search head through a lookup upload. That one needs a high-privileged role. The same advisory has High flaws that need less. Splunk does not report exploitation of any of the three advisories.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-19) for any CVE in the three advisories. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fixes** | **2026-11-18; time/TZ unknown** | SVD-2026-1103, SVD-2026-1106, and SVD-2026-1108. [Enterprise][ent] |

## Detection

Read the build from the product, not from a plan.

- Splunk Enterprise 10.6.0, 10.4.0 through 10.4.4, 10.2.0 through 10.2.8, 10.0.0 through 10.0.11, and 9.4.0 through 9.4.16 are inside CVE-2026-76535. CVE-2026-76536 stops one build earlier on the 10.6 line: 10.6 is not in that row.
- Splunk SOAR below 8.8.0 is inside the SOAR advisory.
- Splunk Enterprise Security below 8.7.0, and the PCI Compliance app below 8.7.0, are inside the Enterprise Security advisory.

A standalone Enterprise instance with an empty `[clustering]` `pass4SymmKey` is the configuration CVE-2026-76536 names. Finding a non-empty value does not show whether it was empty before the upgrade.

## Remediation

1. Upgrade Splunk Enterprise to **10.6.1, 10.4.5, 10.2.9, 10.0.12, or 9.4.17** or later, and restart.
2. If the upgrade waits, set `pass4SymmKey` under `[clustering]` in `server.conf` to a unique value of at least 12 characters, including on a standalone instance, and restart. Splunk names that for CVE-2026-76536. The same file, outside that stanza, is the mitigation Splunk names for the RapidDiag empty secret. Neither replaces the upgrade.
3. Upgrade Splunk SOAR to **8.8.0 or later**.
4. Upgrade Splunk Enterprise Security and the PCI Compliance app to **8.7.0 or later**.
5. Splunk Cloud is Splunk's to patch. These floors are the on-premises products the advisories name.

## Verification

- Enterprise reports one of the fixed builds, and the search head has restarted onto it.
- SOAR reports 8.8.0 or later. Enterprise Security reports 8.7.0 or later.
- A saved search still runs. Do not send an empty shared secret or a crafted playbook.

## Compromise response

Splunk does not report exploitation. A search head or a SOAR host that was below the floor should be reviewed for a clustering setting, a saved search, a playbook, or an app the owner did not add. The upgrade does not remove one. Rotate a credential that a search or a playbook could read.

## Sources

- [SVD-2026-1103][ent] — Splunk, published 2026-11-18. Highest CVSS 3.1 9.4. Enterprise floors 10.6.1, 10.4.5, 10.2.9, 10.0.12, and 9.4.17.
- [SVD-2026-1108][soar] — Splunk, published 2026-11-18. Highest 9.9. SOAR 8.8.0.
- [SVD-2026-1106][es] — Splunk, published 2026-11-18. Highest 9.1. Enterprise Security and PCI Compliance 8.7.0.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-19. None of these CVEs is listed.

[ent]: https://advisory.splunk.com/advisories/SVD-2026-1103
[soar]: https://advisory.splunk.com/advisories/SVD-2026-1108
[es]: https://advisory.splunk.com/advisories/SVD-2026-1106
