# Xen: a guest can read and write other guests' memory

**Last updated:** 2026-11-12 (America/New_York)

[Main Xen summary](../black-october-2026.md#xen-a-guest-can-read-and-write-other-guests-memory) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**SUSE rates [CVE-2026-102703](https://www.cve.org/CVERecord?id=CVE-2026-102703) and [CVE-2026-102704](https://www.cve.org/CVERecord?id=CVE-2026-102704) CVSS 4.0 8.4 and CVSS 3.1 7.1.** The Xen Project advisory gives no score. NVD has not scored either. Vates calls the impact Critical for XCP-ng and prints no CVSS number. Citrix marks bulletin CTX697256 Critical; that bulletin also covers other issues. A guest that can issue grant-copy operations can read and write memory belonging to other guests, including Dom0. Xen says there is no known mitigation. [XSA-523][xsa] [SUSE-SU-2026:5087-1][suse]

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-04). Neither CVE is in the feed. Xen, Vates, Qubes, SUSE, Debian, and Citrix do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [What the two flaws are](#what-the-two-flaws-are)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery | Unknown | Anthropic found it using Claude. Stephan Lipp of Ada Logics validated it. The CodeAnt AI Security Research Team reported it independently. [XSA-523][xsa] |
| Public announcement | 2026-11-03 12:00 UTC | XSA-523 version 2. Xen 4.6 and later are vulnerable. No mitigation. [XSA-523][xsa] |
| SUSE update | 2026-11-03 13:45:04 UTC | `xen` 4.20.4_08-150700.3.52.1 on SLE 15 SP7. Rating: important. Reboot required. [SUSE][suse] |
| XCP-ng 8.3 | 2026-11-03; time/TZ unknown | `xen-4.17.7-4.2.xcpng8.3`. Vates rates the impact Critical and gives no CVSS number. [VSA-2026-055][vates] |
| Qubes OS | 2026-11-03; time/TZ unknown | QSB-121. Qubes 4.3 dom0 Xen packages 4.19.6-3, first in security-testing. Restart dom0. [QSB-121][qubes] |
| Citrix XenServer | 2026-11-03; time/TZ unknown | CTX697256, created 12:31 and last modified 12:34. The page does not state a timezone. Updates pushed to Early Access and Normal for 8.4 and 9. The bulletin names CVE-2026-102703 and not CVE-2026-102704. [CTX697256][citrix] |
| Debian 12 | 2026-11-04 21:39:04 UTC | DLA-4881-1, mailed 22:39:04 +0100. `xen` 4.17.7+13-g2445b30a44-0+deb12u1. The advisory also fixes older Xen issues. [DLA-4881-1][dla] |
| Debian 13 | 2026-11-04; time/TZ unknown | [DSA-6610-1][dsa] fixes trixie at `xen` `4.20.4+63-g7abfd2bce2-0+deb13u1` for both CVEs. sid `4.20.4+63-g7abfd2bce2-1` is also fixed. forky is now fixed at `4.20.4+63-g7abfd2bce2-1`, which migrated to testing on 2026-11-10. [Debian tracker][tracker] |

## What the two flaws are

Grant copy is how a guest asks Xen to copy memory between domains. Xen caches the checks it already made. Two of those checks were wrong:

- [CVE-2026-102703](https://www.cve.org/CVERecord?id=CVE-2026-102703): a frame number and a grant reference can be mixed up.
- [CVE-2026-102704](https://www.cve.org/CVERecord?id=CVE-2026-102704): copying by frame number is allowed only for the caller's own memory, and the check that enforces that was in the wrong place.

Xen's impact line is the same for both: a malicious guest can read and write arbitrary memory belonging to other domains, including Dom0. The attacker needs a guest on that host. This is not an internet-facing flaw in a guest's own services.

The advisory's patches cover xen-unstable through 4.19.x (`xsa523-1.patch`, `xsa523-2.patch`) and 4.18.x through 4.17.x (`xsa523-4.18-1.patch`, `xsa523-4.18-2.patch`). They are written for the tip of the stable branch and may not apply to a release tarball. Xen 4.6 through 4.16 get no patch in the advisory. Xen 4.16's security support ended on 2024-12-02.

## Detection

Read the hypervisor version the host is actually running. A package installed but not booted is not the fix.

```sh
xl info xen_version 2>/dev/null || /usr/sbin/xl info xen_version
```

On a distribution, also read the package:

```sh
# Debian, Ubuntu
dpkg-query -W xen-hypervisor-amd64 xen-hypervisor-arm64 2>/dev/null
# SUSE
rpm -q xen
```

| Platform | Vulnerable | Fixed |
|---|---|---|
| Xen from source, 4.19 and unstable | every release without the XSA-523 patches | tip of the stable branch plus `xsa523-1.patch` and `xsa523-2.patch` |
| Xen from source, 4.17 and 4.18 | every release without the XSA-523 patches | tip of the stable branch plus `xsa523-4.18-1.patch` and `xsa523-4.18-2.patch` |
| Xen 4.6 through 4.16 | every release | no patch in the advisory; move to a supported release |
| Xen 4.5 and earlier | not this flaw | no action for these two CVEs |
| SUSE Linux Enterprise 15 SP7 | below 4.20.4_08-150700.3.52.1 | `xen` 4.20.4_08-150700.3.52.1 |
| Debian 13 (trixie) | 4.20.3+127-gc42374a105-0+deb13u1 and earlier | 4.20.4+63-g7abfd2bce2-0+deb13u1 from trixie-security |
| Debian 12 (bookworm) | 4.17.5+72-g01140da4e8-1 and earlier | 4.17.7+13-g2445b30a44-0+deb12u1 |
| Debian forky | below 4.20.4+63-g7abfd2bce2-1 | 4.20.4+63-g7abfd2bce2-1, fixed; migrated to testing 2026-11-10 |
| Debian sid | below 4.20.4+63-g7abfd2bce2-1 | 4.20.4+63-g7abfd2bce2-1 |
| XCP-ng 8.3 | below xen-4.17.7-4.2.xcpng8.3 | xen-4.17.7-4.2.xcpng8.3 |
| Qubes OS 4.3 | below Xen 4.19.6-3 in dom0 | 4.19.6-3, first in security-testing |
| Citrix XenServer 8.4 and 9 | hosts not yet on the update CTX697256 pushed | latest Early Access or Normal channel update; the bulletin prints no build number |
| Ubuntu | not evaluated | Ubuntu's page says Needs evaluation on every listed release. The hypervisor packages are in universe. |

A version this table does not name is **unknown**, not safe. Ubuntu's "Needs evaluation" is unknown. A cloud guest cannot see the host hypervisor; ask the operator.

## Remediation

1. Install the fixed build for the platform you run, then reboot the host. Rebooting a guest does not load a new hypervisor.
   - **SUSE Linux Enterprise 15 SP7:** `zypper in -t patch SUSE-SLE-Module-Server-Applications-15-SP7-2026-5087`, then reboot. SUSE's note says to reboot after this update.
   - **Debian 13:** install `xen` 4.20.4+63-g7abfd2bce2-0+deb13u1 or later from trixie-security and reboot.
   - **Debian 12:** install `xen` 4.17.7+13-g2445b30a44-0+deb12u1 or later and reboot. That package also fixes older Xen issues named in DLA-4881-1.
   - **Debian forky:** install `xen` 4.20.4+63-g7abfd2bce2-1 or later and reboot. That is the same version sid already had.
   - **XCP-ng 8.3:** update to `xen-4.17.7-4.2.xcpng8.3` and reboot the host.
   - **Qubes OS 4.3:** install Xen packages 4.19.6-3 in dom0 and restart dom0. The packages start in security-testing and move to stable over about two weeks. If you use Anti Evil Maid, reseal the secret passphrase: PCR18 and PCR19 change with the new Xen binaries.
   - **Citrix XenServer 8.4 and 9:** install the latest update from the channel you already use. CTX697256 says the updates were pushed to Early Access and Normal and prints no build number. The same bulletin's other fixes are not this flaw: CVE-2026-98432 is the separate management-network issue, and the PXE issues are a third group.
   - **Xen from source, 4.17 and later:** update to the tip of the stable branch, apply the two patches the advisory names for that branch, and reboot.
   - **Xen 4.6 through 4.16:** the advisory has no patch. Move to a supported release.
2. There is no mitigation to turn on while you wait. Xen says so, and Vates says so. Isolating a host from the internet does not stop a guest that is already running on it.
3. A guest you do not trust should not keep running on an unpatched host. Shut that guest down, or move the host's guests to a patched host, before you treat the old host as safe.

## Verification

After the reboot, read the running hypervisor, not only the package database.

```sh
xl info xen_version
```

On SUSE, the running expectation is a build from `xen-4.20.4_08-150700.3.52.1`. On Debian 13, `4.20.4+63-g7abfd2bce2` or later. On Debian 12, `4.17.7+13-g2445b30a44` or later. On XCP-ng 8.3, `4.17.7`. On Qubes 4.3, `4.19.6`.

A version string that matches and a host that has not rebooted since the package install is **not** fixed. `xl info` reports the booted hypervisor. If that command is missing, the check is **unknown**.

Do not test the flaw. A proof that a guest can read another domain's memory is an exploit, not a check.

## Compromise response

Xen does not report exploitation, and neither does any vendor page read for this guide. A guest that could already run code had a path to Dom0 memory on every unpatched host from Xen 4.6 on.

If a guest was untrusted and the host stayed unpatched after 2026-11-03 12:00 UTC:

- Treat Dom0 as exposed. Patching and rebooting does not remove a change a guest already made there.
- Review Dom0 accounts, authorized keys, and xenstore contents from a trusted console.
- Rotate credentials Dom0 could read, including cloud metadata and host SSH keys.
- A guest that only ran trusted code is not, by these reports, evidence of a compromise.

## Sources

- [XSA-523](https://xenbits.xen.org/xsa/advisory-523.html) (public release 2026-11-03 12:00 UTC).
- [CVE-2026-102703](https://www.cve.org/CVERecord?id=CVE-2026-102703) and [CVE-2026-102704](https://www.cve.org/CVERecord?id=CVE-2026-102704). The Xen Project CNA record has no CVSS score. NVD's record for CVE-2026-102703 has an empty metrics object.
- [SUSE-SU-2026:5087-1](https://www.suse.com/support/update/announcement/2026/suse-su-20265087-1/).
- [Vates VSA-2026-055](https://docs.vates.tech/security-advisories/advisories/2026/vates-sa-2026-055/).
- [Qubes QSB-121](https://www.qubes-os.org/news/2026/11/03/qsb-121/).
- [Citrix CTX697256](https://support.citrix.com/support-home/kbsearch/article?articleNumber=CTX697256&articleURL=XenServer_Security_Update_for_Multiple_Issues).
- [Debian LTS DLA-4881-1](https://lists.debian.org/debian-lts-announce/2026/debian-lts-announce-202611/msg00006.html).
- [Debian security tracker, CVE-2026-102703](https://security-tracker.debian.org/tracker/CVE-2026-102703).
- [Ubuntu CVE-2026-102703](https://ubuntu.com/security/CVE-2026-102703).
- [CISA KEV JSON feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json), catalog 2026.11.04.

[xsa]: https://xenbits.xen.org/xsa/advisory-523.html
[suse]: https://www.suse.com/support/update/announcement/2026/suse-su-20265087-1/
[vates]: https://docs.vates.tech/security-advisories/advisories/2026/vates-sa-2026-055/
[qubes]: https://www.qubes-os.org/news/2026/11/03/qsb-121/
[citrix]: https://support.citrix.com/support-home/kbsearch/article?articleNumber=CTX697256&articleURL=XenServer_Security_Update_for_Multiple_Issues
[dla]: https://lists.debian.org/debian-lts-announce/2026/debian-lts-announce-202611/msg00006.html
[tracker]: https://security-tracker.debian.org/tracker/CVE-2026-102703
[dsa]: https://www.debian.org/security/dsa-6610-1
