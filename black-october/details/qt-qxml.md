# Qt: a document parsed by QXmlSimpleReader exhausts memory

**Last updated:** 2026-11-22 (America/New_York)

[Main Qt summary](../black-october-2026.md#qt-a-document-parsed-by-qxmlsimplereader-exhausts-memory) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-105925](https://www.cve.org/CVERecord?id=CVE-2026-105925) is in Qt's `QXmlSimpleReader`. The Qt Group is the CNA and rates it **CVSS 4.0 8.2 High**. The vector is `CVSS:4.0/AV:L/AC:L/AT:N/PR:N/UI:P/VC:N/VI:N/VA:H/SC:N/SI:N/SA:H/R:U/U:Green`. A document parsed with `QXmlSimpleReader::parse()` can make the parser allocate without a bound, exhaust memory, and stop the application and possibly the machine it runs on. The person at the computer has to get the application to parse the document. Confidentiality and integrity are not in the impact.

It is in the Qt XML module on Qt 5 and in the Qt 5 Core Compatibility APIs module on Qt 6. Affected: **5.0.0 before 6.8.10**, **6.9.0 before 6.11.3**, and **6.12.0 before 6.12.1**. Everything before 5.0.0 is listed as unknown. The fix is **Qt 6.8.10, 6.11.3, or 6.12.1** or later. The advisory also links patch sets for dev, 6.12, 6.11, and 6.8 LTS. Qt 5 has no new release; the advisory's mitigation is to parse only trusted documents with `QXmlSimpleReader` until a fix is applied.

The Qt Group's blog published two related `QXmlSimpleReader` and codec advisories earlier in the same week. [CVE-2026-97845](https://www.cve.org/CVERecord?id=CVE-2026-97845), published November 12, is uncontrolled recursion and is scored 4.3 Medium. [CVE-2026-103645](https://www.cve.org/CVERecord?id=CVE-2026-103645), published November 13, is an integer overflow scored 1.1 Low and only affects ICU builds. Neither meets the High threshold. Both are fixed in the same 6.8.10 and 6.11.3 releases that fix this one, and 6.12.0 already contains them, so a machine that moves to 6.12.1 picks up all three.

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
| CVE-2026-97845 advisory | 2026-11-12; time/TZ unknown | Uncontrolled recursion in the same class. CVSS 4.0 4.3 Medium. [Qt][97845] |
| CVE-2026-103645 advisory | 2026-11-13; time/TZ unknown | Integer overflow in `QTextCodec`. CVSS 4.0 1.1 Low. ICU builds only. [Qt][103645] |
| **Public announcement** | **2026-11-16; time/TZ unknown** | The Qt Group published the advisory and the CVE record. NVD's published time is 08:16 UTC. [Qt][adv] |
| Distribution trackers | 2026-11-22; time unknown | Ubuntu, Debian, SUSE, and Red Hat now list the CVE. None names a released package. [Ubuntu][ubuntu] |
| **Last updated** | **2026-11-22 (America/New_York)** | The distributions have a tracker and still no package. |

## Detection

Read the Qt version the application actually loads, not the one a package manager happens to list first. `qmake -query QT_VERSION` or the version resource of `Qt6Core` answers for a build that ships its own Qt. A distribution package is not a fix yet. Checked 2026-11-22: Ubuntu marks `qt6-5compat` and `qtbase-opensource-src` Needs evaluation; Debian marks both vulnerable, including unstable; SUSE marks every listed line Affected and the overall status Pending; Red Hat rates it Moderate, CVSS 3.1 5.5, and bug 2574015 was still NEW on 2026-11-17 with no erratum. SUSE and Red Hat rescore the same flaw 5.5. The Qt Group's 8.2 is the score this guide follows.

An application that never calls `QXmlSimpleReader::parse()` does not reach the flaw. Confirm that before treating every Qt install as exposed.

## Remediation

1. Update to **Qt 6.8.10, 6.11.3, or 6.12.1** or later, and ship that build. The advisory's patch archives are the alternative for a tree you compile yourself. Ubuntu, Debian, SUSE, and Red Hat had not shipped a package as of 2026-11-22, so a distribution update does not move the library.
2. On Qt 5, which has no release named here, stop parsing untrusted documents with `QXmlSimpleReader`.
3. The update does not restart a process that already exhausted memory. Restart it.

## Verification

The running build reports 6.8.10, 6.11.3, 6.12.1, or later. Do not feed the parser a document to test it.

## Compromise response

The result is memory exhaustion, not code execution. No source reports exploitation. A process that died this way needs a restart after the update, not a rebuild of the host.

## Sources

- [Qt advisory, CVE-2026-105925][adv] — published 2026-11-16. CVSS 4.0 8.2. Fixed in 6.8.10, 6.11.3, and 6.12.1.
- [CVE-2026-105925](https://www.cve.org/CVERecord?id=CVE-2026-105925) — Qt Group, published 2026-11-16. Same score. Affected 5.0.0 before 6.8.10, 6.9.0 before 6.11.3, 6.12.0 before 6.12.1.
- [Qt advisory, CVE-2026-97845][97845] — published 2026-11-12. CVSS 4.0 4.3 Medium.
- [Qt advisory, CVE-2026-103645][103645] — published 2026-11-13. CVSS 4.0 1.1 Low.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, read 2026-11-22. CVE-2026-105925 is not in it.
- [Ubuntu CVE-2026-105925][ubuntu] — read 2026-11-22. Needs evaluation. No package.
- [Debian security tracker](https://security-tracker.debian.org/tracker/CVE-2026-105925) — read 2026-11-22. Vulnerable in bookworm, trixie, forky, and sid.
- [SUSE CVE-2026-105925](https://www.suse.com/security/cve/CVE-2026-105925.html) — read 2026-11-22. Pending. SUSE's score is CVSS 3.1 5.5.
- [Red Hat CVE-2026-105925](https://access.redhat.com/security/cve/CVE-2026-105925) — read 2026-11-22. Moderate, CVSS 3.1 5.5. No erratum.

[adv]: https://www.qt.io/blog/security-advisory-cve-2026-105925
[ubuntu]: https://ubuntu.com/security/CVE-2026-105925
[97845]: https://www.qt.io/blog/security-advisory-cve-2026-97845
[103645]: https://www.qt.io/blog/security-advisory-cve-2026-103645
