# Panorama Suite: an LDAP login reaches another role

[Main guide](../black-october-2026.md#panorama-suite-an-ldap-login-reaches-another-role)

**CODRA rates [CVE-2026-136760](https://www.cve.org/CVERecord?id=CVE-2026-136760) CVSS 4.0 7.1 High.** The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`. The weakness is CWE-90. When the Web HMI or Desktop HMI authenticates through POSIX LDAP, a caller who already knows a valid directory username and password can bypass some of the injection checks and reach an area, a business role, or a permission they were not given. LDAP Active Directory authentication is not affected, and an installation that does not use POSIX LDAP is outside it. CODRA lists Panorama Suite **2020**, **2022-SP1**, **2023**, **2025**, and **2025 Updated Dec. 25 before update PS-2510-02-1317**. The fix for the 2025 line is update **PS-2510-02-1317 or later**. The older lines have to move to that line first. The record does not report exploitation.

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
| **Public announcement** | **2026-11-26; time/TZ unknown** | CODRA published CVE-2026-136760. CVSS 4.0 7.1. Bulletin BS-040. [CVE][cve] |
| **Last updated** | **2026-11-27 (America/New_York)** | New item. The fix is PS-2510-02-1317. |

## Detection

Record the Panorama Suite release and whether the Web HMI or Desktop HMI uses POSIX LDAP. The five releases above are the ones CODRA names. Active Directory authentication, and an installation with no POSIX LDAP, are outside the condition. Reading the configuration changes no state. A release you cannot read is unknown, not safe.

## Remediation

1. On Panorama Suite 2025 Updated Dec. 25, install update **PS-2510-02-1317 or later**.
2. On 2020, 2022-SP1, 2023, and 2025, upgrade to 2025 Updated Dec. 25 and then install that same update.
3. Until then, POSIX LDAP authentication is the path. Moving those logins to Active Directory takes them out of the condition CODRA names. It is not a substitute for the update.

## Verification

- The installed update is PS-2510-02-1317 or later, on the 2025 Updated Dec. 25 line.
- Do not send an LDAP filter to test it.

## Compromise response

The record describes a signed-in user reaching a role they were not given. Review role and permission changes made by POSIX LDAP accounts after the installation was exposed. The record publishes no log line.

## Sources

- [CVE-2026-136760][cve] — CODRA, published 2026-11-26. CVSS 4.0 7.1. POSIX LDAP only. Fixed by PS-2510-02-1317. Points to bulletin BS-040 at `my.codra.net`.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-27. CVE-2026-136760 is not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-136760
