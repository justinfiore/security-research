# Apache OFBiz: an unauthenticated request runs code, and a captured login key is a session

**Last updated:** 2026-11-08 (America/New_York)

[Main OFBiz summary](../black-october-2026.md#apache-ofbiz-an-unauthenticated-request-runs-code-and-a-captured-login-key-is-a-session) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Apache OFBiz is an ERP. On November 4 the project said every version before 24.09.08 is affected and told users to upgrade to 24.09.08. The announcement names 46 CVEs. Apache did not score them. CISA-ADP scored ten, and two of those are Critical.

**CISA-ADP scores [CVE-2026-83542](https://www.cve.org/CVERecord?id=CVE-2026-83542) CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. NVD has not scored it, and the Apache record has no score. Before 24.09.08, an unauthenticated request stages widget XML in an upload and points a manager login page at it. OFBiz evaluates a Groovy expression while rendering the failure page. The record says the same path is reachable through `/sfa/control/editPortalPageColumnWidth`, which is public, and that route returns the command output in the response. The upload does not have to be malformed.

**CISA-ADP scores [CVE-2026-82907](https://www.cve.org/CVERecord?id=CVE-2026-82907) CVSS 3.1 9.8 Critical,** the same vector shape. Before 24.09.08, a captured `externalLoginKey` is a bearer credential. It is not bound to a client, it does not expire, and it is not invalidated after use. The check runs before authentication. The framework appends a live key to cross-application links it renders. Anyone who captures one gets a session as that user, in every application that user can reach, with no cookie.

CISA-ADP scores eight more in the same release High. Apache did not score these either. All are before 24.09.08:

- [CVE-2026-82910](https://www.cve.org/CVERecord?id=CVE-2026-82910), [CVE-2026-82912](https://www.cve.org/CVERecord?id=CVE-2026-82912), [CVE-2026-82960](https://www.cve.org/CVERecord?id=CVE-2026-82960), [CVE-2026-84183](https://www.cve.org/CVERecord?id=CVE-2026-84183), and [CVE-2026-85627](https://www.cve.org/CVERecord?id=CVE-2026-85627) are 8.8. Each lets a logged-in user with a view permission run a command as the OFBiz process user, through FreeMarker, Groovy, or a content layout.
- [CVE-2026-71901](https://www.cve.org/CVERecord?id=CVE-2026-71901) is 8.1. A user of the SFA component can name a different service for a vCard import.
- [CVE-2026-82904](https://www.cve.org/CVERecord?id=CVE-2026-82904) is 7.5. One unauthenticated request can pin a thread for an attacker-chosen number of service calls.
- [CVE-2026-82916](https://www.cve.org/CVERecord?id=CVE-2026-82916) is 7.1. A user with webtools view permission can export any entity, including password hashes, to a path the process can write.

The announcement also names flaws CISA-ADP has not scored, and Apache has not scored. Two of those are unauthenticated on the text of the record. [CVE-2026-92887](https://www.cve.org/CVERecord?id=CVE-2026-92887) skips REST authentication when a definition omits the `auth` attribute. [CVE-2026-73578](https://www.cve.org/CVERecord?id=CVE-2026-73578) renders a saved view without re-checking that the view required a login. [CVE-2026-105330](https://www.cve.org/CVERecord?id=CVE-2026-105330) is narrower: 24.09.06 and 24.09.07 only, and only where an upgrade kept an old `security.properties` with `security.internal.sso.enabled` true. A forged JWT signed with the factory-default key is an administrator. The record says upgrading does not replace a key that is already configured.

24.09.08 is the one release the announcement names. The records say it fixes these.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08). The announcement does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-04 16:13 UTC** | The project posted the CVE list and named 24.09.08. [Announcement][ann] |
| CVE records | 2026-11-05; time/TZ unknown | Apache published the records. CISA-ADP scored ten of them. [CVE-2026-83542][cve83542] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-08) | [KEV][kev] |

## Detection

This reads the version you are running. It does not send a login request or an upload.

The version is the OFBiz release directory, the `build.gradle` version, or the container image tag. A tag that was not redeployed is not the running version.

- **24.09.08 or later** is the release the announcement names.
- **Before 24.09.08** is inside the two Critical flaws and the eight High flaws CISA-ADP scored.
- **24.09.06 and 24.09.07** are also inside the default JWT key, and only when the old properties file is still in use with internal SSO on.

An instance that is not reachable from a network you do not trust is still inside the flaws for anyone who can reach it.

## Remediation

1. Upgrade to **24.09.08 or later** and restart OFBiz. The announcement says every version before 24.09.08 is affected. There is no branch-specific backport in the announcement.
2. The announcement lists no workaround. Taking the service off the internet reduces who can send the unauthenticated requests and does not fix a captured login key already in a link, or a logged-in user who already has a view permission.
3. On 24.09.06 or 24.09.07 that kept `framework/security/config/security.properties` from an older install, replace `security.token.key` after the upgrade. The record says the upgrade does not do that. Turn `security.internal.sso.enabled` off unless you use it.
4. The upgrade does not show whether a request already ran, and it does not expire a captured `externalLoginKey`. End sessions after the upgrade.

## Verification

- The running process is 24.09.08 or later, after the restart.
- A user can still log in. Do not replay an `externalLoginKey`, and do not upload widget XML, to test the check.

## Compromise response

The records do not publish a log line. A request to `/sfa/control/editPortalPageColumnWidth` from an address that should not use SFA, or an `externalLoginKey` query parameter used from a new address, is the indicator. Neither log is guaranteed to exist.

If the service was reachable before 24.09.08:

- End sessions and rotate passwords, including the administrator.
- Rotate the database password and any credential that was in a properties file. The webtools export can write `UserLogin` hashes to a path the process can write.
- Look for a new file under the web root and for a process the OFBiz account should not have started.

## Sources

- [Apache announcement][ann] — Jacopo Cappellato, 2026-11-04 16:13 UTC. All versions before 24.09.08. Upgrade to 24.09.08. Names 46 CVEs and does not score them.
- [CVE-2026-83542][cve83542] — Apache, published 2026-11-05. No vendor score. CISA-ADP CVSS 3.1 9.8. Unauthenticated code execution. NVD has not scored it.
- [CVE-2026-82907][cve82907] — Apache, published 2026-11-05. No vendor score. CISA-ADP CVSS 3.1 9.8. Captured `externalLoginKey`.
- [CVE-2026-82910][cve82910], [CVE-2026-82912][cve82912], [CVE-2026-82960][cve82960], [CVE-2026-84183][cve84183], [CVE-2026-85627][cve85627] — CISA-ADP CVSS 3.1 8.8. View-permission command execution.
- [CVE-2026-71901][cve71901] — CISA-ADP CVSS 3.1 8.1.
- [CVE-2026-82904][cve82904] — CISA-ADP CVSS 3.1 7.5. Unauthenticated thread pin.
- [CVE-2026-82916][cve82916] — CISA-ADP CVSS 3.1 7.1. Entity export, including password hashes.
- [CVE-2026-105330][cve105330] — Apache, no score. 24.09.06 and 24.09.07 only. Factory-default JWT key. The upgrade does not replace a key already configured.
- [CVE-2026-92887][cve92887] and [CVE-2026-73578][cve73578] — Apache, no score from Apache or CISA-ADP. Unauthenticated on the text of the record.
- [CISA KEV JSON][kev] — catalog 2026.11.06, checked 2026-11-08. None of these CVEs is listed.

[ann]: https://lists.apache.org/thread/7b2syzksp7klt9fvhdg0olldvs2g83lz
[cve83542]: https://www.cve.org/CVERecord?id=CVE-2026-83542
[cve82907]: https://www.cve.org/CVERecord?id=CVE-2026-82907
[cve82910]: https://www.cve.org/CVERecord?id=CVE-2026-82910
[cve82912]: https://www.cve.org/CVERecord?id=CVE-2026-82912
[cve82960]: https://www.cve.org/CVERecord?id=CVE-2026-82960
[cve84183]: https://www.cve.org/CVERecord?id=CVE-2026-84183
[cve85627]: https://www.cve.org/CVERecord?id=CVE-2026-85627
[cve71901]: https://www.cve.org/CVERecord?id=CVE-2026-71901
[cve82904]: https://www.cve.org/CVERecord?id=CVE-2026-82904
[cve82916]: https://www.cve.org/CVERecord?id=CVE-2026-82916
[cve105330]: https://www.cve.org/CVERecord?id=CVE-2026-105330
[cve92887]: https://www.cve.org/CVERecord?id=CVE-2026-92887
[cve73578]: https://www.cve.org/CVERecord?id=CVE-2026-73578
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
