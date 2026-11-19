# Linux kernel: NoisyTCP - a TCP packet crashes the host

**Last updated:** 2026-11-19 (America/New_York)

[Main NoisyTCP summary](../black-october-2026.md#linux-kernel-noisytcp---a-tcp-packet-crashes-the-host) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-99288](https://www.cve.org/CVERecord?id=CVE-2026-99288) is a race in the Linux kernel's lockless lookup of established TCP sockets. The researcher who found it, Hyunwoo Kim, calls it NoisyTCP. A stale lookup can take a reference to a socket that was freed and reused at the same address. In the path he demonstrated, the reused object is a SYN-cookie request socket with no listener, and the receive path dereferences that NULL listener. The kernel panics. The crash takes down the host, not only the process that was listening, so a container that shares the host kernel does not contain it.

kernel.org is the CNA and publishes no CVSS score. NVD has not scored it. Red Hat rates it **CVSS 3.1 7.5 High**, vector `CVSS:3.1/AV:N/AC:H/PR:L/UI:N/S:U/C:H/I:H/A:H`, and calls the impact Important. Red Hat says the flaw does not allow data alteration or arbitrary code execution. Kim describes a second path, a nested race on a full child socket, that produces a remote use-after-free, and he says that path is generally hard to trigger. He does not claim code execution.

The flaw was introduced by commit `079096f103fa` on 2015-10-03, so it is present from Linux 4.4. The upstream fix is commit `4e2b3ef19e0e` ("inet: reject unhashed sockets during established lookups"), merged 2026-11-03. kernel.org lists the first fixed stable releases as **6.12.117, 6.18.63, and 7.3.4**, and lists no fixed release for the 5.10, 5.15, 6.1, or 6.6 long-term lines.

Triggering it needs packets processed on more than one receive context: an interface with two or more RX queues, or RPS. Kim measured 5 seconds to 2 minutes against Nginx, Apache, and SSH at their defaults on QEMU/KVM, and about 14 hours against Nginx on a quiet bare-metal server with 8 RX queues. The kernel record says a proof of concept reproduced the crash and quotes the oops from a 7.3.0 test kernel. Kim's repository describes the proof of concept and does not include the code.

This is not the [IPv4 TCP options use-after-free](linux-tcp-options.md), the [TCP SYN-ACK options use-after-free](linux-tcp-rcu.md), or [FragNesia](linux-fragnesia.md).

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
| Introduced | 2015-10-03; time/TZ unknown | Commit `079096f103fa`. Present from Linux 4.4. [kernel.org][cve] |
| Upstream fix merged | 2026-11-03; time/TZ unknown | Commit `4e2b3ef19e0e`. Kim wrote it; Paolo Abeni merged it. [kernel.org][cve] |
| CVE record published | 2026-11-10 18:19:08 UTC | kernel.org CNA. No CVSS score. First fixed stable releases: 6.12.117, 6.18.63, 7.3.4. [kernel.org][cve] |
| **Public technical disclosure** | **2026-11-15 16:00:04 UTC** | Kim posted to oss-security after the linux-distros embargo ended. His message is dated 2026-11-16 01:00:04 +0900. [oss-security][oss] |
| Debian bookworm and trixie fixed | 2026-11-13 and 2026-11-15; time/TZ unknown | trixie: linux 6.12.117-1, [DSA-6628-1][dsa] (November 13). bookworm: linux 6.1.192-1, [DLA-4906-1][dla] (November 15). The security archive publishes bookworm as 6.1.192-2. [Debian tracker][debian] |
| Oracle Linux UEK fixed | 2026-11-12 and 2026-11-13; time/TZ unknown | UEK on Oracle Linux 7, 8, 9, and 10. [Oracle][oracle] |
| Amazon Linux 2 and 2023 | 2026-11-12 and 2026-11-17; time unknown | The 5.10 extra, ALAS2KERNEL-5.10-2026-139, fixes `kernel-5.10.273-275.1133`, released November 12 and updated November 17. The 5.15 extra was released November 12, not November 17. |
| Ubuntu page reread | 2026-11-19; time unknown | The page now says last updated 19 November 2026. `linux` is still Vulnerable, with no package. |
| **Last updated** | **2026-11-19 (America/New_York)** | Amazon's 5.10 extra is fixed. Ubuntu, Red Hat, SUSE, Alma, and Rocky still have no package. |

## Detection

Record the running kernel with `uname -r` and compare it with the distribution row below, not with the upstream version alone. A distribution backport can carry an older-looking version string. A container uses the host kernel.

The listener does not have to be anything special. Nginx, Apache, and SSH at their defaults are enough, because the only requirement is a TCP port the attacker can reach and more than one receive context. A host with a single RX queue and RPS and RFS off does not meet the race condition Kim describes. Confirm that with `ethtool -l <interface>` and `sysctl net.core.rps_sock_flow_entries`; do not treat a default of one queue as a fix.

| Distribution | Release | Status, checked 2026-11-19 |
|---|---|---|
| Upstream stable | 6.12, 6.18, 7.3 | Fixed in 6.12.117, 6.18.63, 7.3.4. No fixed release listed for 5.10, 5.15, 6.1, or 6.6. [kernel.org][cve] |
| Red Hat Enterprise Linux | 8, 9, 10 | Affected, kernel and kernel-rt. No erratum. RHEL 6 and 7 are not affected. [Red Hat][rh] |
| Ubuntu | 20.04, 22.04, 24.04, 26.04, 26.10 | `linux` is Vulnerable on each, and on 18.04 and 16.04. 14.04 is Not affected. No fixed package. Priority High, raised from Medium. The page was last updated 19 November 2026. Ubuntu scores it CVSS 4.0 8.2 and CVSS 3.1 5.9. [Ubuntu][ubuntu] |
| Debian | bookworm, trixie, forky, sid | bookworm security is fixed at 6.1.192-2 ([DLA-4906-1][dla] names 6.1.192-1). trixie security is fixed at 6.12.117-1 ([DSA-6628-1][dsa]). forky and sid are fixed at 7.3.4-1. On November 16 forky 7.2.15-1 was still vulnerable. [Debian][debian] |
| SUSE / SLES | 12 SP5, 15 SP4 through SP7, 16.0, 16.1 | Affected. Overall state Pending. No security announcement. SUSE rates it CVSS 3.1 8.1 and CVSS 4.0 9.2, and calls it important. SLES 11 SP4 is not affected. [SUSE][suse] |
| Amazon Linux | 2 and 2023 | 2023 `kernel` is fixed at 6.1.190-237.442 ([ALAS2023-2026-3455][alas3455], released 2026-11-12). 2023 `kernel6.12` is fixed at 6.12.115-140.210 ([ALAS2023-2026-3448][alas3448], same date). 2023 `kernel6.18` is fixed at 6.18.62-127.179 ([ALAS2023-2026-3477][alas3477], released 2026-11-17), and that advisory includes a livepatch package. Amazon Linux 2 core is fixed at 4.14.355-287.769 ([ALAS2-2026-4124][alas24124], released 2026-11-17), also with a livepatch package. The 5.4 extra is `kernel-5.4.302-229.517` ([ALAS2KERNEL-5.4-2026-138][alas54]). The 5.10 extra is `kernel-5.10.273-275.1133` ([ALAS2KERNEL-5.10-2026-139][alas510]), released 2026-11-12 and updated 2026-11-17. The 5.15 extra is `kernel-5.15.224-160.263` ([ALAS2KERNEL-5.15-2026-121][alas515]), released 2026-11-12 and updated 2026-11-17, not first released on November 17. [Amazon][alas] |
| AlmaLinux, Rocky Linux | 8, 9, 10 | No production erratum as of 2026-11-19. Alma's November 16 post still lists testing kernels only. Rocky's errata index, last updated 2026-11-19, returns nothing for this CVE. |
| Oracle Linux | UEK on 7, 8, 9, 10 | Fixed in the Unbreakable Enterprise Kernel. [ELSA-2026-500630][elsa630] (November 12) covers UEK on 7 and 8. [ELSA-2026-500631][elsa631] (November 13) covers UEK on 8 and 9. [ELSA-2026-500632][elsa632] (November 12) covers UEK on 9 and 10. Oracle's CVE page lists no RHCK erratum. [Oracle][oracle] |

A row that says no advisory was found means **unknown**, not fixed.

## Remediation

Install the distribution kernel that names CVE-2026-99288, then reboot into it. Installing the package does not change the kernel that is running.

Debian bookworm, trixie, forky, and sid, Amazon Linux 2, Amazon Linux 2023's default kernel, `kernel6.12`, and `kernel6.18`, and the Oracle Linux Unbreakable Enterprise Kernel have that package. Red Hat 8, 9, and 10, Ubuntu, SUSE, and the RHEL rebuilds do not. Until yours does:

1. Prefer the upstream stable floors only where you already build your own kernel: 6.12.117, 6.18.63, or 7.3.4. Do not cherry-pick `4e2b3ef19e0e` into a distribution kernel.
2. Kim's temporary mitigations, which he says block the race he demonstrated: set `net.ipv4.tcp_syncookies=0` in **each** network namespace, or reduce the exposed interface to one RX queue and disable RPS and RFS. Disabling SYN cookies weakens SYN-flood protection. Neither is a fix, and neither covers a kernel that is still missing the patch.
3. Keep administrative TCP listeners off untrusted networks. That reduces who can send the packets. It does not fix a listener that must stay open.

## Verification

After the reboot, `uname -r` matches the package the distribution lists for CVE-2026-99288. Do not send the packets Kim describes.

## Compromise response

The demonstrated result is a kernel panic, which stops the host rather than leaving a process behind. No source reports exploitation in the wild. If a host panics with a NULL dereference in `tcp_v4_rcv` while it was reachable, preserve the crash dump and treat the exposure as a lead. The patch does not explain an earlier crash.

## Sources

- [CVE-2026-99288][cve] — kernel.org, published 2026-11-10 18:19:08 UTC. No CVSS score. Introduced by `079096f103fa`, fixed by `4e2b3ef19e0e`, `d69100340b4c`, `8e5172cbd227`, and `eb8a2d156f2c`. Unaffected from 6.12.117, 6.18.63, and 7.3.4.
- [oss-security, Hyunwoo Kim][oss] — 2026-11-15 16:00:04 UTC. The disclosure, the two trigger paths, the timing measurements, and the two mitigations.
- [V4bel/NoisyTCP](https://github.com/V4bel/NoisyTCP) — the same write-up. The repository describes the proof of concept and does not include the code.
- [Red Hat CVE-2026-99288][rh] — Important, CVSS 3.1 7.5, preliminary. RHEL 8, 9, and 10 affected; RHEL 6 and 7 not affected. No erratum. Red Hat says no data alteration and no code execution.
- [Ubuntu CVE-2026-99288][ubuntu] — priority High. Last updated 19 November 2026. `linux` is Vulnerable on 16.04, 18.04, 20.04, 22.04, 24.04, 26.04, and 26.10. 14.04 is Not affected. No fixed package. Ubuntu scores it CVSS 4.0 8.2 and CVSS 3.1 5.9. On November 17 the same page said Medium.
- [Debian security tracker, CVE-2026-99288][debian] — read 2026-11-17. bookworm security 6.1.192-2 fixed (fixed version 6.1.192-1, [DLA-4906-1][dla], November 15). trixie security 6.12.117-1 fixed ([DSA-6628-1][dsa], November 13). forky and sid 7.3.4-1 fixed. On November 16 forky was 7.2.15-1 and vulnerable.
- [Oracle Linux CVE-2026-99288][oracle] — Important. UEK errata only: ELSA-2026-500630 (November 12, Oracle Linux 7 and 8), ELSA-2026-500631 (November 13, Oracle Linux 8 and 9), ELSA-2026-500632 (November 12, Oracle Linux 9 and 10). Each names CVE-2026-99288. No RHCK erratum is listed. Oracle's own CVSS 3.1 vector scores 8.1 and is marked preliminary.
- [SUSE CVE-2026-99288][suse] — read 2026-11-17. Overall state Pending. Important. CVSS 3.1 8.1 and CVSS 4.0 9.2. No security announcement. SLES 15 SP7, 16.0, and 16.1 affected. SLES 11 SP4 not affected.
- [Amazon Linux CVE-2026-99288][alas] — AL2023 kernel fixed in [ALAS2023-2026-3455][alas3455] at 6.1.190-237.442. AL2023 kernel6.12 fixed in [ALAS2023-2026-3448][alas3448] at 6.12.115-140.210. AL2023 kernel6.18 fixed in [ALAS2023-2026-3477][alas3477] at 6.18.62-127.179, released 2026-11-17. Amazon Linux 2 core fixed in [ALAS2-2026-4124][alas24124] at 4.14.355-287.769, the same day. Amazon's own vector is CVSS 3.1 7.5, availability only.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.17, released 2026-11-17T17:53:15.5664Z. CVE-2026-99288 is not in it.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-99288
[oss]: https://www.openwall.com/lists/oss-security/2026/11/15/2
[rh]: https://access.redhat.com/security/cve/CVE-2026-99288
[ubuntu]: https://ubuntu.com/security/CVE-2026-99288
[debian]: https://security-tracker.debian.org/tracker/CVE-2026-99288
[dsa]: https://lists.debian.org/debian-security-announce/2026/msg00548.html
[dla]: https://lists.debian.org/debian-lts-announce/2026/11/msg00032.html
[oracle]: https://linux.oracle.com/cve/CVE-2026-99288.html
[suse]: https://www.suse.com/security/cve/CVE-2026-99288.html
[alas]: https://explore.alas.aws.amazon.com/CVE-2026-99288.html
[alas3455]: https://alas.aws.amazon.com/AL2023/ALAS2023-2026-3455.html
[alas3448]: https://alas.aws.amazon.com/AL2023/ALAS2023-2026-3448.html
[alas3477]: https://alas.aws.amazon.com/AL2023/ALAS2023-2026-3477.html
[alas24124]: https://alas.aws.amazon.com/AL2/ALAS2-2026-4124.html
[alas54]: https://alas.aws.amazon.com/AL2/ALAS2KERNEL-5.4-2026-138.html
[alas510]: https://alas.aws.amazon.com/AL2/ALAS2KERNEL-5.10-2026-139.html
[alas515]: https://alas.aws.amazon.com/AL2/ALAS2KERNEL-5.15-2026-121.html
[elsa630]: https://linux.oracle.com/errata/ELSA-2026-500630.html
[elsa631]: https://linux.oracle.com/errata/ELSA-2026-500631.html
[elsa632]: https://linux.oracle.com/errata/ELSA-2026-500632.html
