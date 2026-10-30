# Mitsubishi Electric ICONICS GENESIS and GENESIS64 SCADA: fixed unlock response and excess DCOM permissions

**Last updated:** 2026-10-30 (America/New_York)

[Main Mitsubishi Electric ICONICS summary](../black-october-2026.md#mitsubishi-electric-iconics-genesis-and-genesis64-scada-fixed-unlock-response-and-excess-dcom-permissions) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Mitsubishi Electric advisory 2026-006 covers four vulnerabilities in its ICONICS SCADA and HMI family: GENESIS, GENESIS64, ICONICS Suite, Hyper Historian, AnalytiX, MobileHMI, IoTWorX, MC Works64, GENESIS32 and BizViz. CISA republished it as ICSA-26-300-02. The products run on Windows and are used for industrial monitoring and control. CISA lists the sector as critical manufacturing, deployed worldwide. [Mitsubishi 2026-006][me] [CISA ICSA-26-300-02][cisa]

**Severity (Mitsubishi Electric is the CNA for the 2026 CVEs).** Mitsubishi's advisory and CVE records give CVSS 4.0 scores. The CSAF advisory that CISA republished also gives CVSS 3.1 scores. NVD has added no score of its own ("Awaiting Analysis"). [Mitsubishi 2026-006][me] [CSAF][csaf] [NVD][nvd-16438]

| CVE | What it is | Mitsubishi CVSS 4.0 | CVSS 3.1 (CSAF) | Attacker needs |
|---|---|---|---|---|
| [CVE-2026-16438](https://www.cve.org/CVERecord?id=CVE-2026-16438) | Incorrect privilege assignment (CWE-266). Installers grant default DCOM permissions to the products' administrator account, so that account can launch and operate DCOM objects locally or remotely that should require UAC elevation. | **9.4 Critical** (`AV:N/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`) | **9.1 Critical** (`AV:N/AC:L/PR:H/UI:N/S:C/C:H/I:H/A:H`) | The ability to log in with the products' administrator account |
| [CVE-2026-16436](https://www.cve.org/CVERecord?id=CVE-2026-16436) | Weak password recovery (CWE-640). The challenge response that unlocks the system is fixed and common to all users. | **9.2 Critical** (`AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`) | **8.1 High** (`AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`) | No authentication, but the challenge response "by some means" |
| [CVE-2026-16437](https://www.cve.org/CVERecord?id=CVE-2026-16437) | Weak password recovery (CWE-640). An administrator can tamper with the Windows-protected management file that stores the challenge response. | 7.1 High (`AV:L/AC:H/AT:N/PR:H/…`) | 6.4 Medium (`AV:L/AC:H/PR:H/…`) | Local login with Windows administrator privileges |
| [CVE-2023-4863](https://www.cve.org/CVERecord?id=CVE-2023-4863) | The 2023 libwebp heap overflow, in a bundled component of GENESIS64 and ICONICS Suite 10.97–10.97.2 | 9.3 Critical (`AV:L/AC:L/AT:N/PR:H/…/SC:H/SI:H/SA:H`), Mitsubishi's score for its products | 8.2 High (`AV:L/AC:L/PR:H/UI:N/S:C/…`) | A local administrator of the product importing a crafted file |

**Worst case:** Mitsubishi says each flaw can lead to information disclosure, tampering with, destruction or deletion of information, or denial of service. CVE-2026-16436 is the one that needs no authentication: anyone who obtains the shared unlock response can unlock the system. CVE-2026-16438 lets anyone with the products' administrator credentials operate DCOM objects remotely without UAC elevation. Mitsubishi has published no technical details beyond its advisory. [Mitsubishi 2026-006][me]

**Fix status by product:** GENESIS, GENESIS64, ICONICS Suite, Hyper Historian, AnalytiX, MobileHMI and IoTWorX have fixed versions. **MC Works64, GENESIS32 and BizViz will not be fixed**; Mitsubishi recommends its mitigations or replacing them with GENESIS64 or GENESIS. See [Remediation](#remediation).

**CISA KEV:** [CVE-2026-16436](https://www.cve.org/CVERecord?id=CVE-2026-16436), [CVE-2026-16437](https://www.cve.org/CVERecord?id=CVE-2026-16437) and [CVE-2026-16438](https://www.cve.org/CVERecord?id=CVE-2026-16438): Not listed (catalog 2026.10.29, checked 2026-10-30). CISA's ADP assessment of 2026-10-15 records "Exploitation: none" for all three, and neither Mitsubishi nor CISA reports exploitation. Absence from KEV is not evidence that exploitation has not occurred. [CVE-2023-4863](https://www.cve.org/CVERecord?id=CVE-2023-4863): Listed — added 2023-09-13, federal due date 2023-10-04. That listing is for Google Chromium WebP exploited through crafted web pages; it is not evidence that the ICONICS products were attacked. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Affected versions](#affected-versions)
  - [Inventory commands (read-only)](#inventory-commands-read-only)
  - [Exposure and log review](#exposure-and-log-review)
- [Remediation](#remediation)
  - [Mitigations when you cannot update](#mitigations-when-you-cannot-update)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | CISA's acknowledgment says Mitsubishi Electric found these vulnerabilities itself; no date is given. [CISA][cisa] |
| CVE-2023-4863 added to CISA KEV | 2023-09-13 | For Google Chromium WebP; federal due date 2023-10-04. [KEV JSON][kev] |
| **Public announcement**: Mitsubishi Electric advisory 2026-006 | 2026-10-15; time/TZ unknown | "Release date: October 15, 2026". Fixed versions were available by then; their individual release dates are not given. [Mitsubishi 2026-006][me] |
| CVE records published | 2026-10-15 08:29:44–08:31:41 UTC | Mitsubishi Electric CNA records for CVE-2026-16436, -16437 and -16438. [CVE JSON][cve-16438] |
| CISA ADP assessments | 2026-10-15 14:04–14:10 UTC | Exploitation: none; Automatable: no; Technical impact: total. [CVE JSON][cve-16438] |
| CISA republication | 2026-10-27 (CSAF revision timestamp 06:00 UTC) | ICSA-26-300-02, revision 2. [CSAF][csaf] |
| CISA revision 3 | 2026-10-29; time/TZ unknown | "Updating vendor and product name". The versions, scores and fixes compared with revision 2 did not change. [CISA][cisa] |
| CISA KEV | Not listed as of catalog 2026.10.29 (checked 2026-10-30) | CVE-2026-16436, -16437 and -16438. [KEV JSON][kev] |

## Detection

### Affected versions

| CVE | Affected | First fixed |
|---|---|---|
| CVE-2026-16436, CVE-2026-16437 | GENESIS 11.03 and earlier | GENESIS 11.04 |
| CVE-2026-16436, CVE-2026-16437, CVE-2026-16438 | GENESIS64, ICONICS Suite, Hyper Historian, AnalytiX, MobileHMI 10.97.3 and earlier | ICONICS Suite 10.98 (GENESIS64, Hyper Historian, AnalytiX and MobileHMI install with ICONICS Suite) |
| CVE-2026-16436, CVE-2026-16437 | IoTWorX 10.97.3 and earlier | IoTWorX 10.98 (Docker image) |
| CVE-2026-16436, CVE-2026-16437, CVE-2026-16438 | MC Works64, all versions | No fix planned |
| CVE-2026-16436, CVE-2026-16437 | GENESIS32 and BizViz, all versions | No fix planned |
| CVE-2023-4863 | GENESIS64 and ICONICS Suite 10.97–10.97.2 | ICONICS Suite 10.97.3 |

ICONICS Suite **10.97.3 fixes only the libwebp flaw**. It is still affected by CVE-2026-16436, -16437 and -16438, so 10.97.3 installations need 10.98. [Mitsubishi 2026-006][me]

Mitsubishi maps product versions to the version shown in Windows **Settings → Apps → Apps & features**: [Mitsubishi 2026-006][me]

- **GENESIS:** affected if "ICONICS GENESIS" shows **11.3.578** or earlier (11.03).
- **GENESIS64, ICONICS Suite, Hyper Historian, AnalytiX, MobileHMI, IoTWorX:** check the "ICONICS Suite" entry. **10.97.306.55** or earlier (10.97.3) is affected by the 2026 CVEs. **10.97.020.27** through **10.97.212.46** (10.97–10.97.2) is also affected by CVE-2023-4863.

### Inventory commands (read-only)

Run these in Windows PowerShell on each SCADA server, engineering workstation and client that has the software. They only read the registry and file system. They were not run on a real ICONICS installation for this guide.

List installed ICONICS and Mitsubishi SCADA products and their versions:

```powershell
Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
  Where-Object { $_.DisplayName -match 'ICONICS|GENESIS|MC Works|BizViz|Hyper Historian|AnalytiX|MobileHMI' } |
  Select-Object DisplayName, DisplayVersion
```

Check whether the challenge-response files named in Mitsubishi's mitigation exist, and who can change them:

```powershell
'C:\Program Files\ICONICS\GENESIS64\Components\ClientChallengeTable.dat', 'C:\ProgramData\ICONICS\11\SecurityChallenges.dat' |
  Where-Object { Test-Path $_ } |
  ForEach-Object { Get-Item $_ | Select-Object FullName, Length, LastWriteTime; (Get-Acl $_).Access | Format-Table IdentityReference, FileSystemRights, AccessControlType }
```

Version 10 uses the first path and version 11 the second. A missing file, a custom install path or an access error means **unknown**, not unaffected. IoTWorX runs as a Docker image; check the deployed image tag instead.

### Exposure and log review

- **CVE-2026-16438 (DCOM):** Find which networks can reach the SCADA hosts over DCOM. DCOM uses the RPC endpoint mapper (TCP 135) and dynamic RPC ports; this is general Windows behaviour, not a statement from Mitsubishi. Identify every person and system that knows the products' administrator account credentials, because that account is what the flaw requires.
- **CVE-2026-16436 (shared unlock response):** Mitsubishi does not say how an attacker could obtain the response. Treat any host where the security challenge feature can be reached from untrusted networks or users as exposed.
- **Logs:** Mitsubishi publishes no indicators of compromise. Review Windows Security logs for logons with the products' administrator account from unexpected hosts, DCOM/RPC activation errors and events, and changes to `ClientChallengeTable.dat` or `SecurityChallenges.dat`. Finding nothing does not prove the system was not accessed.

## Remediation

1. **Update** where a fix exists. Test in a non-production environment and follow your OT change-management process first; a failed SCADA update can affect operations.
   - GENESIS64, ICONICS Suite, Hyper Historian, AnalytiX and MobileHMI: **ICONICS Suite 10.98 or later**.
   - IoTWorX: **10.98 or later** from the `iconics/iotworx` Docker Hub image.
   - GENESIS: **11.04 or later**.
   - Installers come from the [ICONICS community download portal][downloads], which needs a login. [Mitsubishi 2026-006][me]
2. **MC Works64, GENESIS32 and BizViz** will not be fixed. Apply all the mitigations below, and plan a move to GENESIS64 or GENESIS. Mitsubishi's MC Works64 migration guide is in Japanese and behind a login on its FA site. [Mitsubishi 2026-006][me]
3. Updating does not change who knows the products' administrator credentials. After updating, review that account and change its password if many people or systems share it. This is a precaution, not a step Mitsubishi lists.

### Mitigations when you cannot update

Mitsubishi recommends these for all four vulnerabilities: [Mitsubishi 2026-006][me]

- Allow only administrators to log in to the PCs that run the products.
- Keep those PCs on the LAN, and block remote login from untrusted networks, untrusted hosts and non-administrator users.
- When internet access is required, use a firewall or VPN, and allow remote login only for administrators.
- Restrict physical access to the PCs and their network.
- Do not open links or attachments in untrusted emails.
- Install anti-virus software on the PCs (and, for CVE-2026-16438, on PCs that can reach them).

For **CVE-2026-16436 and CVE-2026-16437** on GENESIS, GENESIS64, ICONICS Suite, Hyper Historian, AnalytiX, MobileHMI and MC Works64, Mitsubishi also gives a workaround:

1. Delete the challenge-response file: `C:\Program Files\ICONICS\GENESIS64\Components\ClientChallengeTable.dat` (version 10) or `C:\ProgramData\ICONICS\11\SecurityChallenges.dat` (version 11).
2. Create a blank file with the same name in the same place.
3. Allow write and delete access to that file only to a separate administrator account, not the GENESIS administrator account.

This changes the system and disables the shared unlock response, so plan for how users will recover access. Back up the original file outside the host before you delete it, and keep the backup protected because it contains the challenge responses. Mitsubishi does not list this workaround for IoTWorX, GENESIS32 or BizViz.

For **CVE-2026-16438**, Mitsubishi recommends blocking access from untrusted networks and hosts with firewalls, and a firewall or VPN when internet access is required.

## Verification

- Re-run the inventory command and confirm that ICONICS Suite shows 10.98 or later, GENESIS 11.04 or later, and the IoTWorX image tag is 10.98 or later on every host.
- Where you applied the file workaround, re-run the file check and confirm the file is blank and that only the separate administrator account can write or delete it.
- From an untrusted network segment, confirm that the SCADA hosts' RPC/DCOM ports and remote login are blocked, and that approved operator workstations still work.
- Do not try to unlock production systems with a known challenge response or test DCOM launches against production.

## Compromise response

- If you suspect misuse, follow the site's OT incident and safety procedures first. Preserve Windows event logs, the challenge-response files and the project configuration before changing anything.
- Look for logons with the products' administrator account from unexpected hosts, new or changed DCOM-launched processes, changes to the challenge-response files, and unexpected changes to displays, alarms, historian data or control values.
- Change the products' administrator credentials and any credentials stored in the project. Contact your Mitsubishi Electric representative for product-specific recovery.
- If you cannot establish the host's integrity, rebuild it from trusted media and a known-good project backup.

## Sources

- [Mitsubishi Electric advisory 2026-006][me] (released 2026-10-15) — affected and fixed versions, CVSS 4.0 scores, descriptions, impact, version mapping, mitigations and the file workaround.
- [CISA ICSA-26-300-02][cisa] and its [CSAF][csaf] — the republication, CVSS 3.1 scores, acknowledgment, no-fix statements, and revisions 2 (2026-10-27) and 3 (2026-10-29).
- CVE records (Mitsubishi Electric CNA, with CISA ADP): [CVE-2026-16436][cve-16436], [CVE-2026-16437][cve-16437], [CVE-2026-16438][cve-16438]. [NVD][nvd-16438] shows "Awaiting Analysis" with only Mitsubishi's score.
- [CISA KEV JSON feed][kev] — catalog 2026.10.29.

[me]: https://www.mitsubishielectric.com/psirt/vulnerability/pdf/2026-006_en.pdf
[cisa]: https://www.cisa.gov/news-events/ics-advisories/icsa-26-300-02
[csaf]: https://github.com/cisagov/CSAF/blob/develop/csaf_files/OT/white/2026/icsa-26-300-02.json
[cve-16436]: https://cveawg.mitre.org/api/cve/CVE-2026-16436
[cve-16437]: https://cveawg.mitre.org/api/cve/CVE-2026-16437
[cve-16438]: https://cveawg.mitre.org/api/cve/CVE-2026-16438
[nvd-16438]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-16438
[downloads]: https://iconicsinc.my.site.com/community/s/resource-center/product-downloads
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
