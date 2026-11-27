# Git: a recursive clone of a malicious repository runs code

**Last updated:** 2026-11-27 (America/New_York)

[Main Git summary](../black-october-2026.md#git-a-recursive-clone-of-a-malicious-repository-runs-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Git 2.56.1, and the matching updates on the 2.50 through 2.55 lines, close six flaws. The one that runs code is an integer truncation in the index: a very long path passes the check that refuses to overwrite Git's own metadata, and Git then writes it under a shorter name. An attacker-controlled repository can use that to replace a submodule's `.git` file with a link to a directory of hooks, which run during `git clone --recurse-submodules`.

**GitHub rates [CVE-2026-111760](https://www.cve.org/CVERecord?id=CVE-2026-111760) High.** The advisory now shows **CVSS 3.1 8.3** (`CVSS:3.1/AV:N/AC:H/PR:N/UI:R/S:C/C:H/I:H/A:H`). An earlier reading of the same page showed 8.0 with `PR:L`. GitHub's release post says the fix is in **2.56.1**, **2.55.1**, **2.54.1**, **2.53.1**, **2.52.1**, **2.51.3**, and **2.50.2**. The advisory now says exploitation is not limited to a recursive clone: during a non-recursive clone, a crafted file entry can replace the top-level `.git` directory with a gitfile that points at attacker-controlled metadata, the clone can then fail, and Git recommends `git status`, which can run code through `core.fsmonitor`. Skipping `--recurse-submodules` is not a sufficient workaround. Do not run `git status` in a checkout whose clone failed.

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
| GitLab packages | 2026-11-10; time/TZ unknown | 19.5.4, 19.4.6, and 19.3.8 update the Git bundled with Gitaly. GitLab rates that path Critical: the overflow can run a command in the Gitaly environment. [GitLab][gitlab] |
| GitHub Enterprise Server correction | 2026-11-17; time/TZ unknown | 3.19.16, 3.20.12, 3.21.10, and 3.22.5 carry the Git fixes. The notes for 3.19.15, 3.20.11, 3.21.9, and 3.22.4 say those fixes were incomplete. [3.22.5][ghes] |

## Detection

```sh
git --version
```

- `2.56.1` or later on the 2.56 line is the current fix.
- On an older line, `2.55.1`, `2.54.1`, `2.53.1`, `2.52.1`, `2.51.3`, or `2.50.2` is the fix GitHub names for that line. A 2.49 or older build is outside the list GitHub published. GitHub does not say those older lines are unaffected.
- An application that bundles its own Git, including an IDE, a CI image, or GitHub Desktop, does not use the system `git`. GitHub says Desktop and the Copilot app updates were still being coordinated when the post was written. Read that application's version, not only `git --version`.

Git for Windows **2.56.1** was published on 2026-11-10 at 22:13:20 UTC as a stable release, not a preview. Its notes say it addresses CVE-2026-111760, CVE-2026-113408, CVE-2026-114466, CVE-2026-114467, CVE-2026-114469, and CVE-2026-105437. [Git for Windows 2.56.1](https://github.com/git-for-windows/git/releases/tag/v2.56.1.windows.1)

## Remediation

1. Upgrade to Git **2.56.1**, or to the patched release on the line you already run: 2.55.1, 2.54.1, 2.53.1, 2.52.1, 2.51.3, or 2.50.2. Upgrade anything that ships its own Git.
2. Until that build is what `git --version` prints, do not clone from a source you do not trust, and do not run `git status` in a checkout whose clone failed. GitHub's advisory says skipping `--recurse-submodules` is not a sufficient workaround: a non-recursive clone can still replace the top-level `.git` directory, the clone can fail, and the `git status` Git then recommends can run code through `core.fsmonitor`.
3. On GitHub Enterprise Server, the Git fixes are in **3.19.16**, **3.20.12**, **3.21.10**, and **3.22.5**, released 2026-11-17. GitHub's notes for 3.19.15, 3.20.11, 3.21.9, and 3.22.4, updated that day, say the Git fixes listed for those builds were incomplete. github.com, Enterprise Cloud, and Enterprise Cloud with data residency already have the fixes, per the November 10 post.
4. The upgrade does not show whether a recursive clone already ran a hook.
5. Self-managed GitLab CE and EE from 16.2 before 19.3.8, 19.4 before 19.4.6, and 19.5 before 19.5.4 ship this merge flaw inside Gitaly. Upgrade to **19.5.4, 19.4.6, or 19.3.8**. GitLab.com and GitLab Dedicated already run a patched version. A self-compiled install also has to rebuild the Git that `git.bin_path` points at, or upgrade that Git to 2.56.1. GitLab's package does not replace a Git you installed yourself.

## Verification

- `git --version` prints one of the versions in Remediation, and a fresh shell is what prints it.
- A clone of a repository you already trust still works. Do not clone a repository built to trigger the truncation.

## Compromise response

A recursive clone of a repository you do not trust, on a build older than the versions above, is the event to investigate. A hook that ran did so as the user who ran Git, in that clone.

- Look for a `.git` file inside a submodule that is a symbolic link, and for a `hooks` directory it points at.
- If that clone was on a machine that holds credentials, rotate the credentials that user could read, from a different machine. Deleting the clone does not undo a hook that already ran.

## Sources

- [GitHub advisory GHSA-vp2w-7xxj-jvxr][ghsa] — published 2026-11-10 by newren. High, CVSS 3.1 8.3. Patched in 2.50.2, 2.51.3, 2.52.1, 2.53.1, 2.54.1, 2.55.1, and 2.56.1. Skipping `--recurse-submodules` is not a sufficient workaround.
- [GitHub release post][blog] — 2026-11-10. Fixes in 2.56.1, 2.55.1, 2.54.1, 2.53.1, 2.52.1, 2.51.3, and 2.50.2. The post names Enterprise Server 3.19.15, 3.20.11, 3.21.9, and 3.22.4. The November 17 release notes say those builds were incomplete.
- [GitHub Enterprise Server 3.22.5][ghes] — released 2026-11-17. "This update was previously communicated in the release notes for the last patch release, but had not been fully resolved." The same sentence is on 3.19.16, 3.20.12, and 3.21.10. The 3.22.4 errata, updated 2026-11-17, says the Git fixes are in 3.22.5.
- [CVE-2026-105437][cve105437] — GitLab, CVSS 3.1 7.5 High. Heap buffer overflow in the three-way merge.
- [GitLab 19.5.4][gitlab] — November 10, 2026. The same flaw, inside the Git that Gitaly ships. Fixed in 19.5.4, 19.4.6, and 19.3.8. GitLab's table rates it Critical. Impacted: 16.2 before 19.3.8, 19.4 before 19.4.6, and 19.5 before 19.5.4.
- [CVE-2026-111760](https://www.cve.org/CVERecord?id=CVE-2026-111760) — the CVE.org URL. No record was published when this page was written.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10, checked 2026-11-10. Neither published CVE is listed.

[ghsa]: https://github.com/git/git/security/advisories/GHSA-vp2w-7xxj-jvxr
[blog]: https://github.blog/open-source/git/git-security-vulnerabilities-announced-7
[cve105437]: https://www.cve.org/CVERecord?id=CVE-2026-105437
[gitlab]: https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-5-4-released/
[ghes]: https://docs.github.com/en/enterprise-server@3.22/admin/release-notes#3.22.5
