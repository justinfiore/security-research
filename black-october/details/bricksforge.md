# Bricksforge for WordPress: exploited unauthenticated file upload to RCE

**Last updated:** 2026-10-26 (America/New_York)

[Main Bricksforge summary](../black-october-2026.md#bricksforge-for-wordpress-exploited-unauthenticated-file-upload-to-rce) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-85097](https://www.cve.org/CVERecord?id=CVE-2026-85097): Wordfence (CNA) CVSS 3.1 9.8 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H). Patchstack rates it CVSS 10.0, and The Hacker News reports that 10.0 figure. NVD has added no score of its own (status "Deferred"). Not listed in CISA KEV, but Patchstack reports exploitation attempts since 2026-10-07 21:47:17 UTC.** Bricksforge, a WordPress plugin that extends the Bricks Builder visual site builder, lets **unauthenticated** visitors upload and execute PHP code in versions **up to and including 3.1.8.9**. The Pro Forms upload path validates the MIME type of a temporary upload but later trusts the client-supplied `url` field in the `temporaryFileUploads` parameter. An attacker obtains a nonce from the unauthenticated `bricksforge_regenerate_nonce` AJAX action, uploads a GIF/PHP polyglot, then submits a form whose `url` ends in `.php`. [Wordfence][wf] [CNA][cve] [Patchstack][ps]

**Worst case:** remote code execution as the web server user, then web shells, site takeover, data theft and persistence. [Patchstack][ps]

**Fixed in 3.1.8.10.** The vendor changelog also says 4.0.0 contains the fix, and that 4.0.1 (2026-10-08) fixed a further Pro Forms file-upload security issue affecting every site with Pro Forms active. The reviewed sources give no CVE for that second issue. [Bricksforge changelog][cl]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Patchstack reports active exploitation attempts. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Read-only inventory](#read-only-inventory)
  - [File-system indicators](#file-system-indicators)
  - [Log indicators](#log-indicators)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery | Unknown | Credited to researcher d.v4n_s3c. [Wordfence][wf] |
| CVE ID reserved | 2026-09-03 01:41:17 UTC | CNA metadata. [CNA][cve] |
| Vendor notified | 2026-09-03 02:05:26 UTC | Wordfence CNA timeline. [CNA][cve] |
| Bricksforge 4.0.0 released | 2026-09-17; time/TZ unknown | The vendor later stated this release also fixed CVE-2026-85097. [Bricksforge changelog][cl] |
| Bricksforge 3.1.8.10 released (fixed 3.x) | Unknown; on or before 2026-10-07 | Wordfence lists 3.1.8.10 as patched when it published on 2026-10-07. The changelog shows no date for it. [Wordfence][wf] [Bricksforge changelog][cl] |
| **Public announcement: Wordfence and Patchstack database entries** | **2026-10-07; time/TZ unknown** | Wordfence "Publicly Published October 7, 2026"; Patchstack database "Published 7 Oct, 2026". The CNA timeline's "Disclosed 2026-10-07T00:00:00Z" is date-level. [Wordfence][wf] [Patchstack DB][psdb] [CNA][cve] |
| **First observed exploitation attempts** | **2026-10-07 21:47:17 UTC** | Patchstack telemetry. [Patchstack][ps] |
| CVE record published | 2026-10-08 06:42:09 UTC | Wordfence CNA. NVD published 2026-10-08 07:16:31 (NVD API, UTC). [CNA][cve] [NVD][nvd] |
| Bricksforge 4.0.1 released | 2026-10-08; time/TZ unknown | Further Pro Forms upload security fix. [Bricksforge changelog][cl] |
| Patchstack exploitation write-up | 2026-10-08; page time 11:28:37, TZ unknown | 63 source IPs, payload variants, detection list. [Patchstack][ps] |
| CISA ADP SSVC | 2026-10-08 14:24:30 UTC | "Exploitation: none" at that time, Automatable: yes, Technical impact: total. A point-in-time assessment, not a current exploitation verdict. [CNA ADP][cve] |
| News coverage | 2026-10-12 | The Hacker News (CVSS 10.0, citing Patchstack) and SecurityWeek. [THN][thn] [SecurityWeek][sw] |
| Bricksforge 4.0.2 released | 2026-10-13; time/TZ unknown | REST endpoint hardening; temp upload folder now protects itself against execution. [Bricksforge changelog][cl] |
| CISA KEV | Not listed (catalog 2026.10.23, checked 2026-10-26) | [KEV][kev] |

## Detection

### Read-only inventory

On a **trusted** host (not one you suspect is compromised), from the WordPress root directory, as the site's file owner (not root). Placeholder: `WP_ROOT`. These commands only read; `--skip-plugins --skip-themes` stops WP-CLI from loading plugin and theme code. They were not exercised on a real site.

```sh
cd WP_ROOT
wp plugin list --name=bricksforge --fields=name,status,version,update_version --skip-plugins --skip-themes
```

If WP-CLI is unavailable or the site may be compromised, read the plugin header from the files (or from a copied snapshot) instead of running WordPress:

```sh
grep -H -m1 -iE '^[[:space:]*]*Version:' WP_ROOT/wp-content/plugins/bricksforge/*.php
```

Versions **3.1.8.9 and earlier** are affected. Include multisite networks, staging copies and backups that are web-reachable. Inactive plugins are still files on disk; the reviewed sources do not say whether an inactive copy is exploitable, so update or remove it.

### File-system indicators

Patchstack reports PHP files written to `wp-content/uploads/bricksforge/tmp/` and to dated upload folders, with names like `login_admin_*.php`, and many PHP extension variants. [Patchstack][ps] Read-only checks from `WP_ROOT` (run against a snapshot if compromise is suspected):

```sh
cd WP_ROOT
# Executable-looking files anywhere under uploads (case-insensitive)
find wp-content/uploads -type f \( -iname '*.php' -o -iname '*.php[0-9]' -o -iname '*.phtml' -o -iname '*.pht' -o -iname '*.phtm' -o -iname '*.phps' \) -exec ls -l --time-style=full-iso {} +
find wp-content/uploads -type f -iname 'login_admin_*' -exec ls -l --time-style=full-iso {} +
# Image files in the Bricksforge temp folder that contain PHP open tags (polyglots)
grep -rlI --binary-files=text '<?php' wp-content/uploads/bricksforge/tmp/ 2>/dev/null
```

Any PHP file under `uploads` deserves review. Some plugins do legitimately place `index.php` placeholders there, so compare against a clean backup.

### Log indicators

Search web server access logs (placeholder `ACCESS_LOGS`; read-only):

```sh
grep -E 'wp-json/bricksforge/v1/form_submit|bricksforge_regenerate_nonce|bricksforge_form_submit' ACCESS_LOGS
grep -iE 'GET /wp-content/uploads/.*\.(php[0-9]?|phtml?|pht|phps)' ACCESS_LOGS
grep -F -e '177.75.57.20' -e '23.97.62.146' -e '84.247.60.125' -e '38.154.185.97' -e '150.109.16.166' -e '153.75.90.146' ACCESS_LOGS
```

The IPs are the six most active of 63 that Patchstack recorded; they are not a complete list. Access logs usually do not record POST bodies, so the `temporaryFileUploads` payload and AJAX `action` values sent in the body may not appear. A WAF or request-body log is needed to see the image-path/PHP-URL mismatch Patchstack describes. Finding nothing does not prove the site was not compromised. [Patchstack][ps]

## Remediation

1. **Update Bricksforge** to **3.1.8.10 or later** at minimum. The vendor's newer releases (4.0.1 on 2026-10-08, 4.0.2 on 2026-10-13) add a further upload fix and hardening; prefer the current 4.0.x release where your Bricks setup supports it. Whether the 3.1.8.x line received the 4.0.1 fix was not established. [Wordfence][wf] [Bricksforge changelog][cl]
2. **If you cannot update now,** deactivate the plugin, or block `/wp-json/bricksforge/v1/form_submit` and the `bricksforge_form_submit` and `bricksforge_regenerate_nonce` admin-ajax actions at a WAF (this breaks Pro Forms). Patchstack offers a virtual-patch rule. [Patchstack][ps]
3. **Disable PHP execution in `wp-content/uploads`** in the web server or PHP handler configuration as standing hardening.
4. **Older vulnerabilities:** sites still on 3.1.8.7 or earlier are also exposed to earlier Wordfence-listed unauthenticated privilege escalation flaws (≤3.1.8.6 and ≤3.1.8.7, each Wordfence CVSS 9.8). [Wordfence][wf]

## Verification

- Re-run the version check and confirm 3.1.8.10+ (or the 4.0.x version you deployed) on every site, including staging.
- Re-run the file-system check and confirm no unexpected PHP files remain under `uploads`.
- Benign functional control: submit a normal Pro Forms form with a legitimate image upload and confirm it still works. Do not send polyglot or `.php` URL payloads.

## Compromise response

Updating does not remove a web shell or backdoor.

- Preserve web logs, the `uploads` tree and a database dump before cleanup.
- Remove web shells, then look for persistence: unknown administrator users (query the database directly, as hidden admins may not show in the UI), unexpected plugins and must-use plugins (`wp-content/mu-plugins`), modified core, theme and plugin files, scheduled tasks (cron events) and new files outside `uploads`.
- Rotate the database password, WordPress salts and keys in `wp-config.php`, administrator passwords, and API keys stored in plugins (the vendor separately advised renewing API keys stored in Bricksforge tool settings in 4.0.2). [Bricksforge changelog][cl]
- If the host is shared, check other sites and the hosting account for spread. Rebuild from known-good sources if the extent is unclear.

## Sources

- [Wordfence vulnerability record][wf] and [CVE record (Wordfence CNA)][cve]: description, CVSS 9.8, affected and patched versions, vendor-notification date, researcher.
- [Patchstack exploitation write-up][ps] and [Patchstack database entry][psdb]: CVSS 10.0, first observed exploitation 2026-10-07 21:47:17 UTC, IOCs and detection guidance.
- [Bricksforge version changelog][cl]: 4.0.0, 4.0.1, 4.0.2 dates and notes.
- [NVD][nvd]; [CISA KEV feed][kev] (not listed).
- Secondary: [The Hacker News][thn], [SecurityWeek][sw].

[wf]: https://www.wordfence.com/threat-intel/vulnerabilities/wordpress-plugins/bricksforge/bricksforge-3189-unauthenticated-arbitrary-file-upload-via-temporaryfileuploads-parameter
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-85097
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-85097
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[ps]: https://patchstack.com/articles/critical-unauthenticated-arbitrary-file-upload-vulnerability-exploited-in-bricksforge-plugin/
[psdb]: https://patchstack.com/database/WordPress/Plugin/bricksforge/vulnerability/wordpress-bricksforge-plugin-3-1-8-9-unauthenticated-arbitrary-file-upload-via-temporaryfileuploads-parameter-vulnerability
[cl]: https://bricksforge.io/version-changelog/
[thn]: https://thehackernews.com/2026/10/attackers-exploit-cvss-100-bricksforge.html
[sw]: https://www.securityweek.com/bricksforge-wordpress-plugin-vulnerability-exploited-in-the-wild
