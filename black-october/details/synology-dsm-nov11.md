# Synology DSM: a login request reads or writes any file

**Last updated:** 2026-11-11 (America/New_York)

[Main Synology summary](../black-october-2026.md#synology-dsm-a-login-request-reads-or-writes-any-file) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

DiskStation Manager is the operating system on a Synology NAS. Synology-SA-26:19 fixes two flaws in it. [CVE-2026-76954](https://www.cve.org/CVERecord?id=CVE-2026-76954) is SQL injection in the Auth API: a remote attacker who is not logged in can read or write arbitrary files and cause a denial of service. [CVE-2026-85101](https://www.cve.org/CVERecord?id=CVE-2026-85101) is an authentication bypass in rsync: a remote attacker who is not logged in can read specific files, write arbitrary files, and cause a limited denial of service. Synology lists no mitigation.

**Synology rates CVE-2026-76954 CVSS 3.1 9.8 Critical and CVE-2026-85101 CVSS 3.1 8.6 Important.** The vectors are `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H` and `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:H/A:L`. Synology is the CNA for both, and both CVE.org records were still Reserved when this was written, so the scores and the descriptions come from the advisory. The advisory's severity for every listed DSM line is Critical.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-11). Synology does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

This is not [the September pair](synology-dsm.md), CVE-2026-13639 and CVE-2026-13684, and it is not the Plex package in [Synology-SA-26:17](plex2shell.md). A DSM build that fixed those is still inside this one.

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
| **Public announcement and fix** | **2026-11-10 17:06:42 UTC+8** | Synology-SA-26:19, revision 1. Severity Critical. No mitigation. [Advisory][sa2619] |
| CVE records | Reserved as of 2026-11-11 | CVE.org shows both IDs reserved by a CNA. The advisory is the description and the score. [CVE-2026-76954][cve76954] [CVE-2026-85101][cve85101] |

## Detection

1. In DSM, open **Control Panel > Update & Restore > DSM Update** and read the running build, or run `cat /etc.defaults/VERSION` over SSH. The fields are `productversion` and `buildnumber` with `smallfixnumber`.
2. Compare that build with the floor for its branch. A build below the floor is inside both flaws:

   | Branch | First fixed build |
   |---|---|
   | DSM 7.4 | 7.4.1-90080-1 |
   | DSM 7.3 | 7.3.2-86009-5 |
   | DSM 7.2.2 | 7.2.2-72806-10 |
   | DSM 7.2.1 | 7.2.1-69057-13 |

3. DSM older than 7.2.1 is not in the advisory. The advisory does not say those branches are unaffected, so treat them as unknown and move them onto a supported branch.
4. Note whether DSM's web ports (5000 and 5001) or the rsync port (873) are reachable from the internet. The rsync flaw is the second CVE, so a NAS that does not publish the web UI can still be inside it.

The update does not show whether a file was already read or written. Synology publishes no indicator for this advisory.

## Remediation

1. Upgrade DSM to the fixed build for the installed branch, or later: **7.4.1-90080-1**, **7.3.2-86009-5**, **7.2.2-72806-10**, or **7.2.1-69057-13**. Reboot when DSM asks, and confirm the running build afterward.
2. Synology lists no mitigation. Until the fixed build is running, do not leave DSM or rsync reachable from the internet.
3. These floors are above the September floors (7.4-90075, 7.3.2-86009-4, 7.2.2-72806-9, 7.2.1-69057-12). One update covers both advisories. Do not stop at the September build.

## Verification

- **Control Panel > Update & Restore** shows a build at or above the floor for that branch, and the NAS has rebooted into it.
- DSM and rsync are not reachable from the internet, or they are and the build is fixed.
- A user who could sign in before the update can still sign in. Do not send a crafted login request to test the check.

## Compromise response

Synology does not describe what a successful request leaves behind, so there is no file or account to look for. If the NAS was reachable from the internet while it was below the floor, review the shared folders for files you did not put there and accounts you did not create, and rotate credentials the NAS could reach, including the backup destinations it writes to. Installing the update does not undo a file that was already written.

## Sources

- [Synology-SA-26:19][sa2619] — published 2026-11-10 17:06:42 UTC+8. Severity Critical. CVE-2026-76954 is 9.8 in the Auth API. CVE-2026-85101 is 8.6 in rsync. Fixed builds and no mitigation are in this advisory.
- [CVE-2026-76954][cve76954] and [CVE-2026-85101][cve85101] — both Reserved on CVE.org as of 2026-11-11. The advisory is the source of the description and the score.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10, checked 2026-11-11. Neither CVE is listed.

[sa2619]: https://www.synology.com/en-global/security/advisory/Synology_SA_26_19
[cve76954]: https://www.cve.org/CVERecord?id=CVE-2026-76954
[cve85101]: https://www.cve.org/CVERecord?id=CVE-2026-85101
