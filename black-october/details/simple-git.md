# Node.js: simple-git runs a command from an argument

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#nodejs-simple-git-runs-a-command-from-an-argument) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-22 VulnCheck published [CVE-2026-134815](https://www.cve.org/CVERecord?id=CVE-2026-134815) for the `simple-git` npm package. VulnCheck is the CNA and rates it **CVSS 4.0 9.2 Critical** and **CVSS 3.1 8.1 High**. The CVSS 4.0 vector is `CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The CVSS 3.1 vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`. NVD has not scored it. The maintainer's release notes name the same commit and publish no score of their own.

`allowUnsafePack` used to block the `--exec` option only on `git push`. The same option names the remote program for `ls-remote`, `archive --remote`, `fetch-pack`, and `send-pack`. An application that passes attacker-controlled arguments to `listRemote()` or `raw()` can be given `--exec`, and git runs that program. The record says this needs no privileges. It does need the application to forward those arguments. The maintainer's notes also close other argument and configuration gaps in the same release; this entry tracks the one the CVE names.

`simple-git` **before 4.1.0** is affected, and `@simple-git/argv-parser` **before 3.0.0**. **4.1.0**, released 2026-11-16, blocks `--exec` for every command other than `rebase`. The check is enforced when `unsafe.recommended` or `strict` is on. The release notes say `unsafe.recommended` defaults to `false` and is implied by `strict: true`, and that it will default to `true` in the next major version. An install of 4.1.0 that leaves both off does not get this check. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-23). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| 4.1.0 | 2026-11-16 18:23:38 UTC | Blocks `--exec` beyond `push`. [Release][rel] |
| **Public announcement** | **2026-11-22; time/TZ unknown** | VulnCheck published the record. CVSS 4.0 9.2 and CVSS 3.1 8.1. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-134815) |

## Detection

Read `simple-git` from the lockfile. **Anything before 4.1.0** is inside the range the record names. A dependency that never passes outside arguments to `listRemote()` or `raw()` is outside the path the description names; the version is still the one the record lists. Reading the lockfile changes no state.

## Remediation

1. Upgrade `simple-git` to **4.1.0 or later**, which brings `@simple-git/argv-parser` **3.0.0**.
2. Turn on `strict: true`, or `unsafe.recommended: true`. Without one of those, the release notes say the new `--exec` check is not enforced.
3. The upgrade does not show whether a command already ran.

## Verification

- The installed `simple-git` is **4.1.0 or later**.
- Do not pass `--exec` to a git command to test it.

## Compromise response

No source read for this entry reports an incident. If the application forwarded untrusted arguments to git before the upgrade, review what that process could run and rotate credentials it could read. The upgrade does not undo a command that already ran.

## Sources

- [CVE-2026-134815](https://www.cve.org/CVERecord?id=CVE-2026-134815) — VulnCheck, published 2026-11-22. CVSS 4.0 9.2 and CVSS 3.1 8.1. `simple-git` before 4.1.0 and `@simple-git/argv-parser` before 3.0.0. Credits Zachariah Mithani (AploSec).
- [simple-git 4.1.0][rel] — published 2026-11-16T18:23:38Z. Commit `c8ee6bb` extends `allowUnsafePack` to every command other than `rebase`. `unsafe.recommended` defaults to false.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-23. Not listed.

[rel]: https://github.com/steveukx/git-js/releases/tag/simple-git%404.1.0
