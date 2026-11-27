# Hitachi Virtage: the management command has no login

**Last updated:** 2026-11-27 (America/New_York)

[Main Hitachi summary](../black-october-2026.md#hitachi-virtage-the-management-command-has-no-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Hitachi published two advisories on 2026-11-27 for the Virtage firmware of the BladeSymphony BS2500 and BS500 series. [hitachi-sec-2026-218][adv] covers five flaws. Hitachi says they can lead to data disclosure, data tampering, and denial of service. There is no firmware update. The workaround is to turn on authentication for the HVM management command and to set the management-network security level to High. [hitachi-sec-2026-219][adv219] covers a sixth flaw, in the virtual COM console, with its own two settings.

Hitachi's own scores, from the advisory:

| CVE | Hitachi score | Vector | What Hitachi's title says |
|---|---|---|---|
| [CVE-2026-115283](https://www.cve.org/CVERecord?id=CVE-2026-115283) | CVSS 3.1 **8.8 High** | `CVSS:3.1/AV:A/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:H` | Missing authentication |
| [CVE-2026-115284](https://www.cve.org/CVERecord?id=CVE-2026-115284) | CVSS 3.1 **7.6 High** | `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H` | Missing authentication |
| [CVE-2026-115285](https://www.cve.org/CVERecord?id=CVE-2026-115285) | CVSS 3.1 **7.6 High** | `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H` | Denial of service |
| [CVE-2026-115286](https://www.cve.org/CVERecord?id=CVE-2026-115286) | CVSS 3.1 **7.3 High** | `CVSS:3.1/AV:A/AC:H/PR:H/UI:R/S:C/C:H/I:H/A:H` | Not stated beyond the shared description |
| [CVE-2026-115287](https://www.cve.org/CVERecord?id=CVE-2026-115287) | CVSS 3.1 **7.3 High** | `CVSS:3.1/AV:A/AC:H/PR:H/UI:R/S:C/C:H/I:H/A:H` | Denial of service |
| [CVE-2026-115288](https://www.cve.org/CVERecord?id=CVE-2026-115288) | CVSS 3.1 **8.4 High** | `CVSS:3.1/AV:A/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:H` | Missing authentication, virtual COM console |

The CVE records published the same day give different scores for the first two. CVE-2026-115283's record is CVSS 3.1 **8.8** with vector `CVSS:3.1/AV:A/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:H`, which matches Hitachi. CVE-2026-115284's record is CVSS 3.1 **8.4** with vector `CVSS:3.1/AV:A/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:H`. Hitachi's page says 7.6 and `PR:N/UI:N`. Both issuers are Hitachi. The advisory page is the one that names the workaround.

The affected firmware is every Virtage version: BS2500 from 02-02 through 02-76, and BS500 from 01-01 through 02-76. Both advisories say "all versions" and "not available" for the fixed version. The attack vector on every score is Adjacent, so the path Hitachi describes is the management network, not the internet. The CVE records say the last three of the first advisory are denial of service. Hitachi's page does not say that for CVE-2026-115286 and CVE-2026-115287.

Hitachi does not report exploitation.

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
| **Public announcement** | **2026-11-27; time/TZ unknown** | hitachi-sec-2026-218. Five CVEs. Highest score 8.8. No firmware fix. [Advisory][adv] |
| **Last updated** | **2026-11-27 (America/New_York)** | New item. |

## Detection

Read the Virtage firmware version on the BS2500 or BS500. The advisory's affected range is every version: BS2500 02-02 through 02-76 and BS500 01-01 through 02-76. Then check the two settings the workaround changes:

1. Whether user authentication is enabled for the HVM management command (HvmSh).
2. The security level of HvmSh, HCSM, and LPAR Migration. The advisory says High.
3. Whether user authentication is enabled for the virtual COM console, and whether its connection mode is SSH.

A chassis whose management network is not reachable from untrusted hosts is outside the path the scores describe. A version this table does not list is unknown, not safe. Reading the version and the settings changes no state.

## Remediation

There is no firmware update. Hitachi says to do both of these:

1. Enable user authentication for the HVM management command (HvmSh). The steps are in the "Enable User Authentication" section of the BS2500 HVM User's Guide, or the "User Authentication Settings" section of the BS500 HVM User's Guide.
2. Set the security level of HvmSh and HCSM (LPAR Migration) to High. The steps are in the "About security on HVM features and tools that used management network" section of the BS2500 guide, or the "Security for functions and tools that use a management network" section of the BS500 guide. When the command `opr HvmIfSecureLevel` is used, set HvmSh, HCSM, and Migration all to High.

For the virtual COM console, [hitachi-sec-2026-219][adv219] says to do both of these:

1. Enable user authentication for the virtual COM console. The steps are in the same "Enable User Authentication" and "User Authentication Settings" sections.
2. Set the virtual COM console connection mode to SSH. The steps are in the "Encrypting communication with the virtual COM console" section of the BS2500 guide, or the "How to set the virtual COM console connection method" section of the BS500 guide.

Keep the management network reachable only from hosts you trust. That is not a substitute for the settings.

## Verification

- User authentication for HvmSh is enabled.
- The security level for HvmSh, HCSM, and Migration is High.
- User authentication for the virtual COM console is enabled, and its connection mode is SSH.
- Do not send a crafted management request to test it.

## Compromise response

Hitachi does not report exploitation. A chassis whose management network was reachable from untrusted hosts before the settings were applied should be reviewed for an LPAR or an account the owner did not add. The settings do not remove one. The advisory publishes no indicator.

## Sources

- [hitachi-sec-2026-218][adv] — published 2026-11-27. Five CVEs. Hitachi scores 8.8, 7.6, 7.6, 7.3, and 7.3. No fixed firmware. Two settings named above.
- [hitachi-sec-2026-219][adv219] — published 2026-11-27. CVE-2026-115288. Hitachi score 8.4. No fixed firmware. Virtual COM console authentication and SSH.
- [CVE-2026-115283](https://www.cve.org/CVERecord?id=CVE-2026-115283) — Hitachi, published 2026-11-27. CVSS 3.1 8.8. CWE-306.
- [CVE-2026-115284](https://www.cve.org/CVERecord?id=CVE-2026-115284) — Hitachi, published 2026-11-27. CVSS 3.1 8.4 on the record. The advisory says 7.6.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-27. None of the six is listed.

[adv]: https://www.hitachi.co.jp/products/it/server/security/info/vulnerable/hitachi_sec_2026_218_en.html
[adv219]: https://www.hitachi.co.jp/products/it/server/security/info/vulnerable/hitachi_sec_2026_219_en.html
