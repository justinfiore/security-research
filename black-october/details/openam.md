# OpenAM: a notification socket hands out live session tokens

**Last updated:** 2026-11-08 (America/New_York)

[Main OpenAM summary](../black-october-2026.md#openam-a-notification-socket-hands-out-live-session-tokens) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

OpenAM is an access-management server. With agent notifications on, which is the default, it publishes each user's session token to a WebSocket meant for policy agents. The check that limits that socket to agents can be skipped through a legacy Liberty ID-FF endpoint, with no login. The project rates that 10.0. The same 16.1.4 release fixes two more Critical flaws: the SAML service provider accepts an unsigned assertion on some bindings, and self-registration can put a new account in an administrative group.

**The project rates [GHSA-5c3q-hp86-xjr8](https://github.com/OpenIdentityPlatform/OpenAM/security/advisories/GHSA-5c3q-hp86-xjr8) CVSS 3.1 10.0 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`. VulnCheck assigned [CVE-2026-123551](https://www.cve.org/CVERecord?id=CVE-2026-123551) on 2026-11-08 and scores it CVSS 4.0 10.0 and CVSS 3.1 10.0. The GitHub page still says no CVE is known. A caller who can reach the server holds the notification socket open and reads the `iPlanetDirectoryPro` value of every session that is created, changed, or ended while the connection is open, including an administrator's. That value is a bearer credential for OpenAM and for every application that trusts it. The project says a captured administrator session can be escalated to command execution as the OpenAM service account. Collection is passive: there is no failed login. The attacker does not control when a user logs in; the connection can be kept open until one does. Agent notifications are on by default, and no federation feature has to be configured.

Two more Critical flaws are fixed in the same release:

- [CVE-2026-123550](https://www.cve.org/CVERecord?id=CVE-2026-123550) is [GHSA-3j2f-qhrc-rjfj](https://github.com/OpenIdentityPlatform/OpenAM/security/advisories/GHSA-3j2f-qhrc-rjfj). The project rates it CVSS 3.1 9.8. VulnCheck rates it CVSS 4.0 9.3 and CVSS 3.1 9.8. When OpenAM is a SAML v2.0 service provider, the ECP (PAOS) and HTTP-Artifact bindings accept an unsigned assertion if `WantAssertionsSigned` is off, which is the generated default, and the provider has an encryption key. The result is a session as the user the assertion names. Through 16.1.3.
- [CVE-2026-123549](https://www.cve.org/CVERecord?id=CVE-2026-123549) is [GHSA-jv8f-m88g-h6mm](https://github.com/OpenIdentityPlatform/OpenAM/security/advisories/GHSA-jv8f-m88g-h6mm). The project rates it CVSS 3.1 9.8. VulnCheck rates it CVSS 4.0 9.3 and CVSS 3.1 9.8. Self-registration writes group membership even when the allowed-attribute list does not include it, so a new account can be an administrator. Self-registration is off by default. Only a realm that has it on is affected. Through 16.1.3.

The same release also fixes High flaws the project rates 7.1 and 7.5, and a long list of Medium issues. 16.1.3, released 2026-09-18, fixed a different High flaw, [GHSA-wxmx-q96f-w4gw](https://github.com/OpenIdentityPlatform/OpenAM/security/advisories/GHSA-wxmx-q96f-w4gw), CVSS 3.1 8.6: unauthenticated class instantiation on the legacy JAX-RPC interface. 16.1.4 is the current release when checked on 2026-11-08. The GitHub pages still say no CVE is known. The project withholds proof-of-concept code.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08). The advisories do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| OpenAM 16.1.4 | 2026-10-22 06:52 UTC | The release that fixes all three. [Release][rel] |
| **Public announcement** | **2026-10-22 08:43 UTC** | The project published the three Critical advisories. The session-token one is 08:43:34 UTC, the SAML one 08:48:42 UTC, and the self-registration one 08:54:42 UTC. Each page still says no CVE is known. [Session tokens][ghsa551] |
| CVE records | 2026-11-08 01:37 UTC | VulnCheck published CVE-2026-123549, CVE-2026-123550, and CVE-2026-123551. [CVE-2026-123551][cve551] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-08) | [KEV][kev] |

## Detection

This reads the version you are running. It does not open the notification socket.

The version is in the running war. On a Docker install:

```sh
docker exec CONTAINER cat /usr/openam/openam.version 2>/dev/null || docker exec CONTAINER ls /usr/local/tomcat/webapps
```

The image tag is not the running version until the container was recreated from it. The project publishes `openidentityplatform/openam`. A tag of `latest` is not a version.

- **16.1.4 or later** has the fix for all three.
- **14.0.0 through 16.1.3** are inside the session-token flaw. Releases before 14.0.0 have no notification WebSocket, so they are outside that one flaw. They are not outside the other two: both apply through 16.1.3 with no stated floor.
- A deployment that is not reachable except from agent hosts is outside the session-token path only while that restriction holds. The version check still matters.

## Remediation

1. Upgrade to **16.1.4 or later** and recreate the container. A running container keeps the old image. Back up the configuration directory first.
2. A customised `web.xml` has to take the `<dispatcher>` elements that 16.1.4 adds to the `AuthNFilter`, `AuthZFilter`, `JAXRPCRequestFilter`, and `NotificationsWebSocketFilter` mappings. Without them the filters do not run on an internal forward, which is the bug.
3. A hosted Liberty ID-FF provider now has a Relay State URL List. While it is empty, a destination is accepted only under this deployment's own URLs. A deployment that sends users to another host after ID-FF login has to list that host, or those users land on the home page.
4. Until 16.1.4 is running, the project says to restrict `/openam/notifications` and `/openam/ws/*` to the agent hosts, set `org.forgerock.openam.notifications.agents.enabled` to `false` where agents do not need it, and block `/openam/preLogin` and `/openam/postLogin` unless Liberty ID-FF is in use. None of those replaces the upgrade.
5. The upgrade does not end a session that was already copied. It does not show whether a socket was held open.

## Verification

- The running war is 16.1.4 or later, after the container or process was restarted.
- A login your users already make still succeeds, and a policy agent still receives its notifications. Do not open the notification socket from anywhere else to test the check.

## Compromise response

The project says collection leaves no failed login. A WebSocket to `/openam/notifications` from an address that is not an agent host is the indicator it names, along with a subscription to a topic other than an agent topic and a change to the scripting-engine configuration.

If the server was reachable from outside the agent network on 16.1.3 or earlier:

- End administrator sessions and have administrators sign in again.
- Rotate credentials the OpenAM service account could use, and review accounts created while self-registration was on.
- Read the debug log for changes to scripting, federation, and OAuth 2.0 configuration that nobody made.

## Sources

- [GHSA-5c3q-hp86-xjr8][ghsa551] — the project, published 2026-10-22. CVSS 3.1 10.0. 14.0.0 through 16.1.3, fixed in 16.1.4. The page says no CVE is known.
- [CVE-2026-123551][cve551] — VulnCheck, published 2026-11-08 01:37 UTC. CVSS 4.0 10.0 and CVSS 3.1 10.0.
- [GHSA-3j2f-qhrc-rjfj][ghsa550] — the project, published 2026-10-22. CVSS 3.1 9.8. SAML unsigned assertions. Through 16.1.3.
- [CVE-2026-123550][cve550] — VulnCheck, published 2026-11-08 01:37 UTC. CVSS 4.0 9.3 and CVSS 3.1 9.8.
- [GHSA-jv8f-m88g-h6mm][ghsa549] — the project, published 2026-10-22. CVSS 3.1 9.8. Self-registration. Off by default.
- [CVE-2026-123549][cve549] — VulnCheck, published 2026-11-08 01:37 UTC. CVSS 4.0 9.3 and CVSS 3.1 9.8.
- [OpenAM 16.1.4][rel] — release notes, 2026-10-22.
- [CISA KEV JSON][kev] — catalog 2026.11.06, checked 2026-11-08. None of these CVEs is listed.

[ghsa551]: https://github.com/OpenIdentityPlatform/OpenAM/security/advisories/GHSA-5c3q-hp86-xjr8
[ghsa550]: https://github.com/OpenIdentityPlatform/OpenAM/security/advisories/GHSA-3j2f-qhrc-rjfj
[ghsa549]: https://github.com/OpenIdentityPlatform/OpenAM/security/advisories/GHSA-jv8f-m88g-h6mm
[cve551]: https://www.cve.org/CVERecord?id=CVE-2026-123551
[cve550]: https://www.cve.org/CVERecord?id=CVE-2026-123550
[cve549]: https://www.cve.org/CVERecord?id=CVE-2026-123549
[rel]: https://github.com/OpenIdentityPlatform/OpenAM/releases/tag/16.1.4
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
