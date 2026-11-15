# PostgreSQL: a type change runs code as the database user

**Last updated:** 2026-11-15 (America/New_York)

[Main PostgreSQL summary](../black-october-2026.md#postgresql-a-type-change-runs-code-as-the-database-user) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

PostgreSQL's November 12 updates fix 52 security flaws. The one the project leads with is a type confusion: a database user who can create objects changes a composite type while an older value of that type is still in use, and the server then runs code as the operating system account that runs PostgreSQL.

**The PostgreSQL project rates [CVE-2026-6460](https://www.cve.org/CVERecord?id=CVE-2026-6460) CVSS 3.1 8.8 High.** The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. The project is the CNA. The record says the path is `ALTER ... SET DATA TYPE`, and that other DDL routes exist, including adding a column, rolling back, and adding it again. The attacker needs a login that can create objects. This is not an unauthenticated flaw. Thirty-two of the 52 flaws in the release carry the same 8.8 score, and none is higher. One server flaw needs no login: [CVE-2026-116322](https://www.cve.org/CVERecord?id=CVE-2026-116322) is 5.3 and can restart a PostgreSQL 18 server. The project does not report exploitation of any of them.

The affected lines are every release before **18.7**, **17.12**, **16.16**, **15.20**, and **14.25**. PostgreSQL 14.25 is the final release of PostgreSQL 14, which is now end of life. The release notes say the fix adds version checks on composite values, and that full protection requires rebuilding C-language extensions against the new headers. A new server parameter, `composite_type_mismatch`, can turn those checks off, and the project says doing so carries security risks.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-15) for CVE-2026-6460. The project does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-11-12; time/TZ unknown** | 18.7, 17.12, 16.16, 15.20, 14.25, and PostgreSQL 19 RC 2. Fifty-two security flaws. [Announcement][ann] |
| CVE record | 2026-11-12; time/TZ unknown | CVE-2026-6460, CVSS 3.1 8.8. [Record][cve] |
| CISA KEV | Not listed (catalog 2026.11.13, checked 2026-11-15) | [KEV][kev] |
| **Last updated** | **2026-11-15 (America/New_York)** | New item. Upgrade, and rebuild C extensions. |

## Detection

This only reads.

```sh
psql -c 'SHOW server_version;'
```

A server below the floor for its line is inside the range. A login that cannot create objects is outside the condition the record names for CVE-2026-6460, and it is not outside the other 51 flaws. A managed service such as RDS or Aurora is patched by the provider; this check does not show whether that provider has applied it.

## Remediation

1. Upgrade to **18.7**, **17.12**, **16.16**, **15.20**, or **14.25** on the line you run, and restart the server. A minor upgrade does not need a dump and restore.
2. Rebuild every C-language extension against the new headers. The project says the new checks do not fully protect a server whose extensions were built against the old ones. Do not set `composite_type_mismatch` off to keep an old extension loading.
3. Upgrade the client tools you use for dumps and restores, including `pg_dump` and `pg_restore`. Several of the 52 flaws are in those tools, and a crafted archive can run code as the user who runs them.
4. After the upgrade, reindex a GIN index or a `pg_trgm` GiST index if you suspect it is corrupt, and take a new full backup if you use incremental backups. The release notes say the update fixes corruption bugs in both, and that a corrupt incremental backup stays corrupt.
5. PostgreSQL 14.25 is the last release of that line. Plan a move to a supported major version.
6. The upgrade does not show whether a statement already ran code.

## Verification

- `SHOW server_version;` on the running server is at or above the floor for that line, and the process was restarted after the package install.
- A query that worked before the upgrade still works. Do not run an `ALTER ... SET DATA TYPE` built to trigger the flaw.

## Compromise response

The project does not report exploitation. A database role that can create objects had a path to code execution as the database's operating system user on every unpatched server.

If such a role was held by someone you do not trust, and the server stayed below the floor after 2026-11-12:

- Treat the database host as exposed. The upgrade does not remove a change that role already made.
- Review accounts, authorized keys, and scheduled jobs on that host.
- Rotate credentials the database process could read.

## Sources

- [PostgreSQL 18.7, 17.12, 16.16, 15.20, 14.25, and 19 RC 2][ann] — posted 2026-11-12. Fifty-two security flaws, PostgreSQL 14 end of life, and the post-update steps.
- [CVE-2026-6460][cve] — CVSS 3.1 8.8. Type confusion after `ALTER ... SET DATA TYPE`. Before 18.7, 17.12, 16.16, 15.20, and 14.25.
- [PostgreSQL 18.7 release notes](https://www.postgresql.org/docs/18/release-18-7.html) — the composite-type fix, and the note that C-language extensions must be rebuilt.
- [CISA KEV JSON][kev] — catalog 2026.11.13, checked 2026-11-15. CVE-2026-6460 is not listed.

[ann]: https://www.postgresql.org/about/news/postgresql-187-1712-1616-1520-1425-and-19-rc-2-released-3442/
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-6460
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
