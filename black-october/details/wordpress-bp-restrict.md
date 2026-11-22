# WordPress: Restrictions for BuddyPress runs code before login

**Last updated:** 2026-11-22 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-restrictions-for-buddypress-runs-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-20 Wordfence published [CVE-2026-120539](https://www.cve.org/CVERecord?id=CVE-2026-120539) for the Restrictions for BuddyPress plugin (`bp-restrict`). Wordfence rates it **CVSS 3.1 9.8 Critical**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. The CVE.org record was still reserved on 2026-11-22, so the score lives on Wordfence's page, not on a published CVE record. NVD has not scored it. The researcher is Achmad Zaenuri Dahlan Putra (snr). Wordfence does not describe an incident.

The plugin splices the request URI into a PHP expression inside a double-quoted string and evaluates it with `eval()`. PHP interpolates that string, so a `{${...}}` payload in the URL path runs during interpolation. No quote has to be broken, and WordPress's slashing does not stop it. A request with no login runs code. Wordfence says the affected conditions ship enabled by default and are evaluated before any logged-in check, so no plugin setting is required. The site has to have **BuddyPress** and **Paid Memberships Pro** active alongside this plugin.

Every version through **1.5.4** is affected. **1.5.5** is the fix. Seventh Queen's release, tagged 2026-11-12, says request data is no longer part of evaluated code and that logged-in-only restrictions are skipped for guests.

This is not [User Registration Aide](wordpress-user-registration-aide.md), [Give Peer-to-Peer](give-peer-to-peer.md), or [Advanced Form Integration](advanced-form-integration.md).

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-22). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| 1.5.5 tagged | 2026-11-12 09:48:02 UTC | Seventh Queen. The release calls it a security fix. [Release][rel] |
| **Public announcement** | **2026-11-20; time/TZ unknown** | Wordfence published the vulnerability page. [Wordfence][wf] |
| Wordfence page updated | 2026-11-21; time/TZ unknown | Wordfence's "Last Updated". [Wordfence][wf] |

## Detection

Read the plugin version from the WordPress plugin list. **1.5.4 and earlier** are inside the range Wordfence names. A site that does not have the plugin is outside this entry. A site that has the plugin but does not also have BuddyPress and Paid Memberships Pro active is outside the condition Wordfence names. Reading the version changes no state.

## Remediation

1. Update the plugin to **1.5.5 or later**.
2. Until then, deactivate it. The conditions Wordfence names are on by default, so leaving the plugin active leaves the request path open.
3. The update does not show whether a request already ran code.

## Verification

- The installed plugin is **1.5.5 or later**, or it is gone.
- Do not send a crafted request to test it.

## Compromise response

Wordfence does not describe an incident. The update does not undo a change a request already made. Review administrator accounts and files you did not create.

## Sources

- [Wordfence][wf] — published 2026-11-20, updated 2026-11-21. CVSS 3.1 9.8 Critical, `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Affected through 1.5.4. Patched in 1.5.5. Researcher Achmad Zaenuri Dahlan Putra (snr).
- [seventhqueen/buddypress-restrict 1.5.5][rel] — tagged 2026-11-12 09:48:02 UTC. "Fixed unauthenticated PHP code injection via the request URI in restriction condition evaluation."
- [CVE-2026-120539](https://www.cve.org/CVERecord?id=CVE-2026-120539) — reserved, checked 2026-11-22. No published description and no score on the record.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-22. Not listed.

[wf]: https://www.wordfence.com/threat-intel/vulnerabilities/wordpress-plugins/bp-restrict/restrictions-for-buddypress-154-unauthenticated-remote-code-execution-via-request-uri-string-interpolation-in-eval
[rel]: https://github.com/seventhqueen/buddypress-restrict/releases/tag/1.5.5
