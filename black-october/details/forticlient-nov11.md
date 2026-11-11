# FortiClient: a web page runs code through the local API

**Last updated:** 2026-11-11 (America/New_York)

[Main FortiClient summary](../black-october-2026.md#forticlient-a-web-page-runs-code-through-the-local-api) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

FortiClient is Fortinet's VPN and endpoint agent. FG-IR-26-194 is an origin-validation error, CWE-346, in a local API endpoint. A remote attacker who is not logged in can run code if the person using the computer does something, such as visiting a page. Fortinet's table includes FortiClient Windows, FortiClient Mac, and FortiClient Windows PAM, so the Windows and Mac agents are affected whether or not FortiPAM is in use. Fortinet says no virtual patch exists.

**Fortinet rates [CVE-2026-121529](https://www.cve.org/CVERecord?id=CVE-2026-121529) CVSS 3.1 9.1 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:H/E:P/RL:O/RC:C`. Fortinet is the CNA. The temporal score is lower because the exploit maturity is `E:P`, proof of concept, and the advisory's **Known Exploited** field is No. The CVE record's product list names FortiClient Windows PAM only at 7.4.7 and 7.2.14. The advisory's table is the wider range, 7.4.0 through 7.4.7 and 7.2.0 through 7.2.14, and that is the range to patch.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-11). Fortinet marks the flaw as not known to be exploited. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

This is not the [November 10 FortiManager and FortiAnalyzer set](fortinet-october.md). Those are appliance flaws. This one is the agent on a laptop.

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
| **Public announcement and fix** | **2026-11-10; time/TZ unknown** | FG-IR-26-194, initial publication. Severity Critical. Known Exploited: No. [Advisory][fgir] |
| CVE record published | 2026-11-10; time/TZ unknown | Fortinet CNA. CVSS 3.1 9.1. The product list names narrower PAM builds than the advisory. [CVE-2026-121529][cve] |

## Detection

1. Read the FortiClient version on the endpoint, or from FortiClient EMS. The affected builds are:

   | Product | Affected | First fixed |
   |---|---|---|
   | FortiClient Windows 7.4 | 7.4.0 through 7.4.7 | 7.4.8 |
   | FortiClient Windows 7.2 | 7.2.0 through 7.2.14 | 7.2.15 |
   | FortiClient Mac 7.4 | 7.4.0 through 7.4.7 | 7.4.8 |
   | FortiClient Windows PAM 7.4 | 7.4.0 through 7.4.7 | 7.4.8 |
   | FortiClient Windows PAM 7.2 | 7.2.0 through 7.2.14 | 7.2.15 |

2. FortiClient Mac 8.0, FortiClient Windows 8.0, FortiClient Windows PAM 8.0, and FortiClient Mac 7.2 are not affected.
3. The advisory does not name a log line, a file, or a process that shows the local API was used. A version below the floor is the check. Not seeing anything else is not proof the endpoint was not reached.

## Remediation

1. Upgrade FortiClient Windows and FortiClient Windows PAM to **7.4.8 or later** on the 7.4 line, or **7.2.15 or later** on the 7.2 line. Upgrade FortiClient Mac 7.4 to **7.4.8 or later**.
2. Fortinet lists no virtual patch and no workaround. Until the endpoint is on a fixed build, the person using it can still be led to a page that reaches the local API.
3. Push the upgrade from EMS where the endpoints are managed, and confirm the version EMS reports afterward rather than the version the installer was told to deploy.

## Verification

- The running FortiClient build is 7.4.8 or later, or 7.2.15 or later on a 7.2 Windows or Windows PAM install. FortiClient Mac 7.2 and every 8.0 build were already outside it.
- The endpoint was restarted or the agent was restarted after the upgrade, so the old agent is not still the one listening.
- Do not visit a page built to call the local API to test the check.

## Compromise response

The advisory does not say what a successful call leaves on the endpoint, so the upgrade does not show whether code already ran. On an endpoint that was below the floor while someone was using it, look for an account or a scheduled task that appeared after November 10, and rotate credentials that endpoint could read, including a VPN profile stored on it. Reinstalling the agent does not remove a payload that already ran as the user.

## Sources

- [FG-IR-26-194][fgir] — published 2026-11-10. Severity Critical, CVSS 3.1 9.1. Origin validation in a local API. Affected and fixed builds are in the table above. Known Exploited: No. No virtual patch.
- [CVE-2026-121529][cve] — Fortinet CNA, published 2026-11-10. The same score. The product list names FortiClient Windows PAM only at 7.4.7 and 7.2.14, which is narrower than the advisory.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10, checked 2026-11-11. Not listed.

[fgir]: https://fortiguard.fortinet.com/psirt/FG-IR-26-194
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-121529
