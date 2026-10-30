# Synology DSM: unauthenticated file read and write

**Last updated:** 2026-10-30 (America/New_York)

[Main summary](../black-october-2026.md#synology-dsm-unauthenticated-file-read-and-write) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-13639](https://www.cve.org/CVERecord?id=CVE-2026-13639) and [CVE-2026-13684](https://www.cve.org/CVERecord?id=CVE-2026-13684) — Synology (CNA) CVSS 3.1 9.8 Critical each (`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`).** NVD has added no score of its own. The same [Synology-SA-26:13][sa2613] update also fixes [CVE-2026-13673](https://www.cve.org/CVERecord?id=CVE-2026-13673) (8.8 High, authenticated) and [CVE-2026-6205](https://www.cve.org/CVERecord?id=CVE-2026-6205) (8.1 High, authenticated). The other four CVEs in that advisory are Moderate or Low.

CVE-2026-13639 is insufficient entropy in DSM login logic. CVE-2026-13684 is improper output encoding in DSM's SCGI component. Synology says either one lets a remote unauthenticated attacker read or write arbitrary files and cause a denial of service. Versions of DSM before 7.2.1 are marked unknown in the CNA records, not confirmed unaffected. Synology lists no workaround.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-10-30) for either Critical CVE, the other SA-26:13 CVEs, or the related 2024 flaw [CVE-2024-10441](https://www.cve.org/CVERecord?id=CVE-2024-10441). CISA's ADP assessment of 2026-09-18 records Exploitation "none" for both Critical CVEs. 360 later reported ransomware cases that it attributes to those two CVEs; that report is not a KEV listing. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Synology-SA-26:13 published | 2026-09-18 16:17:35 UTC+8 | Fixes published the same day. Synology severity Critical for the DSM lines below. [SA-26:13][sa2613] |
| CVE records published | 2026-09-18 08:19:14 UTC (CVE-2026-13684) and 08:21:27 UTC (CVE-2026-13639) | Synology CNA. CISA ADP the same day records Exploitation "none". [CVE-2026-13639][cve13639] [CVE-2026-13684][cve13684] |
| 360 ransomware warning | 2026-10-29; time/TZ unknown | 360 says C3RB3R, which it calls a Cerber variant, encrypted Synology NAS devices through CVE-2026-13639 and CVE-2026-13684, and that the cases began in October 2026. [360][q360] |
| Synology press statement | 2026-10-29; time/TZ unknown | Synology says attackers are exploiting a vulnerability patched in December 2024 (it points to [Synology-SA-24:20][sa2420], whose Critical issue is CVE-2024-10441) against outdated DSM. It does not name CVE-2026-13639 or CVE-2026-13684. [Press release][press] |

## Detection

1. In DSM, open **Control Panel → Update & Restore → DSM Update** and record the full version string, including the build and update number. "7.4" or "latest" is not enough.
2. Compare with Synology's fixed floors for SA-26:13. A build at or above the floor for its branch includes that advisory's fixes:

   | Branch | Fixed in |
   |---|---|
   | DSM 7.4 | 7.4-90075 or above |
   | DSM 7.3 | 7.3.2-86009-4 or above |
   | DSM 7.2.2 | 7.2.2-72806-9 or above |
   | DSM 7.2.1 | 7.2.1-69057-12 or above |

   DSM older than 7.2.1 is **unknown** for CVE-2026-13639 and CVE-2026-13684: the CNA records do not say those branches are unaffected. For the separate December 2024 flaw Synology named on 2026-10-29, [SA-24:20][sa2420] fixes CVE-2024-10441 in 7.2.2-72806-1, 7.2.1-69057-6 and 7.2-64570-4 or above. One current DSM update covers both advisories; do not stop at the 2024 floor.
3. Look for C3RB3R indicators 360 described: files renamed with a `.L0CK3D` extension and a ransom note. Absence of those names does not show the device was not reached.
4. Note whether DSM's web UI, SSH, or other services are reachable from the internet, including through port forwarding or a tunnel. Reachability is exposure, not proof of compromise.

## Remediation

Upgrade DSM to the fixed build for the installed branch, or later: **7.4-90075**, **7.3.2-86009-4**, **7.2.2-72806-9**, or **7.2.1-69057-12**. Synology lists no mitigation. Enable automatic DSM updates after the upgrade so a later security build is not left pending.

Until the update is installed, remove the device from the internet: close DSM, SSH, and other forwarded services. A VPN is a way to keep remote access without leaving those services public. It is not a patch.

Synology's October 29 statement and 360's report name different patched vulnerabilities. Installing a current DSM build addresses both named advisories. Do not pick one attribution and skip the other branch's floor.

## Verification

After the update and reboot, read the running DSM version again and confirm it is at or above the floor for that branch. Confirm DSM and SSH are not reachable from an untrusted network if you closed them. Do not send exploit traffic to test the fix.

## Compromise response

If files are encrypted, or if a device below either fixed floor was reachable from the internet during October 2026, treat it as a possible compromise. Isolate it, keep it powered on if encryption is still in progress so responders can capture memory, and restore from a backup that was not on the device. Reset DSM administrator passwords and any exposed application credentials after the restore. Do not pay a ransom on the assumption that a decryptor exists; none was established in the sources reviewed here.

## Sources

- [Synology-SA-26:13][sa2613] — severity, CVSS, affected and fixed DSM builds, no mitigation.
- [CVE-2026-13639][cve13639] and [CVE-2026-13684][cve13684] — Synology CNA records and CISA ADP exploitation status.
- [360 warning (2026-10-29)][q360] — C3RB3R cases attributed to the two September CVEs.
- [Synology press release (2026-10-29)][press] and [Synology-SA-24:20][sa2420] — Synology's attribution to the December 2024 vulnerability and its fixed builds.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30; none of these CVEs are listed.

[sa2613]: https://www.synology.com/en-global/security/advisory/Synology_SA_26_13
[sa2420]: https://www.synology.com/en-global/security/advisory/Synology_SA_24_20
[cve13639]: https://www.cve.org/CVERecord?id=CVE-2026-13639
[cve13684]: https://www.cve.org/CVERecord?id=CVE-2026-13684
[q360]: https://weishi.360.cn/dnzs/13055.html
[press]: https://www.synology.com/en-global/company/news/article/C3RB3R/Synology%20urges%20users%20to%20update%20DSM%20following%20ransomware%20attacks%20on%20outdated%20DSM%20versions
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
