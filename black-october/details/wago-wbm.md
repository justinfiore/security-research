# WAGO: a low-privileged login runs commands as root

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#wago-a-low-privileged-login-runs-commands-as-root) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-23 CERT@VDE published VDE-2026-096 for the web management interface on WAGO controllers and panels. WAGO is the vendor. The advisory names two CVEs.

**The advisory rates [CVE-2026-80466](https://www.cve.org/CVERecord?id=CVE-2026-80466) CVSS 3.1 8.8 High.** The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. A user who can already log in to the web management interface, and who is not an administrator, can put shell commands into routing parameters. A root helper script later runs them. **[CVE-2026-88850](https://www.cve.org/CVERecord?id=CVE-2026-88850) is CVSS 3.1 8.1 High.** The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:N/I:H/A:H`. The same kind of login can change PROFIBUS settings that should require a higher privilege, including the device address.

The affected products are CC100, PFC100 G2, PFC200 G2, Touch Panel 600, Edge Controller, and WP400, on the model numbers in the advisory. **Firmware below 4.10.0 (FW32) is affected, and custom firmware below 4.10.0 (70) is affected.** **4.10.0 (FW32) or later** is the fix. Custom firmware comes from WAGO support, not from the public download. A firmware update restarts the controller. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.23, checked 2026-11-23) for either CVE. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-23 11:00** | VDE-2026-096, revision 1.0.0. The page does not name a timezone. Both CVEs published 11/23/2026 10:14 on the same page. [Advisory][vde] |

## Detection

Read the firmware version on the controller or panel. **Anything below 4.10.0 (FW32)**, or a custom build below **4.10.0 (70)**, is inside the range. A WAGO device that is not one of the listed model families is outside this advisory. Reading the version changes no state.

The flaws need a login. A management interface that is not reachable still runs the affected firmware.

## Remediation

1. Update to firmware **4.10.0 (FW32) or later**. The update restarts the controller, so do it in a window the line can take.
2. For a custom firmware, ask WAGO support for a build at **4.10.0 (70) or later**. Do not stay on the public firmware line if the device runs a custom one.
3. Until the update, allow the web management interface only from the engineering stations that configure the controller. That is a workaround, not the fix.
4. The update does not show whether a command already ran as root, or whether a PROFIBUS address was already changed.

## Verification

- The running firmware is **4.10.0 (FW32) or later**, or the custom build WAGO support names.
- Do not submit a routing parameter to test the injection.

## Compromise response

No source read for this entry reports an incident. If a low-privileged account could reach the management interface before the update, review routing changes and PROFIBUS addresses you did not make. The update does not undo a command that already ran as root.

## Sources

- [VDE-2026-096][vde] — CERT@VDE, published 2026-11-23 11:00, revision 1.0.0. CVE-2026-80466 is CVSS 3.1 8.8. CVE-2026-88850 is CVSS 3.1 8.1. Fixed in 4.10.0 (FW32). Custom firmware from WAGO support.
- [CVE-2026-80466](https://www.cve.org/CVERecord?id=CVE-2026-80466) and [CVE-2026-88850](https://www.cve.org/CVERecord?id=CVE-2026-88850) — referenced by the advisory. CWE-78 and CWE-862.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T19:43:55.7979Z, checked 2026-11-23. Neither is listed.

[vde]: https://certvde.com/en/advisories/VDE-2026-096
