# NVIDIA Linux driver: a GPU container reaches root on the host

**Last updated:** 2026-11-17 (America/New_York)

[Main summary](../black-october-2026.md#nvidia-linux-driver-a-gpu-container-reaches-root-on-the-host) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

The NVIDIA GPU display driver on Linux is the kernel module behind GeForce, RTX, and vGPU. NVIDIA's September 30, 2026 bulletin rates two flaws in it **CVSS 3.1 7.8 High**. Stealthium, which found both, published the write-ups in November 2026 and says an unprivileged container with the GPU passed through can reach root on the host.

**NVIDIA rates [CVE-2026-47591](https://www.cve.org/CVERecord?id=CVE-2026-47591) and [CVE-2026-47501](https://www.cve.org/CVERecord?id=CVE-2026-47501) CVSS 3.1 7.8 High.** The vector for both is `CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. NVIDIA is the CNA. CVE-2026-47591, which Stealthium calls NvRoot, is incorrect authorization: an unprivileged user can write memory the driver marked read-only. CVE-2026-47501, which Stealthium calls ForgePtr, is an out-of-bounds write during event buffer setup. NVIDIA says either can lead to code execution and escalation of privileges. Stealthium scores NvRoot **CVSS 4.0 9.3** and says a multi-tenant GPU host should treat it as critical. That 9.3 is Stealthium's, not NVIDIA's.

NVIDIA's bulletin, revision 2 on October 13, 2026, lists the Linux driver updates. For GeForce the rows this run confirmed are R615 before **615.71.09**. The CVE records list R615 before 615.71.09 and R610 before **610.57.04** for both CVEs, and the ForgePtr record also lists R595 before **595.91.07** and R580 before **580.178.04**. Stealthium says it confirmed ForgePtr root on 610.57.04, the build that fixes NvRoot, and names **615.71.09** as the ForgePtr fix. NVIDIA's CVE record lists 610.57.04 as the R610 fix for ForgePtr. Those two disagree, so a host that stopped at 610.57.04 is inside Stealthium's account of ForgePtr. Stealthium also says R590, R575, R570, and R565 and earlier have no NvRoot fix. NVIDIA's own note says an earlier branch that is not listed should move to the latest branch. There is no workaround: Stealthium says no sysctl or seccomp profile closes either bug.

The bulletin is dated September 30, 2026. The CVE records were published the same day. Stealthium's pages say "NOV 2026" and do not give a day. News coverage places the publication on November 12. Stealthium says it published no proof of concept.

**CISA KEV:** Not listed (catalog 2026.11.17, checked 2026-11-18) for either CVE. Stealthium does not report exploitation in the wild. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| NvRoot fix ships | 2026-08-03; time unknown | Stealthium: 610.57.04, 595.91.07, and 580.178.04. [NvRoot][nvroot] |
| ForgePtr fix ships | 2026-09-09; time unknown | Stealthium: 615.71.09. [ForgePtr][forgeptr] |
| **NVIDIA bulletin** | **2026-09-30; time unknown** | Revision 1. Both CVEs, both 7.8. Revision 2 is 2026-10-13 and does not change these two. [Bulletin][bulletin] |
| Stealthium write-ups | 2026-11 (exact day not on the page) | News coverage says November 12. No proof of concept. [NvRoot][nvroot] |
| **Last updated** | **2026-11-17 (America/New_York)** | New item. Install 615.71.09 or later and reboot. |

## Detection

1. **Running module.** `cat /proc/driver/nvidia/version` prints the module that is loaded. A GeForce, RTX, or vGPU host below 615.71.09 is inside at least one of NVIDIA's ranges. 610.57.04, 595.91.07, and 580.178.04 are the NvRoot floors NVIDIA and Stealthium agree on, and Stealthium says 610.57.04 is still inside ForgePtr.
2. **Who can open the GPU.** A container or a tenant with `/dev/nvidia*` passed through is the case Stealthium demonstrated. A single-user workstation is the case NVIDIA's 7.8 score describes. Both are affected.
3. A host with no NVIDIA GPU is outside this item. Windows is a different table in the same bulletin.

## Remediation

1. Install NVIDIA Linux driver **615.71.09 or later** and reboot. That is the one build both NVIDIA's R615 row and Stealthium name for both flaws.
2. A host that cannot move to R615 should install the newest build on its branch that the bulletin lists, and read Stealthium's note that 610.57.04 does not close ForgePtr. NVIDIA says an unlisted earlier branch should move to the latest branch.
3. Until the reboot, do not pass `/dev/nvidia*` into a container or a tenant you do not trust. That is containment, not the fix. There is no sysctl workaround.
4. Installing the package does not replace the module a running kernel has loaded. Reboot.

## Verification

- `/proc/driver/nvidia/version` reports 615.71.09 or later after the reboot.
- Do not run a container against the GPU to test the bug.

## Compromise response

Stealthium publishes no indicator and no proof of concept, and it does not report exploitation in the wild.

A shared GPU host that handed `/dev/nvidia*` to untrusted tenants before the reboot is the case to review: a poisoned file on the host would be one every tenant executes. The reboot does not show whether that already happened.

## Sources

- [NVIDIA GPU Display Driver security bulletin, September 2026][bulletin] — revision 1 on September 30, 2026, revision 2 on October 13, 2026. Both CVEs are CVSS 3.1 7.8. GeForce Linux R615 updates to 615.71.09. The page says an earlier branch that is not listed should move to the latest branch.
- [CVE-2026-47591](https://www.cve.org/CVERecord?id=CVE-2026-47591) — NVIDIA CNA, published 2026-09-30. 7.8. Linux R615 before 615.71.09 and R610 before 610.57.04.
- [CVE-2026-47501](https://www.cve.org/CVERecord?id=CVE-2026-47501) — NVIDIA CNA, published 2026-09-30. 7.8. The same floors, plus R595 before 595.91.07 and R580 before 580.178.04.
- [Stealthium, NvRoot][nvroot] — November 2026. Confirmed root on 610.43.02. CVSS 4.0 9.3 is Stealthium's score. R590, R575, R570, and R565 and earlier unpatched at the time of writing.
- [Stealthium, ForgePtr][forgeptr] — November 2026. Confirmed root on 610.43.02 and 610.57.04. Fixed in 615.71.09. No proof of concept.
- [CISA KEV JSON][kev] — catalog 2026.11.17, released 2026-11-17T17:53:15.5664Z, checked 2026-11-18. Neither CVE is listed.

[bulletin]: https://nvidia.custhelp.com/app/answers/detail/a_id/5861
[nvroot]: https://stealthium.io/blog/nvroot
[forgeptr]: https://stealthium.io/blog/forgeptr
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
