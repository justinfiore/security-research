# vSRM: a request runs SQL before login

**Last updated:** 2026-11-24 (America/New_York)

[Main plugin summary](../black-october-2026.md#vsrm-a-request-runs-sql-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-24 Turkey's Cyber Security Directorate published notice TR-26-1600 for vSRM, the supplier-relationship product from ITG Bilgisayar Teknolojileri. TR-CERT is the CNA. The notice names seven CVEs and says to upgrade to **v14.08.5 or later**.

**TR-CERT rates [CVE-2026-119582](https://www.cve.org/CVERecord?id=CVE-2026-119582) CVSS 3.1 9.8 Critical and [CVE-2026-117593](https://www.cve.org/CVERecord?id=CVE-2026-117593) CVSS 3.1 9.1 Critical.** The 9.8 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`: SQL injection, and the score says no login. The 9.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`: the password-recovery path lets someone set a password. A third, [CVE-2026-119543](https://www.cve.org/CVERecord?id=CVE-2026-119543), is CVSS 3.1 8.8 High: an identifier in the request reaches a function the caller's permissions should not. All three affect **v14.08.3 before v14.08.5**.

Four more are below High and share the same floor. [CVE-2026-96438](https://www.cve.org/CVERecord?id=CVE-2026-96438) is 6.5, an upload whose extension check a trailing dot gets past, from v14.08.1. [CVE-2026-97198](https://www.cve.org/CVERecord?id=CVE-2026-97198) is 6.5 and needs a login. [CVE-2026-94365](https://www.cve.org/CVERecord?id=CVE-2026-94365) is 5.4, from v14.08.1. [CVE-2026-103756](https://www.cve.org/CVERecord?id=CVE-2026-103756) is 5.4 and needs a login. The records do not say the upload runs code. None of the seven reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.24, checked 2026-11-24) for any of the seven. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-24; time/TZ unknown** | TR-26-1600. Seven CVEs. Upgrade to v14.08.5 or later. [Notice][tr] |
| **Last updated** | **2026-11-24 (America/New_York)** | New item. Upgrade, then reset passwords. |

## Detection

Read the installed vSRM version. **v14.08.3 before v14.08.5** is inside the Critical and High flaws. **v14.08.1 and v14.08.2** are inside the two Medium flaws that start at v14.08.1, and outside the three that start at v14.08.3. v14.08.5 or later is the floor the notice names. Reading the version changes no state.

## Remediation

1. Upgrade to **v14.08.5 or later**. The notice gives no other fix.
2. The upgrade does not reset a password the recovery flaw already changed, and it does not undo a row the SQL flaw already wrote. Reset local passwords after the upgrade.

## Verification

- The installed build is v14.08.5 or later.
- Do not send a SQL statement or a password-recovery request to test it.

## Compromise response

A vSRM below v14.08.5 may already have had its database read or a password reset. Review accounts created or changed on or before 2026-11-24, and database activity you can still see, then reset passwords. The upgrade does not show whether either happened. No source read for this entry reports an incident.

## Sources

- [TR-26-1600][tr] — Turkey's Cyber Security Directorate, 2026-11-24. Names the seven CVEs. Recommends v14.08.5 or later.
- [CVE-2026-119582](https://www.cve.org/CVERecord?id=CVE-2026-119582) — TR-CERT, published 2026-11-24. CVSS 3.1 9.8. SQL injection. v14.08.3 before v14.08.5.
- [CVE-2026-117593](https://www.cve.org/CVERecord?id=CVE-2026-117593) — TR-CERT, published 2026-11-24. CVSS 3.1 9.1. Weak password recovery. Same range.
- [CVE-2026-119543](https://www.cve.org/CVERecord?id=CVE-2026-119543) — TR-CERT, published 2026-11-24. CVSS 3.1 8.8. Same range.
- [CVE-2026-96438](https://www.cve.org/CVERecord?id=CVE-2026-96438), [CVE-2026-97198](https://www.cve.org/CVERecord?id=CVE-2026-97198), [CVE-2026-94365](https://www.cve.org/CVERecord?id=CVE-2026-94365), [CVE-2026-103756](https://www.cve.org/CVERecord?id=CVE-2026-103756) — TR-CERT, published 2026-11-24. 6.5, 6.5, 5.4, and 5.4. Fixed in the same release.
- [CISA KEV JSON][kev] — catalog 2026.11.24, released 2026-11-24T17:47:46.199Z, checked 2026-11-24. None of the seven is listed.

[tr]: https://siberguvenlik.gov.tr/guvenlik-bildirimleri/detay/tr-26-1600
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
