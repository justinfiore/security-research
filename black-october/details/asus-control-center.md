# ASUS Control Center Express: a forged token is the administrator

**Last updated:** 2026-11-20 (America/New_York)

[Main ASUS summary](../black-october-2026.md#asus-control-center-express-a-forged-token-is-the-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-18 ASUS published a bulletin for Control Center Express, the console it sells for managing fleets of business PCs. Three flaws are Critical. ASUS is the CNA.

[CVE-2026-114202](https://www.cve.org/CVERecord?id=CVE-2026-114202) is **CVSS 4.0 10.0**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`. A hard-coded key lets a remote user with no login forge an authentication token and become an administrator of the console and of the clients it manages.

[CVE-2026-114204](https://www.cve.org/CVERecord?id=CVE-2026-114204) is **CVSS 4.0 9.0**. The vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`. A second hard-coded key forges a session token for an account that has logged in recently. It needs low privileges and a condition ASUS marks present.

[CVE-2026-114205](https://www.cve.org/CVERecord?id=CVE-2026-114205) is **CVSS 4.0 9.4**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`. A signed-in user with a low-privileged role creates an administrator account.

The bulletin says versions **earlier than v1.7.29** are affected and that **v1.7.29 or later** is the fix. The three CVE records say **through v1.7.27**. They do not mention v1.7.28. Install 1.7.29 anyway. ASUS then says to push the agent from the console. Neither the bulletin nor the records report exploitation. CISA's SSVC on the records says exploitation is none.

This is not the same day's Control Center Datacenter and Enterprise flaw, CVE-2026-126574.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-20) for any of the three. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-11-18 10:29:54 +0800** | ASUS bulletin. Fix v1.7.29. [Advisory index][adv] |
| CVE records | 2026-11-18 02:01–02:02 UTC | ASUS CNA. Affected line on the records: through v1.7.27. |

## Detection

Read the console version and the agent version on each managed PC. The bulletin's affected line is anything earlier than v1.7.29. A console already on v1.7.28 is inside the bulletin and outside the CVE records. Treat it as affected until it is v1.7.29.

## Remediation

1. Install Control Center Express **v1.7.29 or later** from ASUS.
2. In the console, select the managed devices and use **Select Function, then Client Agent Updater**. The console update alone does not update the agents.
3. Confirm each agent shows the new version.
4. The update does not show whether a forged token already created an administrator.

## Verification

- The console reports v1.7.29 or later.
- Each managed agent reports the updated version.
- Do not send a forged token.

## Compromise response

ASUS does not report exploitation. A console that was reachable on a build before v1.7.29 should be reviewed for an administrator account nobody created. The update does not remove one.

## Sources

- [ASUS security advisory index][adv] — bulletin "Security Update for ASUS Control Center Express Agent", published 2026-11-18. Versions earlier than v1.7.29. Fix v1.7.29. Scores 10.0, 9.0, and 9.4.
- [ASUS advisory RSS](https://security-advisory-api.asus.com/rss/securityrss.xml) — the same bulletin text, published Wed, 18 Nov 2026 10:29:54 +0800.
- [CVE-2026-114202](https://www.cve.org/CVERecord?id=CVE-2026-114202), [CVE-2026-114204](https://www.cve.org/CVERecord?id=CVE-2026-114204), [CVE-2026-114205](https://www.cve.org/CVERecord?id=CVE-2026-114205) — ASUS CNA, published 2026-11-18. Affected through v1.7.27.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-20. None of the three is listed.

[adv]: https://www.asus.com/security-advisory
