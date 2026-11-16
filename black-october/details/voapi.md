# VoAPI: a logged-in user forges the administrator token

**Last updated:** 2026-11-16 (America/New_York)

[Main VoAPI summary](../black-october-2026.md#voapi-a-logged-in-user-forges-the-administrator-token) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

VoAPI is a self-hosted API gateway. [CVE-2026-129540](https://www.cve.org/CVERecord?id=CVE-2026-129540) is a SQL injection in the search filter. VulnCheck is the CNA and rates it **CVSS 4.0 8.7 High** and **CVSS 3.1 8.8 High**. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. The record is tagged `unsupported-when-assigned`. NVD has not scored it.

The record says 1.0.0 through **1.2.0** are affected, and it names no unaffected version. A logged-in user sends a column name as a search filter key on a list endpoint such as `GET /api/log`. The injection reads the HS256 JWT signing secret from the option table. With that secret the user forges a manager token and takes over the `/api/m/` management API. The newest GitHub release is **v1.2.0**, published 2026-01-20, which is the top of the affected range. GitHub issue 78, opened 2026-11-15 by the finder, was closed the same day by a project member, Licoy, who wrote that the public community edition has not been maintained for a long time and that nobody uses it. The issue names no fix and no commit.

This is not [CloudPaste](cloudpaste.md) and not [Bolo](bolo.md). The same finder published all three on November 15.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-16). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| VoAPI v1.2.0 | 2026-01-20 01:59:44 UTC | Newest GitHub release. The top of the affected range. [GitHub releases][rel] |
| Finder's report | 2026-11-15; time/TZ unknown | GitHub issue 78. Closed the same day with no fix. [GitHub][iss] |
| **Public announcement** | **2026-11-16; time/TZ unknown** | VulnCheck published the CVE record. NVD's published time is 2026-11-16 02:17 UTC. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. No fixed release. |

## Detection

Read the version from the deployment's release tag or image tag. A service that is not VoAPI is outside this entry. The flaw needs an account. An instance with no accounts is not the configuration the record describes, and the record does not say the endpoint is absent there.

## Remediation

1. There is no fixed release. v1.2.0 is the newest, the project says the public edition is unmaintained, and the record is tagged unsupported-when-assigned.
2. Take a public instance offline, or stop accepting new accounts and restrict it to a network you control.
3. Rotate the JWT signing secret after you move off it. A secret that was already read keeps working until you do.

## Verification

- The instance is not reachable from the public internet, or it runs a release newer than v1.2.0 once one exists. None does today.
- Do not send the filter key the advisory describes.

## Compromise response

No source publishes an indicator or a confirmed compromise. A forged manager token can do what the management API allows. Look for management actions nobody made, and for tokens issued after the secret could have been read. If you cannot rule that out, rotate the signing secret, which signs out every token, and review the accounts.

## Sources

- [CVE-2026-129540](https://www.cve.org/CVERecord?id=CVE-2026-129540) — VulnCheck, published 2026-11-16. CVSS 4.0 8.7 and CVSS 3.1 8.8. Affected 1.0.0 through 1.2.0. Tagged unsupported-when-assigned. No unaffected version.
- [NVD, CVE-2026-129540](https://nvd.nist.gov/vuln/detail/CVE-2026-129540) — published 2026-11-16 02:17 UTC. NVD has not scored it.
- [GitHub issue 78][iss] — opened 2026-11-15 by Wu Yulun. Closed the same day by Licoy: the public community edition is unmaintained. No fix named.
- [GitHub releases][rel] — v1.2.0 published 2026-01-20T01:59:44Z, the newest.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. CVE-2026-129540 is not in it.

[iss]: https://github.com/VoAPI/VoAPI/issues/78
[rel]: https://github.com/VoAPI/VoAPI/releases
