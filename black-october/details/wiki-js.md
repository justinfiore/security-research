# Wiki.js: a user manager takes the administrator account

**Last updated:** 2026-11-24 (America/New_York)

[Main Wiki.js summary](../black-october-2026.md#wikijs-a-user-manager-takes-the-administrator-account) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Wiki.js (requarks) is a Node.js wiki. Two flaws fixed in **2.5.315** are rated High by GitHub, the CNA. Both need an account. Neither needs to be an administrator.

[CVE-2026-120698](https://www.cve.org/CVERecord?id=CVE-2026-120698) is the account takeover. An account with only `manage:users` calls `users.update` without the `groups` argument and sets the password of any local account, including the root administrator. The same account calls `users.disableTFA` and clears that account's second factor. Sending `groups: []` removes every group from the target, which can leave the site with no administrator. GitHub rates it **CVSS 3.1 8.8 High**, vector `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. [GHSA-45cp-v5ph-2jhm](https://github.com/requarks/wiki/security/advisories/GHSA-45cp-v5ph-2jhm) says versions through 2.5.314 are affected. The advisory was published 2026-09-21.

[CVE-2026-120697](https://www.cve.org/CVERecord?id=CVE-2026-120697) is stored script in a page. An account with `write:pages` stores a JavaScript expression in a `v-slot:tabs` or `v-slot:content` attribute. The sanitizer allows those attributes, and the page is compiled as a Vue template, so the expression runs when someone else opens the page, including an administrator. GitHub rates it **CVSS 3.1 8.7 High**, vector `CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:N`. [GHSA-98c8-px3r-68c6](https://github.com/requarks/wiki/security/advisories/GHSA-98c8-px3r-68c6) says versions before 2.5.314 are affected, and the CVE record says everything before 2.5.315. The release that fixes both is 2.5.315, so a site on 2.5.314 should move too. NVD has not scored either record.

[v2.5.315](https://github.com/requarks/wiki/releases/tag/v2.5.315) was published 2026-09-21 06:18:18 UTC. The release note says 2.x releases have moved to the `wiki-v2` repository and that this is the last 2.x release posted in `requarks/wiki`. The CVE records were published 2026-11-16. CISA's enrichment of the CVE-2026-120698 record, timestamped 2026-11-16 21:28 UTC, marks exploitation `poc`. The same mark was added to CVE-2026-120697 on 2026-11-18 17:59 UTC, citing the GitHub advisory. Both are a public proof of concept, not a report of use in the wild. Neither record describes an incident. `requarks/wiki-v2` has later builds, v2.5.316 (2026-10-02) and v2.5.317 (2026-10-23). Both contain the fix commits, and neither release note names these CVEs.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-18). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

**Wiki.js 3 is a separate line.** [GHSA-fcq7-f2fm-cm85](https://github.com/requarks/wiki/security/advisories/GHSA-fcq7-f2fm-cm85), published 2026-11-23, is High, CVSS 3.1 8.7 (`CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:N`). An editor stores a MathJax formula whose link runs script when an administrator clicks it, and the reporter's lab used that click to add the editor to the Administrators group. **3.6.0 and earlier** are affected. **3.6.1** is the fix. No CVE is assigned. The advisory says earlier 3.x releases that ship the block were not checked, and it does not report exploitation. A 2.x site is outside this flaw.

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
| Advisories and fix | 2026-09-21 06:18:18 UTC | v2.5.315. Both GitHub advisories published the same day. [Release][rel] |
| **Public announcement** | **2026-11-16; time/TZ unknown** | GitHub published both CVE records. |
| Proof of concept marked | 2026-11-16 21:28 UTC | CISA's enrichment of CVE-2026-120698 says `poc`. Not a report of use in the wild. |
| **Proof of concept marked** | **2026-11-18 17:59 UTC** | CISA's enrichment of CVE-2026-120697 now says `poc`, citing the GitHub advisory. Not a report of use in the wild. |
| Wiki.js 3 advisory | 2026-11-23; time/TZ unknown | [GHSA-fcq7-f2fm-cm85][g3]. High, 8.7. Fixed in 3.6.1. No CVE. |
| **Last updated** | **2026-11-24 (America/New_York)** | Wiki.js 3.6.1 closes a High formula flaw. The 2.x floor is unchanged. |

## Detection

Read the Wiki.js version the running process reports, or the image tag. Anything before 2.5.315 is inside at least one of the two ranges. A site that does not run Wiki.js is outside this entry. An account that can edit pages is enough for the script flaw; an account with `manage:users` is enough for the takeover.

## Remediation

1. On 2.x, upgrade to **2.5.315 or later** and restart. 2.5.315 is the last 2.x release in `requarks/wiki`; later 2.x builds are in `requarks/wiki-v2`.
2. On 3.x, upgrade to **3.6.1 or later** and restart. 3.6.0 leaves the MathJax formula flaw in place. The 2.x upgrade does not move a 3.x site.
2. The upgrade does not put a password, a second factor, or a group membership back. Reset the root administrator password, turn its second factor back on, and check that an administrator group still has a member.
3. The upgrade does not remove a page that already contains the slot attribute. Review pages edited by accounts that should not run script.

## Verification

- The running version is 2.5.315 or later. A container image pulled but not restarted is not the fix.
- Do not submit a page built to run script, and do not call `users.update` against the administrator to test it.

## Compromise response

CISA's enrichment marks a proof of concept for the takeover and names no incident. A takeover replaces the administrator password and can disable the second factor, so a login to the root account that the owner did not make is the thing to look for. A stored expression runs as whoever opens the page. If either happened, reset the administrator credentials, remove the page content, and review changes made with that session.

## Sources

- [CVE-2026-120698](https://www.cve.org/CVERecord?id=CVE-2026-120698) — GitHub, published 2026-11-16. CVSS 3.1 8.8. `manage:users` takes the root account. Fixed in 2.5.315.
- [GHSA-45cp-v5ph-2jhm](https://github.com/requarks/wiki/security/advisories/GHSA-45cp-v5ph-2jhm) — published 2026-09-21. Affected through 2.5.314.
- [CVE-2026-120697](https://www.cve.org/CVERecord?id=CVE-2026-120697) — GitHub, published 2026-11-16. CVSS 3.1 8.7. Slot attributes run script. Fixed in 2.5.315.
- [GHSA-98c8-px3r-68c6](https://github.com/requarks/wiki/security/advisories/GHSA-98c8-px3r-68c6) — published 2026-09-21. The advisory's affected line says before 2.5.314; the CVE record says before 2.5.315.
- [v2.5.315][rel] — published 2026-09-21 06:18:18 UTC. Last 2.x release in this repository.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, released 2026-11-18T19:17:41.0354Z, read 2026-11-18. Neither CVE is in it.

[rel]: https://github.com/requarks/wiki/releases/tag/v2.5.315
[g3]: https://github.com/requarks/wiki/security/advisories/GHSA-fcq7-f2fm-cm85
