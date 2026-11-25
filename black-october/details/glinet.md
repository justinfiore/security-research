# GL.iNet: the cloud service installed malware on routers and KVMs

**Last updated:** 2026-11-24 (America/New_York)

[Main summary](../black-october-2026.md#glinet-the-cloud-service-installed-malware-on-routers-and-kvms) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

GL.iNet makes routers and KVM devices, the boxes that control a computer remotely. On November 20 it said an unauthorized party used a vulnerability in its cloud remote management service, GoodCloud, to install malware on some of those devices. The November 23 update of the notice says the identified cloud path was blocked that day, and that the security firmware disables the known malware and removes the related files and traces.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** The notice, updated November 23, 2026 (UTC), says GL.iNet has submitted CVE reports and that the identifiers are pending. It names the cause: GoodCloud's MQTT messaging service, deployed with EMQX, had a configuration error in message authorization, so a client could send management messages to other users' devices. The [GoodCloud report](https://github.com/gl-inet/CVE-issues/blob/main/GoodCloud/EMQX%20Authorization%20Bypass%20Leading%20to%20Remote%20Code%20Execution.md) says GoodCloud **v3.19.13** is affected and **v3.19.14** is fixed. That is a fix on GL.iNet's service, not a claim about every EMQX install.

A second report, linked from the same notice, says an AstroWarp/SD-WAN field runs a command as root on listed routers even when AstroWarp is off. A third says RTTY certificate checks can be bypassed. The notice says those are separate issues. The RTTY report names KVM fixes at **1.10.3** and RMQ1 **1.8.7**, and its router rows still say "expected fix."

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Security incident** | **2026-11-20; time unknown** | Unauthorized access to some GoodCloud-connected routers and KVM devices. The identified cloud path was blocked the same day. [Notice][notice] |
| Notice updated | 2026-11-21 04:25 UTC | Earlier update. Cloud path closed. Firmware still being prepared. |
| Notice updated | 2026-11-22 (UTC); time unknown | Community security check added. |
| **Notice updated** | **2026-11-23 (UTC); time unknown** | Pending CVE reports, the EMQX authorization error, and the recovery change: the firmware removes the known malware, and a factory reset alone does not install the fixes. |
| Forum notice adds models | 2026-11-24 04:04 UTC | The staff post's download table adds fourteen router models: GL-A1300 and GL-X300B at 4.5.24, and twelve models at 4.3.31. [Forum][forum] |

## Detection

The November 23 notice says updating is the primary action, and that a check is optional and is not required before the update. A check that finds nothing does not clear the device. Restarting or updating can remove the signs, so a check has to happen first if you want one.

1. GL.iNet's first choice for a broader check is the [community security check](https://gl-i.net/security/csa-2026-01/fix/), in check-only mode. It is a third-party script. Read it before running it.
2. For a KVM, the notice points at a [forum quick check](https://forum.gl-inet.com/t/quickly-check-if-your-kvm-is-under-attack/73069/1). A negative result does not rule out compromise.
3. The earlier staff post named a process running `crond -i /tmp/.log`. That check is no longer on the notice. A line that is only the `grep` command is not a match.

## Remediation

1. Install the security firmware for the exact model, from the notice's download table. You do not need a terminal check first. The notice says the firmware disables the known malware and removes its related files and the traces it identified, including when settings are kept. It is not a general malware scan.

   | Model | Minimum version |
   |---|---|
   | GL-MG1300, GL-MT3000, GL-MT6000 | 4.11.1 |
   | GL-E5800 | 4.10.3 |
   | GL-BE3600, GL-BE9300 | 4.10.2 |
   | GL-BE14000 | 4.9.3 |
   | GL-BE6500, GL-MT3600BE, GL-MT5000 | 4.9.1 |
   | GL-BE10000 | 4.8.7 |
   | GL-AX1800, GL-AXT1800, GL-SFT1200, GL-X3000, GL-XE3000 | 4.8.4 |
   | GL-MT2500 / GL-MT2500A, GL-X2000 | 4.7.14 |
   | GL-A1300, GL-X300B | 4.5.24 |
   | GL-AP1300, GL-AR300M (NAND), GL-AR300M16, GL-AR750, GL-AR750S-EXT, GL-B1300, GL-E750 / GL-E750V2, GL-MT1300, GL-MT300N-V2, GL-X750, GL-XE300 | 4.3.31 |
   | RM1, RM1V2, RM10, RM10RC, RM1PE, RM4PE | 1.10.3 |
   | RMQ1 | 1.8.7 |

   GL-AXT1800: if the device already shows 4.8.4 and you do not know which build it is, ask support@gl-inet.com. A model that is not in the table has no build named here. Do not install another model's firmware.
2. A device that never connected to GoodCloud does not need a reset or new passwords because of this incident. A device that did connect should have its administrator password changed, and VPN and SSH keys stored on it replaced, after the update. An update cannot revoke a key that was already copied. Some KVMs connect before an account is linked, so the lack of an account is not proof it never connected.
3. If access is known or suspected, the strongest recovery is to install the firmware without keeping settings, then configure the device again with new passwords and keys. On a router, turn **Keep Settings** off. On a KVM, clear **Save current configuration**. Keeping settings is still allowed, and the notice says that can leave other unauthorized changes. A factory reset alone does not install the security fixes.
4. The cloud fix does not remove malware already on a device, and it does not update the device. Do not wait for the email. GL.iNet says not receiving one is not proof the device was unaffected.

## Verification

- The running firmware is at least the version in the table for that model. A model with no row has no published security build to check against.
- Do not probe the cloud service. GL.iNet's statement is the record that the path was blocked.

## Compromise response

A device GL.iNet identified, or one with evidence of unauthorized access, was reached. On an affected KVM, check the connected computer for unfamiliar accounts, software, browser extensions, startup items, or settings changes, and run a full scan. The notice says that check is a precaution and does not mean the computer was reached. Replace credentials stored on the GL.iNet device. Connecting another computer by Ethernet or Wi-Fi does not, by itself, mean that computer's passwords were copied. GL.iNet says it has not confirmed access to other devices through a compromised unit, and that it is still determining how many devices were affected and whether computers on affected KVMs were reached.

## Sources

- [GL.iNet security notice, 2026-11-20][notice] — read 2026-11-23. Updated November 23, 2026 (UTC). Title "Security Notice: GoodCloud Remote Management Incident." EMQX authorization error. Firmware removes the known malware. CVE identifiers pending. No score.
- [GoodCloud report](https://github.com/gl-inet/CVE-issues/blob/main/GoodCloud/EMQX%20Authorization%20Bypass%20Leading%20to%20Remote%20Code%20Execution.md) — linked from the notice. v3.19.13 affected, v3.19.14 fixed.
- [AstroWarp command injection report](https://github.com/gl-inet/CVE-issues/blob/main/4.0.0/AstroWarp(SDWAN)%20API%20Command%20Injection%20via%20thevirtual_ip_info%20Field%20Allows%20Arbitrary%20Command%20Execution%20as%20Root.md) — linked from the notice. Router rows say "expected fix."
- [RTTY report](https://github.com/gl-inet/CVE-issues/blob/main/common/Root%20Access%20via%20Rtty%20Configuration%20Modification%20and%20TLS%20Certificate%20Verification%20Bypass.md) — linked from the notice. KVM fixed at 1.10.3 and RMQ1 1.8.7.
- [GL.iNet forum announcement][forum] — the earlier staff post. The notice now points KVM checks here.
- [CISA KEV JSON][kev] — catalog 2026.11.23, checked 2026-11-23. No CVE to match.

[notice]: https://www.gl-inet.com/en-us/blogs/blog/glinet-security-notice-2026-11-20/
[forum]: https://forum.gl-inet.com/t/2026-11-20-gl-inet-security-notice-goodcloud-kvm-routers/73056
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
