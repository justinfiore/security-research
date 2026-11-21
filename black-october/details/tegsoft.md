# Tegsoft Contact Center: an upload plants a web shell

**Last updated:** 2026-11-21 (America/New_York)

[Main Tegsoft summary](../black-october-2026.md#tegsoft-contact-center-an-upload-plants-a-web-shell) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Tegsoft Contact Center is call-center software from Tegsoft Yönetim ve Bilişim Hizmetleri, a company in Turkey. Turkey's Cyber Security Directorate published [TR-26-1588][tr] on November 20, 2026. TR-CERT is the CNA. The notice names two CVEs and says to upgrade to **latest-202611161510** or later. It does not say whether the upload needs a login. The score says it does not.

**TR-CERT rates [CVE-2026-14914](https://www.cve.org/CVERecord?id=CVE-2026-14914) CVSS 3.1 10.0 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`. The title is "RCE in TEGSOFT Management's Tegsoft Contact Center." The description says an unrestricted upload of a dangerous file type lets someone upload a web shell. Everything before **latest-202611161510** is affected. NVD has not scored it.

**TR-CERT rates [CVE-2026-14915](https://www.cve.org/CVERecord?id=CVE-2026-14915) CVSS 3.1 5.3 Medium.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N`. The same builds expose system information. It is not the reason this item is here, and the same upgrade covers it.

Efe Özel found both. Cemil Sefa Özcan and Ali Sefer analyzed them, and Fordefence sponsored the report. TR-CERT does not report exploitation. Neither record names a workaround.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-21) for either CVE. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix build | 2026-11-16, read from the version string | The fixed build is named latest-202611161510. No release note names that date. [CVE-2026-14914](https://www.cve.org/CVERecord?id=CVE-2026-14914) |
| **Public announcement** | **2026-11-20; time/TZ unknown** | TR-26-1588. Both CVEs. Upgrade to latest-202611161510. [TR-CERT][tr] |
| **Last updated** | **2026-11-21 (America/New_York)** | New item. Upgrade to latest-202611161510. |

## Detection

Read the build from the Contact Center installation. Anything before **latest-202611161510** is inside the range TR-CERT names. The notice does not say how the version is displayed.

## Remediation

Upgrade Tegsoft Contact Center to **latest-202611161510 or later**. TR-CERT names that floor for both CVEs and names no workaround. Tegsoft publishes no separate advisory that this guide could read.

The upgrade does not remove a file the upload already wrote.

## Verification

- The running build is latest-202611161510 or later.
- Do not upload a file to test the check.

## Compromise response

TR-CERT publishes no indicator. A server that was below the floor and reachable is the one the notice describes. Review the web directory for a file you did not put there, and review the process list for a shell that file would start. The upgrade does not delete one.

## Sources

- [TR-26-1588][tr] — Turkey Cyber Security Directorate, 2026-11-20. Names CVE-2026-14914 and CVE-2026-14915. Recommends latest-202611161510 or later.
- [CVE-2026-14914](https://www.cve.org/CVERecord?id=CVE-2026-14914) — TR-CERT CNA, published 2026-11-20. CVSS 3.1 10.0. Unrestricted upload of a web shell, before latest-202611161510.
- [CVE-2026-14915](https://www.cve.org/CVERecord?id=CVE-2026-14915) — TR-CERT CNA, published 2026-11-20. CVSS 3.1 5.3. Information disclosure, same floor.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-21. Neither CVE is listed.

[tr]: https://siberguvenlik.gov.tr/guvenlik-bildirimleri/detay/tr-26-1588
