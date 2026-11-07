# WordPress plugins: unauthenticated upload and role deletion

**Last updated:** 2026-11-07 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-plugins-unauthenticated-upload-and-role-deletion) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Two plugins, two CVEs, each scored Critical by WPScan. They are not one bug, and they are not the [four plugins from November 6](wordpress-plugins-nov6.md) or the [core upgrade-window](wordpress-upgrade-window.md) flaw. A site is affected only by the plugin it has installed. WPScan says neither has a known fix.

**[CVE-2026-118423](https://www.cve.org/CVERecord?id=CVE-2026-118423): WPScan rates WP Libre Form 1.5.0.1 CVSS 3.1 10.0 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`. The plugin does not check the type of a file uploaded through a form, so a logged-out caller can upload PHP and run it. The record names that one version. WPScan's page says the same, and says there is no known fix. The proof of concept is withheld until 2027-02-01. WordPress.org closed the plugin on 2026-09-08, pending review, and the directory page shows **1.4.3**, last updated nine years ago. The record does not say 1.4.3 is affected, and it does not say it is not.

**[CVE-2026-88800](https://www.cve.org/CVERecord?id=CVE-2026-88800): WPScan rates MDJM Event Management and Mobile Events Manager through 1.7.8.7 CVSS 3.1 9.1 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:H`. On every page load the plugins act on a role-deletion request with no capability check and no nonce. The check meant to protect a role that still has users reads a different part of the request from the one that chooses the role, so a logged-out caller can delete any role, including administrator. WPScan says that strips every user of their capabilities, and that there is no known fix. The proof of concept is withheld until 2027-05-03. Confidentiality impact is None: the flaw deletes a role, it does not read one. WordPress.org still offers MDJM Event Management **1.7.8.7**, updated 2026-09-08, with 50+ active installs. Its changelog does not mention this CVE. Mobile Events Manager was closed on 2022-10-05 at the author's request; the directory page shows 1.4.8.3.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-07) for either CVE. WPScan does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| WP Libre Form closed on WordPress.org | 2026-09-08; time/TZ unknown | Directory page says the closure is temporary, pending a full review. The page shows 1.4.3. |
| MDJM 1.7.8.7 published | 2026-09-08 21:47 GMT | WordPress.org plugin API. The changelog does not mention CVE-2026-88800. |
| WPScan page, MDJM | 2026-11-02; time/TZ unknown | Publicly published that day. Last updated 2026-11-05. [WPScan][wpscan-mdjm] |
| WPScan page, WP Libre Form | 2026-11-03; time/TZ unknown | Publicly published, added, and last updated that day. [WPScan][wpscan-libre] |
| **Public CVE records** | **2026-11-06 07:30 UTC** | Both records. WPScan is the CNA. |

## Detection

On a trusted copy of the site, read the installed versions. Do not run this on a host you suspect is compromised; read the files from a snapshot instead.

```sh
wp plugin list --fields=name,status,version --format=csv
```

If WP-CLI is not available, read the `Version:` line in each plugin's main file:

| Plugin | Slug | Affected | Fixed |
|---|---|---|---|
| WP Libre Form | `wp-libre-form` | 1.5.0.1 | No known fix |
| MDJM Event Management | `mobile-dj-manager` | through 1.7.8.7 | No known fix |
| Mobile Events Manager | `mobile-events-manager` | through 1.7.8.7 | No known fix |

A plugin that is installed and inactive can still be reachable if its code loads. Confirm each one. A site with none of the three is outside this entry. The directory copy of WP Libre Form is 1.4.3, which the CVE record does not list. An installed 1.5.0.1 did not come from the current directory page.

## Remediation

1. There is no fixed version. Remove WP Libre Form **1.5.0.1**, and remove MDJM Event Management and Mobile Events Manager through **1.7.8.7**, if the site does not need them.
2. If the site needs MDJM, take the forms and the public pages that load the plugin offline until the vendor publishes a version above 1.7.8.7. WPScan's page, read 2026-11-07, still says no known fix. Leaving 1.7.8.7 active is not a mitigation.
3. Removing the plugin does not delete a PHP file WP Libre Form already saved, and it does not restore a role MDJM already deleted.

## Verification

- `wp plugin get <slug> --field=version` is empty because the plugin is gone, or, once a fix exists, shows a version the vendor says is fixed. On 2026-11-07 neither vendor page says that.
- Load the site's front page. Do not submit the upload or the role-deletion request the advisories describe.

## Compromise response

No source publishes an indicator or a confirmed compromise.

- For WP Libre Form, look for a `.php` file under the uploads directory dated after 2026-11-03 that you did not put there. The record does not name the path.
- For MDJM, look for a missing administrator role, and for users who could sign in yesterday and cannot today. Restoring the role is a WordPress repair, not a plugin update. The plugin's own changelog for 1.7.8.5 says it fixed a different privilege-escalation bug; that note is not this CVE.

## Sources

- [WPScan, WP Libre Form][wpscan-libre] — CVE-2026-118423, 10.0, version 1.5.0.1, no known fix. Publicly published 2026-11-03. Proof withheld until 2027-02-01.
- [WPScan, MDJM][wpscan-mdjm] — CVE-2026-88800, 9.1, through 1.7.8.7, no known fix. Publicly published 2026-11-02, last updated 2026-11-05. Proof withheld until 2027-05-03.
- [CVE-2026-118423](https://www.cve.org/CVERecord?id=CVE-2026-118423), [CVE-2026-88800](https://www.cve.org/CVERecord?id=CVE-2026-88800) — both published 2026-11-06 07:30 UTC. WPScan CNA.
- [WP Libre Form on WordPress.org](https://wordpress.org/plugins/wp-libre-form/) — closed 2026-09-08, directory version 1.4.3. Read 2026-11-07.
- [MDJM Event Management on WordPress.org](https://wordpress.org/plugins/mobile-dj-manager/) — version 1.7.8.7, updated 2026-09-08. The API changelog does not name CVE-2026-88800.

[wpscan-libre]: https://wpscan.com/vulnerability/35149a79-aee1-4f13-ba29-583c2224c5da/
[wpscan-mdjm]: https://wpscan.com/vulnerability/f39f77ac-1885-4021-a4d2-5a2b7c5260b5/
