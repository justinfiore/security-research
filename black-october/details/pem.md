# Postgres Enterprise Manager: an agent reads the server, and a user becomes superuser

**Last updated:** 2026-11-22 (America/New_York)

[Main PEM summary](../black-october-2026.md#postgres-enterprise-manager-an-agent-reads-the-server-and-a-user-becomes-superuser) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-19 EnterpriseDB published three advisories for Postgres Enterprise Manager. Each is **CVSS 4.0 9.4 Critical**, scored by EnterpriseDB, the CNA. The records were published on 2026-11-20. kta1kri reported all three through the EDB Vulnerability Disclosure Program. EDB does not report exploitation.

[CVE-2026-132658](https://www.cve.org/CVERecord?id=CVE-2026-132658) is CWE-269. The `pem_agent` role, which every PEM agent login inherits, is a member of PostgreSQL's `pg_read_server_files` and `pg_write_server_files` on the PEM backend database. Someone who controls any monitored host, and so its PEM agent certificate, reads and writes files on the PEM server host as the `postgres` operating system user. That includes the PEM certificate authority key, which lets them issue certificates for other agents and act as them. PEM **10.5.0 and later, before 10.6.1**, is affected.

[CVE-2026-132659](https://www.cve.org/CVERecord?id=CVE-2026-132659) is CWE-863. The row-level security policies on `pem.job` and `pem.jobstep` do not limit an agent to its own jobs. Someone who controls one monitored host creates, changes, or deletes jobs for every other agent, including the agent on the PEM server. Agents run SQL job steps with the database credentials of the server they monitor, and shell job steps where batch jobs are enabled. Compromising one monitored host can give superuser SQL access to every monitored database and to the PEM backend. PEM **7.3.0 and later, before 10.6.1**, is affected.

[CVE-2026-132660](https://www.cve.org/CVERecord?id=CVE-2026-132660) is CWE-426. Several `SECURITY DEFINER` functions in the `pem` schema are owned by a superuser and do not set a safe `search_path`. Any PEM user who can connect to the PEM backend database creates objects those functions use in place of the intended ones, and runs arbitrary SQL with superuser privileges. Temporary objects work on every supported PostgreSQL version. Objects in the `public` schema work on PostgreSQL 14 backends and on backends upgraded from PostgreSQL 14. PEM **7.6.0 and later, before 10.6.1**, is affected.

PEM 9.8 is end of life and will not receive a fix. PEM 9.x has to move to 10.6.1 or later.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-22) for any of the three. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-19; time/TZ unknown** | EDB published the three advisories. Each says "Original Copy Published" on that date. [658][c658] |
| CVE records published | 2026-11-20; time/TZ unknown | EnterpriseDB is the CNA. Each record repeats the 9.4 score. [CVE-2026-132658](https://www.cve.org/CVERecord?id=CVE-2026-132658) |

## Detection

Read the PEM version on the PEM server. **10.6.1 and later** is outside all three. **10.5.0 through 10.6.0** is inside all three. **7.6.0 through 10.4** is inside the job flaw and the search-path flaw. **7.3.0 through 7.5** is inside the job flaw only. PEM 9.8 and the rest of PEM 9.x get no fix.

The file flaw needs a monitored host the attacker already controls. The job flaw needs the same. The search-path flaw needs a PEM user who can connect to the PEM backend database. Reading the version changes no state.

## Remediation

1. Upgrade to **PEM 10.6.1 or later**. From that version, agents no longer hold the file roles, agents can no longer create jobs or change job definitions or job steps, and the functions run with a fixed `search_path`.
2. PEM 9.8 is end of life. PEM 9.x users upgrade to 10.6.1 or later. There is no 9.x fix.
3. Until the upgrade, protect the PEM agent certificate and key on every monitored host, and limit root access on those hosts to trusted administrators. Keep batch (shell) job steps disabled on agents that do not need them. Limit which hosts can connect to the PEM backend database in `pg_hba.conf`.
4. `REVOKE CREATE ON SCHEMA public FROM PUBLIC` in the PEM backend database closes the public-schema path of the search-path flaw. It does not close the temporary-object path, and EDB says it does not replace upgrading.

## Verification

- The PEM server reports **10.6.1 or later**.
- Do not test by reading a file through an agent, by creating a job for another agent, or by planting an object in the search path.

## Compromise response

EDB does not report exploitation. Upgrading removes the file access and does not undo earlier use of it. If a monitored host may have been compromised, reissue the PEM certificate authority and every PEM agent certificate after upgrading. Review jobs you did not create, and review what those jobs ran, on every monitored database and on the PEM backend. A superuser statement that already ran is not undone by the upgrade.

## Sources

- [CVE-2026-132658 advisory][c658] — EDB, first published 2026-11-19. CVSS 4.0 9.4 Critical, `CVSS:4.0/AV:N/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`. PEM 10.5.0 and later before 10.6.1. CWE-269.
- [CVE-2026-132659 advisory][c659] — EDB, first published 2026-11-19. CVSS 4.0 9.4 Critical, same vector. PEM 7.3.0 and later before 10.6.1. PEM 9.8 will not be fixed. CWE-863.
- [CVE-2026-132660 advisory][c660] — EDB, first published 2026-11-19. CVSS 4.0 9.4 Critical, `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`. PEM 7.6.0 and later before 10.6.1. PEM 9.8 will not be fixed. CWE-426.
- [CVE-2026-132658](https://www.cve.org/CVERecord?id=CVE-2026-132658), [CVE-2026-132659](https://www.cve.org/CVERecord?id=CVE-2026-132659), [CVE-2026-132660](https://www.cve.org/CVERecord?id=CVE-2026-132660) — published 2026-11-20. EnterpriseDB is the CNA and repeats each 9.4 score.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-22. None of the three is listed.

[c658]: https://www.enterprisedb.com/docs/security/advisories/cve2026132658/
[c659]: https://www.enterprisedb.com/docs/security/advisories/cve2026132659/
[c660]: https://www.enterprisedb.com/docs/security/advisories/cve2026132660/
