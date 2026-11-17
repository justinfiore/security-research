# CBoard: any logged-in user reaches the administrator's functions

**Last updated:** 2026-11-17 (America/New_York)

[Main CBoard summary](../black-october-2026.md#cboard-any-logged-in-user-reaches-the-administrators-functions) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

VulnCheck rates [CVE-2026-130073](https://www.cve.org/CVERecord?id=CVE-2026-130073) **CVSS 4.0 7.2 High** and **CVSS 3.1 8.3 High**. VulnCheck is the CNA. The 4.0 vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:L/VI:H/VA:H/SC:N/SI:N/SA:N`. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:L/I:H/A:H`. NVD had not scored it on November 17.

CBoard, before commit [`7bd8180`](https://github.com/TuiQiao/CBoard/commit/7bd8180d8423a36b29a803433078bd66f94a81ed), lets methods on `AdminController` and `DashboardController` skip the role check. A user who has logged in and holds no role grant can call `deleteUser`, `deleteRole`, `getUserList`, `getAllWidgetList`, and `getAllDatasetList`. That reads query configurations and can delete accounts, including the administrator. The commit message says it also gates role deletion, scopes the widget and dataset lists, and redacts a widget's configuration from a board response when the caller has no grant.

The commit is dated 2026-11-16 03:32:45 UTC and is one commit behind the tip of `branch-0.4.2`. The repository's default branch is `branch-0.4.2`. There is no GitHub release, and the newest tag is `v0.4.1`, which does not contain the commit. Deploying the default branch at its November 16 tip includes the fix. Deploying the newest tag does not.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-17). VulnCheck does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix commit | 2026-11-16 03:32:45 UTC | `7bd8180` on `branch-0.4.2`. [Commit][commit] |
| **Public announcement** | **2026-11-16; time unknown** | VulnCheck published the CVE record. |
| **Last updated** | **2026-11-17 (America/New_York)** | New item. No release contains the fix. |

## Detection

1. The running build is the only check. A checkout whose `git merge-base --is-ancestor 7bd8180d8423a36b29a803433078bd66f94a81ed HEAD` succeeds contains the fix. Tag `v0.4.1` and anything older does not. The tip of `branch-0.4.2` on November 16 was `6e00c65`, one commit past the fix.
2. A deleted user, a deleted role, or a board whose query configuration an ordinary account should not have seen is the effect the record describes. Absence of those is not a clean bill, and this guide has no log line from the project.

## Remediation

1. Deploy commit `7bd8180` or later from `branch-0.4.2`, and restart. There is no release to upgrade to. `v0.4.1` is still affected.
2. Until then, do not give an account to anyone who should not be an administrator. The flaw needs a login and nothing more.
3. The deploy does not restore an account or a role that was already deleted.

## Verification

- The deployed revision is `7bd8180` or a descendant of it, and the process was restarted after the deploy.
- An ordinary account can still open its own board. Do not call `deleteUser` to test the check.

## Compromise response

VulnCheck publishes no indicator and does not report exploitation. If untrusted accounts could log in before the deploy, review users and roles for a deletion the owner did not make, and review whether a query configuration was read. The deploy does not put a deleted account back.

## Sources

- [CVE-2026-130073](https://www.cve.org/CVERecord?id=CVE-2026-130073) — VulnCheck, published 2026-11-16. CVSS 4.0 7.2 and CVSS 3.1 8.3. Affected before commit `7bd8180`.
- [Commit 7bd8180][commit] — 2026-11-16 03:32:45 UTC. "Fix broken access control in admin and dashboard endpoints." One behind the tip of `branch-0.4.2`.
- [CBoard tags](https://github.com/TuiQiao/CBoard/tags) — read 2026-11-17. Newest tag `v0.4.1`. No GitHub releases.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, checked 2026-11-17. Not listed.

[commit]: https://github.com/TuiQiao/CBoard/commit/7bd8180d8423a36b29a803433078bd66f94a81ed
