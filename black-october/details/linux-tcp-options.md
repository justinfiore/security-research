# Linux kernel: IPv4 TCP options use-after-free

**Last updated:** 2026-10-30 (America/New_York)

[Main Linux kernel summary](../black-october-2026.md#linux-kernel-ipv4-tcp-options-use-after-free) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-98432](https://www.cve.org/CVERecord?id=CVE-2026-98432) — kernel.org CVSS 3.1 9.8 Critical** is an IPv4 TCP race that can free socket options while they remain in use. kernel.org describes fixes in upstream and stable commits. Red Hat rates its product impact 8.1 High because it assesses network attack complexity as High; Red Hat and Ubuntu both list affected supported products without a released fix at this review.

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). No primary source reviewed reports in-the-wild exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| CVE publication | 2026-10-15; time/TZ unknown | kernel.org CNA record published CVE-2026-98432. [CVE record][cve] |
| Record update | 2026-10-24; time/TZ unknown | The CNA record lists upstream and stable fixed commits. [CVE record][cve] |
| Vendor status reviewed | 2026-10-30; time/TZ unknown | Red Hat and Ubuntu list affected products; Ubuntu shows work in progress for supported LTS kernels. [Red Hat][redhat] [Ubuntu][ubuntu] |

## Detection

1. Inventory running Linux kernels and IPv4-facing TCP services; record the distributor package build rather than inferring status from the upstream version alone.
2. Check the distributor advisory for the exact installed kernel. The CNA record identifies affected ranges by commits, but distributors can backport fixes without changing the upstream version string.
3. Prioritize systems accepting untrusted IPv4 TCP connections. The CNA record describes races around retransmitted SYN processing and request-socket migration; package presence alone does not establish exploitation.

## Remediation

1. Install the distributor kernel package explicitly marked as fixing CVE-2026-98432, then reboot into it. Do not build an arbitrary upstream commit into a production distribution kernel in place of a supported update.
2. At this review, Ubuntu lists supported 22.04, 24.04, 26.04 and 26.10 generic kernels as vulnerable with fixes in progress; Red Hat lists no supported mitigation. Track vendor advisories for release status.
3. Reduce unnecessary exposure of TCP services to untrusted networks while awaiting a supported package. This reduces opportunity but is not a proven workaround.

## Verification

- After a vendor update, confirm the booted package is the vendor-fixed build and that required TCP services function normally.
- Do not generate timing-sensitive malformed TCP traffic against production systems to test this vulnerability.

## Compromise response

The reviewed primary sources do not provide compromise indicators. Preserve kernel, crash and network telemetry if a suspected incident occurred, investigate adjacent service activity, and rebuild or rotate affected application credentials where host integrity cannot be established.

## Sources

- [kernel.org CNA CVE record][cve] — vulnerability mechanics, score and fixed commit ranges.
- [Red Hat advisory][redhat] — product-specific 8.1 High assessment and no qualifying mitigation.
- [Ubuntu advisory][ubuntu] — supported-release status.
- [CISA KEV JSON feed][kev] — catalog status.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-98432
[redhat]: https://access.redhat.com/security/cve/CVE-2026-98432
[ubuntu]: https://ubuntu.com/security/CVE-2026-98432
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
