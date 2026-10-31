# Drupal core: Field UI remote code execution

**Last updated:** 2026-10-31 (America/New_York)

[Main Drupal summary](../black-october-2026.md#drupal-core-field-ui-remote-code-execution) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**SA-CORE-2026-014 / [CVE-2026-108097](https://www.cve.org/CVERecord?id=CVE-2026-108097): the Drupal Security Team (the vendor) rates it Critical, 19/25 (`AC:Basic/A:None/CI:All/II:All/E:Theoretical/TD:Default`). Drupal names the CVE ID in its advisory, but as of 2026-10-26 the CVE Services API returns no record for it and NVD has no entry, so there is no CNA or NVD CVSS score. Not listed in CISA KEV (catalog 2026.10.23, checked 2026-10-26).** A related contributed-module advisory published the same day, **SA-CONTRIB-2026-218 (Entity List, [CVE-2026-108099](https://www.cve.org/CVERecord?id=CVE-2026-108099))**, is also rated Critical 19/25 and has the same exploit-path pattern. [SA-CORE-2026-014][sa-core] [SA-CONTRIB-2026-218][sa-el] [KEV][kev]

**What it is:** A remote code execution flaw in the core **Field UI** module (`field_ui`). Drupal says:

- It is "not directly exploitable with core alone, but multiple serious exploit paths exist with contributed modules."
- "At least one known exploit path does not require authentication."
- "Custom code may also expose the vulnerable functionality."

The advisory does not name the contributed modules. [SA-CORE-2026-014][sa-core]

**Worst case:** Unauthenticated code execution on the web server, which gives full read and write access to site data. The risk vector's confidentiality and integrity values are both "All".

**Exploit status (Drupal's E field):** "Theoretical", which Drupal defines as no public exploit code or documentation. The PSA warned that "exploits might be developed within hours or days". [PSA-2026-10-12][psa] Fortbridge later published a lab reconstruction (2026-10-18) that reaches file disclosure and command execution on 11.4.9 and fails on 11.4.10. The writer module in that lab is synthetic. Fortbridge says the only public contributed module that used the pattern was Entity List, already fixed, and that it found no other public module that writes request data into a `field_ui_table` row. That is public exploit research, not observed exploitation, and it does not change Drupal's score. [Fortbridge][fortbridge]

| Component | Affected | Fixed | Notes |
|---|---|---|---|
| Drupal core 11.4.x | 11.4.0 up to but not including 11.4.10 | **11.4.10** | |
| Drupal core 11.3.x | 11.0.0 up to but not including 11.3.19 | **11.3.19** | 11.2.x and older are end-of-life: **no fix** |
| Drupal core 10.6.x | 8.9.0 up to but not including 10.6.19 | **10.6.19** | 10.5.x and older, Drupal 8 and Drupal 9 are end-of-life: **no fix** |
| Drupal core 12 pre-release | 12.0.0-alpha1 up to but not including 12.0.0-beta2 | **12.0.0-beta2** | Pre-release |
| Entity List (`entity_list`) | below 3.0.10 | **3.0.10** | SA-CONTRIB-2026-218 |

The affected range is the advisory's: `>= 8.9.0 < 10.6.19 || >= 11.0.0 < 11.3.19 || >= 11.4.0 < 11.4.10 || >= 12.0.0-alpha1 < 12.0.0-beta2`. [SA-CORE-2026-014][sa-core]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory (read-only)](#inventory-read-only)
  - [Logs and site review](#logs-and-site-review)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery or report | Unknown date | Reported by Drew Webber (Drupal Security Team) and Octavio Galland. Entity List was also reported by Lee Rowlands and Dave Long. [SA-CORE-2026-014][sa-core] [SA-CONTRIB-2026-218][sa-el] |
| PSA-2026-10-12 pre-announcement | 2026-10-12 (RSS pubDate 16:10:00 +0000) | Announced a core release window of **2026-10-14 16:00–21:00 UTC**, rated Critical 19/25. The PSA's vector (`AC:Complex/…/TD:All`) differs from the final advisory's (`AC:Basic/…/TD:Default`). [PSA][psa] [PSA RSS][psa-rss] |
| Entity List 3.0.10 released | 2026-10-14 15:59:07 UTC | Timestamp from Drupal's release-history feed. [Release history][rh-el] |
| **Public announcement:** SA-CORE-2026-014 | **2026-10-14** (page date). RSS pubDate 16:10:00 +0000 | The RSS timestamp may reflect when the page was created rather than when it was published. It falls inside the announced window. [SA-CORE-2026-014][sa-core] [Core RSS][core-rss] |
| Drupal 11.4.10, 10.6.19 and 11.3.19 released | 2026-10-14 16:16:25, 16:42:50 and 17:10:26 UTC | Labelled "Security update" in the release-history feed. [Release history][rh-core] |
| SA-CONTRIB-2026-218 (Entity List) published | 2026-10-14 (RSS pubDate 17:26:14 +0000) | Critical 19/25. [SA-CONTRIB-2026-218][sa-el] [Contrib RSS][contrib-rss] |
| Drupal 12.0.0-beta2 released | 2026-10-14 21:57:42 UTC | Fixes the 12.x pre-release line. [Release history][rh-core] |
| BleepingComputer coverage | 2026-10-17 | Secondary. [BleepingComputer][bc] |
| Follow-up bug-fix releases 11.4.11, 11.3.20 and 10.6.20 | 2026-10-21 | Not security releases. Being on these versions also includes the fix. [Release history][rh-core] |
| CVE or NVD publication | Not published as of 2026-10-26 | The CVE Services API returns "CVE_RECORD_DNE" for both IDs, and NVD returns no results. [CVE API][cve] [NVD][nvd] |
| CISA KEV | Not listed | Catalog 2026.10.23 checked on 2026-10-26. [KEV][kev] |
| Exploitation evidence | Lab reconstruction published 2026-10-18; no in-the-wild exploitation reported | Fortbridge rebuilt the chain on 11.4.9 with a synthetic writer module and says it fails on 11.4.10. Drupal's E field remains "Theoretical". [Fortbridge][fortbridge] |

## Detection

### Inventory (read-only)

Run these from the Drupal project root, as the deploy user, against each environment (production, staging, and any multisite). They only read data. They were not run on a real site.

```sh
composer show drupal/core drupal/core-recommended 2>/dev/null | grep -E '^(name|versions)'
composer show drupal/entity_list 2>/dev/null | grep -E '^(name|versions)'
vendor/bin/drush status --field=drupal-version
vendor/bin/drush pm:list --status=enabled --filter=field_ui
vendor/bin/drush pm:list --status=enabled --filter=entity_list
```

- Core below the fixed version for its branch: vulnerable. An end-of-life branch is vulnerable and **has no fix**.
- If `field_ui` is **not** enabled, Drupal's mitigation is already in place for CVE-2026-108097. You still need to upgrade.
- If `entity_list` is enabled and below 3.0.10, the site is affected by CVE-2026-108099 **independently of core**.
- Drupal does not name the contributed modules that create exploit paths, so you cannot rule out exposure from your module list. Treat every affected core version as vulnerable.

### Logs and site review

Drupal has published no IOCs. These read-only checks look for signs of compromise rather than proving exploitation:

```sh
vendor/bin/drush watchdog:show --count=200 --severity=Error
vendor/bin/drush sql:query "SELECT name, created, access FROM users_field_data ORDER BY created DESC LIMIT 20"
```

- Review web server access logs from **2026-10-12** onward for unusual requests to Field UI admin routes (`/admin/structure/.../fields` and display pages), especially from anonymous clients.
- Look for new administrator accounts, changed field or display configuration, and new PHP files under `sites/*/files` or the web root.
- Finding nothing proves nothing. Fortbridge's lab uses a synthetic writer module; it is not a list of indicators for a real module.

## Remediation

1. **Update core** to **11.4.10**, **11.3.19** or **10.6.19** (or the later 11.4.11, 11.3.20 or 10.6.20), or to **12.0.0-beta2** on the pre-release line. Use your normal Composer workflow (`composer update drupal/core* --with-all-dependencies`). Then run `drush updatedb` and `drush cache:rebuild`. [SA-CORE-2026-014][sa-core]
2. **Update Entity List** to **3.0.10** if it is installed. A core-only update leaves CVE-2026-108099 open. [SA-CONTRIB-2026-218][sa-el]
3. **Temporary mitigation:** uninstall Field UI (`drush pm:uninstall field_ui`) until you can update. Drupal says this "will provide protection while sites are updated". Field UI provides the admin screens for managing fields. Re-enable it after patching if your site builders need it. Uninstalling it is a state change, so do it in your normal change process. [SA-CORE-2026-014][sa-core]
4. **End-of-life sites** (Drupal 8 and 9, 10.5 and older, 11.2 and older) get no fix. Upgrade to a supported branch, and uninstall `field_ui` in the meantime.
5. Drupal Steward protects against "some known attack vectors" but not all. It does not replace the update. [SA-CORE-2026-014][sa-core]

**Rollback caution:** Restoring an older code base or container image reintroduces the flaw. Database backups taken before the update are fine to keep, but do not restore code older than the fixed release.

## Verification

- `composer show drupal/core` and `drush status --field=drupal-version` report a fixed version in **every** environment and multisite. `composer show drupal/entity_list` reports 3.0.10 or later where installed.
- `drush updatedb:status` shows no pending updates.
- If you used the mitigation, `drush pm:list --status=enabled --filter=field_ui` returns nothing.
- Benign functional check: log in as an administrator on a non-production copy and confirm that the field-management and display pages (if `field_ui` is re-enabled) and Entity List pages work. Do not attempt exploit paths.

## Compromise response

- If an affected, internet-facing site had `field_ui` enabled from 2026-10-14 until it was patched, review it for compromise. Assume that sites using unknown contributed or custom code may have been exposed.
- Look for webshells and modified PHP files: compare the code base with a clean Composer install. Also look for new users and roles, changed configuration (`drush config:status`), and unexpected cron or queue items.
- Rotate secrets that the web server can read, such as database credentials, `settings.php` hash salt, API keys and SMTP credentials. Invalidate sessions.
- If compromise is confirmed, rebuild from clean code and a known-good database backup.

## Sources

- [SA-CORE-2026-014][sa-core]: rating, affected and fixed versions, exploit paths, mitigation, credits.
- [SA-CONTRIB-2026-218][sa-el]: the Entity List rating and fix.
- [PSA-2026-10-12][psa]: release window and pre-announcement rating.
- Drupal release-history feeds for [core][rh-core] and [Entity List][rh-el], and Drupal.org RSS for [core][core-rss], [contrib][contrib-rss] and [PSA][psa-rss] advisories: release and publication timestamps.
- [CVE Services API][cve] and [NVD][nvd]: no published records as of 2026-10-26.
- [CISA KEV feed][kev] (no entry).
- Secondary: [BleepingComputer][bc].

[sa-core]: https://www.drupal.org/sa-core-2026-014
[sa-el]: https://www.drupal.org/sa-contrib-2026-218
[psa]: https://www.drupal.org/psa-2026-10-12
[fortbridge]: https://fortbridge.co.uk/research/cve-2026-108097-deep-dive-turning-a-drupal-field-ui-callback-into-rce/
[core-rss]: https://www.drupal.org/security/rss.xml
[contrib-rss]: https://www.drupal.org/security/contrib/rss.xml
[psa-rss]: https://www.drupal.org/security/psa/rss.xml
[rh-core]: https://updates.drupal.org/release-history/drupal/current
[rh-el]: https://updates.drupal.org/release-history/entity_list/current
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-108097
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-108097
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[bc]: https://www.bleepingcomputer.com/news/security/drupal-patches-critical-rce-flaws-warns-exploits-may-emerge-soon/
