# libslirp: ICMP error quoting reads past the packet

**Last updated:** 2026-11-02 (America/New_York)

[Main libslirp summary](../black-october-2026.md#libslirp-icmp-error-quoting-reads-past-the-packet) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-120830](https://www.cve.org/CVERecord?id=CVE-2026-120830): Red Hat (CNA) CVSS 3.1 7.4 High (CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:C/C:H/I:N/A:N). NVD has not scored it.** `icmp_forward_error()` copied the quoted IPv4 packet using the length in the IP header and did not clamp it to the buffer it actually held. A truncated packet makes that an out-of-bounds heap read. The bytes come back inside the ICMP error returned to the guest or container. Red Hat's vector is adjacent network, not remote over the internet. Red Hat says RHEL 8, 9, and 10, and OpenShift Container Platform 4 and 5, are affected, and that it has no workaround. The CNA record names no fixed package. [CVE][cve] [Red Hat][rh]

Upstream fixed it in **libslirp 4.9.7**, released 2026-10-30. The changelog line is "icmp_forward_error: Fix Out-of-Bounds Heap Read & Information Disclosure." The CVE record was published 2026-11-03 and points at the commit. Debian's tracker now lists the CVE. bookworm 4.7.0-1, trixie 4.8.0-1+deb13u1, and forky and sid 4.9.5-1 are vulnerable, and no fixed Debian package is published. The same tracker lists a second flaw, CVE-2026-120831, as vulnerable on all four, with no fixed package. Ubuntu's newest package found was 4.9.3. Red Hat's bug is still open with no fixed version. [Changelog][log] [Commit][commit]

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03). Red Hat does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Upstream fix | 2026-10-30 02:22 +0100 | Tag v4.9.7. Commit `21b33a6`. [Changelog][log] [Tag][tag] |
| CVE published | 2026-11-03; time/TZ unknown | Red Hat CNA, CVSS 3.1 7.4. No fixed Red Hat package named. [CVE][cve] |

## Detection

1. Read the libslirp version linked into QEMU, rootless Podman, or any other user-mode network stack. `pkg-config --modversion slirp`, or the package manager: `dpkg -l libslirp0`, `rpm -q libslirp`. **4.9.7 or later** contains the upstream fix. A distribution package can carry the commit under an older version number. Trust a package changelog that names CVE-2026-120830 over the version alone.
2. The reach is a guest or container that can send a truncated IPv4 packet through slirp. It is not a remote internet service.
3. Red Hat's page says no errata was available when the CVE was published. "All versions are affected" on that page means no Red Hat build was fixed yet, not that 4.9.7 is vulnerable.

## Remediation

1. Install **libslirp 4.9.7 or later**, or a distribution package whose changelog names CVE-2026-120830. Restart the QEMU or Podman processes that had the library loaded.
2. Until then, Red Hat says it has no workaround that meets its bar. Do not treat a firewall rule on the host as a fix for traffic a guest sends into slirp.

## Verification

- The loaded library is 4.9.7 or later, or the package changelog names the CVE.
- A guest still gets an address and can ping its gateway. Do not send a truncated packet to test this.

## Compromise response

The flaw leaks host memory into a packet the guest receives. It does not, on the CNA's description, write memory or run code.

- A guest or container that was not trusted, and that used slirp before the update, may have received bytes from the host process heap. What those bytes were is not something the log will show.
- Rotate credentials that lived in the memory of the process doing user-mode networking if that guest was untrusted.

## Sources

- [CVE-2026-120830][cve] — Red Hat CNA, CVSS 3.1 7.4, published 2026-11-03.
- [Red Hat CVE page][rh] — no workaround; score marked preliminary.
- [libslirp changelog][log] — 4.9.7, 2026-10-30, names the ICMP fix.
- [Commit 21b33a6][commit] — the change the CNA cites.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30, not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-120830
[rh]: https://access.redhat.com/security/cve/CVE-2026-120830
[log]: https://gitlab.freedesktop.org/slirp/libslirp/-/blob/master/CHANGELOG.md
[tag]: https://gitlab.freedesktop.org/slirp/libslirp/-/tags/v4.9.7
[commit]: https://gitlab.freedesktop.org/slirp/libslirp/-/commit/21b33a6c5588af9f58d15e528fdc1019452708e4
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
