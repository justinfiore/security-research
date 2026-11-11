# Ivanti Endpoint Manager: a SQL query runs code before login

**Last updated:** 2026-11-11 (America/New_York)

[Main Ivanti summary](../black-october-2026.md#ivanti-endpoint-manager-a-sql-query-runs-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Ivanti rates [CVE-2026-121653](https://www.cve.org/CVERecord?id=CVE-2026-121653) CVSS 3.1 9.8 Critical** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`). SQL injection in the Core of Ivanti Endpoint Manager, before version 2024 SU8, lets a remote attacker who is not logged in run code. The CVE record's default status is affected, and it names 2024 SU8 as unaffected. It does not list a lower bound. NVD has not scored it. The record was published 2026-11-10 15:28:19 UTC.

The same day Ivanti published [CVE-2026-121683](https://www.cve.org/CVERecord?id=CVE-2026-121683), CVSS 3.1 9.4 Critical (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:H/A:H`). Missing authentication in Cloud Services Application version 5.0.8 lets a remote attacker who is not logged in add or delete a trusted EPM Core certificate entry. The record's default status is affected, and its versions list says unaffected at 5.0.8. That is the version the description names. The advisory is the page that says which build is fixed. This run could not read the hub pages.

This is not the Ivanti Connect Secure flaw tracked separately.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-11) for either CVE. The reviewed sources do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-10 15:28:19 UTC** | CVE-2026-121653 published. [Record][cve] |
| CSA record | 2026-11-10 15:33:51 UTC | CVE-2026-121683. [Record][cve683] |
| CISA KEV | Not listed (catalog 2026.11.10, checked 2026-11-11) | [KEV][kev] |
| **Last updated** | **2026-11-11 (America/New_York)** | New item. The hub advisories did not load. |

## Detection

Read the version from the Endpoint Manager console, or from the installed-product list on the Core server. A build earlier than 2024 SU8 is inside CVE-2026-121653. The record does not name a first affected release, so an older supported line is in scope until the advisory says otherwise.

For Cloud Services Application, a server on 5.0.8 is the version the description names. Do not clear it because the versions list says unaffected at 5.0.8. Read the advisory.

Do not send a SQL statement to test the Core.

## Remediation

1. Upgrade Endpoint Manager to **2024 SU8**. The CVE record names that build as unaffected.
2. For Cloud Services Application, install the build named in [Ivanti's CSA advisory][csa]. Do not pick 5.0.8 from the CVE record's versions list: the description says 5.0.8 is the affected version.
3. Until the Core is on 2024 SU8, keep it off untrusted networks. The record states no workaround.
4. The upgrade does not show whether a query already ran, or whether a certificate entry was already added.

## Verification

- The console reports Endpoint Manager 2024 SU8 or later.
- A management task you already use still completes. Do not send a crafted query.

## Compromise response

Ivanti's record does not publish an indicator. If the Core was reachable from an untrusted network before the upgrade, treat code execution as possible.

- Preserve the Core logs from before the upgrade.
- Review new administrator accounts, new scheduled tasks, and files written by the Core service account.
- On Cloud Services Application, review the trusted EPM Core certificate entries for one you did not add.
- If you find evidence a command ran, rotate credentials that service could read. The upgrade does not remove that.

## Sources

- [CVE-2026-121653][cve] — Ivanti CNA, published 2026-11-10 15:28:19 UTC. CVSS 3.1 9.8. Unaffected at 2024 SU8. Default status affected.
- [Ivanti EPM advisory, November 2026][epm] — the advisory URL in the CVE record. This run could not read the page.
- [CVE-2026-121683][cve683] — Ivanti CNA, published 2026-11-10 15:33:51 UTC. CVSS 3.1 9.4. Description names version 5.0.8. The versions list says unaffected at 5.0.8.
- [Ivanti CSA advisory][csa] — the advisory URL in that record. This run could not read the page.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-11. Neither CVE is listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-121653
[cve683]: https://www.cve.org/CVERecord?id=CVE-2026-121683
[epm]: https://hub.ivanti.com/s/article/Security-Advisory-Ivanti-Endpoint-Manager-EPM-November-2026?language=en_US
[csa]: https://hub.ivanti.com/s/article/Security-Advisory-Ivanti-CSA-CVE-2026-121683?language=en_US
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
