# Apache HTTP Server: an HTTP/2 request can run code

**Last updated:** 2026-11-13 (America/New_York)

[Main Apache HTTP Server summary](../black-october-2026.md#apache-http-server-an-http2-request-can-run-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Apache rates [CVE-2026-119618](https://www.cve.org/CVERecord?id=CVE-2026-119618) critical and publishes no numeric score.** A race in `mod_http2`'s `assign_headers()` corrupts heap memory and can run code. Red Hat rates the same flaw **CVSS 3.1 9.8 Critical** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`) and says a remote attacker with no account can run commands as the server process. NVD had not scored it on November 12. The Apache advisory says it affects **2.4.55 through 2.4.70**, and standalone `mod_h2` releases **2.0.8 through 2.0.42**. Red Hat says only a server with HTTP/2 turned on (`h2` or `h2c` in the `Protocols` directive) is affected. A server that serves only HTTP/1.1 is not.

The same release, **2.4.71**, fixes two more flaws. Apache rates [CVE-2026-106023](https://www.cve.org/CVERecord?id=CVE-2026-106023) important: a NULL pointer dereference in `mod_md` crashes a child process, affecting **2.4.30 through 2.4.70**. The CVE record says through **2.4.69**. The [changelog][changes] and the [advisory][adv] both say through 2.4.70, so 2.4.70 is in scope. Apache rates [CVE-2026-109163](https://www.cve.org/CVERecord?id=CVE-2026-109163) low: a one-byte stack overwrite in `mod_vhost_alias` on **2.4.69 and 2.4.70**. The CVE record names only 2.4.69. The changelog names both. Neither has a numeric score from Apache.

Red Hat's own `mod_http2` on Enterprise Linux 9 and 10 gives each HTTP/2 stream its own allocator, and Red Hat rates those products **Important** rather than Critical for that reason. Its overall score stays 9.8. It says versions of `mod_http2` before 2.0.8 do not contain the code, and **Enterprise Linux 8, 7, and 6 are not affected**.

Red Hat's statement says public research has demonstrated a reliable exploit against a default-configured server with `mod_http2` enabled, and it does not name or link that research. Wiz, writing the same day, says no exploit is available and no exploitation in the wild has been reported. Those two statements disagree. This guide does not treat either as a confirmed in-the-wild compromise.

The GitHub `mod_h2` repository was archived on June 9 and its release list ends at 2.0.42, the last affected version. A server built against that standalone module has no newer release to install. The Apache HTTP Server 2.4.71 tree contains the fix.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-13) for any of the three. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to Apache (Anthropic) | 2026-10-26; time unknown | OSS Scanner, ANT-2026-MAPKT6MZ. [Advisory][adv] |
| Reported to Apache (Google) | 2026-11-03; time unknown | Anthony Weems and Simon Scannell, Google Cloud Vulnerability Research. [Advisory][adv] |
| **Public announcement and fix** | **2026-11-11 14:54:08 UTC** | CVE-2026-119618 published. Apache HTTP Server **2.4.71** released the same day. [CVE][cve] [Advisory][adv] |
| Red Hat packages | 2026-11-11; time/TZ unknown | Seven `mod_http2` errata for Enterprise Linux 9 and 10 and their extended channels. [Red Hat][rh] |
| Debian trixie package | 2026-11-12 09:54:11 UTC | DSA-6620-1, `apache2` 2.4.71-1~deb13u1. [DSA-6620-1][dsa] |
| Debian bookworm package | 2026-11-12 20:52:26 UTC | DLA-4902-1, `apache2` 2.4.71-1~deb12u1. Forky still has no fixed package. [DLA-4902-1][dla] |
| Ubuntu packages | 2026-11-12; time/TZ unknown | USN-9090-1. Fixed `apache2` on 22.04, 24.04, 26.04, and 26.10, and on 20.04 through Ubuntu Pro. [USN-9090-1][usn] |
| Amazon Linux packages | 2026-11-12; time/TZ unknown | ALAS2-2026-4114 and ALAS2023-2026-3458. Both ship `httpd` 2.4.71. [AL2][alas2] [AL2023][alas2023] |
| CISA KEV | Not listed (catalog 2026.11.10, checked 2026-11-13) | [KEV][kev] |
| **Last updated** | **2026-11-13 (America/New_York)** | Bookworm, Ubuntu, and Amazon Linux have fixed packages. |

## Detection

This only reads the version the package manager reports. It does not send a request.

```sh
apachectl -v 2>/dev/null || httpd -v
```

A build from **2.4.55 through 2.4.70** is inside CVE-2026-119618. **2.4.71 or later** is outside it. A build before 2.4.55 is outside this flaw and may be inside older ones this guide does not cover.

The version string is not the whole answer. Red Hat says the flaw needs HTTP/2. On a server you administer, read the `Protocols` directive in the server config and in each virtual host:

```sh
httpd -t -D DUMP_RUN_CFG 2>/dev/null | grep -i Protocols || apachectl -t -D DUMP_RUN_CFG 2>/dev/null | grep -i Protocols
```

`h2` or `h2c` in that output means HTTP/2 is on. No `Protocols` line does not mean HTTP/2 is off: the packaged default differs by distribution, and a virtual host can set its own. A version inside the range is the fact a version check can establish.

A distribution package does not use the upstream version number. On Red Hat Enterprise Linux the package is `mod_http2`, not `httpd`. Compare it with the table below.

| Product | Fixed package | Source |
|---|---|---|
| Apache HTTP Server project | 2.4.71 | [Advisory][adv] |
| RHEL 9 | `mod_http2-2.0.26-7.el9_9.1` | [RHSA-2026:98981](https://access.redhat.com/errata/RHSA-2026:98981) |
| RHEL 9.8 Extended Update Support | `mod_http2-2.0.26-6.el9_8.3` | [RHSA-2026:98982](https://access.redhat.com/errata/RHSA-2026:98982) |
| RHEL 9.6 Extended Update Support | `mod_http2-2.0.26-4.el9_6.3` | [RHSA-2026:98954](https://access.redhat.com/errata/RHSA-2026:98954) |
| RHEL 9.4 Update Services for SAP Solutions | `mod_http2-2.0.26-2.el9_4.4` | [RHSA-2026:98968](https://access.redhat.com/errata/RHSA-2026:98968) |
| RHEL 10 | `mod_http2-2.0.29-5.el10_3.1` | [RHSA-2026:98978](https://access.redhat.com/errata/RHSA-2026:98978) |
| RHEL 10.2 Extended Update Support | `mod_http2-2.0.29-4.el10_2.3` | [RHSA-2026:98979](https://access.redhat.com/errata/RHSA-2026:98979) |
| RHEL 10.0 Extended Update Support | `mod_http2-2.0.29-2.el10_0.3` | [RHSA-2026:98953](https://access.redhat.com/errata/RHSA-2026:98953) |
| RHEL 8, 7, and 6 | Not affected | [Red Hat][rh] |
| Debian sid | `apache2` 2.4.71-1, fixed | [Debian][deb] |
| Debian trixie (security) | `apache2` 2.4.71-1~deb13u1, fixed | [DSA-6620-1][dsa] |
| Debian trixie, the release pocket | `2.4.68-1~deb13u1`, still vulnerable | [Debian][deb] |
| Debian bookworm (security) | `apache2` 2.4.71-1~deb12u1, fixed | [DLA-4902-1][dla] |
| Debian forky | `2.4.69-1`, vulnerable, no fixed package | [Debian][deb] |
| Ubuntu 26.10 | `apache2` 2.4.68-1ubuntu6.2 | [USN-9090-1][usn] |
| Ubuntu 26.04 LTS | `apache2` 2.4.66-2ubuntu2.8 | [USN-9090-1][usn] |
| Ubuntu 24.04 LTS | `apache2` 2.4.58-1ubuntu8.19 | [USN-9090-1][usn] |
| Ubuntu 22.04 LTS | `apache2` 2.4.52-1ubuntu4.27 | [USN-9090-1][usn] |
| Ubuntu 20.04 LTS | `apache2` 2.4.41-4ubuntu3.23+esm11, Ubuntu Pro | [USN-9090-1][usn] |
| Amazon Linux 2 | `httpd` 2.4.71-1.amzn2.0.1 | [ALAS2-2026-4114][alas2] |
| Amazon Linux 2023 | `httpd` 2.4.71-1.amzn2023.0.1 | [ALAS2023-2026-3458][alas2023] |

Red Hat lists **JBoss Core Services** (`jbcs-httpd24-mod_http2`) and **Red Hat Hardened Images** (`httpd`) as Affected, with no released package. Forky is still `2.4.69-1`, inside the range. Trixie's release pocket is still `2.4.68-1~deb13u1`; the security pocket is the fixed one. SUSE lists current SLES 12 SP5, 15 SP4 through SP7, 16.0, and 16.1 as affected, with no fixed package. AlmaLinux, Rocky Linux, and Oracle Linux had no released erratum for this CVE on November 13.

## Remediation

1. Upgrade the Apache HTTP Server project's own build to **2.4.71 or later**, or install the `mod_http2` package in the table for the Red Hat release you run. Restart `httpd` or `apache2`. A running process keeps the module it loaded.
2. On Debian bookworm, install `apache2` **2.4.71-1~deb12u1** or later. On Debian trixie, install **2.4.71-1~deb13u1** or later from the security pocket. On Debian sid, install **2.4.71-1** or later. Forky has no fixed package yet. On Ubuntu, install the `apache2` build in the table. On Amazon Linux, install `httpd` **2.4.71-1.amzn2.0.1** or **2.4.71-1.amzn2023.0.1**. SUSE has no fixed package yet. Until one ships, take HTTP/2 off.
3. Until the package is in, remove `h2` and `h2c` from every `Protocols` line and leave `http/1.1`. Wiz describes that step. Apache's advisory names no workaround. Turning HTTP/2 off is not a substitute for the upgrade, and it does not fix CVE-2026-106023, which is in `mod_md` and does not need HTTP/2.
4. A server built from the archived GitHub `mod_h2` has no release after 2.0.42. Rebuild it from the 2.4.71 tree, or turn HTTP/2 off.
5. Red Hat Enterprise Linux 8 and earlier do not contain this code. Do not treat a scanner finding there as this flaw without checking the package.
6. The upgrade does not show whether a request already ran code.

## Verification

- `apachectl -v` or the package manager reports **2.4.71** or later, or the `mod_http2` package is at or above the row in the table, and the service was restarted after the install.
- A site the server already serves still answers over HTTP/1.1. Do not send a request built to trigger the race.

## Compromise response

Neither Apache nor Red Hat publishes an indicator. If a server inside the affected range had HTTP/2 reachable from the internet before the upgrade, treat the account the server runs as possibly compromised.

- Preserve the access and error logs from before the upgrade. The advisory does not say the race leaves a log line.
- Rotate credentials that process could read, including TLS private keys and application secrets on that host.
- The upgrade does not remove a payload that already ran.

## Sources

- [Apache HTTP Server 2.4 vulnerabilities][adv] — read 2026-11-12. 2.4.71 released 2026-11-11: CVE-2026-119618 critical, CVE-2026-106023 important, CVE-2026-109163 low. Affected ranges and report dates.
- [CHANGES_2.4][changes] — the 2.4.71 section. Same three flaws. CVE-2026-106023 through 2.4.70, and CVE-2026-109163 on 2.4.69 and 2.4.70, which is wider than each CVE record.
- [CVE-2026-119618][cve] — Apache CNA, published 2026-11-11 14:54:08 UTC. Severity text "critical". No numeric score. Affects 2.4.55 through 2.4.70.
- [Red Hat CVE-2026-119618][rh] — CVSS 3.1 9.8, status verified. Critical overall, Important on RHEL 9 and 10 because of the per-stream allocator. RHEL 8 and earlier not affected. States that public research demonstrated a reliable exploit and does not link it.
- [Red Hat CVE JSON][rhjson] — the seven fixed `mod_http2` releases, all dated 2026-11-11, and the two Affected products with no package.
- [Debian security tracker][deb] — read 2026-11-13. sid fixed at `2.4.71-1`. trixie (security) fixed at `2.4.71-1~deb13u1`. bookworm (security) fixed at `2.4.71-1~deb12u1`. The trixie release pocket and forky are still vulnerable.
- [DSA-6620-1][dsa] — Salvatore Bonaccorso, 2026-11-12 09:54:11 UTC. Fixes CVE-2026-119618, CVE-2026-106023, and CVE-2026-109163 in trixie.
- [DLA-4902-1][dla] — Sylvain Beucler, 2026-11-12 20:52:26 UTC. Fixes the same three in bookworm at `apache2` 2.4.71-1~deb12u1.
- [USN-9090-1][usn] — published 2026-11-12. Fixes CVE-2026-119618 and CVE-2026-106023 on Ubuntu 20.04 LTS through 26.10. The 20.04 build is Ubuntu Pro.
- [ALAS2-2026-4114][alas2] and [ALAS2023-2026-3458][alas2023] — both released 2026-11-12, severity Critical. Amazon Linux 2 fixes all three CVEs. Amazon Linux 2023 lists CVE-2026-119618 and CVE-2026-109163 and does not list CVE-2026-106023.
- [SUSE CVE-2026-119618][suse] — read 2026-11-13. Current SLES releases are affected, with no fixed package.
- [Wiz][wiz] — November 11. Says no exploit is available and no in-the-wild exploitation has been reported. Recommends `Protocols http/1.1` until the upgrade. Its standalone `mod_h2` fixed version does not match the Apache advisory; follow Apache.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-13. None of the three is listed.

[adv]: https://httpd.apache.org/security/vulnerabilities_24.html
[changes]: https://downloads.apache.org/httpd/CHANGES_2.4
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-119618
[rh]: https://access.redhat.com/security/cve/cve-2026-119618
[rhjson]: https://access.redhat.com/hydra/rest/securitydata/cve/CVE-2026-119618.json
[deb]: https://security-tracker.debian.org/tracker/CVE-2026-119618
[dsa]: https://www.debian.org/security/2026/dsa-6620
[dla]: https://www.debian.org/lts/security/2026/dla-4902-1
[usn]: https://ubuntu.com/security/notices/USN-9090-1
[alas2]: https://alas.aws.amazon.com/AL2/ALAS2-2026-4114.html
[alas2023]: https://alas.aws.amazon.com/AL2023/ALAS2023-2026-3458.html
[suse]: https://www.suse.com/security/cve/CVE-2026-119618.html
[ubu]: https://ubuntu.com/security/CVE-2026-119618
[wiz]: https://www.wiz.io/blog/cve-2026-119618-rce-apache-http-server-vulnerability
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
