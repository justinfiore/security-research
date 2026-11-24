# Rclone: a public key logs in as a password

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#rclone-a-public-key-logs-in-as-a-password) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-21 VulnCheck published [CVE-2026-134352](https://www.cve.org/CVERecord?id=CVE-2026-134352) for `rclone serve sftp --auth-proxy`. VulnCheck is the CNA.

The flaw is an authentication bypass. The auth-proxy cache is keyed on the username, the credential, and the client IP, not on whether the credential is a password or a public key. A public key is not a secret. Someone who knows a user's base64 public key sends it as a password, from the same client IP, and receives that user's read-write backend. The proxy is not asked. rclone's advisory says `PasswordCallback` always runs when a proxy is configured, so a proxy that refuses every password still has this path.

VulnCheck rates it **Critical, CVSS 4.0 9.2** (`CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`) and **High, CVSS 3.1 8.1** (`CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`). rclone's own advisory, [GHSA-66qv-66mg-9h74](https://github.com/rclone/rclone/security/advisories/GHSA-66qv-66mg-9h74), rates the same issue **High, CVSS 3.1 8.1**, and the page still says there is no known CVE.

The ranges disagree, and both stay. VulnCheck says **1.51.0 before 1.76.0** is affected and **1.76.0** is unaffected. The GitHub advisory says affected versions are **1.51.0 through 1.76.0** and the patched version is **v1.76.0**. The [changelog for 1.76.0](https://rclone.org/changelog/) lists the fix under that release: "Fix auth proxy letting a public key be used as a password GHSA-66qv-66mg-9h74". The fix commit, [f6ca72f](https://github.com/rclone/rclone/commit/f6ca72fabb09), puts the credential kind in the cache key. **1.76.0** was published 2026-11-06. The advisory was published the same day. The CVE record was published 2026-11-21.

Only `serve sftp` with `--auth-proxy` is this flaw. rclone says `serve ftp`, `serve http`, and `serve webdav` do not take the public-key path, and `serve s3` uses a different call. An rclone that never runs `serve sftp --auth-proxy` is outside it. No source read for this entry reports exploitation.

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
| Fix commit authored | 2026-10-09; time unknown | [f6ca72f](https://github.com/rclone/rclone/commit/f6ca72fabb09). The commit page does not show a clock time. |
| **Public announcement** | **2026-11-06 16:29:59 UTC** | rclone 1.76.0 and GHSA-66qv-66mg-9h74. rclone CVSS 3.1 8.1. The advisory page says no known CVE. [Release][rel] |
| CVE published | 2026-11-21; time/TZ unknown | VulnCheck. CVSS 4.0 9.2 and CVSS 3.1 8.1. Unaffected at 1.76.0. [CVE-2026-134352](https://www.cve.org/CVERecord?id=CVE-2026-134352) |

## Detection

Read the rclone version with `rclone version`. **1.51.0 through 1.75.2** is the range both sources call affected. The GitHub advisory also lists **1.76.0** as affected, and the changelog and the CVE record call 1.76.0 the fix. A binary that does not run `serve sftp --auth-proxy` is outside the flaw either way. Reading the version and the service command line changes no state.

## Remediation

1. Upgrade rclone to **1.76.0 or later** and restart every `rclone serve` process. The changelog puts the fix in 1.76.0. The GitHub advisory's affected range includes 1.76.0; the changelog and the CVE record do not.
2. Until the restart, stop using `--auth-proxy` on `serve sftp`. rclone says the password path cannot be turned off while the proxy is on.
3. The upgrade does not show whether a public key was already sent as a password.

## Verification

- The running `rclone serve sftp` process is **1.76.0 or later**.
- Do not send a public key as a password against a listener you do not operate.

## Compromise response

No source read for this entry reports an incident. If a listener ran `serve sftp --auth-proxy` on a version before 1.76.0, and a public key for a user of that listener is not a secret, treat that user's backend as exposed: review files written through it and rotate credentials the backend can reach. The advisory names no indicator.

## Sources

- [GHSA-66qv-66mg-9h74](https://github.com/rclone/rclone/security/advisories/GHSA-66qv-66mg-9h74) — published 2026-11-06. High, CVSS 3.1 8.1. Affected `>= 1.51.0, <= 1.76.0`, patched v1.76.0. The page says no known CVE. Read 2026-11-23.
- [rclone 1.76.0][rel] — published 2026-11-06T16:29:59Z.
- [rclone changelog, v1.76.0](https://rclone.org/changelog/) — dated 2026-11-06. "Fix auth proxy letting a public key be used as a password GHSA-66qv-66mg-9h74". Read 2026-11-23.
- [Fix commit f6ca72f](https://github.com/rclone/rclone/commit/f6ca72fabb09) — "serve sftp: fix auth proxy letting a public key be used as a password". Read 2026-11-23.
- [CVE-2026-134352](https://www.cve.org/CVERecord?id=CVE-2026-134352) — VulnCheck, published 2026-11-21. CVSS 4.0 9.2 and CVSS 3.1 8.1. Affected from 1.51.0 before 1.76.0. Unaffected at 1.76.0.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T19:43:55.7979Z, checked 2026-11-23. CVE-2026-134352 is not listed.

[rel]: https://github.com/rclone/rclone/releases/tag/v1.76.0
