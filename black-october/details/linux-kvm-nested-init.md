# Linux kernel: a nested AMD guest reads the host

**Last updated:** 2026-11-26 (America/New_York)

[Main KVM summary](../black-october-2026.md#linux-kernel-a-nested-amd-guest-reads-the-host) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On an AMD host running KVM with nested virtualization, a guest that can run a virtual machine of its own can make the host keep a stale pointer to a page the kernel has already freed. Terra Security showed that pointer used to read about 127 GB of a DigitalOcean host's memory, and, on its own server, to write 32 chosen bytes into a live host kernel page. Intel hosts are outside it. A guest that cannot run nested virtualization is outside it. This is not [PwnEscape](pwnescape.md), which is in the host's IPv4 stack, and not [NoisyTCP](linux-noisytcp.md).

**kernel.org rates [CVE-2026-99312](https://www.cve.org/CVERecord?id=CVE-2026-99312) CVSS 3.1 8.8 High.** The vector is `CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`. kernel.org is the CNA. The record says the bug only affects nested SVM: INIT is an unconditional intercept on VMX, so KVM cannot emulate INIT while an L2 guest is active on Intel. The kernel commit message describes a stale MMU context. Red Hat's page describes the same flaw as a use-after-free of the nested page table pointer, and that is the mechanism Terra demonstrated.

Scores disagree, and the disagreement is about impact, not about whether the code is wrong:

| Issuer | Score | What it says the guest gets |
|---|---|---|
| kernel.org (CNA) | CVSS 3.1 8.8 High | High confidentiality, integrity, and availability, scope changed. |
| Ubuntu | CVSS 4.0 8.2 High; priority High | Availability only, on the vulnerable system and a subsequent system. |
| Red Hat | CVSS 3.1 7.8 Important, preliminary | High confidentiality, integrity, and availability, scope changed. The public page now describes the use-after-free with guest read and write of host memory. The security-data feed still marks the score a draft. |
| SUSE | CVSS 3.1 7.8, important | High confidentiality, integrity, and availability, scope changed. The page's earlier 5.5 said availability only. |

DigitalOcean, which reproduced the read on its own hosts, treated it as critical for that fleet. The 8.8 is the score this guide uses for admission. The lower scores are the vendors' own reading of how often the condition is met.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-20). Terra and DigitalOcean describe a researcher demonstration, not an attack. VirtFusion says it knows of no use outside research and of no published exploit. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to KVM maintainers | 2026-10-21; time/TZ unknown | Terra. [Write-up][terra] |
| Fix merged | 2026-11-02; time/TZ unknown | Commit `c7c288d178cb`. First tagged in v7.4-rc2 on 2026-11-09. [DigitalOcean][do] |
| Stable and longterm | 2026-11-17; time/TZ unknown | 7.3.5, 6.18.64, and 6.12.118. [Terra][terra] |
| **Public announcement** | **2026-11-18 08:42:06 UTC** | CVE record published. Terra's write-up is the same day. [CVE][cve] |
| DigitalOcean | 2026-11-19; time/TZ unknown | Says its Droplet fleet is live-patched. Customers of that fleet have nothing to install. [DigitalOcean][do] |
| **Last updated** | **2026-11-26 (America/New_York)** | Bookworm security moved to 6.1.192-3 and is still vulnerable. Sid is 7.3.6-1. RHEL 9 kernel-rt is affected. |

## Detection

The host is inside this only when all three are true:

1. It runs KVM.
2. The CPU is AMD. `grep -m1 vendor_id /proc/cpuinfo` shows `AuthenticAMD`. An Intel host is not affected: the kernel record says INIT cannot be emulated while L2 is active on VMX.
3. Nested virtualization is on. `cat /sys/module/kvm_amd/parameters/nested` prints `1` or `Y`. DigitalOcean says that is the default. If the file is missing, the module is not loaded.

A guest operating system cannot see this. The check is on the host. A cloud customer whose provider runs the host cannot patch it; ask the provider whether nested virtualization is on for AMD and whether the host kernel carries commit `c7c288d178cb`.

Upstream fixed releases are **7.3.5**, **6.18.64**, and **6.12.118**. The record also lists the flaw in **5.15.81 before 5.16** and **6.0.11 before 6.1**. A distribution kernel keeps its own version number, so `uname -r` alone does not prove a backport. Installing the package does not fix a running host: it has to boot the new kernel, or the vendor has to say a live patch for this commit is applied.

## Remediation

Reboot into a kernel that contains commit [`c7c288d178cb`](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c7c288d178cb). Drain guests first. Until that kernel is available, set the `nested` parameter of `kvm_amd` to `0` and reload the module, which means the guests have to stop. That turns nested virtualization off. Guests can no longer run their own virtual machines, including the kind a desktop hypervisor, an Android emulator, or a CI sandbox uses. Tell those tenants before changing it.

| Distribution | Status, checked 2026-11-26 | Source |
|---|---|---|
| Upstream | Fixed in 7.3.5, 6.18.64, 6.12.118, and 7.4-rc2. The November 23 stable releases add 5.15.226, 6.1.193, and 6.6.163. Also fixed before 5.16 and before 6.1 on those short branches. | [CVE record][cve] |
| RHEL 10 | Affected. No erratum. | [Red Hat][rh] |
| RHEL 9 | Affected, including `kernel-rt`. The earlier feed had marked `kernel-rt` not affected. No erratum. | [Red Hat][rh] |
| RHEL 8 | Not affected, including `kernel-rt`. | [Red Hat][rh] |
| RHEL 7 | Not affected. | [Red Hat][rh] |
| Ubuntu 22.04, 24.04, 26.04, 26.10 | Vulnerable. No package. 20.04's base kernel is Not affected; its HWE 5.15 kernel is Vulnerable. Priority High. | [Ubuntu][ubuntu] |
| Debian bookworm, trixie, forky | Trixie security is fixed at 6.12.118-1 (DSA-6652-1). Bookworm security moved to 6.1.192-3 on November 26 and is still vulnerable. That upload fixes [CVE-2026-99362](linux-nfs2root.md), not this one. Bookworm itself is 6.1.176-1 and vulnerable. Sid is now 7.3.6-1 and fixed. Forky stays resolved at 7.3.5-1. | [Debian][debian] |
| SUSE | SLES 15 SP7, 16.0, and 16.1 are Affected. The page had called them Already fixed. SLES 15 SP4, SP5, and SP6 LTSS are Affected. SLES 12 SP5 is Not affected. No package version is named. Overall state Pending. | [SUSE][suse] |
| Amazon Linux | Not in the public ALAS index on 2026-11-21. No package to name. | [ALAS][alas] |
| Oracle Linux | UEK only. ELSA-2026-500643 (2026-11-19) is `kernel-uek-5.15.0-326.224.5.2.el8uek` and `kernel-uek-5.15.0-326.224.5.2.el9uek`. ELSA-2026-500644 (2026-11-19) is `kernel-uek-6.12.0-208.112.5.3.el9uek` and `kernel-uek-6.12.0-208.112.5.3.el10uek`. The RHEL-compatible kernel has no erratum. | [Oracle][oracle] |

Red Hat's feed also lists OpenShift `ose-rhel-coreos-9` and the OpenShift 5 images as Affected, and `ose-rhel-coreos-8` as Not affected. AlmaLinux and Rocky Linux follow the RHEL kernel they rebuild, and neither had a named erratum in the sources read for this run. Oracle's UEK packages are in the table; its RHEL-compatible kernel is not among them. A live-patch vendor is relevant only when it names this commit. DigitalOcean says it shipped its own live patch and that Droplet customers have nothing to install. That claim is about DigitalOcean's hosts, not about a kernel you run yourself.

## Verification

- On an AMD host, `/sys/module/kvm_amd/parameters/nested` is `0`, or the running kernel's changelog names `c7c288d178cb` or CVE-2026-99312.
- `uname -r` matches the kernel you just booted, not the package sitting on disk.
- Do not try to reset a nested guest to test the pointer. That is the exploit.

## Compromise response

Terra and DigitalOcean publish no indicator: no address, no file, and no log line. A host that was sharing AMD hardware with untrusted guests, with nested virtualization left on, through November 18 is the one they describe. Rebooting into the fixed kernel does not show whether a guest already read host memory. Review the host for a process or a kernel module you did not load. A guest operating system will not contain that evidence.

## Sources

- [CVE-2026-99312][cve] — kernel.org, published 2026-11-18 08:42:06 UTC, updated 2026-11-23. CVSS 3.1 8.8. Nested SVM only. Unaffected from 6.12.118, 6.18.64, 7.3.5, and, as of the November 23 update, 5.15.226, 6.1.193, and 6.6.163.
- [Terra write-up][terra] — Oren Yomtov, November 18, 2026. Read of about 127 GB on a DigitalOcean droplet. Write of 32 bytes on Terra's own server. Reported 2026-10-21. Introduced by the fix for CVE-2022-3344.
- [DigitalOcean][do] — Tyler Healy, November 19, 2026. Confirms the read and the write. Fix tagged in v7.4-rc2 on November 9 and shipped in 7.3.5, 6.18.64, and 6.12.118 on November 17. Droplet fleet live-patched.
- [Red Hat][rh] — CVSS 3.1 7.8 Important, preliminary, vector `CVSS:3.1/AV:L/AC:H/PR:L/UI:N/S:C/C:H/I:H/A:H`. RHEL 9 and 10 affected, RHEL 7 and 8 not affected. The CSAF now lists RHEL 9 `kernel-rt` as affected. No erratum. The feed still marks the score a draft.
- [Ubuntu][ubuntu] — priority High, CVSS 4.0 8.2, last updated November 20, 2026. No fixed package.
- [Debian][debian] — read 2026-11-26. Trixie security fixed at 6.12.118-1. Forky resolved at 7.3.5-1. Sid fixed at 7.3.6-1. Bookworm security is 6.1.192-3 and still vulnerable. The 6.1.192-3 changelog, dated November 26, names CVE-2026-99362 only.
- [SUSE][suse] — important, CVSS 3.1 7.8. SLES 15 SP7, 16.0, and 16.1 are Affected; the page had called them Already fixed. No package version. Page last modified November 21, 2026.
- [Oracle][oracle] — ELSA-2026-500643 and ELSA-2026-500644, both 2026-11-19, cover the UEK kernels only. The RHEL-compatible kernel has no erratum.
- [CISA KEV JSON][kev] — catalog 2026.11.25, released 2026-11-25T19:48:12.4344Z, checked 2026-11-26. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-99312
[terra]: https://www.terra.security/blog/kvm-guest-to-host-escape
[do]: https://www.digitalocean.com/blog/cve-2026-99312-kvm-patch
[rh]: https://access.redhat.com/security/cve/cve-2026-99312
[ubuntu]: https://ubuntu.com/security/CVE-2026-99312
[debian]: https://security-tracker.debian.org/tracker/CVE-2026-99312
[suse]: https://www.suse.com/security/cve/CVE-2026-99312.html
[oracle]: https://linux.oracle.com/cve/CVE-2026-99312.html
[alas]: https://alas.aws.amazon.com/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
