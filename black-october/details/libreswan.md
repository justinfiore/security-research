# Libreswan: an empty certificate crashes the VPN daemon

**Last updated:** 2026-11-21 (America/New_York)

[Main Libreswan summary](../black-october-2026.md#libreswan-an-empty-certificate-crashes-the-vpn-daemon) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Libreswan is an IKE implementation used to build IPsec VPNs. [CVE-2026-110339](https://www.cve.org/CVERecord?id=CVE-2026-110339) crashes the `pluto` daemon. The Libreswan Project is the CNA and rates it **CVSS 3.1 7.5 High**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H`. The project's own advisory calls the same flaw **Medium**. NVD has not scored it.

A CERT payload whose PKCS#7 content is an empty certificate list is not caught by the emptiness check, and `pluto` dereferences NULL, crashes, and restarts. Repeating it is a denial of service. The advisory says remote code execution is not possible and that no authentication is required. There is no workaround.

The CNA says **3.24 through 5.4.1** are affected and **5.4.2** is not. The advisory also says 3.0 through 3.23 are not vulnerable. The project was notified on October 6, gave distributors advance notice on November 10, and published the advisory and **5.4.2** on November 16. The tarball `libreswan-5.4.2.tar.gz` is dated 16-Nov-2026 17:39 on the download index. The same release fixes [CVE-2026-115846](https://www.cve.org/CVERecord?id=CVE-2026-115846), which the CNA scores CVSS 3.1 3.7 Low: an IKEv2 peer can skip the `IKE_INTERMEDIATE` exchange and drop a configured post-quantum algorithm. It is not the reason for this entry.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-17) for either CVE. The project does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Vendor notified | 2026-10-06; time/TZ unknown | The advisory writes the date as 06-10-2026. [Advisory][adv] |
| Advance notice | 2026-11-10; time/TZ unknown | Given to supported customers and distributions. Written 10-11-2026. |
| **Public announcement** | **2026-11-16; time unknown** | Advisory and libreswan 5.4.2. The CVE record's published time is 2026-11-16; the clock time was not copied from the record page. |
| Tarball posted | 2026-11-16 17:39; TZ unknown | `libreswan-5.4.2.tar.gz` on the download index. The directory listing does not name the timezone. |
| **Last updated** | **2026-11-17 (America/New_York)** | New item. Upgrade to 5.4.2. |

## Detection

Run `ipsec --version`. A line that reports 3.24 through 5.4.1 is inside the advisory. 5.4.2 or later is the fix. A host that does not run Libreswan is outside this entry. Debian's tracker, read 2026-11-21, still lists bookworm `4.10-2+deb12u1`, trixie `5.2-2.2`, and sid `5.2-2.5` as vulnerable. Ubuntu's page, last updated 2026-11-18, says Needs evaluation on every listed release, including 26.10, 26.04, 24.04, and 22.04. A package that does not name this CVE is not the fix.

## Remediation

1. Upgrade to **libreswan 5.4.2 or later** and restart `pluto`. The advisory says there is no workaround. Debian and Ubuntu have no fixed package yet, so a distribution install of 5.2 or 4.10 is still inside the flaw until the package changelog names CVE-2026-110339.
2. If you cannot upgrade, apply the patch from the project's [patch directory](https://libreswan.org/security/CVE-2026-110339/) and restart. The patch file is dated 16-Nov-2026 18:06.

## Verification

- `ipsec --version` reports 5.4.2 or later, and the running daemon was restarted after the install.
- Do not send a crafted CERT payload to confirm the crash.

## Compromise response

The project publishes no indicator and does not report exploitation. The flaw crashes the daemon; it does not run code. A restart loop in `pluto` before the upgrade is a lead, not proof.

## Sources

- [CVE-2026-110339](https://www.cve.org/CVERecord?id=CVE-2026-110339) — Libreswan Project, published 2026-11-16. CVSS 3.1 7.5. Affected 3.24 through 5.4.1. Unaffected at 5.4.2.
- [Libreswan advisory][adv] — release date Monday, Nov 16, 2026. Severity Medium. No workaround. Notified 06-10-2026, advance notice 10-11-2026.
- [CHANGES](https://download.libreswan.org/CHANGES) — v5.4.2 (Nov 16, 2026) names both CVEs.
- [Download index](https://download.libreswan.org/) — `libreswan-5.4.2.tar.gz`, 16-Nov-2026 17:39.
- [CVE-2026-115846](https://www.cve.org/CVERecord?id=CVE-2026-115846) — same release. CVSS 3.1 3.7 Low. Affected 5.4, unaffected at 5.4.2.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, checked 2026-11-17. Neither CVE is listed.

[adv]: https://libreswan.org/security/CVE-2026-110339/CVE-2026-110339.txt
