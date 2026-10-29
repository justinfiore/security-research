# TianoCore EDK II: PXE pre-boot remote code execution

**Last updated:** 2026-10-28 (America/New_York)

[Main summary](../black-october-2026.md#tianocore-edk-ii-pxe-pre-boot-remote-code-execution) · [Main TOC](../black-october-2026.md#table-of-contents)

**[CVE-2026-97631](https://www.cve.org/CVERecord?id=CVE-2026-97631): TianoCore rates this CVSS 4.0 9.5 Critical** (`CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`). The affected `NetworkPkg/UefiPxeBcDxe` driver can copy oversized ICMP errors beyond its fixed receive buffer while a system is PXE booting.

**CISA KEV:** Not listed (catalog 2026.10.28, checked 2026-10-28). The advisory does not report active exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Public announcement | 2026-10-22; time/TZ unknown | TianoCore published GHSA-99cj-7hg9-mp4m. |
| Source fix | 2026-10-15; time/TZ unknown | Pull request 13302 was merged; the advisory still lists no patched EDK II release. |

## Detection

Inventory systems that PXE boot over IPv4 or IPv6, including provisioning and recovery workflows. Determine the firmware vendor and exact installed firmware build; EDK II is reference code, so a source-level fix does not establish that an OEM image includes it. A system not using PXE is not exposed through this driver path. Missing firmware inventory is **unknown**, not fixed.

## Remediation

Obtain a firmware update from the system or motherboard vendor that incorporates the TianoCore fix; do not build or flash an arbitrary upstream EDK II snapshot onto production hardware. Until a vendor release is available, disable PXE where it is not required and isolate provisioning networks so untrusted hosts cannot send ICMP errors to PXE clients. These controls reduce exposure only while a system is booting.

## Verification

Confirm the installed firmware version against the vendor's release notes, then test an ordinary authorized PXE boot on an isolated provisioning network. Do not send malformed ICMP traffic as a test.

## Compromise response

Treat suspected exploitation as firmware-level compromise: isolate the host, preserve provisioning and network logs, reflash from a vendor-trusted image where supported, and review OS deployment artifacts and credentials used during provisioning. OS reinstallation alone may not remove firmware persistence.

## Sources

- [TianoCore GHSA-99cj-7hg9-mp4m](https://github.com/tianocore/edk2/security/advisories/GHSA-99cj-7hg9-mp4m) — severity, affected component, conditions and patch status.
- [TianoCore PR 13302](https://github.com/tianocore/edk2/pull/13302) — proposed source fix.
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — KEV status.
