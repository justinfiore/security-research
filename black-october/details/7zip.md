# 7-Zip: a padded file name hides the real extension

**Last updated:** 2026-11-17 (America/New_York)

[Main 7-Zip summary](../black-october-2026.md#7-zip-a-padded-file-name-hides-the-real-extension) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

VulnCheck rates [CVE-2026-130067](https://www.cve.org/CVERecord?id=CVE-2026-130067) **CVSS 4.0 8.5 High** and **CVSS 3.1 7.8 High**. VulnCheck is the CNA. The 4.0 vector is `CVSS:4.0/AV:L/AC:L/AT:N/PR:N/UI:P/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The 3.1 vector is `CVSS:3.1/AV:L/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`. NVD had not scored it on November 17.

7-Zip File Manager before **26.03** does not treat Unicode space characters as padding when it decides whether an archive entry's name is deceptive. `CPanel::IsVirus_Message` is the check. An entry whose name looks like a PDF, then ideographic spaces, then `.hta`, gets past the warning. Opening it runs the script through `ShellExecuteExW`. The person at the computer has to open the entry. The command-line unpacker is not what the record describes.

The finder is Dhanush Arvind of Intercontinental Exchange. The fix is commit [`0766b73`](https://github.com/ip7z/7zip/commit/0766b733fe3e06dd2a7f9a3cfbf2108ac73abd17), dated 2026-09-04, and the 26.03 release the same day. 7-Zip's own history names 26.03 on 2026-09-03 and does not mention this CVE. It does name [CVE-2026-58052](https://www.cve.org/CVERecord?id=CVE-2026-58052) in that release: 7-Zip failed to preserve Mark-of-the-Web when extracting a crafted archive. The current release is **26.06**, published 2026-11-06, whose history says "some bugs and vulnerabilities were fixed" and names none.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-17). VulnCheck does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix commit | 2026-09-04 07:17:40 UTC | Commit `0766b73`, message "26.03". [Commit][commit] |
| 7-Zip 26.03 | 2026-09-04 07:34:42 UTC | GitHub release. The history file dates it 2026-09-03 and names CVE-2026-58052, not this one. [Release][rel] |
| 7-Zip 26.06 | 2026-11-06; time/TZ unknown | History file. "Some bugs and vulnerabilities were fixed." No CVE named. [History][hist] |
| **Public announcement** | **2026-11-16; time unknown** | VulnCheck published the CVE record. |
| **Last updated** | **2026-11-17 (America/New_York)** | New item. Update 7-Zip. |

## Detection

1. In 7-Zip File Manager, Help, About. **Before 26.03** is the range the record calls affected. **26.03 or later** contains the fix. 26.06 is the newest release this run found.
2. The flaw is in the File Manager's open warning, on Windows, where `ShellExecuteExW` runs the entry. A Linux or command-line-only install is not what the record describes.
3. An archive whose entry name contains a run of ideographic spaces before a script extension is the shape the record describes. Finding one is a reason to treat the machine as exposed. Not finding one is not a clean bill.

## Remediation

1. Install **7-Zip 26.03 or later**. 26.06, dated 2026-11-06, is the newest release the history file lists, and it is the one to install.
2. Until the update, do not open an archive entry from 7-Zip File Manager when the name contains a long run of spaces. Extract it and read the real extension first.
3. The update does not show whether an entry was already opened.

## Verification

- Help, About reports 26.03 or later. 26.06 satisfies that.
- Do not open a crafted archive to test the warning.

## Compromise response

VulnCheck publishes no indicator and does not report exploitation. If a File Manager before 26.03 opened an archive from an untrusted sender, review what ran afterward. The update does not remove a script that already ran.

## Sources

- [CVE-2026-130067](https://www.cve.org/CVERecord?id=CVE-2026-130067) — VulnCheck, published 2026-11-16. CVSS 4.0 8.5 and CVSS 3.1 7.8. 7-Zip File Manager before 26.03. Finder: Dhanush Arvind, Intercontinental Exchange.
- [Commit 0766b73][commit] — 2026-09-04 07:17:40 UTC. The record lists it as the patch.
- [7-Zip 26.03][rel] — published 2026-09-04 07:34:42 UTC. Names CVE-2026-58052, not CVE-2026-130067.
- [7-Zip history][hist] — read 2026-11-17. 26.03 dated 2026-09-03, 26.06 dated 2026-11-06.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, checked 2026-11-17. Not listed.

[commit]: https://github.com/ip7z/7zip/commit/0766b733fe3e06dd2a7f9a3cfbf2108ac73abd17
[rel]: https://github.com/ip7z/7zip/releases/tag/26.03
[hist]: https://www.7-zip.org/history.txt
