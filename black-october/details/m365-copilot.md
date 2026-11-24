# Microsoft 365 Copilot: a signed-in user could raise their own privileges

**Last updated:** 2026-11-24 (America/New_York)

[Main summary](../black-october-2026.md#microsoft-365-copilot-a-signed-in-user-could-raise-their-own-privileges) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Microsoft 365 Copilot is the hosted assistant inside Microsoft 365. Microsoft says improper authorization there let an attacker who already had some access raise their privileges over the network. Microsoft says it has already fixed the service, and that customers have nothing to install.

**Microsoft rates [CVE-2026-50691](https://www.cve.org/CVERecord?id=CVE-2026-50691) Critical, CVSS 3.1 base 9.9.** Microsoft is the CNA. The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H/E:U/RL:O/RC:C`. The base score is 9.9 and the temporal score is 8.6. The weakness is CWE-285, improper authorization. Microsoft's description is one sentence: improper authorization in M365 Copilot allows an authorized attacker to elevate privileges over a network. The record names no feature, no request, and no version. NVD has not scored it.

**CISA KEV:** Not listed (catalog 2026.11.24, checked 2026-11-24). Microsoft's exploitability table says publicly disclosed no and exploited no. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **MSRC advisory published** | **2026-11-19 08:00 UTC** | CVE-2026-50691. Critical. CVSS 3.1 base 9.9. Microsoft says the service is already mitigated and that no customer action resolves it. [MSRC][msrc] |
| NVD published the record | 2026-11-23 | Awaiting enrichment. NVD has not scored it. [NVD][nvd] |
| **Last updated** | **2026-11-24 (America/New_York)** | New item. Nothing to install. |

## Detection

1. There is no customer-side version to read. Microsoft 365 Copilot is a hosted service, and the advisory names no build.
2. Microsoft publishes no indicator. A review of Copilot and Microsoft 365 audit logs can show who used the assistant. It cannot show whether this flaw was used, because Microsoft does not say what the request looks like.
3. This is not the Entra Connect Health exposure. That one has no CVE and was a read of tenant metadata. It is also not the September Copilot records, CVE-2026-85885 and CVE-2026-85887.

## Remediation

There is nothing to install. Microsoft's customer-action note says the vulnerability requires no customer action to resolve, and the FAQ says Microsoft has fully mitigated it. The CVE exists, Microsoft says, to document a flaw in a cloud service that customers cannot patch themselves.

Microsoft does not name a workaround. Restricting who can use Copilot is a normal control and is not a fix for a service Microsoft says is already mitigated.

## Verification

- The MSRC page for CVE-2026-50691 still says no customer action is required. There is no build number to confirm on a host.
- Do not try to raise a privilege to test the advisory. Microsoft says the path is closed, and the page does not describe the request.

## Compromise response

Microsoft says it has not seen exploitation. The advisory does not say what an attacker who used it would have been able to read or change beyond the CVSS impacts, so there is no indicator list to hunt. If a later notice names an affected tenant, follow that notice. The service-side fix does not undo an action that already happened.

## Sources

- [MSRC, CVE-2026-50691][msrc] — released 2026-11-19. Critical. CVSS 3.1 base 9.9, temporal 8.6. CWE-285. Exploited: No. Publicly disclosed: No. Customer action not required. The FAQ says the vulnerability has already been fully mitigated by Microsoft.
- [CSAF][csaf] — the same advisory as JSON. Initial release date 2026-11-19T08:00:00.000Z. Product status fixed for Microsoft 365 Copilot.
- [NVD][nvd] — published 2026-11-23. Awaiting enrichment. Repeats Microsoft's description and score. Marks the record exclusively hosted.
- [CISA KEV JSON][kev] — catalog 2026.11.24, released 2026-11-24T17:47:46.199Z, checked 2026-11-24. CVE-2026-50691 is not listed.

[msrc]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-50691
[csaf]: https://msrc.microsoft.com/csaf/advisories/2026/msrc_cve-2026-50691.json
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-50691
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
