# Bolo: an article list returns the password that hides a post

**Last updated:** 2026-11-16 (America/New_York)

[Main Bolo summary](../black-october-2026.md#bolo-an-article-list-returns-the-password-that-hides-a-post) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Bolo (bolo-solo) is a self-hosted Java blog. [CVE-2026-129493](https://www.cve.org/CVERecord?id=CVE-2026-129493) returns the password that protects an article. VulnCheck is the CNA and rates it **CVSS 4.0 8.7 High** and **CVSS 3.1 7.5 High**. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N`. The 4.0 vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`. NVD has not scored it.

The record says 1.7 through **2.6.4** are affected, and it names no unaffected version. A request with no login to `GET /articles` receives the plaintext `articleViewPwd` field. Submitting that value reads the article it was meant to hide. The newest GitHub release is **v2.6.4_stable**, published 2025-06-02, which is the top of the affected range. The finder's GitHub issue 331, opened 2026-11-15, describes a stored cross-site scripting flaw in comments and links a report that also covers this password disclosure. The issue is still open, and the project has not answered it. The CVE record does not cover the comment scripting, and no CVE for it was found.

This is not [CloudPaste](cloudpaste.md) and not [VoAPI](voapi.md). The same finder published all three on November 15.

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
| Bolo v2.6.4_stable | 2025-06-02 06:34:21 UTC | Newest GitHub release. The top of the affected range. [GitHub releases][rel] |
| Finder's report | 2026-11-15; time/TZ unknown | GitHub issue 331, which leads with comment scripting. Still open. [GitHub][iss] |
| **Public announcement** | **2026-11-16; time/TZ unknown** | VulnCheck published the CVE record. NVD's published time is 2026-11-16 01:17 UTC. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. No fixed release. |

## Detection

Read the version from the deployment's release tag. The about page of a Bolo blog also shows it; prefer the tag on a host you trust. A blog that is not bolo-solo is outside this entry. A blog that has never set an article password has nothing for this field to return; the record does not say the field is omitted in that case.

## Remediation

1. There is no fixed release. v2.6.4 is the newest, and it is affected.
2. Until a release lands, do not rely on an article password to hide a post. Remove the password-protected articles, or take the blog off the public internet.
3. Change every article password. A password that was already returned still opens the article.

## Verification

- The deployed tag is newer than v2.6.4 once a fixed release exists. None does today.
- Do not request `/articles` to confirm the field. Read the response only from a log you already have.

## Compromise response

No source publishes an indicator or a confirmed compromise. The disclosure shows the content of a password-protected article. Look for article passwords that no longer match what you set, and for comments containing markup nobody wrote: the finder's issue reports comment scripting separately, with no CVE. A comment is a lead, not proof.

## Sources

- [CVE-2026-129493](https://www.cve.org/CVERecord?id=CVE-2026-129493) — VulnCheck, published 2026-11-16. CVSS 4.0 8.7 and CVSS 3.1 7.5. Affected 1.7 through 2.6.4. No unaffected version.
- [NVD, CVE-2026-129493](https://nvd.nist.gov/vuln/detail/CVE-2026-129493) — published 2026-11-16 01:17 UTC. NVD has not scored it.
- [GitHub issue 331][iss] — opened 2026-11-15 by Wu Yulun. Open, with no project response. The issue text describes comment scripting; the linked report also covers this CVE.
- [GitHub releases][rel] — v2.6.4_stable published 2025-06-02T06:34:21Z, the newest.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. CVE-2026-129493 is not in it.

[iss]: https://github.com/bolo-blog/bolo-solo/issues/331
[rel]: https://github.com/bolo-blog/bolo-solo/releases
