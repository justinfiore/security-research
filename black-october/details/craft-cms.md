# Craft CMS: unauthenticated SQL injection to an administrator

**Last updated:** 2026-11-07 (America/New_York)

[Main Craft CMS summary](../black-october-2026.md#craft-cms-unauthenticated-sql-injection-to-an-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-123488](https://www.cve.org/CVERecord?id=CVE-2026-123488) — VulnCheck (CNA) CVSS 4.0 9.3 Critical and CVSS 3.1 9.8 Critical.** Craft's own advisory for the same flaw, [GHSA-qcvp-ggx3-97r6](https://github.com/craftcms/cms/security/advisories/GHSA-qcvp-ggx3-97r6), says **High** and **No known CVE**. NVD has not scored it. The vendor published the advisory on 2026-10-22. The CVE record is 2026-11-06. 5.11.2 and 4.18.9, both released 2026-09-17, also fix five more High flaws. One of those, the sandboxed `getOwners()` call, is now [CVE-2026-123490](https://www.cve.org/CVERecord?id=CVE-2026-123490). VulnCheck rates it CVSS 4.0 8.7 High and CVSS 3.1 8.8 High, published 2026-11-06. Craft's advisory for it still says no CVE is known. The other four still have no CVE.

**Worst case:** The vendor says an unauthenticated caller can read and write the application database, set the admin flag on user ID 1, and overwrite any account's password hash. Craft treats that one column as an administrator. The same releases fix control-panel paths to command execution as the PHP worker. Those need a control-panel account.

**Fixed in 5.11.2 and 4.18.9**, released 2026-09-17. Craft 3 is outside the ranges the advisories name.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-07) for either CVE. Neither Craft nor VulnCheck reports exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [The other High fixes in the same releases](#the-other-high-fixes-in-the-same-releases)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery | Unknown | Craft's advisories carry report IDs. They do not name a finder or a report date. |
| Patch available | 2026-09-17 18:45:32 UTC (5.11.2); 2026-09-17 18:41:07 UTC (4.18.9) | The release notes say high-severity and link the advisories. They do not name a CVE. [5.11.2][rel5] [4.18.9][rel4] |
| **Public announcement** | **2026-10-22 22:52:11 UTC** | GHSA-qcvp-ggx3-97r6. Craft rates it High and says no CVE is known. [GHSA][ghsa] |
| Other High advisories | 2026-10-22 and 2026-10-23; times on the advisory pages | Five more High flaws. Four still have no CVE. [Releases][rel5] |
| getOwners CVE | 2026-11-06; time/TZ unknown | VulnCheck published [CVE-2026-123490](https://www.cve.org/CVERecord?id=CVE-2026-123490) for GHSA-r56r-f696-c8w9. CVSS 4.0 8.7 and CVSS 3.1 8.8. 5.8.17 before 5.11.2. Craft's page still says no CVE. |
| CVE record published | 2026-11-06; time/TZ unknown | VulnCheck CNA. CVSS 4.0 9.3 and CVSS 3.1 9.8. Craft's advisory is unchanged. [CNA][cve] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-07) | Neither CVE. [KEV][kev] |
| **Last updated** | **2026-11-07 (America/New_York)** | The getOwners flaw has a CVE. The fix is unchanged. |

## The other High fixes in the same releases

These are the High advisories the 5.11.2 and 4.18.9 notes name. One now has a CVE. The other four do not. A site below those versions is inside every row that names its line.

| Advisory | Who can reach it | Result Craft describes | Fixed in |
|---|---|---|---|
| [GHSA-mjj9-pjh4-r48g](https://github.com/craftcms/cms/security/advisories/GHSA-mjj9-pjh4-r48g) | Anonymous GraphQL, when the public schema is on | SQL in an element query's `SELECT` | 5.11.2 and 4.18.9 |
| [GHSA-f6gf-r952-rxg6](https://github.com/craftcms/cms/security/advisories/GHSA-f6gf-r952-rxg6) | Any control-panel user | Blind SQL through `getNext` / `getPrev` criteria | 5.11.2 and 4.18.9 |
| [GHSA-v4q3-2g5g-wjj6](https://github.com/craftcms/cms/security/advisories/GHSA-v4q3-2g5g-wjj6) | Any control-panel user | Recovers `securityKey`, then command execution | 5.11.2 and 4.18.9 |
| [GHSA-9hp6-3565-gvh5](https://github.com/craftcms/cms/security/advisories/GHSA-9hp6-3565-gvh5) | A control-panel user with `accessCp` | Replaces `CRAFT_SECURITY_KEY` in `.env`, then command execution | 5.11.2 and 4.18.9 |
| [GHSA-qj3q-j7r4-428p](https://github.com/craftcms/cms/security/advisories/GHSA-qj3q-j7r4-428p) | A non-administrator control-panel user | Signs a Twig template, then command execution on login | 5.11.2 only (5.10.0 through 5.11.1) |
| [GHSA-r56r-f696-c8w9](https://github.com/craftcms/cms/security/advisories/GHSA-r56r-f696-c8w9), [CVE-2026-123490](https://www.cve.org/CVERecord?id=CVE-2026-123490) | A control-panel user | Administrator through sandboxed `getOwners()`. VulnCheck: CVSS 4.0 8.7 and CVSS 3.1 8.8. | 5.11.2 only (5.8.17 through 5.11.1) |

The same releases also fix moderate flaws: public registration can keep a deactivated account's direct permissions ([GHSA-v25r-wr32-jfg7](https://github.com/craftcms/cms/security/advisories/GHSA-v25r-wr32-jfg7), 5.x only), and anonymous GraphQL can read content the schema was set to withhold ([GHSA-xpg7-m6gm-4xfh](https://github.com/craftcms/cms/security/advisories/GHSA-xpg7-m6gm-4xfh), [GHSA-mp59-9rf5-93wr](https://github.com/craftcms/cms/security/advisories/GHSA-mp59-9rf5-93wr)). Those are not the High cluster.

## Detection

On a **trusted** host, from the Craft project root, as the site's file owner. These commands only read. They were not exercised on a real site.

```sh
cd PROJECT_ROOT
composer show craftcms/cms --format=json 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin).get("versions", [""])[0])'
```

If Composer is unavailable, or the site may be compromised, read the constraint from `composer.lock` instead of running Composer:

```sh
python3 -c 'import json; d=json.load(open("PROJECT_ROOT/composer.lock")); print(next(p["version"] for p in d["packages"] if p["name"]=="craftcms/cms"))'
```

Affected: **5.0.0 through 5.11.1**, and **4.0.0 through 4.18.8**. Two of the High flaws, the signing oracle and `getOwners()`, are 5.x only. Craft 3 is outside every range the advisories name. Include staging copies. An install that is not on the public internet is still affected if the control panel or the GraphQL endpoint is reachable by someone who should not have it.

## Remediation

1. **Update `craftcms/cms` to 5.11.2 or later, or 4.18.9 or later on the 4.x line,** then deploy and clear caches the way you normally do. The current 5.x release may be newer than 5.11.2; 5.11.2 is the floor, not a pin.
2. **There is no workaround** in the advisories. Taking the control panel off the internet removes the paths that need a control-panel account. It does not remove the unauthenticated element-search injection or the anonymous GraphQL injection.
3. Updating stops the queries and the template signing. It does not unset an admin flag an injected query already set, and it does not restore a `CRAFT_SECURITY_KEY` an attacker already replaced.

## Verification

- Re-run the version check and confirm **5.11.2 or later**, or **4.18.9 or later**, on every install, including staging.
- Load the control panel and one public page you already use. Do not send SQL payloads.

## Compromise response

The reviewed sources do not publish a query, an indicator, or a confirmed compromise. If the site was below the fixed version while the control panel or the element index was reachable after 2026-09-17, treat a changed administrator and a replaced security key as possible rather than proven.

- Preserve web logs and a database dump before cleanup.
- In the `users` table, look for user ID 1 having `admin` set when it should not, and for password hashes that changed without a password reset you made.
- Look for a new or unexpected `CRAFT_SECURITY_KEY` in `.env`, and for new administrator accounts.
- Look for PHP and shell commands you did not run. The control-panel flaws execute as the PHP worker.
- If you find evidence the query ran, rotate the database password, replace `CRAFT_SECURITY_KEY`, and reset administrator passwords. Sessions signed with the old key should stop working after the key changes; confirm that by signing in again.

## Sources

- [GHSA-qcvp-ggx3-97r6][ghsa]: Craft, High, no CVE, unauthenticated SQL injection to an administrator, 4.0.0–4.18.8 and 5.0.0–5.11.1, published 2026-10-22.
- [CVE-2026-123488][cve]: VulnCheck CNA, published 2026-11-06, CVSS 4.0 9.3 and CVSS 3.1 9.8, same versions, cites the Craft advisory.
- [5.11.2 release][rel5] and [4.18.9 release][rel4]: 2026-09-17, high-severity fixes, no CVE named.
- [CVE-2026-123490](https://www.cve.org/CVERecord?id=CVE-2026-123490): VulnCheck CNA, published 2026-11-06, CVSS 4.0 8.7 and CVSS 3.1 8.8, GHSA-r56r-f696-c8w9, 5.8.17 before 5.11.2. Craft's advisory still says no CVE is known.
- [NVD][nvd]: published 2026-11-06, no NVD score.
- [CISA KEV JSON feed][kev]: catalog 2026.11.06, checked 2026-11-07. Neither CVE is listed.

[ghsa]: https://github.com/craftcms/cms/security/advisories/GHSA-qcvp-ggx3-97r6
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-123488
[rel5]: https://github.com/craftcms/cms/releases/tag/5.11.2
[rel4]: https://github.com/craftcms/cms/releases/tag/4.18.9
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-123488
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
