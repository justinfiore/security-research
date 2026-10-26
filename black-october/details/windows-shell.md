# Windows Shell: Mark of the Web bypass zero-day

**Last updated:** 2026-10-26 (America/New_York)

[Main Windows Shell summary](../black-october-2026.md#windows-shell-mark-of-the-web-bypass-zero-day-cve-2026-96951) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-96951](https://www.cve.org/CVERecord?id=CVE-2026-96951) — Microsoft CVSS 3.1: 8.8 High (`AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`, temporal 8.2 with `E:F/RL:O/RC:C`); Microsoft severity: Important; impact: Security Feature Bypass; CWE-77.** Microsoft says a command-injection flaw in Windows Shell lets an attacker evade **Mark of the Web (MOTW)** defenses. Exploitation needs the user to open a crafted file or follow a link, for example from email or instant messaging (**UI:R**). Microsoft marks it **Exploited: Yes** and **Publicly disclosed: No**. CISA added it to KEV on 2026-10-13. NVD shows only Microsoft's score; no separate NVD score was found. **Worst case:** a crafted download or attachment opens without the usual MOTW, SmartScreen or Office Protected View warnings, so a malicious payload can run as the signed-in user. This CVE is a bypass that enables a follow-on payload. Microsoft does not describe it as wormable or as user-free remote code execution. Microsoft also lists **Outlook.com** (cloud service) as affected and fixed in service build **20260925.100**.

**CISA KEV:** Listed — added 2026-10-13, federal due date 2026-10-16. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Establish exposure](#establish-exposure)
  - [Look for exploitation](#look-for-exploitation)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | MSRC acknowledges yhw; Benoit Sevens (credited as "using Claude with Anthropic"); and Riku Bamba and Yuya Chudo of Fujitsu Limited. No report dates are published. [MSRC CVRF][cvrf] |
| CVE ID reserved | 2026-09-23 20:35:19 UTC | This is when the CVE ID was reserved. It is not the discovery or exploitation date. [CVE JSON][cve] |
| Outlook.com service fix | Unknown; fixed build `20260925.100` | MSRC lists Outlook.com as fixed in build 20260925.100. The deployment date is not given. Rapid7 says the build is dated "several weeks" before Patch Tuesday. [MSRC affected products][msrc-api] [Rapid7][rapid7] |
| Microsoft public disclosure and Windows updates | 2026-10-13 07:00 PDT (UTC−07:00) | October 2026 Patch Tuesday, MSRC revision 1.0 "Information published." The CNA `datePublic` is 2026-10-13 14:00 UTC. Exploited: Yes. [MSRC][msrc] [CVE JSON][cve] |
| CVE record published | 2026-10-13 19:01:26 UTC | CVE record metadata. [CVE JSON][cve] |
| CISA KEV addition | 2026-10-13 (date only) | `dateAdded` 2026-10-13, `dueDate` 2026-10-16, ransomware use "Unknown", forensic triage "Yes". Being added to KEV does not show when exploitation started. [KEV JSON][kev] |
| Exploitation evidence | Not dated | Microsoft states exploitation was detected but publishes no actor, campaign, start date or IOCs. The CISA ADP SSVC entry ("Exploitation: active") is timestamped 2026-10-08, which is earlier than publication. Treat that as record metadata, not as an exploitation date. [MSRC][msrc] [CVE JSON][cve] |
| CNA record update | 2026-10-25 18:48:18 UTC | Microsoft updated the CVE record. The MSRC revision history still shows only revision 1.0, and this review found no substantive change. [CVE JSON][cve] |

## Detection

### Establish exposure

The fixed builds below come from MSRC's affected-product data, checked 2026-10-26. A host is exposed if its OS build is below the fixed build for its branch.

| Product | Update (KB) | Fixed build |
|---|---|---|
| Windows 11 24H2 (x64/ARM64) | KB5127648 | 10.0.26100.9711 |
| Windows 11 25H2 (x64/ARM64) | KB5127648 | 10.0.26200.9711 |
| Windows 11 26H2 (x64/ARM64) | KB5127648 | 10.0.26300.9711 |
| Windows 11 26H1 (x64/ARM64) | KB5127646 | 10.0.28000.3231 |
| Windows 11 23H2 (x64/ARM64) | KB5126653 | 10.0.22631.7652 |
| Windows 10 21H2 / 22H2 (32-bit, x64, ARM64) | KB5126657 | 10.0.19044.7807 / 10.0.19045.7807 |
| Windows 10 1809, Windows Server 2019 (incl. Server Core) | KB5126651 | 10.0.17763.9376 |
| Windows 10 1607, Windows Server 2016 (incl. Server Core) | KB5126868 | 10.0.14393.9612 |
| Windows Server 2022 (incl. Server Core) | KB5126655 | 10.0.20348.5761 |
| Windows Server 2025 (incl. Server Core) | KB5126646 | 10.0.26100.33650 |
| Windows Server 2012 R2 (incl. Server Core) | KB5126836 (Monthly Rollup) | 6.3.9600.23470 |

Whether you can install an update for an older branch, such as Windows 10 or Server 2012 R2, depends on your servicing channel and licensing (for example ESU or LTSC). Confirm that against Microsoft's servicing documentation. Rapid7 notes that Windows Server 2012 (not R2) receives no update for this CVE. [Rapid7][rapid7]

**Read-only build check.** Run in an unprivileged PowerShell session on the host. It only reads the registry:

```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
  Select-Object ProductName, DisplayVersion, CurrentBuild, UBR
```

Compare `CurrentBuild.UBR` (for example `26100.9711`) with the table. `Get-HotFix -Id KB5127648` (substitute your branch's KB) may also show the update. Cumulative-update and hotpatch packaging can mean the KB is missing from `Get-HotFix` even though the build is fixed, so trust the build number first. For fleets, use the patch-compliance report from Intune, WSUS, Configuration Manager or Defender Vulnerability Management, and check when each device last reported. An offline device or a stale report means **unknown**, not fixed. These commands were not run against a real fleet for this review.

### Look for exploitation

- Microsoft has published **no IOCs, file types or exploit chain** for this CVE. Any detection logic here is generic MOTW-bypass hunting, not a confirmed signature.
- In EDR or Defender telemetry, look for user-opened files that came from email, IM or browser downloads (archives, shortcuts and similar containers) and that launched script hosts, `rundll32`, `mshta`, PowerShell or unsigned binaries **without** a SmartScreen or MOTW prompt event, especially before the host installed the October update.
- Check attachment and URL detonation results, email gateway logs and proxy logs for the delivery path. Microsoft's exploitation scenario relies on persuading a user to open a file or click a link.
- If a file's `Zone.Identifier` alternate data stream is missing or zone-less, that can be a lead, but the stream can also be lost legitimately (some archivers, file copies, FAT volumes). It is not proof either way.
- Finding nothing in the logs does not prove the host is clean. A MOTW bypass removes a warning; it does not necessarily leave a unique artifact, and telemetry retention may not reach back far enough.

## Remediation

1. Install the October 2026 security update for each Windows branch listed above through your normal channel (Windows Update, WSUS, Configuration Manager, Intune or Autopatch). Reboot where required; MSRC data lists the cumulative updates as requiring a restart.
2. Prioritize user endpoints that receive email or chat attachments or browse the web, and multi-user hosts (RDS/VDI). Servers where users rarely open files are lower priority but still affected.
3. While you roll out the update, keep in place controls that do not depend on MOTW alone: attachment detonation and file-type blocking at the email gateway, ASR rules for Office and script content, application control (WDAC/AppLocker), and SmartScreen enforcement. These reduce risk but do **not** replace the update.
4. **Outlook.com:** MSRC lists a service-side fixed build and no customer-installable package was identified. Account owners have nothing to install.
5. Rollback caution: uninstalling the cumulative update to fix a compatibility problem reintroduces the vulnerability. Use Known Issue Rollback or vendor guidance where available instead of removing the security update.

## Verification

- Re-read `CurrentBuild`/`UBR` after the reboot, and check that the management console's compliance view shows the updated build on the actual device.
- As a benign functional control, download a harmless test file from a trusted internal web page and confirm that its properties show the "came from another computer" or Unblock indicator, and that SmartScreen and Protected View behave as your policy expects. Do **not** use exploit samples or attempt to reproduce the bypass in production.
- For managed fleets, reconcile devices that report the KB as installed but are below the expected build, which can happen when a reboot is pending.

## Compromise response

If a user may have opened a malicious file on an unpatched host, treat it as a possible endpoint compromise rather than a patching task. Isolate the host, preserve EDR and endpoint evidence and the delivering email or URL, identify what payload ran and under which account, and hunt for persistence (scheduled tasks, Run keys, services, browser extensions) and credential access. Reset credentials and revoke sessions for the affected account from a clean device, look for lateral movement, and rebuild the host from known-good media if you cannot rule out persistence. CISA marks this KEV entry as requiring forensic triage under BOD 26-04 for covered agencies. [KEV JSON][kev]

## Sources

- [Microsoft advisory][msrc]: severity, FAQ (MOTW, UI-required scenario), exploited flag.
- [MSRC Security Update Guide API, affected products][msrc-api] and [MSRC October 2026 CVRF][cvrf]: KB numbers, fixed builds, acknowledgments, release timestamps.
- [Microsoft CNA record][cve]: affected version ranges, publication and update timestamps, CISA ADP SSVC.
- [NVD][nvd]: shows only Microsoft's CVSS score; KEV dates.
- [CISA KEV JSON feed][kev]: `dateAdded`, `dueDate`, `requiredAction`, forensic triage flag.
- [Rapid7 Patch Tuesday analysis][rapid7] (secondary): Windows Server 2012 non-R2 note, Outlook.com context.

[msrc]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-96951
[msrc-api]: https://api.msrc.microsoft.com/sug/v2.0/en-US/affectedProduct?$filter=cveNumber%20eq%20'CVE-2026-96951'
[cvrf]: https://api.msrc.microsoft.com/cvrf/v3.0/cvrf/2026-Oct
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-96951
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-96951
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[rapid7]: https://www.rapid7.com/blog/post/em-patch-tuesday-october-2026/
