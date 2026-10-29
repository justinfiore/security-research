# Tabularis: MCP SQLite read-only bypass through SQL injection

**Last updated:** 2026-10-29 (America/New_York)

[Main Tabularis summary](../black-october-2026.md#tabularis-mcp-sqlite-read-only-bypass-through-sql-injection) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-118378](https://www.cve.org/CVERecord?id=CVE-2026-118378) — VulnCheck CNA CVSS 4.0 8.5 High (`CVSS:4.0/AV:L/AC:L/AT:N/PR:N/UI:P/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`); the upstream GitHub advisory scores the same issue CVSS 3.1 7.8 High.** Tabularis before 0.28.0 can interpolate an attacker-influenced SQLite table name into a `PRAGMA` query reached from the MCP `describe_table` tool. The injected statement can bypass the product's read-only and write-approval controls.

**CISA KEV:** Not listed (catalog 2026.10.28, checked 2026-10-29). The upstream advisory and CNA record do not report active exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | The reviewed sources do not establish a private-report date. |
| Public advisory and CVE publication | 2026-10-28; time/TZ unknown | CVE-2026-118378 was published by VulnCheck; the upstream GitHub advisory describes the SQLite MCP path. [CVE record][cve] [Upstream advisory][ghsa] |
| Fixed release | 2026-10-28; time/TZ unknown | Tabularis 0.28.0 is the patched release. [Release][release] |

## Detection

1. Inventory Tabularis installations and their exact version through trusted package, release-management, or application inventory. Do not launch an untrusted local binary merely to collect its version.
2. Identify SQLite connections exposed through Tabularis's built-in MCP server, especially where an AI client processes untrusted documents, tickets, repository content, or web data that can influence tool arguments.
3. Treat every Tabularis release before 0.28.0 as affected for the documented SQLite MCP path. The CNA record identifies affected versions from 0.10.0 before 0.28.0; the upstream advisory describes a tested main-branch commit and patched 0.28.0 release. Absence of an MCP client, a SQLite connection, or untrusted input must be established per deployment; otherwise record it as unknown.
4. A configured read-only connection or write-approval setting is not proof that this path is safe: the advisory says the vulnerable `describe_table` path bypasses those controls.

The vendors did not publish compromise indicators. Version and configuration inventory establishes possible exposure only; it cannot prove that a database was not queried, modified, or dropped.

## Remediation

1. Upgrade Tabularis to **0.28.0 or later** from the project's official release channel, then restart or redeploy the MCP service so the running artifact is replaced.
2. Until that is complete, do not make SQLite databases whose contents or integrity matter available through the affected MCP path to clients processing untrusted content. Disable or remove the affected MCP connection where the product supports it rather than relying on its read-only or approval controls.
3. Limit the database identity to the minimum required privileges as defense in depth. This does not replace the update because the advisory demonstrates bypass of the product's own safety boundary.
4. Do not test production systems with crafted table names or stacked SQL. Use vendor-supported updates and ordinary trusted operations instead.

## Verification

- Confirm the running Tabularis artifact is 0.28.0 or later, not merely that an installer was downloaded.
- Confirm intended MCP clients can perform an ordinary trusted schema lookup against a disposable or non-sensitive SQLite database after the update.
- Review configured MCP connections and database permissions to ensure untrusted-content workflows do not retain unnecessary write-capable access.
- Do not use malicious SQL, prompt-injection content, or destructive test tables against production databases as a validation method.

## Compromise response

If an affected SQLite MCP connection processed untrusted content, preserve MCP client/server logs, database backups, audit records, and configuration history before cleanup. Review unexpected schema changes, table drops, modified rows, new databases, and data-access activity within the database identity's scope. Restore integrity from known-good backups where needed and rotate credentials accessible through the affected workflow. Upgrading stops this path but does not establish that prior database operations were benign.

## Sources

- [Tabularis GHSA-xrx3-j98v-67x9][ghsa] — upstream technical description, CVSS 3.1 score, affected/patched releases, and remediation.
- [CVE-2026-118378][cve] — VulnCheck CNA publication, CVSS 4.0 score, affected range, references, and release linkage.
- [Tabularis v0.28.0 release][release] — fixed release.
- [CISA KEV JSON feed][kev] — catalog 2026.10.28 status.

[ghsa]: https://github.com/TabularisDB/tabularis/security/advisories/GHSA-xrx3-j98v-67x9
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-118378
[release]: https://github.com/TabularisDB/tabularis/releases/tag/v0.28.0
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
