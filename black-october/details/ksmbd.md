# Linux KSMBD: establish exposure and verify kernel-vendor fixes

**Last updated:** 2026-11-06 (America/New_York)

[Main guide](../black-october-2026.md#7-linux-ksmbd-serious-kernel-level-reports-but-not-every-linux-server) · [Changelog](../../CHANGELOG.md)

**Scope:** ZDI-CAN-33774 (protocol-dispatch race) and ZDI-CAN-33549 (SMB Direct integer underflow) affect the **in-kernel KSMBD server**, not ordinary Samba `smbd`. ZDI rates both 9.0; public demonstrations establish memory disclosure/crashes, **not successful RCE**. [Research assessment][sysdig]

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. No exploitation reported in the reviewed sources. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Distinguish KSMBD from unrelated SMB services](#distinguish-ksmbd-from-unrelated-smb-services)
  - [Evaluate the two prerequisites independently](#evaluate-the-two-prerequisites-independently)
  - [Evidence limits and incident triage](#evidence-limits-and-incident-triage)
- [Remediation](#remediation)
  - [Temporary risk reduction](#temporary-risk-reduction)
  - [Obtain a release that covers both reports](#obtain-a-release-that-covers-both-reports)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date | Evidence and qualification |
|---|---|---|
| Initial discovery / private reports | Unknown | No definitive private discovery/report dates for these ZDI findings in the reviewed sources. |
| ZDI-CAN-33774 fix authored for a different report | 2026-09-30 | Commit `68f410faedaf`, “ksmbd: wait for negotiation before receiving another PDU.” Not a released kernel. [Sysdig][sysdig] |
| ZDI-CAN-33774 public report | 2026-10-21 | Public LKML message timestamp; security address and public lists were copied together. [ZDI report][dispatch] |
| ZDI-CAN-33549 public report | 2026-10-21 | Dated original report quoted in maintainer discussion. [Discussion][discussion] |
| ZDI-CAN-33774 fix queued | 2026-10-21 | `ksmbd-for-next` maintainer branch, per Sysdig; not proof of distribution delivery. [Sysdig][sysdig] |
| ZDI-CAN-33549 small patch posted | 2026-10-23, 10:36 UTC | Namjae Jeon attached the buffer-length-underflow patch after discussion of the 7.5 development branch. [Patch message][patch] |
| ZDI-CAN-33549 patch review | 2026-10-23, 11:02 UTC | Stefan Metzmacher: “looks good.” This supersedes “only discussing a fix,” not the need for a released vendor package. [Review][review] |
| ZDI-CAN-33774 fix merged into mainline | 2026-10-26 01:47:41 UTC (2026-10-25 21:47 EDT) | Linus Torvalds merged `ksmbd-for-7.4-rc1` (merge `4e1b4fdf6113`), which contains `68f410faedaf`. The commit carries no `Cc: stable` tag and credits a different reporter; the ZDI-CAN-33774 mapping comes from Sysdig. [Merge][merge] [Commit][fix33774] [Sysdig][sysdig] |
| ZDI-CAN-33549 fix committed to `ksmbd-for-next` | 2026-10-26 19:15:10 +0900 (10:15:10 UTC) | `7193241a49c9`, “smb: smbdirect: fix buffer length underflow in RDMA transfers” (authored by Stefan Metzmacher 2026-10-23), with `Reported-by: … # ZDI-CAN-33549` and `Cc: stable@vger.kernel.org`. [Commit][fix33549] |
| Both fixes in Linux 7.4-rc1 | 2026-11-01 21:26:31 UTC | Linus Torvalds tagged `v7.4-rc1` (`6628e7d4c6b2`). GitHub's compare of each fix commit to that tag is `behind 0`, so both commits are in the tag. This is a release candidate, not a stable release. [Tag][tag74] |
| ZDI-CAN-33774 in stable Linux 7.2.15 | 2026-11-01 | ChangeLog-7.2.15 includes `aaf8a64a3fbf`, the backport of `68f410faedaf`. Linux 7.2 is marked EOL. 7.3.1 does not contain this commit. [ChangeLog-7.2.15][cl7215] |
| Stable and distribution releases | ZDI-CAN-33549 still none as of 2026-11-02 | `linux-7.3.y` does not contain `7193241a49c9`, and ChangeLog-7.2.15 does not either. Latest stable at review was 7.3.1 (2026-10-30). No distribution or NAS package naming either report was found. |
| Red Hat applicability statement (RHSB-2026-014) | 2026-10-24 18:31; TZ not stated | “No supported versions of Red Hat Enterprise Linux are affected by these vulnerabilities. The affected kernel modules are not built or the vulnerable features are not enabled.” [Red Hat][rhsb] |
| CVE assignment | None as of this review | Neither report has a CVE; the kernel CNA assigns CVEs after a fix reaches a stable tree. [Kernel CVE process][kernelcve] [Updated reporting][news] |

The October 26 news update points to existing maintainer work. Both fix commits are in the **7.4-rc1** tag. That tag is not a stable kernel. Stable **Linux 7.2.15** (2026-11-01) backports only the ZDI-CAN-33774 fix, as `aaf8a64a3fbf`. It does not contain the ZDI-CAN-33549 fix, and Linux 7.2 is marked EOL. No distribution package was found. Do not boot 7.4-rc1, or 7.2.15 unless that is already your line, to get the fix. None of these facts certifies your running kernel. [Updated reporting][news] [ChangeLog-7.2.15][cl7215]

## Detection

### Distinguish KSMBD from unrelated SMB services

From the `black-october` directory on a trusted Linux/NAS **host**, review and run the existing [Linux inventory script](../linux-service-inventory.sh):

```sh
sh linux-service-inventory.sh
```

1. Record the running kernel and vendor package/firmware build. The script checks `/sys/module/ksmbd`, TCP 445 listeners and visible RDMA devices, but only in its current namespace.
2. Confirm `CONFIG_SMB_SERVER` in the actual kernel configuration, whether KSMBD is built-in or a module, and whether `ksmbd.mountd` and KSMBD shares are configured. A package being installed does not prove the server is active.
3. Identify the owner/implementation of each SMB listener through host/vendor tooling. TCP 445 alone cannot distinguish Samba from KSMBD; `lsmod` alone can miss built-in functionality.
4. Check NAS firmware documentation and the storage host, not only an application container. A minimal container may hide host sysfs/configuration and produce incomplete results.
5. Record routing and firewall access from client VLANs, VPNs and other tenants. No public internet exposure does not imply no attacker-reachable path.

### Evaluate the two prerequisites independently

| Report | What to establish | What does not clear it |
|---|---|---|
| ZDI-CAN-33774 | KSMBD reachable for protocol negotiation; pre-authentication read/crash path, with share access relevant to the described write path. [ZDI][dispatch] [Sysdig][sysdig] | Strong passwords, no RDMA, or read-only shares do not remove the pre-authentication path. |
| ZDI-CAN-33549 | SMB Direct enabled, hardware RDMA **or software RXE**, writable KSMBD share and a client able to negotiate SMB Direct. [Discussion][discussion] | No physical RDMA card does not exclude software RDMA; blocking only ordinary SMB TCP may not address every enabled transport. |

**Distribution build status:** Red Hat says supported RHEL is not affected because the modules are not built or the features are not enabled. [Red Hat][rhsb] TuxCare reports that AlmaLinux and CloudLinux 9 and 10 do not build KSMBD at all, while Debian and Ubuntu build it as opt-in: it runs only after an administrator installs `ksmbd-tools` and starts the `ksmbd` service. [TuxCare][tuxcare] Sysdig reports that Ubuntu builds SMB Direct support and Debian does not. [Sysdig][sysdig] These statements cover stock distribution kernels only; custom, appliance and NAS kernels still need the vendor's own statement.

The reports tested **7.3-rc3**; that is a tested version, not a complete affected range or minimum affected version. The SMB Direct report used a custom kernel with `CONFIG_SMB_SERVER_SMBDIRECT=y` and `CONFIG_RDMA_RXE=y` on Debian: do not infer immunity from a distribution’s default configuration alone. [ZDI][dispatch] [Discussion][discussion]

### Evidence limits and incident triage

- Recommended: preserve off-host kernel logs, crash dumps and network telemetry; investigate unexpected KSMBD worker faults or `init_smb2_rsp_hdr`/RDMA-copy stack traces in context.
- Production kernels may lack KASAN and detailed diagnostics. A clean journal or absent crash does not exclude disclosure, and a generic kernel crash does not prove an attack.
- Syscall sensors can observe module/service activation and later process/file activity, but not necessarily the kernel-thread race/overflow itself. Do not mistake a generic post-exploitation rule for direct detection. [Sysdig][sysdig]
- Sysdig reported **no in-the-wild exploitation as of October 24**. This is a dated observation, not a guarantee through the current review or a reason to wait for a CVE identifier.

## Remediation

### Temporary risk reduction

1. If KSMBD is unnecessary, schedule storage downtime, stop it with the vendor-supported procedure and prevent automatic restart/module loading. Do not force-unload a busy storage module.
2. If it must remain, restrict SMB to necessary client networks and hosts at the host and perimeter. Remove internet exposure and guest/unneeded writable shares.
3. Disable **SMB Direct** using supported configuration if it is not required, and verify the RDMA transport is actually unavailable. This addresses the second finding’s prerequisites, not the first.
4. For built-in KSMBD, module blacklisting alone is ineffective; use service/configuration isolation and vendor guidance. If service termination is uncertain, isolate the host until it can be safely rebooted/configured.
5. These are compensating controls, not proof that vulnerable code is fixed. Moving to Samba is a separate storage migration requiring ACL, share and backup validation, not a drop-in patch.

### Obtain a release that covers both reports

- Ask the distribution/NAS supplier to map the **exact running build** to ZDI-CAN-33774 and ZDI-CAN-33549, including backport identifiers and relevant kernel configuration.
- For 33774, supply commit `68f410faedaf`; for 33549, supply `7193241a49c9`. Both are in the Linux 7.4-rc1 tag (2026-11-01). Stable Linux 7.2.15 backports only `68f410faedaf`, as `aaf8a64a3fbf`, and that line is EOL. **Linux 7.3.2** (2026-11-06) backports both: the negotiation wait as `d4a52e78378a`, and the SMB Direct length check as `956968544ae6`. **Linux 6.18.62** the same day backports both as `49675f7bc0e1` and `1f5c774488fa`. Require a stable or vendor package that names the report you actually run. Do not install 7.4-rc1 as the remediation.
- Install the supported kernel/firmware and reboot into it, following storage-cluster/failover procedures. A `ksmbd-tools` update alone does not establish that kernel code changed.
- A live patch is acceptable only with explicit vendor coverage for the relevant functions and a verified applied state; do not assume other Linux patches cover these reports.

## Verification

- Rerun inventory after reboot and reconcile the running kernel with the vendor’s package/build record, not merely the installed package list.
- Verify every storage node and failover target; ensure the next boot cannot silently return to an unpatched image.
- For containment, confirm KSMBD is stopped or restricted from an authorized untrusted network and that SMB Direct remains disabled where intended.
- With harmless test files, verify expected SMB access, read/write ACLs and normal client operation after an approved patch. Do not send race/overflow probes to a production file server.
- Record either **both reports fixed**, **service exposure removed**, or **status unknown with compensating controls**. An absent CVE in a vulnerability scanner is not clearance.

## Compromise response

- Treat credible kernel compromise as a host-wide incident, not merely a damaged share. Preserve evidence using clean systems and retain hypervisor/off-host logs where available.
- Rebuild the OS/NAS from trusted vendor media and restore reviewed data rather than relying on a kernel reboot to eliminate persistence.
- Review share contents and backup changes, host administration, service accounts and credentials usable from the storage server; rotate exposed credentials after containment.
- Investigate clients and management networks reached from the host. A crash-only finding warrants fault investigation, but does not by itself establish credential theft or successful RCE.

## Sources

- [ZDI dispatch report][dispatch]; [SMB Direct discussion][discussion]; [October 23 patch][patch] and [review][review] — primary report and maintainer evidence.
- [Sysdig October 24 analysis][sysdig] — tested impact, commit status, telemetry limits and scoped mitigations.
- [Red Hat RHSB-2026-014][rhsb] and [TuxCare][tuxcare] — distribution build and applicability statements.
- [The Hacker News, updated October 26][news] — newer context; no universal distribution fix version.
- [`ksmbd-for-7.4-rc1` mainline merge][merge], [ZDI-CAN-33774 fix commit][fix33774], [ZDI-CAN-33549 fix commit][fix33549], [kernel.org release list][releases] and [kernel CVE process][kernelcve] — fix landing, release and CVE status as of 2026-10-26.

[dispatch]: https://lore.kernel.org/lkml/BYAPR01MB383076AC412E19C48CFBEAE980662@BYAPR01MB3830.prod.exchangelabs.com/
[discussion]: https://lists.samba.org/archive/samba-technical/2026-October/141179.html
[patch]: https://lists.samba.org/archive/samba-technical/2026-October/141180.html
[review]: https://lists.samba.org/archive/samba-technical/2026-October/141181.html
[sysdig]: https://www.sysdig.com/blog/detecting-and-mitigating-zdi-can-33367-and-five-other-linux-flaws
[news]: https://thehackernews.com/2026/10/two-cvss-90-linux-ksmbd-rce-flaws.html
[merge]: https://github.com/torvalds/linux/commit/4e1b4fdf6113b4eb9564bdf3b76ee3c3132da7d4
[fix33774]: https://github.com/torvalds/linux/commit/68f410faedaf6ee74d81e574733c50ebcc1bd8ed
[fix33549]: https://git.kernel.org/pub/scm/linux/kernel/git/linkinjeon/smb.git/commit/?h=ksmbd-for-next&id=7193241a49c958782ba4b8df06da3734d1e317d2
[tag74]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tag/?h=v7.4-rc1
[cl7215]: https://cdn.kernel.org/pub/linux/kernel/v7.x/ChangeLog-7.2.15
[releases]: https://www.kernel.org/releases.json
[kernelcve]: https://docs.kernel.org/process/cve.html
[rhsb]: https://access.redhat.com/security/vulnerabilities/RHSB-2026-014
[tuxcare]: https://tuxcare.com/blog/zdi-ksmbd-bugs-cve/
