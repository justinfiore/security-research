# OpenEMR: a one-time portal link stays valid, and a logged-in user can write a file

**Last updated:** 2026-11-08 (America/New_York)

[Main OpenEMR summary](../black-october-2026.md#openemr-a-one-time-portal-link-stays-valid-and-a-logged-in-user-can-write-a-file) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

OpenEMR is an electronic health record. The project rates four flaws Critical. Three are fixed in 8.3.0, published August 18. One is fixed in 8.4.0, published September 13. VulnCheck assigned the CVE records on November 8. 8.3.0 is not enough for all four.

**The project rates [GHSA-xg3m-9pfq-c8r6](https://github.com/openemr/openemr/security/advisories/GHSA-xg3m-9pfq-c8r6) Critical.** VulnCheck assigned [CVE-2026-124445](https://www.cve.org/CVERecord?id=CVE-2026-124445) and scores it CVSS 4.0 9.3 and CVSS 3.1 9.8. The GitHub page does not print a numeric score. Versions before 8.4.0 store `enforce_onetime_use` and `max_access_count` on a patient-portal token and never read them. A captured `service_auth` token can be replayed for its whole lifetime, which the project says is up to 14 days for an invoice. The PIN check on the fax and SMS invoice flow has no rate limit, so a 6-digit PIN can be guessed inside that window. Each replay opens a patient-portal session. The project says that session can read the patient's record. The floor the project names is everything before 8.4.0. The CVE record says 7.0.1 before 8.4.0.

Three more are fixed in 8.3.0, and the project rates each Critical:

- [CVE-2026-124450](https://www.cve.org/CVERecord?id=CVE-2026-124450) is [GHSA-wf4w-mx2w-j4vv](https://github.com/openemr/openemr/security/advisories/GHSA-wf4w-mx2w-j4vv), published 2026-08-18. The project scores it CVSS 4.0 9.3. VulnCheck scores it CVSS 4.0 9.3 and CVSS 3.1 9.9. Before 8.3.0, the fax and SMS `disposeDocument` action takes a `file_path` and does not check it. A logged-in user with the `patients/demo` permission, which the project says most clinical and clerical roles have, can read `sites/default/sqlconf.php` and can write a file as the web user. The project says it confirmed both. The CVE record says before 8.3.0 with no floor. The advisory says the flaw arrived with the 8.2.0 fax and SMS refactor.
- [CVE-2026-124490](https://www.cve.org/CVERecord?id=CVE-2026-124490) is [GHSA-38jw-pwgq-9hpj](https://github.com/openemr/openemr/security/advisories/GHSA-38jw-pwgq-9hpj). VulnCheck scores it CVSS 4.0 9.4 and CVSS 3.1 9.1. It is the RingCentral client of the same module: `action=download` reads a file, and `action=setup` writes one. The vector sets Privileges Required to High. The other disposeDocument advisory sets it to Low. Both are before 8.3.0.
- [CVE-2026-124469](https://www.cve.org/CVERecord?id=CVE-2026-124469) is [GHSA-cg8c-2v5q-29g7](https://github.com/openemr/openemr/security/advisories/GHSA-cg8c-2v5q-29g7), published 2026-08-18. The project scores it CVSS 3.1 9.9, and also prints a read-only score of 7.7. VulnCheck scores it CVSS 4.0 9.4 and CVSS 3.1 9.9. Before 8.3.0, the Fee Sheet inventory lookup puts `prod[N][warehouse]` into an `ORDER BY`. A logged-in user can use that as a blind SQL oracle. The project says the comparable earlier flaw was rated 9.9 by OpenEMR as CNA.

8.4.0 is the current floor that covers all four. 8.3.0 fixes the file and SQL flaws and not the token replay.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08). The advisories do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| OpenEMR 8.3.0 | 2026-08-18; time/TZ unknown | Fixes the file read and write and the Fee Sheet SQL injection. [File advisory][file] |
| **Public announcement** | **2026-08-18; time/TZ unknown** | The project published those two Critical advisories. |
| OpenEMR 8.4.0 | 2026-09-13; time/TZ unknown | Fixes the one-time token replay and the PIN guess. [Token advisory][token] |
| CVE records | 2026-11-08 13:15 UTC | VulnCheck published CVE-2026-124445, CVE-2026-124450, CVE-2026-124469, and CVE-2026-124490. [CVE-2026-124445][cve445] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-08) | [KEV][kev] |

## Detection

This reads the version you are running. It does not replay a token or request a file.

The version is in `version.php` at the top of the install, the `v_database` value, and on the Administration, About page. A container tag is not the running version until the container was recreated from it.

- **8.4.0 or later** has the fix for all four.
- **8.3.0** has the file and SQL fixes and not the token replay.
- **Before 8.3.0** is inside all four, on the ranges the advisories name. The token record's floor is 7.0.1. The file advisory says that flaw arrived in 8.2.0. A version older than 8.2.0 is outside that one advisory and is not outside the token flaw.

A portal that is not enabled is outside the token replay only while it stays off. The Fee Sheet and the fax module are separate.

## Remediation

1. Upgrade to **8.4.0 or later**. Follow the project's upgrade path for the version you are on, and back up the database and `sites/` first. 8.3.0 leaves the token flaw in place.
2. The advisories list no workaround. Turning the patient portal off removes the token path and does not remove the Fee Sheet or the fax module. Turning the fax module off removes the file path and does not remove the other two.
3. The upgrade does not expire a token that was already issued, and it does not delete a file that was already written. Revoke outstanding portal tokens after the upgrade, and rotate the database password in `sites/default/sqlconf.php` if a version before 8.3.0 was reachable by a logged-in user.

## Verification

- The running `version.php` reports 8.4.0 or later, after the process or container was restarted.
- A patient who already uses the portal can still open it with a fresh link. Do not replay an old `service_auth` value to test the check.

## Compromise response

The project does not publish a log line. A `service_auth` query parameter used more than once, or a `login_pin` tried many times, is the token indicator. A request to the fax module's `disposeDocument` action with a `file_path` outside its directory is the file indicator. Neither log is guaranteed to exist.

If the portal was reachable before 8.4.0, or any user could log in before 8.3.0:

- Revoke one-time portal tokens and end portal sessions.
- Rotate the database password and any credential that was in `sqlconf.php`.
- Look for PHP files written under the web root that the project did not ship, and for Fee Sheet requests whose warehouse value is not a warehouse id.

## Sources

- [GHSA-xg3m-9pfq-c8r6][token] — the project, published 2026-09-13. Critical. Before 8.4.0, patched in 8.4.0. Token replay and PIN guessing.
- [CVE-2026-124445][cve445] — VulnCheck, published 2026-11-08 13:15 UTC. CVSS 4.0 9.3 and CVSS 3.1 9.8. Says 7.0.1 before 8.4.0.
- [GHSA-wf4w-mx2w-j4vv][file] — the project, published 2026-08-18. Critical, CVSS 4.0 9.3. Before 8.3.0. File read and write. The project says it confirmed both.
- [CVE-2026-124450][cve450] — VulnCheck, published 2026-11-08. CVSS 4.0 9.3 and CVSS 3.1 9.9.
- [GHSA-38jw-pwgq-9hpj][fax] — the RingCentral client of the same module. Before 8.3.0.
- [CVE-2026-124490][cve490] — VulnCheck, published 2026-11-08. CVSS 4.0 9.4 and CVSS 3.1 9.1. Privileges Required is High on this record.
- [GHSA-cg8c-2v5q-29g7][sql] — the project, published 2026-08-18. Critical. The project scores CVSS 3.1 9.9 and also prints 7.7 for a read-only reading. Before 8.3.0.
- [CVE-2026-124469][cve469] — VulnCheck, published 2026-11-08. CVSS 4.0 9.4 and CVSS 3.1 9.9.
- [CISA KEV JSON][kev] — catalog 2026.11.06, checked 2026-11-08. None of these CVEs is listed.

[token]: https://github.com/openemr/openemr/security/advisories/GHSA-xg3m-9pfq-c8r6
[file]: https://github.com/openemr/openemr/security/advisories/GHSA-wf4w-mx2w-j4vv
[fax]: https://github.com/openemr/openemr/security/advisories/GHSA-38jw-pwgq-9hpj
[sql]: https://github.com/openemr/openemr/security/advisories/GHSA-cg8c-2v5q-29g7
[cve445]: https://www.cve.org/CVERecord?id=CVE-2026-124445
[cve450]: https://www.cve.org/CVERecord?id=CVE-2026-124450
[cve490]: https://www.cve.org/CVERecord?id=CVE-2026-124490
[cve469]: https://www.cve.org/CVERecord?id=CVE-2026-124469
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
