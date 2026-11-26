# Windows RPC: a race in NTLM signing runs code

**Last updated:** 2026-11-26 (America/New_York)

[Back to Windows RPC summary](../black-october-2026.md#windows-rpc-a-race-in-ntlm-signing-runs-code) · [Changelog](../../CHANGELOG.md)

**Microsoft rates [CVE-2026-118737](https://www.cve.org/CVERecord?id=CVE-2026-118737) CVSS 3.1 8.1 Critical.** The vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H/E:U/RL:O/RC:C`, and the temporal score is 7.1. The weakness is CWE-347, improper verification of a cryptographic signature, in the Windows Remote Procedure Call Runtime. Microsoft says an unauthenticated attacker with network access wins a race that depends on a pending DNS query, then sends crafted requests and runs code on the server. No one at the computer has to click.

Microsoft's severity is Critical. It rates exploitation less likely, and says the flaw was not publicly disclosed and not exploited. NVD has not added a score of its own.

This is not the [Windows Search](windows-search.md) attachment flaw in the same November 10 updates. That one is CVE-2026-116928, scored 9.8, and it is the path where Exchange indexes an email. The same updates also start offering real NTLM message signing. [KB5135557][kb], updated November 20, says some authentication proxies, single sign-on products, and packaging tools then fail to sign in, because their NTLM challenge leaves out the computer and domain names the protocol requires. That failure is a compatibility break in the fix, not a second vulnerability.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-26). Microsoft says Exploited: No. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery/report | Unknown | MSRC does not name a reporter or a report date. [MSRC][msrc] |
| **Public announcement and patch** | **2026-11-10; time/TZ unknown** | MSRC revision 1.0, "Information published." The CVE record was published the same day. [MSRC][msrc] [CVE][cve] |
| **Known issue** | **2026-11-20; time/TZ unknown** | KB5135557 adds the sign-in failure for some third-party NTLM proxies and SSO products. [KB][kb] |
| **Last updated** | **2026-11-26 (America/New_York)** | New item. Install the November 10 update. |

## Detection

The fixed builds below come from the MSRC Security Updates table, read 2026-11-26. A host is exposed if its build is below the fixed build for its branch. The flaw is in the RPC runtime, so it is not limited to servers that run Exchange.

| Product | Update (KB) | Fixed build |
|---|---|---|
| Windows Server 2025 (incl. Server Core) | KB5131080 | 10.0.26100.33822 |
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

MSRC also lists a hotpatch, KB5131077 for Windows Server 2025 (build 10.0.26100.33730) and KB5132043 for Windows 11 24H2, 25H2, and 26H2 (builds 10.0.26100.9911, 10.0.26200.9911, and 10.0.26300.9911). The cumulative build in the table is the one this guide treats as the floor. Whether an older branch can still be updated depends on the servicing channel.

**Read-only build check.** Run in an unprivileged PowerShell session. It only reads the registry:

```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
  Select-Object ProductName, DisplayVersion, CurrentBuild, UBR
```

Compare `CurrentBuild.UBR` with the table. A missing KB in `Get-HotFix` does not mean the build is unfixed, so trust the build number. For a fleet, use the patch-compliance report, and treat a device that has not reported recently as **unknown**. These commands were not run against a real fleet for this review.

Microsoft has published no indicator for the race itself. A failed sign-in after the update matches the known issue in KB5135557, not evidence that the flaw was used. Event 4021 in `Microsoft-Windows-NTLM/Operational`, with Target Machine "Not Found", is the signature Microsoft gives for that known issue.

## Remediation

1. Install the November 10 cumulative update for each branch in the table, through Windows Update, WSUS, Configuration Manager, or Intune. Reboot. The same update covers CVE-2026-116928.
2. Microsoft lists no workaround for the race. Do not leave a host below the floor because a third-party proxy fails to sign in.
3. If a sign-in through a proxy, an SSO product, or a packaging tool fails after the update, KB5135557's temporary workaround is `ClientAllowUnsignedNtlm` = 1 under `HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0`. Microsoft says to use that only until the product offers Kerberos or a build that fills in the NTLM target names, and that a client left at 1 is exactly what servers will reject when they require signing in May 2027. Prefer fixing the product.
4. The update does not show whether a request already ran code.

## Verification

- The build number is at or above the fixed build for the branch.
- The computer was rebooted into that build. Installing the package without a reboot leaves the running component on the old build.
- A sign-in that the known issue broke either works again on a vendor build that implements NTLM correctly, or is on Kerberos. `ClientAllowUnsignedNtlm` is not the lasting state.
- Do not send a crafted RPC request to test it.

## Compromise response

Microsoft says it has no evidence of exploitation and publishes no indicators. If a review finds a process the RPC service should not have started, preserve the logs before rebuilding, and treat credentials that computer could reach as exposed. The update does not remove a payload that already ran.

## Sources

- [MSRC CVE-2026-118737][msrc] — revision 1.0, November 10, 2026. Score 8.1, temporal 7.1. Exploited: No. Publicly disclosed: No. Exploitation Less Likely. The FAQ describes the race and the pending DNS query. The Security Updates table lists the KBs and builds.
- [CVE record][cve] — published 2026-11-10. Microsoft is the CNA. The description matches the MSRC page.
- [KB5135557][kb] — NTLM signing security improvements. Original publish date November 10, 2026. The change log adds the known issue on November 20, 2026. Phase 2, servers requiring signing, is May 2027 with no day.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-26. CVE-2026-118737 is not listed.

[msrc]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-118737
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-118737
[kb]: https://support.microsoft.com/en-us/servicing/os/windows/docs/2026/11/kb5135557-ntlm-signing-security-improvements
