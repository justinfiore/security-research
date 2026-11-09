# JetBrains Datalore: code execution from a view-only notebook

**Last updated:** 2026-11-08 (America/New_York)

[Main Datalore summary](../black-october-2026.md#jetbrains-datalore-code-execution-from-a-view-only-notebook) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-123279](https://www.cve.org/CVERecord?id=CVE-2026-123279): JetBrains (CNA) rates it CVSS 3.1 9.0 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:H`. NVD has not scored it. Before Datalore **2026.4**, a view-only collaborator could run code in a notebook's computation. The record says the attacker needs low privileges and that a user has to interact. JetBrains does not say what that interaction is. The impact crosses a security boundary.

Five more Datalore flaws in the same publication are High. [CVE-2026-123836](https://www.cve.org/CVERecord?id=CVE-2026-123836) is **8.8**: a workspace collaborator could obtain the owner's SSH private key through Git backup, fixed before 2026.4. [CVE-2026-123280](https://www.cve.org/CVERecord?id=CVE-2026-123280) is **8.1**: an unauthenticated user could run code through a published interactive report, fixed before **2026.2.4**. [CVE-2026-123281](https://www.cve.org/CVERecord?id=CVE-2026-123281) is **7.5**: notebook code could run commands in the sidecar container through the mount broker, fixed before 2026.4. [CVE-2026-123834](https://www.cve.org/CVERecord?id=CVE-2026-123834) is **7.5**: a database task could use another workspace's service account, fixed before 2026.4. [CVE-2026-123282](https://www.cve.org/CVERecord?id=CVE-2026-123282) is **7.4**: an account token that should have expired could start a new session, fixed before 2026.4.

Ten more Datalore records published the same day are below 7.0. They include an SSO sign-in to a pre-registered account (6.8), a view-only collaborator changing shared content (6.5), and an unauthenticated read of hidden notebook code through a public report (5.3). Nine of those ten are fixed before 2026.4. [CVE-2026-123285](https://www.cve.org/CVERecord?id=CVE-2026-123285), 6.3, is fixed before 2026.3.

This is the Datalore you run. Datalore Cloud is JetBrains' to patch. The records do not say Cloud was vulnerable, and they do not say it was not. This is not [Hub](jetbrains-hub.md).

**Fixed in 2026.4.** JetBrains' issues-fixed page, reread 2026-11-08, now lists these CVEs. It rates CVE-2026-123279 Critical, resolved in 2026.4, and CVE-2026-123280 High, resolved in 2026.2.4. It also lists CVE-2026-123836 as High, resolved in 2026.4. Those versions match the CVE records. The page did not list them on 2026-11-07. The On-Premises what's-new page says 2026.4 fixes multiple security issues, including a Critical one, and that further details will be shared after customers have had time to update. It says 2026.2.4 fixed a high-severity vulnerability in public interactive reports, which matches the 8.1 record's version and not its CVE ID. 2026.4.1, the next row, applies security updates to agent Python environments, including eMudhra and Brotli. That is not these CVEs.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08) for any of these CVEs. JetBrains does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | The CVE records name no finder and no report date. The what's-new page says internal review and external penetration testing. |
| **Public announcement** | **2026-11-06 10:27:47 UTC** | CVE-2026-123279 published. The other Datalore records in this cluster follow the same day, through 16:10 UTC. [Record][cve] |
| 2026.2.4 | Date not on the what's-new page | The page says that release fixed a high-severity flaw in public interactive reports. The page footer is 29 October 2026, which is not a release date for 2026.4. [What's new][whatsnew] |
| Patch | 2026.4; release timestamp not on the CVE record | Affected is every version before 2026.4 for the 9.0 flaw. 2026.2.4 is the floor only for CVE-2026-123280. |
| Issues-fixed page | Reread 2026-11-08 | It now lists CVE-2026-123279, CVE-2026-123280, and CVE-2026-123836 at those versions. It did not on 2026-11-07. |
| **Last updated** | **2026-11-08 (America/New_York)** | The vendor index lists the CVEs. The fix is unchanged. |

## Detection

Read the running version from the status panel in the notebook editor, or from Account settings. The help page says both show the On-Premises version.

- Below **2026.4** is inside CVE-2026-123279 and the other flaws fixed in that release.
- Below **2026.2.4** is also inside CVE-2026-123280, the unauthenticated report flaw. 2026.2.4 is not the fix for the 9.0 flaw.
- **2026.4 or later** is outside the flaws in this entry. 2026.4.1 is a later build; it is not required for these CVEs.

A Datalore that only signed-in users can reach is still affected. The 9.0 score needs a view-only collaborator, not an anonymous caller. The 8.1 score does not: a published interactive report is enough, and that one is fixed one release earlier. Datalore Cloud is not a version you upgrade.

## Remediation

1. Update On-Premises Datalore to **2026.4 or later**. That release is the floor for the 9.0 flaw. 2026.2.4 fixes the 8.1 public-report flaw and not the 9.0 flaw.
2. JetBrains publishes no workaround on the CVE records. Unpublishing reports does not fix the view-only flaw. Removing view-only collaborators is not a documented mitigation.
3. The update does not revoke an SSH key a collaborator already copied, does not end a session an expired token already created, and does not undo a command a notebook already ran.

## Verification

- The status panel or Account settings shows **2026.4 or later**.
- Open one notebook you already trust. Do not attempt the view-only computation or the public-report request the records describe.

## Compromise response

JetBrains does not publish an indicator. If the instance was below 2026.4 while notebooks were shared, or below 2026.2.4 while interactive reports were public:

- Export the audit log before the update, if the instance has one.
- Look for notebook runs started by a user whose role was view-only.
- Look for report computations that ran while the report was public and you did not expect a run.
- Rotate SSH keys stored in Datalore workspaces. The 8.8 flaw is a collaborator reading the owner's private key through Git backup. The update does not rotate that key.
- Sign users out and revoke API tokens. The 7.4 flaw let an expired account token start a new session. The update does not end a session already created.

## Sources

- [CVE-2026-123279][cve] — JetBrains CNA. Published 2026-11-06 10:27:47 UTC. CVSS 3.1 9.0. Affected from 0 before 2026.4. CWE-863.
- [CVE-2026-123280](https://www.cve.org/CVERecord?id=CVE-2026-123280) — 8.1 High, fixed before 2026.2.4. Published 2026-11-06 10:27:48 UTC.
- [CVE-2026-123836](https://www.cve.org/CVERecord?id=CVE-2026-123836) — 8.8 High, SSH private key through Git backup, fixed before 2026.4. Published 2026-11-06 16:10:01 UTC.
- [Datalore what's new][whatsnew] — On-Premises release notes. 2026.4 fixes multiple security issues, including a Critical one, and withholds the details. Read 2026-11-07. Page footer 29 October 2026.
- [JetBrains issues fixed](https://www.jetbrains.com/privacy-security/issues-fixed/) — reread 2026-11-08. It now lists CVE-2026-123279, CVE-2026-123280, and CVE-2026-123836 at the versions above. It did not list them on 2026-11-07. Older Datalore rows on that page are earlier issues.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-123279
[whatsnew]: https://www.jetbrains.com/help/datalore/whats-new.html
