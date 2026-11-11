# MongoDB: a replica set primary runs code before login

**Last updated:** 2026-11-11 (America/New_York)

[Main MongoDB summary](../black-october-2026.md#mongodb-a-replica-set-primary-runs-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**MongoDB rates [CVE-2026-118383](https://www.cve.org/CVERecord?id=CVE-2026-118383) CVSS 4.0 9.5 Critical and CVSS 3.1 9.0 Critical.** The vectors are `CVSS:4.0/AV:N/AC:H/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H` and `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:C/C:H/I:H/A:H`. A use after free in the replication component runs when a newly elected replica set primary finishes catch-up. MongoDB says a request that does not require authentication can cause it, and the server can stop or, under some conditions, run code as the server process. Replica set members are affected, including the shard and config server replica sets of a sharded cluster. A standalone `mongod` is not.

The CVE record, published 2026-11-10 20:23:51 UTC, lists seven affected ranges, each fixed at the upper bound: 9.0.0 before 9.0.7, 8.3.0 before 8.3.16, 8.0.0 before 8.0.37, 7.0.0 before 7.0.48, 6.0.0 before 6.0.30, 5.0.0 before 5.0.35, and 4.4.0 before 4.4.32. The release notes for 9.0, 8.3, 8.0, and 7.0 each say the November 10 patch contains the fix. The 6.0, 5.0, and 4.4 release-note pages did not return their text on this read; those three version numbers also appear on the community downloads page. NVD has not scored it.

MongoDB's community notice the same day says the company found the flaw itself and is not aware of attempts to use it. It says Atlas clusters upgrade during maintenance, and a deferred maintenance window should be applied now.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-11). MongoDB says it is not aware of attempts to use the flaw. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-11-10 20:23:51 UTC** | CVE record published. [Record][cve] |
| Release notes | 2026-11-10; time/TZ unknown | 9.0.7, 8.3.16, 8.0.37, and 7.0.48 each name the CVE. [8.0 notes][rn80] |
| Community notice | 2026-11-10 23:20 UTC | Mark Hoskins, MongoDB Community. CVSS 9.5. Not aware of exploitation. [Notice][forum] |
| CISA KEV | Not listed (catalog 2026.11.10, checked 2026-11-11) | [KEV][kev] |
| **Last updated** | **2026-11-11 (America/New_York)** | New item. |

## Detection

This only reads.

```sh
mongod --version
```

A replica set member, including a shard or a config server, on a version below the floor for its line is affected. A process started with no `--replSet`, and no replica set configuration, is a standalone and is outside this flaw. `rs.status()` from a client you already use shows whether the process is in a set. Do not send a catch-up request to test it.

The 6.0.30, 5.0.35, and 4.4.32 floors are the bounds in the CVE record. This run could not read those three release-note pages, so a build number on those lines should be checked against the record before you treat a slightly older package as fixed.

## Remediation

1. Upgrade every replica set member to the floor for its line or later, then restart it: **9.0.7**, **8.3.16**, **8.0.37**, **7.0.48**, **6.0.30**, **5.0.35**, or **4.4.32**.
2. On Atlas, MongoDB says the upgrade happens during cluster maintenance. If maintenance is deferred, apply it. A self-managed replica set does not get that upgrade.
3. The restart does not show whether the process already ran code.

## Verification

- `mongod --version` on each member is at or above the floor for that line, and the running process is the new binary.
- A client you already use can still read and write. Do not trigger a primary election to test the flaw.

## Compromise response

MongoDB does not publish an indicator. If a replica set member was reachable from an untrusted network while its version was below the floor, treat code execution as the server process as possible.

- Preserve the server log from before the upgrade.
- Review new users, new roles, and files written by the `mongod` user.
- If you find evidence a command ran, rotate credentials that process could read and rebuild the host. The upgrade does not remove that.

## Sources

- [CVE-2026-118383][cve] — MongoDB CNA, published 2026-11-10 20:23:51 UTC. CVSS 4.0 9.5 and CVSS 3.1 9.0. Seven affected ranges. Standalone instances are not affected.
- [MongoDB 8.0 release notes][rn80] — 8.0.37, November 10, 2026, names the CVE. The 9.0.7, 8.3.16, and 7.0.48 notes do the same.
- [MongoDB community notice][forum] — November 10, 2026, 11:20pm. Found internally. Not aware of exploitation. Atlas upgrades during maintenance.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-11. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-118383
[rn80]: https://www.mongodb.com/docs/manual/release-notes/8.0/
[forum]: https://www.mongodb.com/community/forums/t/important-mongodb-security-update-available-action-required-november-10-2026/344843
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
