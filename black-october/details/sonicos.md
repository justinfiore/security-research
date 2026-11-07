# SonicOS: SSLVPN SAML bypass, and two management-interface flaws

**Last updated:** 2026-11-06 (America/New_York)

[Main SonicOS summary](../black-october-2026.md#sonicos-sslvpn-saml-bypass-and-management-interface-flaws) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

SonicWall published [SNWLID-2026-0014][adv] on 2026-11-06 with seven CVEs. The advisory's headline score is **CVSS 3.1 8.8**, the score SonicWall assigns to the two management-interface flaws. CISA added one of the seven, the SSLVPN SAML bypass, to KEV the same day. This is not [SonicWall GMS](sonicwall-gms.md). GMS is the retired management product and has no patch.

**[CVE-2026-107155](https://www.cve.org/CVERecord?id=CVE-2026-107155) and [CVE-2026-107154](https://www.cve.org/CVERecord?id=CVE-2026-107154): SonicWall rates both CVSS 3.1 8.8 High.** The vectors are `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`. NVD shows the same 8.8 from CISA-ADP, not from the CNA record. SonicWall says a permissive cross-domain policy (CWE-942) and a session-validation flaw (CWE-291, reliance on an IP address) in the management interface can, in specific conditions, let a remote unauthenticated attacker perform unauthorized operations. Both require user interaction. SonicWall does not name the operation or the condition. CISA-ADP records exploitation "none" for both.

**[CVE-2026-19868](https://www.cve.org/CVERecord?id=CVE-2026-19868): SonicWall rates it CVSS 3.1 7.1 High.** The vendor vector is `CVSS:3.1/AV:N/AC:H/PR:L/UI:N/S:C/C:H/I:L/A:N`. NVD shows **7.5 High** from CISA-ADP, `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:C/C:H/I:L/A:N`. The two scores disagree on whether a login is required. A user who already has valid credentials for an alternate authentication method can bypass SAML controls on the SSLVPN service, including SAML-enforced multi-factor authentication. SonicWall says this applies **only** when SAML is enabled for SSLVPN logins. SonicWall PSIRT says it investigated a report of potential exploitation and urges an upgrade. CISA-ADP records exploitation "active".

**[CVE-2026-82308](https://www.cve.org/CVERecord?id=CVE-2026-82308): SonicWall and CISA-ADP both rate it CVSS 3.1 7.5 High** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H`). A pre-authentication heap overflow in the SSLVPN service can crash the application. It does not, on the published scores, disclose or change data. CISA-ADP records exploitation "none" and says it is automatable.

Three more flaws in the same advisory are below 7.0 and are not the reason for this entry. [CVE-2026-77708](https://www.cve.org/CVERecord?id=CVE-2026-77708) and [CVE-2026-77709](https://www.cve.org/CVERecord?id=CVE-2026-77709) are 5.9: pre-authentication buffer overflows in the TACACS+ client, denial of service only. [CVE-2026-19703](https://www.cve.org/CVERecord?id=CVE-2026-19703) is 5.2 on the advisory and 5.1 from CISA-ADP: weak password hashing on virtual appliances, and it needs existing local access. The same fixed builds cover them.

**Fixed in Gen7 7.3.4-7013 and later, and Gen8 8.2.3-8015 and later.** Affected is Gen7 **7.3.3-7015 and older**, and Gen8 **8.2.2-8015 and older**, hardware and NSv. There is no workaround.

**CISA KEV:** [CVE-2026-19868](https://www.cve.org/CVERecord?id=CVE-2026-19868) is listed — added 2026-11-06, federal due date 2026-11-20. Ransomware use is Unknown. Forensic triage is No. The other six CVEs in SNWLID-2026-0014 are not listed (catalog 2026.11.06, checked 2026-11-06). [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | Credits name Pentest-Tools.com, ACN, and Ryan Harris of The Electronic Office. No report date. |
| **Public announcement** | **2026-11-06; time/TZ unknown** | SNWLID-2026-0014, revision 1.0. [Advisory][adv] |
| CVE records | 2026-11-06 19:17 UTC | NVD published times are 19:17:06 through 19:17:57 UTC. SonicWall is the CNA. The CNA records carry no CVSS; the scores above are the advisory and CISA-ADP. |
| CISA KEV | 2026-11-06 | Catalog 2026.11.06, released 2026-11-06 19:44:45 UTC. Only CVE-2026-19868. Due 2026-11-20. [KEV][kev] |

## Detection

On the firewall, read the running firmware. SonicOS shows it on the status page. These are the ranges the advisory names.

- **Gen7** hardware (TZ 270 through TZ 670, NSa 2700 through NSa 6700, NSsp 10700 through NSsp 15700) and Gen7 NSv (270, 470, 870 on ESX, KVM, Hyper-V, AWS, and Azure): **7.3.3-7015 and older** are affected. **7.3.4-7013 and higher** are fixed.
- **Gen8** hardware (TZ 80 through TZ 680, NSa 2800 through NSa 5800) and Gen8 NSv (XS, S, M, L on the same hypervisors): **8.2.2-8015 and older** are affected. **8.2.3-8015 and higher** are fixed.

A version string that does not match either generation is not a clearance. Compare it with the current advisory rather than assuming it is outside the table.

The SSLVPN bypass applies only when SAML is enabled for SSLVPN logins. A firewall that does not expose SSLVPN, or that does not use SAML for those logins, is outside CVE-2026-19868. It is still inside the management-interface flaws if the firmware is in the affected range and the management interface is reachable by someone who can be induced to load a page. SonicWall does not say whether the management interface must be exposed to the internet.

SonicWall publishes no log signature and no indicator for any of the seven. A quiet log does not show the SAML bypass was not used.

## Remediation

1. Upgrade Gen7 to **7.3.4-7013 or later**, and Gen8 to **8.2.3-8015 or later**. SonicWall says there is no workaround.
2. If SAML is enabled for SSLVPN and the firewall is still on an affected build, treat a VPN login that did not pass the SAML identity provider as possible. The upgrade does not expire a session that login already created.
3. Restrict the management interface to networks that should administer the firewall. That reduces who can be asked to load a page against it. It is not a fix for the 8.8 flaws, and it does not fix the SSLVPN bypass.
4. The three flaws below 7.0 are fixed by the same builds. Do not stay on an affected build because only those remain.

## Verification

- The running firmware is **7.3.4-7013 or later** on Gen7, or **8.2.3-8015 or later** on Gen8, on every unit, including the virtual appliances.
- After the upgrade, a SAML SSLVPN login still requires the identity provider. Do not test the bypass.

## Compromise response

SonicWall says it investigated a report of potential exploitation of CVE-2026-19868. It does not publish an indicator, a source address, or a confirmed customer incident. CISA lists the CVE and does not require forensic triage.

- Preserve VPN and authentication logs from before the upgrade.
- Look for SSLVPN sessions that completed without a corresponding SAML assertion at the identity provider, on a firewall where SAML was required.
- Look for management-interface configuration changes you did not make. SonicWall does not say which operations the 8.8 flaws can perform, so a change you cannot attribute is the thing to review, not a named artifact.
- Rotate credentials that a bypassed SAML login would have reached. The upgrade does not do that.

## Sources

- [SNWLID-2026-0014][adv] — first published and last updated 2026-11-06, revision 1.0. Seven CVEs, affected and fixed builds, and the exploitation note on CVE-2026-19868.
- [CVE-2026-19868][cve19868] — SonicWall CNA, published 2026-11-06. Description matches the advisory. No CVSS in the CNA container. CISA-ADP 7.5, exploitation active.
- [CVE-2026-107155][cve107155] and [CVE-2026-107154][cve107154] — published 2026-11-06 19:17 UTC. CISA-ADP 8.8, exploitation none.
- [CISA KEV][kev] — catalog 2026.11.06. CVE-2026-19868 added 2026-11-06, due 2026-11-20, ransomware Unknown, forensic triage No.

[adv]: https://psirt.global.sonicwall.com/vuln-detail/SNWLID-2026-0014
[cve19868]: https://www.cve.org/CVERecord?id=CVE-2026-19868
[cve107155]: https://www.cve.org/CVERecord?id=CVE-2026-107155
[cve107154]: https://www.cve.org/CVERecord?id=CVE-2026-107154
[kev]: https://www.cisa.gov/known-exploited-vulnerabilities-catalog
