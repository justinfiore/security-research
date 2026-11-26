# Linux kernel: November 20 High fixes

**Last updated:** 2026-11-26 (America/New_York)

[Main summary](../black-october-2026.md#linux-kernel-eight-high-fixes-from-november-20) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

kernel.org published eight Linux kernel CVE records on 2026-11-20 and scored each one CVSS 3.1 High, from 7.0 to 8.3. NVD has not added a score of its own. Two are Bluetooth flaws a nearby radio peer can reach. One is an iSCSI target flaw that needs a logged-in initiator. One is a NIC driver flaw a device on the same link can reach. The other four need a local account, and one of those also needs someone to mount a virtio 9p share. None of the records reports exploitation in the wild. This is not the [November 2–3 set](linux-november-batch.md), not [NoisyTCP](linux-noisytcp.md), and not the [nested AMD guest](linux-kvm-nested-init.md) flaw.

**CISA KEV:** Not listed (catalog 2026.11.24, checked 2026-11-25). None of the eight is in the catalog. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [What each flaw needs](#what-each-flaw-needs)
- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## What each flaw needs

kernel.org is the CNA for every row. A vendor that scores the same flaw lower is named in [Remediation](#remediation).

| CVE | CNA score | What has to be true | First fixed upstream |
|---|---|---|---|
| [CVE-2026-99794](https://www.cve.org/CVERecord?id=CVE-2026-99794) | 8.3 | A nearby Bluetooth peer sends L2CAP configuration while an incoming channel is still in BT_CONNECT2. The CNA says the channel can then become connected before the accept check finishes. | 5.10.275, 5.15.226, 6.1.193, 6.6.163, 6.12.118, 6.18.64, 7.3.5, and 7.4-rc1. |
| [CVE-2026-99793](https://www.cve.org/CVERecord?id=CVE-2026-99793) | 8.1 | A nearby Bluetooth peer answers an L2CAP connection before the host has sent the request. The CNA says the channel can then become connected early. | Same floors as CVE-2026-99794. |
| [CVE-2026-99785](https://www.cve.org/CVERecord?id=CVE-2026-99785) | 7.8 | A guest uses virtio 9p, and the host (or a compromised hypervisor) offers a mount tag longer than 255 bytes. The CNA says the guest then writes past a sysfs page. The vector needs a user to mount the share. | 5.10.275, 5.15.226, 6.1.193, 6.6.163, 6.12.118, 6.18.64, 7.3.5, and 7.4-rc2. |
| [CVE-2026-99773](https://www.cve.org/CVERecord?id=CVE-2026-99773) | 7.8 | A local process keeps a DRM CRTC fence after the device is unbound. The fence operations can then run against freed driver state. | 5.10.275, 5.15.226, 6.1.193, 6.6.163, 6.12.118, 6.18.64, 7.3.5, and 7.4-rc2. |
| [CVE-2026-99804](https://www.cve.org/CVERecord?id=CVE-2026-99804) | 7.8 | A local process uses io_uring. Cancelling a worker can read the worker after its last reference is dropped. Present from the 5.10.164, 5.15.89, and 6.1.7 stable points, and from 6.2. | 5.10.275, 5.15.226, 6.1.193, 6.6.163, 6.12.117, 6.18.61, 7.3.2, and 7.4-rc1. |
| [CVE-2026-99754](https://www.cve.org/CVERecord?id=CVE-2026-99754) | 7.1 | A logged-in iSCSI initiator sends a persistent-reservation command whose ISID is not terminated. The CNA scores confidentiality Low and integrity None. | 5.10.275, 5.15.226, 6.1.193, 6.6.163, 6.12.118, 6.18.64, 7.3.5, and 7.4-rc2. |
| [CVE-2026-99744](https://www.cve.org/CVERecord?id=CVE-2026-99744) | 7.1 | A device on the same Ethernet link sends a frame longer than the atl1c driver's receive buffer. The CNA describes a panic, and scores confidentiality Low and integrity None. Only hosts with an Atheros L1C (AR8151 and similar) NIC are in scope. | 5.10.275, 5.15.226, 6.1.193, 6.6.163, 6.12.118, 6.18.64, 7.3.5, and 7.4-rc2. |
| [CVE-2026-99746](https://www.cve.org/CVERecord?id=CVE-2026-99746) | 7.0 | A local user on an Intel SOF SoundWire machine hits a failed stream enable after DMA has started. The CNA says the close path then tears down DMA that is still running. Present since 6.15. | 6.18.65, 7.3.5, and 7.4-rc2. No 6.12 tag. |

Red Hat scores three of these lower and has deferred the kernel: CVE-2026-99794 is CVSS 3.1 6.3 Moderate, CVE-2026-99744 is 6.5 Moderate, and CVE-2026-99804 is 5.5 Moderate. RHEL 8 `kernel` and `kernel-rt` are Not affected for CVE-2026-99804, and RHEL 9 `kernel-rt` is Not affected for it. Those are Red Hat's scores and states. They do not replace the CNA score. SUSE's page for CVE-2026-99794 repeats the CNA's 8.3 and marks SLES 12 SP5-LTSS, 15 SP7, 16.0, and 16.1 as Analysis, which is not a released package and not "not affected."

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| **Records published** | **2026-11-20 05:51–07:02 UTC** | kernel.org CNA. Seven records at 05:51 UTC. CVE-2026-99804 at 07:02 UTC. |
| Upstream stable tags | The CNA unaffected lines name 6.12.117 or 6.12.118, 6.18.61, 6.18.64, or 6.18.65, and 7.3.2 or 7.3.5 | kernel.org released 6.12.118 and 6.18.64 on 2026-11-17, and 6.18.65, 6.12.119, and 7.3.6 on 2026-11-23. CVE-2026-99746's record, updated 2026-11-23, says unaffected from 6.18.65. That tag is released. |
| Debian security kernel | Tracker read 2026-11-25 | trixie security `linux` 6.12.118-1 is fixed for the rows trixie contains. bookworm security 6.1.192-2 is still vulnerable for those rows. forky 7.3.5-1 and sid 7.3.6-1 are fixed. |
| 6.18.65 released | 2026-11-23; time unknown | kernel.org. The CVE-2026-99746 record now names this tag. [ChangeLog](https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.18.65) |
| **Last updated** | **2026-11-26 (America/New_York)** | 6.18.65 is out. Amazon Linux marks three of the eight not affected. No new package. |

## Detection

1. Record the running kernel with `uname -r`. An installed package that is not the booted kernel is not the fix.
2. Match that build to a vendor advisory that names the CVE. The upstream floors above are not a verdict for a distribution kernel.
3. Decide which rows can fire:
   - Bluetooth adapters that accept BR/EDR connections are the path for CVE-2026-99794 and CVE-2026-99793. A host with Bluetooth powered off is not on that path.
   - `lspci` showing an Atheros L1C or AR8151 device is the path for CVE-2026-99744. Other NICs are outside it.
   - A guest that mounts a virtio 9p share from a hypervisor it does not trust is the path for CVE-2026-99785. The host that offers the share is not the vulnerable side the record describes.
   - An iSCSI target (`targetcli` or LIO) with initiators that are not fully trusted is the path for CVE-2026-99754.
   - io_uring and an Intel SOF SoundWire audio device are the local paths for CVE-2026-99804 and CVE-2026-99746. Missing one does not clear the others.
4. A kernel changelog that names one CVE in this table does not prove the other seven are present.

No public proof of concept was found for these eight records. Do not send Bluetooth or Ethernet frames, or run a reproducer, to test them.

## Remediation

Install a distribution kernel that names the CVE and reboot into it. Installing the package does not fix a running host. Do not copy an upstream commit into a production kernel.

| Distribution | Status checked 2026-11-25 | What to install |
|---|---|---|
| Debian | trixie security `linux` 6.12.118-1 is fixed for CVE-2026-99794, CVE-2026-99793, CVE-2026-99785, CVE-2026-99754, and CVE-2026-99744. trixie 6.12.117-1 is still vulnerable for those and is already fixed for CVE-2026-99804. bookworm security 6.1.192-2 is vulnerable for the rows bookworm contains. bookworm's optional `linux-6.12` 6.12.117-1~deb12u1 is fixed for CVE-2026-99804 only. forky 7.3.5-1 and sid 7.3.6-1 are fixed. CVE-2026-99746 does not apply below 6.15, so bookworm and trixie's 6.12 base are outside it. | trixie: `linux` 6.12.118-1 or later from security, then reboot. bookworm: no security kernel yet for the Bluetooth, 9p, iSCSI, and atl1c rows. |
| Ubuntu | Generic `linux` has no released fix for CVE-2026-99794. The page, updated 2026-11-24, rates the priority Medium and marks 16.04 through 26.04 Vulnerable. 26.10 is Vulnerable, work in progress, at `7.3.0-12.13`. A work-in-progress build is not a package a normal upgrade installs. The other seven were not each opened. Do not treat one Ubuntu page as the status of the rest. | No package yet for CVE-2026-99794. |
| Red Hat | No erratum. CVE-2026-99794 and CVE-2026-99744: RHEL 8, 9, and 10 `kernel`, and RHEL 8 and 9 `kernel-rt`, are Fix deferred. CVE-2026-99804: RHEL 9 and 10 `kernel` are Fix deferred. RHEL 8 `kernel` and `kernel-rt`, and RHEL 9 `kernel-rt`, are Not affected. Red Hat's scores are 6.3, 6.5, and 5.5. | No package. Fix deferred is not a fix. |
| SUSE | CVE-2026-99794 is Analysis on SLES 12 SP5-LTSS, 15 SP7, 16.0, and 16.1. SUSE repeats the CNA score of 8.3. Analysis is not a released package. The other seven were not each opened. | No released package found. |
| Amazon Linux | Pages read 2026-11-26. CVE-2026-99794, CVE-2026-99793, and CVE-2026-99746 are Not Affected on AL2 and AL2023, with no advisory. The pages for CVE-2026-99804, CVE-2026-99785, CVE-2026-99773, CVE-2026-99754, and CVE-2026-99744 returned 404. | No package. Not Affected covers three of the eight, not the set. |
| AlmaLinux, Rocky Linux, Oracle Linux | No erratum naming these eight CVEs was found. Do not assume a RHEL rebuild has a fix Red Hat has deferred. | Unknown until the rebuild publishes it. |

## Verification

- After reboot, `uname -r` matches the build named in the advisory for the CVE you patched.
- Bluetooth, iSCSI, and the NIC you use still pass the checks you already run. Do not use a proof of concept as the check.
- A trixie host still on 6.12.117-1 is fixed for CVE-2026-99804 and not for the Bluetooth, 9p, iSCSI, or atl1c rows.

## Compromise response

No compromise indicators were published for these eight records. A kernel oops that names `l2cap`, `p9_mount_tag_show`, `atl1c`, or `io_wq_cancel_tw_create` is a reason to keep the crash dump, not proof of an attack. Rebooting into a fixed kernel does not remove persistence.

## Sources

- kernel.org CNA records, published 2026-11-20: [CVE-2026-99794](https://www.cve.org/CVERecord?id=CVE-2026-99794), [CVE-2026-99793](https://www.cve.org/CVERecord?id=CVE-2026-99793), [CVE-2026-99785](https://www.cve.org/CVERecord?id=CVE-2026-99785), [CVE-2026-99773](https://www.cve.org/CVERecord?id=CVE-2026-99773), [CVE-2026-99804](https://www.cve.org/CVERecord?id=CVE-2026-99804), [CVE-2026-99754](https://www.cve.org/CVERecord?id=CVE-2026-99754), [CVE-2026-99744](https://www.cve.org/CVERecord?id=CVE-2026-99744), [CVE-2026-99746](https://www.cve.org/CVERecord?id=CVE-2026-99746). Scores, prerequisites, and unaffected version lines are taken from those records.
- Debian security tracker, read 2026-11-25, for the six Debian rows in the table.
- [Ubuntu CVE-2026-99794](https://ubuntu.com/security/CVE-2026-99794), page updated 2026-11-24.
- Red Hat security-data API for CVE-2026-99794, CVE-2026-99744, and CVE-2026-99804.
- [SUSE CVE-2026-99794](https://www.suse.com/security/cve/CVE-2026-99794.html).
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json), catalog 2026.11.24, checked 2026-11-25.
