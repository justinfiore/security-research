# Batflat: the contact form runs PHP

**Last updated:** 2026-11-16 (America/New_York)

[Main Batflat summary](../black-october-2026.md#batflat-the-contact-form-runs-php) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-111559](https://www.cve.org/CVERecord?id=CVE-2026-111559) is in Batflat CMS, from sruupl. The contact endpoint does not sanitize the message it is given. A request with no login can run PHP as `www-data`. CERT Polska is the CNA and rates it **CVSS 4.0 9.3 Critical**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:L/SI:L/SA:L`. CERT Polska's advisory says affected versions are **1.2.0 through 1.3.6**. The CVE record, updated 2026-11-16 15:26 UTC, says **1.2.0 through 1.3.7**. CERT Polska says the project is no longer maintained and the issue is not fixed. The finder's repository says 1.3.7 captures the input and that the escaping still lets the template tags through. Upstream has a commit that bumps the stored version to 1.3.7 and no release that calls it a fix.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-16). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-16; time/TZ unknown** | CERT Polska published the advisory and the CVE record. The advisory shows the date and no time. NVD's published time is 13:17 UTC. |
| CVE record widened | 2026-11-16 15:26:22 UTC | The record now says through 1.3.7. CERT Polska's page still says through 1.3.6. |
| **Last updated** | **2026-11-16 (America/New_York)** | The affected range now includes 1.3.7. Still no fix. |

## Detection

Batflat is a small PHP CMS. Read `inc/init.php` or the version the admin footer prints and compare it with 1.2.0 through 1.3.7. A site on that range is affected. CERT Polska's page stops at 1.3.6; the CVE record includes 1.3.7. Neither says whether a release before 1.2.0 is affected.

## Remediation

There is no fix, and the project is unmaintained. Take the site offline and replace it. Do not leave the contact endpoint exposed while you plan the replacement: that endpoint is the one the record names.

## Verification

The site no longer answers. There is no patched version to confirm. Do not post a message to the contact form to test it.

## Compromise response

A site that was reachable is a candidate for code that already ran as `www-data`. Preserve the web root and the PHP logs, look for files added or changed under the site, and rotate every credential the site stored. Taking it offline does not remove code already written there.

## Sources

- [CERT Polska, CVE-2026-111559](https://cert.pl/en/posts/2026/11/CVE-2026-111559) — published 16 November 2026. Affected 1.2.0 through 1.3.6. Project unmaintained, no fix. Credit Tymbark7372.
- [CVE-2026-111559](https://www.cve.org/CVERecord?id=CVE-2026-111559) — CERT Polska, published 2026-11-16, updated 2026-11-16 15:26:22 UTC. CVSS 4.0 9.3. Affected from 1.2.0 through 1.3.7. Adds the finder's repository.
- [Tymbark7372/CVE-2026-111559](https://github.com/Tymbark7372/CVE-2026-111559) — the finder's repository, created 2026-11-16. Says 1.3.7 captures the input and the escaping still lets the template tags through. It contains a proof of concept; that is not a report of exploitation.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. CVE-2026-111559 is not in it.
