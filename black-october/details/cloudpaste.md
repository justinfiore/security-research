# CloudPaste: a share link returns the WebDAV password

**Last updated:** 2026-11-16 (America/New_York)

[Main CloudPaste summary](../black-october-2026.md#cloudpaste-a-share-link-returns-the-webdav-password) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

CloudPaste is a self-hosted paste and file service. [CVE-2026-129494](https://www.cve.org/CVERecord?id=CVE-2026-129494) returns the WebDAV storage username and password to a request with no login. VulnCheck is the CNA and rates it **CVSS 4.0 8.7 High** and **CVSS 3.1 7.5 High**. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N`. The 4.0 vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`. NVD has not scored it.

The record says 1.1.0 through **1.9.1** are affected, and it names no unaffected version. Someone who knows a public share slug requests `/api/proxy/link` and receives the Basic Authorization header the server uses for its WebDAV storage. With that username and password they can read, change, or delete files on the WebDAV server. The newest GitHub release is **v1.9.1**, published 2026-01-03, which is inside the affected range. GitHub issue 223, opened 2026-11-15 by the finder, is still open. The project has not answered it. A bot comment on that issue says blocking `/api/proxy/link` from the public internet stops the request and also stops the official proxy script, which depends on the same path.

This is not [VoAPI](voapi.md) and not [Bolo](bolo.md). The same finder published all three on November 15.

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
| CloudPaste v1.9.1 | 2026-01-03 13:26:39 UTC | Newest GitHub release. Inside the affected range. [GitHub releases][rel] |
| Finder's report | 2026-11-15; time/TZ unknown | GitHub issue 223. Still open. The project has not answered. [GitHub][iss] |
| **Public announcement** | **2026-11-16; time/TZ unknown** | VulnCheck published the CVE record. NVD's published time is 2026-11-16 01:17 UTC. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. No fixed release. |

## Detection

Read the running version from the deployment, not from a banner on an exposed service. The GitHub release tag and the container image tag are the version. A deployment that is not CloudPaste is outside this entry. A deployment with no WebDAV storage configured has no WebDAV password to return; the record does not say the endpoint is absent in that case.

## Remediation

1. There is no fixed release. v1.9.1 is the newest, and it is affected.
2. Until a release lands, do not expose `/api/proxy/link` to the public internet. The official proxy script uses that path, so this stops the proxy as well.
3. Rotate the WebDAV username and password. Blocking the path does not take back a password that was already returned.
4. Taking the service offline is the alternative where the proxy has to keep working.

## Verification

- The deployed tag is newer than v1.9.1 once a fixed release exists. None does today.
- From outside the network, a request to `/api/proxy/link` for a real share slug does not return an Authorization header. Do not send a request built to extract it.

## Compromise response

No source publishes an indicator or a confirmed compromise. A returned password can read and change every file on that WebDAV account. Look for files added, edited, or deleted there that nobody placed. If you cannot rule that out, treat the stored files as exposed, rotate the WebDAV credential, and rotate any other credential that was stored in those files.

## Sources

- [CVE-2026-129494](https://www.cve.org/CVERecord?id=CVE-2026-129494) — VulnCheck, published 2026-11-16. CVSS 4.0 8.7 and CVSS 3.1 7.5. Affected 1.1.0 through 1.9.1. No unaffected version.
- [NVD, CVE-2026-129494](https://nvd.nist.gov/vuln/detail/CVE-2026-129494) — published 2026-11-16 01:17 UTC. NVD has not scored it.
- [GitHub issue 223][iss] — opened 2026-11-15 by Wu Yulun. Open, with no project response.
- [GitHub releases][rel] — v1.9.1 published 2026-01-03T13:26:39Z, the newest.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. CVE-2026-129494 is not in it.

[iss]: https://github.com/ling-drag0n/CloudPaste/issues/223
[rel]: https://github.com/ling-drag0n/CloudPaste/releases
