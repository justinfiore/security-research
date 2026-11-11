# Cisco BroadWorks: an unauthenticated XML message reads a file

**Last updated:** 2026-11-10 (America/New_York)

[Main BroadWorks summary](../black-october-2026.md#cisco-broadworks-an-unauthenticated-xml-message-reads-a-file) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Cisco BroadWorks accepts provisioning requests as XML on the Open Client Interface. Before release RI.2026.07 the parser resolves external entities, so an unauthenticated message can read a file as the BroadWorks user. Cisco rates it High. CISA added it to KEV on November 10.

**Cisco rates [CVE-2026-20320](https://www.cve.org/CVERecord?id=CVE-2026-20320) CVSS 3.1 7.5 High** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N`). The advisory, first published 2026-08-19 16:00 GMT, says a crafted XML message to the Open Client Interface – Provisioning (OCI-P) service lets the attacker view files with the privileges of the BroadWorks user. There is no workaround. The affected products, on any release earlier than **RI.2026.07**, are the Application Delivery Platform (Open Client Server and OCIOverSoap), the Application Server, the Profile Server, and the Xtended Services Platform. The first fixed release for each is RI.2026.07. Cisco's bug ID is CSCwv48590.

Cisco's advisory says the PSIRT is not aware of any malicious use. That sentence is from the August 19 text. CISA's November 10 listing is the statement that exploitation is known.

**CISA KEV:** Listed — [CVE-2026-20320](https://www.cve.org/CVERecord?id=CVE-2026-20320) added 2026-11-10, federal due date 2026-11-24. Ransomware use Unknown. The feed says an unauthenticated remote attacker can read sensitive configuration information. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-08-19 16:00 GMT** | Cisco advisory cisco-sa-bworks-xxe-uwUd7CEt, version 1.0 Final. CVSS 3.1 7.5. Fixed in RI.2026.07. No workaround. PSIRT not aware of malicious use. [Advisory][cisco] |
| CVE record | 2026-08-19; time/TZ unknown | Cisco CNA. Same description and score. [CVE][cve] |
| **CISA KEV** | **2026-11-10; time/TZ unknown** | Added. Federal due date 2026-11-24. [KEV][kev] |

## Detection

1. Read the BroadWorks release on the Application Delivery Platform, Application Server, Profile Server, and Xtended Services Platform. Earlier than RI.2026.07 is the affected line. Cisco says the vulnerability does not depend on device configuration.
2. OCI-P is the service the advisory names. A host that does not run it is outside the attack the advisory describes. Confirm that from the product's own service list, not from a closed port alone.
3. Cisco publishes no log line for a successful read. A request log that shows XML to OCI-P from an address that does not provision is the place to look. Absence of that request is not proof a file was not read.

## Remediation

1. Upgrade each affected server to **RI.2026.07** or later. Cisco says that is the first fixed release for all four products.
2. There is no workaround. Restricting who can reach OCI-P reduces who can send the message. It does not fix the parser.
3. The upgrade does not show whether a file was already read.

## Verification

- Each of the four products reports RI.2026.07 or later.
- Provisioning from a known client still works. Do not send an external entity to test the parser.

## Compromise response

A file read as the BroadWorks user can include configuration and credentials that user can open. Cisco does not publish a list.

- If the server was on a release before RI.2026.07 and OCI-P was reachable, review provisioning logs for XML from an unexpected address and rotate credentials stored in files that user can read.
- The KEV addition says exploitation is known. It does not say which customer was affected. A log with nothing in it is not a clearance.

## Sources

- [Cisco advisory cisco-sa-bworks-xxe-uwUd7CEt][cisco] — first published 2026-08-19 16:00 GMT, version 1.0 Final. CVSS 3.1 7.5. Affected releases earlier than RI.2026.07 on four products. No workaround. PSIRT not aware of malicious use as of that publication.
- [CVE-2026-20320][cve] — Cisco CNA, published 2026-08-19. Same score and description.
- [CISA alert, November 10](https://www.cisa.gov/news-events/alerts/2026/11/10/cisa-adds-six-known-exploited-vulnerabilities-catalog) — one of six additions that day.
- [CISA KEV JSON][kev] — catalog 2026.11.10. Added 2026-11-10, due 2026-11-24. Ransomware use Unknown.

[cisco]: https://sec.cloudapps.cisco.com/security/center/content/CiscoSecurityAdvisory/cisco-sa-bworks-xxe-uwUd7CEt
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-20320
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
