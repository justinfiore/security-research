# UnrealIRCd: a label tag runs a server command

**Last updated:** 2026-11-09 (America/New_York)

[Main UnrealIRCd summary](../black-october-2026.md#unrealircd-a-label-tag-runs-a-server-command) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

UnrealIRCd is an IRC server. Its labeled-response module echoes an IRCv3 `label` tag into a reply without escaping it. On a network with two or more linked servers, any user can put a newline in that tag, and the next server treats the rest as a command of its own. The project calls this the most critical issue it has found in 15 years. MITRE scores it High, 8.6, and the vector rates confidentiality and availability None. The project also says it is seeing exploitation attempts.

**The project calls [CVE-2026-114713](https://www.cve.org/CVERecord?id=CVE-2026-114713) critical and publishes no CVSS vector.** MITRE, the CNA, rates it CVSS 3.1 8.6 High. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:N/I:H/A:N`. NVD has not scored it. The project says any ordinary user can KILL, GLINE, and do many more bad things, which is a command with server or IRC operator authority. The attack needs a network of two or more linked servers. A single server is outside that condition. UnrealIRCd 6.0.0 through 6.2.7 are affected. The CVE record's affected line is broader: from 0 before 6.2.7.1. The project says UnrealIRCd 5, end of life since 2023-07-01, is similarly affected, and that 3.2.x and 4 were not checked.

The same 6.2.7.1 release and the same hot-patch fix eight more issues the project does not score and does not assign CVEs:

- A user can decloak another user and reveal that user's IP address. A second leak also reveals an IP address.
- A blacklist recheck can hang the server.
- CHGIDENT from Services, which a normal user can trigger, can crash the server. whowasdb can also crash.
- A counting error can answer every new connection with "This server is full" until a restart.
- Services can set more bans than `set::maxbans`. The fix caps that at twice `set::maxbans`.
- TLS renegotiation can flood the server.

The project says it found the set during an internal audit with the help of AI, and it withholds no proof of concept in the advisory itself: the bug is an unescaped tag.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-09). The project says it is seeing attempts to exploit the flaw. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-07 15:00 UTC** | Bram Matthys posted the advisory. The forum stamp is Sat Nov 07, 2026 3:00 pm, and the board is UTC. 6.2.7.1 and hot-patch `bundle-20261107`. [Advisory][adv] |
| oss-security | 2026-11-08 07:31 UTC | The same advisory, plus the statement that the CVE record is now published. The mail's Date header is Sun, 8 Nov 2026 08:31:08 +0100. [oss-security][oss] |
| CVE record | 2026-11-08; time/TZ unknown | MITRE published CVE-2026-114713. CVSS 3.1 8.6. The record does not mention the other eight issues. [CVE-2026-114713][cve] |
| Exploitation attempts | 2026-11-08 10:59 UTC | The project's X account says it is seeing attempts to exploit the flaw, and tells operators who have not hot-patched or upgraded to do so. The post does not say a network was taken over. [X post][xpost] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-09) | [KEV][kev] |

## Detection

This reads the module version. It does not send a label tag.

On the server shell, UnrealIRCd 6.0.2 and later:

```sh
./unrealircd module-status | grep labeled-response
```

As an IRC operator, `MODULE -all` and search for `labeled-response`. A remote server is `MODULE -all remote.server.name`.

- **`labeled-response 5.0-hot-patch-bundle-20261107`** is the hot-patch. The server is on the fixed code.
- **`6.2.7.1`** is the fixed release. The server was not hot-patched, and it does not need to be.
- **`5.0` with no bundle name** is 6.0.0 through 6.2.7 without the hot-patch.
- **No line** means the module is not loaded, or the command could not read it. Unloaded is not the same as patched. On 6.0.0 and 6.0.1 the shell check does not work; use the IRC command.

A network is inside the critical flaw when it has two or more linked servers and at least one of them is unpatched. One server alone is outside that flaw and not outside the crashes, the decloak, and the hang.

## Remediation

Do the workaround first, then the hot-patch or the upgrade. The project says the workaround is not a substitute for the other eight fixes.

1. As an IRC operator, on a network whose servers are all 6.0.4 or newer:

```text
/SPAMFILTER add -regex T block - Invalid_label ^label=(?![^\r\n;\x20]*\z)
```

This blocks the critical flaw on every linked server. It does not fix the crashes, the decloak, or the hang. It does not apply when any server is older than 6.0.4.

2. On each UnrealIRCd 6.0.0 through 6.2.7 server, from the installation directory:

```sh
./unrealircd hot-patch bundle-20261107
```

The last line should be `Patch installed and server rehashed correctly. All should be good now!` or, on older builds, `Done! All should be good now`. The hot-patch does not restart the server. Windows, and a Unix host where that command fails, go to the upgrade instead. The project points a failed hot-patch at its [FAQ](https://www.unrealircd.org/docs/FAQ).

3. Or upgrade to **6.2.7.1** and restart. On Unix, `./unrealircd upgrade` and then restart. Windows downloads 6.2.7.1 from [unrealircd.org](https://www.unrealircd.org/). The GitHub releases API returned an empty list for this repository on 2026-11-09, so the release to trust is the one the advisory names, from unrealircd.org.

4. UnrealIRCd 5 has no hot-patch. Add `blacklist-module "labeled-response";` on every server and restart. A rehash is not enough. 5 has been end of life since 2023-07-01, and the project says to move to 6. Versions 3.2.x and 4 were not checked.

The hot-patch and the upgrade do not show whether a label already ran a command. They do not remove a K-line, a G-line, or a ban that command set.

## Verification

- `labeled-response` reports `5.0-hot-patch-bundle-20261107` or `6.2.7.1` on every server, including the remote ones.
- A client can still connect, and a labeled-response client that sends a normal label still gets its reply. Do not send a label that contains a newline to test the filter.

## Compromise response

The project does not publish log lines for a successful attempt. A server command that no operator ran is the indicator: KILL, GLINE, or a ban, from the server itself, in a window when no operator was acting.

If any linked server was unpatched after 2026-11-07 15:00 UTC:

- Read the server log for KILL, GLINE, KLINE, and spamfilter changes nobody made.
- Remove bans that have no operator behind them.
- An IP revealed by the decloak flaw is already exposed. The patch does not take it back.

## Sources

- [Forum advisory, topic 9487][adv] — Bram Matthys, posted 2026-11-07 15:00 UTC. Nine issues. 6.2.7.1 and hot-patch `bundle-20261107`. The page read on 2026-11-09 still has only this post. The project said updates would be added here, and none were.
- [oss-security][oss] — the same advisory, 2026-11-08 07:31 UTC, and the note that the CVE record is published.
- [CVE-2026-114713][cve] — MITRE, published 2026-11-08. CVSS 3.1 8.6. Affected from 0 before 6.2.7.1. Confidentiality and availability are None in the vector.
- [Project X post][xpost] — 2026-11-08 10:59 UTC. Seeing attempts to exploit CVE-2026-114713. Does not say a network was taken over.
- [CISA KEV JSON][kev] — catalog 2026.11.06, checked 2026-11-09. CVE-2026-114713 is not listed.

[adv]: https://forums.unrealircd.org/viewtopic.php?t=9487
[oss]: https://www.openwall.com/lists/oss-security/2026/11/08/1
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-114713
[xpost]: https://x.com/Unreal_IRCd/status/2119384419081269433
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
