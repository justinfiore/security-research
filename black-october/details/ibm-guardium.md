# IBM Guardium: a request runs code before login

**Last updated:** 2026-11-19 (America/New_York)

[Main Guardium summary](../black-october-2026.md#ibm-guardium-a-request-runs-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-19 IBM published a security bulletin for Guardium Data Protection **12.2**. IBM rates two flaws **CVSS 3.1 9.8 Critical**, and IBM is the CNA for both.

[CVE-2026-84236](https://www.cve.org/CVERecord?id=CVE-2026-84236) is insecure deserialization in the SharePoint Tap MulticastTransceiver. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. An unauthenticated remote attacker can run code.

[CVE-2026-87977](https://www.cve.org/CVERecord?id=CVE-2026-87977) is SQL injection in the edge-controller component, with the same vector. An unauthenticated remote attacker can read or modify the database.

[CVE-2026-82339](https://www.cve.org/CVERecord?id=CVE-2026-82339) is 9.1: the SharePoint S-TAP RelayService has no authentication, so a remote attacker can inject audit events and read the active monitoring policy. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`.

The bulletin lists more, including a PROXY-header overflow at 8.1 and a local root escalation on the Collector at 7.8. The fix for 12.2 is the **12.2.4** GPU, `SqlGuard_12.0p7240_GPU_Oct_2026_V12.2.4_FC`. IBM publishes no workaround. IBM does not report exploitation.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-19) for any CVE in the bulletin. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-11-19; time/TZ unknown** | Initial publication of the bulletin. The GPU build name says October 2026. [Bulletin][bull] |

## Detection

Read the Guardium version from the appliance, not from a plan. **12.2 before 12.2.4** is inside the bulletin. IBM's affected-products table names 12.2 and no other line. The bulletin does not say other lines are unaffected.

## Remediation

1. Install **Guardium Data Protection 12.2.4**, fix `SqlGuard_12.0p7240_GPU_Oct_2026_V12.2.4_FC`, from [Fix Central][fix].
2. IBM publishes no workaround.
3. The update does not show whether a request already ran code or changed an audit record.

## Verification

- The appliance reports 12.2.4, and it has been restarted onto that build.
- A collector still receives the audit stream it received before the update.
- Do not send a deserialization payload or a SQL statement to test the flaws.

## Compromise response

IBM does not report exploitation. A 12.2 appliance that was reachable before the update should be reviewed for an audit event, a monitoring-policy change, or a process the owner did not create. The update does not remove one.

## Sources

- [IBM bulletin 7297484][bull] — initial publication 2026-11-19. Guardium Data Protection 12.2. Fixed in 12.2.4. No workaround.
- [CVE-2026-84236](https://www.cve.org/CVERecord?id=CVE-2026-84236) — IBM, CVSS 3.1 9.8. Unauthenticated code execution in the SharePoint Tap.
- [CVE-2026-87977](https://www.cve.org/CVERecord?id=CVE-2026-87977) — IBM, CVSS 3.1 9.8. Unauthenticated SQL injection in the edge controller.
- [CVE-2026-82339](https://www.cve.org/CVERecord?id=CVE-2026-82339) — IBM, CVSS 3.1 9.1. Missing authentication on the SharePoint S-TAP relay.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-19. None of the bulletin's CVEs is listed.

[bull]: https://www.ibm.com/support/pages/node/7297484
[fix]: https://www.ibm.com/support/fixcentral/swg/quickorder?parent=IBM%20Security&product=ibm/Information+Management/InfoSphere+Guardium&release=All&platform=All&function=fixId&fixids=SqlGuard_12.0p7240_GPU_Oct_2026_V12.2.4_FC&includeSupersedes=0&source=fc
