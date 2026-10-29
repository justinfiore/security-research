# Adobe Connect: Critical code injection in desktop and Android clients

**Last updated:** 2026-10-29 (America/New_York)

[Main summary](../black-october-2026.md#adobe-connect-critical-code-injection-in-desktop-and-android-clients) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**CVEs:** [CVE-2026-48360](https://www.cve.org/CVERecord?id=CVE-2026-48360).

**Adobe rates CVE-2026-48360 CVSS 3.1 9.6 Critical.** The code-injection vulnerability can result in arbitrary code execution in affected Adobe Connect desktop and Android mobile clients.

**CISA KEV:** Not listed (catalog 2026.10.28, checked 2026-10-29). Adobe states it is not aware of exploitation in the wild. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Public bulletin and fixed releases | 2026-10-27; time/TZ unknown | Adobe published APSB26-182. |

## Detection

Inventory Adobe Connect Desktop clients by platform and Adobe Connect Mobile on Android. Record the complete client version from managed endpoint inventory or the product's About screen. A missing device from inventory is unknown, not patched.

## Remediation

Update Adobe Connect Desktop to **2026.9.61** on Windows, **2026.10.66** on Mac Silicon, or **2026.10.170** on Mac Intel. Update Adobe Connect Mobile for Android to **4.5**. Use the supported application-update channel and relaunch the desktop client after the update.

## Verification

Confirm the full client version in endpoint inventory or the About screen, then make an ordinary authorized test call or meeting connection. Do not test with code-injection payloads or untrusted content.

## Compromise response

If compromise is suspected, isolate the endpoint as appropriate, preserve relevant endpoint and application telemetry, review unexpected processes and persistence, and rotate credentials used on the affected device from a known-clean system. Updating the application does not establish that a prior attack did not succeed.

## Sources

- [Adobe APSB26-182](https://www.adobe.com/trust/security/products/connect/apsb26-182.html) — affected/fixed versions, CVSS rating, impact and exploitation statement.
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — KEV status.
