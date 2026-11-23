# Apache Solr: a health check does more than a health check

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#apache-solr-a-health-check-does-more-than-a-health-check) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-22 the Apache Solr project published [CVE-2026-86312](https://www.cve.org/CVERecord?id=CVE-2026-86312). Apache rates it **High, CVSS 3.1 8.8**. The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. NVD has not scored it.

A request to `/admin/ping` is meant to be a health check. On an affected release, that request can trigger other work. Where Solr uses its rule-based authorization and the caller has only the low-privilege `health` permission, the request can do something that permission should not allow. The sample `security.json` that `bin/solr` installs leaves that permission unauthenticated, so the same request needs no login at all.

Apache says you are affected when both of these are true:

- The running Solr is **9.0.0 before 9.11.0**, or **10.0.0 before 10.1.0**.
- `/admin/ping` can be reached with only the `health` permission. That includes the default sample security configuration.

**9.11.0**, announced 2026-10-04, and **10.1.0**, announced 2026-10-27, are the fixes. Both releases predate the advisory. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.23, checked 2026-11-23). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Solr 9.11.0 | 2026-10-04; time/TZ unknown | Announced as the 9.x fix. The advisory is later. [News](https://solr.apache.org/news.html) |
| Solr 10.1.0 | 2026-10-27; time/TZ unknown | Announced as the 10.x fix. [News](https://solr.apache.org/news.html) |
| **Public announcement** | **2026-11-22 23:22 UTC** | Apache announce list. CVSS 3.1 8.8. [Advisory][adv] |

## Detection

Read the Solr version from the running process or the install directory. **9.0.0 through 9.10.x**, and **10.0.x**, are inside the range Apache names. A deployment that does not expose `/admin/ping` with only the `health` permission is outside the condition Apache names; the version is still the one the advisory lists. Reading the version changes no state.

## Remediation

1. Upgrade the 9.x line to **9.11.0 or later**, or the 10.x line to **10.1.0 or later**, and restart Solr.
2. Until then, require a trusted role for `/admin/ping` and keep Solr off untrusted networks. Apache says that is the workaround, not the fix.
3. The upgrade does not show whether a ping request already did more than a health check.

## Verification

- The running Solr is **9.11.0 or later**, or **10.1.0 or later**.
- Do not send a crafted ping request to test it.

## Compromise response

No source read for this entry reports an incident. If an untrusted client could reach `/admin/ping` with only the `health` permission before the upgrade, review what that process could read or change. The upgrade does not undo a request that already ran.

## Sources

- [CVE-2026-86312 announcement][adv] — Jan Høydahl, announce@apache.org, 2026-11-22 23:22 UTC. CVSS 3.1 8.8. Affected 9.0.0 before 9.11.0 and 10.0.0 before 10.1.0. Credits Andrew Rukin (Arenadata), Zhang Yilin, and Calif.io with Anthropic.
- [CVE-2026-86312](https://www.cve.org/CVERecord?id=CVE-2026-86312) — Apache Software Foundation, published 2026-11-23. CVSS 3.1 8.8.
- [Solr news](https://solr.apache.org/news.html) — 9.11.0 announced 2026-10-04; 10.1.0 announced 2026-10-27.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T12:54:37.9646Z, checked 2026-11-23. Not listed.

[adv]: https://lists.apache.org/thread/23vlsohrl7vcckysqp9d094yplt4pjcv
