# Progress MarkLogic Server: 31 flaws including low-privilege paths to administrator

**Last updated:** 2026-10-26 (America/New_York)

[Main MarkLogic summary](../black-october-2026.md#progress-marklogic-server-31-flaws-including-low-privilege-paths-to-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Five Critical flaws, rated by Progress (CNA) under CVSS 3.1. NVD has added no scores of its own; all records are "Awaiting Analysis".** Progress's October 2026 bulletin covers **31 CVEs** in self-managed MarkLogic Server 11.0–11.3.6 and 12.0–12.0.3. By the CNA scores on the CVE records, 5 are Critical, 24 High and 2 Medium. The fixes are **MarkLogic Server 11.3.7** (11.3 LTS line) and **12.1.0** (12 "innovation" line; there is no fixed 12.0.x). Both were released on 2026-09-10, a month before disclosure. [Progress bulletin][bulletin] [11.x release notes][rn11] [12.x release notes][rn12]

| CVE | Progress CVSS 3.1 | What an attacker needs | Worst case |
|---|---|---|---|
| [CVE-2026-85947](https://www.cve.org/CVERecord?id=CVE-2026-85947) | 9.9 Critical (AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H) | Forest-management privileges | Creates a persistent, unauthorized **administrator account** |
| [CVE-2026-85948](https://www.cve.org/CVERecord?id=CVE-2026-85948) | 9.9 Critical (same vector) | `manage-user`-level privileges | XQuery injection in a **deprecated Management API** package path; persistent administrative control |
| [CVE-2026-85955](https://www.cve.org/CVERecord?id=CVE-2026-85955) | 9.9 Critical (same vector) | Query-execution access | Calls an XQuery evaluation function (`xdmp:eval-in`, per the CVE title) without the required eval privilege; **server-side code execution with elevated permissions** |
| [CVE-2026-85956](https://www.cve.org/CVERecord?id=CVE-2026-85956) | 9.6 Critical (AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:N) | Delegated database-administrator privileges | Backup or restore of forests **outside the authorized database scope**; access to or changes in security-critical data |
| [CVE-2026-9191](https://www.cve.org/CVERecord?id=CVE-2026-9191) | 9.6 Critical (AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:H) | Ability to run code through an affected REST or XDBC evaluation path; vector says no privileges, user interaction required | Insufficient isolation from HTTP request, response and session state; unauthorized actions or **hijack of an authenticated session** |

The remaining **26 CVEs ([CVE-2026-85949](https://www.cve.org/CVERecord?id=CVE-2026-85949) to [CVE-2026-85954](https://www.cve.org/CVERecord?id=CVE-2026-85954) and [CVE-2026-85957](https://www.cve.org/CVERecord?id=CVE-2026-85957) to [CVE-2026-85976](https://www.cve.org/CVERecord?id=CVE-2026-85976))** are listed with descriptions in the [Progress bulletin][bulletin]. They include two that the bulletin describes as reachable by **unauthenticated** attackers in specific configurations: SAML assertion acceptance ([CVE-2026-85962](https://www.cve.org/CVERecord?id=CVE-2026-85962), 7.5 High) and deprecated OpsDirector functionality ([CVE-2026-85963](https://www.cve.org/CVERecord?id=CVE-2026-85963), 7.5 High). Two others limit detection: successful logins are not consistently audited ([CVE-2026-85959](https://www.cve.org/CVERecord?id=CVE-2026-85959)), and log files get overly permissive OS permissions ([CVE-2026-85971](https://www.cve.org/CVERecord?id=CVE-2026-85971)). [Progress bulletin][bulletin]

**Scope:** Retired releases (10.x and earlier) "were not included in the complete assessment and do not receive fixes". **MarkLogic Server on Progress Data Cloud** has been patched by Progress. Most Critical flaws need an authenticated account with some delegated privilege, so the realistic threat is a low-privileged or compromised account becoming a cluster administrator. [Progress bulletin][bulletin]

**Exploitation:** Not reported by Progress. CISA's ADP SSVC enrichment on the records marks Exploitation "none". [CVE records][cve47]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26): none of the five Critical CVEs or the other 26 appear in the feed. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory](#inventory)
  - [Account and log review (read-only)](#account-and-log-review-read-only)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Several records credit researchers "via Bugcrowd" (rexnets; WaltWhitehat for CVE-2026-9191). Dates not established. [CVE records][cve9191] |
| CVE-2026-9191 reserved | 2026-05-21 15:15:54 UTC | CNA metadata. [CVE record][cve9191] |
| Fixed releases 11.3.7 and 12.1.0 | 2026-09-10; time/TZ unknown | "Released: September 10, 2026" in both release-note pages; 11.3.7 is described as a "patch and security update". [11.x][rn11] [12.x][rn12] |
| Other CVE IDs reserved | 2026-09-04 18:42 UTC | CVE-2026-85947 through -85976. [CVE record][cve47] |
| Progress bulletin (public announcement) | 2026-10-12; time/TZ unknown | Article 000306510, "Last Modified 10/12/2026 2:30 PM" (timezone not stated). [Progress bulletin][bulletin] |
| CVE records published | 2026-10-12 15:32:46 – 16:56:54 UTC | First: CVE-2026-9191; the five Critical records by 16:00:29 UTC. [CVE records][cve9191] |
| NVD publication | 2026-10-12 ~16:17 UTC | Awaiting Analysis; CNA scores only. [NVD][nvd47] |
| Progress Data Cloud patched | Unknown; on or before 2026-10-12 | Stated without a date. [Progress bulletin][bulletin] |
| CISA KEV | Not listed (catalog 2026.10.23) | Checked 2026-10-26. [KEV][kev] |

## Detection

### Inventory

1. List every self-managed MarkLogic node: production, DR replicas, dev/test, containers and AWS/Azure marketplace deployments. Affected: **11.0–11.3.6** and **12.0–12.0.3**. Retired 10.x and 9.x are unassessed and unfixed, so treat them as affected. [Progress bulletin][bulletin]
2. Read the version from each node. The commands below are **read-only** and were not exercised against a real MarkLogic installation. Replace the placeholders `HOST` and `ADMIN_USER`.

```sh
# On a Linux node, any user (RPM installs; the package is normally named MarkLogic):
rpm -q MarkLogic

# From an administrator workstation, against your own cluster only (HTTP GET, prompts for the password):
curl --anyauth --user ADMIN_USER "https://HOST:8002/manage/v2?format=json"
```

In Query Console, `xdmp:version()` returns the running server version. Also inventory **mlcp** clients: Progress says older mlcp clients must be upgraded to the version matching 12.1 or 11.3.7. [Progress bulletin][bulletin]

3. **Reachability and privilege:** Identify who holds forest-management, `manage-user`, delegated database-administrator or query/eval rights, plus REST/XDBC app servers that evaluate user-supplied code. Check whether SAML authentication, OpsDirector or legacy InfoStudio modules are in use, and whether the Admin (8001), Query Console (8000) and Manage (8002) ports are reachable beyond administrators.

### Account and log review (read-only)

Progress publishes **no IOCs** and warns that "not every vulnerability produces reliable log evidence". [Progress bulletin][bulletin]

- Enumerate users and roles, read-only, with `curl --anyauth --user ADMIN_USER "https://HOST:8002/manage/v2/users?format=json"`, the Admin UI (**Security → Users / Roles**), or both. Compare against your approved administrator list, and look for unknown accounts holding `admin` or `security`.
- On Linux, logs are under `/var/opt/MarkLogic/Logs` by default (`ErrorLog.txt`, `AuditLog.txt` if auditing is enabled, and per-port access logs). Verify the path for your install. Work on copies where possible. Review them for user or role creation, unexpected backup or restore jobs, eval or Management API calls from unusual accounts, and unexpected outbound connections.
- Because of CVE-2026-85959 and CVE-2026-85971, missing login records or clean logs do **not** prove the absence of misuse, and an attacker with local access may have altered logs.

## Remediation

1. **Upgrade** 11.x to **11.3.7** and 12.x to **12.1.0** from the Progress Downloads Center. Retired 9.x/10.x must move to 11.3.7 or 12.1. No fixed 12.0.x exists. [Progress bulletin][bulletin]
2. **Read the incompatibility notes before upgrading.** Progress says the fixes change legacy APIs, privilege requirements, authentication validation, logging, XML parsing and transport behavior. Code that runs through REST/XDBC eval is now isolated from HTTP request, response and session state (CVE-2026-9191). Test applications first. [11.x incompatibilities][inc11] [12.x incompatibilities][inc12]
3. Upgrade **mlcp** to the matching version. On custom RPM-based Linux installs, make sure `curl` is installed so the shipped cloud-metadata protection works. [Progress bulletin][bulletin]
4. **Until upgraded:** reduce the number of accounts holding forest-management, `manage-user`, delegated-DBA and eval privileges. Restrict ports 8000–8002 and REST/XDBC app servers to administrator networks. Disable unused SAML, OpsDirector and InfoStudio components. These steps reduce exposure but do not fix the flaws.
5. Take a backup and follow the documented rolling-upgrade procedure for clusters. Progress Data Cloud customers need no action. [Progress bulletin][bulletin]

## Verification

- Confirm every node, including DR replicas and containers, reports 11.3.7 or 12.1.0 or later (`xdmp:version()` or the Management API).
- Confirm mlcp versions match.
- Run your application's normal regression tests against the upgraded cluster, particularly anything using legacy Management API paths, eval or SAML. Do not send injection or privilege-escalation payloads.
- Re-check newly created and rotated log-file permissions. Progress notes that existing logs keep their old permissions until remediated (CVE-2026-85971). [Progress bulletin][bulletin]

## Compromise response

- If unknown administrator accounts, unexpected role grants, or out-of-scope backup or restore activity appear, treat the cluster and its data as compromised. Preserve logs and configuration first.
- Remove unauthorized accounts and roles. Rotate passwords, certificates, API keys and external-security (LDAP/Kerberos/SAML) secrets known to the server, plus cloud credentials or tokens reachable through the SSRF flaws ([CVE-2026-85951](https://www.cve.org/CVERecord?id=CVE-2026-85951) on Azure; [CVE-2026-85952](https://www.cve.org/CVERecord?id=CVE-2026-85952) on Linux cloud deployments).
- Review data integrity, including security-database changes and restored forests, and rebuild from a known-good backup if needed.
- Open a Progress Technical Support case.

## Sources

- [Progress MarkLogic Critical Security Alert Bulletin – October 2026][bulletin] (article 000306510): affected and fixed versions, all 31 descriptions, Data Cloud status, mlcp and curl notes.
- [MarkLogic 11 release notes][rn11] and [MarkLogic 12 release notes][rn12]: 2026-09-10 release dates.
- CVE records (Progress CNA): [CVE-2026-85947][cve47], [CVE-2026-85948](https://cveawg.mitre.org/api/cve/CVE-2026-85948), [CVE-2026-85955](https://cveawg.mitre.org/api/cve/CVE-2026-85955), [CVE-2026-85956](https://cveawg.mitre.org/api/cve/CVE-2026-85956), [CVE-2026-9191][cve9191]; [NVD][nvd47]; [CISA KEV feed][kev].
- Secondary: [The Hacker News][thn] (reports fixes available since 2026-09-10, consistent with the release notes).

[bulletin]: https://community.progress.com/s/article/Marklogic-Critical-Security-Alert-Bulletin-October-2026
[rn11]: https://docs.progress.com/bundle/marklogic-server-whats-new-11/page/topics/release-notes.html
[rn12]: https://docs.progress.com/bundle/marklogic-server-whats-new-12/page/topics/release-notes.html
[inc11]: https://docs.progress.com/bundle/marklogic-server-whats-new-11/page/topics/known-incompatibilities-with-previous-releases.html
[inc12]: https://docs.progress.com/bundle/marklogic-server-whats-new-12/page/topics/known-incompatibilities-with-previous-versions.html
[cve47]: https://cveawg.mitre.org/api/cve/CVE-2026-85947
[cve9191]: https://cveawg.mitre.org/api/cve/CVE-2026-9191
[nvd47]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-85947
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[thn]: https://thehackernews.com/2026/10/two-critical-marklogic-flaws-could-give.html
