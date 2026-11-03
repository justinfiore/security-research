# s2Member: PayPal item name runs as PHP

**Last updated:** 2026-11-02 (America/New_York)

[Main s2Member summary](../black-october-2026.md#s2member-paypal-item-name-runs-as-php) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-86596](https://www.cve.org/CVERecord?id=CVE-2026-86596): Wordfence (CNA) CVSS 3.1 9.8 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H). NVD has not scored it.** The page title says unauthenticated. The description says a signed-in user with custom-level access or higher. Wordfence says `strip_php_tags_deep()` only removes a literal `<?`, and a later cleanup of leftover `%%...%%` placeholders puts `<?php` back together inside an email template that then runs. The parameter it names is `item_name`. Affected releases are **260927 and earlier**. Wordfence says **261001** is fixed. The current WordPress.org release is **261017**. [Wordfence][wf] [CNA][cve]

**What the tags actually contain.** `strip_php_tags()` is the same function in tags 260927, 261001, and 261017: it still only breaks `<?`. Tag 261017, dated 2026-10-17 in the file header, stops using that function's output as the email. It keeps the original template and fills each placeholder once in `fill_paypal_template_once()`. The PayPal notify file calls that with destination `html` or `text`, and the `html` path runs `esc_html()` on the value. The vendor changelog does not name this CVE. This guide did not execute the plugin. [Tag 261017][tag] [Notify file][notify]

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03). Wordfence does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | Credited to khanhnv. [Wordfence][wf] |
| Template fill rewritten | 2026-10-17; time/TZ unknown | Tag 261017 file headers say 261015–261016. The function comment says only the final render of the saved template is used. [Tag][tag] |
| Wordfence published | 2026-11-02; time/TZ unknown | CVSS 3.1 9.8. Patched version named as 261001. [Wordfence][wf] |
| CVE record published | 2026-11-02 21:30:23 UTC | Wordfence CNA. NVD published 2026-11-02 22:17:23 UTC. [CNA][cve] |

## Detection

On a trusted host, from the WordPress root, read the plugin header. Do not load the plugin to learn the version.

```sh
grep -H -m1 -iE '^[[:space:]*]*Version:' WP_ROOT/wp-content/plugins/s2member/s2member.php
```

**260927 and earlier** are inside Wordfence's affected range. **261001** is the version Wordfence names as patched. **261017** is the release whose template fill this guide read. Include inactive copies, staging sites, and the Pro add-on directory if it is present. The Pro add-on is not a separate fix for this file; the function lives in the framework plugin.

## Remediation

1. Update s2Member to **261017 or later** through WordPress's plugin update. 261017 is the release this guide checked. Wordfence names 261001; this guide did not find the new template fill in that tag.
2. The vendor changelog for 261017 does not mention `item_name` or this CVE. Do not treat a changelog line as proof the site is current. Read the version header.
3. Updating does not show whether an email template already ran attacker-controlled PHP.

## Verification

- The version header reads 261017 or later.
- A normal membership checkout still sends its email. Do not send a crafted `item_name`.

## Compromise response

Wordfence's own text disagrees on who can send `item_name`. Treat a site that was on 260927 or earlier, and that accepted PayPal notifications, as possibly exposed.

- Preserve web logs and `wp-content` before cleanup.
- Look for new administrator users, unexpected plugins, and new PHP files under `wp-content/uploads`.
- Rotate WordPress salts, administrator passwords, and PayPal API credentials stored in the plugin if you find evidence the template ran.

## Sources

- [Wordfence vulnerability record][wf] — CVSS 3.1 9.8, through 260927, patched version 261001, published 2026-11-02. Title says unauthenticated; body says custom-level access.
- [CVE-2026-86596][cve] — Wordfence CNA, published 2026-11-02 21:30:23 UTC.
- [s2Member tag 261017, `utils-strings.inc.php`][tag] — `fill_paypal_template_once()` escapes by destination. `strip_php_tags()` is unchanged.
- [PayPal notify handler, tag 261017][notify] — calls the one-pass fill for the email body.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30, not listed.

[wf]: https://www.wordfence.com/threat-intel/vulnerabilities/id/bbe64cd3-c5ca-4867-90de-4784510a1126?source=cve
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-86596
[tag]: https://plugins.svn.wordpress.org/s2member/tags/261017/src/includes/classes/utils-strings.inc.php
[notify]: https://plugins.svn.wordpress.org/s2member/tags/261017/src/includes/classes/paypal-notify-in-web-accept-sp.inc.php
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
