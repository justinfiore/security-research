# WordPress: Advanced Form Integration assigns a role before login

**Last updated:** 2026-11-26 (America/New_York)

[Main Advanced Form Integration summary](../black-october-2026.md#wordpress-advanced-form-integration-assigns-a-role-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Advanced Form Integration is a WordPress plugin, slug `advanced-form-integration`, that sends form submissions to other services. [CVE-2026-125769](https://www.cve.org/CVERecord?id=CVE-2026-125769) is an incorrect privilege assignment: Patchstack says a request with no login can become an administrator. Patchstack is the CNA and rates it **CVSS 3.1 9.8 Critical**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. The record says the plugin is affected from the beginning through **2.11.3**, and unaffected from **2.11.5**. It does not name the request or the parameter. NVD has not scored it.

The same plugin's own changelog for 2.1.1, dated June 10, says it fixed an unauthenticated privilege escalation in the WooCommerce Create Customer and FluentAffiliate Create Affiliate actions, and that it added a server-side check so a form submission cannot assign administrator, editor, author, or shop manager. 2.11.5, dated November 10, says only "Hardened user role assignment in WooCommerce, FluentAffiliate, WordPress and BuddyBoss actions." Neither entry names this CVE. 2.11.4, dated November 5, is between the affected ceiling and the fix, and its changelog is a Salesforce authentication change. The record does not say whether 2.11.4 is affected.

WordPress.org's plugin API reports **2.12.0**, last updated 2026-11-25 10:58 GMT, and 9,000+ active installs. 2.11.5 is still the first version the record calls unaffected. 2.12.0's changelog does not name the CVE.

Patchstack's page calls the same flaw "Low priority" and "No impactful threat," and says it has a low severity impact and is unlikely to be exploited. That sits next to its own CVSS 9.8 and its statement that a low-privilege user can become an administrator. The page names no attack against a site.

This is not [Estatik](estatik.md), [Frontend Admin](wordpress-plugins-frontend-admin.md), the [November 9 plugin pair](wordpress-plugins-nov9.md), the [November 8 checkout set](wordpress-plugins-nov8.md), the [November 6 set](wordpress-plugins-nov6.md), [LatePoint](wordpress-plugins-latepoint.md), or the [core upgrade-window flaw](wordpress-upgrade-window.md).

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-16). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to Patchstack | 2026-11-09; time/TZ unknown | Phạm Khắc Sang, through the Patchstack bug bounty. [Patchstack][ps] |
| Advanced Form Integration 2.11.5 | 2026-11-10; time/TZ unknown | Changelog: hardened user role assignment in WooCommerce, FluentAffiliate, WordPress, and BuddyBoss actions. It does not name the CVE. [WordPress.org API][api] |
| Advanced Form Integration 2.12.0 | 2026-11-25 10:58 GMT | The current release. The changelog does not name the CVE. 2.11.5 is still the first fixed version. [WordPress.org API][api] |
| Patchstack page | 2026-11-13; time/TZ unknown | CVSS 9.8. Required privilege Unauthenticated. Patched in 2.11.5. [Patchstack][ps] |
| **Public announcement** | **2026-11-15; time/TZ unknown** | Patchstack published the CVE record. NVD's published date is 2026-11-15, and NVD does not show a time. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. Update Advanced Form Integration. |

## Detection

On a trusted copy of the site, read the installed version. Do not run this on a host you suspect is compromised; read the files from a snapshot instead.

```sh
wp plugin list --fields=name,status,version --format=csv
```

If WP-CLI is not available, read the `Version:` line in `wp-content/plugins/advanced-form-integration/advanced-form-integration.php`.

| Plugin | Slug | Affected | Fixed |
|---|---|---|---|
| Advanced Form Integration | `advanced-form-integration` | through 2.11.3 | 2.11.5; current release 2.12.0 |

A plugin that is installed and inactive can still be reachable if WordPress loads its code. Confirm it. A site without Advanced Form Integration is outside this entry. The record does not say which action reaches the role assignment, so a site that has not connected WooCommerce or FluentAffiliate is not known to be safe. 2.11.4 is not named as fixed or affected.

## Remediation

1. Update Advanced Form Integration to **2.12.0 or later**. 2.11.5 is the first version the record calls unaffected.
2. If the plugin is unused, remove it instead of leaving an affected copy inactive.
3. The update does not remove an administrator account that was already created.

## Verification

- `wp plugin get advanced-form-integration --field=version` shows 2.11.5 or later.
- Open the plugin's integrations list. Do not send the request the advisory describes. It does not name that request.

## Compromise response

No source publishes an indicator or a confirmed compromise. Look for administrator accounts created on or after October 26 that nobody on the site recognizes, and for the plugin's own log of a skipped user-role change. 2.11.6 says skipped role changes are now written to that log with a reason; an earlier version does not. A new administrator is a lead, not proof. If you cannot rule out that an account was created, remove it and rotate the passwords and API credentials stored in the plugin.

## Sources

- [CVE-2026-125769](https://www.cve.org/CVERecord?id=CVE-2026-125769) — Patchstack, published 2026-11-15. CVSS 3.1 9.8. Affected from the beginning through 2.11.3. Unaffected from 2.11.5. The record does not name the request.
- [NVD, CVE-2026-125769](https://nvd.nist.gov/vuln/detail/CVE-2026-125769) — published November 15, 2026. Status Not Scheduled. NVD has not scored it. The CNA score is shown as the secondary metric.
- [Patchstack][ps] — published 13 Nov 2026. Required privilege Unauthenticated. Patched in 2.11.5. Reported by Phạm Khắc Sang on 9 Nov 2026. The page also says "Low priority" and "No impactful threat."
- [WordPress.org plugin API, Advanced Form Integration][api] — version 2.12.0, last updated 2026-11-25 10:58 GMT, 9,000+ active installs. 2.11.5 (2026-11-10) hardened user role assignment. 2.12.0 does not name the CVE.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. CVE-2026-125769 is not in it.

[ps]: https://patchstack.com/database/wordpress/plugin/advanced-form-integration/vulnerability/wordpress-advanced-form-integration-plugin-2-11-3-privilege-escalation-vulnerability?_s_id=cve
[api]: https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&request%5Bslug%5D=advanced-form-integration
