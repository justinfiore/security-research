# JSPWiki: a login keeps the session the attacker set

**Last updated:** 2026-11-28 (America/New_York)

[Main guide](../black-october-2026.md#jspwiki-a-login-keeps-the-session-the-attacker-set)

The Apache Software Foundation published [CVE-2026-78114](https://www.cve.org/CVERecord?id=CVE-2026-78114) on 2026-11-25 at 10:22:16 UTC. Apache rates it **Critical, CVSS 4.0 10.0**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`. The weakness is CWE-384, session fixation. The defect is JSPWIKI-1301.

The login flow of Apache JSPWiki 2.10.0 through 3.0.0 does not replace the session identifier when a user authenticates. An attacker who can set a known session identifier in a victim's browser can use that same identifier after the victim logs in. Apache does not report exploitation. NVD has not scored it.

The same advisory names the fixes: **3.0.1** on the 3.x line and **2.12.6** on the 2.x line. The project's [news page][news], modified 2026-11-27 19:40, lists this CVE with twenty-two others disclosed on 2026-11-24. Those records have no CVSS score. This guide tracks the scored one.

**CISA KEV:** Not listed (catalog 2026.11.27, checked 2026-11-28). Apache does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-25 10:22:16 UTC** | Apache published the record. CVSS 4.0 10.0. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-78114) |
| Mailing-list post | 2026-11-25 01:58 | Alex O'Ree posted the same text to user@jspwiki.apache.org. The archive shows a date and not a timezone. [Post][list] |
| Project news | 2026-11-24; time unknown | The news page groups this CVE with twenty-two others. The page was last modified 2026-11-27 19:40. [News][news] |
| **Last updated** | **2026-11-28 (America/New_York)** | New item. The record is November 25. |

## Detection

Read the running JSPWiki version. The footer of a default install prints it, and the `jspwiki-war` package is `org.apache.jspwiki:jspwiki-war`.

| Line | Affected | Fixed |
|---|---|---|
| 2.x | 2.10.0 through 2.12.5 | 2.12.6 or later |
| 3.x | 3.0.0 | 3.0.1 or later |

The record writes one range, 2.10.0 through 3.0.0, and then names 2.12.6 as a fix inside that range. A 2.x install at 2.12.6 or later is the fix Apache names, not an affected build. A version before 2.10.0 is outside the range the record gives. A version you cannot read is unknown, not safe. Reading the version changes no state.

## Remediation

1. Upgrade the line you run and restart the application. 3.x goes to **3.0.1 or later**. 2.x goes to **2.12.6 or later**. The [downloads page](https://jspwiki.apache.org/development/downloads.html) is the vendor's distribution.
2. After the restart, have users log in again. The old session identifier is what the flaw keeps.

Apache names no workaround.

## Verification

- The running build reports 3.0.1 or later, or 2.12.6 or later.
- Do not plant a session identifier to test the login.

## Compromise response

Apache does not report exploitation. The upgrade does not show whether a known identifier was reused before the restart. A session that stayed the same across a login is the place to look. The upgrade does not undo a page edit that session made.

## Sources

- [CVE-2026-78114](https://www.cve.org/CVERecord?id=CVE-2026-78114) — Apache, published 2026-11-25 10:22:16 UTC. CVSS 4.0 10.0. CWE-384. JSPWIKI-1301. Affected 2.10.0 through 3.0.0. Fixed in 3.0.1 and 2.12.6.
- [Mailing list][list] — Alex O'Ree, 2026-11-25 01:58. Same text as the record.
- [Project news][news] — modified 2026-11-27 19:40. The 2026-11-24 line lists this CVE with twenty-two others that have no score.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.27. Not listed.

[list]: https://lists.apache.org/thread.html/n43zhkpnphlksm12w7ndx4d87s7wdffv
[news]: https://jspwiki-wiki.apache.org/Wiki.jsp?page=News
