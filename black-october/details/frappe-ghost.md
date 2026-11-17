# Frappe Ghost: a guest session becomes any account

**Last updated:** 2026-11-16 (America/New_York)

[Main Frappe Ghost summary](../black-october-2026.md#frappe-ghost-a-guest-session-becomes-any-account) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Ghost by muneeb141 is a Frappe app for anonymous sessions. It is not the Ghost publishing platform. [CVE-2026-130070](https://www.cve.org/CVERecord?id=CVE-2026-130070) lets a request with no login take over an existing account. VulnCheck is the CNA and rates it **CVSS 4.0 9.3 Critical** and **CVSS 3.1 9.1 Critical**. The 4.0 vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N`. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. NVD has not scored it. Availability is not in either score.

The affected range is the main branch from commit `c731cdf0d0fbcf4fe67ee27199a48ffbbaf3e66b` through commit `672dfec` (2026-10-13 12:39:19 UTC). `create_ghost_session` is guest-accessible. `convert_to_real_user` then accepts a caller-supplied `bypass_otp` and a caller-supplied `real_email`, and returns OAuth tokens for that account. Commit `641db34f6456c15f381358e2e631df66ea170842`, dated 2026-10-20 19:16:39 UTC, generates the anonymous identity on the server and removes the public OTP bypass. GitHub lists no release. A checkout that has not pulled that commit is still inside the range.

The finder credited by VulnCheck is Behruz Chilmatov. The record names no exploitation.

This is not [Go1 CMS](go1cms.md).

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-16). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Last affected commit | 2026-10-13 12:39:19 UTC | Commit `672dfec`. |
| Fix committed | 2026-10-20 19:16:39 UTC | Commit `641db34`. No release tag. [Commit][fix] |
| **Public announcement** | **2026-11-16; time/TZ unknown** | VulnCheck published the CVE record. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. The fix is a commit, not a release. |

## Detection

Read the commit the deployed app is built from. A tree whose history contains `641db34` has the fix. A tree at `672dfec` or any commit from `c731cdf` up to but not including `641db34` is inside the range. A site that does not run this app is outside this entry. The Ghost publishing platform is a different product and is outside it too.

## Remediation

1. Deploy a tree that contains commit `641db34f6456c15f381358e2e631df66ea170842` and restart the Frappe workers and web process. There is no release to install.
2. The commit does not expire a token that was already issued. Revoke OAuth tokens issued to accounts you cannot account for, and reset those passwords.

## Verification

- The running app's commit history contains `641db34`. A commit fetched but not restarted into is not the fix.
- Do not call `convert_to_real_user` to test it.

## Compromise response

No source publishes an indicator or a confirmed compromise. A request that succeeded returns tokens for an account the caller named, so that account's later actions may not be that user's. If a login or a token exists that the account owner did not create, revoke it, reset the password, and review what that session changed.

## Sources

- [CVE-2026-130070](https://www.cve.org/CVERecord?id=CVE-2026-130070) — VulnCheck, published 2026-11-16. CVSS 4.0 9.3 and CVSS 3.1 9.1. `bypass_otp` through commit `672dfec`.
- [VulnCheck advisory](https://www.vulncheck.com/advisories/ghost-muneeb141-authentication-bypass-via-bypass-otp-in-convert-to-real-user) — same facts, dated 2026-11-16.
- [Commit 641db34][fix] — 2026-10-20 19:16:39 UTC. Removes the public OTP bypass.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. This CVE is not in it.

[fix]: https://github.com/muneeb141/ghost/commit/641db34f6456c15f381358e2e631df66ea170842
