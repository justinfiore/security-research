# Synchronet: a long terminal name blocks the board

**Last updated:** 2026-11-24 (America/New_York)

[Main plugin summary](../black-october-2026.md#synchronet-a-long-terminal-name-blocks-the-board) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-23 the Spanish National Cybersecurity Institute published [CVE-2026-133646](https://www.cve.org/CVERecord?id=CVE-2026-133646) for Synchronet BBS. INCIBE is the CNA. Its notice page rejected this run's fetch, so the record is the source for the technical detail and the notice URL is kept as the reference INCIBE published.

**INCIBE rates it CVSS 4.0 8.7 High.** The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:H/SC:N/SI:N/SA:N`. There is no CVSS 3 score. The SSH service copies the terminal name the client sends into a 41-byte field and does not stop at the end of that field. A client that is not logged in can send up to 64 bytes. INCIBE says the overflow blocks connection threads, including after the client has disconnected, and that filling the sockets stops new connections until Synchronet is restarted. The record describes a denial of service. It does not say the overflow runs code.

**Synchronet BBS 3.20b through 3.21e is affected, when the SSH service is on.** 3.21e is the current release: Synchronet's news page lists it as released 2026-03-17 for Windows, and lists nothing later. INCIBE's record now says the fix is commit `cb6d77dbca` on the master branch, and that the build to install is **Synchronet v3.22, build B or later**, which it says is scheduled for late 2026, or a **v3.22a build released after 2026-11-19** that includes the commit. The news page lists no such build. Turning the SSH service off removes the path the record describes. That is a workaround, not a fix. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.24, checked 2026-11-24). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Synchronet 3.21e | 2026-03-17; time/TZ unknown | Current Windows release on the project's news page. Still inside the affected range. [News][news] |
| **Public announcement** | **2026-11-23; time/TZ unknown** | INCIBE. CVSS 4.0 8.7. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-133646) |
| **Fix named, not released** | **2026-11-24; time/TZ unknown** | The record now says commit `cb6d77dbca` fixes it, in v3.22 build B, scheduled for late 2026, or a v3.22a build released after 2026-11-19. The news page lists neither. |

## Detection

Read the Synchronet version and whether the SSH service is enabled. **3.20b through 3.21e with SSH on** is inside the range. A board that does not offer SSH is outside the condition the record names. Reading the version changes no state.

## Remediation

1. There is no released build with the fix. INCIBE says the fix is commit `cb6d77dbca` on master, and that the build to install is v3.22 build B or later, scheduled for late 2026, or a v3.22a build released after 2026-11-19. The project's news page still ends at 3.21e. Until one of those builds is what you are running, turn the SSH service off if the board does not need it.
2. Turning it off stops new connections from taking this path. It does not unblock a thread that is already stuck. Restart Synchronet for that.
3. A development build that contains the commit is not the same as a release the project says is fixed. Install the build INCIBE names when it exists.

## Verification

- The SSH service is off, or the installed build is v3.22 build B or later, or a v3.22a build released after 2026-11-19. Neither was listed on the news page on 2026-11-24.
- Do not send an overlong terminal name to test it.

## Compromise response

No source read for this entry reports an incident. The record's result is a board that stops accepting connections. Restarting it restores service. It does not, by itself, show who connected.

## Sources

- [CVE-2026-133646](https://www.cve.org/CVERecord?id=CVE-2026-133646) — INCIBE, published 2026-11-23. CVSS 4.0 8.7. CWE-787. Affected 3.20b to 3.21e with SSH enabled. The record now says commit `cb6d77dbca` fixes it, in v3.22 build B (scheduled for late 2026) or a v3.22a build released after 2026-11-19.
- [INCIBE notice](https://www.incibe.es/en/incibe-cert/notices/aviso/out-bounds-write-synchronet-bbs-synchronet) — the record's reference. The page rejected this run's fetch.
- [Synchronet news][news] — 3.21e released 2026-03-17 for Windows. No 3.22 build is listed, checked 2026-11-24.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.24, released 2026-11-24T17:47:46.199Z, checked 2026-11-24. Not listed.

[news]: https://www.synchro.net/
