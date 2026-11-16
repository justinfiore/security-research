# Linux kernel: NoisyTCP - a TCP packet crashes the host

**Last updated:** 2026-11-16 (America/New_York)

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
| **Last updated** | **2026-11-16 (America/New_York)** | New item. No distribution has a fixed package on every tracked release. |

## Detection

Record the running kernel with `uname -r` and compare it with the distribution row below, not with the upstream version alone. A distribution backport can carry an older-looking version string. A container uses the host kernel.

The listener does not have to be anything special. Nginx, Apache, and SSH at their defaults are enough, because the only requirement is a TCP port the attacker can reach and more than one receive context. A host with a single RX queue and RPS and RFS off does not meet the race condition Kim describes. Confirm that with `ethtool -l <interface>` and `sysctl net.core.rps_sock_flow_entries`; do not treat a default of one queue as a fix.

| Distribution | Release | Status, checked 2026-11-16 |
|---|---|---|
| Upstream stable | 6.12, 6.18, 7.3 | Fixed in 6.12.117, 6.18.63, 7.3.4. No fixed release listed for 5.10, 5.15, 6.1, or 6.6. [kernel.org][cve] |
| Red Hat Enterprise Linux | 8, 9, 10 | Affected, kernel and kernel-rt. No erratum. RHEL 6 and 7 are not affected. [Red Hat][rh] |
| Ubuntu | 20.04, 22.04, 24.04, 26.04, 26.10 | `linux` is "Needs evaluation" on each. No fixed package. Priority Medium. [Ubuntu][ubuntu] |
| Debian | bookworm, trixie, forky, sid | Vulnerable. bookworm security is 6.1.190-1, trixie security is 6.12.116-1, forky is 7.2.15-1, sid is 7.3.3-1. The tracker lists no fixed version. [Debian][debian] |
| SUSE / SLES | — | No SUSE CVE page (HTTP 404 on 2026-11-16). |
| Amazon Linux | 2 and 2023 | No Amazon Linux advisory found on 2026-11-16. |
| AlmaLinux, Rocky Linux | — | No erratum found on 2026-11-16. |
| Oracle Linux | — | No Oracle erratum read on 2026-11-16. A secondary report says Oracle shipped Unbreakable Enterprise Kernel packages on November 12; that was not confirmed against an Oracle advisory. |

A row that says no advisory was found means **unknown**, not fixed.

## Remediation

Install the distribution kernel that names CVE-2026-99288, then reboot into it. Installing the package does not change the kernel that is running.

No tracked distribution has shipped that package on every supported release. Until one does:

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
- [Ubuntu CVE-2026-99288][ubuntu] — priority Medium. `linux` needs evaluation on 20.04 through 26.10. No fixed package. Last updated 11 November 2026.
- [Debian security tracker, CVE-2026-99288][debian] — bookworm, trixie, forky, and sid vulnerable. No fixed version listed.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. CVE-2026-99288 is not in it.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-99288
[oss]: https://www.openwall.com/lists/oss-security/2026/11/15/2
[rh]: https://access.redhat.com/security/cve/CVE-2026-99288
[ubuntu]: https://ubuntu.com/security/CVE-2026-99288
[debian]: https://security-tracker.debian.org/tracker/CVE-2026-99288
