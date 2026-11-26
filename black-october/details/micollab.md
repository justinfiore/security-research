# Mitel MiCollab: a conferencing request runs commands before login

**Last updated:** 2026-11-26 (America/New_York)

[Main MiCollab summary](../black-october-2026.md#mitel-micollab-a-conferencing-request-runs-commands-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-16 Mitel published [MISA-2026-0012](https://www.mitel.com/support/security-advisories/mitel-product-security-advisory-misa-2026-0012) for five flaws in the Audio, Web, and Video Conferencing (AWV) component of MiCollab. Mitel is the scoring party. Revision 2.0, dated 2026-11-24, names the five CVEs next to the internal IDs. The scores and the patch are unchanged. The CVE records, published 2026-11-19 by MITRE, repeat Mitel's scores.

[CVE-2026-133323](https://www.cve.org/CVERecord?id=CVE-2026-133323) (MTLVULN-1864) is **CVSS 3.1 10.0 Critical**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:N/I:H/A:H`. Insufficient parameter sanitization lets an unauthenticated attacker run a blind command injection and execute commands in the context of the system. Mitel names integrity and availability. The vector assigns no confidentiality impact.

[CVE-2026-133303](https://www.cve.org/CVERecord?id=CVE-2026-133303) (MTLVULN-1862) is **CVSS 3.1 9.0 Critical**. The vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:C/C:H/I:H/A:H`. An unauthenticated attacker who can use pre-staged malicious content performs an XML injection and executes commands. Mitel says exploiting the five together can significantly amplify their impact. It does not publish a chain.

Three more are Medium, all unauthenticated, all through 10.3 (10.3.0.18):

- [CVE-2026-133311](https://www.cve.org/CVERecord?id=CVE-2026-133311) (MTLVULN-1863) is 5.9. Knowing a system-generated identifier, or using pre-staged content, reads sensitive information. Mitel says it does not give unrestricted access to arbitrary files.
- [CVE-2026-133275](https://www.cve.org/CVERecord?id=CVE-2026-133275) (MTLVULN-1861) is 5.3. Insufficient file-type validation uploads an arbitrary file.
- [CVE-2026-133324](https://www.cve.org/CVERecord?id=CVE-2026-133324) (MTLVULN-1877) is 5.3. Improper handling of authentication bypasses the application's authentication controls.

Affected is **MiCollab 10.3 (10.3.0.18) and earlier**, supported versions only. A host already on 10.3.0.18 is still affected until the patch in [KB000129195](https://mitel.service-now.com/mitel?id=kb_article&sys_id=3e441c0d97285b10cd1b3a871153afc5) is applied, or the host is upgraded to a later release that includes the update. That knowledge-base article needs a Mitel login. Mitel's advisory and CERT Santé, on 2026-11-20, report no exploitation and no public proof of concept. Accenture APEX Labs, in a November 2026 report, says otherwise: one victim had web-shell activity before 23:00 UTC on November 15, the day before the advisory. The first command ran 12 minutes after the first request, root followed within 30 minutes, and the LDAP connector account reached a domain controller within 32 minutes. A second MiCollab server has held an HTTPS channel to the same address, 204.76.203.204, since November 9. Accenture has not shown which flaw that second server used. The shell path it names is `/pictures/*/shell.asp`. Local MiCollab logs were edited, so a clean log is not a clean server.

**CISA KEV:** Listed — all five added 2026-11-25. [CVE-2026-133323](https://www.cve.org/CVERecord?id=CVE-2026-133323), [CVE-2026-133303](https://www.cve.org/CVERecord?id=CVE-2026-133303), [CVE-2026-133275](https://www.cve.org/CVERecord?id=CVE-2026-133275), and [CVE-2026-133324](https://www.cve.org/CVERecord?id=CVE-2026-133324) are due 2026-11-28. [CVE-2026-133311](https://www.cve.org/CVERecord?id=CVE-2026-133311) is due 2026-12-09. The required action includes the vendor's mitigations and CISA's forensic triage. Ransomware use is Unknown for all five. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-16; time/TZ unknown** | MISA-2026-0012 revision 1.0. Internal IDs only. [Advisory][adv] |
| **CVE numbers on the advisory** | **2026-11-24; time/TZ unknown** | Revision 2.0. The five CVE IDs. Scores and the patch are unchanged. |
| CVE records | 2026-11-19; time/TZ unknown | MITRE. Scores match Mitel's table. |
| CERT Santé notice | 2026-11-20; time/TZ unknown | No exploitation and no public proof of concept. [CERT Santé][sante] |
| **Accenture report** | **2026-11; day not stated on the page** | Web shell before 23:00 UTC on 2026-11-15 at one victim. A second server called 204.76.203.204 from 2026-11-09. [Accenture][apex] |
| **CISA KEV** | **2026-11-25; time/TZ unknown** | All five added. Four are due 2026-11-28. CVE-2026-133311 is due 2026-12-09. Forensic triage is required. [KEV][kev] |

## Detection

Read the MiCollab version and whether the KB000129195 patch is installed. A build that reports 10.3.0.18 and has no record of that patch is inside the affected range. The version string alone does not show the patch. Record whether the AWV component is reachable from outside the network. Reading the version changes no state.

## Remediation

1. Upgrade to **MiCollab 10.3 (10.3.0.18)** and apply the patch in **KB000129195**, or upgrade to a later release that includes the security update. The article needs a Mitel login; a partner can apply it.
2. Until that is done, restrict external access to the AWV component, as Mitel describes in the same article.
3. The update does not show whether a command already ran.

## Verification

- The installed build is later than 10.3.0.18, or 10.3.0.18 has the KB000129195 patch recorded.
- External access to AWV is limited to the networks you intend.
- Do not send a command-injection request.

## Compromise response

Mitel and CERT Santé do not report exploitation. Accenture does, for one victim, before the advisory. A server whose AWV component was reachable on an unpatched build should be reviewed for a file under `pictures` named `shell.asp`, for commands nobody ran, and for the LDAP connector account signing in to a domain controller. Look in the proxy or gateway log, not only the MiCollab log. The addresses Accenture names are 204.76.203.204 from November 6 and 204.76.203.216 from November 12. The update does not remove a shell or a directory credential that was already taken. Rotate the LDAP connector password if the account authenticated somewhere it should not have.

## Sources

- [MISA-2026-0012][adv] — Mitel, first issued 2026-11-16, revision 2.0 last updated 2026-11-24. Five AWV flaws. Scores 10.0, 9.0, 5.9, 5.3, and 5.3. Affected: 10.3 (10.3.0.18) and earlier. Revision 2.0 names CVE-2026-133275, CVE-2026-133303, CVE-2026-133311, CVE-2026-133323, and CVE-2026-133324.
- [CVE-2026-133323](https://www.cve.org/CVERecord?id=CVE-2026-133323), [CVE-2026-133303](https://www.cve.org/CVERecord?id=CVE-2026-133303), [CVE-2026-133311](https://www.cve.org/CVERecord?id=CVE-2026-133311), [CVE-2026-133275](https://www.cve.org/CVERecord?id=CVE-2026-133275), [CVE-2026-133324](https://www.cve.org/CVERecord?id=CVE-2026-133324) — MITRE, published 2026-11-19. The scores match Mitel's table.
- [CERT Santé][sante] — 2026-11-20. No known exploitation and no public proof of concept.
- [Accenture APEX Labs][apex] — published November 2026, day not stated. Web shell before 23:00 UTC on 2026-11-15. Indicators 204.76.203.204 and 204.76.203.216, and `/pictures/*/shell.asp`.
- [CISA KEV JSON][kev] — catalog 2026.11.25, released 2026-11-25T19:48:12.4344Z, checked 2026-11-25. All five were added 2026-11-25. CVE-2026-133323, CVE-2026-133303, CVE-2026-133275, and CVE-2026-133324 are due 2026-11-28. CVE-2026-133311 is due 2026-12-09. Ransomware use Unknown.

[adv]: https://www.mitel.com/support/security-advisories/mitel-product-security-advisory-misa-2026-0012
[sante]: https://cyberveille.esante.gouv.fr/alertes/mitel-cve-2026-133323-2026-11-20
[apex]: https://accenture.github.io/cyber-intelligence/micollab-exploitation/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
