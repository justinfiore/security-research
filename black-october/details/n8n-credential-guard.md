# n8n: Execute Sub-workflow credential-guard bypass

**Last updated:** 2026-10-30 (America/New_York)

[Main summary](../black-october-2026.md#n8n-execute-sub-workflow-credential-guard-bypass) · [Main TOC](../black-october-2026.md#table-of-contents)

**[CVE-2026-118675](https://www.cve.org/CVERecord?id=CVE-2026-118675): VulnCheck CNA CVSS 3.1 7.1 High (CVSS 4.0 5.1 Medium).** An editor of a shared workflow can use URL- or local-file-loaded sub-workflows to resolve restricted project credentials and return their decrypted values.

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). No exploitation is reported by the reviewed CNA or vendor advisory. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents
- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline
| Event | Date and time (timezone) | Notes |
|---|---|---|
| Public advisory | 2026-10-28; time/TZ unknown | VulnCheck CNA record. |
| Fixed releases | 2026-10-28; time/TZ unknown | 1.123.85, 2.43.5 and 2.44.1. |

## Detection
Inventory every n8n deployment and worker image. Versions below 1.123.85, 2.43.5, or 2.44.1 are affected. Prioritize shared projects where workflow editors can configure Execute Sub-workflow nodes with `url` or `localFile` sources. Review workflow changes and access to restricted credentials; no log result proves no disclosure.

## Remediation
Upgrade to the fixed release for the deployed branch, restart every worker, and restrict workflow-editor permissions while rollout completes. Avoid treating a UI-only restriction as a substitute for the vendor fix.

## Verification
Confirm the version on each running image and perform normal approved workflow execution with a non-sensitive test credential. Do not attempt to retrieve credentials through a crafted sub-workflow.

## Compromise response
If untrusted editors could configure affected shared workflows, review workflow revisions and access logs, rotate potentially exposed project credentials, and investigate downstream services reached by those credentials.

## Sources
- [CVE record](https://www.cve.org/CVERecord?id=CVE-2026-118675)
- [n8n vendor advisory GHSA-8crx-5h96-q72q](https://github.com/n8n-io/n8n/security/advisories/GHSA-8crx-5h96-q72q)
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json)
