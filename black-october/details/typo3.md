# TYPO3: a marker file reopens the installer

**Last updated:** 2026-11-18 (America/New_York)

[Main TYPO3 summary](../black-october-2026.md#typo3-a-marker-file-reopens-the-installer) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-119623](https://www.cve.org/CVERecord?id=CVE-2026-119623) lets a file whose name starts with `FIRST_INSTALL` reopen TYPO3's first-install wizard on a site that is already configured. The wizard has no login. TYPO3 rates it **Critical**. The suggested vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`, which scores **9.4**. TYPO3 is the CNA. NVD has not scored it.

The same November 17 release fixes nine more advisories. Two of them are the practical way the marker file gets created: a low-privileged backend user can write it through online media, and the Import/Export module can write a file from an import. Both are High. Five of the ten are below 7.0 and are named in Sources so a reader does not treat the release as one flaw.

**CISA KEV:** Not listed (catalog 2026.11.17, checked 2026-11-18). TYPO3 does not report exploitation of CVE-2026-119623. [TYPO3-CORE-SA-2026-029](https://news.typo3.com/security/advisory/typo3-core-sa-2026-029), a Form Framework information disclosure rated below 7.0, says that issue is known to be exploited. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-17; time unknown** | TYPO3-CORE-SA-2026-027. Affected 10.0.0–10.4.62, 11.0.0–11.5.56, 12.0.0–12.4.51, 13.0.0–13.4.39, 14.0.0–14.3.11. [TYPO3][sa027] |
| Fixed releases | 2026-11-17; time unknown | 14.3.12 LTS, 13.4.40 LTS, 12.4.52 ELTS, 11.5.57 ELTS, 10.4.63 ELTS. [TYPO3][sa027] |
| **Last updated** | **2026-11-18 (America/New_York)** | New item. Update TYPO3. |

## Detection

Read the installed version from the project root. Do not run this on a host you suspect is compromised; read `composer.lock` from a snapshot instead.

```sh
composer show typo3/cms-core --format=json
find . -maxdepth 2 -iname 'FIRST_INSTALL*' -print
```

| Line | Affected | Fixed |
|---|---|---|
| 14 LTS | 14.0.0–14.3.11 | 14.3.12 |
| 13 LTS | 13.0.0–13.4.39 | 13.4.40 |
| 12 ELTS | 12.0.0–12.4.51 | 12.4.52 |
| 11 ELTS | 11.0.0–11.5.56 | 11.5.57 |
| 10 ELTS | 10.0.0–10.4.62 | 10.4.63 |

A site with no `FIRST_INSTALL` file is not known to be safe: the companion flaw lets a backend user create one. A site that does not run TYPO3 is outside this entry. 12.4, 11.5, and 10.4 fixes are extended long-term support.

## Remediation

1. Update every `typo3/cms-*` package to **14.3.12, 13.4.40, 12.4.52, 11.5.57, or 10.4.63** on the line you run.
2. Flush caches and run the install tool's upgrade wizard.
3. Delete every file whose name starts with `FIRST_INSTALL` from the public web root and the project root. The fixed code accepts only the exact names `FIRST_INSTALL` and `FIRST_INSTALL.txt`, and only during a real installation.
4. Review backend users with administrator or system-maintainer rights for accounts you do not recognize.
5. Blocking `/typo3/install.php` removes the wizard and does not fix the file-write flaws in the same release.

## Verification

- `composer show typo3/cms-core` reports the fixed version for that line.
- `find` prints no `FIRST_INSTALL` file.
- Load the public home page. Do not place a marker file to test the wizard.

## Compromise response

TYPO3 tells administrators to review administrator and system-maintainer accounts. An account you cannot account for, or a database connection you did not set, is the thing the wizard can change. The update does not remove either. The Form Framework advisory in the same release says its own issue is already exploited; that is a different flaw and a different check.

## Sources

- [TYPO3-CORE-SA-2026-027][sa027] — November 17, 2026. Critical. CVE-2026-119623. A `FIRST_INSTALL*` file reopens the installer without authentication.
- [TYPO3-CORE-SA-2026-026](https://news.typo3.com/security/advisory/typo3-core-sa-2026-026) — CVE-2026-119622, High. A low-privileged backend user can create the marker file.
- [TYPO3-CORE-SA-2026-025](https://news.typo3.com/security/advisory/typo3-core-sa-2026-025) — CVE-2026-119621, High. Import/Export path traversal.
- [TYPO3-CORE-SA-2026-028](https://news.typo3.com/security/advisory/typo3-core-sa-2026-028) — CVE-2026-125159, High. Image processing information disclosure.
- [TYPO3-CORE-SA-2026-031](https://news.typo3.com/security/advisory/typo3-core-sa-2026-031) — CVE-2026-125162, High. Cache flooding.
- [TYPO3-CORE-SA-2026-029](https://news.typo3.com/security/advisory/typo3-core-sa-2026-029) — CVE-2026-125160. TYPO3 says this Form Framework issue is known to be exploited. It is below 7.0.
- [CVE-2026-119623](https://www.cve.org/CVERecord?id=CVE-2026-119623) — CNA TYPO3. Published 2026-11-17.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.17, read 2026-11-18. CVE-2026-119623 is not in it.

[sa027]: https://news.typo3.com/security/advisory/typo3-core-sa-2026-027
