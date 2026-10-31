# Gravity Forms: unauthenticated object injection on post creation

**Last updated:** 2026-10-31 (America/New_York)

[Main Gravity Forms summary](../black-october-2026.md#gravity-forms-unauthenticated-object-injection-on-post-creation) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-103039](https://www.cve.org/CVERecord?id=CVE-2026-103039): Wordfence (CNA) CVSS 3.1 9.8 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H). Patchstack repeats 9.8. NVD has added no score of its own.** Gravity Forms, a WordPress form plugin, passes a Post Custom Field of type List to WordPress's unrestricted `maybe_unserialize()` in versions **up to and including 3.1.2**. Version 3.1.1 added a hardened `GFCommon::maybe_unserialize()` that passes `allowed_classes => false`, but `GFFormsModel::create_post()` does not use it when the field has a content template. An unauthenticated visitor can then store a PHP object in post meta. The plugin itself has no gadget chain. Wordfence says WordPress supplies one when the field is mapped to the protected `_wp_page_template` meta key, and that this becomes remote code execution on hosts with a readable PEAR install and `register_argc_argv` enabled. [Wordfence][wf] [CNA][cve] [Patchstack][ps]

**Worst case:** remote code execution as the web server user, but only where a gadget chain exists. Without one, the result is a PHP object stored in post meta, not code execution. [Wordfence][wf]

**Fixed in 3.1.3.** Wordfence and Patchstack both name 3.1.3 as the patched version. Gravity Forms' own docs site is linked from the CVE record and does not publish this advisory. [Wordfence][wf] [Patchstack][ps]

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-10-31). Wordfence and Patchstack do not report observed exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | Credited to Tin Pham (TF1T), Hao Ngo and Trong Pham. [Wordfence][wf] |
| CVE ID reserved | 2026-09-29 22:08:12 UTC | Wordfence CNA metadata. [CNA][cve] |
| Vendor notified | 2026-09-30 13:29:24 UTC | Wordfence CNA timeline. [CNA][cve] |
| **Public announcement** | **2026-10-29; time/TZ unknown** | Wordfence "Publicly Published October 29, 2026"; Patchstack "29 Oct, 2026". The CNA timeline's "Disclosed 2026-10-29T18:29:20.000Z" is the only timed disclosure stamp. [Wordfence][wf] [Patchstack][ps] [CNA][cve] |
| CVE record published | 2026-10-30 06:47:32 UTC | Wordfence CNA. NVD published 2026-10-30 07:16:30 UTC. [CNA][cve] [NVD][nvd] |
| CISA KEV | Not listed (catalog 2026.10.30, checked 2026-10-31) | [KEV][kev] |

## Detection

On a **trusted** host, from the WordPress root (`WP_ROOT`), as the site's file owner. These commands only read. They were not exercised on a real site. `--skip-plugins --skip-themes` stops WP-CLI from loading plugin and theme code.

```sh
cd WP_ROOT
wp plugin list --name=gravityforms --fields=name,status,version --skip-plugins --skip-themes
```

If WP-CLI is unavailable, or the site may be compromised, read the plugin header from the files or from a copied snapshot instead of running WordPress:

```sh
grep -H -m1 -iE '^[[:space:]*]*Version:' WP_ROOT/wp-content/plugins/gravityforms/gravityforms.php
```

Versions **3.1.2 and earlier** are affected. Include multisite, staging copies and web-reachable backups. An inactive copy is still files on disk; the reviewed sources do not say whether it is exploitable, so update or remove it.

A site is exposed to the described path only when a form has a **Post Custom Field** whose input type is **List** and that field has a **content template**. Mapping that field to `_wp_page_template` is the chain Wordfence names. Inspect forms in the Gravity Forms editor, or, on a database snapshot, search exported form meta for a List field used as a post custom field. Do not print form submissions that may contain personal data.

Code execution further requires a gadget chain. Wordfence's named chain also needs a readable PEAR install and `register_argc_argv` enabled. Confirm those on the PHP host if you are judging whether the WordPress chain could have run; their absence does not clear other chains a theme or plugin might supply.

## Remediation

1. **Update Gravity Forms to 3.1.3 or later** through the vendor's update channel. [Wordfence][wf] [Patchstack][ps]
2. **If you cannot update now,** disable forms that create posts from a List-type Post Custom Field with a content template, or take those forms offline. That is a mitigation, not a fix. Patchstack says it has a mitigation rule; that rule is not a substitute for 3.1.3.
3. Updating stops the unsafe unserialize. It does not remove an object already stored in post meta, and it does not remove a web shell if a chain ran.

## Verification

- Re-run the version check and confirm **3.1.3 or later** on every site, including staging.
- Submit a normal form that creates a post and confirm the post is still created. Do not send serialized-object payloads.

## Compromise response

If a vulnerable form was reachable and a gadget chain was present on the host, treat code execution as possible rather than proven.

- Preserve web logs, a database dump and `wp-content` before cleanup.
- Search post meta written by the form for serialized PHP objects (`O:` followed by a digit). Remove attacker-controlled values; do not unserialize them.
- Look for persistence: unknown administrator users (query the database; hidden admins may not appear in the UI), unexpected plugins and must-use plugins, modified core, theme and plugin files, and new PHP files under `wp-content/uploads`.
- Rotate the database password, WordPress salts and keys, administrator passwords, and API keys stored in the site if you find evidence the chain ran.
- If the host is shared, check other sites on the account. Rebuild from known-good sources if the extent is unclear.

## Sources

- [Wordfence vulnerability record][wf] and [CVE record (Wordfence CNA)][cve]: description, CVSS 3.1 9.8, affected range through 3.1.2, patched version 3.1.3, vendor-notification and disclosure times, researchers.
- [Patchstack database entry][ps]: CVSS 9.8, patched in 3.1.3, published 29 Oct 2026. Patchstack says the issue is "expected to become exploited"; that is not a report of observed exploitation.
- [NVD][nvd]; [CISA KEV feed][kev] (not listed, catalog 2026.10.30).
- [Gravity Forms documentation][docs], linked from the CVE record. It does not publish this advisory.

[wf]: https://www.wordfence.com/threat-intel/vulnerabilities/id/ec1fba15-81e5-42e3-9154-1978c3f81b26?source=cve
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-103039
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-103039
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[ps]: https://patchstack.com/database/wordpress/plugin/gravityforms/vulnerability/wordpress-gravity-forms-plugin-3-1-2-unauthenticated-php-object-injection-vulnerability
[docs]: https://docs.gravityforms.com/
