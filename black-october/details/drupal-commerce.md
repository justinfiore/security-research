# Drupal Commerce Core: exploited access bypass

**Last updated:** 2026-10-30 (America/New_York)

[Main summary](../black-october-2026.md#drupal-commerce-core-exploited-access-bypass) · [Main TOC](../black-october-2026.md#table-of-contents)

**[CVE-2026-118539](https://www.cve.org/CVERecord?id=CVE-2026-118539): Drupal rates SA-CONTRIB-2026-254 Highly critical (21/25).** Commerce Core does not sufficiently protect certain routes and entity fields, permitting an access bypass that can financially affect vendors. Drupal reports active exploitation.

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). Drupal reports exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Public advisory and fixed releases | 2026-10-22; time/TZ unknown | Drupal SA-CONTRIB-2026-254. |
| **Last updated** | **2026-10-30 (America/New_York)** | Added from Drupal’s advisory. |

## Detection
From each Drupal project root, run `composer show drupal/commerce` and compare the installed branch and version. Affected releases are Commerce Core below 8.x-2.41 and 3.x from 3.0.0 through 3.1.x; the vendor advisory does not provide safe indicators beyond version and order review.

Review orders, refunds, discounts, customer-account changes and fulfilment records for inconsistencies around the exposure period. A clean review does not prove no exploitation.

## Remediation
Upgrade 3.x to **3.3.13** or an earlier branch to **8.x-2.41**, then deploy the updated Composer lock file through the ordinary Drupal release process. Test checkout and decoupled API paths before production rollout. Drupal explicitly recommends auditing orders because exploitation is active.

## Verification
Confirm every deployed artifact reports the fixed Commerce version, clear/rebuild caches as required by the deployment process, and run a benign checkout, payment and order-administration test. Do not simulate the access bypass.

## Compromise response
Preserve application, web and payment-provider logs; identify and reconcile suspicious orders before cancellation or fulfilment changes; review payment, refund and shipment events; and reset exposed administrator or integration credentials if unauthorized access is found.

## Sources
- [Drupal SA-CONTRIB-2026-254](https://www.drupal.org/sa-contrib-2026-254)
- [Commerce Core 3.3.13](https://www.drupal.org/project/commerce/releases/3.3.13)
- [Commerce Core 8.x-2.41](https://www.drupal.org/project/commerce/releases/8.x-2.41)
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json)
