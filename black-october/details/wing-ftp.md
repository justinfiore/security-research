# Wing FTP Server: administrator path traversal to code execution

**Last updated:** 2026-11-23 (America/New_York)

[Main summary](../black-october-2026.md#wing-ftp-server-administrator-path-traversal-to-code-execution) · [Main TOC](../black-october-2026.md#table-of-contents)

**[CVE-2026-105420](https://www.cve.org/CVERecord?id=CVE-2026-105420): CERT.PL CNA CVSS 4.0 9.4 Critical.** An administrator can add user directories outside the intended base folder through scripts, write files and execute code as the process owner; installations launched with `sudo` can therefore write as root.

**CISA KEV:** Not listed (catalog 2026.11.23, checked 2026-11-23) for CVE-2026-105420, CVE-2026-133310, CVE-2026-135171, or CVE-2026-135170. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

VulnCheck published [CVE-2026-133310](https://www.cve.org/CVERecord?id=CVE-2026-133310) on November 19 and rates it **CVSS 4.0 9.2**. Wing FTP Server before **8.2.8** accepts an upload-link file name with an embedded NUL byte, which gets past the file-type mask, and an attacker can plant a Lua session file. The vendor history page lists **8.2.8, released 19/Nov/2026**, and one of its lines is "Fixed a potential vulnerability in the upload link interface." That line does not name CVE-2026-133310, so it is the vendor's release, not the vendor's confirmation of this CVE. 8.2.6, the fix for the administrator path traversal, leaves this one in place.

On 2026-11-23 VulnCheck published two more records for the same build. [CVE-2026-135171](https://www.cve.org/CVERecord?id=CVE-2026-135171) is **Critical, CVSS 4.0 9.2** and **High, CVSS 3.1 8.1**: an administrator session identifier can be derived from the process, the time, the ServerID, and the client IP, and a request with no login replays a live session, including the Lua console. [CVE-2026-135170](https://www.cve.org/CVERecord?id=CVE-2026-135170) is **High, CVSS 4.0 7.7** and **CVSS 3.1 7.5**: an LDAP login name injects Lua that runs later as the service account. Both say **before 8.2.8**. The 8.2.8 history lines are "Enhanced the session ID security for the web client/admin" and "Fixed a potential LDAP login name injection vulnerability." Neither line names a CVE. The history page, read 2026-11-23, lists no release after 8.2.8.

## Table of contents
- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline
| Event | Date and time (timezone) | Notes |
|---|---|---|
| Public CVE | 2026-10-28; time/TZ unknown | CERT.PL CNA record. |
| Fixed release | 2026-10-28; time/TZ unknown | Wing FTP Server 8.2.6. CVE-2026-105420 only. |
| Upload-link release | 2026-11-19; time/TZ unknown | Wing FTP Server 8.2.8. The history also says the session ID was strengthened and an LDAP login-name injection was fixed. None of the lines names a CVE. |
| Session and LDAP records | 2026-11-23 14:38 UTC | CVE-2026-135171 at 14:38:49Z, CVSS 4.0 9.2. CVE-2026-135170 at 14:38:50Z, CVSS 4.0 7.7. Both say before 8.2.8. |

## Detection
Inventory Wing FTP Server version, service account and who has administrator access. Versions before 8.2.6 are affected by the path traversal. Versions before 8.2.8 are the range VulnCheck names for the upload link, the session identifier, and the LDAP login name. Review scripted directory changes and service-owned files outside configured user roots; absent evidence does not establish safety.

## Remediation
Upgrade to **8.2.8 or later**. **8.2.6** fixes the administrator path traversal and leaves the other three. VulnCheck says CVE-2026-133310, CVE-2026-135171, and CVE-2026-135170 are fixed in **8.2.8**. The vendor history page, read 2026-11-23, lists 8.2.8, released 19/Nov/2026, with lines for the upload link, the session identifier, and the LDAP login name. None of those lines names a CVE, and the page lists no newer release. Until 8.2.8 is the running build, turn upload links off and end administrator web sessions. Run the service with the least privilege compatible with vendor guidance. Restrict administration to trusted operators and review any `sudo`-based deployment. These controls reduce impact but do not replace the upgrade. The upgrade does not show whether a session was already replayed.

## Verification
Confirm the installed and running version is 8.2.8 or later, check normal user-directory provisioning with a benign test account, and verify the process runs under the expected non-root identity. Do not attempt path traversal or session replay.

## Compromise response
Review writable paths, user-directory changes and process logs; isolate systems with unexpected files or commands; rotate credentials readable by the service; and rebuild if root-level compromise cannot be excluded.

## Sources
- [CVE record](https://www.cve.org/CVERecord?id=CVE-2026-105420)
- [CERT.PL advisory](https://cert.pl/en/posts/2026/10/CVE-2026-105420)
- [Wing FTP Server](https://www.wftpserver.com/)
- [Wing FTP release history](https://www.wftpserver.com/serverhistory.htm) — read 2026-11-23. 8.2.8 released 19/Nov/2026. No newer release. Lines for the upload link, "Enhanced the session ID security for the web client/admin," and "Fixed a potential LDAP login name injection vulnerability."
- [CVE-2026-135171](https://www.cve.org/CVERecord?id=CVE-2026-135171) — VulnCheck, published 2026-11-23T14:38:49.447Z. CVSS 4.0 9.2 and CVSS 3.1 8.1. Before 8.2.8.
- [CVE-2026-135170](https://www.cve.org/CVERecord?id=CVE-2026-135170) — VulnCheck, published 2026-11-23T14:38:50.531Z. CVSS 4.0 7.7 and CVSS 3.1 7.5. Before 8.2.8.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T19:43:55.7979Z, checked 2026-11-23. None of the four is listed.
