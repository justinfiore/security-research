# GL.iNet: the cloud service installed malware on routers and KVMs

**Last updated:** 2026-11-21 (America/New_York)

[Main summary](../black-october-2026.md#glinet-the-cloud-service-installed-malware-on-routers-and-kvms) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

GL.iNet makes routers and KVM devices, the boxes that control a computer remotely. On November 20 it said an unauthorized party used a vulnerability in its cloud remote management services to install malicious software on a subset of those devices. GL.iNet says the cloud path is closed. A device that was already infected stays infected until it is reset or updated.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** GL.iNet's security notice, last updated 04:25 UTC on November 21, says the cloud vulnerability was closed upon discovery and that the company is still investigating, including whether computers connected to affected KVM devices were reached. A staff post on the official forum the same day, last updated November 21 (UTC), adds the check and the firmware plan. It says devices can no longer be newly infected through that path, and that closing the path does not remove malware already installed. Stable firmware with security fixes for both routers and KVM devices is scheduled for November 22, 2026. KVM beta builds are available now.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Security incident** | **2026-11-20; time unknown** | GL.iNet identified a vulnerability in its cloud remote management services. An unauthorized party installed malicious software on a subset of routers and KVM devices. [Notice][notice] |
| Notice updated | 2026-11-21 04:25 UTC | Cloud vulnerability closed. Firmware update still being prepared. Scope of the investigation still open. |
| **Staff guidance** | **2026-11-21; time unknown (UTC)** | The forum post names the process indicator, the KVM beta builds, and a stable firmware date of November 22. [Forum][forum] |
| **Last updated** | **2026-11-21 (America/New_York)** | New item. Stable firmware is not out yet. |

## Detection

1. GL.iNet staff say to look for the exact text `crond -i /tmp/.log` in the details of a running process, on both routers and KVM devices. A line that only shows the `grep` command is not a match.
2. On a router, open LuCI at **Status → Processes** and search for `tmp/.log`. Over SSH, run `ps | grep tmp`.
3. On a KVM, use **Toolbox → Terminal → Access** and run the command in the KVM's terminal, not on the connected computer. RMQ1 uses `ps -a | grep tmp`. Every other KVM model uses `ps -aux | grep tmp`.
4. Not finding the process is not a clearance for a device you could not check. GL.iNet says to contact support@gl-inet.com when the check cannot be completed.

## Remediation

1. Check the device before you reset it. GL.iNet says a factory reset erases the settings, and the check is what tells you the device was infected.
2. If the indicator is present, treat the device as infected. On a KVM, install the security beta for that model now, or factory reset it. The beta floors are RM10, RM10RC, RM1, RM1V2, RM1PE, and RM4PE at **1.10.2 beta or later**, and RMQ1 at **1.8.6 beta or later**. A factory reset erases the configuration and does not replace the firmware.
3. Whether or not the indicator is present, install the stable security firmware for that model when it ships. GL.iNet schedules it for November 22, 2026, for both routers and KVM devices. It has not published the stable build numbers.
4. The cloud fix does not remove malware already installed, and it does not update the device. Do not wait for the email. GL.iNet says it will email affected cloud accounts, and that the check does not depend on that email.

## Verification

- On a router, `ps | grep tmp` shows no `crond -i /tmp/.log`. On a KVM, the model command above shows none. A line that is only `grep` does not count.
- The running firmware is the stable security build once GL.iNet publishes it, or, on an infected KVM, at least the beta floor above. GL.iNet has not published the stable version string yet, so that check cannot be completed today.
- Do not probe the cloud service to see whether the vulnerability is still open. GL.iNet's statement is the only record of that.

## Compromise response

A device that showed the indicator was reached. A factory reset or a beta install does not show what the process did, and GL.iNet says it is still investigating whether computers connected to affected KVM devices were affected. On a KVM that matched, check the connected computer for unfamiliar programs, browser extensions, or user accounts, unexpected startup items or scheduled tasks, and changed settings or unusual network activity, then run a full scan. If anything looks wrong, change the passwords for accounts used on that computer. GL.iNet has not said when the infections began, which models were reached, or what the malware does beyond the process it names.

## Sources

- [GL.iNet security notice, 2026-11-20][notice] — read 2026-11-22. Issued 2026-11-20, last updated 2026-11-21 04:25 UTC. Cloud vulnerability closed upon discovery. Firmware update still being prepared. No CVE and no score.
- [GL.iNet forum announcement, staff post][forum] — read 2026-11-22. Last updated 2026-11-21 (UTC). Names `crond -i /tmp/.log`, the KVM beta floors, and stable firmware scheduled for 2026-11-22.
- [CISA KEV JSON][kev] — catalog 2026.11.20, checked 2026-11-22. No CVE to match.

[notice]: https://www.gl-inet.com/en-us/blogs/blog/glinet-security-notice-2026-11-20/
[forum]: https://forum.gl-inet.com/t/2026-11-20-gl-inet-security-notice-goodcloud-kvm-routers/73056
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
