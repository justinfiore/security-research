# Bazarr: a Windows request reads the config

**Last updated:** 2026-11-26 (America/New_York)

[Main guide](../black-october-2026.md#bazarr-a-windows-request-reads-the-config)

**GitHub rates [GHSA-v569-4w84-grxq](https://github.com/morpheus65535/bazarr/security/advisories/GHSA-v569-4w84-grxq) High, CVSS 3.1 7.5.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N`. VulnCheck's [CVE-2026-137585](https://www.cve.org/CVERecord?id=CVE-2026-137585) scores the same issue CVSS 3.1 7.5 and CVSS 4.0 8.7 (`CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`). The weakness is CWE-22. On Windows, the UI catch-all serves any path that starts with `workbox-` before Basic or Forms authentication, and it passes that path to `send_file`. Windows normalizes `..` before the lookup, so a request with no login reads a file outside `frontend/build`. The advisory says the Windows service normally runs as LocalSystem, and that `config.yaml` holds the Bazarr, Sonarr, Radarr, Plex, proxy, and provider credentials. It claims no file modification and no code execution. **1.4.4 before 1.6.1-beta.29** are affected. The fix commit is August 23, 2026, and **v1.6.1-beta.29** shipped August 24. Stable **v1.6.1** shipped September 15 and **v1.6.2** shipped September 26, both after that commit. The GitHub page still says "No known CVE." The advisory says the flaw is on Windows. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix commit | 2026-08-23 15:43:57 UTC | `9ea62688dfc2`. Validates the resolved path before serving a PWA asset. [Commit][commit] |
| Beta fix | 2026-08-24 06:52:29 UTC | v1.6.1-beta.29. The GitHub advisory names this as the patched version. [Beta][beta] |
| Advisory published | 2026-08-23; time/TZ unknown | GHSA-v569-4w84-grxq, High, CVSS 3.1 7.5. The page says no CVE is known. [GHSA][ghsa] |
| Stable releases | 2026-09-15 01:03:05 UTC, then 2026-09-26 01:37:28 UTC | v1.6.1, then v1.6.2. Both are after the fix commit. [v1.6.2][stable] |
| **Public CVE record** | **2026-11-26; time/TZ unknown** | VulnCheck published CVE-2026-137585. CVSS 4.0 8.7 and CVSS 3.1 7.5. [CVE][cve] |
| **Last updated** | **2026-11-26 (America/New_York)** | New item. Update Windows installs to 1.6.2. |

## Detection

An install that is not Windows is outside the claim the advisory makes. Read the version in the UI or from the running package. **1.4.4 before 1.6.1-beta.29** is the range the record names. A stable install below **1.6.1** is inside it. v1.6.0 is inside it: the advisory says the branch is still present there. The default port is 6767. Reading the version changes no state. A version you cannot read means unknown, not safe.

## Remediation

1. Update a Windows install to **v1.6.2 or later**. That is the current stable release, and it is after the fix. v1.6.1 also contains the fix commit. A beta install needs **v1.6.1-beta.29 or later**.
2. The update does not show whether `config.yaml` was already read. Rotate the Sonarr, Radarr, Plex, proxy, and provider credentials that file holds.
3. Do not expose port 6767 to the internet. The flaw needs no login, so a proxy login in front of it does not help an old build: the `workbox-` route is served before Bazarr's own authentication.

## Verification

- The UI reports **1.6.2 or later**, or a beta at **1.6.1-beta.29 or later**.
- The host is not Windows, which is outside the advisory's claim.
- Do not request a `workbox-` path with `..` to test it.

## Compromise response

Search the web server log, or the proxy log, for a request whose path starts with `workbox-` and contains `%2e%2e` or `..`. A hit against a Windows install below the fix is a lead that `config.yaml` could have been read. Rotate every credential in that file, including ones reused elsewhere. The advisory claims the flaw reads files and does not write them.

## Sources

- [GHSA-v569-4w84-grxq][ghsa] — published 2026-08-23 by morpheus65535. High, CVSS 3.1 7.5. Affected `>= 1.4.4`. Patched in 1.6.1-beta.29. The page says no CVE is known.
- [CVE-2026-137585][cve] — VulnCheck, published 2026-11-26. CVSS 4.0 8.7 and CVSS 3.1 7.5. Affected from 1.4.4 before 1.6.1-beta.29, on Windows.
- [Fix commit 9ea62688dfc2][commit] — 2026-08-23 15:43:57 UTC.
- [v1.6.1-beta.29][beta] — published 2026-08-24 06:52:29 UTC.
- [v1.6.2][stable] — published 2026-09-26 01:37:28 UTC. v1.6.1 was 2026-09-15.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-26. CVE-2026-137585 is not listed.

[ghsa]: https://github.com/morpheus65535/bazarr/security/advisories/GHSA-v569-4w84-grxq
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-137585
[commit]: https://github.com/morpheus65535/bazarr/commit/9ea62688dfc2bd56ed11f6352653eaaf68c2f758
[beta]: https://github.com/morpheus65535/bazarr/releases/tag/v1.6.1-beta.29
[stable]: https://github.com/morpheus65535/bazarr/releases/tag/v1.6.2
