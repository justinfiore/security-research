# Delinea Privilege Manager: Windows agent remote code execution

**Last updated:** 2026-11-05 (America/New_York)

[Back to Privilege Manager summary](../black-october-2026.md#delinea-privilege-manager-windows-agent-remote-code-execution) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Delinea rates [CVE-2026-92744](https://www.cve.org/CVERecord?id=CVE-2026-92744) CVSS 4.0 **8.7 High**. The Privilege Manager Windows agent lets a remote unauthenticated attacker run code as LocalSystem. This is not the [Secret Server](delinea-secret-server.md) login bypass. Upgrading the Secret Server application does not update this agent.

The reporter's November 5 write-up names the condition Delinea's text leaves out. The agent listens on TCP 5593, on all interfaces, and the installer allows that port inbound. The certificate check that is supposed to gate the callback, `AmsServerCertValidator.Validate()`, has an empty body, so a certificate the caller just generated is accepted. One callback then runs PowerShell as `NT AUTHORITY\SYSTEM`. The reporter's end-to-end proof was on the same machine, on 2026-09-12. They did not test a call from a second host, and they rate that demonstrated case 7.8 rather than Delinea's 8.7. The fixed builds are unchanged.

The CNA's affected ranges are **10.1.0 through 12.0.5796** and **13.0.0 through 13.0.1058**. Delinea's release notes put the fix in Windows Core agent **12.0.5804** and **13.0.2064** and newer. The same notes tell customers who cannot upgrade yet to block inbound TCP **5593**.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05). Delinea does not report exploitation, and the reporter's write-up is a closed disclosure, not an in-the-wild report. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | No reporter date in the CNA record. |
| CVE published | 2026-10-29 | Delinea CNA. Affected agent ranges above. [CVE-2026-92744][cve] |
| Vendor advisory | Published date October 29, 2026 | On-prem and cloud. Fix builds 13.0.2064 and 12.0.5804. [Advisories][advisories] |
| Release-note workaround | Date not stated on the note | Block inbound TCP 5593 until the new agent is installed. [12.0.5 notes][notes] |
| Reporter write-up | 2026-11-05; time/TZ unknown | Names the empty certificate validator and the SYSTEM PowerShell callback. The proof was local, on 2026-09-12. Fixed builds unchanged. [Write-up][writeup] |

## Detection

1. Read the **Windows Core agent** build on each workstation, not the Privilege Manager server version. Builds through 12.0.5796 on the 12 line, and through 13.0.1058 on the 13 line, are inside the CNA range.
2. The agent listens for inbound TCP **5593**. A host that does not run the Windows agent is outside this CVE. macOS and Unix agents are not named.
3. The reporter says the listener is bound to all interfaces and the installer opens inbound TCP 5593 on the Domain, Private, and Public firewall profiles. A host that does not accept inbound 5593 is not in the condition they describe.
4. There is no published log query that proves the flaw was or was not used.

## Remediation

1. Install Windows Core agent **13.0.2064 or newer** when the installed 13 line is above 12.0.5796. Install **12.0.5804 or newer** when the installed agent is 12.0.5796 or older. Delinea says both builds are on its Software Downloads page.
2. If that install cannot happen now, use group policy or device management to block inbound TCP **5593**. Delinea says Cloud loses no function from blocking the port. On-premises, block it or restrict it to the Privilege Manager web server; a full block makes agents pull updates on their schedule instead.
3. Blocking the port is containment. It is not a substitute for the agent build.

## Verification

- The installed Windows Core agent build is 12.0.5804 or newer, or 13.0.2064 or newer, on every workstation that had an affected build.
- Until then, an inbound check from a network that should not reach the agent shows TCP 5593 closed.
- Do not send an exploit at a workstation to confirm the flaw.

## Compromise response

If an affected agent accepted connections on TCP 5593 from a network you do not control, treat that workstation as possibly running attacker code as LocalSystem. Preserve the disk, rebuild from a known image, and review accounts that the workstation could reach. Installing the fixed agent does not show whether the old one was used.

## Sources

- [CVE-2026-92744][cve] — Delinea CNA, published 2026-10-29, CVSS 4.0 8.7 High. Affected 10.1.0–12.0.5796 and 13.0.0–13.0.1058.
- [Delinea security advisories][advisories] — on-prem and cloud; upgrade to 13.0.2064 or 12.0.5804.
- [Privilege Manager 12.0.5 release notes][notes] — known issue, same builds, and the TCP 5593 block.
- [CyberCrew write-up][writeup] — repository created 2026-11-05. The empty `Validate()` body, the TCP 5593 listener, and the SYSTEM PowerShell callback. The proof was on the same machine. Their score for that case is CVSS 3.1 7.8, not Delinea's 8.7.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.04, checked 2026-11-05).

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-92744
[advisories]: https://delinea.com/security-advisories
[notes]: https://docs.delinea.com/online-help/privilege-manager/release-notes/12.0.5-combined.htm
[writeup]: https://github.com/isukasanuj/CVE-2026-92744
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
