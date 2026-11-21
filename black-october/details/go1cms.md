# Go1 CMS: a guest request rewrites any record

**Last updated:** 2026-11-20 (America/New_York)

[Main Go1 CMS summary](../black-october-2026.md#go1-cms-a-guest-request-rewrites-any-record) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Go1 CMS (`go1cms`, by TridotsTech) is a Frappe app. [CVE-2026-130071](https://www.cve.org/CVERecord?id=CVE-2026-130071) lets a request with no login change any document, including a User record. VulnCheck is the CNA and rates it **CVSS 4.0 9.3 Critical** and **CVSS 3.1 9.8 Critical**. The 4.0 vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. NVD has not scored it.

The `update_doc` method was on the guest whitelist and saved with `ignore_permissions=True`. A caller supplies a doctype, a name, and fields, and the save writes them. The record covers the master branch through commit `7f68d05` and the version-3 branch before commit `ead8da36a9452b961cc5361d6fd853ca68a58b08`. That commit, dated 2026-09-17 10:08:44 UTC, drops the guest whitelist and saves with the record's own permissions. GitHub lists no release. On 2026-11-20 the default branch `master` was still `7f68d05` and did not contain the fix. The `version-3` tip `868e353`, committed 2026-11-18, does. A checkout that has not pulled the fix is still inside the range.

The finder credited by VulnCheck is Behruz Chilmatov. The record names no exploitation.

This is not [Prime](prime-cms.md) and not [CloudPaste](cloudpaste.md).

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-20). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix committed | 2026-09-17 10:08:44 UTC | Commit `ead8da3` on version-3. No release tag. [Commit][fix] |
| **Public announcement** | **2026-11-16; time/TZ unknown** | VulnCheck published the CVE record. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. The fix is a commit, not a release. |

## Detection

Read the commit the deployed app is built from. `git -C <app> rev-parse HEAD` and `git merge-base --is-ancestor ead8da36a9452b961cc5361d6fd853ca68a58b08 HEAD` tell you whether the fix is in that tree. A checkout of master at or before `7f68d05`, or of version-3 that does not contain `ead8da3`, is inside the range. A site that does not run the go1cms app is outside this entry.

## Remediation

1. Deploy a tree that contains commit `ead8da36a9452b961cc5361d6fd853ca68a58b08` and restart the Frappe workers and web process. There is no release to install.
2. The commit does not undo a User record that was already changed. Look for accounts, roles, and passwords that nobody set.

## Verification

- The running app's commit history contains `ead8da3`. A commit fetched but not restarted into is not the fix.
- Do not call `update_doc` as a guest to test it.

## Compromise response

No source publishes an indicator or a confirmed compromise. A request that succeeded can have changed any document the site stores, including who is an administrator. If you cannot account for a new account, a role change, or a password reset, treat the site as exposed: remove the account, reset the password, and rotate any credential stored in a document the guest method could write.

## Sources

- [CVE-2026-130071](https://www.cve.org/CVERecord?id=CVE-2026-130071) — VulnCheck, published 2026-11-16. CVSS 4.0 9.3 and CVSS 3.1 9.8. Guest `update_doc` before commit `ead8da3`.
- [VulnCheck advisory](https://www.vulncheck.com/advisories/tridotstech-go1cms-unauthenticated-arbitrary-document-modification-via-update-doc) — same facts, dated 2026-11-16.
- [Commit ead8da3][fix] — 2026-09-17 10:08:44 UTC. Drops the guest whitelist and saves with the record's own permissions.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-20. This CVE is not in it.

[fix]: https://github.com/TridotsTech/go1cms/commit/ead8da36a9452b961cc5361d6fd853ca68a58b08
