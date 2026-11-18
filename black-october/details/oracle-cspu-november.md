# Oracle: November 2026 Critical Security Patch Update

**Last updated:** 2026-11-18 (America/New_York)

[Main Oracle November summary](../black-october-2026.md#oracle-november-2026-critical-security-patch-update) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Oracle's November 17 Critical Security Patch Update is a monthly release, not the quarterly CPU. The [October CPU](oracle-cpu-october.md) is a separate set of patches, and the [Java4Shell](java4shell.md) entry covers the Java SE portion of this one. This page covers the rest.

**Oracle rates two APEX flaws and one REST Data Services flaw CVSS 3.1 9.8 Critical, and six Fusion Middleware and Analytics flaws 10.0.** Oracle is the CNA. All of those are remotely exploitable with no authentication, and Oracle says a successful attack can take over the product. The 10.0 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`. The 9.8 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`.

The unauthenticated takeover records this run read, with the versions Oracle names:

| Product | CVE | Score | Versions Oracle names |
|---|---|---|---|
| APEX, General | [CVE-2026-114849](https://www.cve.org/CVERecord?id=CVE-2026-114849), [CVE-2026-114850](https://www.cve.org/CVERecord?id=CVE-2026-114850) | 9.8 | 24.1.22, 24.2.21, 26.1.5, 26.2.0 |
| REST Data Services, Core | [CVE-2026-114849](https://www.cve.org/CVERecord?id=CVE-2026-114849) | 9.8 | 24.2.0 through 26.3.0 |
| Access Manager, Admin Console | [CVE-2026-114835](https://www.cve.org/CVERecord?id=CVE-2026-114835) | 10.0 | 12.2.1.4.0, 14.1.2.1.0 |
| Access Manager, Authentication Engine | [CVE-2026-91500](https://www.cve.org/CVERecord?id=CVE-2026-91500), [CVE-2026-91510](https://www.cve.org/CVERecord?id=CVE-2026-91510) | 10.0 | 12.2.1.4.0, 14.1.2.1.0 |
| WebLogic Server, TopLink | [CVE-2026-91569](https://www.cve.org/CVERecord?id=CVE-2026-91569) | 10.0 | 12.2.1.4.0, 14.1.1.0.0, 14.1.2.0.0, 15.1.1.0.0 |
| Platform Security for Java | [CVE-2026-114824](https://www.cve.org/CVERecord?id=CVE-2026-114824) | 10.0 | 12.2.1.4.0, 14.1.2.0.0 |
| Business Intelligence, Platform Security | [CVE-2026-114784](https://www.cve.org/CVERecord?id=CVE-2026-114784) | 10.0 | 8.2.0.0.0, 26.01.0.0.0 |

Oracle's counts for the release, from the same advisory: Fusion Middleware 71 new patches, 53 remotely exploitable without authentication; E-Business Suite 71, of which 19; Hyperion 267, of which 107; Supply Chain 74, of which 36; Analytics 29, of which 9; PeopleSoft 13, of which 6; Siebel 19, of which 9; MySQL 10, of which 3; REST Data Services 8, of which 5; Database Server 7, of which 3. Hyperion alone has several more 9.8 records, all on 11.2.26.0.000, including [CVE-2026-115047](https://www.cve.org/CVERecord?id=CVE-2026-115047), [CVE-2026-115048](https://www.cve.org/CVERecord?id=CVE-2026-115048), [CVE-2026-115086](https://www.cve.org/CVERecord?id=CVE-2026-115086), and [CVE-2026-115089](https://www.cve.org/CVERecord?id=CVE-2026-115089). The patch documents are on My Oracle Support, and this run did not read them.

**CISA KEV:** Not listed (catalog 2026.11.17, checked 2026-11-18) for CVE-2026-114849, CVE-2026-114850, CVE-2026-114835, CVE-2026-91500, CVE-2026-91510, CVE-2026-91569, CVE-2026-114824, or CVE-2026-114784. Oracle does not report exploitation of this release. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-17; time unknown** | Oracle CSPU Rev 1. [Advisory][oracle] |
| **Last updated** | **2026-11-18 (America/New_York)** | New item. Apply the November CSPU. |

## Detection

1. **APEX.** The affected builds Oracle names are 24.1.22, 24.2.21, 26.1.5, and 26.2.0. An APEX instance on one of those, reachable over HTTPS, is inside both 9.8 records.
2. **REST Data Services.** 24.2.0 through 26.3.0 is inside CVE-2026-114849. The same range is inside CVE-2026-114856, which Oracle scores 9.6 and which needs a person other than the attacker to interact.
3. **Fusion Middleware.** Access Manager 12.2.1.4.0 and 14.1.2.1.0, WebLogic Server through 15.1.1.0.0, and Platform Security for Java 12.2.1.4.0 and 14.1.2.0.0 are the versions in the 10.0 rows. The October CPU does not cover these CVEs.
4. **Business Intelligence.** 8.2.0.0.0 and 26.01.0.0.0 are the versions in CVE-2026-114784.

A product not in that table can still be inside one of the other patches. The advisory's affected-products list is the inventory, not this table.

## Remediation

1. Apply the November 17 Critical Security Patch Update from My Oracle Support for every Oracle product you run, and restart the services the patch notes name. The October CPU does not include these fixes.
2. APEX and REST Data Services are the two with an unauthenticated 9.8 and a short version list. Do those before the larger matrices.
3. Java SE is a different entry. Install the [November 17 JDK](java4shell.md#remediation) as well. This patch set does not replace it.
4. Oracle publishes no workaround for the rows above. The patch does not show whether a request already took the product over.

## Verification

- The patch inventory from My Oracle Support lists the November 17 CSPU as applied for each product you run.
- Do not send a request at APEX or REST Data Services to confirm the flaw.

## Compromise response

Oracle does not report exploitation of this release, and it publishes no indicator. The patch does not show whether a request already ran. An APEX or REST Data Services instance that was reachable before the patch, and that created an account or a session you cannot account for, needs a review of what that session did.

## Sources

- [Oracle Critical Security Patch Update, November 2026][oracle] — Rev 1, 2026-November-17. Product counts and the risk matrices.
- [Text form of the November 2026 risk matrices][verbose] — the CVE descriptions quoted above, including the version lists.
- [CISA KEV JSON][kev] — catalog 2026.11.17, released 2026-11-17T17:53:15.5664Z, checked 2026-11-18. None of the CVEs named here is listed.

[oracle]: https://www.oracle.com/security-alerts/cspunov2026.html
[verbose]: https://www.oracle.com/security-alerts/cspunov2026verbose.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
