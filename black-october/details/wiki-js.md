# Wiki.js: a user manager takes the administrator account

**Last updated:** 2026-11-16 (America/New_York)

[Main Wiki.js summary](../black-october-2026.md#wikijs-a-user-manager-takes-the-administrator-account) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Wiki.js (requarks) is a Node.js wiki. Two flaws fixed in **2.5.315** are rated High by GitHub, the CNA. Both need an account. Neither needs to be an administrator.

[CVE-2026-120698](https://www.cve.org/CVERecord?id=CVE-2026-120698) is the account takeover. An account with only `manage:users` calls `users.update` without the `groups` argument and sets the password of any local account, including the root administrator. The same account calls `users.disableTFA` and clears that account's second factor. Sending `groups: []` removes every group from the target, which can leave the site with no administrator. GitHub rates it **CVSS 3.1 8.8 High**, vector `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. [GHSA-45cp-v5ph-2jhm](https://github.com/requarks/wiki/security/advisories/GHSA-45cp-v5ph-2jhm) says versions through 2.5.314 are affected. The advisory was published 2026-09-21.

[CVE-2026-120697](https://www.cve.org/CVERecord?id=CVE-2026-120697) is stored script in a page. An account with `write:pages` stores a JavaScript expression in a `v-slot:tabs` or `v-slot:content` attribute. The sanitizer allows those attributes, and the page is compiled as a Vue template, so the expression runs when someone else opens the page, including an administrator. GitHub rates it **CVSS 3.1 8.7 High**, vector `CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:N`. [GHSA-98c8-px3r-68c6](https://github.com/requarks/wiki/security/advisories/GHSA-98c8-px3r-68c6) says versions before 2.5.314 are affected, and the CVE record says everything before 2.5.315. The release that fixes both is 2.5.315, so a site on 2.5.314 should move too. NVD has not scored either record.

[v2.5.315](https://github.com/requarks/wiki/releases/tag/v2.5.315) was published 2026-09-21 06:18:18 UTC. The release note says 2.x releases have moved to the `wiki-v2` repository and that this is the last 2.x release posted in `requarks/wiki`. The CVE records were published 2026-11-16. Neither record describes exploitation.

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
| Advisories and fix | 2026-09-21 06:18:18 UTC | v2.5.315. Both GitHub advisories published the same day. [Release][rel] |
| **Public announcement** | **2026-11-16; time/TZ unknown** | GitHub published both CVE records. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. Fixed in 2.5.315. |

## Detection

Read the Wiki.js version the running process reports, or the image tag. Anything before 2.5.315 is inside at least one of the two ranges. A site that does not run Wiki.js is outside this entry. An account that can edit pages is enough for the script flaw; an account with `manage:users` is enough for the takeover.

## Remediation

1. Upgrade to **2.5.315 or later** and restart. 2.5.315 is the last 2.x release in `requarks/wiki`; later 2.x builds are in `requarks/wiki-v2`.
2. The upgrade does not put a password, a second factor, or a group membership back. Reset the root administrator password, turn its second factor back on, and check that an administrator group still has a member.
3. The upgrade does not remove a page that already contains the slot attribute. Review pages edited by accounts that should not run script.

## Verification

- The running version is 2.5.315 or later. A container image pulled but not restarted is not the fix.
- Do not submit a page built to run script, and do not call `users.update` against the administrator to test it.

## Compromise response

No source publishes an indicator or a confirmed compromise. A takeover replaces the administrator password and can disable the second factor, so a login to the root account that the owner did not make is the thing to look for. A stored expression runs as whoever opens the page. If either happened, reset the administrator credentials, remove the page content, and review changes made with that session.

## Sources

- [CVE-2026-120698](https://www.cve.org/CVERecord?id=CVE-2026-120698) — GitHub, published 2026-11-16. CVSS 3.1 8.8. `manage:users` takes the root account. Fixed in 2.5.315.
- [GHSA-45cp-v5ph-2jhm](https://github.com/requarks/wiki/security/advisories/GHSA-45cp-v5ph-2jhm) — published 2026-09-21. Affected through 2.5.314.
- [CVE-2026-120697](https://www.cve.org/CVERecord?id=CVE-2026-120697) — GitHub, published 2026-11-16. CVSS 3.1 8.7. Slot attributes run script. Fixed in 2.5.315.
- [GHSA-98c8-px3r-68c6](https://github.com/requarks/wiki/security/advisories/GHSA-98c8-px3r-68c6) — published 2026-09-21. The advisory's affected line says before 2.5.314; the CVE record says before 2.5.315.
- [v2.5.315][rel] — published 2026-09-21 06:18:18 UTC. Last 2.x release in this repository.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. Neither CVE is in it.

[rel]: https://github.com/requarks/wiki/releases/tag/v2.5.315
