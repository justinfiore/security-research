# Siemens Software Center: DLL side-loading exploited in ClickFix campaign

**Last updated:** 2026-10-26 (America/New_York)

[Main Siemens Software Center summary](../black-october-2026.md#siemens-software-center-dll-side-loading-exploited-in-clickfix-campaign-cve-2026-110936) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**CVE-2026-110936: Siemens CVSS 4.0 8.4 High (CVSS:4.0/AV:L/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N), but Siemens CVSS 3.1 6.7 Medium (CVSS:3.1/AV:L/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:H). Both scores come from Siemens and appear in the advisory and the CVE record. NVD has added no score of its own. Listed in CISA KEV on 2026-10-20.** Siemens Software Center (SSC) is a Windows tool for downloading, installing, activating and updating Siemens software. Versions before **V4.0.9.8** load DLLs from an uncontrolled search path (CWE-427), so a DLL placed in a directory it searches runs with the application's privileges. Siemens reports **active exploitation**. Attackers bundled a **genuine, validly signed** SSC (version 3.5.8.7) with malicious DLLs and delivered it outside official channels as `AllMyBasic.msi` in the "Romulus" multi-platform ClickFix campaign. [SSA-580366][ssa] [Siemens blog][blog] [CNA][cve]

**What this means for defenders:** the threat is mainly **attackers bringing their own vulnerable signed binary** to a PC, not attacks on SSC installs you already have. Updating your SSC protects your installations, but it **does not stop** an attacker from dropping an old signed copy on any Windows PC, including PCs that never had SSC. Siemens says to detect on folder and behaviour, because "the file itself is genuine". [Siemens blog][blog]

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Siemens credits Jose Oregon (Huntress Labs) with the report; no date is given. [SSA-580366][ssa] |
| CVE ID reserved | 2026-10-15 06:40:09 UTC | CNA metadata. [CNA][cve] |
| SSA-580366 V1.0 published | 2026-10-15; time/TZ unknown | First public advisory. [SSA-580366][ssa] |
| CVE record published | 2026-10-15 14:01:17 UTC | CNA metadata. NVD published 2026-10-15 15:17:30 UTC. [CNA][cve] [NVD][nvd] |
| Fix V4.0.9.8 listed (SSA V1.1) | 2026-10-17; time/TZ unknown | "Added remediation for Siemens Software Center." The build date of V4.0.9.8 itself is not established. Existing installs auto-update on their next start. [SSA-580366][ssa] |
| Active exploitation confirmed; IOCs published | 2026-10-19; time/TZ unknown | Siemens ProductCERT blog. SSA V1.2 adds the reference. Exploitation start date: Unknown. [Siemens blog][blog] |
| CISA KEV addition | 2026-10-20 (date only) | Due 2026-11-03. Forensic triage under BOD 26-04: **No**. Ransomware use: Unknown. [KEV][kev] |
| CISA ICS advisory | 2026-10-22; time/TZ unknown | ICSA-26-295-03 republishes the Siemens advisory. [CISA ICS][icsa] |

## Detection

### Legitimate installations

Find SSC installs and record their versions. Anything before V4.0.9.8 is affected. Siemens says existing installs **auto-update on next start**, so an install that has not been started recently may still be old. Check the actual file version; do not assume the update ran. [SSA-580366][ssa]

### Campaign indicators (from Siemens)

| Type | Indicator | Siemens status (2026-10-19) |
|---|---|---|
| IP | `96.62.218[.]59` | Active, payload hosting and C2 |
| Domain | `wizardexpensive[.]com` | Active, payload hosting and C2 |
| IP | `2.27.248[.]127` | Inactive, distributed `AllMyBasic.msi` |
| SHA-256 | `f4d7c5321bb0d1bda439304a753bcf9b467b98ca53c7e9493b9c2c3451092e4a` | `AllMyBasic.msi` |
| SHA-256 | `3fdcc7d7d049a89711fb31fb236940a1c5a09d899143ffd20c3c41fb1f2cf491` | `archive.dll` |

Host warning signs, according to Siemens:

- "Siemens Software Center" in start-up apps or Task Scheduler on a PC that never had it.
- A folder named `SM Software Provisioning Service` under `AppData\Local\Programs`.
- `activate.bak` or `statinfosta.DB` next to `SiemensSoftwareCenter.exe`.
- `AppData\Local\FTSuite\ftc.uml`.
- `SiemensSoftwareCenter.exe` running from `AppData\Local\Programs`, started by `msiexec`.

Search EDR, proxy, DNS and firewall logs for the indicators above, including the inactive distribution IP. [Siemens blog][blog]

### Read-only host check (PowerShell)

These commands only read the file system and the task list. Run them in an **elevated** Windows PowerShell session on the PC under review, so that every user profile is readable; no working directory is needed. They have not been run against a real infected or SSC-equipped host. Errors from profiles you cannot read mean those profiles are **unknown**, not clean.

```powershell
# 1) Every SiemensSoftwareCenter.exe under user profiles, with version, signer status and sibling files
Get-ChildItem -Path 'C:\Users\*\AppData\Local' -Recurse -Filter 'SiemensSoftwareCenter.exe' -ErrorAction SilentlyContinue -Force |
  ForEach-Object {
    [pscustomobject]@{
      Path      = $_.FullName
      Version   = $_.VersionInfo.FileVersion
      Signature = (Get-AuthenticodeSignature $_.FullName).Status
      Siblings  = (Get-ChildItem $_.DirectoryName -Force | Select-Object -ExpandProperty Name) -join ', '
    }
  }

# 2) Siemens-named artefacts
Get-ChildItem -Path 'C:\Users\*\AppData\Local\Programs\SM Software Provisioning Service','C:\Users\*\AppData\Local\FTSuite\ftc.uml' -Force -ErrorAction SilentlyContinue

# 3) Hash DLLs found next to any SSC executable and compare with the published archive.dll hash
Get-ChildItem -Path 'C:\Users\*\AppData\Local' -Recurse -Filter 'SiemensSoftwareCenter.exe' -ErrorAction SilentlyContinue -Force |
  ForEach-Object { Get-ChildItem $_.DirectoryName -Filter '*.dll' -Force } |
  Get-FileHash -Algorithm SHA256 |
  Where-Object Hash -eq '3FDCC7D7D049A89711FB31FB236940A1C5A09D899143FFD20C3C41FB1F2CF491'

# 4) Scheduled tasks that launch SSC
Get-ScheduledTask | Where-Object { ($_.Actions.Execute -join ' ') -match 'SiemensSoftwareCenter' } |
  Select-Object TaskPath, TaskName, @{n='Execute';e={$_.Actions.Execute -join ' '}}
```

A valid signature on the EXE is **expected even for the malicious bundle**, so it does not prove the install is benign. A copy under `AppData\Local\Programs` on a PC with no business need for SSC deserves investigation. Hash matching only finds the one published DLL; new samples will not match. A clean result does not rule out an earlier infection that has since cleaned itself up.

## Remediation

1. **Update legitimate installs** to **V4.0.9.8 or later** by starting SSC, which auto-updates it, or by downloading it from the official Siemens page. [SSA-580366][ssa]
2. **Download Siemens software only from official Siemens sources.** The campaign distributed the signed program outside official channels. [Siemens blog][blog]
3. **Block** `96.62.218[.]59`, `wizardexpensive[.]com` and `2.27.248[.]127` on firewalls, proxies and DNS. Review these indicators again later, because infrastructure changes. [Siemens blog][blog]
4. **Defend against ClickFix:** train users never to paste commands from web pages into Win+R or PowerShell. Consider application-control rules that stop programs running from user-writable `AppData` paths where your business allows it. Test such rules first so you do not block legitimate per-user installers.
5. Siemens's general guidance also applies: protect network access and follow Siemens industrial-security operational guidelines. [SSA-580366][ssa]

## Verification

- Confirm that the file version of every legitimate `SiemensSoftwareCenter.exe` is at least 4.0.9.8 after SSC has been started.
- Run the PowerShell inventory again and confirm that no SSC copies remain in unexpected `AppData\Local\Programs` folders.
- Confirm that the block rules hit (by resolving the domain through your filtering resolver, for example) without opening any connection to the indicator infrastructure from a production host.
- Check that ordinary SSC functions (sign-in, product download and installation) still work for licensed users.

## Compromise response

If you find indicators, follow Siemens's guidance [Siemens blog][blog]:

1. Isolate the PC.
2. Stop the malicious `SiemensSoftwareCenter.exe` process first.
3. Remove the start-up entry and the scheduled task.
4. **Reset passwords.**

Beyond that, preserve EDR telemetry and the dropped files before cleanup, then work out what ran next. The campaign's payload capabilities are not described in the reviewed sources, so assume credential theft is possible. Rotate the credentials and browser-stored secrets used on the PC, and look for lateral movement. If you cannot establish the scope, re-image the PC rather than removing pieces by hand. Updating SSC does not undo a compromise that has already happened.

## Sources

- [Siemens SSA-580366][ssa]: affected and fixed versions, both CVSS scores, reporter credit, revision history.
- [Siemens ProductCERT exploitation blog][blog]: campaign description, IOCs, host warning signs, response steps.
- [CVE record (Siemens CNA)][cve] and [NVD][nvd]: timestamps and scores.
- [CISA KEV feed][kev]: dateAdded 2026-10-20, due date 2026-11-03, no forensic triage required.
- [CISA ICSA-26-295-03][icsa]: CISA republication on 2026-10-22.
- Secondary: [SecurityWeek][sw] and [Help Net Security][helpnet] coverage, 2026-10-19 and 2026-10-20.

[ssa]: https://cert-portal.siemens.com/productcert/html/ssa-580366.html
[blog]: https://productcert.siemens.com/news/2026/10/19/active-exploitation-of-cve-2026-110936-in-siemens-software-center/
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-110936
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-110936
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[icsa]: https://www.cisa.gov/news-events/ics-advisories/icsa-26-295-03
[sw]: https://www.securityweek.com/siemens-software-center-vulnerability-exploited-in-clickfix-malware-attacks/
[helpnet]: https://www.helpnetsecurity.com/2026/10/20/exploitation-siemens-software-center-vulnerability-cve-2026-110936
