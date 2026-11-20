# WatchGuard Dimension: a log request runs code before login

**Last updated:** 2026-11-19 (America/New_York)

[Main Dimension summary](../black-october-2026.md#watchguard-dimension-a-log-request-runs-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-19 WatchGuard published a set of Dimension flaws. WatchGuard rates [CVE-2026-86130](https://www.cve.org/CVERecord?id=CVE-2026-86130) **Critical, CVSS 4.0 9.3**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The log collection service accepts a request with no login, runs SQL, and then runs code as the Dimension WebUI process user. Dimension **2.0 before 2.3.2** is affected. **2.3.2** is the fix. This is the logging and reporting server, not the AuthPoint gateway.

Two more are Critical and need a Dimension Administrator login. [CVE-2026-86094](https://www.cve.org/CVERecord?id=CVE-2026-86094) is CVSS 4.0 9.3: a diagnostic log keeps a Super Administrator's session token, and a low-privileged administrator can read it while that session is open. [CVE-2026-84322](https://www.cve.org/CVERecord?id=CVE-2026-84322) is 9.3: a management API returns those session identifiers. WatchGuard says it is not aware of exploitation of any of the three.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-19) for any of the three. WatchGuard does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-11-19; time/TZ unknown** | WatchGuard published the three pages and named Dimension 2.3.2. [CVE-2026-86130][cve] |

## Detection

Read the version from the Dimension console, not from a plan. Dimension 2.0 through 2.3.1 is inside all three. 2.3.2 or later is the build WatchGuard names.

The log collection service is the path for CVE-2026-86130. A firewall log of that service is a lead. Absence of those lines does not show whether a request already ran.

## Remediation

1. Upgrade Dimension to **2.3.2 or later**.
2. WatchGuard publishes no workaround for CVE-2026-86130. Keeping the log collection service off untrusted networks reduces who can reach it. That is not the fix.
3. After the upgrade, end administrator sessions that were open on a build before 2.3.2. The upgrade does not invalidate a token that was already copied out of the diagnostic log.

## Verification

- The Dimension console reports 2.3.2 or later, and the service has been restarted onto it.
- Log collection from a managed device still arrives.
- Do not send a crafted log request to test the flaw.

## Compromise response

WatchGuard does not report exploitation. A Dimension that was reachable on the log collection port before the upgrade should be reviewed for a process, a file, or an administrator account the owner did not create. The upgrade does not remove one. A Super Administrator session that was open on an older build should be treated as copied: sign that administrator out and sign in again.

## Sources

- [CVE-2026-86130][cve] — WatchGuard, published 2026-11-19. Critical, CVSS 4.0 9.3. Dimension 2.0 before 2.3.2. Fixed in 2.3.2. No exploitation known to WatchGuard.
- [CVE-2026-86094](https://psirt.watchguard.com/CVE-2026-86094/) — WatchGuard, published 2026-11-19. Critical, CVSS 4.0 9.3. A low-privileged administrator reads a Super Administrator session token from the diagnostic log. Same build.
- [CVE-2026-84322](https://psirt.watchguard.com/CVE-2026-84322/) — WatchGuard, published 2026-11-19. Critical, CVSS 4.0 9.3. A management API returns session identifiers. Same build.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-19. None of the three is listed.

[cve]: https://psirt.watchguard.com/CVE-2026-86130/
