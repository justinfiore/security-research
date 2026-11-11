# Git: a recursive clone of a malicious repository runs code

**Last updated:** 2026-11-10 (America/New_York)

[Main Git summary](../black-october-2026.md#git-a-recursive-clone-of-a-malicious-repository-runs-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Git 2.56.1, and the matching updates on the 2.50 through 2.55 lines, close six flaws. The one that runs code is an integer truncation in the index: a very long path passes the check that refuses to overwrite Git's own metadata, and Git then writes it under a shorter name. An attacker-controlled repository can use that to replace a submodule's `.git` file with a link to a directory of hooks, which run during `git clone --recurse-submodules`.

**GitHub rates [CVE-2026-111760](https://www.cve.org/CVERecord?id=CVE-2026-111760) High, CVSS 3.1 8.0** (`CVSS:3.1/AV:N/AC:H/PR:L/UI:R/S:C/C:H/I:H/A:H`). The advisory's patched-versions field says "none" and its text says the patches are being discussed on the git-security list. GitHub's release post, the same day, says the fix is in **2.56.1**, **2.55.1**, **2.54.1**, **2.53.1**, **2.52.1**, **2.51.3**, and **2.50.2**. The workaround in the advisory is to not recursively clone a repository you do not trust. The CVE record was not published when this page was written.

The same releases fix five more. GitLab rates [CVE-2026-105437](https://www.cve.org/CVERecord?id=CVE-2026-105437) CVSS 3.1 7.5 High: a three-way merge of a very large result writes past the buffer it allocated. GitHub describes the other four and does not give them a numeric score: [CVE-2026-113408](https://www.cve.org/CVERecord?id=CVE-2026-113408) writes outside the reference directory from a server's advertised HEAD, [CVE-2026-114467](https://www.cve.org/CVERecord?id=CVE-2026-114467) corrupts the stack when a tag carries more than two signatures, [CVE-2026-114469](https://www.cve.org/CVERecord?id=CVE-2026-114469) reads out of bounds from a binary patch whose uncompressed size is huge, and [CVE-2026-114466](https://www.cve.org/CVERecord?id=CVE-2026-114466) lets a fast-import stream read or create files unless `--allow-unsafe-features` is set. This guide does not treat those four as High. They ship in the same upgrade.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-10) for CVE-2026-111760 or CVE-2026-105437. The CVE records for the other four were not published. GitHub does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-11-10; time/TZ unknown** | GitHub published the six-flaw release note and the CVE-2026-111760 advisory the same day. Git 2.56.1 and the 2.50 through 2.55 updates. [Release][blog] [Advisory][ghsa] |
| CVE-2026-105437 record | 2026-11-10; time/TZ unknown | GitLab, CVSS 3.1 7.5 High. [Record][cve105437] |

## Detection

```sh
git --version
```

- `2.56.1` or later on the 2.56 line is the current fix.
- On an older line, `2.55.1`, `2.54.1`, `2.53.1`, `2.52.1`, `2.51.3`, or `2.50.2` is the fix GitHub names for that line. A 2.49 or older build is outside the list GitHub published. GitHub does not say those older lines are unaffected.
- An application that bundles its own Git, including an IDE, a CI image, or GitHub Desktop, does not use the system `git`. GitHub says Desktop and the Copilot app updates were still being coordinated when the post was written. Read that application's version, not only `git --version`.

Git for Windows is a separate build. This page does not establish whether a Git for Windows installer based on 2.56.1 was published.

## Remediation

1. Upgrade to Git **2.56.1**, or to the patched release on the line you already run: 2.55.1, 2.54.1, 2.53.1, 2.52.1, 2.51.3, or 2.50.2. Upgrade anything that ships its own Git.
2. Until that build is what `git --version` prints, do not clone with `--recurse-submodules` from a source you do not trust. GitHub's advisory says that is the path it believes triggers CVE-2026-111760. Cloning without that flag is not a fix.
3. On GitHub Enterprise Server, GitHub names **3.19.15**, **3.20.11**, **3.21.9**, and **3.22.4**. github.com, Enterprise Cloud, and Enterprise Cloud with data residency already have the fixes, per the same post.
4. The upgrade does not show whether a recursive clone already ran a hook.

## Verification

- `git --version` prints one of the versions in Remediation, and a fresh shell is what prints it.
- A clone of a repository you already trust still works. Do not clone a repository built to trigger the truncation.

## Compromise response

A recursive clone of a repository you do not trust, on a build older than the versions above, is the event to investigate. A hook that ran did so as the user who ran Git, in that clone.

- Look for a `.git` file inside a submodule that is a symbolic link, and for a `hooks` directory it points at.
- If that clone was on a machine that holds credentials, rotate the credentials that user could read, from a different machine. Deleting the clone does not undo a hook that already ran.

## Sources

- [GitHub advisory GHSA-vp2w-7xxj-jvxr][ghsa] — published 2026-11-10 by newren. High, CVSS 3.1 8.0. The patched-versions field says none. The workaround is to avoid `--recurse-submodules` on an untrusted repository.
- [GitHub release post][blog] — 2026-11-10. Fixes in 2.56.1, 2.55.1, 2.54.1, 2.53.1, 2.52.1, 2.51.3, and 2.50.2. Enterprise Server 3.19.15, 3.20.11, 3.21.9, and 3.22.4. Describes the five companion flaws without numeric scores.
- [CVE-2026-105437][cve105437] — GitLab, CVSS 3.1 7.5 High. Heap buffer overflow in the three-way merge.
- [CVE-2026-111760](https://www.cve.org/CVERecord?id=CVE-2026-111760) — the CVE.org URL. No record was published when this page was written.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10, checked 2026-11-10. Neither published CVE is listed.

[ghsa]: https://github.com/git/git/security/advisories/GHSA-vp2w-7xxj-jvxr
[blog]: https://github.blog/open-source/git/git-security-vulnerabilities-announced-7
[cve105437]: https://www.cve.org/CVERecord?id=CVE-2026-105437
