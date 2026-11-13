# ScreenConnect: the RMM+ extension accepts its default secret

**Last updated:** 2026-11-13 (America/New_York)

[Main ScreenConnect summary](../black-october-2026.md#screenconnect-the-rmm-extension-accepts-its-default-secret) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

RMM+ is a third-party extension for ConnectWise ScreenConnect, written by DataComm, not by ConnectWise. It lets other software send commands to managed agents through an API. [CVE-2026-127063](https://www.cve.org/CVERecord?id=CVE-2026-127063) is the API secret: the extension ships with a static default, an administrator can change it, and an installation that keeps the default accepts requests that were not authorized, including requests that send commands to agents. ConnectWise rates it **CVSS 4.0 9.3 Critical**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The record says the flaw is in the extension. The ScreenConnect server and the ScreenConnect client are not affected by it.

ConnectWise's trust-center update, last updated November 12 at 18:45 UTC, says a CVE was assigned to the issue in this independently developed extension. The same update says the campaign that used ScreenConnect partner environments is still under investigation, that the initial access method is not confirmed, and that ConnectWise has found no compromise of its own infrastructure. ConnectWise disabled five extensions where it could: Labtech Plus, RMM Plus, RMM+, RMM Plus Password Link, and RMM+ Password Link. It says about 400 partner environments had at least one of them installed, and that having one installed is not by itself a compromise.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-13). ConnectWise does not say this CVE has been exploited. The campaign it describes is still under investigation, and this record is not that finding. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

A different ScreenConnect flaw, [CVE-2026-84869](https://www.cve.org/CVERecord?id=CVE-2026-84869), has been in KEV since September 11, 2026, with a federal due date of September 14. ConnectWise fixed it in ScreenConnect client **26.6.5**, released September 8, 2026. ConnectWise says the toolkit's attempt to spread from an endpoint to a technician is blocked by that fix. That flaw is in the client, and it is not CVE-2026-127063.

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
| CVE-2026-84869 fixed | 2026-09-08; time unknown | ScreenConnect client 26.6.5. ConnectWise says that fix blocks the toolkit's endpoint-to-technician spread. Not this CVE. [Bulletin][bulletin] |
| CVE-2026-84869 added to KEV | 2026-09-11 | Federal due date 2026-09-14. The client flaw, not CVE-2026-127063. [KEV][kev] |
| **Public announcement** | **2026-11-12; time unknown** | ConnectWise publishes CVE-2026-127063. The disclosure is dated November 12 and gives no clock time. [Disclosure][gh] |
| Trust-center update | 2026-11-12 18:45 UTC | Investigation ongoing. Five extensions disabled where ConnectWise could. [Trust center][trust] |
| **Last updated** | **2026-11-13 (America/New_York)** | New item. Disable the extension. |

## Detection

1. In the ScreenConnect management console, list installed extensions. The names ConnectWise disabled are **Labtech Plus, RMM Plus, RMM+, RMM Plus Password Link, and RMM+ Password Link**. An environment with none of them is outside CVE-2026-127063.
2. The CVE record says every version of the RMM+ extension is affected. It does not name a build number, and the disclosure says no fixed version has been announced. A version check cannot clear it.
3. An extension that is installed and whose API secret was never changed is the configuration the disclosure describes. This guide does not tell you to print that secret to check it.

## Remediation

1. On a cloud-hosted ScreenConnect environment, ConnectWise says it has already disabled and removed the affected extensions. Confirm they are gone. No further action is required for the extension itself.
2. On an on-premises ScreenConnect server, disable the RMM+ extension and confirm it stays disabled. Do not re-enable it and do not reinstall it. ConnectWise says no fixed version has been announced, and that further guidance is still to come.
3. Changing the API secret is what an administrator can do, and the disclosure does not present it as the fix. The instruction ConnectWise gives is to disable the extension.
4. Separately, confirm the ScreenConnect client on managed endpoints is **26.6.5 or later**. That is the fix for CVE-2026-84869, which is a different flaw. Updating the client does not close CVE-2026-127063.

## Verification

- The five extension names are absent from the cloud environment, or disabled on the on-premises server, and a refresh of the extension list still shows them that way.
- Managed endpoints report a ScreenConnect client at **26.6.5 or later**. That check is for CVE-2026-84869 only.
- Do not send a request to the extension's API to test the default secret.

## Compromise response

ConnectWise says the initial access method is not confirmed and that the investigation is ongoing. If the extension was installed and its secret was still the default while the management server was reachable, review commands sent to agents around November 11 and November 12, and look for a ScreenConnect client the environment did not deploy. Huntress reports at least 288 endpoints across 48 organizations reached on November 11; that count is Huntress's, and ConnectWise has not adopted it.

Disabling the extension does not remove a client that was already installed, and it does not show whether a command already ran. A technician workstation that connected to an affected endpoint during that window should be treated as exposed until the client is confirmed at 26.6.5 or later: ConnectWise says the September fix blocks the spread to the technician, and a client older than that does not have the fix.

## Sources

- [ConnectWise disclosure for CVE-2026-127063][gh] — dated November 12, 2026. CVSS 4.0 9.3. Static default API secret in the DataComm RMM+ extension. No fixed version. Cloud environments were cleaned by ConnectWise; on-premises servers disable the extension.
- [CVE-2026-127063][cve] — ConnectWise CNA, published 2026-11-12. Same score and vector. Affects all versions of the RMM+ extension. ScreenConnect server and client are not affected.
- [ConnectWise trust center][trust] — last updated 2026-11-12 18:45 UTC. Five extensions disabled where ConnectWise could. About 400 partner environments had at least one installed. Investigation ongoing, and no compromise of ConnectWise infrastructure found.
- [ScreenConnect security bulletin, September 8, 2026][bulletin] — client 26.6.5 fixes CVE-2026-84869. ConnectWise says that fix blocks the toolkit's spread from an endpoint to a technician.
- [CISA KEV JSON][kev] — catalog 2026.11.10, checked 2026-11-13. CVE-2026-127063 is not listed. CVE-2026-84869 was added 2026-09-11, due 2026-09-14.

[gh]: https://github.com/ConnectWise-Advisories/Disclosures/blob/main/CVE-2026-127063/README.md
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-127063
[trust]: https://www.connectwise.com/company/trust/advisories
[bulletin]: https://www.connectwise.com/company/trust/security-bulletins/2026-09-08-screenconnect-bulletin
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
