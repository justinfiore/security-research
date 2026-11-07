# Windows Paint: remote code execution

**Last updated:** 2026-11-06 (America/New_York)

[Back to Paint summary](../black-october-2026.md#windows-paint-remote-code-execution) · [Changelog](../../CHANGELOG.md)

**Microsoft (CNA) rates [CVE-2026-83844](https://www.cve.org/CVERecord?id=CVE-2026-83844) CVSS 3.1 8.1 High and Important.** The vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H/E:U/RL:O/RC:C`. The temporal score is 7.1, because Microsoft rates exploit code unproven and an official fix available. NVD has not scored it. An out-of-bounds read (CWE-125) in Windows Paint lets an unauthorized attacker execute code over a network. Microsoft's FAQ says the attacker sends a specially crafted packet to an affected service, and that no authentication and no user interaction are required. Attack complexity is High: Microsoft says a successful attack is not guaranteed and needs a deep understanding of the system, and that it depends on the environment and on other security measures. The CVE record, updated 2026-11-06, says Paint 11.0.0.0 before **11.2609.401.0** is affected. The CSAF is version 2, current release date 2026-11-06 08:00 UTC. Its revision note says Microsoft released Paint **11.2609.401.0** to address this CVE and recommends installing it or confirming it updated. The earlier record said 11.2605.91.0. That build is inside the range the current record calls affected. This is the Microsoft Store app. It is not the [.NET Framework](dotnet-framework.md) App Control bypass and not the [Windows Shell](windows-shell.md) Mark of the Web bypass.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-06). Microsoft says the flaw was not publicly disclosed and not exploited, and rates exploitation less likely. CISA-ADP records Exploitation none, Automatable no, and Technical Impact total. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| CVE reserved | 2026-08-31 23:09:05 UTC | Microsoft. Not a public disclosure date. |
| Public announcement and fix | 2026-10-13 14:00 UTC | MSRC entry version 1.0. The CVE record's `datePublic` is the same instant. The record was published at 18:59:53 UTC the same day. |
| Fixed Paint, first record | 2026-10-13; time/TZ unknown | The record then said 11.0.0.0 before 11.2605.91.0. It still said that on 2026-10-31. |
| Fixed Paint, current record | 2026-11-06 08:00 UTC | CSAF version 2. The record and the product tree now say affected is below 11.2609.401.0. Revision 2 names that build as the fix. [CSAF][csaf] |
| CISA-ADP | 2026-10-13 20:24:59 UTC | Exploitation none. Automatable no. Technical Impact total. |
| **Last updated** | **2026-11-06 (America/New_York)** | New item. |

## Detection

1. On each Windows client, read the installed Paint version. In Settings, Apps, Installed apps, open Microsoft Paint and read the version. Or, in PowerShell:

   ```powershell
   Get-AppxPackage -Name Microsoft.Paint | Select-Object Name, Version
   ```

   The current CVE record and the CSAF both say affected is **below 11.2609.401.0**. A machine on 11.2605.91.0, the build the October record named, is inside that range. A machine with no `Microsoft.Paint` package is outside this flaw. A version string that does not start with `11.` is not in the range either source names; record it as unknown rather than safe.
2. Microsoft describes the attack as a crafted packet to an affected service, with no user opening a file. The advisory does not name the port, the protocol, or a log line. Absence of a crash in the Paint process is not evidence the packet was not sent.
3. This check does not cover the October cumulative update or the .NET Framework update. Those are different flaws.

## Remediation

1. Update Microsoft Paint to **11.2609.401.0 or later** through the Microsoft Store. The CVE record and the CSAF now both name that build. A machine on 11.2605.91.0 is not done. MSRC lists one product row, Microsoft Paint, with no Windows build number and no knowledge-base article. Installing the October cumulative update is not this fix.
2. Microsoft publishes no workaround. Uninstalling Paint removes the package; that is a removal, not the patch, and a later Store install can bring an old build back if the Store is not current.
3. The update does not show whether a packet already executed code.

## Verification

- `Get-AppxPackage -Name Microsoft.Paint` reports **11.2609.401.0 or later** for the user who runs Paint. Check each Windows profile that has its own Store apps. A version reported for one user does not prove another user's package. 11.2605.91.0 is below the current record's floor.
- A host with the package absent stays absent after the check. Do not install Paint in order to patch it.

## Compromise response

Microsoft says the flaw has not been exploited and that no public exploit code exists. If a host shows code execution you cannot account for and Paint was below 11.2609.401.0, treat that as a lead, not as proof this CVE was used. Preserve the process list and network connections from a clean system, then update Paint. The update does not remove a payload that already ran.

## Sources

- [MSRC CVE-2026-83844][msrc] — released 2026-10-13, revision 1.0 the same day. Important, CVSS 3.1 base 8.1, temporal 7.1. CWE-125. Not publicly disclosed, not exploited, exploitation less likely. The FAQ says a crafted packet, no authentication, and no user interaction, and that attack complexity is high.
- [CVE-2026-83844][cve] — Microsoft CNA. Published 2026-10-13 18:59:53 UTC, `datePublic` 2026-10-13 14:00 UTC, updated 2026-11-06. Affected from 11.0.0.0 before 11.2609.401.0. CISA-ADP on 2026-10-13 20:24:59 UTC: Exploitation none.
- [CSAF for CVE-2026-83844][csaf] — version 2, current release date 2026-11-06 08:00 UTC. Revision 2 names 11.2609.401.0 as the build that addresses the CVE. Product tree: affected below that build, fixed at that build.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.04, checked 2026-11-06).

[msrc]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-83844
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-83844
[csaf]: https://msrc.microsoft.com/csaf/advisories/2026/msrc_cve-2026-83844.json
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
