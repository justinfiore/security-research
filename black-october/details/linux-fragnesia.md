# Linux kernel: Fragnesia - ESP-in-TCP page-cache overwrite

**Last updated:** 2026-11-25 (America/New_York)

[Main Fragnesia summary](../black-october-2026.md#linux-kernel-fragnesia---esp-in-tcp-page-cache-overwrite) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-46300](https://www.cve.org/CVERecord?id=CVE-2026-46300): kernel.org CNA CVSS 3.1 7.8 High** (`AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`). Ubuntu describes it as a trivial local privilege escalation, potentially including container escape. Palo Alto's November 24 bulletin says the same flaw was used against PAN-OS management interfaces exposed to the internet. The flaw is distinct from the tracked `skb_zerocopy()` path: it loses the shared-fragment marker while TCP coalesces socket-buffer fragments, permitting ESP-in-TCP input to decrypt a shared page-cache fragment in place. [CVE record][cve] [Ubuntu][ubuntu]

**CISA KEV:** Listed — added 2026-10-28, federal due date 2026-10-31. CISA says the flaw can be chained with PHP2Shell to implant web shells and run commands as root; the due date applies to U.S. federal civilian agencies, but makes remediation urgent for everyone. [What KEV means](../black-october-2026.md#what-cisa-kev-means). [KEV][kev]

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [PAN-OS builds](#pan-os-builds)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| CVE published | 2026-05-23; time/TZ unknown | kernel.org CNA record. [CVE record][cve] |
| Ubuntu fixed releases | 2026-06 onward; dates vary by package | Ubuntu lists fixed kernel builds for supported releases and flavors. [Ubuntu][ubuntu] |
| CISA KEV addition | 2026-10-28; time/TZ unknown | CISA reports active exploitation and requires forensic triage for covered agencies. [KEV][kev] |
| Chained with PHP2Shell in the wild | Campaign 2026-10-08 to 2026-10-24 per Dream's timeline (time/TZ unknown); timestamped compromises 2026-10-23 18:14 UTC and 2026-10-24 10:09 and 11:35 UTC; report 2026-10-26, updated 2026-10-29 | Dream Research recovered tooling that ran a custom PHP2Shell exploit and then Fragnesia, overwriting `/etc/pam.d/su` through the page cache so `su root` succeeds without a password, to root 24 PAN-OS firewalls and one management server; Unit 42 independently verified the tooling and results. See the [PHP2Shell guide](php2shell.md#exploitation-status) for indicators. [Dream][dream] [Unit 42][unit42] |
| **PAN-OS fixed builds** | **2026-11-24; time/TZ unknown** | PAN-SA-2026-0015, initial publication. The page's Published line says 2026-11-25 and Updated says 2026-11-24. Exploitation observed against internet-exposed management. The only path Palo Alto names starts with PHP2Shell. [PAN-SA][pansa] |

## Detection

1. Record the running kernel with `uname -r`, then check the installed kernel package with your distribution’s package manager. A newly installed kernel does not protect a host until it is booted.
2. Compare the exact vendor kernel build to that vendor’s advisory. Do not infer status from an upstream version alone: distributions backport kernel fixes independently.
3. Prioritize Linux hosts that accept untrusted local code, container workloads, CI jobs, or PHP applications. CVE-2026-46300 requires local privileges but CISA reports it has been chained with PHP2Shell.

Missing package metadata or an unknown backport state means **unknown**, not fixed. This is a safe inventory procedure; do not run proof-of-concept code.

## Remediation

1. Install the vendor-supported kernel update that explicitly fixes CVE-2026-46300 (and the paired CVE-2026-43284/43503 handling where the vendor requires it), then reboot into that kernel. Ubuntu documents supported fixed builds, including `7.0.0-22.22` for 26.04 LTS, `6.8.0-124.124` for 24.04 LTS, and `5.15.0-181.191` for 22.04 LTS. [Ubuntu][ubuntu]
2. On PAN-OS, install a build PAN-SA-2026-0015 names, then reboot. The floors are **12.2.4-h3**, **12.1.10-h6**, **12.1.7-h15**, **12.1.4-h15**, **11.2.16-h3**, **11.2.13-h6**, **11.2.10-h19**, **11.2.7-h25**, **11.2.4-h25**, **11.1.16-h6**, **11.1.13-h18**, **11.1.10-h38**, **11.1.7-h14**, **11.1.6-h42**, **11.1.4-h40**, **10.2.18-h15**, **10.2.16-h14**, **10.2.13-h29**, **10.2.10-h45**, and **10.2.7-h41**, or a later build on that line. Palo Alto says a fixed build listed in the [PHP2Shell advisory](https://security.paloaltonetworks.com/CVE-2026-109618) is protected, and also says the only exploitation path it knows is PHP2Shell against an internet-exposed management interface. A PHP2Shell hotfix below the floor in this paragraph does not include the kernel fix. If the management interface, or a dataplane interface with a management profile, is reachable from the internet, upgrade now and restrict it to trusted addresses. [PAN-SA][pansa]
3. If a supported vendor fix is not yet available, follow the vendor’s documented compensating controls for the ESP-in-TCP/Dirty Frag family. Do not cherry-pick upstream kernel commits into production kernels.
4. Restrict untrusted code execution and review whether exposed PHP services have the PHP2Shell fixes. These controls reduce the chance of a chain but do not replace the kernel update.

### PAN-OS builds

PAN-SA-2026-0015 names these floors. A later build on the same line includes the fix. A PHP2Shell hotfix below the floor does not.

| PAN-OS line | First build PAN-SA-2026-0015 names |
|---|---|
| 12.2 | 12.2.4-h3 |
| 12.1 | 12.1.4-h15, 12.1.7-h15, 12.1.10-h6 |
| 11.2 | 11.2.4-h25, 11.2.7-h25, 11.2.10-h19, 11.2.13-h6, 11.2.16-h3 |
| 11.1 | 11.1.4-h40, 11.1.6-h42, 11.1.7-h14, 11.1.10-h38, 11.1.13-h18, 11.1.16-h6 |
| 10.2 | 10.2.7-h41, 10.2.10-h45, 10.2.13-h29, 10.2.16-h14, 10.2.18-h15 |

Palo Alto says every observed exploitation targeted a management interface exposed to the internet, and that it knows no other path than PHP2Shell through that interface. Restrict the management interface either way. The bulletin is informational and does not publish its own CVSS score; the kernel.org score remains 7.8.

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
- [Dream Research][dream] and [Unit 42][unit42] — the PHP2Shell + Fragnesia chain to root on PAN-OS devices.
- [PAN-SA-2026-0015][pansa] — 2026-11-24. PAN-OS builds that contain the kernel fix, and Palo Alto's statement that exploitation targeted internet-exposed management.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-46300
[ubuntu]: https://ubuntu.com/security/CVE-2026-46300
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[cisa-alert]: https://www.cisa.gov/news-events/alerts/2026/10/28/cisa-adds-two-known-exploited-vulnerabilities-catalog
[dream]: https://dreamgroup.com/blog/chained-php2shell-exploit-roots-25-servers
[unit42]: https://unit42.paloaltonetworks.com/cve-2026-109618-cve-2026-109619/
[pansa]: https://security.paloaltonetworks.com/PAN-SA-2026-0015
