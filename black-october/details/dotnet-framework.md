# Microsoft .NET Framework: App Control bypass through an untrusted assembly search path

**Last updated:** 2026-10-26 (America/New_York)

[Main .NET Framework summary](../black-october-2026.md#microsoft-net-framework-app-control-bypass-through-an-untrusted-assembly-search-path) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-108398](https://www.cve.org/CVERecord?id=CVE-2026-108398): Microsoft CVSS 3.1 8.8 High (CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H; temporal 7.7 with E:U/RL:O/RC:C); Microsoft severity "Important". NVD has added no score of its own.** This is an untrusted-search-path flaw (CWE-426) in the **.NET Framework** (not .NET 5+/Core). Microsoft's FAQ says an authenticated local attacker "could place a specially crafted .NET assembly on an affected system and register it for loading by a protected process", which bypasses **Windows Defender Application Control (WDAC, now App Control for Business)** and runs code inside the protected process. No user interaction is required. Microsoft credits James Forshaw of Google Project Zero. [MSRC][msrc] [CVE record][cve]

**Who should care most:** organizations that rely on WDAC/App Control policies as a boundary against running unapproved code, such as locked-down workstations, kiosks, privileged-access workstations and servers. The attacker needs an existing low-privileged local foothold. Their gain is defeating application control, not initial access.

**Exploitation:** Microsoft lists it as **Publicly disclosed: Yes; Exploited: No; "Exploitation Less Likely"** at publication. No public exploit code was found in this review. CISA's ADP SSVC enrichment on the record marks Exploitation "none". [MSRC][msrc] [CVE record][cve]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and fixed builds](#inventory-and-fixed-builds)
  - [Read-only checks](#read-only-checks)
  - [Signs of abuse](#signs-of-abuse)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private report | Unknown | Credited to James Forshaw (Google Project Zero); report date not established. [MSRC][msrc] |
| Public disclosure before patch | Unknown | Microsoft marks it "Publicly disclosed: Yes" but gives no date or reference. [MSRC][msrc] |
| CVE reserved | 2026-10-09 21:52:56 UTC | CNA metadata. [CVE record][cve] |
| October 2026 Patch Tuesday updates and MSRC entry (public announcement) | 2026-10-13; time/TZ unknown on MSRC | MSRC revision 1.0 "Information published". The CVE record's `datePublic` is 2026-10-13T14:00:00Z. [MSRC][msrc] [CVE record][cve] |
| CVE record published | 2026-10-13 18:59:30 UTC | Record last updated 2026-10-25 18:37:20 UTC. [CVE record][cve] |
| NVD publication | 2026-10-13 19:18:04 UTC | Awaiting Analysis. [NVD][nvd] |
| CISA KEV | Not listed (catalog 2026.10.23) | Checked 2026-10-26. [KEV][kev] |

## Detection

### Inventory and fixed builds

All updates were released on 2026-10-13. KB numbers and build numbers are from the MSRC Security Updates table. [MSRC][msrc]

| Windows version | .NET Framework | KB | Fixed build(s) |
|---|---|---|---|
| Windows 11 26H2 | 3.5 and 4.8.1 | [KB5127694](https://support.microsoft.com/help/5127694) | 2.0.50727.9188 / 3.0.30729.9171 / **4.8.10008.0** (see note) |
| Windows 11 26H1 | 4.8.1 | [KB5127691](https://support.microsoft.com/help/5127691) | 4.8.9363.0 |
| Windows 11 25H2, 24H2; Server 2025 | 3.5 and 4.8.1 | [KB5127690](https://support.microsoft.com/help/5127690) | 2.0.50727.9188 / 3.0.30729.9171 / 4.8.9363.0 |
| Windows 11 23H2 | 3.5 and 4.8.1 | [KB5127692](https://support.microsoft.com/help/5127692) | 2.0.50727.9188 / 3.0.30729.9171 / 4.8.9363.0 |
| Windows 10 22H2, 21H2 | 3.5 and 4.8.1 | [KB5127689](https://support.microsoft.com/help/5127689) | 2.0.50727.9188 / 3.0.30729.9171 / 4.8.9363.0 |
| Windows 10 22H2, 21H2 | 3.5 and 4.8 | [KB5127683](https://support.microsoft.com/help/5127683) | 2.0.50727.9188 / 3.0.30729.9171 / 4.8.4811.0 |
| Windows Server 2022 | 3.5 and 4.8.1 | [KB5127693](https://support.microsoft.com/help/5127693) | 2.0.50727.9188 / 3.0.30729.9171 / 4.8.9363.0 |
| Windows Server 2022 | 3.5 and 4.8 | [KB5127687](https://support.microsoft.com/help/5127687) | 2.0.50727.9188 / 3.0.30729.9171 / 4.8.4811.0 |
| Windows Server 2019; Windows 10 1809 | 3.5 and 4.8 | [KB5127685](https://support.microsoft.com/help/5127685) | 2.0.50727.9073 / 3.0.30729.9070 / 4.8.4811.0 |
| Windows Server 2019; Windows 10 1809 | 3.5 and 4.7.2 (incl. 4.6.2–4.7.2) | [KB5127666](https://support.microsoft.com/help/5127666) | 2.0.50727.9073 / 3.0.30729.9070 / 4.7.4150.0 |
| Windows Server 2016; Windows 10 1607 | 4.8 | [KB5127684](https://support.microsoft.com/help/5127684) | 4.8.4811.0 |
| Windows Server 2016; Windows 10 1607 | 3.5 and 4.6.2–4.7.2 | [KB5126868](https://support.microsoft.com/help/5126868) | 2.0.50727.8987 / 3.0.30729.8982 / 4.7.4150.0 |
| Windows Server 2012 R2 | 4.8 | [KB5127688](https://support.microsoft.com/help/5127688) | 4.8.4811.0 |
| Windows Server 2012 R2 | 4.6.2–4.7.2 | [KB5127668](https://support.microsoft.com/help/5127668) | 4.7.4150.0 |
| Windows Server 2012 | 4.8 | [KB5127686](https://support.microsoft.com/help/5127686) | 4.8.4811.0 |
| Windows Server 2012 | 4.6.2–4.7.2 | [KB5127667](https://support.microsoft.com/help/5127667) | 4.7.4150.0 |

**Note on Windows 11 26H2:** MSRC lists build **4.8.10008.0** for KB5127694. The CVE record's affected range for 4.8.1 on 26H2 says "less than 4.8.9363.0". Rely on the KB being installed rather than on build comparisons for 26H2. [MSRC][msrc] [CVE record][cve] Windows Server 2012 and 2012 R2 are past end of support, and Microsoft normally delivers their updates only under Extended Security Updates. Confirm your eligibility (not verified for this KB).

### Read-only checks

Run these in Windows PowerShell as a standard user; the WDAC query may need an administrator. They only read state and change nothing. They were not exercised on a real host; replace the KB list with the row(s) for your OS.

```powershell
# Installed October .NET Framework security updates (KB list from the table above)
Get-HotFix | Where-Object HotFixID -in 'KB5127694','KB5127691','KB5127690','KB5127692','KB5127689','KB5127683','KB5127693','KB5127687','KB5127685','KB5127666','KB5127684','KB5126868','KB5127688','KB5127668','KB5127686','KB5127667'

# Installed .NET Framework 4.x release key (identifies 4.8 vs 4.8.1, not the patch level)
(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').Release

# Whether App Control/WDAC code-integrity policy is enforced (2 = enforced, 1 = audit)
(Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard).CodeIntegrityPolicyEnforcementStatus
```

`Get-HotFix` may not list every update type on every Windows version. Confirm with Windows Update history, WSUS/ConfigMgr/Intune compliance data, or the file-version information in each KB article. An empty result means **unknown**, not unpatched.

### Signs of abuse

Microsoft publishes no IOCs. According to the FAQ, exploitation means placing a crafted assembly and registering it for loading by a protected process. Review these as supporting evidence only:

- recently added assemblies and changes to .NET/COM registration in locations that low-privileged users can write to;
- the `Microsoft-Windows-CodeIntegrity/Operational` and `Microsoft-Windows-AppLocker/*` event logs, and EDR telemetry, for code from unexpected paths loading into protected processes.

The exact artifacts are not documented, so clean results do not prove the absence of a bypass.

## Remediation

1. Install the October 2026 .NET Framework update for each OS and .NET Framework version from the table, through Windows Update, WSUS/ConfigMgr/Intune or the Microsoft Update Catalog. Reboot if prompted. [MSRC][msrc]
2. Make sure .NET Framework update rings are not paused for WDAC/App Control-managed devices. Those devices gain the most from this fix.
3. Until patched, rely on layered controls: least privilege (no local admin), EDR and monitoring, and restricting who can write to directories that protected processes load from. These steps reduce but do not remove the bypass risk. Microsoft lists no workaround or mitigation on the reviewed MSRC page.

## Verification

- Confirm the applicable KB is installed and the device reports compliant in your management tool.
- Confirm WDAC/App Control policy still enforces after the update (the `CodeIntegrityPolicyEnforcementStatus` query) and that line-of-business .NET applications start normally.
- Do not attempt to load unsigned assemblies into protected processes as a test.

## Compromise response

- If you suspect application-control bypass on a device, treat the device as running unapproved code. Isolate it, collect EDR and event-log data, and investigate the low-privileged account that would have been needed.
- Remove unauthorized assemblies and registrations, reset credentials used on the device, and re-image if persistence is found.
- Review whether other devices share the same initial-access path.

## Sources

- [MSRC CVE-2026-108398][msrc]: score, vector, FAQ, exploitability, acknowledgement, KB and build table.
- [CVE record (Microsoft CNA)][cve]: affected ranges, timestamps, CISA ADP SSVC values; [NVD][nvd]; [CISA KEV feed][kev].

[msrc]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-108398
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-108398
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-108398
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
