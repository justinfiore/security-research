# macOS: a different spelling of a file name passes a deny rule

**Last updated:** 2026-11-26 (America/New_York)

[Main macOS summary](../black-october-2026.md#macos-a-different-spelling-of-a-file-name-passes-a-deny-rule) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

CERT/CC published [VU#604762][vu] on November 16. On macOS, APFS treats two different spellings of a name as one file: a German `ß` and `ss`, an accented letter and the same letter plus a combining accent, and, on a default volume, different case. Tools that compare the bytes of the name do not. A rule written one way misses the other spelling, and the kernel then opens the file the rule was meant to protect.

The one constituent CERT/CC's note and a vendor both score at 7.0 or higher is [CVE-2026-49401](https://www.cve.org/CVERecord?id=CVE-2026-49401). Deno rates it **CVSS 3.1 7.3 High** (`CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:C/C:L/I:H/A:N`). A program running with a broad allow and a `--deny-read`, `--deny-write`, `--deny-run`, or `--deny-ffi` carve-out can reach the denied path by spelling it differently. Deno says Linux and Windows are not affected. The fix is **Deno 2.7.14**.

The same note lists three more, and none of them meets that bar on its own:

- [CVE-2026-59890](https://www.cve.org/CVERecord?id=CVE-2026-59890), setuptools, CVSS 3.1 **6.1 Medium**. A `MANIFEST.in` exclusion misses an NFD name, so a source distribution can pack a file the maintainer meant to leave out. Fixed in **setuptools 83.0.0**.
- [CVE-2026-14978](https://www.cve.org/CVERecord?id=CVE-2026-14978), HashiCorp go-slug, CVSS 3.1 **5.5 Medium**. A `.terraformignore` exclusion misses, and a slug upload includes the file. Affected **before 0.18.3**. HashiCorp's advisory, published August 24, says **0.18.3** is the fix. The CVE record names 0.4.0 through 0.18.2 and does not name the fix.
- [CVE-2026-45110](https://www.cve.org/CVERecord?id=CVE-2026-45110), libarchive. No score is published. The finder says `bsdtar --exclude` misses the other spelling and the extraction replaces the file, inside the output directory, with no privilege gain. The fix is [PR #3359](https://github.com/libarchive/libarchive/pull/3359), still open. CERT/CC's November 17 revision says the fix is pending release. The CVE record was not published on November 16.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-17) for CVE-2026-49401, CVE-2026-59890, or CVE-2026-14978. CVE-2026-45110 has no published record to match. CERT/CC does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Deno advisory | 2026-05-27; time/TZ unknown | GHSA-8xpq-cjcf-3wh9. Fixed in 2.7.14. [Advisory][deno] |
| setuptools advisory | 2026-07-04; time/TZ unknown | GHSA-h35f-9h28-mq5c. Fixed in 83.0.0. [Advisory][setup] |
| **Public announcement** | **2026-11-16; last revised 16:17 UTC** | CERT/CC VU#604762, date public 2026-11-16. [Note][vu] |
| **CERT/CC revision 3** | **2026-11-17 17:12 UTC** | The libarchive fix is pending release. The note also names yarn CVE-2026-11313; that advisory page is not published. [VU#604762][vu] |
| **Last updated** | **2026-11-26 (America/New_York)** | go-slug 0.18.3 is the fix. libarchive still has no release. |

## Detection

1. On a Mac, `deno --version` below **2.7.14** is inside CVE-2026-49401. A Deno install on Linux or Windows is outside it, per Deno.
2. The bypass needs a `--deny-*` rule whose path is not plain ASCII, or a rule that depends on case, and code you do not fully trust running under a broad `--allow-*`. A Mac that runs only trusted code is not the case Deno describes.
3. `python3 -m setuptools --version` below **83.0.0** is inside CVE-2026-59890, and only matters for a source distribution built on macOS.
4. `bsdtar --version` on macOS does not show whether the libarchive fix has landed. CERT/CC said on November 17 that the fix is pending release, and the pull request is still open, so treat the system `bsdtar` as unfixed.
5. A Go module that requires `github.com/hashicorp/go-slug` before **0.18.3** is inside CVE-2026-14978. The check is the module requirement, not the macOS version.

## Remediation

1. Update Deno to **2.7.14 or later** on every Mac that uses `--deny-read`, `--deny-write`, `--deny-run`, or `--deny-ffi` as a boundary. Deno says an allowlist is safer than a denylist until then.
2. Update setuptools to **83.0.0 or later** before building a source distribution on macOS.
3. libarchive has no release that contains the fix. CERT/CC said on November 17 that it is pending release. Until a release contains it, do not rely on `bsdtar --exclude` to keep a non-ASCII name out of an extraction from an archive you do not trust.
4. Upgrade `github.com/hashicorp/go-slug` to **0.18.3 or later** and rebuild. HashiCorp's advisory says 0.18.3 fixes CVE-2026-14978. 0.18.2 leaves it in place.
5. None of the updates shows whether a file was already read or replaced.

## Verification

- `deno --version` reports **2.7.14** or later.
- A build environment on macOS reports setuptools **83.0.0** or later.
- Do not build an archive to test the bypass.

## Compromise response

Neither CERT/CC nor Deno publishes an indicator. If a Mac ran untrusted Deno code against a `--deny-*` rule before 2.7.14, review the files that rule named. The update does not show whether one was read or written.

## Sources

- [VU#604762][vu] — CERT/CC, date public 2026-11-16, last revised 2026-11-17 17:12 UTC, revision 3. The libarchive fix is pending release. The addendum names yarn CVE-2026-11313; that advisory URL returned 404 on 2026-11-26.
- [GHSA-8xpq-cjcf-3wh9][deno] — Deno, published 2026-05-27. CVSS 3.1 7.3. Fixed in 2.7.14. macOS only.
- [CVE-2026-49401](https://www.cve.org/CVERecord?id=CVE-2026-49401) — published 2026-06-23. Same score and range.
- [GHSA-h35f-9h28-mq5c][setup] — setuptools, published 2026-07-04. CVSS 3.1 6.1. Fixed in 83.0.0.
- [CVE-2026-14978](https://www.cve.org/CVERecord?id=CVE-2026-14978) — HashiCorp, published 2026-08-19. CVSS 3.1 5.5. go-slug 0.4.0 through 0.18.2. The record names no fixed version.
- [GHSA-vvjm-v4gp-jj5c](https://github.com/hashicorp/go-slug/security/advisories/GHSA-vvjm-v4gp-jj5c) — HashiCorp, published 2026-08-24. Moderate, CVSS 3.1 5.5. Patched in go-slug 0.18.3.
- [CVE-2026-45110 write-up](https://github.com/tomasilluminati/security-research/blob/main/CVE-2026-45110/README.md) — the finder, read 2026-11-16. No score. Fix in review as of November 15. Tested on macOS `bsdtar` 3.5.3 (libarchive 3.7.4).
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, checked 2026-11-17. None of the published CVEs is listed.

[vu]: https://kb.cert.org/vuls/id/604762
[deno]: https://github.com/denoland/deno/security/advisories/GHSA-8xpq-cjcf-3wh9
[setup]: https://github.com/pypa/setuptools/security/advisories/GHSA-h35f-9h28-mq5c
