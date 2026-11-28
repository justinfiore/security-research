# Mendix: a token identifier is enough for the introspection endpoint

**Last updated:** 2026-11-27 (America/New_York)

[Main guide](../black-october-2026.md#mendix-a-token-identifier-is-enough-for-the-introspection-endpoint)

Siemens published [SSA-545865][adv] on 2026-11-27, version V1.0. Siemens is the CNA. It rates [CVE-2026-124981](https://www.cve.org/CVERecord?id=CVE-2026-124981) **CVSS 3.1 8.7 High** and **CVSS 4.0 9.4 Critical**. The vectors are `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:C/C:H/I:H/A:N` and `CVSS:4.0/AV:N/AC:H/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:H/SI:H/SA:N`. The weakness is CWE-347.

The Mendix OIDC Provider module does not properly check the integrity of a JWT sent to its token introspection endpoint. The endpoint can match that token to a real token record from the `jti` value alone. An attacker with no account who can reach the endpoint, and who has the `jti` of an active token, can hijack that account's session. Siemens does not report exploitation. NVD has not scored it.

The module is part of each app. Updating the Marketplace component does nothing until that app is deployed again.

**CISA KEV:** Not listed (catalog 2026.11.27, checked 2026-11-27). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-27; time/TZ unknown** | SSA-545865 V1.0. CVSS 3.1 8.7 and CVSS 4.0 9.4. [Advisory][adv] |
| CVE record | 2026-11-27; time/TZ unknown | Siemens published CVE-2026-124981. Same scores. [CVE][cve] |
| **Last updated** | **2026-11-27 (America/New_York)** | New item. |

## Detection

In each Mendix app, read the version of the OIDC Provider module. An app that does not include the module is outside this flaw. The ranges are:

| Line | Affected | Fixed |
|---|---|---|
| Mendix 9 compatible | All versions before V4.3.0 | V4.3.0 or later |
| Mendix 10 compatible | All versions before V6.0.0 | V6.0.0 or later |
| Mendix 11 compatible | All versions before V6.0.0 | V6.0.0 or later |

A version you cannot read is unknown, not safe. Reading the module version changes no state.

## Remediation

1. Update the module and deploy the app again. Mendix 10 and Mendix 11 go to **V6.0.0 or later** ([Marketplace 244687](https://marketplace.mendix.com/link/component/244687)). Mendix 9 goes to **V4.3.0 or later** ([Marketplace 214677](https://marketplace.mendix.com/link/component/214677)).
2. V6.0.0 is a new major version on the Mendix 10 and 11 lines. Read the module release notes before the move.
3. Until the app is deployed, Siemens says a resource server should check the JWT signature itself and not rely only on this introspection endpoint.

## Verification

- Each deployed app shows the fixed module version for its line.
- Do not send a token to the introspection endpoint to test it.

## Compromise response

Siemens does not report exploitation. A session issued before the update should be treated as one the endpoint could have matched from its `jti` alone. The update does not end a session that was already taken. The advisory publishes no indicator.

## Sources

- [SSA-545865][adv] — published 2026-11-27, V1.0. CVSS 3.1 8.7 and CVSS 4.0 9.4. Fixed module versions listed above. No exploitation statement.
- [CVE-2026-124981][cve] — Siemens, published 2026-11-27. Same scores. CWE-347.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.27, checked 2026-11-27. CVE-2026-124981 is not listed.

[adv]: https://cert-portal.siemens.com/productcert/html/ssa-545865.html
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-124981
