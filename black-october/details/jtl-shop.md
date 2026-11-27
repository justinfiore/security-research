# JTL-Shop: the installer still runs after the shop is installed

**Last updated:** 2026-11-27 (America/New_York)

[Main JTL-Shop summary](../black-october-2026.md#jtl-shop-the-installer-still-runs-after-the-shop-is-installed) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

JTL published a security note for the Shop web installer, dated 2026-11-12, and the CVE record was published on 2026-11-19. JTL rates [CVE-2026-123058](https://www.cve.org/CVERecord?id=CVE-2026-123058) **Critical, CVSS 4.0 9.2** and **CVSS 3.1 9.0**. JTL's reference is SHOP-9985. JTL is the issuer of the score. The note says the installer keeps running its installation steps after the shop is already installed, and it is not removed or locked. A request with no login can use that to take the shop over.

JTL says the fix is in **Shop 5.8.4, 5.7.6, 5.6.6, and 5.5.5**. The note's table says **5.0.0 through 5.8.3** are affected where the `install/` directory is still present and reachable, and that **5.0.x through 5.4.x are affected, no longer maintained, and get no patch**. Those shops have to move to a supported line. The CVE record lists only the four supported lines. The note says JTL knows of no exploitation as of November 12, and that the update does not delete an existing `install/` directory. The note is in German. This guide follows the version table and the score in that note.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-27). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| JTL note | 2026-11-12; the page says modified 09:29:30 UTC | Version 1.0. Fixed in 5.8.4, 5.7.6, 5.6.6, and 5.5.5. [Note][note] |
| **CVE record** | **2026-11-19 12:18:39 UTC** | [CVE-2026-123058](https://www.cve.org/CVERecord?id=CVE-2026-123058). |

## Detection

Read the Shop version from the administration page. 5.0.0 through 5.8.3 are inside it where `install/` is still reachable. 5.0 through 5.4 get no patch. On the supported lines, a build below 5.8.4, 5.7.6, 5.6.6, or 5.5.5 is inside it. A missing directory is not proof the build is fixed.

## Remediation

1. Update Shop to **5.8.4, 5.7.6, 5.6.6, or 5.5.5** or later. A 5.0 through 5.4 shop has to move to one of those lines. The update does not delete an existing `install/` directory, so remove it after the update.
2. Until the update, remove or block the web installer. JTL's note is the instruction to follow for how the product expects that to be done. Blocking the path is not a substitute for the build.
3. The update does not show whether a request already reinstalled the shop or changed an administrator.

## Verification

- The administration page shows one of the fixed builds.
- The storefront still serves a page. Do not call the installer.

## Compromise response

JTL does not report exploitation in the text this guide could read. A shop that was reachable with the installer still present should be reviewed for an administrator, a configuration change, or a file the owner did not add. The update does not undo one.

## Sources

- [JTL note, web installer not locked][note] — version 1.0, published 2026-11-12. Critical, CVSS 4.0 9.2 and CVSS 3.1 9.0. Fixed in Shop 5.8.4, 5.7.6, 5.6.6, and 5.5.5. Reference SHOP-9985.
- [CVE-2026-123058](https://www.cve.org/CVERecord?id=CVE-2026-123058) — published 2026-11-19.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-19. Not listed.

[note]: https://www.jtl-software.com/de/security/sicherheitshinweis-web-installer_nicht_gesperrt/
