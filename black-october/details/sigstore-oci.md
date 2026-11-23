# Node.js: sigstore-js sends the registry password to another host

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#nodejs-sigstore-js-sends-the-registry-password-to-another-host) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-12 the sigstore maintainers published [GHSA-9mj6-f434-pgcg](https://github.com/sigstore/sigstore-js/security/advisories/GHSA-9mj6-f434-pgcg) for the `@sigstore/oci` npm package. They rate it **High, CVSS 3.1 7.5**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N`. The advisory page says "No known CVE".

On 2026-11-22 VulnCheck published [CVE-2026-134816](https://www.cve.org/CVERecord?id=CVE-2026-134816) for the same issue and scored it **CVSS 4.0 8.2 High** and **CVSS 3.1 5.9 Medium**. VulnCheck is the CNA. The CVSS 4.0 vector is `CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`. The two CVSS 3.1 scores disagree: the maintainer's is 7.5 with attack complexity Low, and VulnCheck's is 5.9 with attack complexity High. Both stay. NVD has not scored it.

When `@sigstore/oci` authenticates with identity-token credentials, the username is the literal string `<token>` and the client asks the registry's token endpoint for a token with an OAuth2 password grant. The `POST` body carries `username`, `password`, and `grant_type=password`. If that endpoint answers with a `307` or `308` redirect to a different origin, the client follows it and sends the body again, including the password. The client already drops the `Authorization` header on a cross-origin redirect. It does not drop the body. A `303` is not affected, because the follow-up is a `GET` with no body.

The maintainer says all of this has to be true:

- The client uses `<token>` credentials, so the password grant runs.
- The token endpoint, which the caller otherwise trusts, returns a cross-origin `307` or `308` to a host the attacker controls. The advisory names an open redirect, a misconfiguration, or a compromise of the token service.

A registry the attacker already controls does not need the redirect. It picks the token endpoint in its `WWW-Authenticate` challenge. The same advisory notes that Docker Hub canonicalization matches any host ending in `docker.io`, so `mydocker.io` is treated as Docker Hub. Credential lookup still requires an exact host match, so that does not send credentials to an attacker-chosen host. It is a hardening fix in the same release, not this flaw.

`@sigstore/oci` **before 0.8.0** is affected. **0.8.0**, published to npm on 2026-11-05, is the fix. The release says requests now require HTTPS and a public network destination unless the caller allows that origin. The advisory page still says "Not yet patched", and the release is the newer statement. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.23, checked 2026-11-23). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| 0.8.0 | 2026-11-05 00:22:05 UTC | npm publish time. Redirect handling hardened. [Release][rel] |
| **Public announcement** | **2026-11-12 16:40:29 UTC** | GHSA-9mj6-f434-pgcg. Maintainer CVSS 3.1 7.5. The page says no CVE. [Advisory][ghsa] |
| CVE published | 2026-11-22; time/TZ unknown | VulnCheck. CVSS 4.0 8.2 and CVSS 3.1 5.9. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-134816) |

## Detection

Read `@sigstore/oci` from the lockfile. **Anything before 0.8.0** is inside the range the advisory names. A dependency that never uses identity-token credentials, username `<token>`, is outside the path the advisory names; the version is still the one the advisory lists. Reading the lockfile changes no state.

## Remediation

1. Upgrade `@sigstore/oci` to **0.8.0 or later**.
2. Until then, do not use `<token>` identity-token credentials against a token service that can redirect to another origin. Prefer a short-lived registry credential.
3. The upgrade does not show whether a password was already sent, and it does not expire one that was.

## Verification

- The installed `@sigstore/oci` is **0.8.0 or later**.
- Do not send a password grant to a redirecting token endpoint to test it.

## Compromise response

No source read for this entry reports an incident. If the client used identity-token credentials against a token service that could redirect before the upgrade, treat that password as exposed and rotate it. The upgrade does not expire a password that was already sent.

## Sources

- [GHSA-9mj6-f434-pgcg][ghsa] — published 2026-11-12T16:40:29Z. High, CVSS 3.1 7.5. Affected before 0.8.0, patched in 0.8.0 or later. The page text still says "Not yet patched" and "No known CVE". Credits Zachariah Mithani.
- [CVE-2026-134816](https://www.cve.org/CVERecord?id=CVE-2026-134816) — VulnCheck, published 2026-11-22. CVSS 4.0 8.2 and CVSS 3.1 5.9. `@sigstore/oci` before 0.8.0.
- [@sigstore/oci 0.8.0][rel] — published 2026-11-05T00:22:05Z. Commit `7ca56e9` hardens registry authentication and redirect handling.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T12:54:37.9646Z, checked 2026-11-23. Not listed.

[ghsa]: https://github.com/sigstore/sigstore-js/security/advisories/GHSA-9mj6-f434-pgcg
[rel]: https://github.com/sigstore/sigstore-js/releases/tag/%40sigstore%2Foci%400.8.0
