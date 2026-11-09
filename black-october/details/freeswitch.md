# FreeSWITCH: a SIP MESSAGE runs an API command

**Last updated:** 2026-11-09 (America/New_York)

[Back to FreeSWITCH summary](../black-october-2026.md#freeswitch-a-sip-message-runs-an-api-command) · [Changelog](../../CHANGELOG.md)

FreeSWITCH is an open-source telephony switch. **GitHub, the CNA, rates [CVE-2026-116779](https://www.cve.org/CVERecord?id=CVE-2026-116779) CVSS 3.1 9.8 Critical** (`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`). Before 1.11.3, the handler for an inbound SIP MESSAGE splits the user part of the To header on a plus sign and treats the left side as a chat protocol name. Choosing `api` reaches `switch_api_execute()`, so the message runs a FreeSWITCH API command as the daemon, including commands that run an operating-system command. The project says exploitation has been observed. Chat handling is on unless a profile sets `enable-chat=false`, and the stock configuration leaves it on for the internal and external profiles.

**CISA KEV:** Listed — added 2026-11-09, federal due date 2026-11-12. Ransomware use Unknown. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| FreeSWITCH 1.11.3 | 2026-08-28 22:27 UTC | Adds `enable-chat-api-proto`, off unless a profile sets it. The notes call it a critical security fix and do not name the CVE. |
| **Public advisory** | **2026-10-28; time/TZ unknown** | [GHSA-mg63-h38w-8p9p][ghsa]. Exploitation observed. Fixed in 1.11.3. |
| CVE record | 2026-11-05; time/TZ unknown | GitHub, CVSS 3.1 9.8. Affected before 1.11.3. |
| **CISA KEV** | **2026-11-09** | Catalog 2026.11.09, released 16:16:16 UTC. Due 2026-11-12. |
| **Last updated** | **2026-11-09 (America/New_York)** | New item. Upgrade FreeSWITCH. |

## Detection

All of the following put a profile in scope. A profile that fails the first one is outside this flaw.

1. **The running build is older than 1.11.3.** `freeswitch -version` prints the version. A package build can carry a distribution revision; compare it to the upstream tag only when the package notes name this CVE. The 1.11.3 release is the fix the project names.
2. **The profile accepts inbound SIP MESSAGE.** That is the default. `enable-chat=false` on a profile takes that profile out. The stock internal and external profiles do not set it.
3. **One MESSAGE can be accepted.** From 1.10.7, MESSAGE authentication is on by default, and one registered account is enough: an extension, a handset, or a trunk. The stock directory ships `<user id="default">` with no password and no `a1-hash`. A user with neither authenticates unless `allow-empty-password` is false for it. The advisory says the inbound ACL does not cover MESSAGE, so tightening the ACL does not remove the profile.

`disable_system_api_commands=true` removes the `system` API and leaves every other API, including module loading and call origination. It is not a sign the profile is safe.

## Remediation

1. **Upgrade to 1.11.3 or later and restart FreeSWITCH.** The release drops Debian 11 Bullseye from its own builds. A distribution package is the fix only when its notes name this flaw; do not treat an older package version as fixed because the number is below 1.11.3.
2. **Until the upgrade, set `enable-chat=false` on every profile that does not need inbound SIP chat and reload that profile.** That stops the message before the protocol name is read. It also stops legitimate inbound MESSAGE on that profile.
3. **Remove every directory user that has no password and no `a1-hash`.** The stock directory ships `default` and the Skinny example. Together with MESSAGE authentication, which is already the default from 1.10.7, that limits the path to an account you issued. It does not close it.
4. **Leave `enable-chat-api-proto` unset.** The 1.11.3 parameter is off unless a profile sets it. Setting it reopens the path on that profile.
5. The upgrade does not show whether a command already ran, and it does not remove an account or a dialplan change a command made.

## Verification

- `freeswitch -version` reports **1.11.3 or later**, and the process was restarted after the upgrade. A new binary on disk with the old process still running is not the fix.
- No profile that still accepts chat sets `enable-chat-api-proto=true` unless you meant to allow API commands from a MESSAGE.
- The directory has no user with an empty password. `default` and the Skinny example are the two the advisory names.
- On a profile you have not upgraded, `enable-chat=false` is present and the profile was reloaded.

## Compromise response

- The project says exploitation has been observed and does not publish the commands, the dates, or the source addresses. A profile that accepted MESSAGE before the upgrade is the place to look.
- The 1.11.3 build logs a rejected API-protocol MESSAGE with the source and the requested command, and answers 403. That log line exists only after the upgrade. It does not cover a command that ran on the old build.
- Review administrator accounts, dialplan changes, loaded modules, and scheduled commands you cannot account for. Where `mod_lua` is loaded, which the advisory says the stock configuration does, inline Lua was also reachable.
- Rotate credentials stored in the FreeSWITCH configuration. The advisory lists configuration and credential disclosure as an outcome. The upgrade does not rotate them.
- A command runs as the FreeSWITCH user. If that user is root, treat the host as the scope, not only the switch configuration.

## Sources

- [GHSA-mg63-h38w-8p9p][ghsa] — published 2026-10-28. CVSS 3.1 9.8. Affected through 1.11.2, fixed in 1.11.3. Exploitation observed. Reported by Örn Arnarson and Gunnlaugur.
- [FreeSWITCH 1.11.3][rel] — released 2026-08-28 22:27 UTC. Adds `enable-chat-api-proto` to `mod_sofia` and `mod_verto`. Drops Debian 11 Bullseye. The notes do not name the CVE.
- [CVE-2026-116779][cve] — GitHub, published 2026-11-05. CVSS 3.1 9.8. Affected before 1.11.3.
- [CISA KEV JSON feed][kev] — added 2026-11-09, due 2026-11-12 (catalog 2026.11.09, released 16:16:16 UTC). Ransomware use Unknown.

[ghsa]: https://github.com/signalwire/freeswitch/security/advisories/GHSA-mg63-h38w-8p9p
[rel]: https://github.com/signalwire/freeswitch/releases/tag/v1.11.3
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-116779
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
