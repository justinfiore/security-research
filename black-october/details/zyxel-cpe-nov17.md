# Zyxel CPE: a request writes past the buffer before login

**Last updated:** 2026-11-18 (America/New_York)

[Main Zyxel CPE summary](../black-october-2026.md#zyxel-cpe-a-request-writes-past-the-buffer-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-79614](https://www.cve.org/CVERecord?id=CVE-2026-79614) is an out-of-bounds write in `libclinkc.so` on certain Zyxel DSL/Ethernet CPE, fiber ONTs, and wireless extenders. Zyxel is the CNA and rates it **CVSS 3.1 9.8 Critical**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. A crafted HTTP request with no login can raise privileges and potentially run a command. Zyxel says **WAN access is disabled by default** on these devices.

The same advisory covers [CVE-2026-86676](https://www.cve.org/CVERecord?id=CVE-2026-86676), CVSS 3.1 7.2. That one needs an administrator login, and Zyxel says it works only if that password is already compromised. The two do not share the same affected-version rows: the 9.8 flaw is "and earlier," and the 7.2 flaw names one build per model.

This is not the [GS1900](zyxel-gs1900.md) switch flaw and not the [access-point](zyxel-aps.md) flaw.

**CISA KEV:** Not listed (catalog 2026.11.17, checked 2026-11-18). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-17; time unknown** | Zyxel advisory, revision history "Initial release." [Zyxel][adv] |
| CVE record | 2026-11-17 02:17:22 UTC | NVD published time. The record names DX3301-T0 and EX3301-T0 through 5.50(ABVY.8.3)C0. The advisory names more models. |
| **Last updated** | **2026-11-18 (America/New_York)** | New item. Install the listed firmware. |

## Detection

Read the firmware version from the device's status page. Match it against the advisory, not against the two models in the CVE record. Zyxel says a product on sale that is absent from the table is not affected, and that ISP-customized models are not in the table.

The CVE-2026-79614 rows, copied from the advisory:

| Family | Model | Affected | Fixed |
|---|---|---|---|
| DSL/Ethernet CPE | DX3300-T0, DX3300-T1, DX3301-T0, EX3300-T0, EX3300-T1, EX3301-T0 | 5.50(ABVY.8.3)C0 and earlier | 5.50(ABVY.8.4)C0 |
| DSL/Ethernet CPE | DX4510-B0, DX4510-B1 | 5.17(ABYL.10.4)C0 and earlier | 5.17(ABYL.10.5)C0 |
| DSL/Ethernet CPE | DX5401-B1, EX5401-B1 | 5.17(ABYO.7.4)C0 and earlier | 5.17(ABYO.7.5)C0 |
| DSL/Ethernet CPE | EE3301-00 | 5.63(ACMU.3.3)C0 and earlier | 5.63(ACMU.3.4)C0 |
| DSL/Ethernet CPE | EE5301-00 | 5.63(ACLD.3.3)C0 and earlier | 5.63(ACLD.3.4)C0 |
| DSL/Ethernet CPE | EE6510-10 | 5.19(ACJQ.4.4)C0 and earlier | 5.19(ACJQ.4.5)C0 |
| DSL/Ethernet CPE | EMG3525-T50B, EMG5523-T50B, VMG3625-T50B, VMG8623-T50B | 5.50(ABPM.9.11)C0 and earlier | 5.50(ABPM.9.12)C0 |
| DSL/Ethernet CPE | EMG6726-B10A | 5.13(ABNP.8.3)C0 and earlier | 5.13(ABNP.8.4)C0 |
| DSL/Ethernet CPE | EX2210-T0 | 5.50(ACDI.2.7)C0 and earlier | 5.50(ACDI.2.8)C0 |
| DSL/Ethernet CPE | EX3500-T0, EX3501-T0 | 5.44(ACHR.6.1)C0 and earlier | 5.44(ACHR.6.2)C0 |
| DSL/Ethernet CPE | EX3510-B0, EX3510-B1 | 5.17(ABUP.15.4)C0 and earlier | 5.17(ABUP.15.5)C0 |
| DSL/Ethernet CPE | EX3600-T0 | 5.70(ACIF.3.3)C0 and earlier | 5.70(ACIF.3.4)C0 |
| DSL/Ethernet CPE | EX5510-B0 | 5.17(ABQX.11.3)C0 and earlier | 5.17(ABQX.11.4)C0 |
| DSL/Ethernet CPE | EX5512-T0 | 5.70(ACEG.5.8)C0 and earlier | 5.70(ACEG.5.9)C0 |
| DSL/Ethernet CPE | EX5601-T0, EX5601-T1 | 5.70(ACDZ.6.3)C0 and earlier | 5.70(ACDZ.6.4)C0 |
| DSL/Ethernet CPE | EX7501-B0 | 5.18(ACHN.3.4)C0 and earlier | 5.18(ACHN.3.5)C0 |
| DSL/Ethernet CPE | EX7710-B0 | 5.18(ACAK.1.9)C0 and earlier | 5.18(ACAK.1.10)C0 |
| DSL/Ethernet CPE | GM4100-B0 | 5.18(ACCL.2.2)C0 and earlier | 5.18(ACCL.3)C0 |
| DSL/Ethernet CPE | VMG3927-T50K, VMG4927-B50A | 5.13(ABLY.10.3)C0 and earlier | 5.13(ABLY.10.4)C0 |
| DSL/Ethernet CPE | VMG4005-B50A, VMG4005-B60A | 5.17(ABQA.3.5)C0 and earlier | 5.17(ABQA.3.6)C0 |
| DSL/Ethernet CPE | VMG4005-B50B | 5.13(ABRL.5.6)C0 and earlier | 5.13(ABRL.5.7)C0 |
| Fiber ONT | AM7510-00 | 5.63(ACOR.0.4)C0 and earlier | 5.63(ACOR.0.5)C0 |
| Fiber ONT | AX7501-B1 | 5.17(ABPC.8.1)C0 and earlier | 5.17(ABPC.8.2)C0 |
| Fiber ONT | PE5301-01 | 5.63(ACOJ.3.3)C0 and earlier | 5.63(ACOJ.3.4)C0 |
| Fiber ONT | PM3100-T0, PM5100-T0, PM5100-T1 | 5.42(ACBF.4.5)C0 and earlier | 5.42(ACBF.4.6)C0 |
| Fiber ONT | PM7300-T0 | 5.42(ABYY.4.3)C0 and earlier | 5.42(ABYY.4.4)C0 |
| Fiber ONT | PM7500-00 | 5.61(ACKK.1.6)C0 and earlier | 5.61(ACKK.1.7)C0 |
| Wireless extender | WE3300-00 | 5.70(ACKA.2.1)C0 and earlier | 5.70(ACKA.2.2)C0 |
| Wireless extender | WX3100-T0 | 5.50(ABVL.5.2)C0 and earlier | 5.50(ABVL.5.3)C0 |
| Wireless extender | WX5600-T0 | 5.70(ACEB.6.4)C0 and earlier | 5.70(ACEB.6.5)C0 |
| Wireless extender | WX5610-B0 | 5.18(ACGJ.0.6)C0 and earlier | 5.18(ACGJ.0.7)C0 |

A device whose WAN interface is disabled is still affected on the LAN. Zyxel does not say the LAN is safe.

## Remediation

1. Ask Zyxel or the ISP that supplied the device for the fixed file. The advisory says the file is not published for download, and that an ISP build may differ from the table.
2. Install the fixed build for that model and reboot.
3. Leave WAN administration off. Zyxel says it is off by default, and turning it on is not required for the flaw to exist on the LAN.
4. The upgrade does not show whether a request already ran a command.

## Verification

- The status page shows the fixed build for that model, or a later one.
- Do not send the request the advisory describes.

## Compromise response

Zyxel publishes no indicator. A process you did not start, or a configuration change with no matching administrator login, is a lead. It is not proof. Change the administrator password after the upgrade if the device was reachable before the fixed build.

## Sources

- [Zyxel advisory, 2026-11-17][adv] — initial release 2026-11-17. CVE-2026-79614 and CVE-2026-86676. WAN access disabled by default. Patch files are not a public download.
- [CVE-2026-79614](https://www.cve.org/CVERecord?id=CVE-2026-79614) — CNA Zyxel. CVSS 3.1 9.8. The record names DX3301-T0 and EX3301-T0 through 5.50(ABVY.8.3)C0. NVD published 2026-11-17 02:17:22 UTC.
- [CVE-2026-86676](https://www.cve.org/CVERecord?id=CVE-2026-86676) — CVSS 3.1 7.2. Needs an administrator password.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.17, read 2026-11-18. Neither CVE is in it.

[adv]: https://www.zyxel.com/service-provider/emea/en/security-advisories/zyxel-security-advisory-out-of-bounds-write-post-authentication-command-injection-vulnerabilities-cpe-onts-extenders-11-17-2026
