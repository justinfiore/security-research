# Emacs: a project file runs code when a file opens

**Last updated:** 2026-11-19 (America/New_York)

[Main Emacs summary](../black-october-2026.md#emacs-a-project-file-runs-code-when-a-file-opens) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-131959](https://www.cve.org/CVERecord?id=CVE-2026-131959) is a missing check in GNU Emacs 31.1. MITRE is the CNA and rates it **CVSS 3.1 7.8 High**. The vector is `CVSS:3.1/AV:L/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`. A project can ship a `.dir-locals.el` that adds an entry to `auto-mode-alist`. When a matching file is opened, Emacs calls the function in that entry before it checks whether the function is a real mode. The reporter, X3r0Day, showed it running a shell command with no prompt. Emacs 30.2 and older do not have the early call and are not affected. The GNU project marked the bug fixed in **31.2** on November 11, 2026, and 31.2 had not been released when this page was written. Until then, `(setq enable-dir-local-variables nil)` stops the check and also stops legitimate directory-local variables.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-19). The GNU mail does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported | 2026-11-10 15:55:02 UTC | Bug 82213, sent privately first. [Bug][bug] |
| Fix committed and announced | 2026-11-11 09:40:30 UTC | Sean Whitton to oss-security: the patch will be in 31.2. Emacs 30.2 is unaffected. |
| Marked fixed | 2026-11-11 10:15:28 UTC | "Version: 31.2. Fixed on the release branch." |
| **Public CVE record** | **2026-11-18; time unknown** | MITRE, CVSS 3.1 7.8. Affected at 31.1. [Record][cve] |
| Canadian notice | 2026-11-18; time/TZ unknown | AV26-1173 says Emacs prior to 31.2. [AV26-1173][ccc] |

## Detection

`emacs --version` prints 31.1 on an affected build. Emacs 30.2 and older are outside the record. A build that reports a commit on the emacs-31 release branch after November 11, 2026, may already have the patch and still print a version before 31.2. The version number alone does not show that.

## Remediation

1. Install Emacs **31.2 or later** when the GNU project releases it. The bug tracker says the fix is on the release branch and names no tarball.
2. Until that build is what `emacs --version` prints, a project you do not trust should be opened with directory-local variables off: `(setq enable-dir-local-variables nil)`. That also turns off the legitimate uses of `.dir-locals.el`.
3. Opening the file is the action. A clone that nobody has opened in Emacs has not reached the check.

## Verification

- `emacs --version` prints 31.2 or later, or the build is one the distributor says contains the November 11 patch.
- Do not open a file in a directory built to test the bypass.

## Compromise response

The GNU mail does not report exploitation. A `.dir-locals.el` that names a function other than a mode, in a repository you did not write, is the file to look at. Emacs runs it as the user who opened the file. The setting does not show whether a file was already opened.

## Sources

- [CVE-2026-131959][cve] — MITRE, published 2026-11-18. CVSS 3.1 7.8. Affected at Emacs 31.1. Emacs 30.2 is unaffected.
- [GNU bug 82213][bug] — reported 2026-11-10, fixed in version 31.2 on 2026-11-11. The workaround is `enable-dir-local-variables` set to nil.
- [Canadian Centre AV26-1173][ccc] — November 18, 2026. Emacs prior to 31.2.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-19. CVE-2026-131959 is not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-131959
[bug]: https://debbugs.gnu.org/cgi/bugreport.cgi?bug=82213
[ccc]: https://www.cyber.gc.ca/en/alerts-advisories/gnu-security-advisory-av26-1173
