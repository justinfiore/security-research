# Linux kernel: November 2–3 High fixes

**Last updated:** 2026-11-20 (America/New_York)

[Main summary](../black-october-2026.md#linux-kernel-thirteen-high-fixes-from-november-2-and-3) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

kernel.org published thirteen Linux kernel CVE records on 2026-11-02 and 2026-11-03 and scored each one CVSS 3.1 High, from 7.0 to 8.1. NVD has not added a score of its own. Two are reachable from the network when a non-default feature is on. The other eleven need a local account, and several of those also need tracing, io_uring, Bluetooth, or the extensible scheduler. None of the records reports exploitation in the wild. This is not [NoisyTCP](linux-noisytcp.md), not the [IPv4 TCP options use-after-free](linux-tcp-options.md), and not the [skb_zerocopy](skb-zerocopy-lpe.md) page-cache write.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-19). None of the thirteen is in the catalog. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [What each flaw needs](#what-each-flaw-needs)
- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## What each flaw needs

kernel.org is the CNA for every row. The score is the CNA score. A vendor that scores the same flaw lower is named in [Remediation](#remediation).

| CVE | CNA score | What has to be true | First fixed upstream |
|---|---|---|---|
| [CVE-2026-99270](https://www.cve.org/CVERecord?id=CVE-2026-99270) | 8.1 | A remote TCP handshake, plus request-socket migration. Migration is off unless `net.ipv4.tcp_migrate_req` is set or a reuseport BPF program migrates sockets. The CNA says the timer can then use a freed request socket. | 6.12.117, 6.18.61, and 7.1. No 5.10, 5.15, 6.1, or 6.6 tag. |
| [CVE-2026-99246](https://www.cve.org/CVERecord?id=CVE-2026-99246) | 8.1 | TIPC is loaded, a UDP bearer is up, and the node-reset tracepoint is enabled. The CNA says a packet can then race bearer teardown and use a freed link. TIPC is not loaded by default. | 5.10.273, 5.15.224, 6.1.191, 6.6.161, 6.12.115, 6.18.59, 7.2.13, and 7.3. |
| [CVE-2026-99239](https://www.cve.org/CVERecord?id=CVE-2026-99239) | 7.8 | A local process opens a Bluetooth L2CAP socket. The CNA says a bind/connect race can link one channel to two connections. | 5.10.273, 5.15.224, 6.1.191, 6.6.161, 6.12.115, 6.18.60, 7.2.14, and 7.3.1. |
| [CVE-2026-99227](https://www.cve.org/CVERecord?id=CVE-2026-99227) | 7.8 | A local process uses io_uring waitid and cancels it until a 31-bit counter wraps. Present since 6.7. | 6.12.115, 6.18.60, 7.2.14, and 7.3.1. |
| [CVE-2026-99231](https://www.cve.org/CVERecord?id=CVE-2026-99231) | 7.8 | A local process uses io_uring waitid. The wake handler clears its wait head before it owns the request. | 6.12.115, 6.18.60, 7.2.14, and 7.3.2. |
| [CVE-2026-99233](https://www.cve.org/CVERecord?id=CVE-2026-99233) | 7.8 | A local user who can write tracefs histograms creates a synthetic event whose name matches another event. | 6.1.191, 6.6.161, 6.12.115, 6.18.60, 7.2.14, and 7.3.1. No 5.10 or 5.15 tag. |
| [CVE-2026-99235](https://www.cve.org/CVERecord?id=CVE-2026-99235) | 7.8 | A local user who can write tracefs histograms removes a compatible histogram while another still points at it. | 5.10.273, 5.15.224, 6.1.191, 6.6.161, 6.12.115, 6.18.60, 7.2.14, and 7.3.1. |
| [CVE-2026-99236](https://www.cve.org/CVERecord?id=CVE-2026-99236) | 7.8 | A local user sets a perf tracepoint filter that ends in a logical operator. The parser then reads before its program array. Signed by an OpenAI researcher. That trailer does not say the flaw came from OpenAI's November 4 kernel campaign. | 5.10.273, 5.15.224, 6.1.191, 6.6.161, 6.12.115, 6.18.60, 7.2.14, and 7.3.1. Mainline commit `1fdc4164e488`. |
| [CVE-2026-99237](https://www.cve.org/CVERecord?id=CVE-2026-99237) | 7.8 | A local user reads a last-boot tracing instance. Two readers can free the same module map. Present since 6.16. | 6.18.60, 7.2.14, and 7.3.1. |
| [CVE-2026-99238](https://www.cve.org/CVERecord?id=CVE-2026-99238) | 7.8 | A local user removes a tracing instance while a module loads or unloads. Present since 6.15. | 6.18.60, 7.2.14, and 7.3.1. |
| [CVE-2026-99269](https://www.cve.org/CVERecord?id=CVE-2026-99269) | 7.8 | A local user loads a sched_ext scheduler. The CNA says moving a task can race the dispatcher. Present since 7.1. | 7.2.14 and 7.3. |
| [CVE-2026-99218](https://www.cve.org/CVERecord?id=CVE-2026-99218) | 7.0 | A local process dumps core. The CNA says the dumper can wake a parked thread after it has been freed, and that the timing cannot be forced. | 6.1.191, 6.6.161, 6.12.115, 6.18.60, 7.2.14, and 7.3.1. No 5.10 or 5.15 tag. |
| [CVE-2026-99224](https://www.cve.org/CVERecord?id=CVE-2026-99224) | 7.0 | A local user describes a key whose type comes from a module, and a privileged unload races that description. The CNA says the caller cannot unload the module. | 5.10.273, 5.15.224, 6.1.191, 6.6.161, 6.12.115, 6.18.60, 7.2.14, and 7.3.1. |

The CNA's own scenario text says code execution is not established for these records. The scores still mark confidentiality and integrity High because the bugs are use-after-free or out-of-bounds reads in the kernel. Red Hat's page for CVE-2026-99270 says the demonstrated impact is a crash, and scores it 5.9 with only availability High. Amazon Linux uses that same 5.9 vector for CVE-2026-99270 and CVE-2026-99246. SUSE scores CVE-2026-99270 at 7.0 with a local vector. Those lower scores are the vendors' scores. They do not replace the CNA score.

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Records published | 2026-11-02 16:06 UTC and 2026-11-03 11:18–12:32 UTC | kernel.org CNA. Eleven records on November 2. CVE-2026-99246, CVE-2026-99269, and CVE-2026-99270 on November 3. |
| Upstream stable tags | 2026-11-02 and 2026-11-03; per-tag time not rechecked | The unaffected versions in the table above are the CNA's. A later tag contains an earlier fix. |
| Debian security kernels | 2026-11-13; DSA time not rechecked for each CVE | DSA-6628-1 fixes trixie `linux` at 6.12.117-1 and names CVE-2026-99270. The Debian tracker, read 2026-11-19, also marks bookworm security fixed for the local flaws that bookworm contains. |
| Amazon Linux partial fixes | 2026-11-12; time unknown | ALAS2KERNEL-5.10-2026-139 and ALAS2023-2026-3448 name CVE-2026-99246 and CVE-2026-99236. CVE-2026-99270 is still pending on every Amazon Linux kernel listed. |
| Ubuntu kernels | 2026-11-19; time/TZ unknown | USN-9165-1, USN-9166-1, USN-9167-1, and USN-9173-1. They do not list CVE-2026-99270. |
| **Last updated** | **2026-11-20 (America/New_York)** | Ubuntu has packages for part of the set. CVE-2026-99270 is still open there. |

## Detection

1. Record the running kernel with `uname -r`. An installed package that is not the booted kernel is not the fix.
2. Match that build to a vendor advisory that names the CVE you care about. The upstream version floors above are not a verdict for a distribution kernel.
3. Decide which rows can fire:
   - `sysctl net.ipv4.tcp_migrate_req` prints the migration switch for CVE-2026-99270. `0` is the default. A reuseport BPF program can migrate sockets even when the sysctl is 0. The CNA says the bug also needs the listener to stop listening while a request socket is live.
   - `lsmod | grep '^tipc '` shows whether TIPC is loaded now. It does not show whether an administrator will load it later. CVE-2026-99246 also needs the node-reset tracepoint enabled.
   - io_uring, Bluetooth, tracefs write access, and a loaded sched_ext scheduler are the local prerequisites in the table. Missing one means that row's path is not present. It does not clear the other rows.
4. A scanner that only knows CVE-2026-99288 does not cover this set. A kernel changelog that names one of these CVEs does not prove the other twelve are present.

No public proof of concept was found for these thirteen records. Do not send packets or run a reproducer to test them.

## Remediation

Install a distribution kernel that names the CVE and reboot into it. Installing the package does not fix a running host. Do not copy an upstream commit into a production kernel.

| Distribution | Status checked 2026-11-20 | What to install |
|---|---|---|
| Debian | trixie security `linux` 6.12.117-1 is fixed for the rows the tracker lists, including CVE-2026-99270 (DSA-6628-1). bookworm security 6.1.192-2 is fixed for CVE-2026-99246, CVE-2026-99239, CVE-2026-99236, and the other local rows bookworm contains. bookworm security is still vulnerable for CVE-2026-99270. forky 7.3.4-1 and sid 7.3.5-1 are fixed. CVE-2026-99227 and CVE-2026-99269 do not affect bookworm's 6.1 kernel. CVE-2026-99237 and CVE-2026-99238 do not affect bookworm or the trixie base the tracker marks fixed. | The security kernel for the release you boot, then reboot. |
| Ubuntu | USN-9165-1, USN-9166-1, USN-9167-1, and USN-9173-1, all 2026-11-19, ship generic kernels for several of the thirteen: 22.04 `5.15.0-204.214`, 24.04 `6.8.0-151.151`, 26.04 `7.0.0-44.44`, and 26.10 `7.3.0-11.12`. Those notices do not list CVE-2026-99270 or CVE-2026-99239. Ubuntu's page for CVE-2026-99270, updated 2026-11-18, now rates it High and still marks 16.04 through 26.04 Vulnerable with no package. 26.10 is Not affected for that one. | Install the USN kernel for the release you boot and reboot. That does not close CVE-2026-99270. |
| Red Hat | CVE-2026-99270: RHEL 8, 9, and 10 `kernel` Affected, and RHEL 8 and 9 `kernel-rt` Affected. No `affected_release`. Red Hat scores it CVSS 3.1 5.9, availability only, and says the CNA's High/High/High impact is not what it has demonstrated. CVE-2026-99246: the same RHEL 8, 9, and 10 kernel rows are Affected, with no erratum. Red Hat scores that one 8.1 and says TIPC is not loaded by default. | No erratum yet. Do not load TIPC, and leave `tcp_migrate_req` at 0 unless you need it. Neither is a fix. |
| SUSE | CVE-2026-99270: SLES 15 SP7 `kernel-default` Affected. SLES 16.1 `kernel-default` Affected. Real Time 15 SP7 `kernel-source-rt` Affected. SLES 12 SP5-LTSS and SLES 16.0 are Not affected. SUSE scores it 7.0, local, not the CNA's 8.1. | No released package found for the Affected products. |
| Amazon Linux | CVE-2026-99270 is Pending Fix on Amazon Linux 2 core, the 5.4, 5.10, and 5.15 extras, and Amazon Linux 2023 `kernel`, `kernel6.12`, and `kernel6.18`. Amazon scores it 5.9. CVE-2026-99246 is fixed on the Amazon Linux 2 5.10 extra (ALAS2KERNEL-5.10-2026-139, 2026-11-12) and on Amazon Linux 2023 `kernel6.12` (ALAS2023-2026-3448, 2026-11-12). Amazon Linux 2 core is Not Affected for that one. CVE-2026-99236 has those same two fixed advisories, plus the Amazon Linux 2 5.15 extra (ALAS2KERNEL-5.15-2026-121, 2026-11-12). Amazon Linux 2023's default `kernel` is still Pending Fix for both. | Install the ALAS package only for the flavor it names, then reboot. A fixed `kernel6.12` does not fix the default 6.1 kernel. |
| AlmaLinux, Rocky Linux, Oracle Linux | No erratum naming these thirteen CVEs was found. Do not assume a RHEL rebuild has a fix Red Hat has not published. | Unknown until the rebuild publishes it. |

The CNA unaffected lines are the upstream floors, not a distribution package. A host on 5.10, 5.15, 6.1, or 6.6 has no upstream stable tag for CVE-2026-99270. Debian's bookworm fix for some of the other rows does not fill that gap.

## Verification

- After reboot, `uname -r` matches the build named in the advisory for the CVE you patched.
- `sysctl net.ipv4.tcp_migrate_req` is still 0 if you set that as a temporary reduction and you do not use reuseport migration.
- `lsmod` does not list `tipc` if TIPC is not required.
- Ordinary TCP listeners, Bluetooth, and tracing still do what you need them to do. Do not use a proof of concept as the check.

## Compromise response

No compromise indicators were published for these thirteen records. A kernel oops that names `reqsk_timer_handler`, `tipc_link_dump`, `predicate_parse`, or `io_waitid` is a reason to keep the crash dump, not proof of an attack. If a host that met the network prerequisites crashed during the exposure window, preserve the dump and treat a later unexplained root process as a separate incident. Rebooting into a fixed kernel does not remove persistence.

## Sources

- kernel.org CNA records, published 2026-11-02 and 2026-11-03: [CVE-2026-99270](https://www.cve.org/CVERecord?id=CVE-2026-99270), [CVE-2026-99246](https://www.cve.org/CVERecord?id=CVE-2026-99246), [CVE-2026-99239](https://www.cve.org/CVERecord?id=CVE-2026-99239), [CVE-2026-99227](https://www.cve.org/CVERecord?id=CVE-2026-99227), [CVE-2026-99231](https://www.cve.org/CVERecord?id=CVE-2026-99231), [CVE-2026-99233](https://www.cve.org/CVERecord?id=CVE-2026-99233), [CVE-2026-99235](https://www.cve.org/CVERecord?id=CVE-2026-99235), [CVE-2026-99236](https://www.cve.org/CVERecord?id=CVE-2026-99236), [CVE-2026-99237](https://www.cve.org/CVERecord?id=CVE-2026-99237), [CVE-2026-99238](https://www.cve.org/CVERecord?id=CVE-2026-99238), [CVE-2026-99269](https://www.cve.org/CVERecord?id=CVE-2026-99269), [CVE-2026-99218](https://www.cve.org/CVERecord?id=CVE-2026-99218), [CVE-2026-99224](https://www.cve.org/CVERecord?id=CVE-2026-99224). Scores, prerequisites, and unaffected version lines are taken from those records.
- [Debian tracker CVE-2026-99270](https://security-tracker.debian.org/tracker/CVE-2026-99270) and [DSA-6628-1](https://www.debian.org/security/dsa-6628-1). The other Debian rows were read from the same tracker on 2026-11-19.
- [Ubuntu CVE-2026-99270](https://ubuntu.com/security/CVE-2026-99270), [Ubuntu CVE-2026-99246](https://ubuntu.com/security/CVE-2026-99246), and [Ubuntu CVE-2026-99236](https://ubuntu.com/security/CVE-2026-99236).
- [Red Hat CVE-2026-99270](https://access.redhat.com/security/cve/CVE-2026-99270) and [Red Hat CVE-2026-99246](https://access.redhat.com/security/cve/CVE-2026-99246). Package state from the Red Hat security-data API.
- [SUSE CVE-2026-99270](https://www.suse.com/security/cve/CVE-2026-99270.html).
- [Amazon Linux CVE-2026-99270](https://explore.alas.aws.amazon.com/CVE-2026-99270.html), [CVE-2026-99246](https://explore.alas.aws.amazon.com/CVE-2026-99246.html), and [CVE-2026-99236](https://explore.alas.aws.amazon.com/CVE-2026-99236.html).
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json), catalog 2026.11.18, checked 2026-11-19.
