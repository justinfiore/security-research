# WordPress plugins: Contact Form 7 file upload, Ecommerce Affiliate account takeover, and Turisbook stored XSS

**Last updated:** 2026-11-09 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-plugins-contact-form-7-file-upload-ecommerce-affiliate-account-takeover-and-turisbook-stored-xss) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Three plugins, three CVEs, published together on November 8. They are not [Frontend Admin](wordpress-plugins-frontend-admin.md), the [Userplace and Productive Commerce pair](wordpress-plugins-nov9.md), the [November 8 checkout set](wordpress-plugins-nov8.md), the [November 7 upload and role-deletion pair](wordpress-plugins-nov7.md), the [four plugins from November 6](wordpress-plugins-nov6.md), [LatePoint](wordpress-plugins-latepoint.md), or the [core upgrade-window](wordpress-upgrade-window.md) flaw. A site is affected only if that plugin is installed.

**[CVE-2026-114432](https://www.cve.org/CVERecord?id=CVE-2026-114432): WPScan rates Contact Form 7 6.2 through 6.2.3 CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. WPScan is the CNA. The CVE.org record, published 2026-11-08, does not print a score; the score is on the WPScan page. A form with a file field accepts a file the validation should reject, and the temporary-file cleanup leaves it on disk. On a stock Debian or Ubuntu Apache configuration that lists directory contents and maps `.phar` to PHP, that file can be found and run. On nginx, and on Apache with `.htaccess` overrides on, WPScan says the result is a file in the uploads directory, which may still be served as HTML or SVG. The affected range is **6.2 before 6.2.4**, not every older release. The vendor's October 29 post says the vulnerability is only in 6.2 to 6.2.3, and recommends 6.2.4 for every install because the file-name check changed from a denylist to a safelist. The directory, read 2026-11-09, offers **6.2.4.1**, last updated 2026-10-29 11:49 GMT, with 10+ million active installs. 6.2.4.1 is later than 6.2.4. The proof of concept is withheld until 2026-11-19.

**[CVE-2026-106015](https://www.cve.org/CVERecord?id=CVE-2026-106015): WPScan rates Ecommerce Affiliate through 1.0.0 CVSS 3.1 8.1 High.** The vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`. The one-time password can be issued and guessed for any account, including an administrator, with no login. Complexity is High, which is the 8.1. WPScan says there is **no known fix**. The plugin page still shows version **1.0.0**, the only release, with fewer than 10 active installs. The English directory API returned 404 on 2026-11-09; the plugin page on a regional WordPress.org mirror still lists 1.0.0. The proof of concept is withheld until 2027-02-04.

**[CVE-2026-103303](https://www.cve.org/CVERecord?id=CVE-2026-103303): WPScan rates Turisbook Booking System through 1.3.8 CVSS 3.1 8.8 High.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`. Saving a setting does not check who is calling, and one setting is written into an admin page without being escaped, so a logged-out visitor can store script that runs when an administrator opens that page. The user interaction is the administrator. WPScan says there is **no known fix**. The directory listing was closed on 2026-10-23, pending review, at version 1.3.8, with about 20 active installs. The English directory API returned 404 on 2026-11-09. The proof of concept is withheld until 2027-02-04.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-09) for any of the three. WPScan does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Contact Form 7 6.2.4 | 2026-10-29; time/TZ unknown | Vendor post. The directory timestamp is 2026-10-29 11:49 GMT, which is 6.2.4.1. [Vendor][cf7] |
| WPScan, Contact Form 7 | 2026-11-05; time/TZ unknown | Publicly published. Last updated 2026-11-07. [WPScan][wps-cf7] |
| WPScan, the other two | 2026-11-06; time/TZ unknown | Both publicly published. [Ecommerce Affiliate][wps-ea], [Turisbook][wps-tb] |
| **Public CVE records** | **2026-11-08 06:17 UTC** | WPScan CNA. None of the three records prints a CVSS score. [CVE-2026-114432][cve-cf7] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-09) | [KEV][kev] |

## Detection

On a trusted copy of the site, read the installed versions. Do not run this on a host you suspect is compromised; read the files from a snapshot instead.

```sh
wp plugin list --fields=name,status,version --format=csv
```

If WP-CLI is not available, read the `Version:` line in each plugin's main file.

| Plugin | Slug | Affected | Fixed |
|---|---|---|---|
| Contact Form 7 | `contact-form-7` | 6.2 through 6.2.3, and only where a form has a file field | 6.2.4 or later. The directory offers 6.2.4.1 |
| Ecommerce Affiliate | `ecommerce-affiliate` | through 1.0.0, which is the only release | No known fix |
| Turisbook Booking System | `turisbook-booking-system` | through 1.3.8 | No known fix. The directory listing is closed |

A plugin that is installed and inactive can still be reachable if its code loads. A site without that plugin is outside this entry. Contact Form 7 older than 6.2 is outside CVE-2026-114432. The vendor still says to install 6.2.4 because the file-name check changed for every version.

## Remediation

1. Update Contact Form 7 to **6.2.4 or later**. 6.2.4.1 is the directory version on 2026-11-09. The update does not delete a file already left in the uploads directory.
2. **Remove Ecommerce Affiliate.** WPScan says there is no known fix, and 1.0.0 is the only release. Removing it does not restore an account whose password was changed.
3. **Remove Turisbook Booking System.** WPScan says there is no known fix, and the directory listing is closed. Removing it does not remove script already stored in a setting.
4. None of the three pages lists a configuration workaround. Turning off directory listings does not make the Contact Form 7 upload safe: the file can still be served as HTML or SVG. Taking the site offline is a containment step, not a fix.

## Verification

- `wp plugin get contact-form-7 --field=version` prints 6.2.4 or later, or reports that the plugin is not installed.
- `wp plugin get ecommerce-affiliate` and `wp plugin get turisbook-booking-system` report that the plugin is not installed.
- Submit a form that has a file field with an allowed type, such as a PDF. Do not send the file the advisory describes.

## Compromise response

No source publishes an indicator or a confirmed compromise. WPScan withholds all three proofs of concept.

- On a site that had Contact Form 7 6.2 through 6.2.3 with a file field, look in the uploads directory for a file that is not an image, a PDF, or another type the form accepts, including a `.phar`. The update does not delete it.
- On a site that had Ecommerce Affiliate, look for an administrator password that changed, and for a session you do not recognize. Removing the plugin does not end that session.
- On a site that had Turisbook, look at the cart background setting for script. Removing the plugin does not clear a copy stored somewhere else.

## Sources

- [WPScan, Contact Form 7][wps-cf7] — CVE-2026-114432, CVSS 3.1 9.8 Critical, 6.2 before 6.2.4, fixed in 6.2.4. Publicly published 2026-11-05, last updated 2026-11-07. Researchers Shinya Murakami and Jakub Herman. Proof of concept withheld until 2026-11-19.
- [Contact Form 7 6.2.4][cf7] — Takayuki Miyoshi, 2026-10-29. The vulnerability is only in 6.2 to 6.2.3. The file-name check is now a safelist, and the vendor recommends 6.2.4 for every install.
- [CVE-2026-114432][cve-cf7] — WPScan CNA, published 2026-11-08. The record does not print a CVSS score. Affected from 6.2 before 6.2.4. CWE-434.
- [Contact Form 7 on WordPress.org](https://wordpress.org/plugins/contact-form-7/) — version 6.2.4.1, last updated 2026-10-29 11:49 GMT, 10+ million active installs. Read 2026-11-09.
- [WPScan, Ecommerce Affiliate][wps-ea] — CVE-2026-106015, CVSS 3.1 8.1 High, through 1.0.0, no known fix. Publicly published 2026-11-06. Proof of concept withheld until 2027-02-04.
- [CVE-2026-106015][cve-ea] — WPScan CNA, published 2026-11-08. The record does not print a CVSS score. Affected from 0 through 1.0.0.
- [Ecommerce Affiliate plugin page](https://cn.wordpress.org/plugins/ecommerce-affiliate/) — version 1.0.0, fewer than 10 active installs. The English directory API returned 404 on 2026-11-09.
- [WPScan, Turisbook][wps-tb] — CVE-2026-103303, CVSS 3.1 8.8 High, through 1.3.8, no known fix. Publicly published 2026-11-06, last updated 2026-11-07. Researcher Naiches. Proof of concept withheld until 2027-02-04.
- [CVE-2026-103303][cve-tb] — WPScan CNA, published 2026-11-08. The record does not print a CVSS score. Affected from 0 through 1.3.8.
- [WP Beacon, turisbook-booking-system](https://wpbeacon.io/plugins/turisbook-booking-system) — directory listing closed 2026-10-23, version 1.3.8, about 20 active installs. Not an official WordPress.org page.
- [CISA KEV JSON][kev] — catalog 2026.11.06. None of the three is listed.

[wps-cf7]: https://wpscan.com/vulnerability/6b0a5d1f-84fb-425f-8d37-ddde5703937c/
[wps-ea]: https://wpscan.com/vulnerability/7222ff86-fc0e-42e5-ac68-f9506c90fb70/
[wps-tb]: https://wpscan.com/vulnerability/10693b34-ab03-4c24-bd9d-5a2efbfdbeb2/
[cf7]: https://contactform7.com/2026/10/29/contact-form-7-624
[cve-cf7]: https://www.cve.org/CVERecord?id=CVE-2026-114432
[cve-ea]: https://www.cve.org/CVERecord?id=CVE-2026-106015
[cve-tb]: https://www.cve.org/CVERecord?id=CVE-2026-103303
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
