# Craft CMS: unauthenticated SQL injection to an administrator

**Last updated:** 2026-11-08 (America/New_York)

[Main Craft CMS summary](../black-october-2026.md#craft-cms-unauthenticated-sql-injection-to-an-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-123488](https://www.cve.org/CVERecord?id=CVE-2026-123488) — VulnCheck (CNA) CVSS 4.0 9.3 Critical and CVSS 3.1 9.8 Critical.** Craft's own advisory for the same flaw, [GHSA-qcvp-ggx3-97r6](https://github.com/craftcms/cms/security/advisories/GHSA-qcvp-ggx3-97r6), says **High** and **No known CVE**. NVD has not scored it. The vendor published the advisory on 2026-10-22. The CVE record is 2026-11-06. 5.11.2 and 4.18.9, both released 2026-09-17, also fix five more High flaws. One of those, the sandboxed `getOwners()` call, is now [CVE-2026-123490](https://www.cve.org/CVERecord?id=CVE-2026-123490). VulnCheck rates it CVSS 4.0 8.7 High and CVSS 3.1 8.8 High, published 2026-11-06. Craft's advisory for it still says no CVE is known. The other four still have no CVE.

**Worst case:** The vendor says an unauthenticated caller can read and write the application database, set the admin flag on user ID 1, and overwrite any account's password hash. Craft treats that one column as an administrator. The same releases fix control-panel paths to command execution as the PHP worker. Those need a control-panel account.

**Fixed in 5.11.2 and 4.18.9**, released 2026-09-17. Craft 3 is outside the ranges the advisories name.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08) for any of the three CVEs. Neither Craft nor VulnCheck reports exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [The other High fixes in the same releases](#the-other-high-fixes-in-the-same-releases)
  - [GraphQL prev/next, now CVE-2026-124427](#graphql-prevnext-now-cve-2026-124427)
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
| GraphQL prev/next CVE | 2026-11-08 13:15:24 UTC | VulnCheck published [CVE-2026-124427](https://www.cve.org/CVERecord?id=CVE-2026-124427) for GHSA-xpg7-m6gm-4xfh. CVSS 4.0 9.3 and CVSS 3.1 9.8. Craft's page still says Moderate and no CVE. |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-08) | None of the three CVEs. [KEV][kev] |
| 5.11.4 tagged | 2026-10-01 15:49:48 UTC | Fixes the image-transform class guard. The advisory came later. [GHSA-hq78-cm2m-h24h](https://github.com/craftcms/cms/security/advisories/GHSA-hq78-cm2m-h24h) |
| 5.11.5 tagged | 2026-10-07 17:38:22 UTC | Fixes the `findOne()` injection. The advisory came later. [GHSA-cphx-cx67-jcqj](https://github.com/craftcms/cms/security/advisories/GHSA-cphx-cx67-jcqj) |
| Two more High advisories | 2026-11-02; time/TZ unknown | Both published this day. Neither has a CVE. Craft 4 is not in either. |
| **Last updated** | **2026-11-08 (America/New_York)** | The 5.x floor is 5.11.5. 4.18.9 is unchanged. |

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
| [GHSA-hq78-cm2m-h24h](https://github.com/craftcms/cms/security/advisories/GHSA-hq78-cm2m-h24h) | A public site user with a profile photo, in the right circumstances | Image-transform class guard bypassed, then PHP execution. Craft says unauthenticated. No CVE. | 5.11.4 (5.0.0 through 5.11.3). Craft 4 is not in the advisory. |
| [GHSA-cphx-cx67-jcqj](https://github.com/craftcms/cms/security/advisories/GHSA-cphx-cx67-jcqj) | A lowest-privilege account | `Element::findOne()` takes array criteria as raw SQL. The 5.11.2 fix missed this path. No CVE. | 5.11.5 (5.0.0 through 5.11.4). Craft 4 is not in the advisory. |

The same releases also fix flaws Craft rates moderate. Public registration can keep a deactivated account's direct permissions ([GHSA-v25r-wr32-jfg7](https://github.com/craftcms/cms/security/advisories/GHSA-v25r-wr32-jfg7), 5.x only). Anonymous GraphQL can read content the schema was set to withhold. [GHSA-mp59-9rf5-93wr](https://github.com/craftcms/cms/security/advisories/GHSA-mp59-9rf5-93wr) is still Moderate and has no CVE. [GHSA-xpg7-m6gm-4xfh](https://github.com/craftcms/cms/security/advisories/GHSA-xpg7-m6gm-4xfh) is the one VulnCheck scored Critical, below.

### GraphQL prev/next, now CVE-2026-124427

Craft rates [GHSA-xpg7-m6gm-4xfh](https://github.com/craftcms/cms/security/advisories/GHSA-xpg7-m6gm-4xfh) **Moderate** and the page still says **No known CVE**. VulnCheck, the CNA for [CVE-2026-124427](https://www.cve.org/CVERecord?id=CVE-2026-124427), rates the same advisory **CVSS 4.0 9.3 Critical** and **CVSS 3.1 9.8 Critical**, published 2026-11-08 13:15:24 UTC. NVD has not scored it. The CVSS 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Craft's description is a read: title, slug, uid, post date, and custom-field content from a section the schema withholds, by chaining `next` from one visible entry. The record's integrity and availability ratings are VulnCheck's, not Craft's.

It needs a public GraphQL schema, or a scoped private token, that can read at least one section and withholds another, plus one visible entry, and the two sections have to share an entry type so the response serializes. It does not need an account. The range is **5.0.0 before 5.11.2**. Craft 4 is not in the advisory. The fix is the same 5.11.2 release as the High cluster. The update does not show whether a withheld entry was already read.

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

Affected: **5.0.0 through 5.11.4** for the `findOne()` injection, and **4.0.0 through 4.18.8** for the September cluster. An install on 5.11.2 or 5.11.3 is past the September flaws and still inside the image-transform PHP execution (through 5.11.3) and the `findOne()` injection (through 5.11.4). Two of the September High flaws, the signing oracle and `getOwners()`, are 5.x only, and so are both November advisories. Craft 3 is outside every range the advisories name. Include staging copies. An install that is not on the public internet is still affected if the control panel or the GraphQL endpoint is reachable by someone who should not have it.

## Remediation

1. **Update `craftcms/cms` to 5.11.5 or later, or 4.18.9 or later on the 4.x line,** then deploy and clear caches the way you normally do. 5.11.2 fixed the September cluster and left two High paths open. 5.11.4 fixes the image-transform PHP execution. 5.11.5 fixes the `findOne()` injection. 5.11.5 is the floor, not a pin.
2. **There is no workaround** in the advisories. Taking the control panel off the internet removes the paths that need a control-panel account. It does not remove the unauthenticated element-search injection or the anonymous GraphQL injection.
3. Updating stops the queries and the template signing. It does not unset an admin flag an injected query already set, and it does not restore a `CRAFT_SECURITY_KEY` an attacker already replaced.

## Verification

- Re-run the version check and confirm **5.11.5 or later**, or **4.18.9 or later**, on every install, including staging.
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
- [GHSA-xpg7-m6gm-4xfh](https://github.com/craftcms/cms/security/advisories/GHSA-xpg7-m6gm-4xfh): Craft, Moderate, no CVE, anonymous GraphQL prev/next read of a withheld section, 5.0.0 before 5.11.2, published 2026-10-23.
- [GHSA-hq78-cm2m-h24h](https://github.com/craftcms/cms/security/advisories/GHSA-hq78-cm2m-h24h): Craft, High, no CVE, image-transform class guard bypass to PHP execution, 5.0.0 before 5.11.4, published 2026-11-02. Craft says an unauthenticated attacker can execute PHP in the right circumstances.
- [GHSA-cphx-cx67-jcqj](https://github.com/craftcms/cms/security/advisories/GHSA-cphx-cx67-jcqj): Craft, High, no CVE, authenticated SQL injection through `Element::findOne()` array criteria, 5.0.0 before 5.11.5, published 2026-11-02. A lowest-privilege account can read the database. The 5.11.2 fix missed this path.
- [CVE-2026-124427](https://www.cve.org/CVERecord?id=CVE-2026-124427): VulnCheck CNA, published 2026-11-08 13:15:24 UTC, CVSS 4.0 9.3 and CVSS 3.1 9.8, same advisory. NVD has not scored it. Craft's page still says Moderate and no CVE.
- [NVD][nvd]: published 2026-11-06, no NVD score, for CVE-2026-123488.
- [CISA KEV JSON feed][kev]: catalog 2026.11.06, checked 2026-11-08. None of the three CVEs is listed.

[ghsa]: https://github.com/craftcms/cms/security/advisories/GHSA-qcvp-ggx3-97r6
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-123488
[rel5]: https://github.com/craftcms/cms/releases/tag/5.11.2
[rel4]: https://github.com/craftcms/cms/releases/tag/4.18.9
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-123488
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
