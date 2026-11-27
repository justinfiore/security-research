# Linux kernel: NFS2ROOT - an NFS client writes past a kernel buffer

**Last updated:** 2026-11-27 (America/New_York)

[Main NFS summary](../black-october-2026.md#linux-kernel-nfs2root---an-nfs-client-writes-past-a-kernel-buffer) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

A Linux host that serves files with the in-kernel NFS server can be crashed, and kernel.org's score says the same request can run code, by a client that never logs in. The client asks for the smallest cached reply the server allows, then sends one compound request. The server copies that reply past the end of the slot it allocated. A host that does not run `nfsd`, or that serves only NFSv3 or NFSv4.0, is outside it. This is not [NoisyTCP](linux-noisytcp.md), which is in the TCP stack, and not [the nested AMD guest flaw](linux-kvm-nested-init.md).

**kernel.org rates [CVE-2026-99362](https://www.cve.org/CVERecord?id=CVE-2026-99362) CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. kernel.org is the CNA. The record was published 2026-11-19 and updated 2026-11-27. It describes an out-of-bounds write of the cached reply, including a tag the client chooses, and says the server returns the adjacent bytes to that client. The bug has been in the server since Linux 3.16. Red Hat scores the same flaw **CVSS 3.1 9.4 Critical**, vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:L/A:H`: it keeps confidentiality and availability High and marks integrity Low. Amazon Linux scores it **9.4** as well, with the low impact on confidentiality instead, vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:H/A:H`. SUSE scores it **9.8** and also **CVSS 4.0 9.0**, vector `CVSS:4.0/AV:N/AC:L/AT:P/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`, and calls the issue critical. Ubuntu's priority is Critical and its page shows the kernel.org 9.8. NVD has not scored it. The 9.8 is the score this guide uses for admission.

Red Hat says a default install does not run `nfsd`. Only a host configured to export NFSv4.1 or NFSv4.2 is exposed, and a deployment that is not an NFS server is not.

**CISA KEV:** Not listed (catalog 2026.11.27, checked 2026-11-27). The kernel record, Red Hat, and SUSE do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Introduced | Linux 3.16; time unknown | The record says the flaw is present from 3.16. [CVE][cve] |
| **Public announcement** | **2026-11-19 14:22:44 UTC** | kernel.org published the record. [CVE][cve] |
| Record updated | 2026-11-27 11:04:21 UTC | Same 9.8 score. The unaffected list is unchanged. [CVE][cve] |
| Distribution fixes | 2026-11-26 and 2026-11-27 | Red Hat, Debian, Amazon Linux, Rocky, Alma, and Oracle. See the table. |
| **Last updated** | **2026-11-27 (America/New_York)** | New item. |

## Detection

The host is inside this only when both are true:

1. The in-kernel NFS server is running. `systemctl is-active nfs-server` prints `active`, or `lsmod` lists `nfsd`.
2. NFSv4.1 or NFSv4.2 is enabled. `cat /proc/fs/nfsd/versions` contains `+4.1` or `+4.2`. A line with only `-4.1` and `-4.2` is not this flaw. If the file is missing, `nfsd` is not loaded.

A client of someone else's NFS server cannot see this. The check is on the server. Restricting the export to authenticated clients does not remove it: the record says the session setup that reaches the copy runs before the server checks who the client is.

Upstream fixed releases are **5.10.275**, **5.15.226**, **6.1.193**, **6.6.163**, **6.12.117**, **6.18.61**, **7.3.2**, and **7.4-rc1**. A distribution kernel keeps its own version number, so `uname -r` alone does not prove a backport. Installing the package does not fix a running host: it has to boot the new kernel, or the vendor has to say a live patch for this flaw is applied.

## Remediation

Reboot into a kernel whose changelog names CVE-2026-99362. Drain clients first. Until that kernel is available, Red Hat's mitigation is to stop `nfs-server` where the host does not need to share files, or to allow TCP port 2049 only from clients you mean to serve. Stopping the service drops the mounts those clients already have. Neither step is the fix.

| Distribution | Status, checked 2026-11-27 | Source |
|---|---|---|
| Upstream | Fixed in 5.10.275, 5.15.226, 6.1.193, 6.6.163, 6.12.117, 6.18.61, 7.3.2, and 7.4-rc1. Kernels before 3.16 are not affected. | [CVE record][cve] |
| RHEL 10 | 10.0 EUS is fixed by RHSA-2026:104032 (2026-11-27), `kernel-6.12.0-55.121.1.el10_0`. 10.2 EUS is fixed by RHSA-2026:104044 (2026-11-27), `kernel-6.12.0-211.78.1.el10_2`. The base 10 line has no erratum on the page. | [Red Hat][rh] |
| RHEL 9 | Affected, including `kernel-rt`. No erratum. | [Red Hat][rh] |
| RHEL 8 | Fixed. RHSA-2026:103817 (2026-11-26) is `kernel-4.18.0-553.190.1.el8_10`. RHSA-2026:103838 (2026-11-26) fixes `kernel-rt`. RHSA-2026:104030 (2026-11-27) covers 8.6 EUS. | [Red Hat][rh] |
| RHEL 7 and 6 | Affected. No erratum. Both are past their maintenance window. | [Red Hat][rh] |
| Ubuntu 16.04 through 26.10 | Vulnerable. No released package. 26.10 and 26.04 have a fix in progress. 14.04 is not affected. Priority Critical. | [Ubuntu][ubuntu] |
| Debian bookworm, trixie, forky | Bookworm security is fixed at `linux` 6.1.192-3 (DLA-4942-1). Bookworm's `linux-6.12` is fixed at 6.12.117-1~deb12u1 (DLA-4927-1). Trixie is fixed at 6.12.117-1, and trixie security at 6.12.118-1. Forky is fixed at 7.3.5-1. Sid is fixed at 7.3.6-1. Bookworm's base 6.1.176-1 is still vulnerable. | [Debian][debian] |
| SUSE | Overall state Pending, rated critical. SLES 15 SP7 is In progress. SLES 16.0 and 16.1 are Affected. SLES 12 SP5-LTSS is In progress, with a kernel-source floor of 4.12.14-122.344.1 named on the page. No released package. | [SUSE][suse] |
| Amazon Linux 2023 | Fixed. ALAS2023-2026-3540 (2026-11-27) is `kernel-6.1.190-237.446.amzn2023`. ALAS2023-2026-3539 is `kernel6.12-6.12.115-140.213.amzn2023`. ALAS2023-2026-3538 is `kernel6.18-6.18.62-127.179.amzn2023`. Amazon scores it 9.4. | [ALAS][alas] |
| Amazon Linux 2 | Pending fix. ALAS2-2026-4166 (2026-11-27) lists `kernel-4.14.355-287.771.amzn2`, and the 5.4, 5.10, and 5.15 kernel topics each have an advisory dated the same day. The feed still marks all four PendingFix. | [ALAS][alas] |
| AlmaLinux 8 | Fixed. ALSA-2026:103817 (2026-11-26) is `kernel-4.18.0-553.190.1.el8_10`. AlmaLinux 9 and 10 had no erratum in the sources read. | [Alma][alma] |
| Rocky Linux 8 | Fixed. RLSA-2026:103817, published 2026-11-27, is `kernel-4.18.0-553.190.1.el8_10`. Rocky 9 and 10 had no erratum in the sources read. | [Rocky][rocky] |
| Oracle Linux | The RHEL-compatible kernel on Oracle Linux 8 is fixed by ELSA-2026-103817, `kernel-4.18.0-553.190.1.el8_10`. UEK is fixed by ELSA-2026-500697 (OL9 and OL10), ELSA-2026-500698 (OL8 and OL9), and ELSA-2026-500699 (OL7 and OL8). Oracle's page gives no UEK package version. | [Oracle][oracle] |

Red Hat's page also lists OpenShift `ose-rhel-coreos-8` and `ose-rhel-coreos-9` on platform 4, and `ose-rhel-coreos-9` and `ose-rhel-coreos-10` on platform 5, as Affected. A live-patch package is relevant only when the vendor names this flaw. Amazon's AL2023 advisory lists a live-patch package for the 6.1 kernel; the page does not say it covers this CVE on its own.

## Verification

- `uname -r` matches the kernel you just booted, not the package sitting on disk.
- The running kernel's changelog names CVE-2026-99362, or `systemctl is-active nfs-server` is `inactive` on a host that does not serve files.
- Do not send a compound request to test the copy. That is the exploit.

## Compromise response

The kernel record publishes no indicator: no address, no file, and no log line. It says the copy crashes the NFS thread and can panic the host, and that the reply the client gets can include bytes from the next kernel object. A reboot into the fixed kernel does not show whether a client already did that. Review the host for a kernel module you did not load. An NFS client will not contain that evidence.

## Sources

- [CVE-2026-99362][cve] — kernel.org, published 2026-11-19 14:22:44 UTC, updated 2026-11-27 11:04:21 UTC. CVSS 3.1 9.8. Unaffected from 5.10.275, 5.15.226, 6.1.193, 6.6.163, 6.12.117, 6.18.61, 7.3.2, and 7.4-rc1.
- [Red Hat][rh] — CVSS 3.1 9.4 Critical, vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:L/A:H`. RHEL 8 fixed by RHSA-2026:103817 (2026-11-26). RHEL 10.0 EUS fixed by RHSA-2026:104032 and 10.2 EUS by RHSA-2026:104044, both 2026-11-27. RHEL 9 affected. A default install does not run `nfsd`.
- [Ubuntu][ubuntu] — priority Critical. Last updated 25 November 2026. No released package. 14.04 not affected.
- [Debian][debian] — read 2026-11-27. Bookworm security fixed at 6.1.192-3. Trixie fixed at 6.12.117-1. Forky fixed at 7.3.5-1. Sid fixed at 7.3.6-1.
- [SUSE][suse] — critical, CVSS 3.1 9.8 and CVSS 4.0 9.0. Overall state Pending. SLES 15 SP7 In progress. SLES 16.0 and 16.1 Affected.
- [Amazon Linux][alas] — severity Critical, CVSS 3.1 9.4. AL2023 fixed 2026-11-27. AL2 pending the same day.
- [AlmaLinux][alma] — ALSA-2026:103817, 2026-11-26, `kernel-4.18.0-553.190.1.el8_10`.
- [Rocky Linux][rocky] — RLSA-2026:103817, published 2026-11-27, Rocky Linux 8, same kernel version.
- [Oracle][oracle] — ELSA-2026-103817 for the Oracle Linux 8 kernel, and ELSA-2026-500697, ELSA-2026-500698, and ELSA-2026-500699 for UEK.
- [CISA KEV JSON][kev] — catalog 2026.11.27, released 2026-11-27T18:03:12.5733Z, checked 2026-11-27. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-99362
[rh]: https://access.redhat.com/security/cve/cve-2026-99362
[ubuntu]: https://ubuntu.com/security/CVE-2026-99362
[debian]: https://security-tracker.debian.org/tracker/CVE-2026-99362
[suse]: https://www.suse.com/security/cve/CVE-2026-99362.html
[alas]: https://alas.aws.amazon.com/cve/json/v1/CVE-2026-99362.json
[alma]: https://errata.almalinux.org/8/ALSA-2026-103817.html
[rocky]: https://errata.rockylinux.org/RLSA-2026:103817
[oracle]: https://linux.oracle.com/cve/CVE-2026-99362.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
