# Babelfish: a TDS handshake can run code as the database user

**Last updated:** 2026-11-06 (America/New_York)

[Main Babelfish summary](../black-october-2026.md#babelfish-a-tds-handshake-can-run-code-as-the-database-user) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-119923](https://www.cve.org/CVERecord?id=CVE-2026-119923) — Amazon (CNA) CVSS 3.1 9.8 Critical and CVSS 4.0 9.3 Critical.** A heap-based buffer overflow in the TDS prelogin parser of Babelfish for PostgreSQL. Amazon says a remote attacker can send a malformed TDS prelogin packet to the TDS port and run commands as the database process user. No login is required. NVD has not scored it.

The open-source extension is affected in 1.0 through 1.5, 2.1 through 2.15, 3.1 through 3.12, 4.0 through 4.8, and 5.1 through 5.4. Amazon's fix for that extension is 4.10, 5.6, or 6.1, or later. There is no 1.x, 2.x, or 3.x open-source fix on those lines. Aurora PostgreSQL with Babelfish has its own version list, below.

**[CVE-2026-119924](https://www.cve.org/CVERecord?id=CVE-2026-119924)** is the second issue in the same bulletin. Amazon says an authenticated actor can read adjacent process memory or cause a denial of service through TDS remote-procedure-call handling. This entry does not repeat a score for it; the bulletin does not print one. The same upgrades cover it.

Amazon's bulletin is 2026-166-AWS, published 2026-11-06 10:00 AM PST. It does not report exploitation. Restricting the TDS port is the workaround, not the fix.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-06). Amazon does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-06 10:00 AM PST (UTC−08:00)** | AWS bulletin 2026-166-AWS. CVE records the same day. [AWS][aws] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-06) | [KEV][kev] |

## Detection

This only reads.

On Aurora, the cluster's engine version is in the RDS console or in `aws rds describe-db-clusters`. Compare it with the fixed floors in Remediation. A cluster that does not have Babelfish enabled is outside both flaws. AWS does not say the PostgreSQL port is affected; the packet is TDS, default port 1433.

On a self-managed Babelfish build, `SELECT babelfish_version();` inside the database prints the extension version. If that function is absent, Babelfish is not installed. A version inside 1.0–1.5, 2.1–2.15, 3.1–3.12, 4.0–4.8, or 5.1–5.4 is affected. 6.0 before 6.1 is on Amazon's Aurora list and is not in the open-source affected ranges; treat a self-managed 6.0 as unknown rather than clear.

Do not send a malformed prelogin packet to check.

## Remediation

1. **Aurora PostgreSQL with Babelfish:** upgrade the cluster to one of these versions or later, then apply pending maintenance. The Babelfish version is in parentheses. 13.9.16 (1.5.5), 13.23.3 (1.17.2), 14.6.16 (2.3.5), 14.17.8 (2.12.4), 14.18.6 (2.13.3), 14.19.5 (2.14.2), 14.20.5 (2.15.2), 14.22.3 (2.16.1), 14.23.1 (2.17.0), 15.10.8 (3.8.4), 15.12.8 (3.9.4), 15.13.6 (3.10.3), 15.14.5 (3.11.2), 15.15.5 (3.12.2), 15.17.3 (3.13.1), 15.18.1 (3.14.0), 16.8.8 (4.5.5), 16.9.6 (4.6.3), 16.10.5 (4.7.2), 16.11.5 (4.8.2), 16.13.3 (4.9.1), 16.14.1 (4.10.0), 17.4.8 (5.1.4), 17.5.6 (5.2.3), 17.6.5 (5.3.2), 17.7.5 (5.4.2), 17.9.3 (5.5.1), 17.10.1 (5.6.0), 18.3.4 (6.0.2), 18.4.1 (6.1.0).
2. **Self-managed Babelfish for PostgreSQL:** upgrade the extension to 4.10, 5.6, or 6.1, or later. Amazon names no fix on the 1.x, 2.x, or 3.x extension lines.
3. Until the upgrade is applied, restrict TCP 1433 to the hosts that need TDS. Amazon says that is the workaround. It does not fix the parser.
4. The upgrade does not show whether a packet already ran code as the database user.

## Verification

- The Aurora engine version, or `babelfish_version()`, is on the fixed list above.
- A SQL Server client you already use can still connect. Do not send a truncated prelogin packet.

## Compromise response

Amazon does not publish an indicator. If port 1433 was reachable from an untrusted network while the version was affected, treat code execution as the database process user as possible.

- Preserve the database logs from before the upgrade.
- Review new roles, new functions, and files written by the database OS user.
- If you find evidence a command ran, rotate credentials the database process could read and rebuild the host. The upgrade does not remove that.

## Sources

- [AWS bulletin 2026-166-AWS][aws] — published 2026-11-06 10:00 AM PST. Both CVEs, the Aurora version floors, and the open-source extension floors.
- [CVE-2026-119923][cve] — Amazon CNA, published 2026-11-06. CVSS 3.1 9.8 and CVSS 4.0 9.3. Unauthenticated. Commands as the database process user.
- [CISA KEV][kev] — catalog 2026.11.06. Not listed.

[aws]: https://aws.amazon.com/security/security-bulletins/2026-166-aws/
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-119923
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
