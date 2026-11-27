# Hitachi RV3000: the log monitor leaks an ESXi account

**Last updated:** 2026-11-27 (America/New_York)

[Main Hitachi summary](../black-october-2026.md#hitachi-rv3000-the-log-monitor-leaks-an-esxi-account) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Hitachi published [hitachi-sec-2026-216][adv] on 2026-11-27. It says a file-permission flaw in the RV3000 Log Monitor for VMware could leak account information for ESXi hosts. Hitachi rates [CVE-2026-105917](https://www.cve.org/CVERecord?id=CVE-2026-105917) CVSS 3.1 **8.8 High**, vector `CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`. The vector is Local, so the path is a user who can already reach the monitor's host.

The affected builds are RV3000 Log Monitor for VMware (CIM) 98-08 and earlier, on the RV3000 A2 with VMware ESXi 7.0, fixed in **98-09**, and RV3000 Log Monitor for VMware 97-04 and earlier, on the RV3000 A1 with VMware ESXi 7.0 or 6.7, fixed in **97-05**.

Hitachi does not report exploitation. This is not the Virtage firmware on the BladeSymphony BS2500 and BS500.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-27). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-27; time/TZ unknown** | hitachi-sec-2026-216. CVSS 3.1 8.8. Fixed in 98-09 and 97-05. [Advisory][adv] |
| **Last updated** | **2026-11-27 (America/New_York)** | New item. |

## Detection

Read the version of the RV3000 Log Monitor for VMware. The advisory's affected ranges are 98-08 and earlier for the CIM build, and 97-04 and earlier for the other build. A version this table does not list is unknown, not safe. Reading the version changes no state.

## Remediation

Upgrade to the fixed version or later: **98-09** for RV3000 Log Monitor for VMware (CIM), and **97-05** for RV3000 Log Monitor for VMware. Hitachi says to download the software from the [RV3000 download site](https://www.hitachi.co.jp/products/it/rv3000/download/index.html), which is in Japanese, and to contact the Hitachi support representative for the fixed products.

## Verification

- The installed build is 98-09 or later, or 97-05 or later, for the product that is installed.
- Do not read the monitor's files to test the leak.

## Compromise response

Hitachi does not report exploitation. A host that ran an affected build should be reviewed for an ESXi account or credential the owner did not expect to be readable. The upgrade does not rotate one. The advisory publishes no indicator.

## Sources

- [hitachi-sec-2026-216][adv] — published 2026-11-27. CVE-2026-105917. CVSS 3.1 8.8. Fixed in 98-09 and 97-05.
- [CVE-2026-105917](https://www.cve.org/CVERecord?id=CVE-2026-105917) — Hitachi, published 2026-11-27. CVSS 3.1 8.8.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-27. CVE-2026-105917 is not listed.

[adv]: https://www.hitachi.co.jp/products/it/server/security/info/vulnerable/hitachi_sec_2026_216_en.html
