# WordPress: User Registration Aide changes a password before login

**Last updated:** 2026-11-20 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-user-registration-aide-changes-a-password-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-20 WPScan published [CVE-2026-121385](https://www.cve.org/CVERecord?id=CVE-2026-121385). WPScan is the CNA and prints no score on the record. CISA's enrichment scores it **CVSS 3.1 9.8 Critical**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. NVD has not scored it.

The User Registration Aide plugin through **1.5.3.8** changes a user's password without checking the current password or a reset token. Someone who is not logged in, and who knows a username and an email address, can set a new password on any account, including an administrator. The record names no fixed version. Patchstack's page, the same day, also says there is no official patch.

This is not [Frontend Admin](wordpress-plugins-frontend-admin.md), [Advanced Form Integration](advanced-form-integration.md), or the [November 6 set](wordpress-plugins-nov6.md).

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-20). WPScan's reference is marked as an exploit entry and describes no incident. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-20; time/TZ unknown** | WPScan published the CVE record. No fixed version. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-121385) |

## Detection

Read the plugin version from the WordPress plugin list. **1.5.3.8 and earlier** are inside the record. A site that does not have the plugin is outside this entry. Knowing a username and an email address is the condition the record names.

## Remediation

1. There is no fixed version. Deactivate the plugin and remove it.
2. Until then, the password-update page stays open to anyone who knows an account's username and email.
3. Removing the plugin does not put back a password that was already changed. Reset every account password, starting with administrators.

## Verification

- The plugin is not active, and its directory is gone.
- An administrator can still sign in with the password you just set. Do not submit the password-update request.

## Compromise response

No source names an incident. An administrator whose password changed, and who did not change it, should be treated as taken over: reset the password, end that user's sessions, and review what the account did. Removing the plugin does not end a session that already exists.

## Sources

- [CVE-2026-121385](https://www.cve.org/CVERecord?id=CVE-2026-121385) — WPScan, published 2026-11-20. No score on the CNA record. Affected through 1.5.3.8. No fixed version. CISA-ADP CVSS 3.1 9.8.
- [Patchstack](https://patchstack.com/database/wordpress/plugin/user-registration-aide/vulnerability/wordpress-user-registration-aide-plugin-1-5-3-8-unauthenticated-account-takeover-vulnerability) — published 2026-11-20. Says no official patch.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-20. Not listed.
