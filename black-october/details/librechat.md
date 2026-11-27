# LibreChat: a login request stops the server

**Last updated:** 2026-11-26 (America/New_York)

[Main guide](../black-october-2026.md#librechat-a-login-request-stops-the-server)

**GitHub rates [GHSA-572g-g8hc-w8c9](https://github.com/LibreChat-AI/LibreChat/security/advisories/GHSA-572g-g8hc-w8c9) High, CVSS 3.1 7.5.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H`. VulnCheck's [CVE-2026-137586](https://www.cve.org/CVERecord?id=CVE-2026-137586) scores the same issue CVSS 3.1 7.5 and CVSS 4.0 8.7 (`CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:H/SC:N/SI:N/SA:N`). The GitHub weakness is CWE-248. The CVE record says CWE-1287. With LDAP login enabled, `POST /api/auth/login` passes the JSON `password` to the LDAP bind without checking its type. A non-zero number or `true`, sent with an email that exists in the directory, makes ldapjs throw inside a socket callback. LibreChat's `uncaughtException` handler then calls `process.exit(1)`. One request with no login stops the process, and the same request stops it again after each restart. Local login is not affected. LDAP is off unless `LDAP_URL` and `LDAP_USER_SEARCH_BASE` are set. The advisory says it reproduced this on **v0.8.8** and **v0.7.9**, and that versions between them were not tested. The patched release is **v0.8.9**, published November 17, 2026. The CVE record says **0.7.3 before 0.8.9**. The GitHub page's affected range is `>= 0.7.9, <= 0.8.8`. The page's CVE field says "No known CVE." No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix and advisory | 2026-11-17; time/TZ unknown | GHSA-572g-g8hc-w8c9, High, CVSS 3.1 7.5. Patched in v0.8.9. The page says no CVE is known. [GHSA][ghsa] |
| Release | 2026-11-17 14:25:11 UTC | v0.8.9. The note names the LDAP credential check as pull 18235. [Release][rel] |
| **Public CVE record** | **2026-11-26; time/TZ unknown** | VulnCheck published CVE-2026-137586. CVSS 4.0 8.7 and CVSS 3.1 7.5. [CVE][cve] |
| **Last updated** | **2026-11-26 (America/New_York)** | New item. Update an LDAP install to v0.8.9. |

## Detection

An install that does not set `LDAP_URL` and `LDAP_USER_SEARCH_BASE` is outside this flaw. Read the image tag or the release. The GitHub range is **v0.7.9 through v0.8.8**. The CVE record starts at 0.7.3, and the advisory says the versions between v0.7.9 and v0.8.8 were not tested one by one. A restart loop with the log line `credentials (string) is required` is the failure the advisory shows. Reading the configuration changes no state. A version you cannot read means unknown, not safe.

## Remediation

1. Update to **v0.8.9 or later**. That is the release the advisory names, and the fix commit `3de814c0fa` is an ancestor of that tag. The advisory says this covers the source release, not a stale third-party image.
2. An install that cannot update should turn LDAP login off, or set `CONTINUE_ON_UNCAUGHT_EXCEPTION` only with the understanding that the advisory treats the exit as the crash. Turning the variable on is not the fix.
3. The update does not show whether the process was already stopped this way. A crash discloses nothing by itself: the impact is availability.

## Verification

- The running image is **v0.8.9 or later**, or LDAP login is not configured.
- A login with a string password still succeeds.
- Do not send a non-string password to test it.

## Compromise response

Look for repeated process exits with `credentials (string) is required`, and for the container restart count climbing. That is the indicator the advisory prints. The flaw stops the process. It does not read the directory password or write data. A crash alone is not a reason to rotate LDAP credentials.

## Sources

- [GHSA-572g-g8hc-w8c9][ghsa] — published 2026-11-17 by danny-avila. High, CVSS 3.1 7.5. Affected `>= 0.7.9, <= 0.8.8`. Patched in 0.8.9. The page says no CVE is known.
- [v0.8.9][rel] — published 2026-11-17 14:25:11 UTC. Includes pull 18235, "Reject Malformed LDAP Credentials Before Authentication."
- [CVE-2026-137586][cve] — VulnCheck, published 2026-11-26. CVSS 4.0 8.7 and CVSS 3.1 7.5. Affected from 0.7.3 before 0.8.9.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-26. CVE-2026-137586 is not listed.

[ghsa]: https://github.com/LibreChat-AI/LibreChat/security/advisories/GHSA-572g-g8hc-w8c9
[rel]: https://github.com/LibreChat-AI/LibreChat/releases/tag/v0.8.9
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-137586
