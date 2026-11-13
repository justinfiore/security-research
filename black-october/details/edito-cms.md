# Edito CMS: an unsigned token becomes any account

**Last updated:** 2026-11-13 (America/New_York)

[Main Edito CMS summary](../black-october-2026.md#edito-cms-an-unsigned-token-becomes-any-account) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Edito CMS is a content-management system from Edito. CERT Polska coordinated eight CVEs and published them on November 13. Three are High by CERT.PL's own CVSS 4.0 scores. [CVE-2026-59074](https://www.cve.org/CVERecord?id=CVE-2026-59074) is **8.7**: a logged-in user with low privileges submits a JWT that names another user, the refresh logic does not check the signature, and the server returns a valid session token for that account, including an administrator. [CVE-2026-59081](https://www.cve.org/CVERecord?id=CVE-2026-59081) is **8.4**: the CMS deserializes JSON without validating it, and someone who can change or inject a cache entry can run code on the server. CERT.PL says a user, including an administrator, cannot reach that one through the application's normal functions. [CVE-2026-59075](https://www.cve.org/CVERecord?id=CVE-2026-59075) is **7.1**: a logged-in user injects a condition into the `sort` parameter of a paginated administrative endpoint and reads any field, one character at a time.

Every version before **5.10.2607** is affected by those three. CERT.PL says hotfixes for the 5.8 branch were released as well, and does not name the hotfix build. [CVE-2026-59079](https://www.cve.org/CVERecord?id=CVE-2026-59079) is also **7.1**: an avatar upload accepts any file type. CERT.PL describes the upload and does not say the uploaded file is executed.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-13) for any of the eight CVEs. Neither CERT.PL nor the CVE records report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-13; time/TZ unknown** | CERT Polska publishes eight CVEs. The post gives the date and no time. [CERT Polska][cert] |
| CVE records published | 2026-11-13; time unknown | CERT.PL is the CNA. Each record says updated and published 2026-11-13 and gives no clock time. [CVE-2026-59074][cve74] |
| **Last updated** | **2026-11-13 (America/New_York)** | New item. Upgrade Edito CMS. |

## Detection

1. Read the running Edito CMS version from the installation, or from the vendor's update screen. A build below **5.10.2607** is inside CVE-2026-59074, CVE-2026-59075, CVE-2026-59079, and CVE-2026-59081. A 5.8 build is inside them until the hotfix for that branch is installed, and CERT.PL does not name that hotfix's version.
2. CVE-2026-59074 needs a logged-in account. A site with no accounts other than administrators is still inside it, because the account that starts the attack only has to be low-privileged, not absent.
3. CVE-2026-59081 needs a way to change or inject cache entries. CERT.PL says the application itself does not give a user that way. A cache that an outside party can write is the condition to look for, and this guide has no log line for it.

## Remediation

1. Upgrade to **Edito CMS 5.10.2607 or later**. CERT.PL says that version fixes CVE-2026-59074, CVE-2026-59075, CVE-2026-59079, and CVE-2026-59081, and the four lower-scored issues in the same post.
2. On the 5.8 branch, install the hotfix CERT.PL says was released. The post does not name the build, so confirm the version with Edito rather than guessing a number.
3. [CVE-2026-59080](https://www.cve.org/CVERecord?id=CVE-2026-59080) is not fixed by 5.10.2607. CERT.PL scores it CVSS 4.0 **2.1 Low** and says the vendor judged a fix unnecessary. The CMS sends a JWT in a GET request, the token is short-lived, and someone with access to the browser history can use it until it expires. The record lists every version through 5.10.2607 as affected.

The same post includes three issues CERT.PL scores below 7.0. [CVE-2026-59076](https://www.cve.org/CVERecord?id=CVE-2026-59076) and [CVE-2026-59077](https://www.cve.org/CVERecord?id=CVE-2026-59077) are stored cross-site scripting at CVSS 4.0 **5.1 Medium**. [CVE-2026-59078](https://www.cve.org/CVERecord?id=CVE-2026-59078) is the same score for a script in an uploaded avatar. 5.10.2607 fixes those three. This guide does not raise them to the three High scores.

## Verification

- The running Edito CMS reports **5.10.2607** or later, or the 5.8 hotfix Edito names for that branch.
- An ordinary user can still sign in, and an administrator can still open the changelog.
- Do not submit a crafted JWT, a cache entry, or a sort expression to test the flaws.

## Compromise response

CERT.PL publishes no indicator of an account that was already taken over. If the site was reachable and any low-privileged account could log in while the build was below 5.10.2607, review administrator sessions and password changes the owner did not make, and expire sessions after the upgrade. The upgrade does not undo a session token that was already issued, and it does not show whether a cache entry was replaced.

## Sources

- [CERT Polska][cert] — 13 November 2026. Eight CVEs in Edito CMS. Versions before 5.10.2607 are affected, and hotfixes for 5.8 were released. CVE-2026-59080 has no fix, by the vendor's decision.
- [CVE-2026-59074][cve74] — CERT.PL, published 2026-11-13. CVSS 4.0 8.7 (`CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`). Unsigned JWT refresh returns a session for any account.
- [CVE-2026-59081][cve81] — CERT.PL, published 2026-11-13. CVSS 4.0 8.4 (`CVSS:4.0/AV:L/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:H/SC:L/SI:L/SA:L`). Deserialization needs a modified or injected cache entry.
- [CVE-2026-59075][cve75] — CERT.PL, published 2026-11-13. CVSS 4.0 7.1 (`CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`). Dynamic LINQ injection in `sort`.
- [CVE-2026-59079][cve79] — CERT.PL, published 2026-11-13. CVSS 4.0 7.1 (`CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:N/VI:H/VA:N/SC:N/SI:N/SA:N`). Avatar upload accepts any file type. The record does not say the file runs.
- [CVE-2026-59076][cve76], [CVE-2026-59077][cve77], and [CVE-2026-59078][cve78] — CERT.PL, published 2026-11-13. Each is CVSS 4.0 5.1 Medium. Stored cross-site scripting, fixed in 5.10.2607.
- [CVE-2026-59080][cve80] — CERT.PL, published 2026-11-13. CVSS 4.0 2.1 Low. A JWT in a GET request. Affected through 5.10.2607, and the vendor says no fix is necessary.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10, checked 2026-11-13. None of the eight is listed.

[cert]: https://cert.pl/en/posts/2026/11/CVE-2026-59074/
[cve74]: https://www.cve.org/CVERecord?id=CVE-2026-59074
[cve75]: https://www.cve.org/CVERecord?id=CVE-2026-59075
[cve76]: https://www.cve.org/CVERecord?id=CVE-2026-59076
[cve77]: https://www.cve.org/CVERecord?id=CVE-2026-59077
[cve78]: https://www.cve.org/CVERecord?id=CVE-2026-59078
[cve79]: https://www.cve.org/CVERecord?id=CVE-2026-59079
[cve80]: https://www.cve.org/CVERecord?id=CVE-2026-59080
[cve81]: https://www.cve.org/CVERecord?id=CVE-2026-59081
