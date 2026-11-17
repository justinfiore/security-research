# B3log Solo: an article list returns the password that hides a post

**Last updated:** 2026-11-17 (America/New_York)

[Main B3log Solo summary](../black-october-2026.md#b3log-solo-an-article-list-returns-the-password-that-hides-a-post) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

B3log Solo is a self-hosted Java blog, repository `88250/solo`. [CVE-2026-130081](https://www.cve.org/CVERecord?id=CVE-2026-130081) returns the password that protects an article. VulnCheck is the CNA and rates it **CVSS 4.0 8.7 High** and **CVSS 3.1 7.5 High**. The 4.0 vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N`. NVD has not scored it.

The record says versions through **4.4.0** are affected. A request with no login to `GET /articles` receives the `articleViewPwd` property, and that value reads the article it was meant to hide. The finder is Wu Yulun. The newest GitHub release is **v4.4.0**, published 2022-01-22, which is the top of the affected range. Commit [`4630843`](https://github.com/88250/solo/commit/46308431d479b61d4ac5cc768474efa140c23cc8), dated 2026-11-13 05:14:56 UTC, removes the property from the public data model. Its message also covers SQL injection and cross-site scripting, which this CVE record does not. The commit is the tip of `master`. No release contains it.

This is not [Bolo](bolo.md). Bolo has the same symptom under CVE-2026-129493, in a different project, and that one has no fix commit.

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
| Solo v4.4.0 | 2022-01-22 08:33:12 UTC | Newest GitHub release. The top of the affected range. [Releases][rel] |
| Fix commit | 2026-11-13 05:14:56 UTC | `4630843` on `master`. No tag. [Commit][commit] |
| **Public announcement** | **2026-11-16; time unknown** | VulnCheck published the record. Its advisory page dates it 11/16/2026. |
| **Last updated** | **2026-11-17 (America/New_York)** | New item. No release contains the fix. |

## Detection

Read the version from the deployment's build. A blog running a release through v4.4.0, or a build of `master` from before the commit, is inside the record. A blog that is Bolo, or that is not Solo, is outside this entry. A blog that has never set an article password has nothing for this field to return; the record does not say the field is omitted in that case.

## Remediation

1. Deploy commit `4630843` or later and restart. v4.4.0, the newest release, is still affected.
2. Until the deploy, do not rely on an article password to hide a post. Remove the password-protected articles, or take the blog off the public internet.
3. Change every article password. A password that was already returned still opens the article.

## Verification

- The deployed commit is `4630843` or later. No release tag qualifies.
- Do not request `/articles` to confirm the field. Read the response only from a log you already have.

## Compromise response

VulnCheck publishes no indicator and does not report exploitation. The disclosure shows the content of a password-protected article. The commit also changes SQL handling and template escaping; those are not this CVE. The deploy does not show whether a password was already read.

## Sources

- [CVE-2026-130081](https://www.cve.org/CVERecord?id=CVE-2026-130081) — VulnCheck, published 2026-11-16. CVSS 4.0 8.7 and CVSS 3.1 7.5. Affected through 4.4.0.
- [VulnCheck advisory](https://www.vulncheck.com/advisories/b3log-solo-through-4.4.0-article-view-password-disclosure-via-articles) — dated 11/16/2026. Severity high. Same description.
- [Commit 4630843][commit] — 2026-11-13 05:14:56 UTC. Removes `articleViewPwd` from the public data model. Also touches SQL and templates.
- [GitHub releases][rel] — v4.4.0 published 2022-01-22T08:33:12Z, the newest.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, checked 2026-11-17. CVE-2026-130081 is not in it.

[commit]: https://github.com/88250/solo/commit/46308431d479b61d4ac5cc768474efa140c23cc8
[rel]: https://github.com/88250/solo/releases
