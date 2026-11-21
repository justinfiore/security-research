# Cloud Commander: a rename request moves any file before login

**Last updated:** 2026-11-20 (America/New_York)

[Main Cloud Commander summary](../black-october-2026.md#cloud-commander-a-rename-request-moves-any-file-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Cloud Commander (the npm package `cloudcmd`, by coderaiser) is a web file manager. [CVE-2026-130072](https://www.cve.org/CVERecord?id=CVE-2026-130072) lets a request with no login move any file the Node.js process can reach. VulnCheck is the CNA and rates it **CVSS 4.0 8.8 High** and **CVSS 3.1 9.1 Critical**. The 4.0 vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:H/VA:H/SC:N/SI:N/SA:N`. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:H`. NVD has not scored it. The 4.0 score does not count confidentiality, because the request moves a file rather than reading it.

Versions before **19.21.4** are affected. `PUT /rename` is handled by the `nomine` middleware, which the server mounts before authentication, so `--auth` never sees the request. The handler then renames whatever paths the body names, including absolute paths and `../`, so `--root` does not contain it. The finder, George Chen, demonstrated it on 2026-10-23 against v19.21.2: a request with no credentials moved a file out of the configured root. The maintainer shipped the fix in [v19.21.4](https://github.com/coderaiser/cloudcmd/releases/tag/v19.21.4) on 2026-10-25 and closed the issue on 2026-11-13. The CVE record was published on 2026-11-16. npm's latest `cloudcmd` on 2026-11-20 is still 19.23.2, which is past the fix.

A second report, [issue 488](https://github.com/coderaiser/cloudcmd/issues/488), is not this CVE and has no score. On 19.23.2 the socket listeners compare the typed password with the stored hash instead of hashing it first, and a client that already has that hash can name its own terminal command. The reporter says an unauthenticated request cannot read the hash. The maintainer closed it on 2026-11-19 in commit `939d423`, which is on `master` and in no release. 19.23.2 is still the newest npm version.

This is not [CloudPaste](cloudpaste.md).

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-20). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Finder's report | 2026-10-23; time/TZ unknown | GitHub issue 486, against v19.21.2. [Issue 486][iss] |
| Fix released | 2026-10-25 12:12:08 UTC | v19.21.4. Commit `25f496ff`. [Release][rel] |
| Issue closed | 2026-11-13; time/TZ unknown | Maintainer closed it for inactivity after the fix. |
| **Public announcement** | **2026-11-16; time/TZ unknown** | VulnCheck published the CVE record. |
| Socket report | 2026-11-19; time/TZ unknown | Issue 488, against 19.23.2. Not this CVE. No score. Closed the same day in commit `939d423`, which is not in a release. [Issue 488][i488] |

## Detection

Read the installed `cloudcmd` version from the deployment's package metadata or the container image tag, not from a page the service returns. Anything before 19.21.4 is inside the range. A deployment that does not run Cloud Commander is outside this entry. Turning on `--auth` does not take a version before 19.21.4 out of the range: the rename handler runs before authentication.

## Remediation

1. Upgrade `cloudcmd` to **19.21.4 or later** and restart the process. That closes CVE-2026-130072. npm's latest on 2026-11-20 is 19.23.2.
2. 19.23.2 does not contain the socket fix from issue 488. Until a release contains commit `939d423`, treat the stored hash as a second credential. Change the account password if a browser or a log has held that hash.
3. The upgrade does not put a moved file back. Look for files that disappeared from the configured root, or appeared outside it, that nobody moved.

## Verification

- The running process is 19.21.4 or later. A package on disk that the process has not restarted into is not the fix.
- Do not send a `PUT /rename` built to move a file. The version check is the verification.

## Compromise response

No source publishes an indicator or a confirmed compromise. A request that succeeded can move any file the process could rename, including ones the service depends on. If a file is missing or has moved and nobody placed it, treat that path as changed, restore it from a copy you trust, and rotate any credential that lived in a file the process could reach.

## Sources

- [CVE-2026-130072](https://www.cve.org/CVERecord?id=CVE-2026-130072) — VulnCheck, published 2026-11-16. CVSS 4.0 8.8 and CVSS 3.1 9.1. Affected before 19.21.4.
- [VulnCheck advisory](https://www.vulncheck.com/advisories/cloud-commander-before-19.21.4-authentication-bypass-and-path-traversal-via-put-rename) — same facts, dated 2026-11-16.
- [GitHub issue 486][iss] — opened 2026-10-23 by George Chen. Closed 2026-11-13.
- [v19.21.4][rel] — published 2026-10-25 12:12:08 UTC. Commit `25f496ff`.
- [GitHub issue 488][i488] — opened and closed 2026-11-19. Socket auth accepts the stored password hash. Fixed in commit `939d423`, not in a release. No CVE.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-20. This CVE is not in it.

[iss]: https://github.com/coderaiser/cloudcmd/issues/486
[i488]: https://github.com/coderaiser/cloudcmd/issues/488
[rel]: https://github.com/coderaiser/cloudcmd/releases/tag/v19.21.4
