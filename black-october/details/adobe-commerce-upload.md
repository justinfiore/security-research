# Adobe Commerce / Magento Open Source dangerous-file upload: detection and remediation

**Last updated:** 2026-10-28 (America/New_York)

[Main summary](../black-october-2026.md#adobe-commerce--magento-open-source-exploited-dangerous-file-upload) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-48356](https://www.cve.org/CVERecord?id=CVE-2026-48356): Adobe CNA CVSS 3.1 9.3 Critical (AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:N); Adobe's APSB26-73 lists 9.6 Critical with a different vector.** It is an unrestricted dangerous-file-upload vulnerability distinct from the October BlockStrap vulnerabilities.

**CISA KEV:** Listed — added 2026-10-27, federal due date 2026-11-10. CISA listing means it has reliable evidence of active exploitation. Adobe's August 11 bulletin revision says it was not aware of exploits in the wild for any issue in APSB26-73; public sources reviewed here do not reconcile that later KEV listing with Adobe's earlier statement. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and evidence |
|---|---|
| Public announcement and fixed updates | 2026-07-14; Adobe APSB26-73. |
| Adobe bulletin last updated | 2026-08-11; still states no known exploitation for issues in the bulletin. |
| CISA KEV addition | 2026-10-27; federal civilian due date 2026-11-10. |

## Detection

Inventory every Adobe Commerce, Commerce B2B, Magento Open Source and Adobe Commerce Events deployment. On a trusted copy, record the installed metapackage and patch level from `composer.lock`; the relevant July update must be present for the specific product line. Include public storefronts, admin nodes, asynchronous workers and every container image.

Adobe has not published CVE-specific indicators of compromise. Treat unexpected uploaded executable or script files, recently modified web-root content, new administrator/integration accounts, and anomalous upload or admin logs as investigation leads, not proof of CVE-2026-48356 exploitation. A missing artifact does not establish safety.

## Remediation

Install the vendor's July 2026 fixed update for the deployed product:

- Adobe Commerce: 2.4.9/2.4.8/2.4.7/2.4.6/2.4.5/2.4.4 `-2026-jul`.
- Adobe Commerce B2B: 1.5.3/1.5.2/1.4.2/1.3.4/1.3.3 `-2026-jul`.
- Magento Open Source: 2.4.9/2.4.8/2.4.7/2.4.6 `-2026-jul`.
- Adobe Commerce Events: 1.21.0.

Use Adobe's supported release instructions and test normal storefront, checkout and upload workflows in staging before rollout. This July update does not replace the separate October BlockStrap patch sequence.

## Verification

- Confirm the deployed package or isolated update is the applicable July fixed version, not just the build artifact that received it.
- Restart PHP-FPM and background workers so no process retains old PHP code.
- Run benign staging controls for normal upload and checkout workflows; do not upload executable test payloads or reproduce malicious-page interactions.

## Compromise response

Because CISA lists this CVE as exploited, preserve application, web-server, PHP-FPM and audit logs before cleanup. Review uploaded files, administrator and integration accounts, cron entries, deployment history and payment-page code from a trusted copy. If compromise is suspected, rebuild from known-good artifacts and rotate credentials and API keys reachable by the Commerce process; patching alone cannot remove persistence or prove an earlier attack did not succeed.

## Sources

- [Adobe APSB26-73](https://www.adobe.com/trust/security/products/commerce/apsb26-73.html): affected/fixed versions, July release and Adobe's exploitation statement.
- [CVE-2026-48356 CNA record](https://www.cve.org/CVERecord?id=CVE-2026-48356): description, affected ranges and CNA CVSS attribution.
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json): listing date, due date and exploitation status.
