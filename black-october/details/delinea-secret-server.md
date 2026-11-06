# Delinea Secret Server: second-factor login bypass and unsigned admin token

**Last updated:** 2026-11-06 (America/New_York)

[Main Delinea summary](../black-october-2026.md#delinea-secret-server-second-factor-login-bypass-and-unsigned-admin-token) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Delinea republished three Secret Server records on 2026-11-05. The CNA text now names **Secret Server (On-Prem)** through **12.2.7**, fixed in **12.3.1**. It no longer says cloud. The public [advisories page](https://delinea.com/security-advisories) matches that product line. The Privilege Manager Windows agent is a [separate product](privilege-manager.md) and is not updated by this upgrade.

| CVE | Score | What Delinea says |
|---|---|---|
| [CVE-2026-115829](https://www.cve.org/CVERecord?id=CVE-2026-115829) | Delinea (CNA) CVSS 4.0 **9.9 Critical** (`AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:H/SI:H/SA:N`) | Before 12.3.1, an unauthenticated user can cause a two-factor PIN to be generated for any account, then authenticate with only that second factor. The October 30 record scored this 8.7 High and required high privileges. |
| [CVE-2026-115830](https://www.cve.org/CVERecord?id=CVE-2026-115830) | Delinea (CNA) CVSS 4.0 **8.7 High** (`AV:N/AC:H/AT:N/PR:H/UI:N/VC:H/VI:H/VA:N/SC:H/SI:H/SA:N`) | Before 12.3.1, a user under certain conditions could submit an unsigned JWT and receive cloudadmin permissions. |
| [CVE-2026-115828](https://www.cve.org/CVERecord?id=CVE-2026-115828) | Delinea (CNA) CVSS 4.0 **9.4 Critical** (`AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:H/VA:N/SC:H/SI:H/SA:N`) | Before 12.3.1, Secret Server did not always validate the PIN or biometric check on a FIDO2 device. The October 30 record scored this 5.1. |

NVD has not scored the records. CISA's enrichment on 2026-10-30 records Exploitation "none" for the two October High CVEs. Older Critical issues on the page, including CVE-2026-19117 (FIDO2 registration bypass, CVSS 3.1 9.8) and CVE-2026-15640 (SAML impersonation, CVSS 4.0 9.5), were published in September and are not this entry. A host still below 12.2.7 is exposed to those as well.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-06) for CVE-2026-115829, CVE-2026-115830, or CVE-2026-115828. CISA records Exploitation "none" for the first two. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private report | Unknown | CVE-2026-115829 credits Aidan Stansfield, Division 5. No date. |
| CVE records published | 2026-10-30 19:46:55 UTC (CVE-2026-115830) and 19:47:31 UTC (CVE-2026-115829) | Delinea CNA. Affected through 12.2.7; fixed line is versions earlier than 12.3.1. |
| Vendor advisory page | Checked 2026-11-01 | [delinea.com/security-advisories][advisories] listed both CVEs for on-prem and cloud, through 12.2.7, fixed in 12.3.1. An October 31 reading of the same page did not. |
| Records republished | 2026-11-05 17:58–17:59 UTC | Delinea CNA. CVE-2026-115829 is now 9.9 Critical and needs no login. CVE-2026-115828 is now 9.4 Critical. The product line on all three records is on-prem only. |

## Detection

1. Read the installed Secret Server version from the product's about or version page, not from a ticket. Delinea's November 5 records say on-prem through 12.2.7 is affected and 12.3.1 is the fix. 12.3.0 is not named. Treat 12.3.0 as unconfirmed rather than calling it fixed or vulnerable. The records no longer name cloud. A cloud tenant is not in the range the CNA now publishes.
2. The second-factor bypass no longer needs an account. The November 5 text says an unauthenticated user can generate a PIN for any account and then finish only the second factor. The unsigned-JWT flaw still needs "certain conditions" the CNA does not list.
3. There is no published log query. A successful admin login is not evidence of the JWT flaw.

## Remediation

1. Upgrade on-prem Secret Server to **12.3.1 or later**. Delinea publishes no workaround in the CNA records. The November 5 records do not name a cloud action.
2. If the instance is still below 12.2.7, the upgrade also moves past the September Critical fixes on the public advisories page (12.2.7 for CVE-2026-19117, CVE-2026-15640, and CVE-2026-15638). Do not stop at 12.2.7: that version is inside the affected range for these two October flaws.
3. Keep the management interface off untrusted networks until the new version is the one answering. That is containment, not a fix.

## Verification

- Confirm the running version is 12.3.1 or later, then sign in with an account you already use, including its second factor.
- Do not submit an unsigned JWT or skip the first login step against a production server to test either flaw.

## Compromise response

If an affected version was reachable, preserve authentication and admin-audit logs before cleanup. Look for sessions that completed a second factor without a matching first-factor success, and for cloudadmin actions you cannot tie to a known administrator. Upgrading closes the two paths the CNA describes; it does not show whether either was used. Revoke sessions and review admin membership after an unexplained cloudadmin grant.

## Sources

- [CVE-2026-115829][cve829] — Delinea CNA, published 2026-10-30 19:47:31 UTC, updated 2026-11-05 17:58:16 UTC. Now CVSS 4.0 9.9 Critical, unauthenticated PIN generation, on-prem through 12.2.7.
- [CVE-2026-115830][cve830] — Delinea CNA, published 2026-10-30 19:46:55 UTC, updated 2026-11-05 17:58:43 UTC. Still CVSS 4.0 8.7 High. Product line is now on-prem only.
- [CVE-2026-115828][cve828] — Delinea CNA, updated 2026-11-05 17:59:32 UTC. Now CVSS 4.0 9.4 Critical. The October 30 score was 5.1.
- [Delinea security advisories][advisories] — the product line now matches the records: on-prem, through 12.2.7, fixed in 12.3.1.
- [CISA KEV JSON feed][kev] — neither High CVE listed (catalog 2026.10.30).

[cve829]: https://www.cve.org/CVERecord?id=CVE-2026-115829
[cve830]: https://www.cve.org/CVERecord?id=CVE-2026-115830
[cve828]: https://www.cve.org/CVERecord?id=CVE-2026-115828
[advisories]: https://delinea.com/security-advisories
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
