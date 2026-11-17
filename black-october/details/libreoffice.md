# LibreOffice: a database document runs a macro

**Last updated:** 2026-11-17 (America/New_York)

[Main LibreOffice summary](../black-october-2026.md#libreoffice-a-database-document-runs-a-macro) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

LibreOffice is the Document Foundation's office suite. On November 16 it published a batch fixed in **26.2.7** and **26.8.2**. The Document Foundation is the CNA and scores eight of the records **CVSS 4.0 High**, all 7.3 or higher. NVD has not scored them.

[CVE-2026-84443](https://www.cve.org/CVERecord?id=CVE-2026-84443) is the one the records title. A Base document binds a macro to an event such as opening the document, and that macro ran without the macro security setting. Opening or converting the document can run any command. The same score, 8.5, covers five more that also run code from a document: [CVE-2026-101892](https://www.cve.org/CVERecord?id=CVE-2026-101892) (a form control in an ODF document), [CVE-2026-101930](https://www.cve.org/CVERecord?id=CVE-2026-101930) (a macro bound to an HTML document event), [CVE-2026-104007](https://www.cve.org/CVERecord?id=CVE-2026-104007) (the JDBC driver path of a database document), [CVE-2026-104692](https://www.cve.org/CVERecord?id=CVE-2026-104692) (a Java method call in an HSQLDB database), and [CVE-2026-104920](https://www.cve.org/CVERecord?id=CVE-2026-104920) (a Calc data link that loads remote Java). [CVE-2026-100101](https://www.cve.org/CVERecord?id=CVE-2026-100101) is 8.4: on Linux and other Unix-like systems, emailing a document can run a command through the file name. [CVE-2026-108169](https://www.cve.org/CVERecord?id=CVE-2026-108169) is 7.3: a web query file given on the command line runs code. The same releases fix five more that the CNA scores 6.7 or lower. They are named in Sources and are not the reason for this entry.

The CVE records say the 26.2 series before 26.2.7 and the 26.8 series before 26.8.2 are affected, and they do not say whether an older line is. The download page on November 17 offered **26.8.3** and **26.2.7**. Both are past the floors. The person at the computer has to open the document, or start the conversion. The vendor's advisory says the fixes make Base event macros follow the same security setting as other documents.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-17) for any of the thirteen. The Document Foundation does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-16 16:40:34 UTC** | The Document Foundation published the CVE records and the advisory. [CVE-2026-84443](https://www.cve.org/CVERecord?id=CVE-2026-84443) |
| **Last updated** | **2026-11-17 (America/New_York)** | New item. Update to 26.2.7 or 26.8.2. |

## Detection

Read **Help, About LibreOffice**. The version string starts with the release, such as 26.2.6 or 26.8.1. A 26.2 build before 26.2.7 and a 26.8 build before 26.8.2 are inside the records. A build that is not LibreOffice is outside this entry. A Linux package can carry a fix under an older number; the package changelog has to name these CVEs, and this run did not find a distribution advisory.

## Remediation

1. Install **26.2.7 or later** on the 26.2 line, or **26.8.2 or later** on the 26.8 line, and restart LibreOffice. The download page offered 26.8.3 and 26.2.7.
2. A headless conversion service that runs `soffice` is in scope. Restart it on the new build.
3. Until the update, do not open a Base or HTML document, or a spreadsheet with a data link, that you did not expect. That is not the fix.

## Verification

- About shows 26.2.7 or later, or 26.8.2 or later.
- Do not open a crafted document to confirm the macro no longer runs.

## Compromise response

The Document Foundation publishes no indicator and does not report exploitation. If a Base or HTML document from an untrusted sender was opened before the update, review what ran afterward. The update does not remove a command that already ran.

## Sources

- [CVE-2026-84443](https://www.cve.org/CVERecord?id=CVE-2026-84443) — Document Foundation, published 2026-11-16 16:40:34 UTC. CVSS 4.0 8.5. Base event macros skip the security setting. Affected 26.2 before 26.2.7 and 26.8 before 26.8.2.
- [LibreOffice security advisories](https://www.libreoffice.org/about-us/security/advisories/) — announced Nov 16, 2026, fixed in 26.2.7/26.8.2. The same section lists the other twelve.
- The other High records, same CNA, same versions, same time: [CVE-2026-100101](https://www.cve.org/CVERecord?id=CVE-2026-100101) (8.4), [CVE-2026-101892](https://www.cve.org/CVERecord?id=CVE-2026-101892) (8.5), [CVE-2026-101930](https://www.cve.org/CVERecord?id=CVE-2026-101930) (8.5), [CVE-2026-104007](https://www.cve.org/CVERecord?id=CVE-2026-104007) (8.5), [CVE-2026-104692](https://www.cve.org/CVERecord?id=CVE-2026-104692) (8.5), [CVE-2026-104920](https://www.cve.org/CVERecord?id=CVE-2026-104920) (8.5), [CVE-2026-108169](https://www.cve.org/CVERecord?id=CVE-2026-108169) (7.3).
- The same releases, scored below 7.0 by the CNA: [CVE-2026-101929](https://www.cve.org/CVERecord?id=CVE-2026-101929) (5.4), [CVE-2026-101933](https://www.cve.org/CVERecord?id=CVE-2026-101933) (5.4), [CVE-2026-104933](https://www.cve.org/CVERecord?id=CVE-2026-104933) (6.7), [CVE-2026-18563](https://www.cve.org/CVERecord?id=CVE-2026-18563) (5.4), [CVE-2026-97892](https://www.cve.org/CVERecord?id=CVE-2026-97892) (5.4).
- [LibreOffice download](https://www.libreoffice.org/download/download-libreoffice/) — read 2026-11-17. Offered 26.8.3 and 26.2.7.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, checked 2026-11-17. None of the thirteen is listed.
