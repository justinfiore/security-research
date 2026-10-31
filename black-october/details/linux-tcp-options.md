# Linux kernel: IPv4 TCP options use-after-free

**Last updated:** 2026-10-31 (America/New_York)

[Main Linux kernel summary](../black-october-2026.md#linux-kernel-ipv4-tcp-options-use-after-free) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-98432](https://www.cve.org/CVERecord?id=CVE-2026-98432) — kernel.org CVSS 3.1 9.8 Critical** is an IPv4 TCP race that can free socket options while they remain in use. kernel.org describes fixes in upstream and stable commits. Red Hat's public page now also shows CVSS 3.1 9.8 (vector `AV:N/AC:L`), and labels that score preliminary and subject to review; an earlier Red Hat draft scored 8.1 High with attack complexity High. Red Hat and Ubuntu both list affected supported products without a released fix at this review. On 2026-10-27 Anthropic reported that an unreleased Claude model produced a lab proof of concept which sends packets to a Linux server exposing a multipath TCP listener and runs commands as root, without credentials. Anthropic did not publish the exploit, and neither Anthropic nor the CNA reports in-the-wild use. Go's security team says the demonstrated exploit needs an MPTCP listener but the kernel bug is not MPTCP-specific, so disabling MPTCP is a fragile stopgap, not a fix.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-10-31). No primary source reviewed reports in-the-wild exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| CVE publication | 2026-10-15; time/TZ unknown | kernel.org CNA record published CVE-2026-98432. [CVE record][cve] |
| Record update | 2026-10-24; time/TZ unknown | The CNA record lists upstream and stable fixed commits. [CVE record][cve] |
| Vendor status reviewed | 2026-10-30; time/TZ unknown | Red Hat and Ubuntu list affected products; Ubuntu shows work in progress for supported LTS kernels. [Red Hat][redhat] [Ubuntu][ubuntu] |
| Red Hat mitigation bulletin | 2026-10-30 16:03 (timezone not stated on the page) | RHSB-2026-016 publishes an nftables filter. Red Hat says it reduces exposure and cannot fully prevent the flaw. [RHSB-2026-016][rhsb] |
| Debian fixed kernels | 2026-10-16 13:39:29 UTC (trixie); 2026-10-17 15:39:22 UTC (bookworm) | trixie `linux` 6.12.113-1 ([DSA-6568-1][dsa]) and bookworm `linux` 6.1.190-1 ([DLA-4841-1][dla]). Bookworm's optional `linux-6.12` 6.12.113-1~deb12u1 is [DLA-4850-1][dla612] (2026-10-22 15:09:29 UTC). |

## Detection

1. Inventory running Linux kernels and IPv4-facing TCP services; record the distributor package build rather than inferring status from the upstream version alone.
2. Check the distributor advisory for the exact installed kernel. The CNA record identifies affected ranges by commits, but distributors can backport fixes without changing the upstream version string.
3. Prioritize systems accepting untrusted IPv4 TCP connections. The CNA record describes races around retransmitted SYN processing and request-socket migration; package presence alone does not establish exploitation.

## Remediation

1. Install the distributor kernel package explicitly marked as fixing CVE-2026-98432, then reboot into it. Do not build an arbitrary upstream commit into a production distribution kernel in place of a supported update.
2. Debian has fixed packages: trixie `linux` 6.12.113-1 ([DSA-6568-1][dsa], 2026-10-16) and bookworm `linux` 6.1.190-1 ([DLA-4841-1][dla], 2026-10-17). Bookworm's optional 6.12 kernel is `linux-6.12` 6.12.113-1~deb12u1 ([DLA-4850-1][dla612], 2026-10-22). Oracle Linux UEK errata [ELSA-2026-500397, ELSA-2026-500398 and ELSA-2026-500399][oracle] (2026-10-16) cover the UEK kernels on Oracle Linux 7, 8, 9 and 10; they do not fix the Red Hat-compatible kernel. Install the package for the release you run, then reboot. Ubuntu lists supported 22.04, 24.04, 26.04 and 26.10 generic kernels as vulnerable with fixes in progress. Red Hat still has no released kernel fix. SUSE's tracker shows released `kernel-default` packages for some products, including SUSE Linux Micro 6.2 and SLES 16.0, and still marks SLES 15 SP7 affected; use the tracker for the installed product rather than a single version. On 2026-10-30 Red Hat published [RHSB-2026-016][rhsb], which drops incoming IPv4 TCP packets that contain IP options (`ip protocol tcp ip hdrlength > 5`). Red Hat says this reduces exposure, can disrupt workloads that need those packets, and is not a substitute for patching. Test it before production use, and remove the table after the kernel is fixed. Red Hat's CVE JSON API still says a qualifying mitigation is not available, which disagrees with the public bulletin; follow the bulletin.
3. Reduce unnecessary exposure of TCP services to untrusted networks while awaiting a supported package. That, and the nftables filter, reduce opportunity; neither is a fix.

## Verification

- After a vendor update, confirm the booted package is the vendor-fixed build and that required TCP services function normally.
- Do not generate timing-sensitive malformed TCP traffic against production systems to test this vulnerability.

## Compromise response

The reviewed primary sources do not provide compromise indicators. Preserve kernel, crash and network telemetry if a suspected incident occurred, investigate adjacent service activity, and rebuild or rotate affected application credentials where host integrity cannot be established.

## Sources

- [kernel.org CNA CVE record][cve] — vulnerability mechanics, score and fixed commit ranges.
- [Red Hat advisory][redhat] — public CVSS 3.1 9.8 (preliminary), and a pointer to the mitigation bulletin.
- [Red Hat RHSB-2026-016][rhsb] — nftables mitigation, published 2026-10-30 16:03, explicitly not a substitute for a kernel update.
- [Ubuntu advisory][ubuntu] — supported-release status.
- [Debian DSA-6568-1][dsa], [DLA-4841-1][dla] and [DLA-4850-1][dla612] — fixed trixie and bookworm kernels; the tracker lists CVE-2026-98432 on all three.
- [Oracle Linux CVE page][oracle] — UEK errata ELSA-2026-500397, 500398 and 500399, dated 2026-10-16.
- [SUSE CVE page][suse] — per-product status; SUSE scores the flaw 8.1, not kernel.org's 9.8.
- [CISA KEV JSON feed][kev] — catalog status.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-98432
[redhat]: https://access.redhat.com/security/cve/CVE-2026-98432
[rhsb]: https://access.redhat.com/security/vulnerabilities/RHSB-2026-016
[ubuntu]: https://ubuntu.com/security/CVE-2026-98432
[dsa]: https://lists.debian.org/debian-security-announce/2026/msg00482.html
[dla]: https://lists.debian.org/debian-lts-announce/2026/10/msg00035.html
[dla612]: https://lists.debian.org/debian-lts-announce/2026/10/msg00044.html
[oracle]: https://linux.oracle.com/cve/CVE-2026-98432.html
[suse]: https://www.suse.com/security/cve/CVE-2026-98432.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
