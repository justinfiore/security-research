# Synology DSM: a login request reads or writes any file

**Last updated:** 2026-11-20 (America/New_York)

[Main Synology summary](../black-october-2026.md#synology-dsm-a-login-request-reads-or-writes-any-file) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

DiskStation Manager is the operating system on a Synology NAS. Three advisories now apply, and the floors are not the same.

[CVE-2026-120382](https://www.cve.org/CVERecord?id=CVE-2026-120382) is in the OAuth API. Synology-SA-26:21, published 2026-11-19, says a remote attacker who is not logged in can read or write arbitrary files and cause a denial of service. **Synology rates it CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Synology is the CNA. The status is Ongoing. Revision 2, dated 2026-11-20, marks the DSM 7.4 and 7.3 builds as available: **7.4.1-90080-2** and **7.3.2-86009-6**. DSM 7.2.2, 7.2.1, and 7.1 stay Ongoing, and Synology recommends moving 7.2.2 and 7.2.1 to 7.3.2-86009-6. BeeStation OS 1.5 has none yet. The detail line also names floors on 6.2.4, 7.1.1, 7.2.1, and 7.2.2. The product table is what says whether a build exists, and for 7.2 and 7.1 it still says Ongoing. Synology's mitigation is to deactivate the OAuth Service package. The November 10 builds, including 7.4.1-90080-1, are below this floor.

[CVE-2026-76954](https://www.cve.org/CVERecord?id=CVE-2026-76954) is SQL injection in the Auth API: a remote attacker who is not logged in can read or write arbitrary files and cause a denial of service. [CVE-2026-85101](https://www.cve.org/CVERecord?id=CVE-2026-85101) is an authentication bypass in rsync: a remote attacker who is not logged in can read specific files, write arbitrary files, and cause a limited denial of service. Synology-SA-26:19 lists no mitigation for those two.

**Synology rates CVE-2026-76954 CVSS 3.1 9.8 Critical and CVE-2026-85101 CVSS 3.1 8.6 Important.** The vectors are `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H` and `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:H/A:L`. Synology is the CNA for both. Both CVE.org records were published on 2026-11-12 with those same scores and the same fixed builds. The advisory's severity for every listed DSM line is Critical.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-20) for CVE-2026-120382, CVE-2026-76954, or CVE-2026-85101. [CVE-2024-10441](https://www.cve.org/CVERecord?id=CVE-2024-10441) is listed under [the September guide](synology-dsm.md) and is not one of these three. Synology does not report exploitation of the three. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

This is not [the September pair](synology-dsm.md), CVE-2026-13639 and CVE-2026-13684, and it is not the Plex package in [Synology-SA-26:17](plex2shell.md). A DSM build that fixed those is still inside this one. The November 10 builds fix the Auth and rsync flaws and leave the OAuth flaw in place.

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
| CVE records published | 2026-11-12 03:40:28 UTC and 2026-11-12 03:41:52 UTC | Synology CNA. Same scores, descriptions, and fixed builds as the advisory. [CVE-2026-85101][cve85101] [CVE-2026-76954][cve76954] |
| **OAuth advisory** | **2026-11-19 15:47:20 UTC+8** | Synology-SA-26:21, revision 1. CVE-2026-120382, CVSS 3.1 9.8. Status Ongoing. The 7.4 and 7.3 builds were scheduled and not out. [Advisory][sa2621] |
| **OAuth builds available** | **2026-11-20 16:25:36 UTC+8** | Revision 2. DSM 7.4 and 7.3 are now "upgrade to" 7.4.1-90080-2 and 7.3.2-86009-6. DSM 7.2, 7.1, and BeeStation OS 1.5 stay Ongoing. |
| **Last updated** | **2026-11-20 (America/New_York)** | The 7.4 and 7.3 builds shipped. The other branches still have none. |

## Detection

1. In DSM, open **Control Panel > Update & Restore > DSM Update** and read the running build, or run `cat /etc.defaults/VERSION` over SSH. The fields are `productversion` and `buildnumber` with `smallfixnumber`.
2. Compare that build with both floors. The November 10 floor closes the Auth and rsync flaws. The OAuth floor is higher, and revision 2 of SA-26:21 marks the 7.4 and 7.3 builds available:

   | Branch | Auth and rsync (SA-26:19) | OAuth (SA-26:21) |
   |---|---|---|
   | DSM 7.4 | 7.4.1-90080-1 | 7.4.1-90080-2 or above, available 2026-11-20 |
   | DSM 7.3 | 7.3.2-86009-5 | 7.3.2-86009-6 or above, available 2026-11-20 |
   | DSM 7.2.2 | 7.2.2-72806-10 | none; Synology says move to 7.3.2-86009-6 |
   | DSM 7.2.1 | 7.2.1-69057-13 | none; Synology says move to 7.3.2-86009-6 |
   | DSM 7.1 and BeeStation OS 1.5 | not in SA-26:19 | Ongoing, no build |

3. DSM older than 7.2.1 is not in the November 10 advisory. SA-26:21 does name 7.1, and marks it Ongoing. Treat a branch the advisory does not list as unknown and move it onto a supported branch.
4. Note whether DSM's web ports (5000 and 5001) or the rsync port (873) are reachable from the internet. The rsync flaw is the second CVE, so a NAS that does not publish the web UI can still be inside it. The OAuth flaw is the package, not the port: check whether OAuth Service is installed.

The update does not show whether a file was already read or written. Synology publishes no indicator for this advisory.

## Remediation

1. For the OAuth flaw, install **7.4.1-90080-2** or **7.3.2-86009-6** or above and reboot. Revision 2 of SA-26:21, dated 2026-11-20, marks both available. Do not install 7.4.1-90080-1 or 7.3.2-86009-5 and stop. DSM 7.2.2 and 7.2.1 have no OAuth build; Synology says to move to 7.3.2-86009-6. DSM 7.1 and BeeStation OS 1.5 have none yet.
2. Until that build is running, deactivate the OAuth Service package. That is Synology's mitigation for CVE-2026-120382, and it is still the only step on a branch with no build. It does not close the Auth or rsync flaws.
3. For those two, upgrade to **7.4.1-90080-1**, **7.3.2-86009-5**, **7.2.2-72806-10**, or **7.2.1-69057-13** or later. Synology lists no mitigation. Until a fixed build is running, do not leave DSM or rsync reachable from the internet.
4. These floors are above the September floors (7.4-90075, 7.3.2-86009-4, 7.2.2-72806-9, 7.2.1-69057-12). The September build leaves all three of these in place. The November 10 build leaves the OAuth flaw in place.

## Verification

- **Control Panel > Update & Restore** shows a build at or above the floor for that branch, and the NAS has rebooted into it.
- DSM and rsync are not reachable from the internet, or they are and the build is fixed.
- A user who could sign in before the update can still sign in. Do not send a crafted login request to test the check.

## Compromise response

Synology does not describe what a successful request leaves behind, so there is no file or account to look for. If the NAS was reachable from the internet while it was below the floor, review the shared folders for files you did not put there and accounts you did not create, and rotate credentials the NAS could reach, including the backup destinations it writes to. Installing the update does not undo a file that was already written.

## Sources

- [Synology-SA-26:19][sa2619] — published 2026-11-10 17:06:42 UTC+8. Severity Critical. CVE-2026-76954 is 9.8 in the Auth API. CVE-2026-85101 is 8.6 in rsync. Fixed builds and no mitigation are in this advisory.
- [CVE-2026-76954][cve76954] and [CVE-2026-85101][cve85101] — published by Synology on 2026-11-12. CVE-2026-76954 is CWE-89, CVSS 3.1 9.8. CVE-2026-85101 is CWE-288, CVSS 3.1 8.6. The version ranges match the advisory.
- [Synology-SA-26:21][sa2621] — published 2026-11-19 15:47:20 UTC+8, revision 2 at 2026-11-20 16:25:36 UTC+8. Status Ongoing. CVE-2026-120382 is CVSS 3.1 9.8 in the OAuth API. DSM 7.4 and 7.3 now say upgrade to 7.4.1-90080-2 and 7.3.2-86009-6. DSM 7.2, 7.1, and BeeStation OS 1.5 stay Ongoing. Mitigation: deactivate the OAuth Service package.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-20. None of the three CVEs is listed.

[sa2619]: https://www.synology.com/en-global/security/advisory/Synology_SA_26_19
[sa2621]: https://www.synology.com/en-global/security/advisory/Synology_SA_26_21
[cve76954]: https://www.cve.org/CVERecord?id=CVE-2026-76954
[cve85101]: https://www.cve.org/CVERecord?id=CVE-2026-85101
