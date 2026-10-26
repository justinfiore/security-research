# Rank Math PRO for WordPress: malicious 3.0.123 builds from the official update channel

**Last updated:** 2026-10-26 (America/New_York)

[Main Rank Math PRO summary](../black-october-2026.md#rank-math-pro-for-wordpress-malicious-30123-builds-from-the-official-update-channel) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-111862](https://www.cve.org/CVERecord?id=CVE-2026-111862): Wordfence (CNA) CVSS 3.1 9.8 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H), CWE-506 Embedded Malicious Code. Patchstack also lists 9.8 ("High" priority, classified as a backdoor). NVD has added no score of its own (status "Deferred"; it shows Wordfence's score as secondary). Not listed in CISA KEV; the vendor confirmed that its own download and update channel delivered the malware.** This is a malicious-release incident, not a coding flaw: some copies of Rank Math PRO **3.0.123**, the paid edition of the Rank Math SEO plugin, that were **downloaded from rankmath.com or installed through an update between 2026-10-15 20:02 UTC and 2026-10-16 07:12 UTC** contained malware. The version number alone does not identify an affected copy. 3.0.123 was first released clean on 2026-10-07, and copies obtained outside the window are not claimed as affected. Rank Math says the malware could compromise a site **if the plugin was activated**, and it tells sites that activated an affected copy to treat the site as compromised. The free Rank Math SEO plugin from WordPress.org is not affected. [Rank Math notice][rm] [CNA][cve] [Wordfence][wfdb] [Patchstack][ps]

**Worst case:** persistent attacker access to the site and server. Rank Math and the CNA record say the malware can recreate a hidden backdoor on page visits, communicate with `rank1cdn[.]com`, add administrator accounts, plant PHP backdoors, a fake core file, PHP-executable `.cache` files and cron jobs, and expose every password, database credential, API key and other secret the web server can read. Rank Math warns of changes outside the WordPress directory too (SSH keys, other users' crontabs, processes). [Rank Math notice][rm] [CNA][cve]

**Clean release: 3.0.124 (2026-10-16).** It replaces the plugin files only. It does **not** remove files, accounts, database entries or scheduled tasks the malware already created. [Rank Math changelog][cl] [Wordfence blog][wfb]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Rank Math confirmed that copies of 3.0.123 distributed through its official download and update channel during the affected window contained malware. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Which sites need investigation](#which-sites-need-investigation)
  - [File-system indicators](#file-system-indicators)
  - [Database indicators](#database-indicators)
  - [Cron, server and network indicators](#cron-server-and-network-indicators)
  - [Offline indicator script](#offline-indicator-script)
  - [What a negative result cannot prove](#what-a-negative-result-cannot-prove)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Rank Math PRO 3.0.123 released (clean) | 2026-10-07; time/TZ unknown | Bug-fix release. The same version number was later served with malware. [Rank Math changelog][cl] |
| Domain `rank1cdn.com` registered | 2026-10-14 19:31:14 UTC | Verisign RDAP registry record, cited by the CNA and The Hacker News. Registration is not evidence of when the attacker gained access. [RDAP][rdap] [THN][thn] |
| Private discovery | 2026-10-15 (date only; time and discoverer unknown) | CNA timeline "Discovered"; Wordfence lists the researcher as unknown. Rank Math gives no discovery time. [CNA][cve] [Wordfence blog][wfb] |
| **Affected download/update window opens** | **2026-10-15 20:02 UTC** | Rank Math; equals 16:02 EDT. [Rank Math notice][rm] |
| **Affected window closes** | **2026-10-16 07:12 UTC** | Rank Math removed the affected files. [Rank Math notice][rm] |
| Clean release 3.0.124 | 2026-10-16; time/TZ unknown | Changelog: "Cleaned up PRO package v3.0.123". [Rank Math changelog][cl] |
| **Public announcement: Rank Math security notice** | **2026-10-16 20:32:21 UTC** | Page publication metadata (`article:published_time`). [Rank Math notice][rm] |
| Wordfence PSA and vulnerability record | 2026-10-16; time/TZ unknown | Blog dated October 16 and record "Publicly Published October 16, 2026". The Hacker News dates the Wordfence advisory October 17. [Wordfence blog][wfb] [Wordfence record][wfdb] [THN][thn] |
| Patchstack database entry | 2026-10-17; time/TZ unknown | No virtual-patch rule possible because the attack was on vendor infrastructure. [Patchstack][ps] |
| CVE ID reserved | 2026-10-17 02:00:53 UTC | CNA metadata. [CNA][cve] |
| CVE record published | 2026-10-19 16:35:59 UTC | Wordfence CNA. NVD published 2026-10-19 17:17:04 (NVD API, UTC). [CNA][cve] [NVD][nvd] |
| News coverage | 2026-10-19 | The Hacker News; SecurityWeek (11:20 AM ET); BleepingComputer. [THN][thn] [SecurityWeek][sw] [BleepingComputer][bc] |
| CISA ADP SSVC | 2026-10-20 14:10:17 UTC | "Exploitation: none", Automatable: yes, Technical impact: total. A point-in-time CISA assessment, not a finding that no site was compromised. [CNA ADP][cve] |
| Vendor statement: "several hundred customers" | 2026-10-20 (article date) | Rank Math statement to The Repository. It did not say how attackers got in. [The Repository][repo] |
| Rank Math notice last modified | 2026-10-22 10:01:47 UTC | Page metadata only; what changed was not established. [Rank Math notice][rm] |
| CISA KEV | Not listed (catalog 2026.10.23, checked 2026-10-26) | [KEV][kev] |

**Root cause:** not published as of 2026-10-26. Rank Math has not said how the files entered its download and update system, which systems were involved, or published hashes of clean and tainted packages. [THN][thn] [The Repository][repo]

## Detection

### Which sites need investigation

1. List every site with Rank Math PRO, including staging copies, multisite networks, agency or client sites, and sites managed through a central update tool.
2. Establish **when** each site obtained 3.0.123 and **whether it was activated**. A 3.0.123 obtained before 2026-10-15 20:02 UTC is outside the window. Useful records include Rank Math's notification email (the vendor says it has download records and emailed affected users), update or activity logs, management-tool logs and backup file listings. File modification times on the site are not reliable download times.
3. Apply the vendor's three cases: installed **and** activated in the window → treat as compromised; installed but never activated → delete the files, install 3.0.124, scan; downloaded but never installed → no indication of compromise from this incident alone. If you cannot tell, treat the site as compromised. A site that has since updated to 3.0.124 is still in scope. [Rank Math notice][rm] [Wordfence blog][wfb]

Read the installed version from the files rather than running WordPress (placeholder `WP_ROOT`; read-only; prefer a copy or snapshot of a suspect site):

```sh
grep -H -E '^[[:space:]*]*Version:' WP_ROOT/wp-content/plugins/rank-math-pro/*.php
```

### File-system indicators

All from the Rank Math notice. Run read-only, against a snapshot if possible, from `WP_ROOT`:

```sh
cd WP_ROOT
# Fake core file (not part of WordPress)
ls -l wp-includes/class-wp-cache-util.php
# Vendor-named key and domain in code files
find . -type f \( -name '*.php' -o -name '*.cache' -o -name '.htaccess' \) -exec grep -l -F -e xmmqhn -e rank1cdn {} +
# .cache files containing PHP, and .htaccess rules involving .cache
find . -type f -name '*.cache' -exec grep -l -F '<?php' {} +
find . -type f -name '.htaccess' -exec grep -n -i -F '.cache' {} +
# PHP in places to review by hand
find wp-content/mu-plugins wp-content/uploads -type f -name '*.php' -exec ls -l {} + 2>/dev/null
```

Also review the `inc/`, `includes/` and `lib/` folders of non-default themes, other plugins' folders and the Rank Math `includes/` folder for PHP that combines `base64_decode` with XOR loops, or uses `proc_open` or PHP-FPM socket code. Those constructs also occur in legitimate code, so a hit needs review, not automatic deletion. [Rank Math notice][rm]

### Database indicators

Query a restored copy of the database from a trusted host, or run read-only `SELECT` statements; do not load the suspect site to look. Replace `wp_` with the site's `$table_prefix` from `wp-config.php`; on multisite, repeat the options query for each `wp_N_options` table.

```sql
SELECT option_name, autoload FROM wp_options
 WHERE option_name IN ('_uf6qdn2hmm', 't8krdk990phb', '_np5pvf754c');

SELECT u.ID, u.user_login, u.user_email, u.user_registered
  FROM wp_users u JOIN wp_usermeta m ON m.user_id = u.ID
 WHERE m.meta_key = 'wp_capabilities' AND m.meta_value LIKE '%administrator%';

SELECT ID, user_login, user_email, user_registered FROM wp_users
 WHERE user_login LIKE 'wpsupport\_%' OR user_email LIKE '%@wp-mail.net';
```

Any of the three option names, an unknown administrator, a `wpsupport_` username or an `@wp-mail.net` address is an indicator. Review every administrator, not only those matching the patterns. On multisite, also check super admins (`site_admins` in `wp_sitemeta`). [Rank Math notice][rm]

### Cron, server and network indicators

- Crontab of the web server user (and other users) with entries tagged `#ms6v46`, for example `sudo crontab -l -u www-data | grep -F '#ms6v46'` (read-only; substitute the actual user). [Rank Math notice][rm]
- WordPress scheduled events you do not recognize (stored in the `cron` option).
- SSH `authorized_keys` files, running processes, and files outside the site in locations the web server user can write.
- DNS, proxy or firewall logs showing lookups of or connections to `rank1cdn.com`. Treat it as an indicator to search for, **not a URL to visit**. The legitimate vendor domain is `rankmath.com`.

The vendor's notice also suggests WP-CLI (`wp user list --role=administrator`, `wp cron event list`). WP-CLI loads WordPress, and so can run the site's malicious code. Use it only after the vendor's Step 1 containment, or prefer the database queries above.

### Offline indicator script

[rankmath-ioc-check.sh](../rankmath-ioc-check.sh) checks a WordPress copy for the fake core file, the installed Rank Math PRO version, the strings `xmmqhn` and `rank1cdn` in PHP, `.cache` and `.htaccess` files, `.cache` files containing PHP, and `.htaccess` lines pairing `.cache` with a PHP handler. Optionally, it searches operator-supplied text exports (an SQL dump, saved query output or saved `crontab -l` output) for the three option names, `wpsupport_`, `@wp-mail.net`, `rank1cdn` and `#ms6v46`.

```sh
# Placeholders: a read-only copy of the site and optional exports made by you.
sh rankmath-ioc-check.sh /mnt/snapshot/WP_ROOT site-db.sql www-data-crontab.txt
```

- **Platform and requirements:** POSIX `sh` with `find`, `grep`, `sed`, `ls` and `head`. Run from any working directory as a user who can read the copy; no root needed for a copy.
- **Safety:** it only reads. It does not run PHP, WordPress, WP-CLI or a database client, contact the network, follow symlinks or change files.
- **Exit status:** `0` no indicators found by the checks that ran (**not** proof the site is clean); `1` at least one indicator found; `2` unknown (bad arguments, unreadable input or files, not a WordPress root, or a 3.0.123 copy whose download time the files cannot establish). `1` takes precedence over `2`.
- **Limits:** it checks only the default `rank-math-pro` folder name and `WP_ROOT/wp-content`. It does not judge PHP files that lack the named strings, server-wide crontabs, SSH keys, processes or logs, and it does not query a live database. The `.htaccess` check matches single lines only; review multi-line `<FilesMatch>` blocks by hand. A security plugin's own signature files could contain the strings it searches for. Without an evidence file it prints `NOT CHECKED` for the database and cron indicators. It was tested only on disposable fixtures, not on a real compromised site.

### What a negative result cannot prove

The malware can recreate its backdoor and may have left changes outside WordPress. Rank Math and Wordfence published indicators, not a full malware analysis, so other files and names may exist. Missing indicators, clean checksums or a current 3.0.124 header do not prove a site that activated an affected copy is clean. Missing logs or exports mean **unknown**. [Wordfence blog][wfb] [THN][thn]

## Remediation

Follow the [Rank Math notice][rm] for the authoritative steps; this summary keeps its order.

1. **Installed but never activated:** delete the `rank-math-pro` folder, install 3.0.124 from your Rank Math account, and run a security scan. **Downloaded but never installed:** discard the archive, including copies cached by management tools.
2. **Activated, preferred: restore** the site **and database** from a backup made before **2026-10-15 20:02 UTC**, scan, change all passwords and credentials (see [Compromise response](#compromise-response)), then install 3.0.124 last. A restore does not reverse changes the attacker made outside the restored files and database, such as crontabs or SSH keys, so check those too.
3. **Activated, no clean backup: clean manually, in this order.** The malware can recreate its backdoor when someone visits the site, so first:
   1. Delete the entire `rank-math-pro` plugin folder. Deactivating is not enough.
   2. Delete the `wp_options` rows named `_uf6qdn2hmm`, `t8krdk990phb` and `_np5pvf754c`.
   3. Block outbound connections to `rank1cdn.com` at the host or firewall if possible.

   Only then remove the other indicators listed under [Detection](#detection): backdoor files, unknown administrators, the fake core file (then reinstall WordPress core from an official source), `.htaccess` rules and `.cache` files, malicious cron entries and scheduled events, and changes outside the site. Reinstall other plugins and themes from official sources. Hand the work to the host or a security professional if you are not comfortable with files, the database and server settings.
4. **Install 3.0.124** downloaded by signing in at `rankmath.com` directly. Rank Math says it never sends login or download links by email, so treat such emails as phishing. Some customers may need to reset their Rank Math account password. [Rank Math notice][rm]
5. **Sites that never had an affected copy:** update to 3.0.124 or later as normal. Patchstack notes that no firewall rule can mitigate a vendor-infrastructure compromise. [Patchstack][ps]

**Rollback cautions:** do not restore any backup taken after the window opened without checking it for the indicators. Do not reinstall a 3.0.123 archive from a local cache or management tool. Do not rely on deactivating the plugin or on the update to 3.0.124 alone.

**Side effect:** Rank Math removed free accounts registered 2026-10-13 to 2026-10-16 during a system refresh. The free plugin keeps working, but those users must recreate and reconnect their accounts. This is not a sign of site compromise. [Rank Math notice][rm]

## Verification

- Read the plugin header from the files and confirm **3.0.124** or later on every site.
- Confirm that `wp-includes/class-wp-cache-util.php` is absent and that the three option names, unknown administrators, `#ms6v46` cron entries and `rank1cdn.com` traffic do not return over the following days. Rank Math says files that reappear mean the cleanup is incomplete.
- Run `wp core verify-checksums` and, where available, `wp plugin verify-checksums --all` from a contained or cleaned site, as Rank Math recommends. WordPress.org publishes no checksums for Rank Math PRO (The Hacker News checked on 2026-10-19), so compare its files with a fresh copy downloaded from your Rank Math account. [THN][thn]
- Re-run the [offline indicator script](#offline-indicator-script) with fresh database and crontab exports.
- Benign functional control: confirm that SEO settings, sitemaps and the Rank Math account connection work after reinstalling. Do not fetch or execute the malware or contact `rank1cdn.com`.

## Compromise response

Updating does not remove a backdoor. For any site that activated an affected copy:

- **Preserve evidence first:** copies of the files, database, web and PHP logs, crontabs and egress logs.
- **Rotate everything the site could reach,** even after a restore: WordPress user passwords, the database username and password in `wp-config.php`, WordPress keys and salts (this also ends existing logged-in sessions), payment-gateway, SMTP and other API keys stored in settings or configuration, hosting control panel, FTP/SFTP and SSH credentials, and secrets in environment variables. Review and reset administrators' two-factor authentication. [Rank Math notice][rm]
- **Look beyond WordPress:** SSH `authorized_keys`, other users' crontabs, running processes, and writable locations outside the site. On shared hosting, ask the host to check these and other sites in the same account. Rebuild from known-good sources if the extent is unclear.
- **Check downstream exposure:** review payment, email and API provider logs for use of the rotated keys, and look for content or SEO spam changes made through the added administrators.
- Ask Rank Math support if you are unsure whether an affected copy was installed or activated. [Rank Math notice][rm]

## Sources

- [Rank Math security notice][rm]: affected window, three cases, ordered cleanup, IOCs, credential rotation, 3.0.124, free-account side effect. Published 2026-10-16 20:32:21 UTC, modified 2026-10-22 10:01:47 UTC (page metadata).
- [Rank Math PRO changelog][cl]: 3.0.123 (2026-10-07) and 3.0.124 (2026-10-16) dates.
- [CVE record (Wordfence CNA)][cve], [Wordfence record][wfdb] and [Wordfence PSA][wfb]: CVSS 9.8, CWE-506, affected and patched versions, timeline, IOC summary, CISA ADP SSVC.
- [Patchstack database entry][ps]: 9.8, backdoor classification, no mitigation rule possible.
- [NVD][nvd]: status "Deferred", Wordfence score shown as secondary. [CISA KEV feed][kev]: not listed.
- [Verisign RDAP for rank1cdn.com][rdap]: registration 2026-10-14 19:31:14 UTC.
- Secondary: [The Hacker News][thn] (undisclosed root cause, no PRO checksums on WordPress.org), [The Repository][repo] (vendor statement: "several hundred customers"), [SecurityWeek][sw], [BleepingComputer][bc].

Sources read on 2026-10-26. No malicious package was obtained or run, `rank1cdn.com` was not contacted (only its registry record was read), and no real affected site was examined. No root-cause statement, package hashes or full malware analysis had been published in the sources reviewed.

[rm]: https://rankmath.com/kb/pro-3-0-123-security-incident/
[cl]: https://rankmath.com/changelog/pro/
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-111862
[wfdb]: https://www.wordfence.com/threat-intel/vulnerabilities/id/81cd7a2c-ad0c-4dbc-b5dc-07ec866d5c1f
[wfb]: https://www.wordfence.com/blog/2026/10/rank-math-seo-pro-3-0-123-malware/
[ps]: https://patchstack.com/database/wordpress/plugin/seo-by-rank-math-pro/vulnerability/wordpress-rank-math-seo-pro-plugin-3-0-123-unauthenticated-embedded-malicious-code-vulnerability
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-111862
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[rdap]: https://rdap.verisign.com/com/v1/domain/rank1cdn.com
[thn]: https://thehackernews.com/2026/10/popular-wordpress-seo-plugin-rank-math.html
[repo]: https://www.therepository.email/rank-math-confirms-system-breach-delivered-malware-to-several-hundred-pro-customers
[sw]: https://www.securityweek.com/rank-math-pro-wordpress-plugin-compromised-in-supply-chain-attack
[bc]: https://www.bleepingcomputer.com/news/security/wordPress-seo-plugin-rank-math-compromised-to-backdoor-websites/
