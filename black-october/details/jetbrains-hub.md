# JetBrains Hub: privilege escalation during email verification

**Last updated:** 2026-11-08 (America/New_York)

[Main JetBrains Hub summary](../black-october-2026.md#jetbrains-hub-privilege-escalation-during-email-verification) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-123294](https://www.cve.org/CVERecord?id=CVE-2026-123294): JetBrains (CNA) rates it CVSS 3.1 9.6 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:N`. NVD has not scored it. Before Hub **2026.2.52556**, changing email authentication details during the verification flow could escalate privileges. The record says the attacker needs low privileges, and that the impact crosses a security boundary. JetBrains does not say which privilege is gained, and it does not name a finder for this CVE.

The same publication includes five more Hub flaws. Only one is also High. [CVE-2026-123296](https://www.cve.org/CVERecord?id=CVE-2026-123296) is CVSS 3.1 **7.5 High**, fixed in **2026.2.52519**: privilege escalation through a forged email verification. The other four are below 7.0 and are fixed in one of those two builds: [CVE-2026-123297](https://www.cve.org/CVERecord?id=CVE-2026-123297) is 6.8, a two-factor bypass through password reset, in 2026.2.52519; [CVE-2026-123298](https://www.cve.org/CVERecord?id=CVE-2026-123298) is 5.0, SMTP command injection through email verification, in 2026.2.52556; [CVE-2026-123299](https://www.cve.org/CVERecord?id=CVE-2026-123299) is 3.1 and [CVE-2026-123300](https://www.cve.org/CVERecord?id=CVE-2026-123300) is 2.7, both in 2026.2.52519.

Hub is the identity service behind self-hosted YouTrack and other JetBrains team tools. A hosted YouTrack Cloud instance is JetBrains' to patch. This entry is the Hub you run.

**Fixed in 2026.2.52556.** JetBrains' issues-fixed page, reread 2026-11-08, now lists both High and Critical Hub flaws. It rates CVE-2026-123294 Critical, resolved in 2026.2.52556, and CVE-2026-123296 High, resolved in 2026.2.52519. The page did not list CVE-2026-123294 on 2026-11-06. The CVE record remains the source for the score. Affected is every version before that build.

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
| Private discovery | Unknown | The CVE records name no finder and no report date. |
| **Public announcement** | **2026-11-06 10:27:54 UTC** | CVE-2026-123294 published. The five related records follow within the same minute, through 10:27:57 UTC. [Record][cve] |
| Patch available | Unconfirmed as a calendar date | The record says fixed before is not the case at 2026.2.52556. JetBrains does not publish that build's release timestamp on the CVE record. |
| Issues-fixed page | Reread 2026-11-08 | It now lists CVE-2026-123294 at 2026.2.52556 and CVE-2026-123296 at 2026.2.52519. It did not list the first on 2026-11-06. |
| **Last updated** | **2026-11-08 (America/New_York)** | The vendor index lists the CVEs. The fix is unchanged. |

## Detection

On the Hub host, read the running version from the Hub footer or from the installation's `build.txt`. Compare the build number, not only the 2026.2 train.

- Below **2026.2.52556** is inside CVE-2026-123294 and CVE-2026-123298.
- Below **2026.2.52519** is also inside CVE-2026-123296 and the three lower-scored flaws.
- **2026.2.52556 or later** is outside all six.

A Hub that only administrators can reach is still affected. The 9.6 score requires a low-privilege account, not an anonymous caller. YouTrack Cloud is not a version you can read this way.

## Remediation

1. Upgrade Hub to **2026.2.52556 or later**. That build is the floor for the 9.6 flaw. 2026.2.52519 fixes the 7.5 flaw and not the 9.6 flaw.
2. JetBrains publishes no workaround on the CVE record. Removing email verification is not a documented mitigation and can break sign-in.
3. The upgrade does not revoke a privilege the verification flow already granted, and it does not undo a group mapping a read-only user already changed.

## Verification

- The running build is **2026.2.52556 or later**.
- Sign in with an ordinary account and confirm Hub still sends a verification message. Do not attempt the verification-flow change the record describes.

## Compromise response

JetBrains does not publish an indicator. If Hub was below 2026.2.52556 while users could start an email change:

- Export the audit log before the upgrade.
- Look for privilege or group changes that coincide with an email verification you did not expect.
- Look for mail the Hub server sent that no administrator generated. The 5.0 flaw is an SMTP injection through the same verification flow; the record rates its integrity impact Low.
- If a user holds a role they should not, remove it. The upgrade does not.

## Sources

- [CVE-2026-123294][cve] — JetBrains CNA. Published 2026-11-06 10:27:54 UTC, updated 2026-11-06 14:44:08 UTC. CVSS 3.1 9.6. Affected from 0 before 2026.2.52556. CWE-915.
- [CVE-2026-123296](https://www.cve.org/CVERecord?id=CVE-2026-123296) — 7.5 High, fixed before 2026.2.52519. Published 2026-11-06 10:27:55 UTC.
- [JetBrains issues fixed][fixed] — the vendor index. Read 2026-11-06. It does not list these six CVEs. Older Hub rows on that page are earlier issues.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-123294
[fixed]: https://www.jetbrains.com/privacy-security/issues-fixed/
