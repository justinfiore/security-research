# Linux kernel: IPv4 TCP options use-after-free

**Last updated:** 2026-11-03 (America/New_York)

[Main Linux kernel summary](../black-october-2026.md#linux-kernel-ipv4-tcp-options-use-after-free) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-98432](https://www.cve.org/CVERecord?id=CVE-2026-98432) — kernel.org CVSS 3.1 9.8 Critical** is an IPv4 TCP race that can free socket options while they remain in use. kernel.org describes fixes in upstream and stable commits. Red Hat's public page now also shows CVSS 3.1 9.8 (vector `AV:N/AC:L`), and labels that score preliminary and subject to review; an earlier Red Hat draft scored 8.1 High with attack complexity High. On 2026-11-01 Red Hat released fixed kernels for RHEL 8, 9 and 10. Ubuntu still lists supported products without a released fix. On 2026-10-27 Anthropic reported that an unreleased Claude model produced a lab proof of concept which sends packets to a Linux server exposing a multipath TCP listener and runs commands as root, without credentials. Anthropic did not publish the exploit, and neither Anthropic nor the CNA reports in-the-wild use. Go's security team says the demonstrated exploit needs an MPTCP listener but the kernel bug is not MPTCP-specific, so disabling MPTCP is a fragile stopgap, not a fix.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03). No primary source reviewed reports in-the-wild exploitation. Arista says it is not aware of exploitation in customer networks. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Red Hat fixed kernels | 2026-11-01; time/TZ unknown | [RHSA-2026:93414][rhsa8] (RHEL 8, Critical), [RHSA-2026:93412][rhsa9] (RHEL 9) and [RHSA-2026:93413][rhsa10] (RHEL 10). RHEL 8 real-time is [RHSA-2026:93415][rhsart]. |
| NVIDIA on RHEL 10 kernel | 2026-11-02; time/TZ unknown | [RHSA-2026:93775][rhsa10nv] (Important) names CVE-2026-98432 in `kernel-6.12.0-265.31.el10nv` for Red Hat Enterprise Linux for ARM 64 10. That build is not the RHEL 10 `el10_2` kernel. |
| Red Hat mitigation bulletin | 2026-10-30 16:03 (timezone not stated on the page) | RHSB-2026-016 publishes an nftables filter. Red Hat says it reduces exposure and cannot fully prevent the flaw. [RHSB-2026-016][rhsb] |
| Debian fixed kernels | 2026-10-16 13:39:29 UTC (trixie); 2026-10-17 15:39:22 UTC (bookworm) | trixie `linux` 6.12.113-1 ([DSA-6568-1][dsa]) and bookworm `linux` 6.1.190-1 ([DLA-4841-1][dla]). Bookworm's optional `linux-6.12` 6.12.113-1~deb12u1 is [DLA-4850-1][dla612] (2026-10-22 15:09:29 UTC). |
| Amazon Linux kernel packages | 2026-10-30; time/TZ unknown | [AWS bulletin 2026-160-AWS][aws] says Amazon Linux 2 and Amazon Linux 2023 kernel packages are available and that a reboot is required. Amazon scores the flaw CVSS 3.1 8.1 (attack complexity High), not kernel.org's 9.8. The ALAS pages name `kernel-4.14.355-287.758.amzn2` ([ALAS2-2026-4065][alas2]), Amazon Linux 2023 `kernel-6.1.189-236.400.amzn2023` ([ALAS2023-2026-3365][alas2023]), and `kernel6.12-6.12.113-138.209.amzn2023` ([ALAS2023-2026-3335][alas612]). Extra kernel flavors have their own advisories; install the one for the booted kernel. |
| AlmaLinux production kernels | 2026-11-02; time/TZ unknown | AlmaLinux's post says the fix left the testing repository. Production floors match the November 1 RHEL builds: `kernel-4.18.0-553.182.1.el8_10`, `kernel-5.14.0-687.64.1.el9_8`, `kernel-6.12.0-211.72.1.el10_2`. [AlmaLinux][alma] |
| Arista Security Advisory 0203 | 2026-11-02; time/TZ unknown | Wi-Fi access points on kernel 6.6 in OpenConfig mode, and NDR through 5.4.11, have MPTCP enabled. No fixed release. [Advisory 0203][arista0203] |
| Later Oracle UEK builds | 2026-11-02; time/TZ unknown | ELSA-2026-500572, 500573 and 500574 name this CVE. They are newer builds than the October 16 UEK errata. [ELSA-2026-500572][elsa572] |
| AWS GameLift AMIs | Bulletin updated 2026-11-03 14:15 PM PST (UTC−08:00) | Container fleets created after 2026-11-02 21:06 UTC, and managed EC2 fleets created after 2026-11-03 01:55 UTC, use the updated AMIs. [AWS][aws] |

## Detection

1. Inventory running Linux kernels and IPv4-facing TCP services; record the distributor package build rather than inferring status from the upstream version alone.
2. Check the distributor advisory for the exact installed kernel. The CNA record identifies affected ranges by commits, but distributors can backport fixes without changing the upstream version string.
3. Prioritize systems accepting untrusted IPv4 TCP connections. The CNA record describes races around retransmitted SYN processing and request-socket migration; package presence alone does not establish exploitation.

## Remediation

1. Install the distributor kernel package explicitly marked as fixing CVE-2026-98432, then reboot into it. Do not build an arbitrary upstream commit into a production distribution kernel in place of a supported update.
2. Debian has fixed packages: trixie `linux` 6.12.113-1 ([DSA-6568-1][dsa], 2026-10-16) and bookworm `linux` 6.1.190-1 ([DLA-4841-1][dla], 2026-10-17). Bookworm's optional 6.12 kernel is `linux-6.12` 6.12.113-1~deb12u1 ([DLA-4850-1][dla612], 2026-10-22). Oracle Linux UEK errata [ELSA-2026-500397, ELSA-2026-500398 and ELSA-2026-500399][oracle] (2026-10-16) cover the UEK kernels on Oracle Linux 7, 8, 9 and 10. On 2026-11-02 Oracle shipped later UEK builds that also name this CVE: [ELSA-2026-500572][elsa572] (`kernel-uek-6.12.0-208.112.5` on Oracle Linux 9 and 10), [ELSA-2026-500573][elsa573] (`kernel-uek-5.4.17-2136.361.4` on Oracle Linux 7 and 8), and [ELSA-2026-500574][elsa574] (`kernel-uek-5.15.0-326.222.4` on Oracle Linux 8 and 9). Install the package that matches the booted UEK, not the October 16 build, if that newer channel is the one the host uses. On 2026-11-02 Oracle also shipped the Red Hat-compatible kernel for Oracle Linux 8 ([ELSA-2026-93414][elsa8], `kernel-4.18.0-553.182.1.el8_10`), Oracle Linux 9 ([ELSA-2026-93412][elsa9], `kernel-5.14.0-687.64.1.el9_8`), and Oracle Linux 10 ([ELSA-2026-93413][elsa10], `kernel-6.12.0-211.72.1.el10_2`). The Oracle Linux 9 changelog names this CVE at 5.14.0-687.64.1. The Oracle Linux 8 changelog also contains the `skb_zerocopy()` marker copy at 4.18.0-553.181.1, so that one build covers this flaw and [ZDI-CAN-33367](skb-zerocopy-lpe.md#fixed-kernels-and-live-patches). The Oracle Linux 10 changelog does not. Amazon Linux packages that name this CVE are available as of 2026-10-30: Amazon Linux 2 core `kernel-4.14.355-287.758.amzn2` ([ALAS2-2026-4065][alas2]), Amazon Linux 2023 `kernel-6.1.189-236.400.amzn2023` ([ALAS2023-2026-3365][alas2023], releasever `2023.12.20261102`), and Amazon Linux 2023 `kernel6.12-6.12.113-138.209.amzn2023` ([ALAS2023-2026-3335][alas612]). The 5.4, 5.10 and 5.15 Amazon Linux 2 extras and Amazon Linux 2023 `kernel6.18` have separate ALAS pages on the [CVE package table][alas-cve]; update the package that matches the booted kernel, then reboot. [AWS bulletin 2026-160-AWS][aws] says a kernel update and reboot is the only complete remediation, that self-managed EC2 and Lightsail instances are the customer's to patch, and that Lambda functions are not affected because they do not expose a public IPv4 TCP port. EKS-optimized Amazon Linux 2023 AMIs are release v20261031. Update managed node groups, self-managed nodes, and Karpenter nodes to that release or later. EKS Auto Mode AMIs shipped on 2026-10-31 as "Bottlerocket (EKS Auto, Standard) 2026.10.31", and AWS says Auto Mode replaces nodes itself, subject to NodePool disruption budgets. Bottlerocket's patched kernel is released; updated Bottlerocket AMIs were still expected beginning 2026-11-02 when the bulletin was last updated that day. Amazon MQ for RabbitMQ and ActiveMQ: brokers created after 2026-11-02 12:16 UTC use the patched host image. Existing brokers get it at the next maintenance window, and a reboot does not apply it. Amazon's own score is CVSS 3.1 8.1, with attack complexity High. Install the package for the release you run, then reboot. On 2026-11-02 Ubuntu said fixes are in the **-proposed** pocket, which `apt upgrade` does not install: 22.04 `5.15.0-203.213`, 24.04 `6.8.0-149.149`, and 26.04 `7.0.0-43.43`. Ubuntu 26.10 is fixed in `7.3.0-10.10`. 20.04 and older were still pending. Ubuntu said the updates pocket will get the builds after testing, and that disabling multipath TCP is not the fix. ([Ubuntu, November 2][ubuntu-proposed]) On 2026-11-01 Red Hat released fixed kernels: RHEL 8 `kernel-4.18.0-553.182.1.el8_10` ([RHSA-2026:93414][rhsa8], rated Critical) and real-time `kernel-rt-4.18.0-553.182.1.rt7.523.el8_10` ([RHSA-2026:93415][rhsart]), RHEL 9 `kernel-5.14.0-687.64.1.el9_8` ([RHSA-2026:93412][rhsa9]), and RHEL 10 `kernel-6.12.0-211.72.1.el10_2` ([RHSA-2026:93413][rhsa10]). The RHEL 9 and RHEL 10 errata are rated Important and also fix other kernel flaws. On 2026-11-02 Red Hat released a separate kernel for NVIDIA on RHEL 10, `kernel-6.12.0-265.31.el10nv` ([RHSA-2026:93775][rhsa10nv], rated Important), for Red Hat Enterprise Linux for ARM 64 10. The November 1 `el10_2` package does not replace that build. Install the package that matches the booted kernel, then reboot. Red Hat's CVE API still lists RHEL 9 `kernel-rt` and OpenShift Container Platform 4 and 5 RHCOS as Affected with no released fix; do not treat the RHEL 9 `kernel` errata as covering those. Install the package for the release you run, then reboot. SUSE's tracker shows released `kernel-default` packages for some products, including SUSE Linux Micro 6.2 and SLES 16.0, and still marks SLES 15 SP7 affected; use the tracker for the installed product rather than a single version. On 2026-10-30 Red Hat published [RHSB-2026-016][rhsb], which drops incoming IPv4 TCP packets that contain IP options (`ip protocol tcp ip hdrlength > 5`). Red Hat says this reduces exposure, can disrupt workloads that need those packets, and is not a substitute for patching. Test it before production use, and remove the table after the kernel is fixed. Red Hat's CVE JSON API still says a qualifying mitigation is not available, which disagrees with the public bulletin; follow the bulletin. On 2026-11-02 AlmaLinux said the fix is in its production repositories, since `kernel-4.18.0-553.182.1.el8_10` (8), `kernel-5.14.0-687.64.1.el9_8` (9), and `kernel-6.12.0-211.72.1.el10_2` (10) ([AlmaLinux][alma]). The earlier testing kernels (`553.180.2`, `687.61.2`, `211.69.2`) also contain the fix. AlmaLinux says mirrors can lag a few hours. On 2026-11-03 Rocky Linux published the same builds: [RLSA-2026:93414][rlsa8] (`kernel-4.18.0-553.182.1.el8_10`), [RLSA-2026:93412][rlsa9] (`kernel-5.14.0-687.64.1.el9_8`), and [RLSA-2026:93413][rlsa10] (`kernel-6.12.0-211.72.1.el10_2`). Do not assume a clone has the RHEL build until that clone publishes it. On 2026-11-02 [Arista Security Advisory 0203][arista0203] said Wi-Fi access points using Linux kernel 6.6 are vulnerable, with exact versions still being determined, and that exposure is OpenConfig mode where that listener can be reached. NDR through 5.4.11 is vulnerable by default. Arista has no fixed release and no hotfix. It will disable MPTCP on NDR platforms that are not air-gapped; air-gapped systems need Arista support. EOS-based products are listed as not affected because MPTCP is off, not because the IPv4 code is absent. Arista says it is not aware of malicious exploitation in customer networks.
3. Reduce unnecessary exposure of TCP services to untrusted networks while awaiting a supported package. That, and the nftables filter, reduce opportunity; neither is a fix. On 2026-10-31 AWS added two interim steps to [bulletin 2026-160-AWS][aws] for customers who cannot update yet: set `net.mptcp.enabled=0` (or `GODEBUG=multipathtcp=0` for Go 1.24+), and drop IP-option packets with `iptables -I INPUT 1 -m u32 --u32 "0>>24&0x0f=6:15" -j DROP`. AWS says the MPTCP step reduces the conditions for running code and does not resolve the flaw. The same update says the Redshift cluster OS patch will be available Monday, 2026-11-02, the RDS/Aurora OS patch will be available Tuesday, 2026-11-03, and a Storage Gateway update is expected beginning 2026-11-03. Those are service patches, not a substitute for the kernel on a self-managed instance. AWS's November 1 update (13:15 PM PDT) says every new Fargate task launched after 2026-11-01 17:00 UTC uses a patched platform version. Existing tasks stay on the old platform until they are retired or you replace them. ECS-optimized AMI release 20261031 is the image for EC2 container instances. The same update says the patched kernel for AWS DMS replication instances, including Serverless, will be available in all Regions by 2026-11-02 and applied in the weekly maintenance window, with a reboot. AWS says those instances do not accept the traffic that triggers this flaw, so the reboot is defense in depth. AWS's November 3 update (14:15 PM PST) says Amazon GameLift Servers has released the updated Amazon Linux 2 and 2023 AMIs in all Regions. Container fleets created after 2026-11-02 21:06 UTC, and managed EC2 fleets created after 2026-11-03 01:55 UTC, use those AMIs. Fleets created earlier do not get them by being recreated unless the new fleet is created after those times. Anywhere fleets are yours to patch. Windows fleets are not affected. The same update says Elastic Beanstalk Amazon Linux 2023 platform versions that include the patched kernel are expected beginning 2026-11-04. Until then, an instance Elastic Beanstalk launches starts from the unpatched platform AMI.

## Verification

- After a vendor update, confirm the booted package is the vendor-fixed build and that required TCP services function normally.
- Do not generate timing-sensitive malformed TCP traffic against production systems to test this vulnerability.

## Compromise response

The reviewed primary sources do not provide compromise indicators. Preserve kernel, crash and network telemetry if a suspected incident occurred, investigate adjacent service activity, and rebuild or rotate affected application credentials where host integrity cannot be established.

## Sources

- [kernel.org CNA CVE record][cve] — vulnerability mechanics, score and fixed commit ranges.
- [Red Hat advisory][redhat] — public CVSS 3.1 9.8 (preliminary), and a pointer to the mitigation bulletin.
- [RHSA-2026:93414][rhsa8], [RHSA-2026:93415][rhsart], [RHSA-2026:93412][rhsa9] and [RHSA-2026:93413][rhsa10] — RHEL 8, 8 real-time, 9 and 10 kernels issued 2026-11-01. Each names CVE-2026-98432.
- [Red Hat RHSB-2026-016][rhsb] — nftables mitigation, published 2026-10-30 16:03, explicitly not a substitute for a kernel update.
- [Ubuntu advisory][ubuntu] — supported-release status.
- [Debian DSA-6568-1][dsa], [DLA-4841-1][dla] and [DLA-4850-1][dla612] — fixed trixie and bookworm kernels; the tracker lists CVE-2026-98432 on all three.
- [Oracle Linux CVE page][oracle] — UEK errata ELSA-2026-500397, 500398 and 500399 (2026-10-16), plus the 2026-11-02 UEK updates ELSA-2026-500572, 500573 and 500574. Red Hat-compatible kernels ELSA-2026-93414 (OL8), ELSA-2026-93412 (OL9), and ELSA-2026-93413 (OL10), all 2026-11-02.
- [SUSE CVE page][suse] — per-product status; SUSE scores the flaw 8.1, not kernel.org's 9.8.
- [AWS bulletin 2026-160-AWS][aws] — Amazon Linux packages available 2026-10-30; reboot required; managed-service scope.
- [ALAS2-2026-4065][alas2], [ALAS2023-2026-3365][alas2023] and [ALAS2023-2026-3335][alas612] — package versions. The [ALAS CVE table][alas-cve] lists the other kernel flavors.
- [CISA KEV JSON feed][kev] — catalog status.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-98432
[redhat]: https://access.redhat.com/security/cve/CVE-2026-98432
[rhsa8]: https://access.redhat.com/errata/RHSA-2026:93414
[rhsa9]: https://access.redhat.com/errata/RHSA-2026:93412
[rhsa10]: https://access.redhat.com/errata/RHSA-2026:93413
[rhsa10nv]: https://access.redhat.com/errata/RHSA-2026:93775
[rhsart]: https://access.redhat.com/errata/RHSA-2026:93415
[rhsb]: https://access.redhat.com/security/vulnerabilities/RHSB-2026-016
[alma]: https://almalinux.org/blog/2026-10-30-cve-2026-98432/
[ubuntu]: https://ubuntu.com/security/CVE-2026-98432
[ubuntu-proposed]: https://ubuntu.com/blog/fixes-available-in-proposed-pocket-for-cve-2026-98432
[arista0203]: https://www.arista.com/en/support/advisories-notices/security-advisory/25023-security-advisory-0203
[dsa]: https://lists.debian.org/debian-security-announce/2026/msg00482.html
[dla]: https://lists.debian.org/debian-lts-announce/2026/10/msg00035.html
[dla612]: https://lists.debian.org/debian-lts-announce/2026/10/msg00044.html
[oracle]: https://linux.oracle.com/cve/CVE-2026-98432.html
[elsa8]: https://linux.oracle.com/errata/ELSA-2026-93414.html
[elsa10]: https://linux.oracle.com/errata/ELSA-2026-93413.html
[elsa9]: https://linux.oracle.com/errata/ELSA-2026-93412.html
[elsa572]: https://linux.oracle.com/errata/ELSA-2026-500572.html
[elsa573]: https://linux.oracle.com/errata/ELSA-2026-500573.html
[elsa574]: https://linux.oracle.com/errata/ELSA-2026-500574.html
[rlsa8]: https://errata.rockylinux.org/RLSA-2026:93414
[rlsa9]: https://errata.rockylinux.org/RLSA-2026:93412
[rlsa10]: https://errata.rockylinux.org/RLSA-2026:93413
[suse]: https://www.suse.com/security/cve/CVE-2026-98432.html
[aws]: https://aws.amazon.com/security/security-bulletins/2026-160-aws
[alas2]: https://alas.aws.amazon.com/AL2/ALAS2-2026-4065.html
[alas2023]: https://alas.aws.amazon.com/AL2023/ALAS2023-2026-3365.html
[alas612]: https://alas.aws.amazon.com/AL2023/ALAS2023-2026-3335.html
[alas-cve]: https://explore.alas.aws.amazon.com/CVE-2026-98432.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
