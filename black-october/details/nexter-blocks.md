# WordPress: Nexter Blocks Pro registers an administrator

**Last updated:** 2026-11-22 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-nexter-blocks-pro-registers-an-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-21 Wordfence published [CVE-2026-125294](https://www.cve.org/CVERecord?id=CVE-2026-125294) for the Nexter Blocks Pro plugin (`the-plus-addons-for-block-editor-pro`). Wordfence is the CNA and rates it **CVSS 3.1 9.8 Critical**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. NVD shows that score and has not produced its own. The researcher is 0xd4rk5id3. No source read for this entry reports exploitation.

The registration handler keeps a byte-level denylist of user-meta keys and misses a key written with look-alike characters. WordPress's default accent-insensitive collation then treats that key as `wp_capabilities`, so a newly registered account receives the Administrator role. Wordfence says the nonce is printed on any page that contains the Login | Register block, and that the path is open on a default install where user registration is enabled. A site that has user registration turned off is outside the condition Wordfence names.

Every version through **5.0.10** is affected. **5.0.11**, dated 2026-11-16 on the vendor changelog, restricts user-meta keys to an ASCII allowlist. This is the Pro plugin. The free Nexter Blocks plugin is not named in the record.

This is not [Restrictions for BuddyPress](wordpress-bp-restrict.md) or [User Registration Aide](wordpress-user-registration-aide.md).

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-22). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Vendor notified | 2026-11-09 19:43:27 UTC | Wordfence's timeline. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-125294) |
| 5.0.11 | 2026-11-16; time/TZ unknown | The changelog calls it a security fix for the Login \| Register block. [Changelog][cl] |
| **Public announcement** | **2026-11-20; time/TZ unknown** | Wordfence's disclosure date. The page says publicly published November 20. [Wordfence][wf] |
| CVE record | 2026-11-21 18:31:29 UTC | Wordfence published the record. CVSS 3.1 9.8. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-125294) |

## Detection

Read the plugin version from the WordPress plugin list. The Pro plugin's slug is `the-plus-addons-for-block-editor-pro`. **5.0.10 and earlier** are inside the range Wordfence names. A site that has only the free Nexter Blocks plugin is outside this entry. The condition Wordfence names also needs user registration enabled and a page that contains the Login | Register block. Reading the version changes no state.

## Remediation

1. Update Nexter Blocks Pro to **5.0.11 or later**.
2. Until then, turn user registration off, or take the page with the Login | Register block off the public site. Neither replaces the update.
3. The update does not remove an administrator account that was already created.

## Verification

- The installed Pro plugin is **5.0.11 or later**.
- Do not submit a crafted registration to test it.

## Compromise response

No source read for this entry reports an incident. Review accounts with the Administrator role, especially ones created while a version through 5.0.10 was installed, and remove the ones you do not recognize. The update does not end a session that account already has.

## Sources

- [Wordfence][wf] — publicly published 2026-11-20, updated 2026-11-21. CVSS 3.1 9.8 Critical, `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Affected through 5.0.10. Patched in 5.0.11. Researcher 0xd4rk5id3.
- [CVE-2026-125294](https://www.cve.org/CVERecord?id=CVE-2026-125294) — Wordfence, published 2026-11-21T18:31:29.545Z. CWE-269. The record repeats the score and the affected range.
- [Nexter Blocks Pro 5.0.11 changelog][cl] — dated 2026-11-16. Restricts user-meta keys to an ASCII allowlist.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-22. Not listed.

[wf]: https://www.wordfence.com/threat-intel/vulnerabilities/id/8670d9ac-e2b0-4c19-a9d7-00be23a139c4?source=cve
[cl]: https://roadmap.nexterwp.com/en/changelogs/version-5-0-11
