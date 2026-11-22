# Microsoft Entra Connect Health: a flaw exposed administrator email addresses

**Last updated:** 2026-11-22 (America/New_York)

[Main summary](../black-october-2026.md#microsoft-entra-connect-health-a-flaw-exposed-administrator-email-addresses) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Microsoft Entra Connect Health is the cloud service that monitors hybrid identity: Entra Connect sync, AD FS, and domain controllers. Microsoft told affected customers that a flaw in its API let an unauthorized party read tenant metadata, including administrator and technical-contact email addresses. Microsoft fixed it on its own servers. There is nothing to install.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** Microsoft has not published an MSRC advisory. What follows is Microsoft's Azure Service Health notice and a spokesperson statement, both as reported by BleepingComputer on November 21, 2026. The notice, dated November 20, says Microsoft found the flaw on November 9 after it was introduced on July 23, deployed a server-side fix on November 19, and concluded that unauthorized read-only access to tenant-level metadata had occurred. Microsoft says it found no unauthorized configuration changes.

Microsoft says the exposed information was: email addresses of tenant technical contacts and administrator accounts; tenant IDs, display names, initial domain names, country codes, and regional information; Entra license tiers and directory synchronization status, including whether synchronization was enabled and the last synchronization timestamp; Connect Health onboarding status; and an expired certificate that had registered Connect Health agents with a Microsoft internal service decommissioned in late 2024. Microsoft says that certificate was no longer in use but was still returned by the API.

Microsoft says the flaw did not expose passwords, password hashes, authentication tokens, valid cryptographic keys, on-premises server or Active Directory topology, or Azure subscription information. Microsoft has not said who exploited it, how many tenants were affected, or when exploitation began. BleepingComputer reports that managed service providers received the notice for more than one customer tenant.

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
| Flaw introduced | 2026-07-23; time unknown | Microsoft's notice, as reported. The year is the one BleepingComputer states for the discovery, not a date Microsoft printed on a public advisory. [BleepingComputer][bc] |
| Microsoft finds the flaw | 2026-11-09; time unknown | In the Entra Connect Health API. |
| **Server-side fix** | **2026-11-19; time unknown** | Microsoft says the fix prevents further exploitation. |
| **Investigation concluded** | **2026-11-20; time unknown** | Unauthorized read-only access confirmed. Notices sent through Azure Service Health. |
| **Public report** | **2026-11-21 13:01 EST (UTC−05:00)** | BleepingComputer, quoting the notice and a Microsoft spokesperson. The page prints 01:01 PM and no zone; this is Eastern, where the page is edited. |
| **Last updated** | **2026-11-22 (America/New_York)** | New item. Nothing to install. |

## Detection

1. Open Azure Service Health for each tenant and look for the Entra Connect Health security notice. Receiving it is how Microsoft says it identified an affected tenant. Not receiving it is not a clearance for a tenant whose Service Health alerts you do not read.
2. Microsoft published a PowerShell script at [aka.ms/ConnectHealth/scripts](https://aka.ms/ConnectHealth/scripts) that shows the kinds of tenant metadata the API could return. BleepingComputer says the script shows the current configuration, not what was read during the incident.
3. Review Entra audit and sign-in logs for the administrator and technical-contact accounts the notice names. Microsoft does not publish an indicator that distinguishes this access from ordinary use.

## Remediation

There is no customer-side update. Microsoft says the fix is deployed and that no software update or other customer remediation is required for the vulnerability itself.

Microsoft's notice, as reported, asks affected organizations to warn their security teams about targeted phishing and social engineering that uses the exposed addresses and tenant details, to put phishing-resistant multifactor authentication on privileged accounts, to review Connect Health configuration, and to examine Entra audit and sign-in logs.

The script does not rotate anything. The expired certificate Microsoft describes was already unused; the notice does not ask customers to revoke a current certificate.

## Verification

- Azure Service Health for the tenant has been read. A tenant with no notice is not the same as a tenant whose notices were never delivered.
- Privileged accounts named in a notice use phishing-resistant multifactor authentication.
- Do not call the Connect Health API to see whether the flaw is still open. Microsoft's statement is the only record of the fix.

## Compromise response

A tenant that received the notice had its metadata read. Microsoft says the access was read-only and that it found no configuration changes. That does not show what was done with the addresses afterward. Treat the named administrator and technical-contact addresses as known to the party that read them, and review sign-ins and help-desk requests against those people for a pretext that uses tenant details only Connect Health would have held. Microsoft has not said when the reading began, so the window starts at July 23 only as the date the flaw was introduced.

## Sources

- [BleepingComputer, November 21, 2026][bc] — quotes Microsoft's Azure Service Health notice of November 20 and a Microsoft spokesperson. The notice is not published as an MSRC advisory. Discovery November 9, fix November 19, conclusion November 20. No CVE and no score.
- [Microsoft, Connect Health scripts](https://aka.ms/ConnectHealth/scripts) — the script Microsoft points administrators at. BleepingComputer says it shows current metadata, not the incident.
- [CISA KEV JSON][kev] — catalog 2026.11.20, checked 2026-11-22. No CVE to match.

[bc]: https://www.bleepingcomputer.com/news/security/microsoft-entra-connect-health-flaw-exploited-to-steal-tenant-data/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
