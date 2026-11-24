# EV Reach: a low-privileged user runs commands as SYSTEM

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#ev-reach-a-low-privileged-user-runs-commands-as-system) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-23 EasyVista published advisory EVA-2026-01 for the EV Reach Client Agent on Windows. EasyVista-OTRS is the CNA.

**EasyVista rates [CVE-2026-93585](https://www.cve.org/CVERecord?id=CVE-2026-93585) CVSS 3.1 8.8 High and CVSS 4.0 8.7 High.** The CVE record carries only the CVSS 3.1 score. The vectors are `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H` and `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N/RE:M/U:Red`. A user who is already authenticated, and who is not an administrator, can run a command on a remote Windows endpoint as `NT AUTHORITY\SYSTEM`. The agent is supposed to run that command as the calling user. EasyVista says that, under specific conditions, it does not, and the command runs as the agent service. No further login prompt is required after the first authentication.

**EV Reach Console before 11.0.14.1127, EV Reach Agent before 11.0.16, and EV Reach Server before 11.0.14.1274 are affected.** Those three builds are the fixes. Until they are installed, EasyVista says to limit TCP port 22000 to the management systems you trust, or to disable the agent where it is not needed. That reduces who can reach it. It is not the fix. No source read for this entry reports exploitation.

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
| **Public announcement** | **2026-11-23; time/TZ unknown** | EVA-2026-01. CVSS 3.1 8.8 and CVSS 4.0 8.7. [Advisory][eva] |

## Detection

Read the installed version of the EV Reach Console, the Agent, and the Server. A Console below **11.0.14.1127**, an Agent below **11.0.16**, or a Server below **11.0.14.1274** is inside the range. A Windows computer with no EV Reach component is outside it. Reading the version changes no state.

## Remediation

1. Update the EV Reach Console to **11.0.14.1127 or later**, the Agent to **11.0.16 or later**, and the Server to **11.0.14.1274 or later**.
2. Until then, allow TCP port 22000 only from management systems you trust. Where the agent is not needed, disable or remove the service. That is the workaround, not the fix.
3. The update does not show whether a command already ran as `SYSTEM`.

## Verification

- The Console, Agent, and Server versions are at or above the floors above.
- Do not send a management command to test the authorization check.

## Compromise response

No source read for this entry reports an incident. If a low-privileged account could reach the agent before the update, review what that account could start on the endpoints. The update does not undo a command that already ran as `SYSTEM`.

## Sources

- [EVA-2026-01][eva] — EasyVista, dated 2026-11-23. CVSS 3.1 8.8 and CVSS 4.0 8.7. Fixed in Console 11.0.14.1127, Agent 11.0.16, and Server 11.0.14.1274. Workaround: restrict TCP 22000.
- [CVE-2026-93585](https://www.cve.org/CVERecord?id=CVE-2026-93585) — EasyVista-OTRS, published 2026-11-23. CVSS 3.1 8.8 only. CWE-863.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T19:43:55.7979Z, checked 2026-11-23. Not listed.

[eva]: https://otrs.com/release-notes/easyvista-advisory-2026-01/
