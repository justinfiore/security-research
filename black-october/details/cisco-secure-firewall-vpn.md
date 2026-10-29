# Cisco Secure Firewall ASA and FTD: exploited SSL VPN denial of service

**Last updated:** 2026-10-29 (America/New_York)

[Main Cisco Secure Firewall summary](../black-october-2026.md#cisco-secure-firewall-asa-and-ftd-exploited-ssl-vpn-denial-of-service) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-76418](https://www.cve.org/CVERecord?id=CVE-2026-76418) — Cisco CVSS 3.1 8.6 High (`AV:N/AC:L/PR:N/UI:N/S:C/C:N/I:N/A:H`).** An unauthenticated remote attacker can send a crafted request to the Remote Access SSL VPN service and reload an affected Cisco Secure Firewall ASA or FTD device. The vulnerable path requires the SSL VPN service to be reachable and secondary authentication in the applicable tunnel group. Cisco reports active exploitation.

**CISA KEV:** Not listed (catalog 2026.10.28, checked 2026-10-29). Cisco reports active exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Discovery | Unknown | Cisco credits Eric Fernald during a TAC support case; no private-report date is published. [Cisco advisory][cisco] |
| Cisco advisory and fixed releases | 2026-10-28 19:15 GMT | Cisco published `cisco-sa-asaftd-tunnel-dos-s6mgkb75`, version 1.0 Final. [Cisco advisory][cisco] |
| CVE record published | 2026-10-28; time/TZ unknown | Cisco CNA publication date. [CVE record][cve] |
| Active exploitation known to Cisco | 2026-10 (exact day not established) | Cisco PSIRT reports active exploitation. [Cisco advisory][cisco] |

## Detection

1. Inventory Cisco Secure Firewall **ASA** and **FTD** appliances and record their exact software train and release.
2. Determine whether Remote Access SSL VPN is enabled. On ASA, inspect the running configuration for `webvpn` and `enable <interface>`; on FTD, inspect the deployed Remote Access VPN policy in FMC or FDM.
3. Review the applicable tunnel groups, including `DefaultWEBVPNGroup`, for `secondary-authentication-server-group`. When `tunnel-group-list enable` is configured, inspect every listed group; when it is absent, the default group can still be exposed. A successful VPN login is not required to reach the vulnerable path.
4. Preserve VPN, device-reload, authentication and external firewall logs before making changes. A clean configuration or log review cannot establish that earlier exploitation did not occur.

## Remediation

1. Upgrade to Cisco's first fixed release for the installed train: ASA 9.16 and earlier → **9.16.4.104**; 9.18 → **9.18.4.96**; 9.20 → **9.20.4.50**; 9.22 → **9.22.3.200**; 9.23 → **9.23.1.48**; 9.24 → **9.24.1.27** or **9.24.10.1**. For FTD: 7.0 and earlier → **7.0.11**; 7.2 → **7.2.13**; 7.4 → **7.4.9**; 7.6 → **7.6.7**; 7.7 → **7.7.14**; 10.0 → **10.0.3**; 10.1 → **10.1.1**. [Cisco advisory][cisco]
2. Cisco states there is no workaround. Until the upgrade is complete, its tested mitigation is to remove secondary authentication from the applicable tunnel group, or, where `DefaultWEBVPNGroup` does not use secondary authentication, disable the tunnel-group list. Both change VPN functionality or security posture; validate them in the deployment before use.
3. Cloud-delivered Firewall, cloud-delivered FMC and Secure FMC are not affected according to Cisco.

## Verification

- Re-check every appliance's running release and confirm it meets Cisco's first-fixed version for its train.
- Verify the deployed Remote Access VPN policy and tunnel-group configuration match the intended post-change design, then use a normal authorized VPN connection to confirm service continuity. Do not send crafted VPN requests.
- Monitor device reload and VPN-authentication logs after rollout; retain the before-and-after configuration review in the change record.

## Compromise response

Cisco's advisory describes a device-reload outcome, not post-compromise indicators. Because Cisco reports active exploitation, preserve logs and investigate anomalous VPN activity, unexpected reloads and configuration changes before applying disruptive changes. Engage Cisco TAC if signs of unauthorized activity exist; upgrading prevents this vulnerability but cannot determine whether prior access or configuration changes occurred.

## Sources

- [Cisco advisory][cisco] — score, affected configuration, fixed releases, mitigation and active-exploitation statement.
- [Cisco CNA CVE record][cve] — CVE identity, score and publication date.
- [CISA KEV JSON feed][kev] — catalog 2026.10.28 status.

[cisco]: https://sec.cloudapps.cisco.com/security/center/content/CiscoSecurityAdvisory/cisco-sa-asaftd-tunnel-dos-s6mgkb75
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-76418
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
