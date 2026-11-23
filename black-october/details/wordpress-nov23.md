# WordPress: Simple Shopping Cart and APCu Manager run code from a field

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-simple-shopping-cart-and-apcu-manager-run-code-from-a-field) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-22 Patchstack published two records. Patchstack is the CNA for both and rates each **CVSS 3.1 9.8 Critical**. The vector on both is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. NVD has not scored either. No source read for this entry reports exploitation.

[CVE-2026-131782](https://www.cve.org/CVERecord?id=CVE-2026-131782) is Simple Shopping Cart, plugin slug `wordpress-simple-paypal-shopping-cart`, by mra13 / Team Tips and Tricks HQ. Patchstack says a PHP object injection needs no login. Every version **through 5.3.3** is affected. **5.3.4** is the fix. Patchstack's page is dated 2026-11-20 and says it was reported on 2026-11-16.

[CVE-2026-131754](https://www.cve.org/CVERecord?id=CVE-2026-131754) is APCu Manager, plugin slug `apcu-manager`, by Pierre Lannoy. Patchstack says a PHP object injection needs no login. Every version **through 4.6.1** is affected. **4.7.0** is the fix. Patchstack's page is dated 2026-11-20 and says it was reported on 2026-11-17.

The two plugins are unrelated. Each record says "Deserialization of Untrusted Data" and names no function, no field, and no condition beyond the version. Patchstack's page says vulnerabilities of this kind are used in mass campaigns and that it expects exploitation. That is Patchstack's general wording for the priority, not a report that either flaw has been used.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-23) for either CVE. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Simple Shopping Cart reported | 2026-11-16; time/TZ unknown | Patchstack credits ytaero. [Patchstack][ssc] |
| APCu Manager reported | 2026-11-17; time/TZ unknown | Patchstack credits AndrewN. [Patchstack][apcu] |
| Patchstack pages | 2026-11-20; time/TZ unknown | Both pages are dated November 20. |
| **Public announcement** | **2026-11-22; time/TZ unknown** | Patchstack published both CVE records. Each is CVSS 3.1 9.8. |

## Detection

Read both plugins from the WordPress plugin list. Simple Shopping Cart's slug is `wordpress-simple-paypal-shopping-cart`; **5.3.3 and earlier** are inside the range. APCu Manager's slug is `apcu-manager`; **4.6.1 and earlier** are inside the range. A site that has neither plugin is outside both records. Reading the list changes no state.

## Remediation

1. Update Simple Shopping Cart to **5.3.4 or later**.
2. Update APCu Manager to **4.7.0 or later**.
3. Neither update shows whether a request already ran code.

## Verification

- Simple Shopping Cart is **5.3.4 or later**, or it is not installed.
- APCu Manager is **4.7.0 or later**, or it is not installed.
- Do not send a crafted request to test either one.

## Compromise response

No source read for this entry reports an incident. Where a version inside either range was reachable, review administrator accounts and plugin files added while it was installed. The update does not undo a request that already ran.

## Sources

- [CVE-2026-131782](https://www.cve.org/CVERecord?id=CVE-2026-131782) — Patchstack, published 2026-11-22. CVSS 3.1 9.8. Simple Shopping Cart through 5.3.3, fixed in 5.3.4.
- [Patchstack, Simple Shopping Cart][ssc] — dated 2026-11-20. Unauthenticated. Reported 2026-11-16 by ytaero.
- [CVE-2026-131754](https://www.cve.org/CVERecord?id=CVE-2026-131754) — Patchstack, published 2026-11-22. CVSS 3.1 9.8. APCu Manager through 4.6.1, fixed in 4.7.0.
- [Patchstack, APCu Manager][apcu] — dated 2026-11-20. Unauthenticated. Reported 2026-11-17 by AndrewN.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-23. Neither is listed.

[ssc]: https://patchstack.com/database/wordpress/plugin/wordpress-simple-paypal-shopping-cart/vulnerability/wordpress-simple-shopping-cart-plugin-5-3-3-php-object-injection-vulnerability?_s_id=cve
[apcu]: https://patchstack.com/database/wordpress/plugin/apcu-manager/vulnerability/wordpress-apcu-manager-plugin-4-6-1-php-object-injection-vulnerability?_s_id=cve
