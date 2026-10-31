# Delinea Secret Server: second-factor login bypass and unsigned admin token

**Last updated:** 2026-10-31 (America/New_York)

[Main Delinea summary](../black-october-2026.md#delinea-secret-server-second-factor-login-bypass-and-unsigned-admin-token) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Delinea published two High flaws in Secret Server on 2026-10-30. Both are fixed before 12.3.1 is required; the CNA's affected range is "older versions" through **12.2.7**. The vendor's public [advisories page](https://delinea.com/security-advisories) did not list either CVE when this guide was written, so the version claim comes from the CNA records, not from a Delinea write-up.

| CVE | Score | What Delinea says |
|---|---|---|
| [CVE-2026-115829](https://www.cve.org/CVERecord?id=CVE-2026-115829) | Delinea (CNA) CVSS 4.0 **8.7 High** (`AV:N/AC:H/AT:N/PR:H/UI:N/VC:H/VI:H/VA:N/SC:H/SI:H/SA:N`) | Before 12.3.1, a user could bypass the initial login step and authenticate by completing only the second-factor step. Credit: Aidan Stansfield, Division 5. |
| [CVE-2026-115830](https://www.cve.org/CVERecord?id=CVE-2026-115830) | Delinea (CNA) CVSS 4.0 **8.7 High** (same vector) | Before 12.3.1, a user under certain conditions could submit an unsigned JWT and receive cloudadmin permissions. |

NVD has not scored either record. CISA's enrichment on 2026-10-30 records Exploitation "none" for both. The CNA does not say whether Secret Server Cloud is affected; the product field is "Secret Server" with no edition. Do not assume cloud tenants are out of scope, and do not assume they are vulnerable, until Delinea says which edition.

The same public advisories page does list older Critical issues whose fixes are earlier than 12.3.1, including CVE-2026-19117 (FIDO2 registration bypass, CVSS 3.1 9.8) and CVE-2026-15640 (SAML impersonation, CVSS 4.0 9.5). Those were published in September and are not this entry. A host still below 12.2.7 is exposed to those as well as to the two October flaws.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-10-31) for CVE-2026-115829 or CVE-2026-115830. CISA records Exploitation "none". Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Vendor advisory page | Checked 2026-10-31 | [delinea.com/security-advisories][advisories] does not yet name these two CVEs. |

## Detection

1. Read the installed Secret Server version from the product's about or version page, not from a ticket. The CNA says versions through 12.2.7 are affected and versions earlier than 12.3.1 are the vulnerable set. 12.3.0 is not named. Treat 12.3.0 as unconfirmed rather than calling it fixed or vulnerable.
2. The second-factor bypass needs an account that can complete a second factor without the first login step. The unsigned-JWT flaw needs "certain conditions" the CNA does not list. Neither description is an unauthenticated internet scan you can confirm from outside.
3. There is no published log query. A successful admin login is not evidence of the JWT flaw.

## Remediation

1. Upgrade Secret Server to **12.3.1 or later**. Delinea publishes no workaround in the CNA records.
2. If the instance is still below 12.2.7, the upgrade also moves past the September Critical fixes on the public advisories page (12.2.7 for CVE-2026-19117, CVE-2026-15640, and CVE-2026-15638). Do not stop at 12.2.7: that version is inside the affected range for these two October flaws.
3. Keep the management interface off untrusted networks until the new version is the one answering. That is containment, not a fix.

## Verification

- Confirm the running version is 12.3.1 or later, then sign in with an account you already use, including its second factor.
- Do not submit an unsigned JWT or skip the first login step against a production server to test either flaw.

## Compromise response

If an affected version was reachable, preserve authentication and admin-audit logs before cleanup. Look for sessions that completed a second factor without a matching first-factor success, and for cloudadmin actions you cannot tie to a known administrator. Upgrading closes the two paths the CNA describes; it does not show whether either was used. Revoke sessions and review admin membership after an unexplained cloudadmin grant.

## Sources

- [CVE-2026-115829][cve829] — Delinea CNA, published 2026-10-30 19:47:31 UTC, CVSS 4.0 8.7 High, affected through 12.2.7. CISA ADP Exploitation "none".
- [CVE-2026-115830][cve830] — Delinea CNA, published 2026-10-30 19:46:55 UTC, CVSS 4.0 8.7 High, unsigned JWT to cloudadmin. CISA ADP Exploitation "none".
- [Delinea security advisories][advisories] — checked 2026-10-31; these two CVEs are absent. Older Critical Secret Server issues and their fix versions are listed there.
- [CISA KEV JSON feed][kev] — neither CVE listed (catalog 2026.10.30).

[cve829]: https://www.cve.org/CVERecord?id=CVE-2026-115829
[cve830]: https://www.cve.org/CVERecord?id=CVE-2026-115830
[advisories]: https://delinea.com/security-advisories
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
