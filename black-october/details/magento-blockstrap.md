# Adobe Commerce / Magento Open Source: BlockStrap - unauthenticated template-injection RCE

**Last updated:** 2026-10-27 (America/New_York)

[Main BlockStrap summary](../black-october-2026.md#adobe-commerce--magento-open-source-blockstrap---unauthenticated-template-injection-rce) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-103849](https://www.cve.org/CVERecord?id=CVE-2026-103849) ("BlockStrap"): Adobe (CNA) CVSS 3.1 10.0 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H), CWE-1336, no authentication required. NVD lists Adobe's score as its only CVSS data (status "Awaiting Analysis"). Adobe rates the bulletin priority 2 and was not aware of exploits in the wild at publication; Sansec had seen no attacks on live stores as of 2026-10-15.** [Adobe][apsb] [CNA][cve] [NVD][nvd] [Sansec][sansec]

BlockStrap is a template-engine injection in Magento's email template filter (`Magento\Framework\Filter\Template`). Sansec describes it as a second-pass directive injection: the September StyleSmuggler hotfix signs trusted deferred directives, but attacker-controlled text in a child template can still be signed and rescanned at the root level, where a smuggled `{{block}}` directive runs inside Magento's rendering. Adobe's October patch replaces the signed rescan with registered placeholders. [Sansec][sansec] [Mage-OS 3.6.0][mageos]

**Affected (Adobe bulletin):** Adobe Commerce 2.4.4 through 2.4.9 at "-2026-sep" and earlier; Adobe Commerce B2B 1.3.3, 1.3.4, 1.4.2, 1.5.2 and 1.5.3 at "-2026-sep" and earlier; Magento Open Source 2.4.6 through 2.4.9 at "-2026-sep" and earlier. The CVE record's Magento Open Source entry lists only 2.4.7–2.4.9. Mage-OS up to 3.5.0 is affected (Sansec); Mage-OS 3.6.0 contains the fix. [Adobe][apsb] [CNA][cve] [Sansec][sansec] [Mage-OS 3.6.0][mageos]

**Attack conditions:** network access to the storefront; no account and no user interaction (CNA vector). Sansec reproduced four code-execution routes within 24 hours of the patch and did not publish them. A third-party public validation lab (created 2026-10-18) documents one unauthenticated carrier through guest GraphQL checkout operations and the failed-payment email path; it proves the directive-dispatch primitive and a bounded file side effect, but states it does **not** prove full code execution on stock Magento. [Sansec][sansec] [Lab re-analysis][lab]

**Worst case:** arbitrary PHP execution as the web server user on the store server, with access to the database, customer and order data, `app/etc/env.php` secrets and checkout pages (card skimming). [Adobe][apsb] [Sansec][sansec]

**Related fixes in the same bulletin (separate flaws, all Adobe CNA CVSS 3.1, same patch):** [Adobe][apsb]

- [CVE-2026-92909](https://www.cve.org/CVERecord?id=CVE-2026-92909): incorrect authorization leading to arbitrary code execution, 9.8 Critical (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H), no authentication. The bulletin marks it **B2B**; the CVE record's product list also names Adobe Commerce and Magento Open Source. [CNA 92909][cve92909]
- [CVE-2026-91013](https://www.cve.org/CVERecord?id=CVE-2026-91013) and [CVE-2026-100133](https://www.cve.org/CVERecord?id=CVE-2026-100133): stored XSS leading to privilege escalation, 9.3 Critical each (AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:N); no authentication, but a victim must view the injected content. Sansec ties CVE-2026-91013 to the `EmailAddress.php` change missing from the first 2.4.8-p5 patch. [CNA 91013][cve91013] [CNA 100133][cve100133] [Sansec][sansec]
- [CVE-2026-92464](https://www.cve.org/CVERecord?id=CVE-2026-92464): improper input validation leading to arbitrary code execution, 9.1 Critical (AV:N/AC:L/PR:H/UI:N/S:C/C:H/I:H/A:H); requires **high privileges** (an admin-level account). [CNA 92464][cve92464]
- The bulletin also fixes five High issues (CVSS 8.7–7.2) and one Medium issue; see [APSB26-153][apsb].

**Separate prerequisite:** the October patch does **not** include the September StyleSmuggler hotfix (`VULN-39341`, [CVE-2026-75650](https://www.cve.org/CVERecord?id=CVE-2026-75650), APSB26-146), which CISA KEV lists as exploited (added 2026-09-08). Both fixes are required. [Adobe KB][kb] [StyleSmuggler KB][kb146] [KEV][kev]

**CISA KEV:** Not listed (catalog 2026.10.27, checked 2026-10-28). No exploitation of CVE-2026-103849 was reported by Adobe (2026-10-13) or Sansec (2026-10-15); CISA's ADP assessment records "Exploitation: poc". Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Read-only inventory](#read-only-inventory)
  - [Patch-state checks](#patch-state-checks)
  - [Database and file indicators](#database-and-file-indicators)
  - [Log indicators](#log-indicators)
  - [Official and vendor tools](#official-and-vendor-tools)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| StyleSmuggler hotfix (APSB26-146, CVE-2026-75650, `VULN-39341`) | 2026-09-07; time/TZ unknown | Prerequisite context; exploited zero-day. KEV added 2026-09-08. [StyleSmuggler KB][kb146] [KEV][kev] |
| Private discovery/report | Unknown | Adobe credits researcher "vozec"; CNA source "EXTERNAL". [Adobe][apsb] [CNA][cve] |
| CVE ID reserved | 2026-10-01 11:27:51 UTC | Adobe CNA metadata. [CNA][cve] |
| **Public announcement: Adobe bulletin APSB26-153** | **2026-10-13; CNA `datePublic` 2026-10-13 17:00:00 UTC** | Priority 2; "not aware of any exploits in the wild". [Adobe][apsb] [CNA][cve] |
| October isolated patches released (2.4.4-p18, 2.4.5-p17, 2.4.6-p15, 2.4.7-p10, 2.4.8-p5, 2.4.9) | 2026-10-13; time/TZ unknown | Isolated patch files only, no Composer packages; 2.4.6 and older downloads require Adobe Commerce Composer keys. [Adobe KB][kb] |
| CVE records published (all five bulletin CVEs in this guide) | 2026-10-13 18:15:47–18:15:53 UTC | Adobe CNA. CVE-2026-103849 at 18:15:53 UTC. [CNA][cve] |
| NVD publication of CVE-2026-103849 | 2026-10-13 19:17:53 (NVD API, UTC) | Status "Awaiting Analysis"; Adobe score only. [NVD][nvd] |
| Lock-file side effect reported (magento/magento2 #41535) | 2026-10-13 21:42:54 UTC | Patch creates an empty file named `976bc24c…a228` in the Magento root. [GitHub issue][issue] |
| Sansec reproduces four RCE routes; Shield rules deployed | 2026-10-14; time/TZ unknown | [Sansec][sansec] |
| Adobe corrects the 2.4.8-p5 patch zip and publishes `248p5-2026-10-002-CE` | 2026-10-14; time/TZ unknown | Missing `EmailAddress.php` change for CVE-2026-91013; BlockStrap fix was in both versions. Per Sansec; Adobe KB links a replacement article. [Sansec][sansec] [Adobe 2.4.8-p5 KB][kb2485] |
| Mage-OS 3.6.0 (fixed) | 2026-10-14 (release notes); GitHub release published 2026-10-15 14:26:31 UTC | Ports `249-2026-10-001-CE`; Mage-OS 3.5.0 reaches end of life. [Mage-OS 3.6.0][mageos] [GitHub release][mageosgh] |
| CISA ADP SSVC assessment | Timestamp 2026-10-14 00:00:00 UTC; ADP record updated 2026-10-20 03:55:26 UTC | Exploitation "poc", Automatable "yes", Technical impact "total". [CNA ADP][cve] |
| **Sansec analysis published** | **2026-10-15; time/TZ unknown** | No exploitation observed on live stores. [Sansec][sansec] |
| BleepingComputer coverage | 2026-10-16; page shows 04:00 PM, TZ not stated | Repeats Sansec; no attacks observed. [BleepingComputer][bc] |
| Adobe KB ka-49323 last updated | 2026-10-16; time/TZ unknown | [Adobe KB][kb] |
| Public validation lab (dinosn) created | 2026-10-18 08:12:41 UTC | Primitive + guest GraphQL carrier; no stock full-RCE chain claimed. [Lab][labrepo] [Lab re-analysis][lab] |

## Detection

### Read-only inventory

Run on a **trusted** copy or host where possible. Placeholder: `MAGENTO_ROOT` (the directory containing `composer.json` and `app/etc/env.php`). These commands read files only; they were not exercised on a real store.

```sh
cd MAGENTO_ROOT
# Installed product metapackage and framework version, from the lock file (no PHP executed)
grep -E -A1 '"name": "(magento/product-(community|enterprise)-edition|magento/extension-b2b|magento/framework|mage-os/product-community-edition|mage-os/framework)"' composer.lock
```

Every store on an affected line is vulnerable until the October patch is **applied in code**: Adobe shipped the October fixes as isolated patch files without new Composer packages, so a version string alone does not show patch state, and Sansec warns that a plain `composer install` still yields the vulnerable base. Include staging, preview and headless/GraphQL-only deployments, and every web node and container image. [Adobe KB][kb] [Sansec][sansec]

Reachability: the flaw needs no account (CVSS PR:N). Any storefront or GraphQL endpoint reachable from the internet should be treated as exposed. The public lab's carrier used guest GraphQL cart operations and the failed-payment email path; Sansec's four routes were not published, so blocking one flow is not a mitigation. [Lab re-analysis][lab] [Sansec][sansec]

### Patch-state checks

From `MAGENTO_ROOT` (read-only):

```sh
# BlockStrap fix: 0 means missing (Mage-OS: vendor/mage-os/framework/Filter/Template.php)
grep -c resolveDeferredDirectives vendor/magento/framework/Filter/Template.php
# 2.4.8-p5 only: 0 means the CVE-2026-91013 EmailAddress.php change is missing; apply 248p5-2026-10-002-CE
grep -c QUOTED_LOCAL_PART_PATTERN vendor/magento/framework/Validator/EmailAddress.php
```

Check the deployed code, not the build log: Sansec notes that Composer patch plugins can skip a hunk without failing the build, and deploy scripts using `patch ... || true` hide failures. [Sansec][sansec]

### Database and file indicators

No vendor or researcher IOCs for BlockStrap exploitation have been published. The checks below are **derived from the public validation lab's route** (one of several possible routes); a hit warrants investigation, and a miss proves nothing.

Read-only SQL against a replica or dump (add your table prefix if configured):

```sql
-- Template directive text in guest-supplied address fields (legitimate data rarely contains "{{")
SELECT address_id, quote_id, address_type, created_at FROM quote_address
 WHERE CONCAT_WS(' ', company, firstname, lastname, street, city, region, telephone) LIKE '%{{%';
SELECT entity_id, parent_id, address_type FROM sales_order_address
 WHERE CONCAT_WS(' ', company, firstname, lastname, street, city, region, telephone) LIKE '%{{%';
```

```sh
cd MAGENTO_ROOT
# The lab's stock side effect: tiny random-name CSVs (32 hex chars) under var/export
find var/export -maxdepth 1 -type f -regextype posix-extended -regex '.*/[0-9a-f]{32}\.csv' -size -10c -exec ls -l --time-style=full-iso {} + 2>/dev/null
# Generic: PHP files where none should be, and recently changed PHP code (compare with a clean release)
find pub/media pub/static var generated -type f \( -iname '*.php' -o -iname '*.phtml' -o -iname '*.phar' \) -exec ls -l --time-style=full-iso {} + 2>/dev/null
find app pub -type f -name '*.php' -newermt 2026-10-13 -exec ls -l --time-style=full-iso {} +
```

The empty file `976bc24c08055e67a58cf491401c8b2f3d48ff55b8092f1ede196bac4756a228` in the Magento root is a **benign** side effect of the October patch, not an indicator. [Sansec][sansec] [GitHub issue][issue]

### Log indicators

Access logs normally do not record POST bodies, so GraphQL payloads will not be visible. With request-body or WAF logs, look for `{{` directive text (for example `{{block`) in guest checkout fields, and for bursts of anonymous `POST /graphql` cart and payment mutations ending in payment failures. Sansec notes that Twig payloads containing `registerUndefinedFilterCallback` and callbacks to `bxss.me` (Acunetix) are **not** BlockStrap. Finding nothing does not prove the store was not attacked. [Sansec][sansec] [Lab re-analysis][lab]

### Official and vendor tools

- **Adobe Commerce Version Tool (CVT):** `php vendor/bin/patch-status` reports applied and missing monthly patches and per-CVE `PROTECTED`/`VULNERABLE`/`UNKNOWN`. It is installed only with the July 2026 isolated patch; `UNKNOWN` is not protected. It runs PHP from the store's own `vendor/`, so on a suspected-compromised host prefer the read-only `grep` checks above on a copy. [Adobe KB][kb] [CVT docs][cvt]
- **Quality Patches Tool (QPT):** `vendor/bin/magento-patches -n status | grep "39341\|Status"` checks the StyleSmuggler hotfix (Adobe documents QPT verification for Cloud). [StyleSmuggler KB][kb146]
- **Sansec eComscan:** a commercial scanner (basic scan free) that Sansec says flags the missing patch and checks for backdoors; it reads `env.php` for database credentials and scans files, database, processes and cron. It is third-party code fetched over the network; review it before running and follow Sansec's guidance on which user to run as. [Sansec][sansec] [eComscan guide][ecomscan]

## Remediation

1. **Apply the StyleSmuggler hotfix first if it is not already in place.** Install `VULN-39341` for your version from Adobe's APSB26-146 article; Sansec says to install it before the October patch (with it, `patch` reports line offsets in `Preview.php` and `AbstractTemplate.php`, but hunks still apply). [StyleSmuggler KB][kb146] [Sansec][sansec]
2. **Adobe Commerce on-premises (including B2B):** move to the latest security-only release of your line (2.4.9, 2.4.8-p5, 2.4.7-p10, 2.4.6-p15, 2.4.5-p17 or 2.4.4-p18), make sure every earlier monthly isolated patch is applied in order, then apply each file in the October zip that matches an installed component (CE, then EE, then B2B and others). Adobe's bulletin calls the result "-2026-oct" (B2B: 1.3.3–1.5.3 "-2026-oct"). [Adobe KB][kb] [Adobe][apsb]
3. **Adobe Commerce on Cloud:** update to the latest `magento-cloud-patches` release, which Adobe says includes the fix; do not also apply the isolated patch, which can then fail. [Adobe KB][kb]
4. **Magento Open Source 2.4.7, 2.4.8, 2.4.9:** apply the public October patch for 2.4.7-p10, 2.4.8-p5 or 2.4.9. On 2.4.8-p5, confirm the `EmailAddress.php` change (see [Patch-state checks](#patch-state-checks)) or apply `248p5-2026-10-002-CE`. [Adobe KB][kb] [Sansec][sansec]
5. **Magento Open Source 2.4.6 and older:** Adobe publishes no public Open Source patch (downloads for 2.4.6 and earlier need Adobe Commerce Composer keys). Upgrade to 2.4.7-p10 or later. Sansec points to third-party backports from Happy Horizon but gives no warranty; review them yourself if you use them. [Adobe KB][kb] [Sansec][sansec]
6. **Mage-OS:** upgrade to 3.6.0 (`composer require mage-os/product-community-edition=^3.6 --no-update && composer update && bin/magento setup:upgrade`). 3.5.0 is end of life. [Mage-OS 3.6.0][mageos]
7. **Redeploy correctly:** make the patch part of the build (composer patches or deploy pipeline) so a fresh `composer install` or image rebuild does not drop it, then follow Adobe's isolated-patch instructions for recompilation and cache flush and restart PHP-FPM on every node so no worker keeps old code. [Adobe KB][kb] [How to apply][howto]
8. **Until patched:** Adobe published no workaround. Sansec Shield (commercial WAF) has blocking rules; other WAF rules are untested here. Rolling back the patch reintroduces the flaw.

## Verification

- Re-run the [patch-state checks](#patch-state-checks) on each running web node or container: `resolveDeferredDirectives` count ≥1; on 2.4.8-p5, `QUOTED_LOCAL_PART_PATTERN` count ≥1; QPT shows `VULN-39341` applied.
- Where CVT is installed, run `php vendor/bin/patch-status` and confirm no missing October patches and `PROTECTED` for CVE-2026-103849.
- Benign functional controls on staging: place a normal test order, send a test transactional email and preview an email template in the admin; confirm they render correctly. Do not send `{{block}}` payloads or reproduce exploit routes against production.

## Compromise response

Patching does not remove backdoors or skimmers. If indicators are found, or the store ran unpatched while StyleSmuggler or BlockStrap were open:

- Preserve web, PHP-FPM and WAF logs, the code tree and a database dump before cleanup.
- Run a deep malware scan (for example `ecomscan --deep --min-confidence=0` on a copy) and diff code against a clean release; look for web shells, modified core files, unknown admin users, new integrations and tokens, unexpected cron jobs, and injected scripts in CMS blocks, email templates and `core_config_data` (Sansec separately reports CMS-block skimmer loaders on compromised Magento stores). [eComscan guide][ecomscan] [Sansec CMS loader][cmsloader]
- Rotate secrets the web user can read: the Magento encryption key, database password, admin passwords, REST/SOAP/GraphQL integration tokens and payment/API keys. Adobe's StyleSmuggler article gives a rotation sequence (maintenance mode, disable cron, rotate keys, passwords and tokens). [StyleSmuggler KB][kb146]
- If payment pages may have been altered, involve your payment provider; rebuild from known-good sources if the extent is unclear.

## Sources

- [Adobe APSB26-153][apsb]: BlockStrap affected/updated versions, CVSS, priority, exploitation statement and credits.
- [Adobe KB ka-49323][kb], [2.4.8-p5 replacement KB][kb2485], [How to apply an isolated patch][howto], [Commerce Version Tool][cvt]: patch files, prerequisites, Cloud path, verification.
- [Adobe APSB26-146 StyleSmuggler hotfix][kb146]: `VULN-39341`, QPT check, credential rotation.
- CVE records (Adobe CNA, CISA ADP): [CVE-2026-103849][cve], [CVE-2026-92909][cve92909], [CVE-2026-91013][cve91013], [CVE-2026-100133][cve100133], [CVE-2026-92464][cve92464]; [NVD][nvd]; [CISA KEV feed][kev] (catalog 2026.10.27).
- [Sansec BlockStrap analysis][sansec]: mechanism, four routes, no exploitation observed, patch caveats and checks.
- [Mage-OS 3.6.0 release notes][mageos] and [GitHub release][mageosgh].
- [magento/magento2 issue #41535][issue]: lock-file side effect.
- Third-party, unvetted: [dinosn validation lab][labrepo] and its [re-analysis][lab] (not run for this guide).
- Secondary: [BleepingComputer][bc].

[apsb]: https://www.adobe.com/trust/security/products/commerce/apsb26-153.html
[kb]: https://experienceleague.adobe.com/en/docs/experience-cloud-kcs/kbarticles/ka-49323
[kb2485]: https://experienceleague.adobe.com/en/docs/experience-cloud-kcs/kbarticles/ka-50927
[howto]: https://experienceleague.adobe.com/en/docs/support-resources/adobe-support-tools-guide/adobe-commerce-support/how-to-apply-an-isolated-security-patch-file-provided-by-adobe
[cvt]: https://experienceleague.adobe.com/en/docs/commerce-operations/tools/commerce-version-tool/intro
[kb146]: https://experienceleague.adobe.com/en/docs/commerce-knowledge-base/kb/announcements/commerce-apsb26-146
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-103849
[cve92909]: https://cveawg.mitre.org/api/cve/CVE-2026-92909
[cve91013]: https://cveawg.mitre.org/api/cve/CVE-2026-91013
[cve100133]: https://cveawg.mitre.org/api/cve/CVE-2026-100133
[cve92464]: https://cveawg.mitre.org/api/cve/CVE-2026-92464
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-103849
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[sansec]: https://sansec.io/research/blockstrap-magento-rce
[cmsloader]: https://sansec.io/research/magento-cms-block-loader-deepveindrilling
[ecomscan]: https://sansec.io/guides/usage
[mageos]: https://mage-os.org/releases/2026-10-14-mage-os-3-6-0-release
[mageosgh]: https://github.com/mage-os/mageos-magento2/releases/tag/3.6.0
[issue]: https://github.com/magento/magento2/issues/41535
[labrepo]: https://github.com/dinosn/cve-2026-103849-blockstrap-lab
[lab]: https://github.com/dinosn/cve-2026-103849-blockstrap-lab/blob/main/REANALYSIS.md
[bc]: https://www.bleepingcomputer.com/news/security/critical-blockstrap-flaw-lets-hackers-run-code-on-magento-servers/
