# Linux kernel: Fragnesia - ESP-in-TCP page-cache overwrite

**Last updated:** 2026-10-28 (America/New_York)

[Main Fragnesia summary](../black-october-2026.md#linux-kernel-fragnesia---esp-in-tcp-page-cache-overwrite) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-46300](https://www.cve.org/CVERecord?id=CVE-2026-46300): kernel.org CNA CVSS 3.1 7.8 High** (`AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`). Ubuntu describes it as a trivial local privilege escalation, potentially including container escape. The flaw is distinct from the tracked `skb_zerocopy()` path: it loses the shared-fragment marker while TCP coalesces socket-buffer fragments, permitting ESP-in-TCP input to decrypt a shared page-cache fragment in place. [CVE record][cve] [Ubuntu][ubuntu]

**CISA KEV:** Listed — added 2026-10-28, federal due date 2026-10-31. CISA says the flaw can be chained with PHP2Shell to implant web shells and run commands as root; the due date applies to U.S. federal civilian agencies, but makes remediation urgent for everyone. [What KEV means](../black-october-2026.md#what-cisa-kev-means). [KEV][kev]

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
| CVE published | 2026-05-23; time/TZ unknown | kernel.org CNA record. [CVE record][cve] |
| Ubuntu fixed releases | 2026-06 onward; dates vary by package | Ubuntu lists fixed kernel builds for supported releases and flavors. [Ubuntu][ubuntu] |
| CISA KEV addition | 2026-10-28; time/TZ unknown | CISA reports active exploitation and requires forensic triage for covered agencies. [KEV][kev] |

## Detection

1. Record the running kernel with `uname -r`, then check the installed kernel package with your distribution’s package manager. A newly installed kernel does not protect a host until it is booted.
2. Compare the exact vendor kernel build to that vendor’s advisory. Do not infer status from an upstream version alone: distributions backport kernel fixes independently.
3. Prioritize Linux hosts that accept untrusted local code, container workloads, CI jobs, or PHP applications. CVE-2026-46300 requires local privileges but CISA reports it has been chained with PHP2Shell.

Missing package metadata or an unknown backport state means **unknown**, not fixed. This is a safe inventory procedure; do not run proof-of-concept code.

## Remediation

1. Install the vendor-supported kernel update that explicitly fixes CVE-2026-46300 (and the paired CVE-2026-43284/43503 handling where the vendor requires it), then reboot into that kernel. Ubuntu documents supported fixed builds, including `7.0.0-22.22` for 26.04 LTS, `6.8.0-124.124` for 24.04 LTS, and `5.15.0-181.191` for 22.04 LTS. [Ubuntu][ubuntu]
2. If a supported vendor fix is not yet available, follow the vendor’s documented compensating controls for the ESP-in-TCP/Dirty Frag family. Do not cherry-pick upstream kernel commits into production kernels.
3. Restrict untrusted code execution and review whether exposed PHP services have the PHP2Shell fixes. These controls reduce the chance of a chain but do not replace the kernel update.

## Verification

- Reboot and confirm `uname -r` matches the installed vendor-fixed build.
- Confirm the build against the vendor advisory or supported security tracker, not only a generic scanner result.
- Run normal application, IPsec, and container workloads after the maintenance window. Do not use exploit probes as verification.

## Compromise response

CISA’s KEV entry requires forensic triage for covered agencies and reports the issue can be chained to obtain root. Treat suspected exploitation as a potential root compromise: isolate the host, preserve relevant logs and memory where feasible, investigate persistence and credential access, rotate reachable secrets, and rebuild from trusted media when root compromise cannot be excluded. Patching alone does not remove a web shell or other persistence.

## Sources

- [kernel.org CNA CVE record][cve] — description, CVSS score and fix commits.
- [Ubuntu CVE tracker][ubuntu] — affected status, supported fixed kernel builds and mitigation context.
- [CISA KEV JSON feed][kev] and [CISA’s October 28 alert][cisa-alert] — active-exploitation status, due date and forensic-triage requirement.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-46300
[ubuntu]: https://ubuntu.com/security/CVE-2026-46300
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[cisa-alert]: https://www.cisa.gov/news-events/alerts/2026/10/28/cisa-adds-two-known-exploited-vulnerabilities-catalog
