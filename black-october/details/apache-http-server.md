# Apache HTTP Server: an HTTP/2 request can run code

**Last updated:** 2026-11-22 (America/New_York)

[Main Apache HTTP Server summary](../black-october-2026.md#apache-http-server-an-http2-request-can-run-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Apache rates [CVE-2026-119618](https://www.cve.org/CVERecord?id=CVE-2026-119618) critical and publishes no numeric score.** A race in `mod_http2`'s `assign_headers()` corrupts heap memory and can run code. Red Hat rates the same flaw **CVSS 3.1 9.8 Critical** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`) and says a remote attacker with no account can run commands as the server process. NVD had not scored it on November 12. The Apache advisory says it affects **2.4.55 through 2.4.70**, and standalone `mod_h2` releases **2.0.8 through 2.0.42**. Red Hat says only a server with HTTP/2 turned on (`h2` or `h2c` in the `Protocols` directive) is affected. A server that serves only HTTP/1.1 is not.

The same release, **2.4.71**, fixes two more flaws. Apache rates [CVE-2026-106023](https://www.cve.org/CVERecord?id=CVE-2026-106023) important: a NULL pointer dereference in `mod_md` crashes a child process, affecting **2.4.30 through 2.4.70**. The CVE record says through **2.4.69**. The [changelog][changes] and the [advisory][adv] both say through 2.4.70, so 2.4.70 is in scope. Apache rates [CVE-2026-109163](https://www.cve.org/CVERecord?id=CVE-2026-109163) low: a one-byte stack overwrite in `mod_vhost_alias` on **2.4.69 and 2.4.70**. The CVE record names only 2.4.69. The changelog names both. Neither has a numeric score from Apache.

Red Hat's own `mod_http2` on Enterprise Linux 9 and 10 gives each HTTP/2 stream its own allocator, and Red Hat rates those products **Important** rather than Critical for that reason. Its overall score stays 9.8. It says versions of `mod_http2` before 2.0.8 do not contain the code, and **Enterprise Linux 8, 7, and 6 are not affected**.

Red Hat's statement says public research has demonstrated a reliable exploit against a default-configured server with `mod_http2` enabled, and it does not name or link that research. Wiz, writing the same day, says no exploit is available and no exploitation in the wild has been reported. Those two statements disagree.

On November 19 Broadcom published [VMSA-2026-0010](https://support.broadcom.com/web/ecx/support-content-notification/-/external/content/SecurityAdvisories/0/39625) and rated this same flaw **CVSS 3.1 9.8 Critical** in three of its products. A request with network access to VMware Aria Operations or VCF Operations HCX can run code. The affected lines are VMware Cloud Foundation Operations 9.x, VMware Aria Operations 8.18.x, VMware Aria Operations on Cloud Foundation 5.x, and VCF Operations HCX 9.1.x. Every row says **patch pending**. The workaround is to turn HTTP/2 off: [KB463005](https://knowledge.broadcom.com/external/article/463005) for Operations and [KB463022](https://knowledge.broadcom.com/external/article/463022) for HCX. KB463005 says each node runs Apache 2.4.68, that the scripted workaround does not touch collectors, agents, or the API, and that an upgrade replaces the configuration and turns HTTP/2 back on. Google Cloud bulletin GCP-2026-086, the same day, repeats the advisory and names no Google-built fix. This is not [VMSA-2026-0009](vcenter.md), the vCenter authentication bypass.

On November 17 Singapore's Cyber Security Agency published [AL-2026-164](https://www.csa.gov.sg/alerts-and-advisories/alerts/al-2026-164/) and said attackers are exploiting the flaw to run code. It scores the flaw CVSS 3.1 8.1, lower than Red Hat's 9.8, and it says a public proof of concept exists. It names no victim and no scale. CISA has not added the CVE. The alert is a report of exploitation, and it is not a list of indicators.

The GitHub `mod_h2` repository was archived on June 9 and its release list ends at 2.0.42, the last affected version. A server built against that standalone module has no newer release to install. The Apache HTTP Server 2.4.71 tree contains the fix.

**CISA KEV:** Not listed (catalog 2026.11.17, checked 2026-11-18) for any of the three. Singapore's Cyber Security Agency said on November 17 that attackers are exploiting CVE-2026-119618. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| CISA KEV | Not listed (catalog 2026.11.17, checked 2026-11-18) | [KEV][kev] |
| Singapore CSA alert | 2026-11-17; time unknown | Says attackers are exploiting CVE-2026-119618. Scores it 8.1. Names no victim. [AL-2026-164][csa] |
| SUSE, Debian testing, Oracle | 2026-11-18 and 2026-11-16 | SUSE-SU-2026:24742-1 names SLES 16.1. Debian forky is fixed at 2.4.71-1. Oracle Linux 9 has ELSA-2026-98981 for `mod_http2`. |
| VMware Aria Operations and HCX | 2026-11-19; time/TZ unknown | VMSA-2026-0010. Patch pending on Operations 9.x and 8.18.x, Cloud Foundation 5.x, and HCX 9.1.x. [VMSA][vmsa] |
| **Last updated** | **2026-11-20 (America/New_York)** | VMware products that bundle Apache have no patch. |

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
| Debian forky | `2.4.71-1`, fixed | [Debian][deb] |
| Ubuntu 26.10 | `apache2` 2.4.68-1ubuntu6.2 | [USN-9090-1][usn] |
| Ubuntu 26.04 LTS | `apache2` 2.4.66-2ubuntu2.8 | [USN-9090-1][usn] |
| Ubuntu 24.04 LTS | `apache2` 2.4.58-1ubuntu8.19 | [USN-9090-1][usn] |
| Ubuntu 22.04 LTS | `apache2` 2.4.52-1ubuntu4.27 | [USN-9090-1][usn] |
| Ubuntu 20.04 LTS | `apache2` 2.4.41-4ubuntu3.23+esm11, Ubuntu Pro | [USN-9090-1][usn] |
| Amazon Linux 2 | `httpd` 2.4.71-1.amzn2.0.1 | [ALAS2-2026-4114][alas2] |
| Amazon Linux 2023 | `httpd` 2.4.71-1.amzn2023.0.1 | [ALAS2023-2026-3458][alas2023] |
| SLES 15 SP7 | `apache2` 2.4.71-150700.4.30.1 | [SUSE-SU-2026:5231-1][suse] |
| SLES 16.0 | `apache2` 2.4.71-160000.1.1 | [SUSE][suse] |
| SLES 15 SP4, SP5, and SP6 LTSS, and 12 SP5 LTSS | `apache2` 2.4.66 builds, released | [SUSE][suse] |

Red Hat's [RHSA-2026:100550](https://access.redhat.com/errata/RHSA-2026:100550), issued 2026-11-17, fixes **JBoss Core Services** on RHEL 8 (`jbcs-httpd24-mod_http2-2.0.29-16.el8jbcs`). [RHSA-2026:100552](https://access.redhat.com/errata/RHSA-2026:100552), the same day, is the text-only JBoss Core Services 2.4.62 SP7 advisory. **Red Hat Hardened Images** (`httpd`) is now Not affected. Trixie's release pocket is still `2.4.68-1~deb13u1`; the security pocket is the fixed one. SUSE's page, last modified 2026-11-16, marks SLES 15 SP7 and SLES 16.0 Released. SUSE-SU-2026:24742-1, mailed 2026-11-18, names `apache2-2.4.71-160100.1.1` for SLES 16.1 and lists this CVE. SUSE's CVE page, last modified 2026-11-16, still marks 16.1 Affected. openSUSE Leap 16.0 and 16.1 are still Affected. Rocky Linux published [RLSA-2026:98981](https://errata.rockylinux.org/RLSA-2026:98981) on November 13 (`mod_http2-2.0.26-7.el9_9.1` on Rocky 9) and [RLSA-2026:98978](https://errata.rockylinux.org/RLSA-2026:98978) the same day (`mod_http2-2.0.29-5.el10_3.1` on Rocky 10). AlmaLinux published [ALSA-2026:98981](https://errata.almalinux.org/9/ALSA-2026-98981.html) and [ALSA-2026:98978](https://errata.almalinux.org/10/ALSA-2026-98978.html) on November 16, with the same package versions. Oracle Linux 9 has ELSA-2026-98981, released 2026-11-18, for `mod_http2`. No other Oracle Linux version is listed. Debian's tracker now marks forky fixed at `2.4.71-1`, migrated to testing on 2026-11-16.

## Remediation

1. Upgrade the Apache HTTP Server project's own build to **2.4.71 or later**, or install the `mod_http2` package in the table for the Red Hat release you run. Restart `httpd` or `apache2`. A running process keeps the module it loaded.
2. On Debian bookworm, install `apache2` **2.4.71-1~deb12u1** or later. On Debian trixie, install **2.4.71-1~deb13u1** or later from the security pocket. On Debian sid and forky, install **2.4.71-1** or later. On Ubuntu, install the `apache2` build in the table. On Amazon Linux, install `httpd` **2.4.71-1.amzn2.0.1** or **2.4.71-1.amzn2023.0.1**. On SLES 15 SP7, install `apache2` **2.4.71-150700.4.30.1** or later (SUSE-SU-2026:5231-1, 2026-11-13). SLES 16.0, SLES 16.1, and the 15 SP4 through SP6 and 12 SP5 LTSS lines are also Released. openSUSE Leap 16.0 and 16.1 now have `apache2` 2.4.71 (openSUSE-SU-2026:22352-1, 2026-11-13). SUSE's CVE page, last modified 2026-11-19, still labels both Affected while listing those packages. Take HTTP/2 off only where the installed package is older than 2.4.71.
3. Until the package is in, remove `h2` and `h2c` from every `Protocols` line and leave `http/1.1`. Wiz describes that step. Apache's advisory names no workaround. Turning HTTP/2 off is not a substitute for the upgrade, and it does not fix CVE-2026-106023, which is in `mod_md` and does not need HTTP/2.
4. A server built from the archived GitHub `mod_h2` has no release after 2.0.42. Rebuild it from the 2.4.71 tree, or turn HTTP/2 off.
5. Red Hat Enterprise Linux 8 and earlier do not contain this code. Do not treat a scanner finding there as this flaw without checking the package.
6. On VMware Aria Operations 8.18.x, VMware Cloud Foundation Operations 9.x, Aria Operations on Cloud Foundation 5.x, and VCF Operations HCX 9.1.x, there is no build yet. Apply [KB463005](https://knowledge.broadcom.com/external/article/463005) or [KB463022](https://knowledge.broadcom.com/external/article/463022), which turn HTTP/2 off, and run the check again after every upgrade. Those appliances are not fixed by installing a distribution `apache2` package.
7. The upgrade does not show whether a request already ran code.

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
- [SUSE CVE-2026-119618][suse] — reread 2026-11-17. Last modified 2026-11-16. SLES 15 SP7 and 16.0 are Released, as are the 15 SP4 through SP6 and 12 SP5 LTSS lines. SLES 16.1 and openSUSE Leap 16.0 and 16.1 are still Affected. Overall state Pending.
- [Wiz][wiz] — November 11. Says no exploit is available and no in-the-wild exploitation has been reported. Recommends `Protocols http/1.1` until the upgrade. Its standalone `mod_h2` fixed version does not match the Apache advisory; follow Apache.
- [Singapore CSA, AL-2026-164][csa] — November 17, 2026. Says attackers are exploiting CVE-2026-119618. Scores it CVSS 3.1 8.1. Names no victim.
- [VMSA-2026-0010][vmsa] — Broadcom, 2026-11-19. CVSS 3.1 9.8. Aria Operations, Cloud Foundation Operations, and VCF Operations HCX. Patch pending. Workaround in KB463005 and KB463022.
- [Google Cloud GCP-2026-086](https://docs.cloud.google.com/support/bulletins#gcp-2026-086) — published 2026-11-19. Points at VMSA-2026-0010 and names no Google-built fix.
- [CISA KEV][kev] — catalog 2026.11.17, released 2026-11-17T17:53:15.5664Z, checked 2026-11-18. None of the three is listed.

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
[csa]: https://www.csa.gov.sg/alerts-and-advisories/alerts/al-2026-164/
[vmsa]: https://support.broadcom.com/web/ecx/support-content-notification/-/external/content/SecurityAdvisories/0/39625
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
