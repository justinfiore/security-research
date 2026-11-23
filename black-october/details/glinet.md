# GL.iNet: the cloud service installed malware on routers and KVMs

**Last updated:** 2026-11-22 (America/New_York)

[Main summary](../black-october-2026.md#glinet-the-cloud-service-installed-malware-on-routers-and-kvms) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

GL.iNet makes routers and KVM devices, the boxes that control a computer remotely. On November 20 it said an unauthorized party used a vulnerability in its cloud remote management services to install malicious software on a subset of those devices. GL.iNet says the cloud path is closed. A device that was already infected stays infected until it is reset or updated.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** GL.iNet's security notice, last updated 04:25 UTC on November 21, says the cloud vulnerability was closed upon discovery and that the company is still investigating, including whether computers connected to affected KVM devices were reached. A staff post on the official forum the same day, last updated November 21 (UTC), adds the check and the firmware plan. It says devices can no longer be newly infected through that path, and that closing the path does not remove malware already installed. The notice still says stable firmware is scheduled for November 22 and does not name builds. The download API has since published them. On November 22 and 23 the release notes for eleven router models say the build fixes a vulnerability in the cloud platform's remote management that could lead to unauthorized access and the installation of malware. The seven KVM models named in the staff post have stable builds whose notes say the update strengthens that same service. A model whose newest stable release predates November 22 is not on that list.

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
| **Stable firmware** | **2026-11-22 21:42:40 UTC through 2026-11-23 08:33:48 UTC** | The download API published stable builds whose release notes name this cloud-management flaw. First release time is RM10RC 1.10.3. Last in this read is GL-XE3000 and GL-X3000 4.8.4. [API][api] |
| **Last updated** | **2026-11-22 (America/New_York)** | Stable firmware is out for the models named below. The notice itself is unchanged. |

## Detection

1. GL.iNet staff say to look for the exact text `crond -i /tmp/.log` in the details of a running process, on both routers and KVM devices. A line that only shows the `grep` command is not a match.
2. On a router, open LuCI at **Status → Processes** and search for `tmp/.log`. Over SSH, run `ps | grep tmp`.
3. On a KVM, use **Toolbox → Terminal → Access** and run the command in the KVM's terminal, not on the connected computer. RMQ1 uses `ps -a | grep tmp`. Every other KVM model uses `ps -aux | grep tmp`.
4. Not finding the process is not a clearance for a device you could not check. GL.iNet says to contact support@gl-inet.com when the check cannot be completed.

## Remediation

1. Check the device before you reset it. GL.iNet says a factory reset erases the settings, and the check is what tells you the device was infected.
2. If the indicator is present, treat the device as infected. On a KVM, install the stable build below, or factory reset it. A factory reset erases the configuration and does not replace the firmware. The November 21 beta floors, 1.10.2 and RMQ1 1.8.6, are older than the stable builds.
3. Whether or not the indicator is present, install the stable build whose release note names this flaw. Read from `firmware-api.gl-inet.com` on November 23:

   | Model | Stable build | Release time (GL.iNet API, timezone not stated) |
   |---|---|---|
   | GL-MT6000 Flint 2, GL-MT3000 Beryl AX | 4.11.1 | 2026-11-22 23:34:52; 2026-11-23 00:17:50 |
   | GL-BE9300 Flint 3, GL-BE3600 Slate 7 | 4.10.2 | 2026-11-23 05:04:26; 2026-11-23 07:38:08 |
   | GL-AXT1800 Slate AX, GL-AX1800 Flint, GL-SFT1200 Opal, GL-XE3000 Puli AX, GL-X3000 Spitz AX | 4.8.4 | 2026-11-23 05:17:12 through 08:33:48 |
   | GL-X2000 Spitz Plus, GL-MT2500/GL-MT2500A Brume 2 | 4.7.14 | 2026-11-23 03:43:10; 2026-11-23 08:25:01 |
   | RM10, RM10RC, RM1, RM1V2, RM1PE, RM4PE | 1.10.3 | 2026-11-22 21:42:40 through 23:32:34 |
   | RMQ1 | 1.8.7 | 2026-11-22 23:37:49 |

   Each router's note says the release fixes a vulnerability in the cloud platform's remote management that could lead to unauthorized access and the installation of malware. Each KVM note says the update strengthens the security of that service. A model whose newest stable release is older than November 22, including GL-B3000, GL-A1300, and GL-MT1300, had no such note in this read. Do not install another model's build on it.
4. The cloud fix does not remove malware already installed, and it does not update the device. Do not wait for the email. GL.iNet says it will email affected cloud accounts, and that the check does not depend on that email. Installing the build is not a substitute for the process check: GL.iNet has not said the update removes an infection by itself.

## Verification

- On a router, `ps | grep tmp` shows no `crond -i /tmp/.log`. On a KVM, the model command above shows none. A line that is only `grep` does not count.
- The running firmware is at least the stable build in the table above for that model. The November 21 beta floors are below those builds. A model with no row in the table has no published security build to check against.
- Do not probe the cloud service to see whether the vulnerability is still open. GL.iNet's statement is the only record of that.

## Compromise response

A device that showed the indicator was reached. A factory reset or a beta install does not show what the process did, and GL.iNet says it is still investigating whether computers connected to affected KVM devices were affected. On a KVM that matched, check the connected computer for unfamiliar programs, browser extensions, or user accounts, unexpected startup items or scheduled tasks, and changed settings or unusual network activity, then run a full scan. If anything looks wrong, change the passwords for accounts used on that computer. GL.iNet has not said when the infections began, which models were reached, or what the malware does beyond the process it names.

## Sources

- [GL.iNet security notice, 2026-11-20][notice] — read 2026-11-23. Issued 2026-11-20, last updated 2026-11-21 04:25 UTC. Cloud vulnerability closed upon discovery. The notice still says stable firmware is scheduled for 2026-11-22 and names no build. No CVE and no score.
- [GL.iNet forum announcement, staff post][forum] — read 2026-11-23. Last updated 2026-11-21 (UTC). Names `crond -i /tmp/.log`, the KVM beta floors, and stable firmware scheduled for 2026-11-22.
- [GL.iNet firmware API][api] — read 2026-11-23. `/cloud-api/model/info` and `/cloud-api/kvm`. Stable builds and release notes for the models in the remediation table. The API does not state a timezone for `release_time`.
- [GL-MT6000 4.11.1 release note][mt6000] — the same note the API returns, on the download site.
- [CISA KEV JSON][kev] — catalog 2026.11.20, checked 2026-11-23. No CVE to match.

[notice]: https://www.gl-inet.com/en-us/blogs/blog/glinet-security-notice-2026-11-20/
[forum]: https://forum.gl-inet.com/t/2026-11-20-gl-inet-security-notice-goodcloud-kvm-routers/73056
[api]: https://firmware-api.gl-inet.com
[mt6000]: https://dl.gl-inet.com/release/router/release/mt6000/4.11.1
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
