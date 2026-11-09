# WordPress plugins: Userplace administrator creation, and Productive Commerce SQL injection

**Last updated:** 2026-11-08 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-plugins-userplace-administrator-creation-and-productive-commerce-sql-injection) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Two plugins, two CVEs, published together. They are not [Frontend Admin](wordpress-plugins-frontend-admin.md), the [November 8 checkout set](wordpress-plugins-nov8.md), the [November 7 upload and role-deletion pair](wordpress-plugins-nov7.md), the [four plugins from November 6](wordpress-plugins-nov6.md), [LatePoint](wordpress-plugins-latepoint.md), or the [core upgrade-window](wordpress-upgrade-window.md) flaw. A site is affected only if that plugin is installed.

**[CVE-2026-110963](https://www.cve.org/CVERecord?id=CVE-2026-110963): WPScan rates Userplace through 1.2.0 CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. WPScan is the CNA. The CVE.org record, published 2026-11-08, does not print a score; the score is on the WPScan page. An AJAX action available to logged-out visitors does not check who is calling, and the nonce that is supposed to protect it is public. WPScan says that lets an unauthenticated attacker create an administrator account or write arbitrary site options. WPScan says there is **no known fix**. The WordPress.org directory, read 2026-11-09, still offers **1.2.0**, last updated five years ago, with 10+ active installs, and the zip it serves has `Version: 1.2.0` in the plugin header. The proof of concept is withheld until 2027-02-04.

**[CVE-2026-109925](https://www.cve.org/CVERecord?id=CVE-2026-109925): WPScan rates Productive Commerce before 1.1.54 CVSS 3.1 8.6 High.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:N/A:N`. WPScan is the CNA. The CVE.org record does not print a score. A parameter is used in a SQL statement without being escaped, on the wishlist and compare handlers, and the caller does not need to log in. Confidentiality is High and integrity is None, which is why this one is 8.6 rather than 9.8. Patchstack scores the same flaw 9.3 and calls it High priority; both scores stay. WPScan says the fix is **1.1.54**. The 1.1.54 changelog, dated 2026-11-04, says "Addressed SQL vulnerability when deleting user wishlisted and Comparison products." The directory API and the 1.1.54 zip, read 2026-11-09, both report version 1.1.54 and stable tag 1.1.54. The public plugin page still displays 1.1.44. The proof of concept is withheld until 2026-12-06. Active installs are about 30 to 40.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-09) for either CVE. WPScan does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Productive Commerce 1.1.54 | 2026-11-04 16:12 GMT | Changelog: "Addressed SQL vulnerability when deleting user wishlisted and Comparison products." [Directory API][api-pc] |
| WPScan pages | 2026-11-06; time/TZ unknown | Both publicly published. Last updated 2026-11-07. [Userplace][wps-up], [Productive Commerce][wps-pc] |
| **Public CVE records** | **2026-11-08 06:17 UTC** | WPScan CNA. Neither record prints a CVSS score. [CVE-2026-110963][cve-up], [CVE-2026-109925][cve-pc] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-09) | [KEV][kev] |

## Detection

On a trusted copy of the site, read the installed versions. Do not run this on a host you suspect is compromised; read the files from a snapshot instead.

```sh
wp plugin list --fields=name,status,version --format=csv
```

If WP-CLI is not available, read the `Version:` line in each plugin's main file.

| Plugin | Slug | Affected | Fixed |
|---|---|---|---|
| Userplace – Member Subscription, Restriction & Payments | `userplace-member-subscription-restriction-payments` | through 1.2.0, which is the current directory version | No known fix |
| Productive Commerce | `productive-commerce` | before 1.1.54 | 1.1.54 or later |

A plugin that is installed and inactive can still be reachable if its code loads. A site without that plugin is outside this entry. The public Productive Commerce page still displays 1.1.44; the version in the installed plugin header, or `wp plugin get`, is the one to trust.

## Remediation

1. **Remove Userplace.** WPScan says there is no known fix, and the directory still ships 1.2.0. Deleting the plugin does not remove an administrator account or a site option already written.
2. Update Productive Commerce to **1.1.54 or later**. The directory API on 2026-11-09 reports 1.1.54. The update does not undo a SQL statement that already ran.
3. Neither page lists a configuration workaround. Taking the site offline is a containment step, not a fix.

## Verification

- `wp plugin get userplace-member-subscription-restriction-payments` reports that the plugin is not installed.
- `wp plugin get productive-commerce --field=version` prints 1.1.54 or later, or reports that the plugin is not installed.
- Load the site's front page and the wishlist and compare pages. Do not send the requests the advisories describe.

## Compromise response

No source publishes an indicator or a confirmed compromise. WPScan withholds both proofs of concept.

- On a site that had Userplace installed, look for an administrator account you do not recognize, and for a site option that changed without an administrator doing it. Removing the plugin does not delete that account.
- On a site that had Productive Commerce before 1.1.54, the flaw reads the database. It does not, on WPScan's score, write it. Look for unexpected queries in the database log if you have one. No matching log line is not proof the site was safe.

## Sources

- [WPScan, Userplace][wps-up] — CVE-2026-110963, CVSS 3.1 9.8 Critical, through 1.2.0, no known fix. Publicly published 2026-11-06, last updated 2026-11-07. Researcher Naoki Kawahigashi. Proof of concept withheld until 2027-02-04.
- [CVE-2026-110963][cve-up] — WPScan CNA, published 2026-11-08. The record does not print a CVSS score. Affected from 0 through 1.2.0.
- [Userplace on WordPress.org](https://wordpress.org/plugins/userplace-member-subscription-restriction-payments/) — version 1.2.0, last updated five years ago, 10+ active installs. Read 2026-11-09. The directory zip's plugin header is `Version: 1.2.0`.
- [WPScan, Productive Commerce][wps-pc] — CVE-2026-109925, CVSS 3.1 8.6 High, before 1.1.54, fixed in 1.1.54. Publicly published 2026-11-06, last updated 2026-11-07. Proof of concept withheld until 2026-12-06.
- [CVE-2026-109925][cve-pc] — WPScan CNA, published 2026-11-08. The record does not print a CVSS score. Affected from 0 before 1.1.54.
- [Patchstack, Productive Commerce](https://patchstack.com/database/wordpress/plugin/productive-commerce/vulnerability/wordpress-productive-commerce-plugin-1-1-54-unauthenticated-sqli-vulnerability) — scores the same flaw 9.3, High priority, patched in 1.1.54. Published 2026-11-08.
- [Productive Commerce directory API][api-pc] — version 1.1.54, last updated 2026-11-04 16:12 GMT, about 30 active installs. The 1.1.54 changelog names the SQL fix. The public plugin page still displays 1.1.44. Read 2026-11-09.
- [CISA KEV JSON][kev] — catalog 2026.11.06. Neither CVE is listed.

[wps-up]: https://wpscan.com/vulnerability/c30f71d3-2ec4-4bee-8864-f7c19cf6fcb7/
[wps-pc]: https://wpscan.com/vulnerability/4f6cf8d4-4c76-4cfe-be5c-030fa86e6926/
[cve-up]: https://www.cve.org/CVERecord?id=CVE-2026-110963
[cve-pc]: https://www.cve.org/CVERecord?id=CVE-2026-109925
[api-pc]: https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&request%5Bslug%5D=productive-commerce
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
