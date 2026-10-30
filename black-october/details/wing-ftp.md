# Wing FTP Server: administrator path traversal to code execution

**Last updated:** 2026-10-30 (America/New_York)

[Main summary](../black-october-2026.md#wing-ftp-server-administrator-path-traversal-to-code-execution) · [Main TOC](../black-october-2026.md#table-of-contents)

**[CVE-2026-105420](https://www.cve.org/CVERecord?id=CVE-2026-105420): CERT.PL CNA CVSS 4.0 9.4 Critical.** An administrator can add user directories outside the intended base folder through scripts, write files and execute code as the process owner; installations launched with `sudo` can therefore write as root.

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). No exploitation is reported by the CNA. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fixed release | 2026-10-28; time/TZ unknown | Wing FTP Server 8.2.6. |

## Detection
Inventory Wing FTP Server version, service account and who has administrator access. Versions before 8.2.6 are affected. Review scripted directory changes and service-owned files outside configured user roots; absent evidence does not establish safety.

## Remediation
Upgrade to **8.2.6 or later** and run the service with the least privilege compatible with vendor guidance. Restrict administration to trusted operators and review any `sudo`-based deployment. These controls reduce impact but do not replace the upgrade.

## Verification
Confirm the installed and running version is 8.2.6 or later, check normal user-directory provisioning with a benign test account, and verify the process runs under the expected non-root identity. Do not attempt path traversal.

## Compromise response
Review writable paths, user-directory changes and process logs; isolate systems with unexpected files or commands; rotate credentials readable by the service; and rebuild if root-level compromise cannot be excluded.

## Sources
- [CVE record](https://www.cve.org/CVERecord?id=CVE-2026-105420)
- [CERT.PL advisory](https://cert.pl/en/posts/2026/10/CVE-2026-105420)
- [Wing FTP Server](https://www.wftpserver.com/)
