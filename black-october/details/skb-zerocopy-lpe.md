# Linux kernel: skb_zerocopy page-cache write gives local root despite the Dirty Frag fix

**Last updated:** 2026-10-26 (America/New_York)

[Main guide](../black-october-2026.md#linux-kernel-skb_zerocopy-page-cache-write-gives-local-root-despite-the-dirty-frag-fix) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**ZDI-CAN-33367 (no CVE assigned): ZDI, the reporter, rates it CVSS 3.0 7.8 High (AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H). Red Hat lists it as "Potentially Affected" with severity Important (RHSB-2026-014). ZDI is reporting through Trend Micro's disclosure program, not as the kernel's CNA; no CNA or NVD score exists because no CVE exists.** [ZDI report][report] [ZDI upcoming][zdi] [Red Hat][rh]

**Scope:** a bug in the kernel networking helper `skb_zerocopy()`. It lets an **unprivileged local user change the page-cache copy of any file they can read**, including root-owned setuid binaries and libraries, which leads to root. The file on disk is not modified, but every process that reads the file sees the attacker's bytes until the cached pages are evicted or the host reboots. [AlmaLinux][alma] [CloudLinux][cl]

- **Mechanism:** the [CVE-2026-43284](https://www.cve.org/CVERecord?id=CVE-2026-43284) ("Dirty Frag") fix made IPsec ESP check the `SKBFL_SHARED_FRAG` marker and decrypt into a private copy when packet pages belong to a file. `skb_zerocopy()`, used by NFQUEUE and Open vSwitch upcalls, transfers the file pages to a new buffer but drops the marker. ESP then decrypts in place over the cached file pages. [Fix commit][commit] [CloudLinux][cl]
- **Not covered by earlier fixes:** kernels carrying the Dirty Frag fix are still exposed; TuxCare rooted AlmaLinux kernels that ship it. Sysdig counts six earlier follow-up CVEs for other paths that lost the marker, including [CVE-2026-90049](https://www.cve.org/CVERecord?id=CVE-2026-90049), a different error path in `skb_zerocopy()` itself. A kernel fixed only for those is not fixed for this report. [TuxCare][tux] [Sysdig][sysdig]
- **Attack conditions:** local code execution as any user, plus the ability to gain network-administration rights in a namespace. The public proof of concept (PoC) creates an unprivileged user namespace and uses the auto-loadable modules `nfnetlink_queue`, `nft_queue`, `nlmon`, `cls_u32`, `act_pedit`, `act_mirred`, `esp4` and `xfrm_user`. A process that already holds network-admin rights, such as root in a container granted them, does not need the namespace step. Nothing in it is reachable from the network on its own. [CloudLinux][cl] [Sysdig][sysdig]
- **Worst case:** any shell account, CI job, compromised web application or container with the prerequisites becomes root on the host. On shared hosts this reaches every tenant. [CloudLinux][cl] [TuxCare][tux]
- **Exploit code:** the ZDI report was posted to public kernel mailing lists with PoC source. CloudLinux/TuxCare obtained root with it on AlmaLinux 8, 9 and 10, CloudLinux 9 and 10, Debian 12 and 13 and Ubuntu 24.04 and 26.04, bypassing Ubuntu's AppArmor user-namespace restriction. CentOS 6 and 7 kernels are not affected. [CloudLinux][cl] [TuxCare][tux]

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. A working public PoC exists; no in-the-wild exploitation had been reported as of TuxCare's October 23 update or Sysdig's October 24 analysis. [What KEV means](../black-october-2026.md#what-cisa-kev-means). [TuxCare][tux] [Sysdig][sysdig]

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Which hosts matter](#which-hosts-matter)
  - [Kernel build and fix status](#kernel-build-and-fix-status)
  - [Read-only exposure checks](#read-only-exposure-checks)
  - [Indicators and evidence limits](#indicators-and-evidence-limits)
- [Remediation](#remediation)
  - [Fixed kernels and live patches](#fixed-kernels-and-live-patches)
  - [Temporary mitigations](#temporary-mitigations)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Vulnerable code introduced | `af2806f8f90a` (kernel 3.14) and `f4c50a4034e6` | The fix names both commits in `Fixes:` tags: the commit that introduced `skb_zerocopy()` and the Dirty Frag ESP fix whose guard this bypasses. TuxCare dates `af2806f8f90a` to kernel 3.14. No CNA affected-version range exists. [Fix commit][commit] [TuxCare][tux] |
| Private discovery | Unknown | Not established in the reviewed sources. ZDI credits the researcher p1r0x. [ZDI report][report] |
| Same bug privately reported with a patch by another source | About 2026-10-15 (exact date not established) | Eric Dumazet, replying on 2026-10-22, said a report with a patch arrived "one week ago" from another source. [Dumazet reply][dumazet] |
| ZDI report to the vendor | 2026-10-21; time/TZ unknown | ZDI's upcoming-advisories list gives "Reported 2026-10-21" and a 120-day deadline of 2027-02-18. [ZDI upcoming][zdi] |
| **Public announcement** (ZDI report on LKML/netdev with PoC source) | **2026-10-21 21:46:49 UTC** | ZDI sent the report to `security@kernel.org` with LKML and netdev copied, so it became public immediately. TuxCare says the public copies were a mistake. [ZDI report][report] [TuxCare][tux] |
| Netdev maintainer reply | 2026-10-22 04:28 UTC (06:28 +0200) | Dumazet: "Patch will be available soon." [Dumazet reply][dumazet] |
| Fix posted to netdev | 2026-10-22 10:42:17 UTC (18:42:17 +0800) | `[PATCH v2 net] net: skbuff: propagate shared-frag marker in skb_zerocopy()` by Zizhen Liu, copied to `stable@kernel.org`. [Patch][patch] |
| Root confirmed on major distributions | 2026-10-22 18:44 UTC | CloudLinux's kernel team, with the public PoC. [CloudLinux][cl] |
| TuxCare ELS kernel for AlmaLinux 9.2 ESU lists the fix | 2026-10-23 10:36:48 UTC (OSV publication time) | OSV import of TuxCare advisory CLSA-2026-1792751700: `kernel-5.14.0-284.1101.el9_2.tuxcare.11.els17`. Seen only through OSV; not confirmed on a TuxCare advisory page. [OSV][osv] |
| KernelCare live patch released for EL10 | 2026-10-23 14:59 UTC | Production feed for AlmaLinux, CloudLinux, RHEL, Oracle Linux and Rocky Linux 10, built from the upstream fix candidate and verified against the public PoC. EL9 in review, EL8 in progress, Debian/Ubuntu not started. [CloudLinux][cl] [TuxCare][tux] |
| AlmaLinux testing kernels | 2026-10-23; time/TZ unknown | `kernel-4.18.0-553.177.2.el8_10`, `kernel-5.14.0-687.59.2.el9_8`, `kernel-6.12.0-211.68.2.el10_2` in `almalinux-testing`, backported ahead of RHEL. Not yet in production repositories at the time. [AlmaLinux][alma] |
| AlmaLinux 8 production kernel | 2026-10-25 14:54 (repository listing; TZ not shown) | `kernel-4.18.0-553.178.1.el8_10` in BaseOS; its RPM changelog includes "net: skbuff: propagate shared-frag marker in skb_zerocopy()". `553.179.1` followed on 2026-10-26. AlmaLinux 9 and 10 production kernels do not carry the fix yet. [AlmaLinux repository][almarepo] |
| Fix committed to the netdev `net` tree | 2026-10-23 19:41:58 UTC (15:41:58 EDT) | Commit `79dc34beb1fd` by Jakub Kicinski, with `Reviewed-by: Eric Dumazet` and `Cc: stable@kernel.org`. A maintainer tree, not a released kernel. [Fix commit][commit] |
| Red Hat bulletin | 2026-10-24 18:31 (TZ not stated) | RHSB-2026-014: "Potentially Affected", Important; says upstream patches are not yet available and no CVEs are assigned. No RHEL fix. [Red Hat][rh] |
| CloudLinux 7 hybrid and 8 beta kernels | 2026-10-26 09:11 UTC | `kernel-4.18.0-553.177.1.lve.1.el7h` and `kernel-4.18.0-553.177.1.lve.1.el8`, beta and rolling out. [CloudLinux][cl] |
| Mainline, stable and longterm releases | None established as of 2026-10-26 ~11:20 EDT | The commit was not in `torvalds/linux` master (latest commit 2026-10-26 04:04 UTC, 7.4 merge window). Newest kernel.org releases (7.3 on 2026-10-18; 7.2.12, 6.18.58, 6.12.114, 6.6.160 on 2026-10-21; 6.1.190, 5.15.223, 5.10.272 on 2026-10-15) predate the fix. [kernel.org releases][releases] |
| CVE assignment | None as of this review | CloudLinux (updated 2026-10-26) and AlmaLinux say no CVE is assigned. The kernel CNA assigns CVEs after a fix reaches a stable tree. No Debian or Ubuntu tracker entry or notice was found. [CloudLinux][cl] [Kernel CVE process][kernelcve] |

## Detection

### Which hosts matter

Prioritize Linux hosts where someone other than the administrators can run code: shared hosting, CI runners and build farms, login and university nodes, Kubernetes nodes running untrusted workloads, and any server whose web applications could be compromised. A single-user host with no untrusted code is lower priority, not unaffected: an attacker who gains any foothold can use this to become root. [TuxCare][tux] [AlmaLinux][alma]

Affected status by distribution, as reported (not a complete matrix):

| Distribution / kernel line | Reported status | Source |
|---|---|---|
| AlmaLinux 8, 9, 10; CloudLinux 9, 10 | Root obtained with the public PoC | [CloudLinux][cl] [TuxCare][tux] |
| Debian 12 (6.1) and 13 (6.12) | Root obtained; 6.1 uses a TCP-based route | [TuxCare][tux] |
| Ubuntu 24.04 (6.8) and 26.04 (7.0) | Root obtained; AppArmor userns restriction bypassed | [TuxCare][tux] |
| RHEL | "Potentially Affected", Important; investigation ongoing | [Red Hat][rh] |
| CloudLinux 7 hybrid, 8, 8 ELS, 9 ELS; Ubuntu 22.04; Oracle UEK, cloud, HWE, FIPS and ESU kernels | Not tested; prerequisites present where checked. Treat as possibly affected. | [CloudLinux][cl] [TuxCare][tux] |
| CentOS 6 (2.6.32) and CentOS 7 / CloudLinux 7 (3.10) | Not affected: 2.6.32 predates `skb_zerocopy()`; 3.10's ESP always copies before decrypting | [TuxCare][tux] [CloudLinux][cl] |

### Kernel build and fix status

1. Record the **running** kernel with `uname -r`, and the installed packages with `rpm -q kernel` or `dpkg -l 'linux-image*'`. A newer installed package does not help until the host reboots into it.
2. Compare against a vendor build that explicitly includes "net: skbuff: propagate shared-frag marker in skb_zerocopy()" or names ZDI-CAN-33367. Known builds as of 2026-10-26 are listed under [Fixed kernels and live patches](#fixed-kernels-and-live-patches).
3. Do not accept a CVE-2026-43284, [CVE-2026-46300](https://www.cve.org/CVERecord?id=CVE-2026-46300) ("Fragnesia"), [CVE-2026-43503](https://www.cve.org/CVERecord?id=CVE-2026-43503) or CVE-2026-90049 fix as coverage. Those are different paths. Vulnerability scanners keyed on CVE IDs will not report this issue until a CVE exists. [Sysdig][sysdig] [TuxCare][tux]
4. With KernelCare, run `kcarectl --patch-info | grep -i 33367`. CloudLinux warns that `kcarectl --info` returns nothing for a specific issue even on a patched server. [CloudLinux][cl]

### Read-only exposure checks

Run on the host itself, not only inside a container:

```sh
uname -r
sysctl user.max_user_namespaces
sysctl kernel.unprivileged_userns_clone 2>/dev/null   # Debian-specific knob, if present
lsmod | grep -E '^(esp4|esp6|nlmon|act_pedit|nfnetlink_queue|nft_queue|cls_u32|act_mirred|xfrm_user) '
for m in esp4 esp6 nlmon act_pedit; do modprobe -n -v "$m"; done
```

- `user.max_user_namespaces = 0` closes the namespace step for ordinary accounts. **Any non-zero value means the path is open**; the number itself has no further meaning. On CloudLinux 8/9/10 the 0 default applies only to servers installed since mid-2024. [CloudLinux][cl] Sysdig names `kernel.unprivileged_userns_clone=0` as the Debian equivalent. [Sysdig][sysdig]
- **Do not count** Ubuntu's `kernel.apparmor_restrict_unprivileged_userns` as a mitigation. The PoC bypasses it through the AppArmor profile of an installed container-launcher package. [TuxCare][tux]
- `lsmod` shows only modules loaded now. These modules auto-load on demand, so an empty result does not mean they are unavailable. `modprobe -n -v <module>` printing `install /bin/false` confirms a block is configured, not that the exploit is stopped. [TuxCare][tux]
- Container platforms: check whether workloads can call `unshare(CLONE_NEWUSER)` or hold `CAP_NET_ADMIN`. Kubernetes pods run seccomp Unconfined unless `RuntimeDefault` is set per pod or with kubelet `--seccomp-default`; Docker's default profile blocks the call. [Sysdig][sysdig] [CloudLinux][cl]
- CageFS and LVE do not block the namespace step. CloudLinux confirmed this with a compiled test program; a shell test that "fails" only shows a missing tool. [CloudLinux][cl]

The existing [Linux inventory script](../linux-service-inventory.sh) checks only KSMBD, SMB/Plex listeners and RDMA devices. It does not cover this issue. Extending it with the read-only `sysctl`, `lsmod` and `modprobe -n -v` checks above would be a reasonable follow-up; it was not changed for this entry.

### Indicators and evidence limits

- **Runtime behavior:** the PoC runs as one unprivileged process. It unshares into new user and network namespaces, writes sysctls, brings up an `nlmon` interface, installs XFRM state over netlink, adds an nftables `NFQUEUE` rule, attaches a `tc` pedit action with a redirect, and then calls `splice()` into a socket on `127.0.0.1`. Sysdig says nothing legitimate does all of that from one unprivileged process. Sysdig Secure ships a rule, **Page Cache Poisoning via Spliced File Pages to Loopback**, in its Runtime Behavioral Analytics policy; it is available to Sysdig Secure customers. [Sysdig][sysdig]
- **Targets:** profiles in the public PoC source target `/usr/lib/x86_64-linux-gnu/security/pam_rootok.so` on Ubuntu and then run `su`. Earlier attacks of this class targeted setuid binaries such as `/usr/bin/su` and `/etc/passwd`. Other targets are possible. [ZDI report][report] [AlmaLinux][alma] [Sysdig][sysdig]
- **Evidence limits:**
  - The tampering lives only in the page cache. A reboot or eviction erases it, and the on-disk file stays unchanged. A disk image taken after the fact will not show the modification. [AlmaLinux][alma]
  - Package verification (`rpm -V`, `dpkg --verify`) on the live host reads through the page cache. A mismatch there can reflect tampered cached pages; a clean result after reboot or cache eviction proves nothing about earlier tampering. This is an inference from the mechanism, not a vendor-documented check.
  - The kernel write itself is not logged. Absence of alerts, kernel messages or file-integrity changes does not show the host was not attacked.

## Remediation

### Fixed kernels and live patches

The fix is a two-line change in `net/core/skbuff.c` that copies `SKBFL_SHARED_FRAG` to the destination buffer. It is in the netdev `net` tree as `79dc34beb1fd`, marked for stable, but **not in mainline or any kernel.org release** as of 2026-10-26. Use vendor builds; do not apply maintainer-tree commits to production kernels yourself. [Fix commit][commit] [kernel.org releases][releases]

| Distribution / product | Fixed build or status (as of 2026-10-26) | Channel | Source |
|---|---|---|---|
| AlmaLinux 8 | `kernel-4.18.0-553.178.1.el8_10` or later in production (testing `553.177.2` also carries the fix) | Production BaseOS since 2026-10-25; established from the repository and RPM changelog, no AlmaLinux announcement found | [AlmaLinux repository][almarepo] [AlmaLinux][alma] |
| AlmaLinux 9 | `kernel-5.14.0-687.59.2.el9_8` or later | `almalinux-testing` only | [AlmaLinux][alma] |
| AlmaLinux 10 | `kernel-6.12.0-211.68.2.el10_2` or later | `almalinux-testing` only | [AlmaLinux][alma] |
| AlmaLinux Kitten 10 | Next regular kernel update; no separate build | — | [AlmaLinux][alma] |
| CloudLinux 7 hybrid | `kernel-4.18.0-553.177.1.lve.1.el7h` | Beta (`cl7h_beta`), rolling out | [CloudLinux][cl] |
| CloudLinux 8 | `kernel-4.18.0-553.177.1.lve.1.el8` | Beta (`cloudlinux-updates-testing`), rolling out | [CloudLinux][cl] |
| CloudLinux 9, 10 | Follows the AlmaLinux kernels; no CloudLinux build released yet | — | [CloudLinux][cl] |
| CloudLinux 8 ELS, 9 ELS | Pending on the extended-support channel | — | [CloudLinux][cl] |
| TuxCare ELS AlmaLinux 9.2 ESU | `kernel-5.14.0-284.1101.el9_2.tuxcare.11.els17` lists the fix | OSV-imported TuxCare data (unconfirmed on TuxCare's site) | [OSV][osv] |
| KernelCare live patch | Released for EL10 (AlmaLinux, CloudLinux, RHEL, Oracle Linux, Rocky Linux 10) on 2026-10-23; EL9 in review; EL8 in progress; Debian/Ubuntu not started | KernelCare production feed (not yet ePortal, per TuxCare) | [TuxCare][tux] [CloudLinux][cl] |
| RHEL | No fix; "Potentially Affected", Important | — | [Red Hat][rh] |
| Debian, Ubuntu | No advisory, tracker entry or fixed kernel found | — | — |

- Install the fixed kernel and **reboot into it**. A testing or beta kernel is not production-supported: AlmaLinux recommends disabling `almalinux-testing` again after the reboot (`dnf config-manager --disable almalinux-testing`). [AlmaLinux][alma]
- Keep the previous kernel as a boot fallback; if you roll back, reapply the temporary mitigations below before returning the host to service.
- A live patch counts only when the vendor states coverage for this issue and `kcarectl --patch-info` shows it applied.

### Temporary mitigations

None of these has been confirmed by its source to stop every path to the bug. CloudLinux and TuxCare state they have **not tested** the user-namespace or module mitigations against the PoC. Treat them as compensating controls until a fixed kernel boots. [CloudLinux][cl] [TuxCare][tux]

1. **Disable unprivileged user namespaces** where nothing needs them. It applies without a reboot. It breaks rootless Podman/Docker, unprivileged LXC, Flatpak and some browser sandboxes. Existing namespaces keep running.

   ```sh
   echo 'user.max_user_namespaces = 0' > /etc/sysctl.d/99-zdi-33367.conf
   sysctl --system
   ```

   [CloudLinux][cl] [TuxCare][tux]
2. **Block `esp4` and `esp6`** on hosts that do not use IPsec. AlmaLinux says this blocks the PoC's write path; hosts that kept the Dirty Frag/Fragnesia module block are already covered. **IPsec workloads will break.** If `lsmod` still lists either module afterwards, it is in use and the host stays exposed until reboot.

   ```sh
   printf 'install esp4 /bin/false\ninstall esp6 /bin/false\n' > /etc/modprobe.d/zdi-can-33367.conf
   lsmod | grep -E '^esp(4|6)'   # no output = not loaded
   ```

   [AlmaLinux][alma]
3. **Block `nlmon` and `act_pedit`** where namespaces cannot be disabled (for example CI runners). Low impact on most servers, but confirm nobody uses `tc pedit` or `nlmon` first. It may not cover every path: the fix commit names Open vSwitch upcalls as a second `skb_zerocopy()` user. [CloudLinux][cl] [TuxCare][tux] [Fix commit][commit]

   ```sh
   printf 'install nlmon /bin/false\ninstall act_pedit /bin/false\n' > /etc/modprobe.d/zdi-33367.conf
   lsmod | grep -E '^(nlmon|act_pedit) '   # must print nothing, else unload safely or reboot
   ```

4. **Kubernetes:** enforce seccomp `RuntimeDefault` cluster-wide (kubelet `--seccomp-default`) so pods cannot create user namespaces, and avoid granting `CAP_NET_ADMIN` to untrusted workloads. [Sysdig][sysdig]
5. Ubuntu's AppArmor user-namespace restriction and CloudLinux CageFS are **not** mitigations for this issue. [TuxCare][tux] [CloudLinux][cl]

Do not force-unload modules that an active IPsec tunnel or tooling depends on; schedule a reboot instead. To revert a mitigation, remove the file under `/etc/sysctl.d/` or `/etc/modprobe.d/` and reload or reboot.

## Verification

- After reboot, confirm `uname -r` matches a fixed build in the table above (or later), on every node, and that the default boot entry cannot fall back to an unfixed kernel.
- For live patches, confirm with `kcarectl --patch-info | grep -i 33367`. [CloudLinux][cl]
- For interim controls, confirm `sysctl user.max_user_namespaces` prints `0`, `modprobe -n -v` prints `install /bin/false` for each blocked module, and `lsmod` lists none of them.
- Run benign functional controls: rootless containers or sandboxes you still need, IPsec tunnels you rely on, and `tc`/nftables tooling. Do **not** run the public PoC on production hosts; it modifies system files in memory.
- Record the result as **fixed build running**, **live patch applied and verified**, **mitigated pending fix**, or **unknown**. A scanner that finds no matching CVE is not a pass.

## Compromise response

- Treat suspected exploitation as **full root compromise** of the host, and on shared hosts as compromise of every tenant. [CloudLinux][cl]
- If forensics matter, capture memory before rebooting: the tampered page-cache contents are lost on reboot or eviction. [AlmaLinux][alma]
- AlmaLinux suggests `echo 3 > /proc/sys/vm/drop_caches` to evict tampered pages if a host may have been targeted before mitigation. Pages still mapped by running processes are not evicted; rebooting into the fixed kernel is more reliable. Neither removes persistence the attacker installed after gaining root. [AlmaLinux][alma]
- Investigate what ran as root after the likely exploitation time: new accounts, SSH keys, cron/systemd units, modified binaries on disk, kernel modules and container images. Rotate credentials and keys stored on or reachable from the host. Rebuild from trusted media where root compromise is confirmed or cannot be ruled out.
- Review which local account, CI job or web application provided the initial foothold; fixing the kernel does not close that entry point.

## Sources

- [ZDI-CAN-33367 report on LKML][report] (public report, CVSS vector, tested version 7.3-rc1 on Debian trixie, PoC source) and [ZDI upcoming advisories][zdi] (reported date, deadline, CVSS 3.0 calculator link).
- [Eric Dumazet's reply][dumazet], [v2 patch][patch] and [netdev `net` commit `79dc34beb1fd`][commit] — fix authorship, review, stable tag and commit time.
- [AlmaLinux, 2026-10-23][alma] — affected releases, testing kernels, `esp4`/`esp6` mitigation, cache-eviction guidance.
- [CloudLinux, updated 2026-10-26][cl] — confirmed root, affected matrix, beta kernels, KernelCare status, user-namespace and module mitigations, CageFS test.
- [TuxCare, 2026-10-22 (modified 2026-10-23)][tux] — tested kernels, AppArmor bypass, prerequisites, KernelCare status, exploitation status.
- [Sysdig, 2026-10-24][sysdig] — syscall sequence, detection rule, related CVEs, seccomp guidance, exploitation status.
- [Red Hat RHSB-2026-014][rh] — Red Hat severity and status.
- [OSV CLSA-2026-1792751700][osv] — TuxCare ELS AlmaLinux 9.2 ESU kernel.
- [The Hacker News, updated 2026-10-26][thn] — secondary summary; no new primary facts.
- [kernel.org releases][releases] and [kernel CVE process][kernelcve] — release and CVE status.

[report]: https://lore.kernel.org/lkml/BYAPR01MB3830CECF5D0871064C59BA0280662@BYAPR01MB3830.prod.exchangelabs.com/
[zdi]: https://www.zerodayinitiative.com/advisories/upcoming/
[dumazet]: https://lore.kernel.org/lkml/CAL4WiipTihtytPEPj5cSY+=t9NwRwRTfUQ_efCSWPT7nQ=0K0Q@mail.gmail.com/
[patch]: https://lore.kernel.org/all/20261022104217.1852191-1-pointerliu@126.com/
[commit]: https://github.com/kernelorg-mirror/linux_kernel_git_netdev_net/commit/79dc34beb1fdb3da79753e51e15c68591a2561fe
[alma]: https://almalinux.org/blog/2026-10-23-zdi-can-33367/
[cl]: https://blog.cloudlinux.com/zdi-can-33367
[tux]: https://tuxcare.com/blog/zdi-ksmbd-bugs-cve/
[sysdig]: https://www.sysdig.com/blog/detecting-and-mitigating-zdi-can-33367-and-five-other-linux-flaws
[rh]: https://access.redhat.com/security/vulnerabilities/RHSB-2026-014
[osv]: https://osv.dev/vulnerability/CLSA-2026-1792751700
[thn]: https://thehackernews.com/2026/10/two-cvss-90-linux-ksmbd-rce-flaws.html
[releases]: https://www.kernel.org/releases.json
[kernelcve]: https://docs.kernel.org/process/cve.html
[almarepo]: https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os/Packages/
