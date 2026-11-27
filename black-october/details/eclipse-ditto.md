# Eclipse Ditto: a query parameter picks the user

**Last updated:** 2026-11-27 (America/New_York)

[Main Ditto summary](../black-october-2026.md#eclipse-ditto-a-query-parameter-picks-the-user) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-19 the Eclipse Ditto project published [GHSA-chwq-wg27-qvfr][ghsa] for [CVE-2026-120753](https://www.cve.org/CVERecord?id=CVE-2026-120753). The project rates it **Critical, CVSS 4.0 9.1**. Eclipse is the CNA.

When pre-authentication is on, the gateway reads the subject from the `x-ditto-pre-authenticated` header, which a trusted proxy is supposed to set, and also from a query parameter of the same name. A proxy that overwrites the header does not stop the parameter. The default Helm chart sets `global.jwtOnly` to false, which turns pre-authentication on, and its nginx skips HTTP Basic authentication for any request that carries an `Authorization: Bearer` header. A request with no login can send an invalid Bearer token and `?x-ditto-pre-authenticated=<subject>` and is treated as that subject. The token is not checked. That subject can then read and change the Things and Policies it is allowed to see.

Affected ranges are **1.1.0 before 3.8.15**, and **3.9.0 before 3.9.9**. The fixes are **3.8.15** and **3.9.9**. The project does not report exploitation.

**Those two builds are not enough.** On 2026-11-25 Eclipse published [GHSA-f779-cv8j-4p59](https://github.com/eclipse-ditto/ditto/security/advisories/GHSA-f779-cv8j-4p59) for [CVE-2026-135150](https://www.cve.org/CVERecord?id=CVE-2026-135150), a bypass of the November 19 fix. The project rates it **Critical, CVSS 4.0 9.1**, vector `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N`. The nginx configurations and the Ingress shipped with Ditto forwarded a client-supplied `x-ditto-pre-authenticated` header, so the same impersonation works without the query parameter. The record says **1.1.0 through 3.9.9**. The fixes are **3.8.16** and **3.9.10**, both published 2026-11-25: nginx clears the header, the gateway rejects dot-segment paths, and Helm chart 4.10.0 refuses to render an Ingress with pre-authentication unless `ingress.preAuthenticationHeaderSanitized: true`. The advisory page still says the fix is in preparation. The release notes, published the same minute, are the newer statement. The same releases also fix a JavaScript mapper sandbox escape, CVE-2026-135203. The project does not report exploitation of either.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-27) for CVE-2026-120753 or CVE-2026-135150. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fixes** | **2026-11-19; time/TZ unknown** | GHSA-chwq-wg27-qvfr. Fixed in 3.8.15 and 3.9.9. [Advisory][ghsa] |
| **Bypass and fixes** | **2026-11-25; time/TZ unknown** | CVE-2026-135150. A client-supplied header bypasses 3.8.15 and 3.9.9. Fixed in 3.8.16 and 3.9.10. [3.9.10][rel] |
| **Last updated** | **2026-11-27 (America/New_York)** | The November 19 floors leave the bypass in place. |

## Detection

Read the gateway image, not the chart alone. A gateway on 1.1.0 through 3.8.14, or on 3.9.0 through 3.9.8, is inside the flaw when pre-authentication is enabled. The default Helm chart enables it. A deployment that sets `global.jwtOnly` to true is outside the path the advisory describes for the bundled nginx. Confirm that from the running values, not from a default.

## Remediation

1. Upgrade the gateway to **3.8.16 or 3.9.10** or later and roll the pods. 3.8.15 and 3.9.9 fix the query parameter and leave the header bypass in place.
2. Until the upgrade, do not rely on the proxy overwriting the header. The query parameter bypasses that.
3. The upgrade does not show whether a request already acted as another subject.

## Verification

- The running gateway image is 3.8.16, 3.9.10, or later.
- A Thing that should be readable still is. Do not send a Bearer token with the query parameter.

## Compromise response

The project does not report exploitation. A gateway that was exposed with pre-authentication on should be reviewed for a Thing or a Policy change the owner did not make. The upgrade does not undo one.

## Sources

- [GHSA-chwq-wg27-qvfr][ghsa] — Eclipse Ditto, published 2026-11-19. Critical, CVSS 4.0 9.1. Fixed in 3.8.15 and 3.9.9.
- [CVE-2026-120753](https://www.cve.org/CVERecord?id=CVE-2026-120753) — the CVE record.
- [GHSA-f779-cv8j-4p59](https://github.com/eclipse-ditto/ditto/security/advisories/GHSA-f779-cv8j-4p59) — published 2026-11-25. Critical, CVSS 4.0 9.1. The page still says the fix is in preparation.
- [Ditto 3.9.10 release notes][rel] — published 2026-11-25. CVE-2026-135150 fixed in 3.9.10, and 3.8.16 for the 3.8 line.
- [CVE-2026-135150](https://www.cve.org/CVERecord?id=CVE-2026-135150) — Eclipse, published 2026-11-25. Affected 1.1.0 through 3.9.9.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-27. Neither CVE is listed.

[rel]: https://github.com/eclipse-ditto/ditto/releases/tag/3.9.10

[ghsa]: https://github.com/eclipse-ditto/ditto/security/advisories/GHSA-chwq-wg27-qvfr
