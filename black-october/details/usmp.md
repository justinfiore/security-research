# Unstable Slope Management Program: a request runs SQL before login

**Last updated:** 2026-11-21 (America/New_York)

[Main USMP summary](../black-october-2026.md#unstable-slope-management-program-a-request-runs-sql-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

The Unstable Slope Management Program is a web application federal land managers use to inventory slopes beside roads and trails. CISA published [VA-26-324-01][csaf] on November 20, 2026, covering six flaws. CISA is the CNA. The advisory says a combination of them could let an attacker inject SQL commands, create or delete users, retrieve user passwords, and bypass authentication. Every one says "Fixed on or around 2026-10-19." CISA names no build number and no download.

**CISA rates [CVE-2026-129175](https://www.cve.org/CVERecord?id=CVE-2026-129175) CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. The CVE record also carries CVSS 4.0 9.3, `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. A request with no login injects SQL, and CISA says that can give root access and complete control of the database.

**CISA rates [CVE-2026-129176](https://www.cve.org/CVERecord?id=CVE-2026-129176) CVSS 3.1 8.2 High.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:L/A:H`. A POST with no cookie deletes a named user.

**CISA rates [CVE-2026-129179](https://www.cve.org/CVERecord?id=CVE-2026-129179) CVSS 3.1 8.1 High.** The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N`. Someone who already has a local application password can open a session by posting JSON to the login endpoint, with no Referrer header and without the Keycloak flow the application intends.

**CISA rates [CVE-2026-129177](https://www.cve.org/CVERecord?id=CVE-2026-129177) CVSS 3.1 7.5 High.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:N`. A POST with no cookie creates a user.

Two more are Medium and are not the reason this item is here. [CVE-2026-129178](https://www.cve.org/CVERecord?id=CVE-2026-129178) is 6.5: local passwords are stored as unsalted MD5. [CVE-2026-129174](https://www.cve.org/CVERecord?id=CVE-2026-129174) is 5.3: a request with no login returns the user list and their permissions in plaintext. The CVE record for that one also carries CVSS 4.0 6.9.

Blake Rash of CISA is credited on all six. The SSVC notes in the CSAF mark exploit evidence as proof of concept, not active exploitation. CISA does not report exploitation.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-21) for any of the six. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix | 2026-10-19; time unknown | "Fixed on or around 2026-10-19." No build number. [VA-26-324-01][csaf] |
| **Public announcement** | **2026-11-20 18:51 UTC** | CSAF initial release. Six CVEs. [VA-26-324-01][csaf] |
| **Last updated** | **2026-11-21 (America/New_York)** | New item. Confirm the October 19 fix is the one running. |

## Detection

The application is the Unstable Slope Management Program at usmp.info, used by the National Park Service, the Federal Highway Administration, and other federal land managers. A deployment that is not that application is outside this advisory.

The advisory does not name a version string, a file, or a page that shows whether the October 19 fix is installed. Ask the operator who runs the instance. A copy that was last deployed before October 19 is inside the affected range CISA names.

## Remediation

CISA's only remediation is "Fixed on or around 2026-10-19." There is no public package and no workaround.

1. Confirm with the operator that the instance running now is the one fixed on or around October 19. Redeploy it if it is not.
2. Until that is confirmed, do not expose the application to the internet. The four High and Critical flaws need no login, except CVE-2026-129179, which needs a local password.
3. After the fix is in, reset local passwords. The old ones were unsalted MD5, and the user list was readable without a login.

## Verification

- The operator confirms the running instance is the October 19 fix.
- A request with no cookie does not return the user list, create a user, or delete a user. Do not send a SQL payload to test CVE-2026-129175.
- Local passwords are no longer the hashes from before the fix.

## Compromise response

CISA publishes no indicator. An instance that was reachable before October 19 is the one the advisory describes. Review accounts for a user you did not create, and review the database for a change you cannot account for. Reset every local password. The fix does not undo a row that was already changed.

## Sources

- [VA-26-324-01][csaf] — CISA CSAF, version 1.0.0, initial release 2026-11-20T18:51:46Z. Six flaws, all "Fixed on or around 2026-10-19." CVE-2026-129175 is CVSS 3.1 9.8. CVE-2026-129176 is 8.2. CVE-2026-129179 is 8.1. CVE-2026-129177 is 7.5. CVE-2026-129178 is 6.5. CVE-2026-129174 is 5.3.
- [CVE-2026-129175](https://www.cve.org/CVERecord?id=CVE-2026-129175) — CISA CNA, published 2026-11-20. CVSS 3.1 9.8 and CVSS 4.0 9.3. Unaffected at 2026-10-19.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-21. None of the six is listed.

[csaf]: https://raw.githubusercontent.com/cisagov/CSAF/develop/csaf_files/IT/white/2026/va-26-324-01.json
