# VMware vCenter: a network request skips login

**Last updated:** 2026-11-20 (America/New_York)

[Main vCenter summary](../black-october-2026.md#vmware-vcenter-a-network-request-skips-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-19 Broadcom published [VMSA-2026-0009][vmsa]. Broadcom rates [CVE-2026-123890](https://www.cve.org/CVERecord?id=CVE-2026-123890) **Critical, CVSS 3.1 9.8**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Broadcom is the CNA. The flaw is in the VMware Directory Service. A request with network access to vCenter bypasses authentication. Google Threat Intelligence Group and Mandiant say the result is a session as `administrator@vsphere.local`, and that ARMORY CASTLE used it in early September 2026. There is no workaround. ESX hosts are not affected.

The same advisory fixes four more flaws. Two are High and need a login on SDDC Manager. Two are Moderate.

| CVE | Broadcom score | What it does | Fixed in |
| --- | --- | --- | --- |
| [CVE-2026-123890](https://www.cve.org/CVERecord?id=CVE-2026-123890) | Critical, 9.8. `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H` | Directory Service authentication bypass. No login. | vCenter 9.1.1.0200, 9.0.2.0200, 8.0 U3m, Cloud Foundation 5.2.5. vCenter 7.0 is end of general support; an extended-support contract is the only path. Telco Cloud follows [KB463116][kb463]. |
| [CVE-2026-123891](https://www.cve.org/CVERecord?id=CVE-2026-123891) | Important, 8.1. `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N` | SQL injection. A logged-in user reads and writes the SDDC Manager database. | SDDC Manager 9.1.1.0200, 9.0.2.0100, 5.2.5. |
| [CVE-2026-123892](https://www.cve.org/CVERecord?id=CVE-2026-123892) | Important, 7.2. `CVSS:3.1/AV:N/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:H` | Command injection. A logged-in user runs a command on the appliance. | the same three SDDC Manager builds. |
| [CVE-2026-123893](https://www.cve.org/CVERecord?id=CVE-2026-123893) | Moderate, 6.7. `CVSS:3.1/AV:L/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:H` | A local administrator on SDDC Manager becomes root. | the same three SDDC Manager builds. |
| [CVE-2026-123894](https://www.cve.org/CVERecord?id=CVE-2026-123894) | Moderate, 6.7. `CVSS:3.1/AV:L/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:H` | VMware Tools for Windows accepts a SAML token. The attacker already has a privileged process in a Windows guest that uses guest alias mapping. The escalation stays inside that guest. | Tools 13.1.5.0 for 13.x, and 12.5.5 for 12.x and 11.x. 12.4.10, inside 12.5.5, covers Windows 32-bit. |

GTIG describes CVE-2026-123890 as an unauthenticated Secure Remote Password session-key disclosure over DCE/RPC on TCP 2012. With the administrator session, the attacker can run commands and copy `data.mdb` through the `vmdird` interface `vmdirdbcp`. Broadcom's FAQ says this is not the July flaw, [CVE-2026-59309](https://www.cve.org/CVERecord?id=CVE-2026-59309), and that a system patched for that one still needs this update. Mandiant says BONESAW ran in early September against a vCenter that was already patched for the July flaw. None of the five is a guest-to-host escape. ESX does not need an update for this advisory.

**CISA KEV:** Listed — [CVE-2026-123890](https://www.cve.org/CVERecord?id=CVE-2026-123890) was added 2026-11-20, federal due date 2026-11-23. CISA requires mitigations per the vendor and forensic triage under BOD 26-04. Ransomware use is Unknown. The other four are not listed (catalog 2026.11.20, checked 2026-11-20). [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| BONESAW build time | 2026-07-13 09:21:24 UTC | The Go binary Mandiant recovered. Build metadata can be changed before compilation. [GTIG][gtig] |
| Exploitation | early September 2026; day and time unknown | ARMORY CASTLE used BONESAW against a vCenter already patched for CVE-2026-59309. [GTIG][gtig] |
| **Public announcement and fixes** | **2026-11-19; CVE records from 14:02:38 UTC** | VMSA-2026-0009, initial advisory. [VMSA][vmsa] |
| GTIG write-up | 2026-11-19; time/TZ unknown | Names the actor, the session, and the tooling. [GTIG][gtig] |
| **CISA KEV** | **2026-11-20; catalog released 17:48:39 UTC** | CVE-2026-123890 added. Federal due date 2026-11-23. The other four are not listed. [KEV][kev] |
| VMSA update | 2026-11-20; time/TZ unknown | VMSA-2026-0009.1. Tools 11.x and 12.x are fixed in 12.5.5, and 13.x in 13.1.5.0. [VMSA][vmsa] |
| **Last updated** | **2026-11-20 (America/New_York)** | KEV listing, and the Tools range now includes 11.x. |

## Detection

Read the build from the appliance, not from a plan.

- vCenter 9.1 below 9.1.1.0200, 9.0 below 9.0.2.0200, and 8.0 below 8.0 U3m are inside CVE-2026-123890. Cloud Foundation 5.x below 5.2.5 is inside it. vCenter 7.0 has no public build.
- SDDC Manager 9.1 below 9.1.1.0200, 9.0 below 9.0.2.0100, and 5.x below 5.2.5 are inside the three SDDC Manager flaws. The 9.0 floor is 9.0.2.0100, one build behind the vCenter floor.
- Windows guests with VMware Tools 13.x below 13.1.5.0, or 11.x or 12.x below 12.5.5, are inside CVE-2026-123894. The advisory says the attack needs guest alias mapping, and it lists no workaround, so update Tools either way. `VGAuthCLI.exe list`, run as an administrator in the guest, lists aliases. Turning guest operations off in vSphere does not close this flaw.

GTIG's reconnaissance hit TCP 443, 2012, 389, 5480, and 9080. Port 2012 is the Directory Service RPC. A scan of that port is a lead, and a closed port today does not show whether it was open in September.

The files Mandiant names are on the Linux host the actor used, not on vCenter itself:

- `/tmp/123` is BONESAW. The `csa` command writes `anon_<host>_data.mdb` and tenant credential PEM files under an output directory.
- `/tmp/sss` is SAWSNAKE. It writes `idp_key.pem`, `trusted_cert_2.pem`, and `domain.txt`.
- `/tmp/dbr` is BEARBONES. Its banner is `SSH-2.0-pulsesecure_23345`.
- Webshells `ActiveSer.jsp` and `u.jsp`.
- `/usr/bin/vmtoolscs` is the LAZYBONES Slack backdoor.

On vCenter, Mandiant saw SSH enabled through a PUT to `/rest/appliance/access/ssh`, a new SSO account named `sps-<redacted>@vsphere.local`, and SSH turned back off after the master key and the PostgreSQL password were copied. An SSO account you did not create, and SSH that was enabled and then disabled, are leads. Not seeing them does not clear the appliance. The actor deleted tools after use.

## Remediation

1. Update vCenter to **9.1.1.0200**, **9.0.2.0200**, or **8.0 U3m**. Cloud Foundation 5.x goes to **5.2.5** by the async path in [KB 88287][kb882]. Telco Cloud Platform and Telco Cloud Infrastructure follow [KB463116][kb463]. vCenter 7.0 has no public fix; an extended-support contract is the path Broadcom names, and Broadcom says to move to Cloud Foundation 9.1.
2. These vCenter updates are **not eligible for vCenter Quick Patch**. Use the ordinary update, including the VAMI. vSphere 8 has to be on Update 3 before 8.0 U3m applies.
3. **vCenter 8.0 U3m and 9.0.2.0200 block an upgrade to Cloud Foundation 9.1.1.** Broadcom says to wait for 9.1.2, or to move vCenter to 9.1.1 first and apply the security update there. [KB 67077][kb670] is the back-in-time note.
4. Update SDDC Manager to **9.1.1.0200**, **9.0.2.0100**, or **5.2.5**. That update does not stop virtual machines.
5. Update VMware Tools for Windows to **13.1.5.0** on 13.x, and to **12.5.5** on 12.x and 11.x. VMSA-2026-0009.1, dated 2026-11-20, adds 11.x and the rest of 12.x to the range the earlier text limited to 12.3. 12.4.10, inside 12.5.5, covers Windows 32-bit.
6. ESX hosts do not need an update for this advisory. Updating vCenter does not update them, and they do not have to move first.
7. There is no workaround. A firewall in front of TCP 2012, 443, and 5480 is not a substitute for the build.

## Verification

- The vCenter build is 9.1.1.0200, 9.0.2.0200, or 8.0 U3m, and the appliance has been restarted onto it.
- SDDC Manager, where you run it, is 9.1.1.0200, 9.0.2.0100, or 5.2.5.
- Windows guests report Tools 13.1.5.0, or 12.5.5 on 12.x and 11.x.
- Do not send an SRP exchange to port 2012.

## Compromise response

GTIG says the flaw was used as a zero-day in early September 2026. A vCenter that was below the fixed build then should be treated as a possible compromise, not only as a patch job.

Look for an SSO account you did not create, SSH enabled through the VAMI, a copy of `/storage/db/vmware-vmdir/data.mdb` leaving the appliance, and the STS signing key. Mandiant then saw `vpxuser` and root SSH to ESXi, a hidden `.a` directory on a VMFS volume, and copies of a guest's `NTDS`, `SYSTEM`, and `SECURITY` hives. An ESXi host that was reachable from that vCenter needs the same review. The update does not remove an account, a key, or a hive that was already copied. Rotate the SSO administrator password and the vCenter master key if those artifacts are present, and rebuild from a known-clean backup if they are.

## Sources

- [VMSA-2026-0009][vmsa] — initial advisory, issue date 2026-11-19. Critical, CVSS 3.1 range 6.7–9.8. No workaround.
- [VMSA-2026-0009 questions and answers][faq] — ESX is not affected. The vCenter updates are not eligible for Quick Patch. 8.0 U3m and 9.0.2.0200 block an upgrade to Cloud Foundation 9.1.1. CVE-2026-123890 is distinct from CVE-2026-59309.
- [CVE-2026-123890](https://www.cve.org/CVERecord?id=CVE-2026-123890) — Broadcom, published 2026-11-19 14:02:38 UTC. CVSS 3.1 9.8.
- [CVE-2026-123891](https://www.cve.org/CVERecord?id=CVE-2026-123891), [CVE-2026-123892](https://www.cve.org/CVERecord?id=CVE-2026-123892), [CVE-2026-123893](https://www.cve.org/CVERecord?id=CVE-2026-123893), [CVE-2026-123894](https://www.cve.org/CVERecord?id=CVE-2026-123894) — the four others, published the same minute.
- [GTIG and Mandiant, ARMORY CASTLE][gtig] — published 2026-11-19. Exploitation in early September, the session name, TCP 2012, and the tool names.
- [CISA KEV JSON][kev] — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z. CVE-2026-123890 was added 2026-11-20, due 2026-11-23. The other four are not listed.

[vmsa]: https://support.broadcom.com/web/ecx/support-content-notification/-/external/content/SecurityAdvisories/0/39495
[faq]: https://github.com/vmware/vcf-security-and-compliance-guidelines/blob/main/security-advisories/vmsa-2026-0009/README.md
[gtig]: https://cloud.google.com/blog/topics/threat-intelligence/armory-castle-exploits-vsphere
[kb882]: https://knowledge.broadcom.com/external/article?legacyId=88287
[kb463]: https://knowledge.broadcom.com/external/article/463116
[kb670]: https://knowledge.broadcom.com/external/article?legacyId=67077
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
