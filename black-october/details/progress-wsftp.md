# Progress WS_FTP Server: Critical authentication and command-injection flaws

**Last updated:** 2026-10-30 (America/New_York)

[Main WS_FTP Server summary](../black-october-2026.md#progress-ws_ftp-server-critical-authentication-and-command-injection-flaws) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-84295](https://www.cve.org/CVERecord?id=CVE-2026-84295) — Progress CNA CVSS 3.1 10.0 Critical** permits unauthenticated access to sensitive information, including administrator credentials. **[CVE-2026-90868](https://www.cve.org/CVERecord?id=CVE-2026-90868) — Progress CNA CVSS 3.1 9.9 Critical** is OS command injection under certain configurations. Both affect Windows WS_FTP Server installations.

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). No active exploitation is reported by the Progress CNA records. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| CVE records published | 2026-10-29; time/TZ unknown | Progress published both CNA records. [CVE-2026-84295][cve-auth] [CVE-2026-90868][cve-cmd] |
| CVE-2026-84295 fixes | 2026-09-03; time/TZ unknown | Fixed in 2024.0.6 and 2025.0.3 according to Progress's CNA record. [CVE-2026-84295][cve-auth] |
| CVE-2026-90868 fixes | 2026-10-01; time/TZ unknown | Fixed in 2024.0.7 and 2025.0.4 according to Progress's CNA record. [CVE-2026-90868][cve-cmd] |

## Detection

1. Inventory Windows hosts running WS_FTP Server and record the product train and exact version from the product console or installed-program metadata.
2. CVE-2026-84295 affects versions before 2024.0.6 and 2025.0.3; CVE-2026-90868 affects versions before 2024.0.7 and 2025.0.4. An unverified version is unknown, not safe.
3. Review service and Windows event logs, administrator-account changes, and command-execution telemetry for unexpected activity. The CNA records do not publish IOCs, so absence of a named indicator cannot clear a host.

## Remediation

1. Upgrade WS_FTP Server to **2024.0.7** or **2025.0.4** or a later supported release; these versions cover both records.
2. Restrict WS_FTP administrative and transfer-service exposure to required trusted networks while scheduling the update. Do not treat access restriction as a replacement for the update.
3. Follow Progress's supported update procedure and back up configuration before maintenance; validate any version-path prerequisites with Progress documentation.

## Verification

- Confirm the running service reports 2024.0.7/2025.0.4 or a later supported version, then verify ordinary authenticated transfers in a controlled environment.
- Do not submit crafted authentication requests or command-injection inputs to a production server.

## Compromise response

Treat suspected exploitation as server compromise: preserve logs and configuration, rotate WS_FTP administrator and stored integration credentials, review transferred data and Windows process telemetry, and rebuild the server from trusted media if integrity cannot be established.

## Sources

- [CVE-2026-84295][cve-auth] — Progress CNA severity, affected versions and authentication impact.
- [CVE-2026-90868][cve-cmd] — Progress CNA severity, affected versions and command-injection impact.
- [CISA KEV JSON feed][kev] — catalog status.

[cve-auth]: https://www.cve.org/CVERecord?id=CVE-2026-84295
[cve-cmd]: https://www.cve.org/CVERecord?id=CVE-2026-90868
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
