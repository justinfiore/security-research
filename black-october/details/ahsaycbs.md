# AhsayCBS: authentication bypass and command injection chain

**Last updated:** 2026-10-26 (America/New_York)

[Main AhsayCBS summary](../black-october-2026.md#ahsaycbs-authentication-bypass-and-command-injection-chain-cve-2026-105133-and-cve-2026-105134) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-105133](https://www.cve.org/CVERecord?id=CVE-2026-105133) (improper authentication, CWE-287) — VulDB (CNA) CVSS 3.1: 7.3 High (`AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:L`). VulDB CVSS 4.0: the CNA record says 6.9 Medium, while NVD shows VulDB's same vector, which includes `E:P`, as 5.5 Medium.** **[CVE-2026-105134](https://www.cve.org/CVERecord?id=CVE-2026-105134) (OS command injection, CWE-78/77) — VulDB CVSS 3.1: 10.0 Critical (`S:C/C:H/I:H/A:H`). VulDB CVSS 4.0: 10.0 Critical in the CNA record; NVD shows 9.3 Critical (with `E:P`).** No NVD primary score was found for either CVE. The 4.0 scores differ because VulDB's 2026-10-26 record update set exploit maturity to `E:A` (attacked), while NVD still displays the earlier `E:P` vector. The other disagreement is that the bypass is Medium under 4.0 but High under 3.1. Ahsay publishes no CVSS score.

Attackers **chain the two flaws**. CVE-2026-105133 bypasses authentication through the `random` argument to `checkSysPwd` (`com/ahsay/obs/api/ApiStructsAction.java`). CVE-2026-105134 then injects OS commands through the `random` argument at `/rps/api/json/UpdateReceivers.do` (Replication Receiver). Huntress observed unauthenticated remote code execution as **NT AUTHORITY\SYSTEM** on Windows hosts: JSP webshells, malicious replication receivers, and XMRig miners disguised as Microsoft Edge. **Worst case:** an attacker fully controls the backup server that holds or brokers many customers' backups. AhsayCBS is used mainly by MSPs.

**CISA KEV:** Listed — both CVEs added 2026-10-14, federal due date 2026-10-17. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and exposure](#inventory-and-exposure)
  - [Indicators to check (read-only)](#indicators-to-check-read-only)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | VulDB credits "nickc (VulDB User)" as reporter. No date establishes whether or when Ahsay was notified before publication. [CVE 105133][cve133] |
| VulDB advisory disclosed / entry created | 2026-10-03 (VulDB timeline; recorded as 00:00 and 02:00 UTC, treat as date-level) | VulDB timeline: "Advisory disclosed", "VulDB entry created". VulDB says the exploit is public. The VulDB pages returned HTTP 403 to this review. [CVE 105133][cve133] [CVE 105134][cve134] |
| CVE records published | 2026-10-04 05:15:14 UTC (105133); 05:30:12 UTC (105134) | Original affected range was "up to 10.3.2", with 10.3.4 listed as unaffected; Huntress and Ahsay contradicted both points. [CVE 105133][cve133] [CVE 105134][cve134] |
| CVE records corrected | 2026-10-26 14:31:10 UTC (105133); 14:31:13 UTC (105134) | VulDB now lists "up to 9.15.2.69/10.3.4.44" as affected and 9.15.2.70 / 10.3.4.45 as fixed, noting "The initial patch did not fix the security vulnerability properly." Exploit maturity changed to attacked (`E:A`). [CVE 105133][cve133] [CVE 105134][cve134] |
| Earlier vendor builds | v10.3.4.0 released 2026-08-05; v9.15.2.59 date unknown | Ahsay later said both "did not fully address" the CVEs. The v10.3.4 release notes list no security fix. [Ahsay update][ahsay-update] [v10.3.4 notes][relnotes] |
| Exploitation begins (observed) | 2026-10-07 23:20:15 UTC | Huntress saw exploitation in the wild, with five organizations targeted as of October 8. [Huntress][huntress] |
| Huntress research published | 2026-10-08; time/TZ unknown | Huntress update at 6 pm ET on October 8: **10.3.4 is also affected**. [Huntress][huntress] |
| Ahsay receives partner compromise reports | 2026-10-09 (date only) | From Ahsay's incident timeline. [Ahsay status][ahsay-status] |
| v10 hotfix 10.3.4.45 | 2026-10-10 per Ahsay; 2026-10-12 per Huntress | Ahsay's first alert (Oct 10) and incident timeline say 10.3.4.45 was released October 10. Huntress's update says Ahsay released "a hotfix" on October 12. Both dates are shown because the sources disagree. Huntress says it independently verified that 10.3.4.45 blocks the initial entry point. [Ahsay alert][ahsay-alert] [Huntress][huntress] |
| v7/v8/v9 hotfix 9.15.2.70 | 2026-10-12 (date only) | v8 and v7 must first upgrade to 9.15.0.0 and then apply 9.15.2.70. [Ahsay update][ahsay-update] [Ahsay status][ahsay-status] |
| Ahsay compromise and recovery guidance | 2026-10-13 (date only) | Lists IOCs and full-rebuild steps, and says the 9.15.2.70 and 10.3.4.45 hotfixes "fully address" both CVEs. [Ahsay status][ahsay-status] |
| CISA KEV addition | 2026-10-14 (date only) | Both CVEs: `dueDate` 2026-10-17, ransomware use "Unknown". Forensic triage is **"No"** for 105133 and **"Yes"** for 105134. [KEV JSON][kev] |
| Ahsay partner statement | 2026-10-21 (date only) | Promises further v9/v10 safeguards. [Ahsay message][ahsay-msg] |
| Security-hardening hotfix | 2026-10-22 (date only) | The announcement names it both "v10.3.5.54 hotfix" and "v10.3.4.54 official hotfix". It says v10.3.6 is "scheduled for next week" and a v9 hardening hotfix is expected "early next week". Neither was verified as released by 2026-10-26. [Ahsay hardening][ahsay-harden] |

## Detection

### Inventory and exposure

1. Find every AhsayCBS server, on Windows or Linux, including servers run for you by an MSP. Record the major version (v7, v8, v9 or v10), the exact build, and any applied hotfix as shown in the AhsayCBS management console or your deployment records.
2. **Use the corrected affected range.** VulDB's original "up to 10.3.2 / 10.3.4 unaffected" was wrong; its records were corrected on 2026-10-26 to "up to 9.15.2.69/10.3.4.44", matching Huntress and Ahsay. Scanners that cached the old record may still mis-classify 10.3.3–10.3.4.44. Ahsay directs v7, v8, v9 and v10 users to the hotfixes. Treat any build below **10.3.4.45** (v10) or **9.15.2.70** (v7–v9) as affected.
3. Determine whether the AhsayCBS web console and API (HTTP/HTTPS) can be reached from the internet. Huntress says the exploit targets the externally accessible web service.

### Indicators to check (read-only)

Ahsay lists these indicators: unusual folders at the root of drives (for example `ahsay_ts`, `ahsay_t8`, `ahsay_t9`, `ahsay_t20`, `ahsay_t21`, `srv`, `user`, `opt`); randomly named `.jsp` files (for example `75bc584d292933ad.jsp`) or short lowercase-alphanumeric folders (for example `xtj7iu`) under `%CBS%\webapps`; **unauthorized RPS (replication) receivers**; and **unauthorized AhsayCBS users with Admin privilege**. [Ahsay status][ahsay-status]

Huntress adds: child processes of `cbssvcX64.exe`/`cbssvcX86.exe` running `curl`, `certutil` or PowerShell; files named `Taskgmr.ps1`, `msedge.exe`, `edge.exe`, `config.json` and `WinRing0x64.sys` in `%TEMP%` or a user's `AppData\Local\Temp`; a Windows service named **`MicrosoftEdgeUpdateSvc`** (the genuine one is `edgeupdate`); payload downloads from `imagefiles-backup.oss-ap-southeast-7.aliyuncs[.]com`; mining traffic to `xmr.kryptex[.]network:8029` / `51.195.127[.]124`; and the source IPs, SHA-256 hashes and Sigma rules in the [Huntress post][huntress] and [Huntress Sigma rules][sigma].

The following read-only PowerShell, run as a local administrator on the Windows AhsayCBS host, only lists files and services. Replace `CBS_DIR` with your installation directory, for example the folder that contains `webapps`:

```powershell
$cbs = 'CBS_DIR'   # placeholder: AhsayCBS install directory
Get-ChildItem -Path (Join-Path $cbs 'webapps') -Recurse -Include *.jsp -File -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending | Select-Object -First 50 FullName, LastWriteTime
Get-PSDrive -PSProvider FileSystem | ForEach-Object {
  Get-ChildItem -Path $_.Root -Directory -Filter 'ahsay_t*' -ErrorAction SilentlyContinue }
Get-Service -Name MicrosoftEdgeUpdateSvc -ErrorAction SilentlyContinue
Get-ChildItem -Path "$env:SystemRoot\Temp", 'C:\Users\*\AppData\Local\Temp' -Include Taskgmr.ps1, edge.exe, msedge.exe, WinRing0x64.sys -Recurse -File -ErrorAction SilentlyContinue
```

On Linux, the equivalent read-only check as root is `find CBS_DIR/webapps -name '*.jsp' -newermt 2026-10-01 -ls`, with the same placeholder. The public IOCs come from Windows incidents, so Linux-specific artifacts are **not established**. Legitimate AhsayCBS JSP files exist, so compare against a clean installation of the same build. In the console, also review the replication receiver list and the administrator list. These commands were not run on a real AhsayCBS server for this review.

Finding no indicators does not prove the server is clean. Huntress warns that attackers can hide secondary backdoors, and the indicator list reflects only the campaigns observed so far.

## Remediation

1. **v10:** apply the **AhsayCBS 10.3.4.45** hotfix or later (partner portal login required) and **reboot the server**, as Ahsay instructs. **v7, v8, v9:** v8 and v7 must first upgrade to **9.15.0.0**; then apply **9.15.2.70** and reboot. Ahsay states these hotfixes "fully address" both CVEs. This review could not access the partner-only download pages to inspect the builds.
2. Consider the 2026-10-22 hardening hotfix (named both v10.3.5.54 and v10.3.4.54 by Ahsay) or the upcoming v10.3.6 release. Ahsay presents these as additional hardening, not as the CVE fix.
3. Do **not** rely on 10.3.4.0 or 9.15.2.59. Ahsay says neither fully fixed the CVEs.
4. Whatever the patch status, restrict web console and API access to trusted IPs or a VPN, as Huntress recommends. If the replication-receiver function is unused, block external access to `/rps/` paths at a reverse proxy or firewall. That is a defensive network control; Ahsay has not documented it as a supported workaround.
5. If the server shows any indicator, follow **Compromise response** instead of only patching it in place.

## Verification

- Confirm the running build shown in the AhsayCBS console is 10.3.4.45 or later (v10), or 9.15.2.70 or later (v9), and that the server was rebooted after the hotfix.
- From an untrusted network, confirm the management interface is unreachable, or reachable only where you intend it to be.
- As a functional check, log in as a legitimate administrator and run a normal client backup and restore test. Do **not** send exploit requests to `checkSysPwd` or `UpdateReceivers.do`.
- Re-run the read-only indicator checks after patching and compare them with your earlier baseline.

## Compromise response

Ahsay recommends a **full rebuild**: reinstall Windows or Linux, install AhsayCBS 9.15.0.0 or 10.3.4.0 and apply the 9.15.2.70 or 10.3.4.45 hotfix, then restore the server configuration from an **Auto Save version that predates the compromise**, at least one day before the earliest suspicious file or folder. Huntress likewise advises re-imaging from a trusted backup. [Ahsay status][ahsay-status] [Huntress][huntress]

Before rebuilding, preserve disk and memory evidence, logs and the webshell files. Then go beyond the host:
- Remove unauthorized replication receivers and admin accounts.
- Rotate AhsayCBS admin and user credentials, any cloud-storage or destination credentials stored in CBS, and the SSL keys.
- Check whether customer backup data was accessed or exfiltrated, or whether replicated data went to attacker-added receivers.
- If you are an MSP, notify affected customers under your contractual and legal obligations.
- Check that backup sets are intact before relying on them for recovery.

## Sources

- [Ahsay status update and IOCs][ahsay-status], [initial alert][ahsay-alert], [updated alert][ahsay-update], [partner message][ahsay-msg], [hardening hotfix][ahsay-harden], [v10.3.4 release notes][relnotes]: fix versions, dates, recovery guidance.
- VulDB CNA records for [CVE-2026-105133][cve133] and [CVE-2026-105134][cve134]: descriptions, CVSS, VulDB timeline.
- NVD for [CVE-2026-105133][nvd133] and [CVE-2026-105134][nvd134]: displayed VulDB CVSS 4.0 5.5/9.3; no NVD primary score.
- [CISA KEV JSON feed][kev]: dates, forensic-triage flags.
- [Huntress research][huntress] and [Sigma rules][sigma]: exploitation start time, IOCs, 10.3.4 finding.

[cve133]: https://cveawg.mitre.org/api/cve/CVE-2026-105133
[cve134]: https://cveawg.mitre.org/api/cve/CVE-2026-105134
[nvd133]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-105133
[nvd134]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-105134
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[ahsay-alert]: https://www.ahsay.com/en/company/announcements/patch-cve-105133-105134
[ahsay-update]: https://www.ahsay.com/en/company/announcements/patch-cve-105133-105134-update
[ahsay-status]: https://www.ahsay.com/en/company/announcements/ahsaycbs-vulnerability-status-update
[ahsay-msg]: https://www.ahsay.com/en/company/announcements/ahsaycbs-security-update-message-to-partners
[ahsay-harden]: https://www.ahsay.com/en/company/announcements/release-103454
[relnotes]: https://www.ahsay.com/en/support/help-centre/release-notes/cbs/v10.3.4
[huntress]: https://www.huntress.com/blog/ahsaycbs-flaws-exploit
[sigma]: https://github.com/huntresslabs/threat-intel/tree/main/2026/2026-10/AhsayCBS_XMRig_Miner
