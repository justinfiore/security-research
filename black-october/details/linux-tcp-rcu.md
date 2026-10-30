# Linux kernel: IPv4 TCP SYN-ACK options use-after-free

**Last updated:** 2026-10-30 (America/New_York)

[Main summary](../black-october-2026.md#linux-kernel-ipv4-tcp-syn-ack-options-use-after-free) · [Main TOC](../black-october-2026.md#table-of-contents)

**[CVE-2026-98432](https://www.cve.org/CVERecord?id=CVE-2026-98432): kernel.org CNA CVSS 3.1 9.8 Critical.** A concurrent IPv4 TCP SYN-ACK path can use freed IP options, producing a remote unauthenticated use-after-free. The CNA record does not report in-the-wild exploitation.

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Public CVE publication | 2026-10-15; time/TZ unknown | kernel.org CNA record. |
| Upstream mainline fix | 2026-10-05 16:21:57 -0700 | Commit `e3f33b0a1d89` changes the IPv4 destructors to defer freeing through RCU. |
| **Last updated** | **2026-10-30 (America/New_York)** | Added from the CNA record and upstream fix. |

## Detection
Record every running kernel with `uname -r` and match its vendor package against the vendor’s advisory. The upstream fixed floors are 5.10.272, 5.15.223, 6.1.190, 6.6.159, 6.12.113, 6.18.56, 7.2.10 and 7.3. A distribution backport may use another version string, so an upstream comparison alone is not a verdict.

This is a network-reachable IPv4 TCP flaw. Inventory internet-facing and untrusted-network listeners first. Missing package or backport information means **unknown**, not fixed. Do not run proof-of-concept traffic against production.

## Remediation
Install the vendor kernel package that explicitly fixes CVE-2026-98432, reboot into it, and remove older vulnerable kernels according to normal operational policy. Where a vendor package is unavailable, restrict untrusted network access to affected services as a temporary exposure reduction; do not cherry-pick upstream patches into production kernels.

## Verification
After the reboot, confirm `uname -r` and the installed package against the vendor tracker, then perform normal approved service checks. Do not use exploit traffic as a verification control.

## Compromise response
No exploitation is established by the reviewed primary sources. If suspicious crashes, kernel faults or unexpected privileged activity coincide with exposure, preserve logs and memory where feasible, isolate the host and investigate under the incident-response process; patching does not remove persistence.

## Sources
- [kernel.org CNA CVE record](https://www.cve.org/CVERecord?id=CVE-2026-98432)
- [upstream fix `e3f33b0a1d89`](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e3f33b0a1d89d738e2b913dab519226eaf76e15b)
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json)
