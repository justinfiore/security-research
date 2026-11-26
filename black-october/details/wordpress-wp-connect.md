# WordPress: six WP connect plugins shipped a backdoor

**Last updated:** 2026-11-25 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-six-wp-connect-plugins-shipped-a-backdoor) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-23 Wordfence published a supply-chain report for six WordPress plugins from the developer WP connect. Wordfence is the CNA for [CVE-2026-135202](https://www.cve.org/CVERecord?id=CVE-2026-135202) and rates it **Critical, CVSS 3.1 9.8**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. The record, published 2026-11-24, says the same. It was still reserved on 2026-11-23.

On the afternoon of 2026-11-22, new releases were committed to the WordPress.org repositories of all six plugins from the developer's own account, over about two hours. Each release adds `includes/airwp-online.php` and loads it from the plugin's main file. The file runs on every request, including a page view with no login, and on a half-hourly cron event. It sends the site URL, the PHP, WordPress, and operating system versions, and the system user to `tascredit-pay.com`, with TLS certificate verification turned off, and runs the PHP that server returns. It can also run a shell command, read and write files, dump the users table including password hashes, write a PHP file into the uploads directory, and register an hourly cron hook.

Wordfence lists these versions:

| Plugin | Slug | Backdoored versions |
|---|---|---|
| Air WP Sync – Airtable to WordPress | `air-wp-sync` | 2.9.1 through 2.9.4 |
| WP Sync for Notion – Notion to WordPress | `wp-sync-for-notion` | 1.7.4 |
| Add-on Brevo for Gravity Forms | `addon-gravityforms-sendinblue-free` | 2.6.3 |
| Add-On for Contact Form 7 to Airtable | `add-on-cf7-for-airtable` | 2.5.4 |
| Add-On for Contact Form 7 to Notion | `add-on-cf7-for-notion` | 1.6.4 |
| Orders Sync to Airtable for WooCommerce | `orders-sync-to-airtable-for-woocommerce` | 1.0.2 |

The release immediately before each of those does not contain the file. WordPress.org's Protect The Shire release delay, and its automated reviewer, stopped the versions before they were offered to sites. All six plugins were closed on WordPress.org the same evening. Read again on 2026-11-25, the directory calls the closure of WP Sync for Notion, Add-on Brevo for Gravity Forms, Add-On for Contact Form 7 to Airtable, Add-On for Contact Form 7 to Notion, and Orders Sync to Airtable for WooCommerce permanent. It calls the closure of Air WP Sync temporary, pending a full review. None of the six is available for download, and none has a patched release. Wordfence says most sites should not have a backdoored copy, and that there is no patch. The WordPress.org Plugins Team says the developer reports the account was compromised. Further details are still pending. Wordfence says it is still writing malware signatures.

**CISA KEV:** Not listed (catalog 2026.11.24, checked 2026-11-24). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Backdoored releases committed | 2026-11-22, about 16:30–17:40 America/New_York | Six plugins, from the developer's WordPress.org account. Wordfence gives the window, not a clock time. [Report][wf] |
| Releases stopped | 2026-11-22; time/TZ unknown | Protect The Shire held them, and the plugins were closed the same evening. [Report][wf] |
| **Directory reread** | **2026-11-25; time/TZ unknown** | Five closures are permanent. Air WP Sync's is temporary, pending a full review. Still no patched release. |
| **Public announcement** | **2026-11-23; time/TZ unknown** | Wordfence. CVSS 3.1 9.8. [Report][wf] |
| **CVE record published** | **2026-11-24; time/TZ unknown** | Wordfence is the CNA. CVSS 3.1 9.8. No patched version. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-135202) |

## Detection

Look for the file, not only the version number. A site that never installed one of the six versions above is outside what Wordfence describes. A site that has any of these has the backdoor, whether or not WordPress.org offered the update:

- `wp-content/plugins/<slug>/includes/airwp-online.php` for one of the slugs in the table.
- An option whose name starts with `airwp_`, including `airwp_api_url`, `airwp_pending_cmd`, and `airwp_client_id`.
- A cron event named `airwp_tick` or `airwp_persist_tick`.
- An outbound request to `tascredit-pay.com`.
- A PHP file in `wp-content/uploads/` that the site owner did not put there.

Reading those paths changes no state. Finding none of them does not prove a webshell was never written and then removed.

## Remediation

1. If any listed version is installed, remove that plugin. There is no patched release. Five of the six are closed permanently. Air WP Sync's closure is temporary and pending a review, and it is still not available for download. Do not reinstall it from the directory while that page still offers no fixed version.
2. Removing the plugin does not remove a PHP file already written under `wp-content/uploads/`, and it does not remove an hourly cron hook the backdoor registered.
3. A site that is not on a listed version needs no change for this incident. Wordfence says the backdoored versions were never released to sites.

## Verification

- None of the six slugs is installed at a version in the table.
- `includes/airwp-online.php` is absent from each plugin directory.
- Do not request `tascredit-pay.com` to test it.

## Compromise response

If a listed version ran, treat the site as compromised. Wordfence's own indicators are the file, the `airwp_` options, the two cron events, requests to `tascredit-pay.com`, and unexpected PHP under `wp-content/uploads/`. Rotate administrator passwords and the site's secret keys, and remove a webshell and a cron hook before putting the site back. Removing the plugin does not do that.

## Sources

- [Wordfence, 2026-11-23][wf] — Chloe Chamberland. CVSS 3.1 9.8. Six plugins, the versions in the table, the file `includes/airwp-online.php`, and the host `tascredit-pay.com`. Says the versions were never released and that there is no patch.
- [Wordfence Intelligence record](https://www.wordfence.com/threat-intel/vulnerabilities/id/2bda1d59-0524-40ee-9427-2d31470780f9) — published 2026-11-23. CVSS 3.1 9.8. Names CVE-2026-135202. No patched version.
- [CVE-2026-135202](https://www.cve.org/CVERecord?id=CVE-2026-135202) — Wordfence, published 2026-11-24. CVSS 3.1 9.8. CWE-506. The same six versions. Says the plugins are closed and no patched version is available. It rendered reserved on 2026-11-23.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.24, released 2026-11-24T17:47:46.199Z, checked 2026-11-24. Not listed.

[wf]: https://www.wordfence.com/blog/2026/11/supply-chain-compromise-backdoors-six-wp-connect-plugins-blocked-by-wordpress-orgs-release-hold/
