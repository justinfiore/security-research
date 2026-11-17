# Dell PowerStore: a file-service request runs code before login

**Last updated:** 2026-11-16 (America/New_York)

[Main Dell PowerStore summary](../black-october-2026.md#dell-powerstore-a-file-service-request-runs-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Dell rates [DSA-2026-479][dsa] **Critical**. The advisory covers 44 Dell-specific flaws in PowerStoreT OS **5.1.x before 5.1.0.0-2798105**, on the PowerStore T models it lists. Dell rates seven of them **CVSS 3.1 9.8 Critical**, all in the SDNAS file-services layer. The one Dell describes as needing no login and no position inside the network is [CVE-2026-116443](https://www.cve.org/CVERecord?id=CVE-2026-116443): a stack-based buffer overflow in the NAS TFTP service, which Dell says can cause a denial of service or potential code execution. The other 9.8 rows are:

- [CVE-2026-116440](https://www.cve.org/CVERecord?id=CVE-2026-116440), a buffer overflow on the NAS node.
- [CVE-2026-116448](https://www.cve.org/CVERecord?id=CVE-2026-116448) and [CVE-2026-116449](https://www.cve.org/CVERecord?id=CVE-2026-116449), command injection that needs internal network access and runs commands as root.
- [CVE-2026-116439](https://www.cve.org/CVERecord?id=CVE-2026-116439), path traversal that reads, modifies, or deletes files.
- [CVE-2026-116446](https://www.cve.org/CVERecord?id=CVE-2026-116446), an out-of-bounds memory flaw in the NAS NFS service.
- [CVE-2026-67271](https://www.cve.org/CVERecord?id=CVE-2026-67271), an out-of-bounds read that can take the file service down.

Dell also rates [CVE-2026-116441](https://www.cve.org/CVERecord?id=CVE-2026-116441) **9.6**: an out-of-bounds write in the storage-processor interconnect driver that a malicious peer can use to run code. The CVE Program had published some of the lower-scored records by November 16, including [CVE-2026-82156](https://www.cve.org/CVERecord?id=CVE-2026-82156) at 8.8. The 9.8 records were not published yet, so the scores above are Dell's, from the advisory. NVD had not scored them.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-17) for any CVE in the advisory. Dell does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Last updated** | **2026-11-16 (America/New_York)** | New item. Upgrade PowerStoreT OS. |

## Detection

1. Read the PowerStoreT OS version in PowerStore Manager. **5.1.x before 5.1.0.0-2798105** is inside every flaw the advisory lists. **5.1.0.0-2798105 or later** is the build Dell names as the fix. A version outside the 5.1 line is not what the advisory covers, and Dell does not say those lines are unaffected.
2. The models Dell lists are PowerStore 500T, 1000T, 1200T, 1500, 3000T, 3200Q, 3200T, 5000T, 5200Q, 5200T, 5500, 7000T, 9000T, 9200T, and 9500.
3. TFTP, NFS, and the NAS management path are the services the 9.8 rows name. A firewall log of those services is an indicator to review. Absence of those lines is not a clean bill, and this guide has no log signature from Dell.

## Remediation

1. Upgrade PowerStoreT OS to **5.1.0.0-2798105 or later**. Dell gives that one build for every model and every CVE in the advisory.
2. Until the upgrade, Dell's coverage of the advisory says to limit access to the NAS services, including TFTP and NFS, and to keep the management interface on a network only administrators use. That is a mitigation, not the fix.
3. The upgrade does not show whether a request already ran code or changed a file.

## Verification

- PowerStore Manager reports **5.1.0.0-2798105** or later, and the array has finished the upgrade.
- File shares and volumes that clients use still mount.
- Do not send a TFTP or NFS payload to test the overflow.

## Compromise response

Dell publishes no indicator for these flaws and does not report exploitation. If the NAS services were reachable from an untrusted network before the upgrade, review the array for a file share, a user, or a configuration change the owner did not make. The upgrade does not undo one.

## Sources

- [DSA-2026-479][dsa] — Dell, revision 1.0 dated 2026-10-30, article last modified 30 Oct 2026, read 2026-11-16. Impact Critical. Seven CVSS 3.1 9.8 rows, one 9.6 row, and the rest of the 44. Fixed in PowerStoreT OS 5.1.0.0-2798105.
- [CVE-2026-82156](https://www.cve.org/CVERecord?id=CVE-2026-82156) — Dell CNA, published 2026-11-16. CVSS 3.1 8.8. One of the lower-scored rows, included because its record was public.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, checked 2026-11-17. None of the advisory's CVEs are listed.

[dsa]: https://www.dell.com/support/kbdoc/en-us/000527640/dsa-2026-479-dell-powerstore-t-security-update-for-multiple-vulnerabilities
