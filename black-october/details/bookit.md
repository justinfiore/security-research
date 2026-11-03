# BookIt: unauthenticated SQL injection on the public booking endpoint

**Last updated:** 2026-11-02 (America/New_York)

[Main BookIt summary](../black-october-2026.md#bookit-unauthenticated-sql-injection-on-the-public-booking-endpoint) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-62048](https://www.cve.org/CVERecord?id=CVE-2026-62048): Patchstack (CNA) CVSS 3.1 9.3 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:N/A:L). NVD has added no score of its own and lists the record as not scheduled for enrichment.** BookIt, a WordPress appointment-booking plugin from Liquid Web / StellarWP (Nexcess), is affected through **2.6.0.6**. Patchstack says the flaw needs no account. The vendor's 2.6.0.7 changelog says it hardened the public booking endpoint and credits the same finder, AndrewN. Neither source names the parameter, the query, or what a successful query returns beyond SQL injection. [Patchstack][ps] [CNA][cve] [changelog][wp]

**Worst case:** Patchstack says an attacker can read, modify, or delete the database, including user accounts and private data. The CNA vector scores confidentiality High and integrity None, so those two descriptions do not match. The plugin changelog does not describe the impact. [Patchstack][ps] [CNA][cve]

**Fixed in 2.6.0.7**, released 2026-10-29. The same release also says it hardened price handling on the public booking endpoint, credited to a different finder (cazy). No separate CVE for that change was found. [changelog][wp]

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-02). Patchstack says this class of flaw is "expected to become exploited" and "used in mass-exploit campaigns." That is a prediction, not a report of observed exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | Finder: AndrewN, through the Patchstack Bug Bounty Program. Patchstack's timeline records the report on 2026-10-22; time/TZ unknown. [Patchstack][ps] [CNA][cve] |
| CVE ID reserved | 2026-07-13 06:14:38.874Z | Patchstack CNA metadata. The reservation is months before the report. [CNA][cve] |
| **Public announcement** | **2026-10-30; time/TZ unknown** | Patchstack entry dated 30 Oct 2026. The CNA `datePublic` is 2026-10-30T15:09:05.000Z. The plugin changelog for 2.6.0.7 is dated 2026-10-29 and does not name the CVE. [Patchstack][ps] [CNA][cve] [changelog][wp] |
| Patch available | 2026-10-29; time/TZ unknown | WordPress.org changelog: 2.6.0.7. The directory lists the plugin last modified October 29, 2026. [changelog][wp] |
| CVE record published | 2026-11-01 16:00:09.158Z | Patchstack CNA. NVD published 2026-11-01. [CNA][cve] [NVD][nvd] |
| CISA KEV | Not listed (catalog 2026.10.30, checked 2026-11-02) | [KEV][kev] |

## Detection

On a **trusted** host, from the WordPress root (`WP_ROOT`), as the site's file owner. These commands only read. They were not exercised on a real site. `--skip-plugins --skip-themes` stops WP-CLI from loading plugin and theme code.

```sh
cd WP_ROOT
wp plugin list --name=bookit --fields=name,status,version --skip-plugins --skip-themes
```

If WP-CLI is unavailable, or the site may be compromised, read the plugin header from the files or from a copied snapshot instead of running WordPress:

```sh
grep -H -m1 -iE '^[[:space:]*]*Version:' WP_ROOT/wp-content/plugins/bookit/bookit.php
```

Versions **2.6.0.6 and earlier** are affected, including copies that never reached 2.6. Include multisite, staging copies, and web-reachable backups. An inactive copy is still files on disk; the reviewed sources do not say whether it is exploitable, so update or remove it.

The vendor changelog places the fix on the public booking endpoint. A site that never exposes a BookIt booking form still has the plugin files. Do not treat a hidden form as proof the endpoint is unreachable.

## Remediation

1. **Update BookIt to 2.6.0.7 or later** from WordPress.org or the site's normal update screen. WordPress.org lists 2.6.0.7 as the current release. [changelog][wp] [Patchstack][ps]
2. **If you cannot update now,** deactivate the plugin or take the booking form offline. That is a mitigation, not a fix. Patchstack says it has a mitigation rule for its own customers; that rule is not a substitute for 2.6.0.7.
3. Updating stops the query the vendor hardened. It does not undo rows an attacker already changed, and it does not remove an administrator account an injected query created.

## Verification

- Re-run the version check and confirm **2.6.0.7 or later** on every site, including staging.
- Submit one ordinary booking and confirm it is stored and the notification email still sends. Do not send SQL payloads.

## Compromise response

The reviewed sources do not publish a query, an indicator, or a confirmed compromise. If the booking form was reachable on 2.6.0.6 or earlier after the patch date, treat database reads and writes as possible rather than proven.

- Preserve web logs and a database dump before cleanup. The public booking endpoint is the path the changelog names; the sources do not give its URL.
- Look for new administrator users, changed user email addresses, and unexpected rows in the plugin's appointment and customer tables. Query the database; a hidden administrator may not appear in the WordPress user screen.
- Look for persistence outside the database: unexpected plugins and must-use plugins, modified core and theme files, and new PHP files under `wp-content/uploads`.
- If you find evidence the query ran, rotate the database password, WordPress salts and keys, and administrator passwords.
- If the host is shared, check other sites on the account.

## Sources

- [Patchstack database entry][ps]: CVSS 3.1 9.3, unauthenticated, affected through 2.6.0.6, patched in 2.6.0.7, published 30 Oct 2026, reported 22 Oct 2026 by AndrewN. Patchstack says the issue is "expected to become exploited"; that is not a report of observed exploitation.
- [CVE record (Patchstack CNA)][cve]: CVSS 3.1 9.3 (confidentiality High, integrity None, availability Low, scope Changed), affected from 0 through 2.6.0.6, unaffected from 2.6.0.7, `datePublic` 2026-10-30T15:09:05.000Z, published 2026-11-01.
- [WordPress.org plugin page and changelog][wp]: 2.6.0.7 on 2026-10-29, "Hardened the public booking endpoint," credited to AndrewN. The same release hardens price handling, credited to cazy, with no CVE found for that change. Active installations are listed as 4,000+.
- [NVD][nvd]: published 2026-11-01, no NVD score, enrichment not scheduled.
- [CISA KEV feed][kev] (not listed, catalog 2026.10.30, checked 2026-11-02).

[ps]: https://patchstack.com/database/wordpress/plugin/bookit/vulnerability/wordpress-bookit-plugin-2-6-0-6-sql-injection-vulnerability?_s_id=cve
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-62048
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-62048
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[wp]: https://wordpress.org/plugins/bookit/
