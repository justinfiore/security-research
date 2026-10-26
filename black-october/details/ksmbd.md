# Linux KSMBD: establish exposure and verify kernel-vendor fixes

**Last updated:** 2026-10-26 (America/New_York)

[Main guide](../black-october-2026.md#7-linux-ksmbd-serious-kernel-level-reports-but-not-every-linux-server) · [Changelog](../../Changelog.md)

**Scope:** ZDI-CAN-33774 (protocol-dispatch race) and ZDI-CAN-33549 (SMB Direct integer underflow) affect the **in-kernel KSMBD server**, not ordinary Samba `smbd`. ZDI rates both 9.0; public demonstrations establish memory disclosure/crashes, **not successful RCE**. [Research assessment][sysdig]

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
| Fixed mainline/stable/distribution releases | Not established as of this review | Sources do not provide a universal released-kernel or NAS-firmware matrix covering both issues. |

The October 26 news update points to existing maintainer work; the October 23 mailing-list follow-up additionally confirms a concrete SMB Direct patch was posted and reviewed. Neither fact certifies your running kernel. [Updated reporting][news]

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
- For 33774, supply commit `68f410faedaf` as a tracking reference; for 33549, supply the October 23 patch/review links. Require delivery confirmation rather than applying arbitrary development branches in production.
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
- [The Hacker News, updated October 26][news] — newer context; no universal distribution fix version.

[dispatch]: https://lore.kernel.org/lkml/BYAPR01MB383076AC412E19C48CFBEAE980662@BYAPR01MB3830.prod.exchangelabs.com/
[discussion]: https://lists.samba.org/archive/samba-technical/2026-October/141179.html
[patch]: https://lists.samba.org/archive/samba-technical/2026-October/141180.html
[review]: https://lists.samba.org/archive/samba-technical/2026-October/141181.html
[sysdig]: https://www.sysdig.com/blog/detecting-and-mitigating-zdi-can-33367-and-five-other-linux-flaws
[news]: https://thehackernews.com/2026/10/two-cvss-90-linux-ksmbd-rce-flaws.html
