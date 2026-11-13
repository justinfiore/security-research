# NetScaler: a packet crashes the appliance, and the Console skips login

**Last updated:** 2026-11-13 (America/New_York)

[Back to NetScaler summary](../black-october-2026.md#netscaler-a-packet-crashes-the-appliance-and-the-console-skips-login) · [Changelog](../../CHANGELOG.md)

Citrix published two Critical bulletins on November 12. [CTX697305](https://support.citrix.com/support-home/kbsearch/article?articleNumber=CTX697305) covers NetScaler ADC and NetScaler Gateway. [CTX697320](https://support.citrix.com/support-home/kbsearch/article?articleNumber=CTX697320) covers NetScaler Console.

**Citrix rates [CVE-2026-120868](https://www.cve.org/CVERecord?id=CVE-2026-120868) CVSS 4.0 9.3 Critical** (`CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:L/SI:L/SA:L`). A memory overflow in packet processing can lead to unpredictable behavior or a denial of service. The bulletin says every NetScaler ADC and NetScaler Gateway deployment is affected, including the default configuration, and that no feature has to be turned on. The CVE record, published 2026-11-12 23:39:03 UTC by the NetScaler CNA, now carries the same score and the same vector. ADC is affected before 14.1-73.57, 13.1-64.39, 14.1-73.58 FIPS, and 13.1-37.293, and Gateway before 14.1-73.57 and 13.1-64.39. The record writes the FIPS floor as "13.1-37.293 FIPs and NDcPP".

**Citrix rates [CVE-2026-120869](https://www.cve.org/CVERecord?id=CVE-2026-120869) CVSS 4.0 9.4 Critical** in CTX697320 (`CVSS:4.0/AV:A/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`). An attacker who is not logged in can bypass authentication and reach restricted resources on the Console appliance. The precondition is access to the Console IP. The CVE record, also published November 12 by the NetScaler CNA, scores the same flaw **9.3** with a different vector, `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:L/SI:L/SA:L`: the record says network, and the bulletin says adjacent. Both are Citrix's. The record says Console before 14.1-74.34 is affected.

The same ADC and Gateway bulletin lists eight more flaws Citrix scores 9.3 or 9.5, each with a configuration it names, and many more it scores below 9.0. The highest of the conditional ones is [CVE-2026-107412](https://www.cve.org/CVERecord?id=CVE-2026-107412) at 9.5, and it needs the appliance configured as a Gateway or an AAA virtual server. The same day Citrix published two High client bulletins: [CVE-2026-118268](https://www.cve.org/CVERecord?id=CVE-2026-118268) is 8.5 in Secure Access Client for Windows, and [CVE-2026-118269](https://www.cve.org/CVERecord?id=CVE-2026-118269) is 8.5 in the Linux client. A low-privileged local user reaches SYSTEM or root.

Citrix's community post says it is not aware of exploits for any of the announced vulnerabilities. The Hacker News reports the same statement.

This is not the October SAML crash, [CVE-2026-88779](https://www.cve.org/CVERecord?id=CVE-2026-88779), which is a different bulletin and a different build. The builds that fixed that one, 14.1-73.41 and 13.1-64.28, are still inside this one.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-12) for CVE-2026-120868, CVE-2026-120869, CVE-2026-118268, or CVE-2026-118269. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fixes** | **2026-11-12; time/TZ unknown** | CTX697305 changelog says "Initial Publication" on 2026-11-12 and gives no time. The page metadata says created 11-12-2026 12:16 and last modified 12:52, with no timezone. [CTX697305][ctx305] |
| Console bulletin | 2026-11-12; time/TZ unknown | CTX697320, created 11-12-2026 12:25, no timezone. [CTX697320][ctx320] |
| CVE-2026-120869 record | 2026-11-12; time unknown | NetScaler CNA. Score 9.3, vector network. The bulletin scores 9.4, vector adjacent. [Record][cve120869] |
| CVE-2026-120868 record | 2026-11-12 23:39:03 UTC | NetScaler CNA. CVSS 4.0 9.3, the same vector as the bulletin. [Record][cve120868] |
| **Last updated** | **2026-11-13 (America/New_York)** | The CVE-2026-120868 record is published. The builds are unchanged. |

## Detection

1. **Which appliance.** ADC and Gateway are one bulletin. Console is another. Secure Access Client for Windows and for Linux are two more. A build that fixes one does not fix the others.
2. **ADC and Gateway version.** `show ns version` is read-only. Affected builds are those before **14.1-73.57**, before **13.1-64.39**, before **14.1-73.58 FIPS**, and before **13.1-37.293** on the 13.1-FIPS and 13.1-NDcPP line. Check both nodes of an HA pair, FIPS and NDcPP builds, and NetScaler instances that Secure Private Access Hybrid uses. Citrix-managed cloud services and Citrix-managed Adaptive Authentication are updated by Cloud Software Group.
3. **CVE-2026-120868 needs no feature.** The bulletin says the default configuration is enough. The other ADC and Gateway flaws each name a configuration, and the bulletin gives the `ns.conf` pattern for each one.
4. **Console version.** Before **14.1-74.34**. The precondition is that the Console IP is reachable.
5. **Clients.** Secure Access Client for Windows before **26.11.1.6**, and Secure Access Client for Linux before **26.10.4**.

## Remediation

1. Upgrade NetScaler ADC and NetScaler Gateway to **14.1-73.57** or later, **13.1-64.39** or later on the 13.1 line, **14.1-73.58 FIPS** or later, or **13.1-37.293** or later on 13.1-FIPS and 13.1-NDcPP. Upgrade both nodes of an HA pair. The October builds, 14.1-73.41 and 13.1-64.28, do not include this fix.
2. Upgrade NetScaler Console to **14.1-74.34** or later. The ADC build does not fix the Console.
3. Upgrade Secure Access Client for Windows to **26.11.1.6** or later, and Secure Access Client for Linux to **26.10.4** or later.
4. Citrix names no workaround for CVE-2026-120868. Restricting who can reach the Console IP limits CVE-2026-120869 and is not the fix.
5. The upgrade does not show whether a packet already crashed the appliance or a request already reached the Console without a login.

## Verification

- `show ns version` on every ADC and Gateway node reports one of the builds above, and the Console reports 14.1-74.34 or later.
- A virtual server that should require a login still does. Do not send a packet built to crash it.

## Compromise response

Neither bulletin publishes an indicator. Citrix says it is not aware of exploits.

- If the Console was reachable from a network you do not trust, review who signed in and which resources changed, and rotate credentials the Console holds.
- A crash of an ADC or Gateway that you cannot explain is not, on these pages, evidence that this flaw was used. The October chain is a different pair of CVEs.

## Sources

- [CTX697305][ctx305] — read 2026-11-12. Critical. CVE-2026-120868 is CVSS 4.0 9.3 and needs no feature. Eight more are 9.3 or 9.5 with a named configuration. Fixed builds 14.1-73.57, 13.1-64.39, 14.1-73.58 FIPS, and 13.1-37.293. Changelog: initial publication 2026-11-12.
- [CTX697320][ctx320] — read 2026-11-12. CVE-2026-120869, CVSS 4.0 9.4, vector adjacent. Console before 14.1-74.34. Fixed in 14.1-74.34.
- [CVE-2026-120869][cve120869] — NetScaler CNA, published 2026-11-12. CVSS 4.0 9.3, vector network. Affected before 14.1-74.34.
- [CVE-2026-120868][cve120868] — NetScaler CNA, published 2026-11-12 23:39:03 UTC. CVSS 4.0 9.3, the same vector as CTX697305. ADC before 14.1-73.57, 13.1-64.39, 14.1-73.58 FIPS, and 13.1-37.293. Gateway before 14.1-73.57 and 13.1-64.39.
- [CTX697280](https://support.citrix.com/support-home/kbsearch/article?articleNumber=CTX697280) — CVE-2026-118268, CVSS 4.0 8.5 High. Secure Access Client for Windows before 26.11.1.6.
- [CTX697281](https://support.citrix.com/support-home/kbsearch/article?articleNumber=CTX697281) — CVE-2026-118269, CVSS 4.0 8.5 High. Secure Access Client for Linux before 26.10.4. Cited from Citrix's own cross-links and from The Hacker News; this page was not opened on its own.
- [The Hacker News, November 12](https://thehackernews.com/2026/11/citrix-patches-12-netscaler-and-secure.html) — reports Citrix's statement that it is not aware of exploits. The fixed builds match the bulletins.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-12. None of these CVEs is listed.

[ctx305]: https://support.citrix.com/support-home/kbsearch/article?articleNumber=CTX697305
[ctx320]: https://support.citrix.com/support-home/kbsearch/article?articleNumber=CTX697320
[cve120868]: https://www.cve.org/CVERecord?id=CVE-2026-120868
[cve120869]: https://www.cve.org/CVERecord?id=CVE-2026-120869
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
