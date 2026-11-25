# WordPress: an editor link creates an administrator

**Last updated:** 2026-11-24 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-an-editor-link-creates-an-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

WordPress 7.1.5, released 2026-11-18, is a security release. The project published 19 GitHub advisories that day. Five are rated High. The rest of that set is Moderate or Low, and the release post also lists two hardening changes. None of the 19 has a CVE. Wordfence later scored several of the same issues and called one Critical; where that number disagrees with the project's own High rating, both stay visible below.

**The WordPress project rates [GHSA-pmp8-6cv8-q323](https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-pmp8-6cv8-q323) High and publishes no numeric score.** A Template Part block's theme and slug attributes could make an Administrator's editor send a request to another URL on the same site. An unauthenticated person can send that Administrator a crafted editor link. A user with the Author role or above can set the attributes in a post. When the Administrator opens it, the request can create an Administrator account for the attacker, who can then run code by uploading a plugin. It affects **5.9 through 7.1.4**, on the ranges in the advisory, and is fixed in **7.1.5** and the backports through **5.9.21**. Wordfence scores the same issue CVSS 3.1 8.8 and describes the path it reproduced as cross-site request forgery that needs the Administrator to open the link. Its write-up says remote code execution was not demonstrated.

**[GHSA-mwj7-xhp9-7773](https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-mwj7-xhp9-7773) is also High, with no numeric score.** On a multisite install that uses a classic theme with widgets enabled, a site Administrator can replay a Customizer widget hash as the signature for navigation-menu refresh arguments and take over a Super Admin account. It reaches back to **4.7** and is fixed in **4.7.40** and the later branch releases. Wordfence scores it CVSS 3.1 9.1 Critical. A single-site install is outside the condition the advisory names.

Three more are High. [GHSA-cr2m-2j4r-3v3x](https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-cr2m-2j4r-3v3x) lets a visitor post a comment whose shortcode attribute becomes HTML after sanitization, where a Comments or Latest Comments block sits in post content. [GHSA-gm52-6h3w-97v4](https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-gm52-6h3w-97v4) is reflected script in the legacy media library popup, and it runs when a logged-in user who can upload files opens the link. [GHSA-jmhp-hg7w-w9c5](https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-jmhp-hg7w-w9c5) puts Openverse creator metadata into an image caption without escaping it, so inserting that image from the editor's Openverse search runs the script. The first two reach 4.7. The Openverse one starts at 6.2. No advisory in the set reports exploitation.

The release also fixes SQL injection in `WP_Meta_Query` and in Customizer front-page previews, an unauthenticated denial of service through batched XML-RPC pingbacks, and information-disclosure and authorization issues that need a signed-in user. The project rates those Moderate or Low. This is not the [upgrade-window race](wordpress-upgrade-window.md), which is CVE-2026-119977 and was fixed in 7.1.4.

**CISA KEV:** Not applicable to the 19 advisories — no CVE is assigned, and KEV lists only CVEs. The catalog does not list a WordPress core CVE added for this release. Absence of a listing is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fixes** | **2026-11-18; time/TZ unknown** | [WordPress 7.1.5][news]. Nineteen advisories, five rated High. The post prints the date and no time. |
| HelpHub branch list | 2026-11-18; time/TZ unknown | [Version 7.1.5][help]. Fixed releases from 7.1.5 back to 4.7.40. 4.6 and earlier get nothing. |
| **Last updated** | **2026-11-24 (America/New_York)** | New item. Update to the fixed release for the branch. |

## Detection

Read `$wp_version` in `wp-includes/version.php`, or **Dashboard → Updates**. A site below the fixed release for its branch is inside at least one of the High advisories:

| Branch | Fixed release |
|---|---|
| 7.1 | 7.1.5 |
| 7.0 | 7.0.9 |
| 6.9 | 6.9.12 |
| 6.8 | 6.8.13 |
| 6.7 | 6.7.12 |
| 6.6 | 6.6.12 |
| 6.5 | 6.5.15 |
| 6.4 | 6.4.15 |
| 6.3 | 6.3.15 |
| 6.2 | 6.2.16 |
| 6.1 | 6.1.17 |
| 6.0 | 6.0.19 |
| 5.9 | 5.9.21 |
| 5.8 | 5.8.20 |
| 5.7 | 5.7.22 |
| 5.6 | 5.6.24 |
| 5.5 | 5.5.25 |
| 5.4 | 5.4.26 |
| 5.3 | 5.3.28 |
| 5.2 | 5.2.31 |
| 5.1 | 5.1.29 |
| 5.0 | 5.0.32 |
| 4.9 | 4.9.36 |
| 4.8 | 4.8.35 |
| 4.7 | 4.7.40 |

Not every High advisory reaches every branch. The Template Part flaw starts at 5.9, and the Openverse flaw starts at 6.2. The comment flaw, the media-library flaw, and the multisite flaw reach 4.7. WordPress 4.6 and earlier receive no fix. Reading the version changes no state.

## Remediation

1. Update to **7.1.5**, or to the fixed release for the installed branch in the table above. WordPress says only the newest branch is actively supported. The backports are a courtesy.
2. 4.6 and earlier get nothing. Move that site to a supported branch.
3. The update does not remove an Administrator account the Template Part flaw already created, and it does not undo a Super Admin takeover that already happened. Review accounts created on or after 2026-11-18 that you cannot account for.
4. On 6.9.12 and earlier, this release also removes 1024-bit certificates from the bundled roots. A plugin that still trusts one of those roots can fail a TLS check after the update. That is a compatibility change, not a second vulnerability.

## Verification

- The installed version is the fixed release for its branch, or newer.
- Do not send a crafted editor link or a comment to test it.

## Compromise response

A site below the fixed release may already have a new Administrator, or, on multisite, a Super Admin account that changed hands. Review users created or promoted since 2026-11-18, and plugins installed in that window. The update does not show whether either happened. No source read for this entry reports exploitation.

## Sources

- [WordPress 7.1.5 release][news] — Jeremy Felt, 2026-11-18. Twenty security bullets, two of them hardening. Backports through the 4.7 branch, in progress as they become ready.
- [Version 7.1.5][help] — the per-branch fixed releases, from 7.1.5 through 4.7.40. 4.6 and earlier are unsupported. First published 2026-11-18.
- [GHSA-pmp8-6cv8-q323](https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-pmp8-6cv8-q323) — High, published 2026-11-18. Template Part attributes. No CVE. Fixed from 5.9.21 through 7.1.5.
- [GHSA-mwj7-xhp9-7773](https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-mwj7-xhp9-7773) — High, published 2026-11-18. Multisite Super Admin takeover. Needs a classic theme with widgets. Fixed from 4.7.40.
- [GHSA-cr2m-2j4r-3v3x](https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-cr2m-2j4r-3v3x) — High, published 2026-11-18. Stored script in a comment. Fixed from 4.7.40.
- [GHSA-gm52-6h3w-97v4](https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-gm52-6h3w-97v4) — High, published 2026-11-18. Reflected script in the legacy media library popup. Fixed from 4.7.40.
- [GHSA-jmhp-hg7w-w9c5](https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-jmhp-hg7w-w9c5) — High, published 2026-11-18. Openverse caption. Fixed from 6.2.16.
- [Wordfence, 2026-11-19](https://www.wordfence.com/blog/2026/11/wordpress-7-1-5-security-release-fixes-19-vulnerabilities/) — scores the multisite issue CVSS 3.1 9.1 and the Template Part issue 8.8. The project's own rating for both is High, with no number.
- [CISA KEV JSON][kev] — catalog 2026.11.24, released 2026-11-24T17:47:46.199Z, checked 2026-11-24. No CVE from this release is listed. CVE-2026-119977, the earlier upgrade-window flaw, was already listed.

[news]: https://wordpress.org/news/2026/11/wordpress-7-1-5-release/
[help]: https://wordpress.org/documentation/wordpress-version/version-7-1-5/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
