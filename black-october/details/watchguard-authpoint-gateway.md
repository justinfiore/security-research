# WatchGuard AuthPoint Gateway: unauthenticated disruption and forged logins

**Last updated:** 2026-11-05 (America/New_York)

[Back to WatchGuard AuthPoint Gateway summary](../black-october-2026.md#watchguard-authpoint-gateway-unauthenticated-disruption-and-forged-logins) · [Changelog](../../CHANGELOG.md)

WatchGuard published four flaws in **AuthPoint Authentication Gateway** before 7.6.0 on 2026-11-04. The scores are CVSS 4.0, from WatchGuard as CNA. NVD has not scored them. None is in CISA KEV.

- **[CVE-2026-121639](https://www.cve.org/CVERecord?id=CVE-2026-121639) is 9.2 Critical.** Anyone who can reach the gateway host, with no login, can disrupt authentication and delete the local directory-synchronization configuration. WatchGuard says this applies when the gateway uses an LDAP or Active Directory provider. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:L/VA:H/SC:N/SI:N/SA:H`. Confidentiality is none. The high scores are integrity and availability, on the gateway and on subsequent systems for availability. [Advisory][a639]
- **[CVE-2026-121638](https://www.cve.org/CVERecord?id=CVE-2026-121638) is 9.1 Critical.** An on-path attacker can intercept and modify traffic between the gateway and a local RADIUS, LDAP, or ADFS provider because the gateway does not validate that provider's certificate. The vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N`. [Advisory][a638]
- **[CVE-2026-121640](https://www.cve.org/CVERecord?id=CVE-2026-121640) is 9.1 Critical.** An attacker who has seen a legitimate request between gateway components can replay it and perform administrative actions, including disrupting authentication. The vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:N/VI:H/VA:H/SC:N/SI:H/SA:H`. WatchGuard does not name a required provider for this one. [Advisory][a640]
- **[CVE-2026-121637](https://www.cve.org/CVERecord?id=CVE-2026-121637) is 8.9 High.** A network attacker who already has a valid header signature can forge the authentication result and the transaction identifier in an LDAP authentication callback, and get a session they should not have. The vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:N/VI:H/VA:N/SC:N/SI:H/SA:N`. WatchGuard says this applies to LDAP. The advisory page spells the product "AtuhPoint" in that sentence; the title and the product table say AuthPoint. [Advisory][a637]

The CVE records were published 2026-11-04. CVE-2026-121639's record timestamp is 14:44:14 UTC. The other three advisories use the same published date and do not print a clock time. This is the on-premises **AuthPoint Authentication Gateway**, not the AuthPoint cloud service and not a Firebox by itself. A deployment that only uses the cloud service, with no gateway host, is outside these four records.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05) for any of the four CVEs. CISA-ADP records Exploitation "none" for CVE-2026-121639. WatchGuard says it is not aware of exploitation of any of the four. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| CVE records published | 2026-11-04 | WatchGuard CNA. CVE-2026-121639 at 14:44:14 UTC. The other three advisories say Published 2026-11-04 and do not print a clock time. |
| **Last updated** | **2026-11-05 (America/New_York)** | New item. |

## Detection

1. Find hosts running **AuthPoint Authentication Gateway**, not the AuthPoint mobile app and not a Firebox that only points at the AuthPoint cloud. The affected range is **1.0 through every build before 7.6.0**. Read the version on the running gateway.
2. CVE-2026-121639 needs an LDAP or Active Directory provider. CVE-2026-121638 needs RADIUS, LDAP, or ADFS. CVE-2026-121637 needs LDAP. CVE-2026-121640 does not name a provider. A gateway that uses none of those local providers is outside the three configuration-specific flaws and still inside the replay flaw if it is below 7.6.0.
3. The 9.2 flaw needs network access to the gateway host and no login. A gateway that answers from a network you do not trust is in that condition. The certificate flaw needs an on-path position between the gateway and the local provider. The replay flaw needs a captured legitimate request between gateway components. The HMAC flaw needs a valid header signature already in the attacker's hands.
4. WatchGuard publishes no log signature and no indicator of compromise. A quiet authentication log does not show that a callback was not forged or that a request was not replayed.

## Remediation

1. Upgrade AuthPoint Authentication Gateway to **7.6.0 or later**. That is the fixed version on all four advisories. There is no separate fix per CVE.
2. WatchGuard lists no workaround. Taking the gateway off untrusted networks reduces who can send the unauthenticated request. It does not fix certificate validation, replay, or the LDAP callback.
3. A gateway that only syncs to a cloud directory and does not use LDAP, Active Directory, RADIUS, or ADFS is still named by the replay advisory. Do not skip 7.6.0 because those providers are off.
4. Upgrading does not restore a directory-synchronization configuration the 9.2 flaw already deleted, and it does not end a session the HMAC flaw already issued.

## Verification

- The running gateway reports **7.6.0 or later**. A Firebox firmware version is not this number.
- After the upgrade, an LDAP or Active Directory sync configuration that disappeared before the upgrade is not evidence the flaw is still present. Recreate that configuration; the upgrade does not put it back.
- A test login through the local provider still succeeds, and a login you cannot account for is a compromise question, not a version check.

## Compromise response

- If the gateway was reachable from a network you do not trust while it was below 7.6.0, treat the local directory-synchronization configuration as something an attacker could delete, and treat authentication as something they could disrupt. WatchGuard does not say this flaw reads the directory's passwords.
- The HMAC flaw can produce a session the real user did not complete, but only after the attacker already holds a valid header signature. Review sessions that completed without a matching user action, and revoke those sessions in AuthPoint. The upgrade does not revoke them.
- The certificate flaw can expose or change what passed between the gateway and a local RADIUS, LDAP, or ADFS provider. Rotate secrets those providers shared with the gateway if an on-path attacker was plausible on that path. WatchGuard does not name the secrets.
- The replay flaw can repeat an administrative action the attacker observed. Review gateway configuration changes you cannot account for. The upgrade does not undo one that already landed.

## Sources

- [CVE-2026-121639 advisory][a639] — 9.2 Critical. Unauthenticated disruption and deletion of the local directory-synchronization configuration. LDAP or Active Directory. Fixed in 7.6.0. No known exploitation.
- [CVE-2026-121638 advisory][a638] — 9.1 Critical. On-path interception when the gateway uses RADIUS, LDAP, or ADFS. Fixed in 7.6.0.
- [CVE-2026-121640 advisory][a640] — 9.1 Critical. Replay of an observed inter-component request, including disruption of authentication. Fixed in 7.6.0. No provider named.
- [CVE-2026-121637 advisory][a637] — 8.9 High. Forged LDAP authentication result and transaction identifier, given a valid header signature. Fixed in 7.6.0.
- [CVE-2026-121639 record][cve639] — published 2026-11-04 14:44:14 UTC, updated 18:20:22 UTC. CISA-ADP Exploitation "none."
- [CISA KEV JSON feed][kev] — none of the four CVEs listed (catalog 2026.11.04, checked 2026-11-05).

[a639]: https://psirt.watchguard.com/CVE-2026-121639/
[a638]: https://psirt.watchguard.com/CVE-2026-121638/
[a640]: https://psirt.watchguard.com/CVE-2026-121640/
[a637]: https://psirt.watchguard.com/CVE-2026-121637/
[cve639]: https://www.cve.org/CVERecord?id=CVE-2026-121639
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
