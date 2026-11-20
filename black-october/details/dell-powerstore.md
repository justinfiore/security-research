# Dell PowerStore: a file-service request runs code before login

**Last updated:** 2026-11-20 (America/New_York)

[Main Dell PowerStore summary](../black-october-2026.md#dell-powerstore-a-file-service-request-runs-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Dell rates [DSA-2026-479][dsa] **Critical**. The advisory covers 44 Dell-specific flaws in PowerStoreT OS **5.1.x before 5.1.0.0-2798105**, on the PowerStore T models it lists. Dell rates seven of them **CVSS 3.1 9.8 Critical**, all in the SDNAS file-services layer. The one Dell describes as needing no login and no position inside the network is [CVE-2026-116443](https://www.cve.org/CVERecord?id=CVE-2026-116443): a stack-based buffer overflow in the NAS TFTP service, which Dell says can cause a denial of service or potential code execution. The other 9.8 rows are:

- [CVE-2026-116440](https://www.cve.org/CVERecord?id=CVE-2026-116440), a buffer overflow on the NAS node.
- [CVE-2026-116448](https://www.cve.org/CVERecord?id=CVE-2026-116448) and [CVE-2026-116449](https://www.cve.org/CVERecord?id=CVE-2026-116449), command injection that needs internal network access and runs commands as root.
- [CVE-2026-116439](https://www.cve.org/CVERecord?id=CVE-2026-116439), path traversal that reads, modifies, or deletes files.
- [CVE-2026-116446](https://www.cve.org/CVERecord?id=CVE-2026-116446), an out-of-bounds memory flaw in the NAS NFS service.

Dell also rates [CVE-2026-116441](https://www.cve.org/CVERecord?id=CVE-2026-116441) **9.6**: an out-of-bounds write in the storage-processor interconnect driver that a malicious peer can use to run code. Dell's CNA published the 9.8 records on November 18, including CVE-2026-116443, CVE-2026-116448, and CVE-2026-116449, each fixed before 5.1.0.0-2798105. CVE-2026-116446 lists both that floor and **4.3.1.3-2800620**. CVE-2026-116440 and CVE-2026-116439 were still unpublished on November 19. Revision 3.0, dated November 17, removes CVE-2026-67271 from the advisory because Dell says it was fixed in the previous release. The public record for that CVE is an older SMB/CIFS flaw, fixed before 5.0.0.2-2761110, and it points at DSA-2026-330.

Dell's CNA published three more rows from the same advisory on November 19. [CVE-2026-111509](https://www.cve.org/CVERecord?id=CVE-2026-111509) is **9.1**: a weak random-number generator lets a network attacker decrypt or tamper with NAS SSH and SFTP sessions. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. [CVE-2026-111506](https://www.cve.org/CVERecord?id=CVE-2026-111506) is **8.8**: missing authentication on an adjacent network. Both are in the 5.1 floor. CVE-2026-111506 is also in the 4.3.1.3 row. CVE-2026-111509 is not. The 5.1 and 4.3 build numbers are unchanged.

Revision 4.0, dated November 19, updates the proprietary-code table and does not change the build numbers. Revision 2.0, dated November 17, adds a first fix for the **4.3 LTS** line. **4.3.1.3-2800620** covers a subset, including CVE-2026-116446 and CVE-2026-116440. It does not include CVE-2026-116443, CVE-2026-116448, CVE-2026-116449, CVE-2026-116439, or CVE-2026-116441. Dell says the rest of the 4.3 fixes will ship in later patches. The 5.1 floor is unchanged.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-19) for any CVE in the advisory. Dell does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public advisory** | **2026-10-30; time/TZ unknown** | DSA-2026-479 revision 1.0. Dell's article says last modified 30 Oct 2026. [Advisory][dsa] |
| First CVE records published | 2026-11-13; time unknown | Dell CNA records such as CVE-2026-107524 and CVE-2026-116412. The 9.8 records were still unpublished on November 16. |
| Advisory revision 2.0 | 2026-11-17; time/TZ unknown | Adds PowerStoreT OS 4.3.1.3-2800620 for a subset of the 4.3 LTS flaws. [Advisory][dsa] |
| 9.8 records published | 2026-11-18; time unknown | CVE-2026-116443, CVE-2026-116448, CVE-2026-116449, and CVE-2026-116441. CVE-2026-116440 and CVE-2026-116439 still unpublished on November 19. |
| Advisory revision 4.0 | 2026-11-19; time/TZ unknown | Removes CVE-2026-67271. The build numbers are unchanged. [Advisory][dsa] |
| **Last updated** | **2026-11-20 (America/New_York)** | The 9.8 table no longer lists CVE-2026-67271. |

## Detection

1. Read the PowerStoreT OS version in PowerStore Manager. **5.1.x before 5.1.0.0-2798105** is inside every flaw the advisory lists for that line. **5.1.0.0-2798105 or later** is the build Dell names as the fix for 5.1. **4.3.x before 4.3.1.3-2800620** is inside the subset Dell lists for the 4.3 LTS line. That build does not cover CVE-2026-116443, CVE-2026-116448, CVE-2026-116449, CVE-2026-116439, or CVE-2026-116441. A version on neither line is not what the advisory covers, and Dell does not say those lines are unaffected.
2. The models Dell lists are PowerStore 500T, 1000T, 1200T, 1500, 3000T, 3200Q, 3200T, 5000T, 5200Q, 5200T, 5500, 7000T, 9000T, 9200T, and 9500.
3. TFTP, NFS, and the NAS management path are the services the 9.8 rows name. A firewall log of those services is an indicator to review. Absence of those lines is not a clean bill, and this guide has no log signature from Dell.

## Remediation

1. On the 5.1 line, upgrade PowerStoreT OS to **5.1.0.0-2798105 or later**. On the 4.3 LTS line, install **4.3.1.3-2800620 or later** for the CVEs Dell lists in that row, and plan for the later 4.3 patches Dell says are still to come. 4.3.1.3-2800620 is not a fix for CVE-2026-116443.
2. Until the upgrade, Dell's coverage of the advisory says to limit access to the NAS services, including TFTP and NFS, and to keep the management interface on a network only administrators use. That is a mitigation, not the fix.
3. The upgrade does not show whether a request already ran code or changed a file.

## Verification

- On 5.1, PowerStore Manager reports **5.1.0.0-2798105** or later. On 4.3, it reports **4.3.1.3-2800620** or later, and the CVEs Dell left out of that row are still open. The array has finished the upgrade.
- File shares and volumes that clients use still mount.
- Do not send a TFTP or NFS payload to test the overflow.

## Compromise response

Dell publishes no indicator for these flaws and does not report exploitation. If the NAS services were reachable from an untrusted network before the upgrade, review the array for a file share, a user, or a configuration change the owner did not make. The upgrade does not undo one.

## Sources

- [DSA-2026-479][dsa] — Dell, revision 1.0 dated 2026-10-30. Revision 2.0, 2026-11-17, adds 4.3.1.3-2800620 for a subset of the 4.3 LTS flaws. Revision 4.0, 2026-11-19, removes CVE-2026-67271. Read 2026-11-20. Impact Critical. 5.1 is still fixed in 5.1.0.0-2798105.
- [CVE-2026-116443](https://www.cve.org/CVERecord?id=CVE-2026-116443) — Dell CNA, published 2026-11-18. CVSS 3.1 9.8. Fixed before 5.1.0.0-2798105. Not in the 4.3.1.3 row.
- [CVE-2026-116446](https://www.cve.org/CVERecord?id=CVE-2026-116446) — Dell CNA, published 2026-11-18. CVSS 3.1 9.8. Fixed before 5.1.0.0-2798105 and before 4.3.1.3-2800620.
- [CVE-2026-82156](https://www.cve.org/CVERecord?id=CVE-2026-82156) — Dell CNA, published 2026-11-16. CVSS 3.1 8.8. One of the lower-scored rows.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, released 2026-11-18T19:17:41.0354Z, checked 2026-11-19. None of the advisory's CVEs are listed.

[dsa]: https://www.dell.com/support/kbdoc/en-us/000527640/dsa-2026-479-dell-powerstore-t-security-update-for-multiple-vulnerabilities
