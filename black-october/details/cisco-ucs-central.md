# Cisco UCS Central: authenticated path traversal to commands and files

**Last updated:** 2026-11-04 (America/New_York)

[Main Cisco UCS Central summary](../black-october-2026.md#cisco-ucs-central-authenticated-path-traversal-to-commands-and-files) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Cisco rates [CVE-2026-76506](https://www.cve.org/CVERecord?id=CVE-2026-76506) CVSS 3.1 7.6 High** (`AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:L/A:L`). NVD has not scored it. The web management interface of Cisco UCS Central Software does not validate a path in an HTTP request. A remote attacker who already has a user account can run arbitrary commands, write arbitrary files, and read sensitive information. Cisco says the flaw does not depend on device configuration, and that there is no workaround. Cisco PSIRT is not aware of public announcements or malicious use. [cisco-sa-cucs-rce-LzHSFRDQ][advisory]

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-04). Cisco does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private report | Unknown | Anand Murugan of Gulf Business Machines (GBM). Cisco does not give a date. [Advisory][advisory] |
| Public announcement | 2026-11-04 16:00 GMT | Advisory version 1.0, Final. First fixed release is 2.1(2c). [Advisory][advisory] |
| CVE record published | 2026-11-04 16:27:03 UTC | Cisco CNA. CVSS 3.1 7.6. [CVE-2026-76506][cve] |

## Detection

This is the UCS Central management appliance, not UCS Manager on a fabric interconnect and not a server's CIMC.

In the UCS Central GUI, read **System > Settings > System Profile > Version** (or the equivalent About page). The advisory's fixed floor is the only version line it publishes:

| Running release | Status |
|---|---|
| 2.0 and earlier, including every 2.0(1x) build the CVE record lists | Vulnerable. Cisco says migrate to a fixed release. |
| 2.1(1a), 2.1(1b), 2.1(1c), 2.1(2a), 2.1(2b) | Vulnerable. The CVE record lists these as affected. |
| 2.1(2c) and later 2.1 releases | Fixed, per the advisory. |
| A 2.1 build this table does not name, other than 2.1(2c) | **Unknown.** The CVE record stops at 2.1(2b) as affected and the advisory names only 2.1(2c) as the first fix. Do not treat an unlisted build as safe. |

A version string you cannot read is **unknown**, not safe. UCS Manager and CIMC are not this product. A login to the management interface is the condition the advisory requires; keeping the interface off the internet reduces who can try, and it is not the fix.

## Remediation

1. Upgrade Cisco UCS Central Software to **2.1(2c) or later**. Releases **2.0 and earlier** have no fix on that train; Cisco says to migrate to a fixed release.
2. There is no workaround. Restricting the management interface to an administration network is sensible and does not close the flaw for an account that can still reach it.
3. Cisco says any user credential on the device is enough. After the upgrade, review accounts you do not recognize. The advisory does not say the upgrade expires existing sessions.

## Verification

After the upgrade, read the running version again. It should be **2.1(2c) or later**. A package staged but not activated is not the fix.

Do not send a crafted path to the management interface. That is an exploit, not a check.

## Compromise response

Cisco PSIRT says it is not aware of malicious use. If an untrusted account could reach the interface before the upgrade:

- Treat commands and files that account could reach as exposed. The upgrade does not show whether a request already wrote a file or read a secret.
- Review administrator accounts, API tokens, and recent configuration changes from a trusted console.
- Rotate credentials the appliance could read, including any backup or integration secret stored on it.

An account you trust, on an interface that was not reachable by anyone else, is not by itself evidence of a compromise.

## Sources

- [Cisco advisory cisco-sa-cucs-rce-LzHSFRDQ][advisory] — first published 2026-11-04 16:00 GMT, version 1.0 Final. CVSS 3.1 7.6. Fixed release 2.1(2c). No workaround. No malicious use known to PSIRT.
- [CVE-2026-76506][cve] — Cisco CNA, published 2026-11-04 16:27:03 UTC. Lists affected 2.0(1a) through 2.0(1w) and 2.1(1a) through 2.1(2b).
- [CISA KEV JSON feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.04, checked 2026-11-04. This CVE is not listed.

[advisory]: https://sec.cloudapps.cisco.com/security/center/content/CiscoSecurityAdvisory/cisco-sa-cucs-rce-LzHSFRDQ
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-76506
