# SAP: November patch day - unauthenticated code execution in Web Dispatcher, ICM, and Gateway

**Last updated:** 2026-11-11 (America/New_York)

[Main SAP November summary](../black-october-2026.md#sap-november-patch-day---unauthenticated-code-execution-in-web-dispatcher-icm-and-gateway) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**SAP (CNA) rates four of these CVSS 3.1 10.0 Critical and five more Critical at 9.9, 9.9, 9.9, 9.6, and 9.1. NVD has added no score of its own.** All nine records were published 2026-11-10, between 00:17 and 00:43 UTC, as part of the November 10 SAP Security Patch Day. Each CVE record links an SAP Note at `me.sap.com`, which requires an SAP login. Those notes were not read for this guide, so no fixed patch level is stated here. SAP published the public patch-day page on November 10. It lists 35 new security notes and 4 GitHub security advisories, plus 3 updates to notes released earlier. It names affected versions and scores, and it does not name a fixed patch level. The notes index now links that page. A read on November 10 did not find the link. [November bulletin][nov] [CNA records][cve-list]

The four unauthenticated 10.0 flaws:

- **[CVE-2026-120017](https://www.cve.org/CVERecord?id=CVE-2026-120017)** — SAP NetWeaver AS ABAP and ABAP Platform, SAML2 service provider. SAP says the system does not verify incoming authentication assertions sufficiently under certain configurations, so an unauthenticated attacker can submit crafted data, bypass authentication, and impersonate any user, including a privileged account. SAP says the impact can extend to connected systems. Affected: SAP_BASIS 702, 731, 740, 750, 751, 752, 753, 754, 755, 756, 757, 758, 816, 920, 921, 922. Vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`. Note [3849308][n3849308].
- **[CVE-2026-89126](https://www.cve.org/CVERecord?id=CVE-2026-89126)** — SAP Web Dispatcher. SAP says crafted network traffic triggers memory corruption and can run code. The CVE record lists KERNEL 7.53, 9.18, and 9.20. The November bulletin also lists KERNEL 7.54, 7.77, 7.93, and 9.16. The rest matches both: HDB 2.00, KRNL64UC 7.53, WEBDISP 7.53, 7.54, 7.77, 7.93, 9.16, XS_ADVANCED_RUNTIME 1.00, SAP_EXTENDED_APP_SERVICES 1. Note [3778556][n3778556].
- **[CVE-2026-76964](https://www.cve.org/CVERecord?id=CVE-2026-76964)** — SAP NetWeaver AS ABAP, Internet Communication Manager. SAP says the same kind of memory corruption, from unauthenticated network traffic, can run code. Affected: KRNL64UC 7.53, KERNEL 7.53, 7.54, 7.77, 7.93, 9.16, 9.18, 9.20. Note [3778530][n3778530].
- **[CVE-2026-89103](https://www.cve.org/CVERecord?id=CVE-2026-89103)** — SAP Gateway. SAP says the default access control list is activated with high privileges, so an external attacker is categorized as an internal application server and can perform unauthorized actions. The CVE record lists KRNL64UC 7.22, 7.53, and 8.04, and KERNEL 7.22, 7.54, 7.77, 7.93, 9.16, 9.20, and 9.21. The November bulletin also lists KRNL64UC 7.22EXT and KERNEL 7.53 and 8.04. Both list KRNL64NUC 7.22 and 7.22EXT. Note [3798345][n3798345].

The other five Critical flaws:

- **[CVE-2026-76965](https://www.cve.org/CVERecord?id=CVE-2026-76965)** — 9.9. A low-privileged user can run an operating system command on the host. The CVE record lists KRNL64UC 7.22 and 7.53, and KERNEL 7.22, 7.54, 7.77, 7.93, and 9.16. The November bulletin also lists KRNL64UC 7.22EXT and KERNEL 7.53. Both list KRNL64NUC 7.22 and 7.22EXT. Note [3792735][n3792735].
- **[CVE-2026-109803](https://www.cve.org/CVERecord?id=CVE-2026-109803)** — 9.9. Knowledge Management XML Forms (KMC-CM 7.50) does not restrict which XSL transformation it processes, so an authenticated user can run code. Note [3809153][n3809153].
- **[CVE-2026-109795](https://www.cve.org/CVERecord?id=CVE-2026-109795)** — 9.9. A low-privileged user sends crafted input through a remote interface and runs code. Affected: S4CRM 204, 205, 206; S4CEXT 107, 108, 109; BBPCRM 713, 714. Note [3834842][n3834842].
- **[CVE-2026-89119](https://www.cve.org/CVERecord?id=CVE-2026-89119)** — 9.6. Web Dispatcher and ICM do not validate an administrative request. An unauthenticated attacker who gets a logged-on administrator to open a link can act as that administrator, and SAP says that can compromise the operating system. The CVE record lists KERNEL 7.93, 9.20, and 9.21. The November bulletin also lists KERNEL 9.16. Both list WEBDISP 7.93 and 9.16, and XS_ADVANCED_RUNTIME 1.00. The same note lists a second CVE, [CVE-2026-120014](https://www.cve.org/CVERecord?id=CVE-2026-120014), which SAP scores 7.6 High: a cross-site request forgery against SAP HANA XSA Web Dispatcher. Note [3804858][n3804858].
- **[CVE-2026-109798](https://www.cve.org/CVERecord?id=CVE-2026-109798)** — 9.1. BusinessObjects Web Intelligence resolves external entities in an OLAP connection request, so an authenticated attacker can read files and reach internal systems. Affected: ENTERPRISE 430, 2025, 2027. Note [3799117][n3799117].

**The same day also published High flaws that this guide does not track individually.** A news summary of the patch day counts 15 High, 13 Medium, and 1 Low across 34 notes. The High records read for this guide include [CVE-2026-76966](https://www.cve.org/CVERecord?id=CVE-2026-76966) at 8.9, memory corruption from an unauthenticated crafted RFC request, and [CVE-2026-120008](https://www.cve.org/CVERecord?id=CVE-2026-120008) at 8.2, an out-of-bounds write in the Internet Graphics Service. Several more High records are denial of service only. Apply the whole November note set, not only the nine above. [SecurityOnline summary][news]

**Worst case:** An internet-reachable Web Dispatcher, ICM, or Gateway on an affected kernel lets an attacker with no account run code or act as an internal application server. The SAML2 flaw lets the same attacker become any user on an ABAP system whose configuration hits the unverified path. The 9.9 flaws need only a low-privileged account.

**Related items:** October's Visual Composer flaw, [CVE-2026-89110](https://www.cve.org/CVERecord?id=CVE-2026-89110), is tracked in [sap-netweaver-visual-composer.md](sap-netweaver-visual-composer.md). The SAP Cloud SDK for Python flaw, [CVE-2026-89111](https://www.cve.org/CVERecord?id=CVE-2026-89111), is tracked in [sap-cloud-sdk-python.md](sap-cloud-sdk-python.md). Neither is part of this patch day.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-11). None of the nine CVEs is in the feed. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory](#inventory)
  - [Exposure](#exposure)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | No researcher or report date is named in the CVE records. |
| SAP Security Patch Day | 2026-11-10; time/TZ unknown | Second Tuesday of November. [Patch day index][patchday] |
| Public bulletin | 2026-11-10; time/TZ unknown | SAP's page lists 35 new notes and 4 GitHub advisories, plus 3 updates. It names no fixed patch level. [November bulletin][nov] |
| CVE records published | 2026-11-10 00:17–00:43 UTC | Nine Critical records, SAP CNA. [CNA records][cve-list] |
| Exploitation evidence | None found | No vendor or government report of exploitation was found. |
| CISA KEV | Not listed (catalog 2026.11.10) | Checked 2026-11-11 against the live feed. [KEV JSON][kev] |

## Detection

### Inventory

1. List every SAP NetWeaver AS ABAP, ABAP Platform, Web Dispatcher, SAP Gateway, HANA XS Advanced, BusinessObjects, and S/4HANA CRM system, including development and disaster recovery.
2. Record the kernel release and patch level, and the component versions named above (SAP_BASIS, WEBDISP, KMC-CM, S4CRM, ENTERPRISE). Reading them changes no state. In an ABAP system the kernel release is shown by transaction `SM51` or the system status dialog.
3. Compare each component with the affected list in the matching CVE record above. A component on a release the record does not name is not automatically safe: the record lists affected versions, not a fixed version.

### Exposure

- **Who can reach it:** The four 10.0 flaws need no account. Note which Web Dispatcher, ICM, and Gateway ports are reachable from outside the network, and which ABAP systems expose the SAML2 service provider.
- **What a login is worth:** The 9.9 command and code flaws need only a low-privileged account. Count the accounts that can sign in, including partner and test accounts.

SAP and the reviewed sources have published no indicators of compromise and no request paths. Absence of unusual logins is not evidence the system was not reached.

## Remediation

1. **Apply the November 10 SAP Security Notes** through your normal SAP maintenance process, starting with the four 10.0 notes on anything reachable from the internet: [3849308][n3849308], [3778556][n3778556], [3778530][n3778530], and [3798345][n3798345]. Then the 9.9 and 9.6 notes: [3792735][n3792735], [3809153][n3809153], [3834842][n3834842], and [3804858][n3804858]. Then [3799117][n3799117]. Each note is behind an SAP login and names the correction for your release. This guide does not repeat a patch level it has not read.
2. **Apply the rest of the November note set.** The day also includes High flaws, including an 8.9 memory corruption from an unauthenticated RFC request ([CVE-2026-76966](https://www.cve.org/CVERecord?id=CVE-2026-76966), note [3769130][n3769130]) and an 8.2 out-of-bounds write in the Internet Graphics Service ([CVE-2026-120008](https://www.cve.org/CVERecord?id=CVE-2026-120008), note [3809953][n3809953]).
3. **Until the kernel notes are applied, limit who can reach the ports.** Restrict network access to SAP Gateway, Web Dispatcher, and ICM to the networks that need them. Review the SAML2 configuration on ABAP systems. Neither step replaces the note.
4. **Kernel and Web Dispatcher fixes need a restart** of the component that was updated. Plan it. Installing the package does not fix a process that is still running.
5. **Rollback caution:** Reverting the kernel or the note re-opens the flaw.

## Verification

- Confirm the kernel patch level and the component versions on every instance, including every application server in a cluster, match the correction the note names for that release.
- Confirm the updated Web Dispatcher, ICM, Gateway, and message server processes were restarted after the update.
- Confirm a normal business login and a normal SAML2 login still work. Do not send crafted assertions or packets at production to test these flaws.

## Compromise response

- A system that exposed Web Dispatcher, ICM, or Gateway to the internet before the update should be treated as possibly compromised. Preserve its logs before changing anything.
- On ABAP systems, review the Security Audit Log for logins that do not match a real user, new or changed privileged accounts, and unexpected RFC calls.
- Rotate credentials that such a system could have read, including RFC destinations and technical users.
- Applying the notes does not undo a change an attacker already made.

## Sources

- [CVE-2026-120017][c120017], [CVE-2026-89126][c89126], [CVE-2026-76964][c76964], [CVE-2026-89103][c89103], [CVE-2026-76965][c76965], [CVE-2026-109803][c109803], [CVE-2026-109795][c109795], [CVE-2026-89119][c89119], [CVE-2026-109798][c109798] — SAP CNA records, published 2026-11-10. Scores, vectors, affected components, and note links.
- [SAP Security Patch Day index][patchday] — reread 2026-11-11. November 10 is a link to the November bulletin. A read on November 10 found the date with no link.
- [SAP Security Patch Day, November 2026][nov] — reread 2026-11-11. 35 new notes and 4 GitHub advisories, plus 3 updates. Affected versions and scores. No fixed patch level. Note 3804858 also lists CVE-2026-120014 at 7.6. The nine `me.sap.com` notes still return an unauthenticated redirect to SAP login.
- [SecurityOnline, November 10 2026][news] — secondary count of the day's notes (9 Critical, 15 High, 13 Medium, 1 Low). Not a source for versions or scores.
- [CISA KEV JSON feed][kev] — none of the nine is listed in catalog 2026.11.10, checked 2026-11-11.

[cve-list]: https://www.cve.org/CVERecord?id=CVE-2026-120017
[c120017]: https://cveawg.mitre.org/api/cve/CVE-2026-120017
[c89126]: https://cveawg.mitre.org/api/cve/CVE-2026-89126
[c76964]: https://cveawg.mitre.org/api/cve/CVE-2026-76964
[c89103]: https://cveawg.mitre.org/api/cve/CVE-2026-89103
[c76965]: https://cveawg.mitre.org/api/cve/CVE-2026-76965
[c109803]: https://cveawg.mitre.org/api/cve/CVE-2026-109803
[c109795]: https://cveawg.mitre.org/api/cve/CVE-2026-109795
[c89119]: https://cveawg.mitre.org/api/cve/CVE-2026-89119
[c109798]: https://cveawg.mitre.org/api/cve/CVE-2026-109798
[n3849308]: https://me.sap.com/notes/3849308
[n3778556]: https://me.sap.com/notes/3778556
[n3778530]: https://me.sap.com/notes/3778530
[n3798345]: https://me.sap.com/notes/3798345
[n3792735]: https://me.sap.com/notes/3792735
[n3809153]: https://me.sap.com/notes/3809153
[n3834842]: https://me.sap.com/notes/3834842
[n3804858]: https://me.sap.com/notes/3804858
[n3799117]: https://me.sap.com/notes/3799117
[n3769130]: https://me.sap.com/notes/3769130
[n3809953]: https://me.sap.com/notes/3809953
[nov]: https://support.sap.com/en/my-support/knowledge-base/security-notes-news/november-2026.html
[patchday]: https://support.sap.com/en/my-support/knowledge-base/security-notes-news.html
[news]: https://securityonline.info/sap-security-patch-day-november-2026/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
