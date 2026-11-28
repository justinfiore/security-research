# MONEO: a public ping forges a session

**Last updated:** 2026-11-28 (America/New_York)

[Main guide](../black-october-2026.md#moneo-a-public-ping-forges-a-session)

**ENISA's record for [CVE-2026-59103](https://www.cve.org/CVERecord?id=CVE-2026-59103) scores it CVSS 4.0 9.3 Critical.** NVD also shows CVSS 3.1 9.8 from the same record and has not scored it itself. OffSeq, the finder, prints both: `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N` and `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. The record was published 2026-11-27. NVD's affected range is through **1.8.45.6**. OffSeq confirmed the flaw on that version and says MONEO Latvia fixed it in the release of **2026-08-03**. That write-up does not name the fixed build number.

The server exposes `Ping` on its WebSocket JSON-RPC interface with no session. The method's only check compares an application name, and the client supplies that name. Setting it to `_login` makes `Ping` store a session identifier, user number, and company that the caller chose. The next call with that identifier is that user, in that company, including an administrator, on any tenant the server hosts. OffSeq retested the August 3 release on August 6 and says `Ping` then only returns true. No source read for this entry reports exploitation. This is not [UgCS](ugcs.md).

**CISA KEV:** Not listed (catalog 2026.11.27, checked 2026-11-28). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to CERT.LV | 2026-06-30; time/TZ unknown | OffSeq, through Latvia's disclosure platform. |
| Forwarded to the vendor | 2026-07-06; time/TZ unknown | CERT.LV. |
| Vendor reports the session fix | 2026-07-30; time/TZ unknown | OffSeq's timeline. |
| **Patch** | **2026-08-03; time/TZ unknown** | MONEO Latvia's release. OffSeq retested it 2026-08-06. No build number is printed. |
| CVE reserved | 2026-08-06; time/TZ unknown | CVE-2026-59103. |
| OffSeq write-up | 2026-11-25; time/TZ unknown | Both scores. Confirmed on 1.8.45.6. |
| **Public announcement** | **2026-11-27; time/TZ unknown** | NVD published the ENISA record. |
| **Last updated** | **2026-11-28 (America/New_York)** | New item. |

## Detection

On each MONEO server, read the server build, not the desktop client version. A site that does not run MONEO ERP is outside this flaw. NVD says through 1.8.45.6 is affected. OffSeq confirmed that version and says the August 3, 2026 release removes the session write. A build number for that release is not in the sources read for this entry, so a version string alone does not prove the fix. Ask MONEO Latvia which build is the August 3 release, then compare the running server to that answer. A build you cannot read is unknown, not safe.

The interface is a WebSocket. OffSeq says the frame starts with the four bytes `json`. A log you cannot read is unknown, not clear.

## Remediation

1. Update the MONEO ERP server to the **2026-08-03 release or later**. OffSeq says server-hosted deployments were updated by the vendor. An on-premise server has to be updated by the operator. Confirm the build with MONEO Latvia, because the write-up names a date and not a version.
2. The update does not invalidate a session an attacker already created, and it does not undo a change that session made.

## Verification

- The running server build is the one MONEO Latvia identifies as the August 3, 2026 release, or a later build.
- Do not send a `Ping` request to test the flaw.

## Compromise response

No source read for this entry reports exploitation. On a server that was reachable before the August 3 release, review administrator and user actions the owner did not take, in every company that server hosts. One forged session can name any tenant on that server. Updating the server does not reverse a record that was changed.

## Sources

- [OffSeq, unauthenticated session forging in the MONEO ERP server](https://offseq.com/en/research/moneo-cve-2026-59103/) — November 25, 2026. CVSS 4.0 9.3 and CVSS 3.1 9.8. Confirmed on 1.8.45.6. Fixed in the release of 2026-08-03. Retested 2026-08-06. Credit Nils Putniņš. Coordinated by CERT.LV.
- [NVD, CVE-2026-59103](https://nvd.nist.gov/vuln/detail/CVE-2026-59103) — published November 27, 2026. CNA ENISA. CVSS 4.0 9.3, vector `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. Also shows CVSS 3.1 9.8. Affected through 1.8.45.6. NVD has not scored it itself.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.27, checked 2026-11-28. CVE-2026-59103 is not listed.
