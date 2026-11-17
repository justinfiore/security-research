# ooRexx: a local user talks to RXAPI and injects a macro

**Last updated:** 2026-11-17 (America/New_York)

[Main ooRexx summary](../black-october-2026.md#oorexx-a-local-user-injects-a-macro) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

MITRE rates three flaws in Open Object Rexx (ooRexx) **4.0.0 before 5.2.0**. All three are in RXAPI, the process other REXX programs talk to. MITRE is the CNA.

- [CVE-2026-130327](https://www.cve.org/CVERecord?id=CVE-2026-130327), **CVSS 3.1 9.3 Critical**, vector `CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`. Unless `XDG_RUNTIME_DIR` is set, RXAPI uses a world-writable file in `/tmp`, or TCP port 10010 on localhost. Any local user can send it a message, including a macro that a REXX script then runs. The record lists Windows and macOS as platforms.
- [CVE-2026-130320](https://www.cve.org/CVERecord?id=CVE-2026-130320), **CVSS 3.1 9.3 Critical**, the same vector. RXAPI does not check the bounds of `nameArg` and `userid`, and MITRE says a crafted message can run code.
- [CVE-2026-130290](https://www.cve.org/CVERecord?id=CVE-2026-130290), **CVSS 3.1 7.9 High**, vector `CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:C/C:H/I:N/A:L`. `DataQueue::add` trusts the size the client sends. A large `parameter1` in an `ADD_TO_SESSION_QUEUE` or `ADD_TO_NAMED_QUEUE` message, followed by `PULL_FROM_SESSION_QUEUE`, reads past the buffer. A very large value crashes the process.

All three need a local user. None is reachable from the network by the description in the record. NVD had not scored them on November 17. The records name **5.2.0** as the first fixed version and point at SVN commit [r12916](https://sourceforge.net/p/oorexx/code-0/12916/), whose message says it is the Unix fix for bugs 1981, 1982, and 1983. The project's site lists **5.2.0 (GA)** as a current release, with installers in the `5.2.0` file directory, and lists 5.3.0 only as a beta. An earlier reading of the recent-uploads feed missed 5.2.0 because that directory is not a new upload. The bug tracker needs a SourceForge login, so this run could not read the bug pages.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-17) for any of the three. MITRE does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-16; time unknown** | MITRE published all three CVE records. |
| Fix commit | date not established | SVN r12916, "Unix fixes for rxapi issues." The log page did not show a date. [r12916][r12916] |
| Beta builds uploaded | 2026-11-16 14:39 to 14:45 UT | SourceForge files feed. `oorexx-5.3.0-13532` portable builds. The feed does not say these contain r12916. |
| **Last updated** | **2026-11-17 (America/New_York)** | 5.2.0 is the current GA release. An earlier note that no stable download existed was wrong. |

## Detection

1. `rexx -v`, or the package version, names the install. **4.0.0 before 5.2.0** is the range the records call affected. A build that reports **5.2.0 or later** is what the records call fixed. The 5.3.0 beta uploads are not that statement.
2. On Unix, a world-writable file under `/tmp` that RXAPI uses, or a listener on TCP port 10010 bound to localhost, matches the condition CVE-2026-130327 describes. Setting `XDG_RUNTIME_DIR` is the condition the record says avoids the `/tmp` file. Neither check shows whether a local user already sent a message.
3. A host with no local accounts other than the one that runs REXX is outside the attack the records describe. A host with several local users is not.

## Remediation

1. Install **ooRexx 5.2.0 or later** from the project's downloads page. 5.2.0 is the current GA release. The 5.3.0 beta is not required.
2. Until then, the record for CVE-2026-130327 says setting `XDG_RUNTIME_DIR` avoids the world-writable `/tmp` file. That does not address the two bounds flaws, and it does not close port 10010.
3. Keep untrusted local users off a host that runs RXAPI. The records describe a local attacker, not a remote one.
4. The upgrade does not show whether a macro was already injected.

## Verification

- `rexx -v` reports 5.2.0 or later, from a release you can name, not only a beta build number.
- Do not send a crafted RXAPI message to test the bounds check.

## Compromise response

MITRE publishes no indicator and does not report exploitation. On a multi-user host that ran an affected build, review REXX macros and scripts for one the owner did not write. The upgrade does not remove one.

## Sources

- [CVE-2026-130327](https://www.cve.org/CVERecord?id=CVE-2026-130327) — MITRE, published 2026-11-16. CVSS 3.1 9.3. World-writable `/tmp` file or localhost port 10010. Affected 4.0.0 before 5.2.0. Platforms Windows and macOS.
- [CVE-2026-130320](https://www.cve.org/CVERecord?id=CVE-2026-130320) — MITRE, published 2026-11-16. CVSS 3.1 9.3. Bounds on `nameArg` and `userid`. Same range.
- [CVE-2026-130290](https://www.cve.org/CVERecord?id=CVE-2026-130290) — MITRE, published 2026-11-16. CVSS 3.1 7.9. Heap over-read in `DataQueue::add`. Same range.
- [SVN r12916][r12916] — "Unix fixes for rxapi issues," bugs 1981, 1982, and 1983. Read 2026-11-17. The page did not show a commit date.
- [ooRexx home](https://www.oorexx.org/) — read 2026-11-17. "Open Object Rexx version 5.2.0 (GA) is now available." 5.3.0 is announced as beta.
- [ooRexx downloads](https://www.oorexx.org/downloads.rsp) — read 2026-11-17. Current releases include Release 5.2.0, with installers, and Release 5.3.0(beta).
- [SourceForge files feed](https://sourceforge.net/projects/oorexx/rss?path=/oorexx) — read 2026-11-17. New files that day were 5.3.0 beta builds. The feed lists new uploads, not the 5.2.0 directory.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, checked 2026-11-17. None of the three is listed.

[r12916]: https://sourceforge.net/p/oorexx/code-0/12916/
