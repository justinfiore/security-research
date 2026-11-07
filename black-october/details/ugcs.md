# UgCS: an empty login is accepted when only one user exists

**Last updated:** 2026-11-06 (America/New_York)

[Main UgCS summary](../black-october-2026.md#ugcs-an-empty-login-is-accepted-when-only-one-user-exists) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-59104](https://www.cve.org/CVERecord?id=CVE-2026-59104) — ENISA (CNA) CVSS 3.1 9.8 Critical and CVSS 4.0 9.3 Critical.** The finder, OffSeq, publishes the same scores. NVD has not scored it. UgCS, the SPH Engineering drone ground-control server, before 6.2, accepts a login with empty credentials when the user database holds exactly one account. That is the default single-operator install. The HCI listener binds to every interface, without TLS, on TCP port 3334. The session can command connected drones and upload flight routes.

OffSeq says the fix shipped in UgCS 6.2 on 2026-10-09. The vendor's public site does not mention the CVE. The CVE record was published 2026-11-06.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-06). OffSeq does not report exploitation of a customer system. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private report | 2026-06-30; time/TZ unknown | OffSeq reported it to CERT.LV. [OffSeq][offseq] |
| Vendor coordination | 2026-07-06; time/TZ unknown | CERT.LV forwarded it. Confirmed and CVE reserved 2026-08-06. [OffSeq][offseq] |
| Patch available | 2026-10-09; time/TZ unknown | UgCS 6.2. The vendor told CERT.LV the fix was complete on 2026-10-08. [OffSeq][offseq] |
| **Public announcement** | **2026-11-06; time/TZ unknown** | ENISA published the CVE record. OffSeq's write-up is the same disclosure. [CNA][cve] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-06) | [KEV][kev] |

## Detection

On the host that runs the UgCS server. This only reads.

```sh
ss -lnt | awk '$4 ~ /:3334$/'
```

A listener on `0.0.0.0:3334` or `[::]:3334` is the default OffSeq describes. A listener on `127.0.0.1` only is the mitigation, not the fix. No listener means this port is not open; it does not prove the installed build.

The version is in the UgCS application's own about dialog. OffSeq names UgCS for Windows, macOS, and Linux before 6.2. A server with more than one user is outside the condition OffSeq describes. Do not send an empty login to test that.

## Remediation

1. **Update UgCS to 6.2 or later** on every server. OffSeq says 6.2 no longer accepts empty credentials.
2. Until that build is installed, bind the HCI listener to `127.0.0.1` and allow TCP 3334 only from the hosts that need it. That is a mitigation. It does not fix the login handler.
3. The update does not undo a flight route already uploaded or a command a session already sent.

## Verification

- The installed build is **6.2 or later**.
- Open a mission you already use and confirm it still loads. Do not send a login with the user and password fields omitted.

## Compromise response

OffSeq does not publish an indicator or a confirmed customer compromise. If port 3334 was reachable while the build was below 6.2 and the server had one user, treat a command to a connected drone as possible.

- Preserve the UgCS logs and a copy of the mission store before cleanup.
- Review flight routes and operator accounts you did not create.
- If a route changed and you cannot account for it, treat the aircraft and the ground station as needing a vendor-guided check. The upgrade does not revert a route.

## Sources

- [CVE-2026-59104][cve] — ENISA CNA, published 2026-11-06. CVSS 3.1 9.8 and CVSS 4.0 9.3. Before 6.2.
- [OffSeq][offseq] — the disclosure write-up. Port 3334, the single-user condition, the 2026-10-09 release, and no customer compromise claimed.
- [UgCS][vendor] — the vendor's product page. It does not mention the CVE.
- [CISA KEV][kev] — catalog 2026.11.06. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-59104
[offseq]: https://offseq.com/en/research/ugcs-cve-2026-59104/
[vendor]: https://www.ugcs.com/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
