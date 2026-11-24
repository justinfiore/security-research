# Microsoft Azure API Management: stored secrets were read

**Last updated:** 2026-11-24 (America/New_York)

[Main summary](../black-october-2026.md#microsoft-azure-api-management-stored-secrets-were-read) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Azure API Management is the cloud service that publishes and fronts an organization's APIs. It stores the credentials those APIs use. Microsoft told customers, in an Azure Service Health security advisory (tracking ID MZK9-GH0) that has not been published as a public MSRC advisory, that a flaw in the Classic tiers let an unauthorized party reach management functions and read secrets stored in an instance. Microsoft says it found the issue on November 18 and closed the access path on November 19.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** The Register describes the customer advisory as critical. That is a description of the notice, not a scored rating.

Microsoft told BleepingComputer the affected tiers are the Classic **Developer, Basic, Standard, and Premium** tiers. The Classic **Consumption** tier and every **v2** tier are not affected. Microsoft says the access applied to Classic instances that were not configured to its recommended security practices. The items Microsoft lists as possibly exposed are secrets stored in named values, client secrets for identity providers, client secrets for OpenID Connect providers, subscription keys, and tokens used to call the direct management API. A credential taken from that configuration can be used against the service it protects, outside API Management, for as long as the issuer still accepts it.

Norway's National Security Authority (NSM) says an unknown actor actively targeted access tokens, secrets, and named values in API Management, and that the flaw was first found by Norway's energy sector. NSM names Equinor and Skagerak Energi among the affected organizations, and says the flaw reaches several sectors in Norway and outside Norway. Equinor disclosed an attack on November 17, a day before Microsoft says it identified the flaw, and later said it found no indication that data was stolen or altered. Skagerak Energi reported an attempted attack with no operational impact. NSM says the extent of exploitation is still not established, and that it has no evidence so far that a compromise affected deliveries at Norwegian organizations.

Microsoft says the November 19 remediation is fully deployed to Microsoft-hosted instances and needed no customer action, and that it rotated Microsoft-controlled keys where appropriate. Microsoft also says the remediation does not invalidate a customer credential that was read before the fix. NSM still asks every customer to check the gateway runtime: open `https://<your-gateway-hostname>/internal-status-0123456789abcdef` and read `RuntimeVersion`. On 0.52.x the last number has to be **31936 or higher**. On 0.53.x it has to be **31938 or higher**. A different pattern, such as `0.53.4608.0` or `0.52.4150.0`, is a v2 or Consumption gateway, and NSM says those thresholds do not apply and that gateway is not vulnerable. A lower number is still vulnerable, and NSM says to contact the provider.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Equinor discloses an attack | 2026-11-17; time unknown | Equinor's own notice. Microsoft says it identified the API Management flaw the next day. [BleepingComputer][bc] |
| Microsoft identifies the flaw | 2026-11-18; time unknown | Azure Service Health advisory MZK9-GH0, as reported. Not a public MSRC advisory. |
| Skagerak Energi reports an attempt | 2026-11-18; time unknown | No operational impact, the company says. |
| **Access path closed** | **2026-11-19; time unknown** | Microsoft says the fix is deployed to hosted instances and does not revoke customer credentials already read. |
| **NSM advisory** | **2026-11-20; time unknown** | Published. Updated 2026-11-23 to say the energy sector, not the power sector, found it first. [NSM][nsm] |
| Microsoft rotation guide | 2026-11-21; time unknown | Public. Does not name the flaw. Updated November 22. [Guide][rotate] |
| **Public report of the advisory** | **2026-11-23 14:42 EST (UTC−05:00)** | BleepingComputer, quoting MZK9-GH0 and a Microsoft statement. The page prints 02:42 PM and no zone; this is Eastern, where the page is edited. |
| **Last updated** | **2026-11-24 (America/New_York)** | New item. Rotate the credentials. |

## Detection

1. List every API Management instance and its tier. Classic Developer, Basic, Standard, and Premium are in scope. Consumption and v2 are not, including a runtime whose version looks like `0.53.4608.0` or `0.52.4150.0`.
2. On a Classic gateway, open `https://<your-gateway-hostname>/internal-status-0123456789abcdef` and read `RuntimeVersion`. 0.52.x is patched at **31936** or higher. 0.53.x is patched at **31938** or higher. A lower number is still vulnerable.
3. Open Azure Service Health and look for tracking ID **MZK9-GH0**. Not seeing it is not a clearance for an instance whose notices you do not read.
4. The direct management API, `<instance>.management.azure-api.net`, does not write to the Azure Resource Manager activity log. Its calls are not evidence you can recover from that log. Microsoft [retired it in March 2025](https://learn.microsoft.com/en-us/azure/api-management/breaking-changes/direct-management-api-retirement-march-2025), which means unsupported, not removed.

## Remediation

Treat every secret stored in a Classic instance as exposed, whether or not the runtime is now above the threshold. Microsoft's fix does not revoke a credential that was read before November 19.

Rotate each one at the system that issued it, then update API Management, then revoke the old value. Microsoft's rotation guide lists subscription keys, named values that contain secrets, backend credentials (headers, query parameters, and client certificates), OAuth 2.0 and OpenID Connect client secrets, connection strings such as an Event Hubs logger, and credentials written directly into policies. Updating the value inside API Management does not revoke the old credential at its issuer.

NSM also says to map what sits behind each instance, so a credential that was copied has a known blast radius. On every instance, set **Management API → Enable Management REST API** to **No** unless something you still run calls the direct management API. That endpoint does not use Entra ID.

A forgotten development or test instance is in scope. The Classic Consumption tier and the v2 tiers are not.

## Verification

- Every Classic Developer, Basic, Standard, and Premium instance has a runtime at or above the threshold for its version, or the provider has confirmed the fix.
- Every named-value secret, identity-provider secret, OpenID Connect client secret, subscription key, and direct-management token that the instance held has been replaced at its issuer, and the old value rejected.
- The direct management API is off on every instance that does not still need it.

## Compromise response

A credential that was valid before November 19 may already have been used against the service behind API Management. Review sign-ins and API calls for the applications whose secrets were stored there, and for the Key Vaults those named values reference, starting at November 17. Equinor says it found no data theft. That statement is about Equinor. It does not clear another tenant. Replacing the secret does not show whether it was already used.

## Sources

- [NSM, November 20, 2026, updated November 23][nsm] — an unknown actor targeted access tokens, secrets, and named values. Equinor and Skagerak Energi are named. Runtime thresholds 31936 on 0.52.x and 31938 on 0.53.x. v2 and Consumption are not covered by those thresholds. No CVE.
- [BleepingComputer, November 23, 2026][bc] — quotes Azure Service Health advisory MZK9-GH0 and a Microsoft statement. Identified November 18, access path closed November 19. Classic Developer, Basic, Standard, and Premium. Consumption and v2 are not affected. The fix does not revoke customer credentials already read.
- [Microsoft, rotating credentials in Azure API Management][rotate] — published November 21, updated November 22. The list of credential types, and the order: replace at the issuer, update API Management, then revoke. The page does not name the flaw.
- [The Record, November 23, 2026](https://therecord.media/norway-microsoft-cyberattack-equinor) — Equinor detected the attack on November 17 and contained it on November 21. Microsoft confirmed the tiers to Recorded Future News.
- [Anders Kristiansen, November 21, 2026](https://anderskristiansen.com/post/2026/apim-legacy-access/) — hunting notes. A credential from the configuration can be used outside API Management. The direct management API does not appear in the activity log. His queries are a map, not a confirmed chain.
- [CISA KEV JSON][kev] — catalog 2026.11.23, checked 2026-11-24. No CVE to match.

[nsm]: https://nsm.no/aktuelt/nsm-deler-tiltak-mot-sarbarhet-i-azure-api-management
[bc]: https://www.bleepingcomputer.com/news/security/microsoft-azure-flaw-exploited-to-steal-customers-api-credentials/
[rotate]: https://techcommunity.microsoft.com/blog/integrationsonazureblog/rotating-credentials-in-azure-api-management/4575478
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
