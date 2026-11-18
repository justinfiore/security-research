# CIRCUTOR PowerStudio: an unsigned token is any user

**Last updated:** 2026-11-18 (America/New_York)

[Main PowerStudio summary](../black-october-2026.md#circutor-powerstudio-an-unsigned-token-is-any-user) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-120387](https://www.cve.org/CVERecord?id=CVE-2026-120387) is an authentication bypass in CIRCUTOR PowerStudio SCADA WAVE for 64-bit Windows. CIRCUTOR is the CNA and rates it **CVSS 4.0 10.0 Critical**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`. The product accepts a JSON Web Token whose algorithm is `none` and does not check a cryptographic signature, so the token impersonates another user. The record says the desktop version is affected from **24.8.0 before 24.11.17.0**, and unaffected at **24.11.17.0**. NVD has not published its own score.

CIRCUTOR's cybersecurity page lists the same CVE as Critical, dated 16/11/2026, product Power Studio Wave, version 24.8.0 to 24.11.17. The PDF linked from that row is on a SharePoint path that asks for a login. This guide does not use that PDF.

A researcher write-up dated August 3, 2026, describes the same behavior on **24.11.6.0** and scores it CVSS 3.1 8.6. It says one shared library accepts the unsigned token on every microservice, and that reaching a service port is enough to stop the engine or push configuration. It says that result is not itself code execution. Where the researcher and the CNA disagree, the CNA score and the fixed version are what this guide recommends.

**CISA KEV:** Not listed (catalog 2026.11.17, checked 2026-11-18). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Researcher write-up | 2026-08-03; time/TZ unknown | Tested 24.11.6.0. Researcher score CVSS 3.1 8.6. [0day Rubbish][blog] |
| CIRCUTOR product page | 2026-11-16; time/TZ unknown | Critical. Version 24.8.0 to 24.11.17. The report PDF needs a login. [CIRCUTOR][vendor] |
| **Public announcement** | **2026-11-17; time unknown** | CVE record published by CIRCUTOR. NVD published 2026-11-17 05:18:33 UTC. |
| **Last updated** | **2026-11-18 (America/New_York)** | New item. Install 24.11.17.0. |

## Detection

On the Windows host, open PowerStudio and read the version from its about box, or read the file version of the installed executable. A build below 24.11.17.0 and at or above 24.8.0 is inside the record. The record does not say whether a build older than 24.8.0 is affected.

The researcher's write-up names these listeners on 24.11.6.0. Treat them as a lead for that build, not as a list the vendor confirmed:

| Service | Port the write-up names | What a forged token could do, on that account |
|---|---|---|
| PSSWidgets | 8105, and a gateway on 8091 | Upload, download, or delete files |
| PSSEvents | 8101 | Change communication settings |
| PSSAdministrator | 8089, bound to loopback by default | Stop or start the engine |

A host that does not run PowerStudio is outside this entry. A service that is not reachable from a network you do not trust is still affected if something else on the host can reach it.

## Remediation

1. Install **24.11.17.0 or later** from CIRCUTOR.
2. Until that build is running, do not expose the product's service ports to a network you do not trust.
3. The update does not show whether a request already stopped the engine or changed a configuration. Compare the configuration with a copy you trust.

## Verification

- The about box or the file version reads 24.11.17.0 or later.
- Do not send an unsigned token. The check is the version, not a login attempt.

## Compromise response

No source publishes an indicator for a real incident. The researcher's account of what the token can do is engine stop and start, a configuration push, and file upload and delete. An engine that stopped with no operator action, or a configuration change with no matching login, is a lead. It is not proof. Rotate credentials stored in the product after the upgrade if you cannot account for who used them.

## Sources

- [CVE-2026-120387](https://www.cve.org/CVERecord?id=CVE-2026-120387) — CNA CIRCUTOR. Published 2026-11-17. CVSS 4.0 10.0. Affected from 24.8.0 before 24.11.17.0. Unaffected at 24.11.17.0.
- [CIRCUTOR, ciberseguridad][vendor] — row dated 16/11/2026. Critical. Power Studio Wave, 24.8.0 to 24.11.17. The linked report is a SharePoint file that asks for a login.
- [Researcher write-up][blog] — August 3, 2026. Tested 24.11.6.0. CVSS 3.1 8.6. Says the result is not itself code execution.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.17, read 2026-11-18. CVE-2026-120387 is not in it.

[vendor]: https://circutor.com/soporte/ciberseguridad/
[blog]: https://0day-rubbish.com/blog/circutor-powerstudio-jwt-alg-none-identity-forgery
