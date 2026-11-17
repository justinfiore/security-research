# Silverstripe: a dev task URL runs code

**Last updated:** 2026-11-17 (America/New_York)

[Main Silverstripe summary](../black-october-2026.md#silverstripe-a-dev-task-url-runs-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

GitHub rates [CVE-2026-91115](https://www.cve.org/CVERecord?id=CVE-2026-91115) **CVSS 3.1 8.8 High**. GitHub is the CNA. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`. Silverstripe's own page gives the same 8.8 and calls it High. NVD had not scored it on November 17.

`silverstripe/framework` from **6.0.0 before 6.2.13** passes the `writer` option of the `i18nTextCollectorTask` dev task to the dependency injector without checking that it names an allowed writer. A crafted dev-task URL creates an arbitrary object with attacker-controlled constructor arguments and runs code on the server. The nested task did not ask for confirmation, so an administrator can be led into running it by opening a link. A site in dev mode exposes the path with no login. CMS 5 is not affected. The reporter is Jack Wallace.

**6.2.13**, released 2026-10-28, is the fix. The same release fixes more flaws that GitHub rates below 7.0, so they are not tracked here: CVE-2026-91112 at 6.8, CVE-2026-91110 at 6.4, CVE-2026-88987 and CVE-2026-88988 at 5.4, CVE-2026-91114 at 4.4, and CVE-2026-88989 at 4.3. Silverstripe's release notes also name SS-2026-004, a password-reset token account takeover, which has no CVE and no score on that page.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-17). Silverstripe does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Fix released** | **2026-10-28 02:24:33 UTC** | `silverstripe/framework` 6.2.13. [Release][rel] |
| Vendor page | 2026-10-28; time unknown | Silverstripe's security release page gives that date and no clock time. [Page][page] |
| **Public announcement** | **2026-11-16 16:18 UTC** | GitHub published the CVE record. The vendor page is earlier. |
| **Last updated** | **2026-11-17 (America/New_York)** | New item. Update the framework. |

## Detection

1. `composer show silverstripe/framework` prints the version. **6.0.0 through 6.2.12** is the range the record calls affected. **6.2.13 or later** is the fix. CMS 5 does not ship this framework line, and the record says it is not affected.
2. A site whose environment is `dev` exposes the task with no login. A site in `live` still runs the task when an administrator opens the URL. The mode changes who can reach it, not whether the code is affected.
3. A request log for `dev/tasks/i18nTextCollectorTask` with a `writer` value is the shape the advisory describes. This guide has no signature from Silverstripe, and absence of that line is not a clean bill.

## Remediation

1. Update `silverstripe/framework` to **6.2.13 or later** and deploy it. That release also carries the lower-scored fixes from the same day.
2. Until the update, do not leave a production site in dev mode, and do not open a dev-task link you did not expect. Silverstripe does not call either a fix.
3. The update does not show whether a task URL already ran code.

## Verification

- `composer show silverstripe/framework` reports 6.2.13 or later on the deployed site, and the site was redeployed after the update.
- The CMS still serves a page. Do not open a crafted task URL to test it.

## Compromise response

Silverstripe publishes no indicator and does not report exploitation. If the site was in dev mode, or an administrator may have opened a task link, review the web root and the administrator accounts for a file or an account the owner did not create. The update does not remove one.

## Sources

- [CVE-2026-91115](https://www.cve.org/CVERecord?id=CVE-2026-91115) — GitHub CNA, published 2026-11-16. CVSS 3.1 8.8. `silverstripe/framework` 6.0.0 before 6.2.13. CMS 5 not affected.
- [Silverstripe security release][page] — release date 2026-10-28. Same 8.8 score. Reporter Jack Wallace.
- [Framework 6.2.13][rel] — published 2026-10-28 02:24:33 UTC. Also lists CVE-2026-91112, CVE-2026-91110, CVE-2026-88987, CVE-2026-88988, CVE-2026-88989, and SS-2026-004.
- [GHSA-c94f-87xg-65wf](https://github.com/silverstripe/silverstripe-framework/security/advisories/GHSA-c94f-87xg-65wf) — the GitHub advisory the CVE record cites.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, checked 2026-11-17. Not listed.

[page]: https://www.silverstripe.org/download/security-releases/cve-2026-91115
[rel]: https://github.com/silverstripe/silverstripe-framework/releases/tag/6.2.13
