# Jumis: the SQL Server administrator password is computed from the server name

**Last updated:** 2026-11-06 (America/New_York)

[Main Jumis summary](../black-october-2026.md#jumis-the-sql-server-administrator-password-is-computed-from-the-server-name) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-59105](https://www.cve.org/CVERecord?id=CVE-2026-59105) — ENISA (CNA) CVSS 3.1 9.8 Critical and CVSS 4.0 9.3 Critical.** The finder, OffSeq, publishes the same CVSS 3.1 9.8. NVD has not scored it. Jumis (formerly Tildes Jumis), a Windows accounting application from Jumis Pro SIA, creates a SQL Server login whose password is computed from the server name and constants in the client. The CNA says that login is a member of `sysadmin`. The vendor's public site does not mention the CVE. OffSeq says the fix shipped in TJ7.0.141.36.

**Worst case:** Anyone who can reach the SQL Server can authenticate as that login and read or change every accounting database on the instance. The CNA says the on-premise server installation enables `xp_cmdshell` during routine operation, so the same login can run operating-system commands on the database host. OffSeq says it confirmed both against a copy it controls, and it is withholding the derivation constants.

**Fixed in TJ7.0.141.36.** OffSeq says the latest build at publication was TJ7.0.142.7. Jumis Finance, the vendor's cloud product, is not the Windows application this record names.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-06). OffSeq does not report exploitation of a customer system. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private report | 2026-06-25; time/TZ unknown | OffSeq reported it to CERT.LV. [OffSeq][offseq] |
| Vendor coordination | 2026-06-29; time/TZ unknown | CERT.LV opened coordination. The vendor confirmed it by 2026-07-30. [OffSeq][offseq] |
| CVE reserved | 2026-08-06; time/TZ unknown | OffSeq's timeline. [OffSeq][offseq] |
| Patch available | By 2026-10-09; time/TZ unknown | OffSeq says the fix ships from TJ7.0.141.36, which it calls the July 2026 release. The day the build was published is not stated. [OffSeq][offseq] |
| **Public announcement** | **2026-11-06; time/TZ unknown** | ENISA published the CVE record. OffSeq's write-up is the same disclosure. [CNA][cve] [OffSeq][offseq] |
| CISA KEV | Not listed (catalog 2026.11.04, checked 2026-11-06) | [KEV][kev] |

## Detection

On the **SQL Server** that holds Jumis databases, as an administrator you already have. This only reads.

```sql
SELECT name, is_disabled, create_date
FROM sys.sql_logins
WHERE name LIKE '%JumisAdmin%';
```

Then, for a login that query returns:

```sql
SELECT r.name
FROM sys.server_role_members m
JOIN sys.server_principals r ON r.principal_id = m.role_principal_id
JOIN sys.server_principals l ON l.principal_id = m.member_principal_id
WHERE l.name LIKE '%JumisAdmin%';
```

The CNA's login name is `##Tilde_JumisAdmin##`. A row in `sysadmin` on a server whose Jumis build is below TJ7.0.141.36 matches the flaw. A row that remains after the upgrade is the limited account OffSeq says the fix leaves behind in legacy databases; confirm it is not in `sysadmin`.

The Windows application version is on the Jumis client, not in this query. OffSeq names Jumis / Tildes Jumis for Windows before TJ7.0.141.36. Jumis Finance is a different product and is not named by the record.

Do not compute the password or try to log in as that account. The finder withheld the constants because copies are still in the field.

## Remediation

1. **Update Jumis to TJ7.0.141.36 or later** on every client and on the server installation. OffSeq says TJ7.0.142.7 was current when it published. The vendor's public pages do not list the build.
2. **Until that build is installed,** restrict the SQL Server so only the hosts that run Jumis can reach it. That is a mitigation, not a fix. The password is computed, so changing it by hand does not survive the application recomputing it.
3. After the upgrade, confirm the login is no longer `sysadmin`. OffSeq says it should hold only a limited public account in legacy databases and no account in new ones.
4. Updating does not undo rows the login already changed, and it does not remove a command `xp_cmdshell` already ran.

## Verification

- Confirm the installed build is **TJ7.0.141.36 or later**, then re-run the role query and confirm the login is not in `sysadmin`.
- Open one company database you already use and confirm the ledger still opens. Do not attempt the derived password.

## Compromise response

OffSeq does not publish an indicator or a confirmed customer compromise. If the SQL port was reachable by anyone other than the Jumis hosts while the build was below TJ7.0.141.36, treat a read of every database on that instance as possible.

- Preserve the SQL Server error log and a backup before cleanup.
- Review `sysadmin` membership, new logins, and jobs you did not create.
- On the on-premise server installation, review the use of `xp_cmdshell`. The CNA says the product enables it during routine operation, so a row there is not by itself proof of abuse.
- If you find evidence the login was used by someone other than Jumis, rotate the remaining SQL credentials, review accounting records for changes you cannot explain, and rebuild the host if a command ran.

## Sources

- [CVE-2026-59105][cve]: ENISA CNA, published 2026-11-06, CVSS 3.1 9.8 and CVSS 4.0 9.3, affected before TJ7.0.141.36, finder OffSeq.
- [OffSeq write-up][offseq]: the same scores, the July 2026 fix build, CERT.LV coordination, and the statement that the derivation constants are withheld.
- [Jumis Pro][vendor]: the vendor's product site. It does not mention this CVE.
- [CISA KEV JSON feed][kev]: catalog 2026.11.04. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-59105
[offseq]: https://offseq.com/en/research/jumis-cve-2026-59105/
[vendor]: https://www.mansjumis.lv/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
