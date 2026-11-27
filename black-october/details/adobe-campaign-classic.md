# Adobe Campaign Classic: eight Critical code-execution and authorization flaws

**Last updated:** 2026-11-27 (America/New_York)

[Main summary](../black-october-2026.md#adobe-campaign-classic-eight-critical-code-execution-and-authorization-flaws) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**CVEs:** [CVE-2026-104350](https://www.cve.org/CVERecord?id=CVE-2026-104350), [CVE-2026-104351](https://www.cve.org/CVERecord?id=CVE-2026-104351), [CVE-2026-104353](https://www.cve.org/CVERecord?id=CVE-2026-104353), [CVE-2026-104354](https://www.cve.org/CVERecord?id=CVE-2026-104354), [CVE-2026-105489](https://www.cve.org/CVERecord?id=CVE-2026-105489), [CVE-2026-105779](https://www.cve.org/CVERecord?id=CVE-2026-105779), [CVE-2026-105780](https://www.cve.org/CVERecord?id=CVE-2026-105780), [CVE-2026-105781](https://www.cve.org/CVERecord?id=CVE-2026-105781).

**Adobe rates all eight CVSS 3.1 Critical.** The highest-rated issues are CVE-2026-104351, CVE-2026-104353, CVE-2026-105780 and CVE-2026-105489 (9.9); CVE-2026-105781 is 9.8. They can lead to arbitrary code execution or security-feature bypass in affected on-premise and hybrid Adobe Campaign Classic components.

**A second bulletin moved the floor.** [APSB26-194](https://www.adobe.com/trust/security/products/campaign/apsb26-194.html), published 2026-11-24, says 7.4.4 build 9403 and earlier, and 7.4.5 build 9420 and earlier, are affected. The fixes are **7.4.4 build 9404** and **7.4.5 build 9421**. Adobe rates twelve issues Critical. Seven are code injection at CVSS 3.1 9.9: [CVE-2026-125676](https://www.cve.org/CVERecord?id=CVE-2026-125676), [CVE-2026-125675](https://www.cve.org/CVERecord?id=CVE-2026-125675), [CVE-2026-123987](https://www.cve.org/CVERecord?id=CVE-2026-123987), [CVE-2026-123986](https://www.cve.org/CVERecord?id=CVE-2026-123986), [CVE-2026-123723](https://www.cve.org/CVERecord?id=CVE-2026-123723), [CVE-2026-123722](https://www.cve.org/CVERecord?id=CVE-2026-123722), and [CVE-2026-123342](https://www.cve.org/CVERecord?id=CVE-2026-123342). The other five are 9.0 to 9.6. Build 9403, the October fix, leaves all twelve in place. The bulletin applies to the on-premise deployment. Adobe says it is not aware of exploits in the wild for any of them.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-27). Adobe states it is not aware of exploitation in the wild for any issue in APSB26-162 or APSB26-194. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Public bulletin and fixed build | 2026-10-27; time/TZ unknown | Adobe published APSB26-162 for Campaign Classic v7. |
| **Second bulletin** | **2026-11-24; time/TZ unknown** | APSB26-194. Twelve Critical flaws. Fixed in 7.4.4 build 9404 and 7.4.5 build 9421. |

## Detection

Inventory fully on-premise Campaign Classic and on-premise components of hybrid deployments, including every application and workflow host. Record the exact installed build rather than only the major release. Adobe-hosted instances were remediated by Adobe and do not require this customer update.

Adobe has not published CVE-specific indicators of compromise. Treat unexpected Campaign service accounts, processes, configuration changes, web-tier requests to administrative paths, or application and database audit anomalies as investigation leads, not proof of exploitation. Missing logs or indicators do not prove that a deployment is safe.

## Remediation

Update affected Windows and Linux **Adobe Campaign Classic v7** to **7.4.4 build 9404** or **7.4.5 build 9421**. Build 9403, the October fix, leaves the November 24 flaws in place. Restart the Adobe Campaign server (`nlserver`) after deployment so the patched build is loaded. Restrict access to Campaign administration and application hosts to trusted operators while the update is deployed; access restriction is not a substitute for the vendor update.

## Verification

Confirm each on-premise or hybrid component reports build 9404 or later on the 7.4.4 line, or 9421 or later on the 7.4.5 line, after restart, then perform ordinary authorized campaign and workflow controls in staging. Do not exercise code-injection, command-injection, SQL-injection, authorization-bypass, or XSS payloads as a test.

## Compromise response

If compromise is suspected, preserve Campaign, web-server, application, database and identity logs before cleanup. Review privileged accounts, integration credentials, workflow changes and host persistence from a known-clean administrative system. Rebuild or recover untrusted hosts and rotate credentials readable by the affected service; patching alone does not establish that prior exploitation did not occur.

## Sources

- [Adobe APSB26-162](https://www.adobe.com/trust/security/products/campaign/apsb26-162.html) — October 27. Eight Critical flaws. Fixed in 7.4.4 build 9403. Adobe is not aware of exploits.
- [Adobe APSB26-194](https://www.adobe.com/trust/security/products/campaign/apsb26-194.html) — published 2026-11-24. Twelve Critical flaws, seven at 9.9. Fixed in 7.4.4 build 9404 and 7.4.5 build 9421. On-premise only. Adobe is not aware of exploits.
- [Adobe Campaign Classic latest release notes](https://experienceleague.adobe.com/en/docs/campaign-classic/using/release-notes/latest-release) — deployment scope, hosted-instance status and restart requirement.
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — KEV status.
