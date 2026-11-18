# REDCap: a public survey runs code

**Last updated:** 2026-11-18 (America/New_York)

[Main REDCap summary](../black-october-2026.md#redcap-a-public-survey-runs-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-90817](https://www.cve.org/CVERecord?id=CVE-2026-90817) lets a request that knows one public survey hash reach REDCap's Data Import path and run code. Securifera, the CNA, rates it **CVSS 3.1 9.8 Critical**, `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. NVD has not scored it. The record says the flaw exists in REDCap 13.3.0 and higher. The structured versions list only 13.3.0 as affected, with `defaultStatus` unknown, and name 16.0.49, 17.3.10, and 17.4.4 as unaffected.

**CISA KEV:** Listed — added 2026-11-18, federal due date 2026-11-21. Ransomware use Unknown. Forensic triage is required. Catalog 2026.11.18, released 2026-11-18T19:17:41.0354Z. CISA's own enrichment of the CVE record, dated 2026-09-21, says exploitation was none. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| CVE reserved | 2026-09-13 17:35:41 UTC | Securifera. [CVE JSON][json] |
| **Public announcement** | **2026-09-20 12:05:32 UTC** | CVE record. 9.8 Critical. Solution: 16.0.49 LTS, 17.3.10 LTS, or 17.4.4 Standard. [CVE JSON][json] |
| CISA SSVC | 2026-09-21 14:15:50 UTC | Exploitation none. Automatable yes. Technical impact total. [CVE JSON][json] |
| Finder's write-up | 2026-09-27 20:19:02 UTC | The survey hash reaches Data Import, which writes a compiled template. [Securifera][blog] |
| **CISA KEV** | **2026-11-18; time/TZ unknown** | Added. Federal due date 2026-11-21. Forensic triage required. [KEV][kev] |
| **Last updated** | **2026-11-18 (America/New_York)** | New item. Upgrade REDCap. |

## Detection

REDCap is not a public download. Read the version from the Control Center, or from `redcap_version` in the application directory, on a copy you trust.

The CNA's English description says 13.3.0 and higher. The same record's version list marks only 13.3.0 affected and leaves every other version unknown except the three it calls unaffected. Treat 13.3.0 and higher as in scope until Vanderbilt publishes a range, and treat these three as the named fixes:

| Line | Named unaffected build |
|---|---|
| 16 LTS | 16.0.49 |
| 17 LTS | 17.3.10 |
| 17 Standard | 17.4.4 |

A site with no public survey is outside the precondition the finder describes. A survey hash is not a password: the write-up says public survey links are distributed on purpose.

## Remediation

1. Upgrade to **16.0.49 LTS, 17.3.10 LTS, or 17.4.4 Standard**, or a later build on that line. The consortium distributes the upgrade; it is not on a public package index.
2. Until the upgrade, turn off public surveys, or block survey requests that carry `__passthru` to the root dispatcher. Securifera calls that containment, not a fix.
3. REDCap's own page does not publish this advisory. The CVE record is the vendor-facing fix statement, and Securifera wrote it.

## Verification

- Control Center shows 16.0.49, 17.3.10, 17.4.4, or a later build on that line.
- Do not send a survey request to test the route.

## Compromise response

CISA requires forensic triage. Securifera says the chain writes a compiled template under the temporary cache and then includes it. Look for a survey request with an encoded `__passthru`, a request to `DataImportController` or `ParcelController` from a survey context, and an `fname` value that contains `php://filter`. A cache file you cannot account for is the thing the chain writes. The upgrade does not restore that file or show whether it already ran.

## Sources

- [CVE-2026-90817 JSON][json] — Securifera, published 2026-09-20T12:05:32.698Z. CVSS 3.1 9.8. Solution names 16.0.49 LTS, 17.3.10 LTS, and 17.4.4 Standard. Affected list is 13.3.0 only, default status unknown.
- [Securifera write-up][blog] — 2026-09-27. The survey hash, the Data Import write, and the template include.
- [Securifera advisory index](https://www.securifera.com/advisories/) — lists the REDCap entry and links back to the CVE record. It is not a separate advisory.
- [CISA KEV JSON feed][kev] — catalog 2026.11.18, released 2026-11-18T19:17:41.0354Z. Added 2026-11-18, due 2026-11-21. Ransomware use Unknown. Forensic triage Yes.

[json]: https://cveawg.mitre.org/api/cve/CVE-2026-90817
[blog]: https://www.securifera.com/blog/2026/09/27/survey-says-remote-code-execution-cve-2026-90817/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
