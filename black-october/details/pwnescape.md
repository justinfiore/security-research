# Linux kernel: PwnEscape - guest-to-host escape via IPv4 checksum metadata

**Last updated:** 2026-10-31 (America/New_York)

[Main PwnEscape summary](../black-october-2026.md#linux-kernel-pwnescape---guest-to-host-escape-via-ipv4-checksum-metadata) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-99999](https://www.cve.org/CVERecord?id=CVE-2026-99999) ("PwnEscape"): kernel.org CNA CVSS 3.1 9.3 Critical (CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H). Red Hat CVSS 3.1 8.8, severity Important (PR:L). Amazon Linux CVSS 3.1 8.8, Important. Ubuntu priority Medium. NVD has added no score of its own.** [CNA][cve] [Red Hat][rh] [Amazon Linux][alas] [Ubuntu][ubuntu] [NVD][nvd]

The bug is in the **host kernel's IPv4 networking stack**, not in KVM. Malformed checksum-offload metadata (`csum_start`/`csum_offset`) supplied with a packet lets `skb_checksum_help()` write into an IPv4 header that the kernel has already validated. During fragmentation, `ip_do_fragment()` then trusts the changed header length. The CNA scenario is a malicious microVM: it sends crafted virtio-net checksum metadata, the VMM writes the frame to the host TAP device, and the host IPv4 stack processes it. Red Hat adds that a **local attacker** can also trigger the flaw. [CNA][cve] [Red Hat][rh] [pwn.ai][pwn]

**Worst case:** an untrusted guest crosses into the host, which threatens every other guest on that host.

- Vercel says repeated **host-memory disclosure** in guest-sent packets was **demonstrated against Vercel production sandboxes**.
- A **host crash** and **command execution as host administrator** were demonstrated only on the researcher's own KVM and Firecracker machines, configured like Vercel Sandbox.
- The researcher calls the execution chain a bounded lab proof and explicitly does not claim root execution in any vendor's production environment. The write-chain details are held back for a "Part 2".

[Vercel][vercel] [pwn.ai][pwn]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). CISA's ADP SSVC entry records exploitation as "none" (2026-10-16). Red Hat's page says Red Hat "tracks this flaw as a KEV active-exploit case". That conflicts with the KEV feed, and no supporting exploitation evidence was found. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means). [KEV][kev] [CNA][cve] [Red Hat][rh]

**Companion issue, Vghost:** [CVE-2026-74580](https://www.cve.org/CVERecord?id=CVE-2026-74580) is a separate vhost flaw with its own dates and conditions. It is covered in Vghost subsections under each heading below. [CNA][cve-vg] [NVD][nvd-vg] [KEV][kev] [Tencent][tencent]

- **Severity:** kernel.org CNA CVSS 3.1 8.8 High (CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H). NVD has added no score of its own.
- **CISA KEV:** not listed (catalog 2026.10.23, checked 2026-10-26). CISA ADP SSVC records exploitation as "none" (2026-10-16).
- **Mechanism:** vhost caches the IOTLB mapping behind each vring's metadata. `VHOST_SET_VRING_ADDR` and `VHOST_SET_VRING_NUM` did not reset that cache. With a device IOTLB attached, later used-ring writes and descriptor reads go through the stale translation, which gives out-of-bounds access.
- **Impact:**
  - **Local root:** any user who can open `/dev/vhost-net` or `/dev/vhost-vsock` can become root.
  - **Guest-triggered:** only in device-IOTLB setups (vIOMMU plus `iommu_platform`). A guest can then write out of bounds into the **host QEMU process heap**. This compromises the VMM process, not directly the host kernel.
- **Exploit code:** a public proof of concept exists.

## Table of contents

- [Timeline](#timeline)
  - [Vghost timeline](#vghost-timeline)
- [Detection](#detection)
  - [Which hosts matter](#which-hosts-matter)
  - [Fixed versions and backports](#fixed-versions-and-backports)
  - [Read-only inventory](#read-only-inventory)
  - [Logs and indicators](#logs-and-indicators)
  - [Vghost applicability](#vghost-applicability)
- [Remediation](#remediation)
  - [Vghost remediation](#vghost-remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Vulnerable code introduced | Linux 2.6.27 (commit `f43798c27684`) | The CNA lists 2.6.27 as the first affected version. AlmaLinux says the vulnerable code has been present for about 18 years. [CNA][cve] [AlmaLinux][alma] |
| Vercel Sandbox challenge opens | 2026-08-18; time/TZ unknown | Researcher write-up. [pwn.ai][pwn] |
| Private discovery and report to Vercel | 2026-08-20; time/TZ unknown | The researcher dates the initial report to August 20. Vercel says it arrived on "day three" of the challenge. [pwn.ai][pwn] [Vercel][vercel] |
| Private report to the kernel security contact | 2026-09-04; time/TZ unknown | Sent with candidate patches. Michael S. Tsirkin reproduced the bug on 2026-09-07. [pwn.ai][pwn] [AlmaLinux][alma] |
| Public patch discussion on netdev | 2026-09-19 to 2026-09-22; time/TZ unknown | The researcher's v4 patch series was archived on 2026-09-20. The patches were public before the vulnerability was announced. [pwn.ai][pwn] [netdev v4][netdev-v4] |
| CVE ID reserved | 2026-09-25 10:25:14 UTC | CNA metadata. [CNA][cve] |
| Amazon Linux fixed kernels | 2026-10-01 (AL2 core and Kernel-5.4 Extra); 2026-10-12 (AL2 5.10/5.15 Extra and AL2023 kernels); times unknown | These are the release dates Amazon lists; the reviewed sources do not explain why some predate the upstream fix. [Amazon Linux][alas] |
| Fix accepted into `net.git` | 2026-10-08; time/TZ unknown | Accepted patch by Tsirkin, posted 2026-10-07. [pwn.ai][pwn] |
| Mainline fix merged (`6785011f8b16`) | 2026-10-14; time/TZ unknown | Researcher and AlmaLinux. [pwn.ai][pwn] [AlmaLinux][alma] |
| **Public announcement** (Vercel) | **2026-10-14; time/TZ unknown** | Vercel's findings post describes the leak, crash and code-execution results. It says the vulnerability "was separately disclosed in public". An oss-security post says it was disclosed "a few days ago on Twitter"; that earlier post was not located or verified. [Vercel][vercel] [oss-security][oss] |
| Upstream stable releases with the fix | 2026-10-15; per-file kernel.org upload times 10:05–13:04 UTC | 5.10.272, 5.15.223, 6.1.190, 6.6.159, 6.12.113, 6.18.57 and 7.2.11. The times are ChangeLog file `Last-Modified` headers, an approximation of release time. [CNA][cve] [kernel.org][korg] |
| CVE record published | 2026-10-15 12:19:22 UTC | kernel.org CNA. NVD received the record the same day. [CNA][cve] [NVD][nvd] |
| Researcher write-up (pwn.ai) | 2026-10-15; time not shown (site metadata: created 02:48:52 UTC) | The page shows no publication date. It was quoted on oss-security at 2026-10-15 15:25:54 −04:00. [pwn.ai][pwn] [oss-security][oss] |
| CISA ADP SSVC | 2026-10-16 15:49 UTC | Exploitation: none. Automatable: no. Technical impact: total. [CNA ADP][cve] |
| AlmaLinux testing kernels | 2026-10-16 20:17 UTC | Released to `almalinux-testing` ahead of RHEL. [AlmaLinux][alma] |
| Debian, Oracle Linux fixes | 2026-10-16 | DSA-6568-1 (trixie `6.12.113-1`), DLA-4841-1 (bookworm `6.1.190-1`); Oracle UEK ELSA-2026-500397/500398/500399. [Debian][debian] [Oracle][oracle] |
| Mainline 7.3 released | 2026-10-18 | 7.3 is the first mainline release with the fix. [kernel.org][kreleases] [CNA][cve] |
| Red Hat fixed kernels | 2026-10-19 to 2026-10-24 (dates only) | RHEL 10 RHSA-2026:85321 (`kernel-6.12.0-211.67.1.el10_2`, 10-19); RHEL 9 RHSA-2026:86033 (`kernel-5.14.0-687.59.1.el9_8`, 10-20); RHEL 7 ELS RHSA-2026:88206 (10-22); RHEL 8 RHSA-2026:89083 (`kernel-4.18.0-553.178.1.el8_10`, 10-24); plus EUS/SAP streams. [Red Hat][rhapi] |
| Red Hat real-time fixed kernels | 2026-10-22 to 2026-10-24 (dates only) | RHEL 7 ELS `kernel-rt-3.10.0-1160.167.2.rt56.1320.el7` (RHSA-2026:88204), RHEL 9.2 SAP Solutions `kernel-rt-5.14.0-284.199.1.rt14.484.el9_2` (RHSA-2026:87822), and RHEL 8 `kernel-rt-4.18.0-553.178.1.rt7.519.el8_10` (RHSA-2026:89082). General RHEL 9 `kernel-rt` remains affected. [Red Hat][rhapi] |
| Further Red Hat fixed kernels | 2026-10-27 (date only) | RHEL 6 ELS `kernel-2.6.32-754.66.1.el6` (RHSA-2026:90933). OpenShift Container Platform RHCOS images for 4.12, 4.14, 4.16, 4.18, 4.19, 4.20, 4.21 and 4.22 (RHSA-2026:90272, 89838, 89714, 89725, 89651, 89333, 89232, 89197). OpenShift Container Platform 5 remains affected. [Red Hat][rhapi] |
| AlmaLinux production kernels | 2026-10-23 17:16 UTC | `kernel-4.18.0-553.177.1.el8_10`, `kernel-5.14.0-687.59.1.el9_8`, `kernel-6.12.0-211.67.1.el10_2`. AlmaLinux warns that `kernel-5.14.0-687.58.1.el9_8` is newer than its testing kernel but lacks the fix. [AlmaLinux][alma] |
| Exploitation in the wild | None reported in the reviewed sources | The researcher expects public exploits within weeks. See the KEV note above about Red Hat's wording. [pwn.ai][pwn] [Red Hat][rh] |
| CISA KEV addition | Not listed | Catalog 2026.10.23, checked 2026-10-26. [KEV][kev] |

### Vghost timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Vulnerable code introduced | Linux 4.11 (commit `f88949138058`, 2017) | The bug also depends on deferred address validation added in 5.9 (commit `0210a8db2aec`); the CNA still lists 4.11 as the first affected version. [Tencent][tencent] [CNA][cve-vg] |
| Private discovery | 2026-07-31; time/TZ unknown | Tencent says the missing invalidation was identified and read/write reproduced that day. [Tencent][tencent] |
| Mainline fix (`de845981da67`) | 2026-08-03; time/TZ unknown | [Tencent][tencent] |
| CVE ID reserved | 2026-08-15 05:44:03 UTC | [CNA][cve-vg] |
| Upstream fixed releases | 7.2 (mainline); 2026-08-19 for 5.10.265, 5.15.216, 6.1.183, 6.6.152, 6.12.104, 6.18.45 and 7.1.9 (ChangeLog upload 15:20–16:40 UTC) | The upload times are approximate release times. [CNA][cve-vg] [kernel.org][korg] |
| **Public announcement** (CVE published) | **2026-08-21 16:31:54 UTC** | Linux kernel CVE announcement. At that point the record contained no score or exploit details. [CNA][cve-vg] [kernel CVE announce][lore-vg] |
| CNA CVSS published | 2026-08-25; time/TZ unknown | 8.8 High. [Tencent][tencent] |
| Technical write-up | 2026-10-12; time/TZ unknown | Tencent Zhuque Lab "Vghost" post. [Tencent][tencent] |
| oss-security disclosure | 2026-10-14 10:16:22 +08:00 | Includes mitigations and a PoC link. [oss-security][oss-vg] |
| Red Hat fixed kernels | 2026-10-19 to 2026-10-24 (dates only) | RHEL 10 RHSA-2026:85321 (`kernel-6.12.0-211.67.1.el10_2`, 10-19); RHEL 9 RHSA-2026:86033 (`kernel-5.14.0-687.59.1.el9_8`, 10-20); RHEL 7 ELS RHSA-2026:88206 (10-22); RHEL 8 RHSA-2026:89083 (`kernel-4.18.0-553.178.1.el8_10`, 10-24); plus EUS/SAP streams. [Red Hat][rhapi] |
| AlmaLinux production kernels | 2026-10-23 17:16 UTC | `kernel-4.18.0-553.177.1.el8_10`, `kernel-5.14.0-687.59.1.el9_8`, `kernel-6.12.0-211.67.1.el10_2`. AlmaLinux warns that `kernel-5.14.0-687.58.1.el9_8` is newer than its testing kernel but lacks the fix. [AlmaLinux][alma] |
| Exploitation in the wild | None reported | CISA ADP SSVC "none" (2026-10-16). [CNA ADP][cve-vg] |
| CISA KEV addition | Not listed | Catalog 2026.10.23, checked 2026-10-26. [KEV][kev] |

## Detection

### Which hosts matter

Prioritize these hosts, in this order:

1. **Hosts that run untrusted guests with virtio-net networking**: KVM/QEMU and Firecracker hosts, VPS and cloud hypervisors, CI runners that start VMs, and code-execution or AI-agent sandboxes built on microVMs. The CNA scenario needs only a tenant that can send through its own virtio-net interface; no host credentials are required. The VMM forwards guest output to its TAP file descriptor, so the host kernel is the target. [CNA][cve] [Vercel][vercel]
2. **Multi-user Linux systems.** Red Hat says a local attacker can trigger the flaw, and the researcher's discussion covered TUN and AF_PACKET paths without a VM. The reviewed sources do not spell out the exact local privileges needed. Access to `/dev/net/tun` or packet sockets with virtio-net headers is the likely prerequisite; this is our inference. AlmaLinux recommends updating every system for this reason. [Red Hat][rh] [pwn.ai][pwn] [AlmaLinux][alma]
3. **Guests themselves** carry the vulnerable code too, but the host-escape risk sits with the host kernel that processes guest packets.

Where the hosting provider runs the host, as with managed cloud VMs or hosted sandboxes, only the provider can patch the host. Watch the provider's notices. Vercel says it mitigated the issue and worked with AWS and other partners. [Vercel][vercel]

### Fixed versions and backports

Upstream fixed versions (CNA): **5.10.272, 5.15.223, 6.1.190, 6.6.159, 6.12.113, 6.18.57, 7.2.11, and mainline 7.3**. Every earlier kernel from 2.6.27 on is affected. [CNA][cve]

- **No upstream stable fix is listed for other series**, including 5.4, 7.0 and 7.1. Use a distribution backport or move to a fixed series.
- **Distribution kernels keep older base versions.** For example, RHEL 9 reports 5.14.0-*, and Ubuntu 24.04 reports 6.8.0-*. Their `uname -r` cannot be compared with upstream numbers. Status when reviewed:
  - **Red Hat:** fixed kernels shipped for RHEL 10 (`kernel-6.12.0-211.67.1.el10_2`), RHEL 9 (`kernel-5.14.0-687.59.1.el9_8`), RHEL 8 (`kernel-4.18.0-553.178.1.el8_10`), RHEL 7 ELS (`kernel-3.10.0-1160.167.2.el7`), RHEL 6 ELS (`kernel-2.6.32-754.66.1.el6`, 2026-10-27) and listed EUS/SAP streams. Real-time fixes are listed for RHEL 7 ELS, RHEL 9.2 SAP Solutions and RHEL 8. OpenShift RHCOS images for 4.12 through 4.22 except 4.13, 4.15 and 4.17 shipped on 2026-10-27. General RHEL 9 `kernel-rt` and OpenShift Container Platform 5 remain affected. [Red Hat][rhapi]
  - **Ubuntu:** releases show "Vulnerable" or "work in progress" (page updated 2026-10-23). [Ubuntu][ubuntu]
  - **AlmaLinux:** production kernels `kernel-4.18.0-553.177.1.el8_10`, `kernel-5.14.0-687.59.1.el9_8` and `kernel-6.12.0-211.67.1.el10_2` (2026-10-23). `kernel-5.14.0-687.58.1.el9_8` does **not** contain the fix. [AlmaLinux][alma]
  - **Debian:** bookworm-security `6.1.190-1` (DLA-4841-1), bookworm `linux-6.12` `6.12.113-1~deb12u1` (DLA-4850-1), trixie-security `6.12.113-1` (DSA-6568-1). [Debian][debian]
  - **Oracle Linux UEK:** ELSA-2026-500397, -500398 and -500399. [Oracle][oracle]
  - **Amazon Linux:** advisories ALAS2-2026-3962, ALAS2KERNEL-5.4-2026-131, ALAS2KERNEL-5.10-2026-133, ALAS2KERNEL-5.15-2026-117, ALAS2023-2026-3197, ALAS2023-2026-3196 and ALAS2023-2026-3192. [Amazon Linux][alas]
- **`uname -r` alone does not prove the fix is present.** It shows the running build string, not which patches the vendor backported. Check the vendor's advisory or package changelog for this CVE or the fix title `ipv4: validate checksum_start before completing checksum`. Also confirm the host has **rebooted** into that kernel.

### Read-only inventory

These commands were not exercised on a production host. Run them on each candidate host as an ordinary user; package-changelog reads may need root on some systems. Placeholders are in capitals. None of the commands change state.

```sh
# Running kernel and boot time (the boot time shows whether a newer kernel could be running)
uname -r; uptime -s

# Is this a virtualization host? KVM device, VMM processes, TAP/vhost devices in use
ls -l /dev/kvm /dev/net/tun /dev/vhost-net /dev/vhost-vsock 2>/dev/null
ps -eo pid,user,comm | grep -E 'qemu|firecracker|cloud-hypervisor|crosvm' | grep -v grep
ip -d link show type tun 2>/dev/null | head -50

# RPM-based: does the running kernel's changelog mention the CVE or fix?
rpm -q --changelog "kernel-$(uname -r)" 2>/dev/null | grep -i -E 'CVE-2026-99999|validate checksum_start'

# Debian/Ubuntu: same check against the installed image's changelog
zgrep -i -E 'CVE-2026-99999|validate checksum_start' "/usr/share/doc/linux-image-$(uname -r)/changelog.Debian.gz" 2>/dev/null
```

A changelog with no match means **unknown**, not vulnerable: vendors do not always name CVEs. Look the build up in the vendor tracker instead. For custom-built kernels, check the source tree for the `ip_check_csum_start()` helper in `include/net/ip.h`.

### Logs and indicators

No IOCs have been published. Signs worth reviewing on virtualization hosts:

- Unexplained host crashes, panics or `WARN` output involving `skb_checksum_help` or `ip_do_fragment`. Check `journalctl -k`, `dmesg`, kdump and crash archives, and serial-console logs. These read-only commands need root or `systemd-journal` group membership.
- Guest-originated IPv4 fragments that carry IP options. The leak returns host bytes as IPv4 options in guest-emitted packets. This is a hunting idea taken from the researcher's description, not a validated signature. [pwn.ai][pwn]

```sh
journalctl -k --since "2026-08-01" | grep -i -E 'skb_checksum_help|ip_do_fragment|csum' | head -100
```

No matches does not show that a host was not targeted. The leak primitive produces no host log entry.

### Vghost applicability

- **Local path:** any host where untrusted users can open `/dev/vhost-net` or `/dev/vhost-vsock`. Tencent reproduced local root on these distributions: [Tencent][tencent] [oss-security][oss-vg]

  | Distribution | `/dev/vhost-vsock` on the tested image | Who could exploit it |
  |---|---|---|
  | RHEL 9.8 | `0666` | Any ordinary user |
  | Amazon Linux 2023 | `0666` | Any ordinary user |
  | Azure Linux 3.0 | `0666` | Any ordinary user |
  | Oracle Linux 10.2 | `0666` | Any ordinary user |
  | Ubuntu 26.04 | `0660 root:kvm` | Members of the `kvm` group |

  Containers that are given vhost devices count as local too.
- **Guest path:** QEMU guests whose virtio devices sit behind a vIOMMU with `iommu_platform=on` (device-IOTLB mode). The guest uses `VIRTIO_F_RING_RESET` to reach the QEMU heap. Guests without a vIOMMU and `iommu_platform` are not exposed through this path, according to Tencent. [Tencent][tencent]
- **Fixed upstream:** 5.10.265, 5.15.216, 6.1.183, 6.6.152, 6.12.104, 6.18.45, 7.1.9 and 7.2. The affected range starts at 4.11. Distribution kernels need their vendor's backport. When Tencent wrote its post, Amazon Linux and Oracle Linux (ELSA-2026-500248) had published fixes. As with PwnEscape, `uname -r` does not prove a backport is present. [CNA][cve-vg] [Tencent][tencent]

Read-only exposure check, run as an ordinary user. It was not exercised on production. `DOMAIN` is a placeholder for a libvirt domain name.

```sh
ls -l /dev/vhost-net /dev/vhost-vsock /dev/vhost-scsi /dev/vhost-vdpa-* 2>/dev/null   # world-writable shows as crw-rw-rw-
getent group kvm                                                                        # who can open 0660 root:kvm nodes
virsh dumpxml DOMAIN 2>/dev/null | grep -E "<iommu|iommu=.on."                          # vIOMMU + iommu_platform (libvirt)
```

Also review container runtime configuration for vhost devices passed into containers.

## Remediation

1. **Patch virtualization and sandbox hosts first.** Install a kernel with the fix: an upstream release from the list above, or your vendor's backport. Then **reboot into it**. Migrate or drain guests before rebooting. AlmaLinux points out that a reboot interrupts every guest on the host. [AlmaLinux][alma]
2. **If your vendor or exact branch has not shipped a fix,** as with Ubuntu, general RHEL 9 `kernel-rt` and OpenShift Container Platform 5 when reviewed, limit exposure until one is available:
   - Do not place untrusted tenants on unpatched hosts.
   - Prefer hosts already running a fixed kernel for untrusted workloads.
   - Restrict who can create TUN/TAP devices or packet sockets on multi-user systems.

   Neither the researcher, upstream nor Red Hat has published a workaround; Red Hat says no mitigation meets its criteria. [AlmaLinux][alma] [Red Hat][rh]
3. **Patch other Linux systems** at your normal fast cadence, given the local-attacker path. [Red Hat][rh]
4. **Patch Vghost at the same time.** It needs its own checks, covered in the [Vghost section](#vghost-remediation). On the 5.10, 5.15, 6.1, 6.6, 6.12, 6.18 and 7.2 series, the upstream PwnEscape fix releases are newer than the Vghost fix releases. Hosts on the 7.1 series have a Vghost fix (7.1.9) but no listed PwnEscape fix.
5. **Rollback caution:** keep the previous kernel available for rollback. Booting back into it reintroduces the vulnerability.

### Vghost remediation

- **Install a fixed kernel** (upstream release or vendor backport) and reboot into it.
- **Until then,** follow the researchers' recommendations: [oss-security][oss-vg] [Tencent][tencent]
  - Remove world access to every `/dev/vhost-*` node.
  - Treat the `kvm` group and other device-owning groups as privileged.
  - Do not pass vhost devices to untrusted containers.
  - Do not give untrusted guests vhost devices with `iommu_platform` behind a vIOMMU.
- **Limits of these measures:** permission changes do not revoke file descriptors that are already open, and they do not address the guest-triggered path.

## Verification

- Each host is running (`uname -r`) the fixed build named in your vendor's advisory, or an upstream version at or above the fixed release for its series.
- The boot time is later than the kernel installation.
- Every node in a cluster is checked, including standby, CI and spare hypervisors.
- Guest networking still works after the reboot: test ordinary TCP and UDP traffic, large transfers that fragment, and any checksum-offload features your guests use.
- Do **not** run the researcher's packets or any exploit code against production hosts.

## Compromise response

- If an untrusted guest ran on an unpatched host, assume **host memory may have leaked** to that guest. Memory may include keys, tokens and other tenants' data. Rotate secrets that lived in host-kernel or VMM memory, such as storage and network credentials and orchestration tokens, based on your own risk assessment.
- Treat unexplained host crashes during the exposure window as possible exploitation attempts. Preserve kdump images, kernel logs and VMM logs.
- If you suspect host code execution, rebuild the host from known-good media. Then review the other guests on that host and any control-plane credentials it held.
- Hosted-platform customers should ask their provider whether their tenancy ran on affected hosts during the exposure window.

- **Vghost:** if untrusted users could reach a `0666` vhost node on an unpatched host, treat local root as possible. Review for unexpected root processes and recent changes to `modprobe_path`. The published chain restores `/proc/sys/kernel/modprobe` afterwards, so a clean value proves nothing. Rebuild the host if you suspect root compromise. A QEMU crash in a vIOMMU guest with `iommu_platform` may indicate an attempt through the guest path. [Tencent][tencent]

## Sources

- [kernel.org CNA record CVE-2026-99999][cve]: scores, scenario text, affected and fixed versions, SSVC.
- [NVD CVE-2026-99999][nvd]; [CISA KEV feed][kev] (catalog 2026.10.23).
- [pwn.ai PwnEscape write-up][pwn]: discovery, report dates, lab-only escape, fix history.
- [Vercel challenge findings (2026-10-14)][vercel]: production leak, lab crash and code execution.
- [oss-security 2026-10-15][oss]; [researcher's netdev v4 patch series][netdev-v4]; [upstream fix `6785011f8b16`][fix].
- Vendor trackers: [Red Hat][rh] ([security data API][rhapi]), [Ubuntu][ubuntu], [Amazon Linux][alas], [AlmaLinux][alma], [Debian][debian], [Oracle Linux][oracle].
- [kernel.org releases][kreleases] and [stable ChangeLog files][korg] (upload times).
- Vghost: [kernel.org CNA record CVE-2026-74580][cve-vg], [NVD][nvd-vg], [Tencent Zhuque Lab write-up][tencent], [oss-security 2026-10-14][oss-vg], [Linux CVE announcement][lore-vg].

[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-99999
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-99999
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[pwn]: https://pwn.ai/blog/pwnescape
[vercel]: https://vercel.com/blog/findings-from-the-1-million-dollar-vercel-sandbox-challenge
[oss]: https://www.openwall.com/lists/oss-security/2026/10/15/5
[netdev-v4]: https://lists.openwall.net/netdev/2026/09/20/11
[fix]: https://github.com/torvalds/linux/commit/6785011f8b16abf40b1e9d8b2e332232b3e68822
[rh]: https://access.redhat.com/security/cve/cve-2026-99999
[ubuntu]: https://ubuntu.com/security/CVE-2026-99999
[alas]: https://explore.alas.aws.amazon.com/CVE-2026-99999.html
[alma]: https://almalinux.org/blog/2026-10-16-pwnescape-cve-2026-99999
[rhapi]: https://access.redhat.com/hydra/rest/securitydata/cve/CVE-2026-99999.json
[debian]: https://security-tracker.debian.org/tracker/CVE-2026-99999
[oracle]: https://linux.oracle.com/cve/CVE-2026-99999.html
[kreleases]: https://www.kernel.org/releases.json
[korg]: https://cdn.kernel.org/pub/linux/kernel/
[cve-vg]: https://cveawg.mitre.org/api/cve/CVE-2026-74580
[nvd-vg]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-74580
[tencent]: https://matrix.tencent.com/en/2026/10/12/vghost-cve-2026-74580
[oss-vg]: https://www.openwall.com/lists/oss-security/2026/10/14/2
[lore-vg]: https://lore.kernel.org/linux-cve-announce/2026082158-CVE-2026-74580-5db9@gregkh/
