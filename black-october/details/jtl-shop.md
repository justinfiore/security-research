# JTL-Shop: the installer still runs after the shop is installed

**Last updated:** 2026-11-27 (America/New_York)

[Main JTL-Shop summary](../black-october-2026.md#jtl-shop-the-installer-still-runs-after-the-shop-is-installed) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

JTL published a security note for the Shop web installer, dated 2026-11-12, and the CVE record was published on 2026-11-19. JTL rates [CVE-2026-123058](https://www.cve.org/CVERecord?id=CVE-2026-123058) **Critical, CVSS 4.0 9.2** and **CVSS 3.1 9.0**. JTL's reference is SHOP-9985. JTL is the issuer of the score. The note says the installer keeps running its installation steps after the shop is already installed, and it is not removed or locked. A request with no login can use that to take the shop over.

JTL says that fix is in **Shop 5.8.4, 5.7.6, 5.6.6, and 5.5.5**. The note's table says **5.0.0 through 5.8.3** are affected where the `install/` directory is still present and reachable, and that **5.0.x through 5.4.x are affected, no longer maintained, and get no patch**. Those shops have to move to a supported line. The CVE record lists only the four supported lines. The note says JTL knows of no exploitation as of November 12, and that the update does not delete an existing `install/` directory. The note is in German.

On 2026-11-24 JTL published four more notes. The builds that close them are **5.8.5, 5.7.7, 5.6.7, and 5.5.6**. The November 12 builds leave all four.

| CVE | JTL reference | What it is | JTL score | ENISA score | Affected | Fixed in |
|---|---|---|---|---|---|---|
| [CVE-2026-133939](https://www.cve.org/CVERecord?id=CVE-2026-133939) | SHOP-10575 | A search term in the page-builder start menu runs script in a logged-in backend browser | CVSS 4.0 8.6 High | CVSS 3.1 9.3 Critical | 5.0.0 through 5.8.4 | 5.8.5, 5.7.7, 5.6.7, 5.5.6 |
| [CVE-2026-133938](https://www.cve.org/CVERecord?id=CVE-2026-133938) | SHOP-10619 | The backend language switch has no token and stores a value that later runs as script | CVSS 4.0 8.6 High | CVSS 3.1 9.3 Critical | 5.2.3 through 5.8.4 | 5.8.5, 5.7.7, 5.6.7, 5.5.6 |
| [CVE-2026-133941](https://www.cve.org/CVERecord?id=CVE-2026-133941) | SHOP-10636 | The country manager writes `activeSortOrder` into script | CVSS 4.0 8.6 High | CVSS 3.1 9.3 Critical | 5.6.0 through 5.8.4 | 5.8.5, 5.7.7, 5.6.7 |
| [CVE-2026-133940](https://www.cve.org/CVERecord?id=CVE-2026-133940) | SHOP-10477 | A backup under `export/backup` downloads with no login | CVSS 4.0 8.2 High | CVSS 3.1 5.9 Medium | 5.0.0 through 5.8.4 | 5.8.5, 5.7.7, 5.6.7, 5.5.6 |

JTL says the three script flaws have no known exploitation as of November 24. For the backup files, it says automated requests on November 19 came back 404 and it knows of no successful download. ENISA published the four records on November 27. The vectors JTL prints are `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:P/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N` for the three script flaws and `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N` for the backup files. ENISA's 9.3 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:N`. The 5.9 vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:N/A:N`. Keep both scores: JTL calls each note High, and ENISA's 3.1 score on the script flaws is Critical.

The update blocks `export/backup` only where Apache reads `.htaccess`. On nginx, and on a reverse proxy that serves the files itself, block the folder on the server. 5.0 through 5.4 get patch files and patch diffs rather than a release, except the country manager, which starts at 5.6.0. One zip holds the corrections for all four November 24 notes, with a folder per Shop version from 5.0.0 through 5.8.4. A database migration does not clean a language value the language-switch flaw already stored.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-27) for any of the five. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| JTL note | 2026-11-12; the page says modified 09:29:30 UTC | Installer. Fixed in 5.8.4, 5.7.6, 5.6.6, and 5.5.5. [Note][note] |
| **CVE record** | **2026-11-19 12:18:39 UTC** | [CVE-2026-123058](https://www.cve.org/CVERecord?id=CVE-2026-123058). |
| **Four notes** | **2026-11-24; time/TZ unknown** | 5.8.5, 5.7.7, 5.6.7, and 5.5.6. [Start menu][opc], [language switch][lang], [country manager][countries], [backups][backup] |
| **Four records** | **2026-11-27; time/TZ unknown** | ENISA published CVE-2026-133938 through CVE-2026-133941. |

## Detection

Read the Shop version from the administration page. Below 5.8.5, 5.7.7, 5.6.7, or 5.5.6, the November 24 notes still apply, with the ranges in the table above. The country manager starts at 5.6.0. The language switch starts at 5.2.3. A 5.0 through 5.4 shop is inside the installer, the start menu, and the backup files, and gets no release. A missing `install/` directory is not proof the build is fixed. A backup folder that answers 404 today is not proof it did on November 19.

## Remediation

1. Update Shop to **5.8.5, 5.7.7, 5.6.7, or 5.5.6** or later. The November 12 builds, 5.8.4, 5.7.6, 5.6.6, and 5.5.5, leave the four November 24 notes. A 5.0 through 5.4 shop has to move to one of those lines. Until it does, apply the patch files for that version from JTL's November 24 package.
2. Block `export/backup` on the server. The update does this only on Apache, and only when `.htaccess` is read. On nginx, do it in the server configuration.
3. Remove the `install/` directory after the update. The update does not delete it.
4. The update does not show whether a request already reinstalled the shop, changed an administrator, downloaded a backup, or ran script in a backend browser. A stored language value is not cleaned by the migration.

## Verification

- The administration page shows one of the November 24 builds, or later.
- A request for a file under `export/backup` is refused by the web server, including on nginx.
- The storefront still serves a page. Do not call the installer.

## Compromise response

JTL does not report exploitation of the installer or the three script flaws. It reports automated requests for backup files on November 19 that came back 404, and no successful download. A shop that was reachable with the installer still present, or with `export/backup` served, should be reviewed for an administrator, a configuration change, a file the owner did not add, and access to a backup. Reset a backend password whose hash was in a backup that may have been downloaded. The update does not undo any of that.

## Sources

- [JTL note, web installer not locked][note] — version 1.0, published 2026-11-12. Critical, CVSS 4.0 9.2 and CVSS 3.1 9.0. Fixed in Shop 5.8.4, 5.7.6, 5.6.6, and 5.5.5. Reference SHOP-9985.
- [JTL note, page-builder start menu][opc] — published 2026-11-24. CVSS 4.0 8.6 and CVSS 3.1 9.3. SHOP-10575. CVE-2026-133939.
- [JTL note, backend language switch][lang] — published 2026-11-24. Same scores. SHOP-10619. CVE-2026-133938.
- [JTL note, country manager][countries] — published 2026-11-24. Same scores. Starts at 5.6.0. SHOP-10636. CVE-2026-133941.
- [JTL note, backup files][backup] — published 2026-11-24. CVSS 4.0 8.2 and CVSS 3.1 5.9. SHOP-10477. CVE-2026-133940. The update blocks the folder only on Apache.
- [CVE-2026-123058](https://www.cve.org/CVERecord?id=CVE-2026-123058) — published 2026-11-19.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-27. None of the five is listed.

[note]: https://www.jtl-software.com/de/security/sicherheitshinweis-web-installer_nicht_gesperrt/
[opc]: https://www.jtl-software.com/de/security/sicherheitshinweis-opc-startmenue_xss/
[lang]: https://www.jtl-software.com/de/security/sicherheitshinweis-backend-sprachumschaltung_xss/
[countries]: https://www.jtl-software.com/de/security/sicherheitshinweis-backend-laenderverwaltung_xss/
[backup]: https://www.jtl-software.com/de/security/sicherheitshinweis-sicherungsdateien-export_backup_abrufbar/
