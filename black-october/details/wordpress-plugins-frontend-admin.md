# WordPress plugins: Frontend Admin privilege escalation

**Last updated:** 2026-11-09 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-plugins-frontend-admin-privilege-escalation) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

One plugin, one CVE. It is not the [November 9 Userplace and Productive Commerce pair](wordpress-plugins-nov9.md), the [November 8 checkout set](wordpress-plugins-nov8.md), the [November 7 upload and role-deletion pair](wordpress-plugins-nov7.md), the [four plugins from November 6](wordpress-plugins-nov6.md), [LatePoint](wordpress-plugins-latepoint.md), or the [core upgrade-window](wordpress-upgrade-window.md) flaw. A site is affected only if this plugin is installed.

**[CVE-2026-119506](https://www.cve.org/CVERecord?id=CVE-2026-119506): Patchstack rates Frontend Admin by DynamiApps through 3.30.1 CVSS 3.1 9.1 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. Patchstack is the CNA. The record title is "Incorrect Privilege Assignment" (CWE-266) and says the plugin allows privilege escalation. The record does not say what the caller has to submit, or what role they end up with. Patchstack's page says the required privilege is **Unauthenticated** and that a low-privilege user can become an admin. Those two lines are both on the page; the CVSS vector matches the unauthenticated line (`PR:N`). Availability is None, which is why the score is 9.1 and not 9.8. NVD has not scored it. The fix is **3.30.2**. The WordPress.org directory, read 2026-11-09, offers 3.30.2, last updated 2026-11-01 12:31 GMT, with about 8,000 active installs. The 3.30.2 changelog, dated 01-11-2026, does not name this CVE. It does say public registration forms now need the "Assign Privileged User Roles" special permission to give new users a role that can edit, publish, or upload content. An older unauthenticated privilege-escalation flaw in the same plugin, through 3.29.13, was fixed in 3.30.0 and is a different issue. Updating to 3.30.2 covers this CVE. It does not undo a role already granted.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-09). Patchstack does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to Patchstack | 2026-10-24; time/TZ unknown | Nguyen Quang Tan, Patchstack Bug Bounty Program. [Patchstack][ps] |
| Frontend Admin 3.30.2 | 2026-11-01 12:31 GMT | Changelog dated 01-11-2026. It does not name the CVE. [Directory API][api] |
| Patchstack page | 2026-11-06; time/TZ unknown | CVSS 9.1, required privilege Unauthenticated, patched in 3.30.2. [Patchstack][ps] |
| **Public CVE record** | **2026-11-09; time/TZ unknown** | Patchstack CNA. CVSS 3.1 9.1 Critical. [CVE-2026-119506][cve] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-09) | [KEV][kev] |

## Detection

On a trusted copy of the site, read the installed version. Do not run this on a host you suspect is compromised; read the files from a snapshot instead.

```sh
wp plugin get acf-frontend-form-element --fields=name,status,version
```

If WP-CLI is not available, read the `Version:` line in `acf-frontend-form-element.php`.

| Plugin | Slug | Affected | Fixed |
|---|---|---|---|
| Frontend Admin by DynamiApps | `acf-frontend-form-element` | through 3.30.1 | 3.30.2 or later |

A plugin that is installed and inactive can still be reachable if its code loads. A site without the plugin is outside this entry. The directory name is "ACF Frontend Admin by DynamiApps"; the CVE record calls it "Frontend Admin by DynamiApps". Same slug.

## Remediation

1. Update Frontend Admin to **3.30.2 or later**. The directory API on 2026-11-09 reports 3.30.2. The update does not remove a role or a user already created.
2. Patchstack lists no configuration workaround. Taking the site offline is a containment step, not a fix.
3. After the update, a public registration form needs the "Assign Privileged User Roles" special permission before it can give a new user a role that can edit, publish, or upload. That is a 3.30.2 changelog line, not a description of the flaw.

## Verification

- `wp plugin get acf-frontend-form-element --field=version` prints 3.30.2 or later, or reports that the plugin is not installed.
- Load a public registration form if the site has one. Do not send the request the advisory describes.

## Compromise response

No source publishes an indicator or a confirmed compromise.

- Look for a user account you do not recognize, and for a role change on an account that should not be able to edit, publish, or upload. The update does not reverse that change.
- No matching account is not proof the site was safe. Patchstack does not publish the request.

## Sources

- [Patchstack][ps] — CVE-2026-119506, CVSS 3.1 9.1, required privilege Unauthenticated, through 3.30.1, patched in 3.30.2. Published 2026-11-06. Reported 2026-10-24 by Nguyen Quang Tan. The page also says a low-privilege user can become an admin.
- [CVE-2026-119506][cve] — Patchstack CNA, published 2026-11-09. CVSS 3.1 9.1 Critical, `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. Affected from 0 through 3.30.1. Unaffected from 3.30.2. CWE-266.
- [Frontend Admin directory API][api] — version 3.30.2, last updated 2026-11-01 12:31 GMT, about 8,000 active installs. The 3.30.2 changelog does not name the CVE. Read 2026-11-09.
- [CISA KEV JSON][kev] — catalog 2026.11.06. Not listed.

[ps]: https://patchstack.com/database/wordpress/plugin/acf-frontend-form-element/vulnerability/wordpress-frontend-admin-by-dynamiapps-plugin-3-30-1-privilege-escalation-vulnerability
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-119506
[api]: https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&request%5Bslug%5D=acf-frontend-form-element
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
