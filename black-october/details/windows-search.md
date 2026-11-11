# Windows Search: an email attachment runs code when Exchange indexes it

**Last updated:** 2026-11-10 (America/New_York)

[Back to Windows Search summary](../black-october-2026.md#windows-search-an-email-attachment-runs-code-when-exchange-indexes-it) · [Changelog](../../CHANGELOG.md)

**Microsoft rates [CVE-2026-116928](https://www.cve.org/CVERecord?id=CVE-2026-116928) CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H/E:U/RL:O/RC:C`, and the temporal score is 8.5. The weakness is CWE-787, an out-of-bounds write in the Windows Search component. An unauthenticated attacker sends an email with a crafted attachment. Exchange indexes that attachment automatically, so the recipient never opens the email or the file. Microsoft says successful exploitation runs code with the permissions of the processing service.

Microsoft's severity is Critical. It rates exploitation less likely, and says the flaw was not publicly disclosed and not exploited. NVD has not added a score of its own.

This is not the October [Windows Shell](windows-shell.md) Mark of the Web bypass, and it is not the Outlook spoofing flaw [CVE-2026-124194](https://www.cve.org/CVERecord?id=CVE-2026-124194). Microsoft scores that one 6.5 Moderate, and CISA added it on November 10. It is below this guide's High threshold, so it is not a separate item.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-11). Microsoft says Exploited: No. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery/report | Unknown | MSRC credits 41ae55e9310ff27fa6f26af4727e5590 and Jean-Jamil Khalife of HDWSec. No report date is published. [MSRC][msrc] |
| **Public announcement and patch** | **2026-11-10; time/TZ unknown** | MSRC revision 1.0, "Information published." The CVE record was published 2026-11-10 18:21 UTC. [MSRC][msrc] [CVE][cve] |

## Detection

The fixed builds below come from the CVE record and the MSRC Security Updates table, read 2026-11-11. A host is exposed if its build is below the fixed build for its branch. Exchange servers are the path Microsoft describes. The same component is on the Windows versions listed, so those are in scope too.

| Product | Update (KB) | Fixed build |
|---|---|---|
| Windows Server 2022 (incl. Server Core) | KB5131090 | 10.0.20348.5870 |
| Windows Server 2019, Windows 10 1809 (incl. Server Core) | KB5131085 | 10.0.17763.9487 |
| Windows Server 2016, Windows 10 1607 (incl. Server Core) | KB5131291 | 10.0.14393.9688 |
| Windows 10 22H2 | KB5131096 | 10.0.19045.7846 |
| Windows 10 21H2 | KB5131096 | 10.0.19044.7846 |
| Windows 11 23H2 | KB5131087 | 10.0.22631.7711 |
| Windows 11 24H2 | KB5132061 | 10.0.26100.9974 |
| Windows 11 25H2 | KB5132061 | 10.0.26200.9974 |
| Windows 11 26H2 | KB5132061 | 10.0.26300.9974 |
| Windows 11 26H1 | KB5132059 | 10.0.28000.3501 |
| Windows Server 2025 (incl. Server Core) | KB5131080 | 10.0.26100.33822 |

MSRC also lists KB5132043 for Windows 11 24H2, 25H2, and 26H2, and KB5131077 for Windows Server 2025. The CVE record's fixed build is the higher number in the table. Whether an older branch can still be updated depends on the servicing channel.

**Read-only build check.** Run in an unprivileged PowerShell session. It only reads the registry:

```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
  Select-Object ProductName, DisplayVersion, CurrentBuild, UBR
```

Compare `CurrentBuild.UBR` with the table. A missing KB in `Get-HotFix` does not mean the build is unfixed, so trust the build number. For a fleet, use the patch-compliance report, and treat a device that has not reported recently as **unknown**. These commands were not run against a real fleet for this review.

Microsoft has published no file type, attachment name, or indicator for the crafted email. A mail that arrived and was indexed is not, by itself, evidence that this flaw was used.

## Remediation

1. Install the November 10 cumulative update for each branch in the table, through Windows Update, WSUS, Configuration Manager, or Intune. Reboot. Start with servers that run Exchange, because that is the path in Microsoft's FAQ.
2. Microsoft lists no workaround. Blocking a file type at the gateway is not a fix Microsoft describes, and Exchange indexes the attachment whether or not the recipient opens it.
3. The update does not show whether an attachment already ran.

## Verification

- The build number is at or above the fixed build for the branch, on every Exchange server and on the Windows versions in the table.
- The server was rebooted into that build. Installing the package without a reboot leaves the running component on the old build.
- Mail still arrives and is searchable. Do not send a crafted attachment to test it.

## Compromise response

Microsoft says it has no evidence of exploitation and publishes no indicators. If a review of an Exchange server finds a process or a scheduled task that the indexing service should not have started, preserve the logs before rebuilding, and treat credentials that server could reach as exposed. The update does not remove a payload that already ran.

## Sources

- [MSRC CVE-2026-116928][msrc] — revision 1.0, November 10, 2026. Score 9.8, temporal 8.5. Exploited: No. Publicly disclosed: No. Exploitation Less Likely. The FAQ describes the Exchange indexing path. The Security Updates table lists the KBs and builds.
- [CVE record][cve] — published 2026-11-10 18:21 UTC. The affected ranges match the table above.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10, checked 2026-11-11. CVE-2026-116928 is not listed.

[msrc]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-116928
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-116928
