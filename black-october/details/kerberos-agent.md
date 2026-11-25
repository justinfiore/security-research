# Kerberos Agent: a default key forges an administrator token

**Last updated:** 2026-11-24 (America/New_York)

[Main plugin summary](../black-october-2026.md#kerberos-agent-a-default-key-forges-an-administrator-token) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Kerberos Agent is the camera-side component of Kerberos.io. Its REST API checks a JWT. When `AGENT_JWT_SECRET` is unset, the middleware signs and verifies tokens with the literal string `TOBECHANGED`. The project's own deployment manifests leave that variable unset.

**The maintainers rate [GHSA-3c52-7fc8-c39j](https://github.com/kerberos-io/agent/security/advisories/GHSA-3c52-7fc8-c39j) Critical, CVSS 3.1 9.8.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. VulnCheck's [CVE-2026-135208](https://www.cve.org/CVERecord?id=CVE-2026-135208), published 2026-11-23, scores the same issue CVSS 3.1 9.8 and CVSS 4.0 9.3 (`CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`). An unauthenticated client forges an HS256 token and reaches `/api` and `/config` as an administrator. The advisory's proof of concept returned the agent configuration, including the agent key. With a camera configured, the same token returns stored RTSP and ONVIF credentials, Hub keys, and the recording encryption key, and it can rewrite the configuration or stop the camera. **Every release through 3.14.3** is affected. **3.14.4**, released 2026-11-21, drops the default key. Changing the login password and leaving the signing key at its default does not close it. The GitHub advisory still says "No known CVE."

3.14.5, released 2026-11-22, derives recording keys with PBKDF2 and uses AES-GCM. That is a separate change, and the release note does not rate it. 3.14.6 accepts Kerberos Factory tokens when the secret is shared. Neither release note reports exploitation of the JWT flaw.

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
| Advisory published | 2026-11-21; time/TZ unknown | [GHSA-3c52-7fc8-c39j][ghsa]. Critical, CVSS 3.1 9.8. The page prints no time. |
| **Fix** | **2026-11-21 22:31:39 UTC** | [v3.14.4][rel]. Drops the default JWT key. |
| Follow-up releases | 2026-11-22 06:28:36 UTC and 07:14:25 UTC | v3.14.5 derives recording keys with PBKDF2. v3.14.6 accepts Factory tokens. |
| **Public CVE** | **2026-11-23; time/TZ unknown** | [CVE-2026-135208][cve]. VulnCheck. CVSS 3.1 9.8 and CVSS 4.0 9.3. |
| **Last updated** | **2026-11-24 (America/New_York)** | New item. Upgrade to 3.14.4 or later, and set a secret. |

## Detection

Read the running agent version. **3.14.3 and earlier** are inside the flaw. 3.14.4 or later is the floor the advisory names. Also check whether `AGENT_JWT_SECRET` is set. A deployment that still uses the shipped manifests and has not set it is the configuration the advisory describes. Reading the version and the environment changes no state. A 401 from an unauthenticated request does not show that the default key is gone.

## Remediation

1. Upgrade to **3.14.4 or later** and restart the agent. 3.14.6 is the current release and includes the token fix.
2. Set `AGENT_JWT_SECRET` to a value you generate. The advisory says the docker-compose, Kubernetes, snap, and balena manifests do not set it. Changing `AGENT_USERNAME` and `AGENT_PASSWORD` away from the default `root` / `root` is separate and does not replace the signing key.
3. The upgrade does not show whether a forged token already read the camera credentials or rewrote the configuration. Rotate RTSP, ONVIF, Hub, and recording keys that the agent stored.

## Verification

- The running build is 3.14.4 or later, and `AGENT_JWT_SECRET` is set to a value that is not `TOBECHANGED`.
- Do not forge a token to test it.

## Compromise response

An agent through 3.14.3 that left the secret unset may already have had its configuration read or rewritten. Review configuration changes and stopped cameras you cannot account for, then rotate the credentials the agent stored. The upgrade does not show whether either happened. No source read for this entry reports an incident.

## Sources

- [GHSA-3c52-7fc8-c39j][ghsa] — kerberos-io, published 2026-11-21. Critical, CVSS 3.1 9.8. Through 3.14.3. Fixed in 3.14.4. The page says no CVE is known.
- [CVE-2026-135208][cve] — VulnCheck, published 2026-11-23. CVSS 3.1 9.8 and CVSS 4.0 9.3. Before 3.14.4.
- [v3.14.4][rel] — released 2026-11-21 22:31:39 UTC. Pull 361 drops the default JWT key.
- [v3.14.5](https://github.com/kerberos-io/agent/releases/tag/v3.14.5) and [v3.14.6](https://github.com/kerberos-io/agent/releases/tag/v3.14.6) — 2026-11-22. Recording-key derivation, then Factory tokens. Neither replaces 3.14.4 as the JWT floor.
- [CISA KEV JSON][kev] — catalog 2026.11.24, released 2026-11-24T17:47:46.199Z, checked 2026-11-24. CVE-2026-135208 is not listed.

[ghsa]: https://github.com/kerberos-io/agent/security/advisories/GHSA-3c52-7fc8-c39j
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-135208
[rel]: https://github.com/kerberos-io/agent/releases/tag/v3.14.4
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
