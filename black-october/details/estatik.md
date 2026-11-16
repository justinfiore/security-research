# WordPress: Estatik loads a local file before login

**Last updated:** 2026-11-16 (America/New_York)

[Main Estatik summary](../black-october-2026.md#wordpress-estatik-loads-a-local-file-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Estatik is a WordPress real estate plugin, slug `estatik`. [CVE-2026-125795](https://www.cve.org/CVERecord?id=CVE-2026-125795) is a local file inclusion: a request with no login can make the site load a file from the server. Patchstack is the CNA and rates it **CVSS 3.1 9.8 Critical**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. The record says the plugin is affected from the beginning through **4.3.6**, and unaffected from **4.3.7**. It does not name the parameter or the file the request controls. NVD has not scored it.

The vendor's changelog for 4.3.7, dated November 11, says it improved template handling, avatar uploads, and user registration. It does not name the CVE. The directory offers 4.3.7, and WordPress.org reports 10,000+ active installs. This is not [Frontend Admin](wordpress-plugins-frontend-admin.md), the [November 9 plugin pair](wordpress-plugins-nov9.md), the [November 8 checkout set](wordpress-plugins-nov8.md), the [November 6 set](wordpress-plugins-nov6.md), [LatePoint](wordpress-plugins-latepoint.md), or the [core upgrade-window flaw](wordpress-upgrade-window.md).

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-16). The CVE record carries Patchstack's `x_known-exploited-vulnerability` tag and names no incident, and Patchstack's page says a flaw of this kind is expected to be used in mass campaigns. Neither names an attack against a site. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to Patchstack | 2026-10-26; time/TZ unknown | AndrewN, through the Patchstack bug bounty. [Patchstack][ps] |
| Estatik 4.3.7 | 2026-11-11; directory last updated 2026-11-12 05:46 GMT | The changelog says template handling, avatar uploads, and user registration were improved. It does not name the CVE. [WordPress.org][wp] |
| Patchstack page | 2026-11-13; time/TZ unknown | CVSS 9.8. Required privilege Unauthenticated. Patched in 4.3.7. The record's `datePublic` is 2026-11-13 14:28:23 UTC. [Patchstack][ps] |
| **Public announcement** | **2026-11-15 15:09:10 UTC** | Patchstack published the CVE record. NVD's published time is 2026-11-15 15:16:47 UTC. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. Update Estatik. |

## Detection

On a trusted copy of the site, read the installed version. Do not run this on a host you suspect is compromised; read the files from a snapshot instead.

```sh
wp plugin list --fields=name,status,version --format=csv
```

If WP-CLI is not available, read the `Version:` line in `wp-content/plugins/estatik/estatik.php`.

| Plugin | Slug | Affected | Fixed |
|---|---|---|---|
| Estatik | `estatik` | through 4.3.6 | 4.3.7 |

A plugin that is installed and inactive can still be reachable if WordPress loads its code. Confirm it. A site without Estatik is outside this entry. The record does not say which template or which request reaches the include, so a site that does not publish listings is not known to be safe.

## Remediation

1. Update Estatik to **4.3.7 or later**.
2. If the plugin is unused, remove it instead of leaving an affected copy inactive.
3. The update does not show whether a request already made the site load a file.

## Verification

- `wp plugin get estatik --field=version` shows 4.3.7 or later.
- Load one listing page. Do not send the request the advisory describes. It does not name that request.

## Compromise response

No source publishes an indicator or a confirmed compromise. Look for PHP errors that name an unexpected path under an Estatik template, and for files in the uploads directory you did not place. A path in a log is a lead, not proof. Local file inclusion can read `wp-config.php`; if you cannot rule that out, rotate the database password and the authentication keys in that file.

## Sources

- [CVE-2026-125795](https://www.cve.org/CVERecord?id=CVE-2026-125795) — Patchstack, published 2026-11-15 15:09:10 UTC. CVSS 3.1 9.8. Affected through 4.3.6. Unaffected from 4.3.7. The record carries `x_known-exploited-vulnerability` and describes no incident.
- [NVD, CVE-2026-125795](https://nvd.nist.gov/vuln/detail/CVE-2026-125795) — published 2026-11-15 15:16:47 UTC. Status Deferred. NVD has not scored it.
- [Patchstack][ps] — published 13 Nov 2026. Required privilege Unauthenticated. Patched in 4.3.7. Reported by AndrewN on 26 Oct 2026.
- [WordPress.org, Estatik][wp] — version 4.3.7, last updated 2026-11-12 05:46 GMT. 10,000+ active installs. The 4.3.7 changelog does not name the CVE.
- [CISA KEV JSON, cisagov/kev-data mirror](https://github.com/cisagov/kev-data) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. CVE-2026-125795 is not in it. The feed on cisa.gov returned HTTP 403.

[ps]: https://patchstack.com/database/wordpress/plugin/estatik/vulnerability/wordpress-estatik-plugin-4-3-6-local-file-inclusion-vulnerability?_s_id=cve
[wp]: https://wordpress.org/plugins/estatik/
