# OpenJDK: Java4Shell - a Base64 string corrupts memory

**Last updated:** 2026-11-21 (America/New_York)

[Main Java4Shell summary](../black-october-2026.md#openjdk-java4shell---a-base64-string-corrupts-memory) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Vulnerability Info Site: [calif.io](https://calif.io/java4shell/)

OpenJDK is the Java runtime behind Oracle Java SE and the other Java distributions. On November 17 the OpenJDK Vulnerability Group and Oracle published a fix for a flaw in the hardware-accelerated Base64 decoder. Calif, which found it, calls it Java4Shell.

**Oracle and the OpenJDK Vulnerability Group rate [CVE-2026-114938](https://www.cve.org/CVERecord?id=CVE-2026-114938) CVSS 3.1 8.1 High.** The vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`. Calif rates the same flaw **CVSS 4.0 9.2 Critical**. Oracle is the CNA. The OpenJDK matrix marks Java 17, 21, 25, and 27, and not standard Java 8 or 11. Oracle's risk matrix lists Oracle Java SE **8u511b33-perf**, **17.0.21.0.3**, **21.0.13.0.3**, **25.0.5.0.3**, and **27.0.1.0.3**, Oracle GraalVM for JDK 17.0.21.0.3 and 21.0.13.0.3, and GraalVM Enterprise Edition 21.3.20.0.3. The 8u build is the Enterprise Performance Pack. Oracle's note says the flaw is reached by supplying data to the component's APIs, such as through a web service, and not through an untrusted applet.

Calif says the bug is in HotSpot's x86-64 Base64 intrinsic, from OpenJDK **17.0.6** on, and only on a CPU with AVX-512 VBMI. ARM64 is not affected. A string of 64 `A` characters and one `=` makes the decoder write past the output array. In older OpenJDK 17 the trigger is 128 `A` characters. Calif says that overwrite can leak heap memory and, with heap grooming, run code. It says it showed unauthenticated code execution in Keycloak, Jira, Confluence, JFrog Artifactory, Jenkins, and PingFederate, and authenticated code execution in Kafka, Solr, Elasticsearch, Gerrit, and Spinnaker. It is withholding the product-specific exploits. CISA's November 17 alert calls the flaw critical and says crafted Base64 input could crash the JVM and allow unauthenticated remote code execution. CISA does not publish a score.

The same OpenJDK advisory lists four more flaws at 7.0 or higher: [CVE-2026-114939](https://www.cve.org/CVERecord?id=CVE-2026-114939) and [CVE-2026-114940](https://www.cve.org/CVERecord?id=CVE-2026-114940) at 7.4, and [CVE-2026-114941](https://www.cve.org/CVERecord?id=CVE-2026-114941) and [CVE-2026-114942](https://www.cve.org/CVERecord?id=CVE-2026-114942) at 7.0. OpenJFX [CVE-2026-86144](https://www.cve.org/CVERecord?id=CVE-2026-86144) is 7.5. Oracle's Java matrix gives 7.5 to CVE-2026-86144 and 7.4 to CVE-2026-114939, and it does not print a row for the other three.

Oracle's download page lists the replacement builds **17.0.21.1**, **21.0.13.1**, **25.0.5.1**, **27.0.1.1**, and **8u513**. The 17.0.21.1 release notes are dated November 17, 2026, and the security baseline for the 17 family is `17.0.21.1+4`. A runtime bundled inside an application or a container image does not move when the system JDK does.

Other distributions now name their own builds. Amazon Corretto's changelogs, dated November 17, list **17.0.21.1.2**, **21.0.13.1.2**, **25.0.5.1.2**, and **27.0.1.1.4**, and each table includes CVE-2026-114938. Microsoft's November 18 post says **17.0.21.1**, **21.0.13.1**, and **25.0.5.1** contain the fix; Microsoft does not ship 27. Adoptium says the Temurin builds with the fix are **17.0.21.1+2**, **21.0.13.1+2**, **25.0.5.1+2**, and **27.0.1.1+4**, and that binaries are published as testing completes. Azul says the November 17 Zulu builds fix it in 17, 21, 25, and 27, and names Prime **26.08.110.0** and **26.02.510.0**. Red Hat rates the same flaw Critical, CVSS 3.0 **9.8** (`CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`). Its CVE page, read November 20, marks the RHEL OpenJDK packages Fixed, with errata issued November 18: RHEL 8 `java-17-openjdk` **17.0.21.1.2-2.1.el8** and `java-21-openjdk` ([RHSA-2026:100563](https://access.redhat.com/errata/RHSA-2026:100563)); RHEL 9 `java-17-openjdk` **17.0.21.1.2-2.2.el9**, `java-21-openjdk`, and `java-25-openjdk` **25.0.5.1.2** ([RHSA-2026:100564](https://access.redhat.com/errata/RHSA-2026:100564)); RHEL 10 `java-21-openjdk` **21.0.13.1.2-1.2.el10** and `java-25-openjdk` **25.0.5.1.2-1.1.el10** ([RHSA-2026:100568](https://access.redhat.com/errata/RHSA-2026:100568)). RHEL 8 has no `java-25` package and RHEL 10 has no `java-17` package. RHSB-2026-018, updated November 20, still says fixes are being expedited and does not name these errata. Red Hat build of Keycloak, JBoss EAP 7 and 8 images, and the Hardened Images are still listed Affected. OpenJDK 8 and 11 do not contain the path.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-21). CISA published an alert on November 17 and did not add the CVE. GreyNoise, as of early November 19, reports more than 150 Java4Shell-shaped requests from five addresses and no successful intrusion on its sensors. Previdian reports nine attempts from six addresses, in China, Germany, Romania, and the United States, on November 18 and 19, and says its sensors cannot show that a target was compromised. Cloudflare's blog, published November 18, says it has seen no indication the flaw was exploited on Cloudflare's own Java. Cloudforce One said on November 18 that one address sent both ARTEX traffic and a Java4Shell attempt, and later that one address returned with a Chrome User-Agent; neither post says the attempt succeeded. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and Oracle fix** | **2026-11-17; time unknown** | Oracle CSPU Rev 1 and the OpenJDK advisory. The advisory's last update is 2026-11-17 17:44 UTC. [OpenJDK][openjdk] |
| Calif write-up | 2026-11-17; time unknown | After the patch. CVSS 4.0 9.2. Product-specific exploits withheld. [Calif][calif] |
| CISA alert | 2026-11-17; time unknown | "Critical Java Vulnerability Requires Immediate Patching." Not a KEV addition. [CISA][cisa] |
| Corretto, Microsoft, Temurin, and Zulu builds | 2026-11-17 and 2026-11-18 | Corretto 17.0.21.1.2, 21.0.13.1.2, 25.0.5.1.2, and 27.0.1.1.4. Microsoft 17.0.21.1, 21.0.13.1, and 25.0.5.1. Temurin 17.0.21.1+2, 21.0.13.1+2, 25.0.5.1+2, and 27.0.1.1+4. [Corretto][corretto] [Microsoft][ms] [Temurin][temurin] |
| Red Hat bulletin | 2026-11-18 13:53 UTC | RHSB-2026-018. Critical, CVSS 3.0 9.8. The bulletin text still says fixes are being expedited. [Red Hat][rh] |
| Red Hat errata | 2026-11-18; time/TZ unknown | The CVE page marks the RHEL 8, 9, and 10 OpenJDK packages Fixed. [RHSA-2026:100563](https://access.redhat.com/errata/RHSA-2026:100563) |
| Exploit-shaped requests | 2026-11-18 through 2026-11-19 | GreyNoise reports more than 150 requests from five addresses and no successful intrusion. Previdian reports nine attempts from six addresses and says that does not show a compromise. Cloudforce One reports one address sending ARTEX and a Java4Shell attempt. None of this is a KEV listing. [GreyNoise][grey] |
| Ubuntu and Debian packages | 2026-11-18 and 2026-11-20; time/TZ unknown | USN-9155-1 through USN-9158-1, and the CRaC notices USN-9178-1 through USN-9180-1. Debian DLA-4917-1, DSA-6639-1, and DSA-6640-1. Forky has none. |
| **Last updated** | **2026-11-21 (America/New_York)** | Ubuntu, Debian, Amazon Linux, and AlmaLinux have packages. Forky, Rocky 9 and 10, and SUSE do not. |

## Detection

1. **Build.** `java -version` on Oracle JDK. 17.0.21.0.3, 21.0.13.0.3, 25.0.5.0.3, 27.0.1.0.3, and 8u511-perf are the builds Oracle names. The replacement builds end in `.1` (8u513 for the performance pack and for standard Java 8). A build older than 17.0.6 is outside Calif's range. Standard Java 8 and Java 11 are outside the OpenJDK matrix for this CVE. They are inside CVE-2026-114939 and CVE-2026-114940. Corretto's fixed builds are 17.0.21.1.2, 21.0.13.1.2, 25.0.5.1.2, and 27.0.1.1.4. Microsoft's are 17.0.21.1, 21.0.13.1, and 25.0.5.1. Temurin's are 17.0.21.1+2, 21.0.13.1+2, 25.0.5.1+2, and 27.0.1.1+4. On Red Hat Enterprise Linux, the November 18 errata are the fix: `java-17-openjdk` 17.0.21.1.2-2.1.el8 on RHEL 8 and 17.0.21.1.2-2.2.el9 on RHEL 9, `java-21-openjdk` on RHEL 8, 9, and 10, and `java-25-openjdk` 25.0.5.1.2 on RHEL 9 and 10. RHEL 8 has no Java 25 package and RHEL 10 has no Java 17 package. A Red Hat build of Keycloak, and a JBoss EAP image, are still listed without a package.
2. **CPU.** On Linux, the four flags `avx512f`, `avx512bw`, `avx512vbmi`, and `bmi2` all have to be present. ARM64 is not affected. A container inherits the host CPU.
3. **Bundled runtimes.** A product that ships its own JVM does not show up as a system JDK. CISA names container images and appliances. Keycloak, Jira, Confluence, Artifactory, Jenkins, and PingFederate are the products Calif says it reached without a login. That list is Calif's, not Oracle's.
4. A host missing one of the four flags is outside the decoder bug. It can still be inside the other November 17 Java flaws.

## Remediation

1. Install Oracle JDK **17.0.21.1, 21.0.13.1, 25.0.5.1, or 27.0.1.1**, or **8u513** for the Enterprise Performance Pack, and restart every process that loaded the old runtime. Rebuild a container image that bundles Java.
2. For the other distributions, install the build that vendor names: Corretto **17.0.21.1.2, 21.0.13.1.2, 25.0.5.1.2, or 27.0.1.1.4**; Microsoft **17.0.21.1, 21.0.13.1, or 25.0.5.1**; Temurin **17.0.21.1+2, 21.0.13.1+2, 25.0.5.1+2, or 27.0.1.1+4**; Azul's November 17 Zulu build, or Prime **26.08.110.0** or **26.02.510.0**. On Red Hat Enterprise Linux, install the November 18 `java-17-openjdk`, `java-21-openjdk`, or `java-25-openjdk` erratum for the release you run. Do not treat the Oracle build number as another vendor's. A Red Hat build of Keycloak and a JBoss EAP image are still listed without a fixed package.
3. Linux packages that name this CVE:
   - **Ubuntu:** the package in USN-9155-1 through USN-9158-1 (November 18) for `openjdk-17`, `openjdk-21`, and `openjdk-25` on 22.04, 24.04, and 26.04 LTS. `openjdk-27` is fixed only on 26.10. The CRaC packages are USN-9178-1 through USN-9180-1 (November 20).
   - **Debian:** `openjdk-17` **17.0.21.1+2-1~deb12u1** on bookworm (DLA-4917-1), `openjdk-21` **21.0.13.1+2-1~deb13u1** (DSA-6639-1) and `openjdk-25` **25.0.5.1+2-1~deb13u1** (DSA-6640-1) on trixie. Forky is still marked vulnerable.
   - **Amazon Linux:** ALAS2-2026-4123 on Amazon Linux 2, and ALAS2023-2026-3478 through 3481 on Amazon Linux 2023, all dated November 17. Java 8 and 11 are not affected.
   - **AlmaLinux:** ALSA-2026:100563 and ALSA-2026:100564 (November 19) for `java-17-openjdk` **17.0.21.1.2** on 8 and 9, and ALSA-2026:100568 for `java-21-openjdk` **21.0.13.1.2-1.2.el10.alma.1** on 10.
   - **Rocky Linux:** RLSA-2026:100563 and RLSA-2026:100567 (November 19) cover Rocky Linux 8 only. Rocky 9 and 10 have no advisory.
   - **SUSE:** the page last modified November 19 still says Java 17, 21, and 25 on SUSE Linux Enterprise Server 15 SP7 and 16.0 are In progress. Java 8 and 11 are not affected.
4. Until that build is running, Calif says start the JVM with `-XX:-UseBASE64Intrinsics`, or with `-XX:UseAVX=2` on x86-64 only. OpenJDK on ARM does not recognize the second flag and fails to start. Oracle's advisory and the OpenJDK advisory do not mention either flag.
5. CISA's temporary control is to restrict and validate Base64 at the application boundary and limit unauthenticated access. That is not the fix.
6. The restart does not show whether a request already corrupted memory.

## Verification

- `java -version` reports 17.0.21.1, 21.0.13.1, 25.0.5.1, 27.0.1.1, or 8u513, or the vendor's fixed build.
- A service process was started after that install. A JVM that was already running is still the old one.
- Do not send the 64-`A` string at a service to confirm the bug.

## Compromise response

CISA says to look for rogue runtimes, unexpected JVM crashes, and suspicious Java processes. It publishes no indicator. GreyNoise reports more than 150 exploit-shaped requests and no successful intrusion. Previdian reports nine attempts and says that count does not show a compromise. A Chrome User-Agent on a request is not evidence the request came from a browser, and a shared address is not evidence the attempt succeeded.

The update does not show whether a request already ran code. A service Calif lists, on an affected JVM and an AVX-512 VBMI host, that crashed or spawned a process before the update needs a review of what ran afterward.

## Sources

- [OpenJDK Vulnerability Advisory: 2026/11/17][openjdk] — last update 2026-11-17 17:44 UTC. CVE-2026-114938 is CVSS 3.1 8.1 in hotspot/compiler, affecting 17, 21, 25, and 27. Four more are 7.0 or 7.4. OpenJFX CVE-2026-86144 is 7.5.
- [Oracle Critical Security Patch Update, November 2026][oracle] — Rev 1, 2026-November-17. Java SE risk matrix: CVE-2026-114938 is 8.1, remote, no authentication, Note 1. Credits Quang Luong of Calif.io and Albert Yang.
- [CVE-2026-114938](https://www.cve.org/CVERecord?id=CVE-2026-114938) — Oracle CNA, published 2026-11-17. Same 8.1 score and the same affected builds.
- [Calif, Java4Shell][calif] — CVSS 4.0 9.2. OpenJDK 17.0.6 and newer, x86-64 with AVX-512 VBMI. Product list and the two startup flags.
- [CISA alert][cisa] — November 17, 2026. Calls the flaw critical. Points at Oracle's advisory. Not a KEV listing.
- [JDK 17.0.21.1 release notes](https://www.oracle.com/java/technologies/javase/17-0-21-1-relnotes.html) — release date November 17, 2026. Full version 17.0.21.1+4. Security baseline for the 17 family is that build. The 11 baseline listed there is 11.0.33.1+4 and the 8 baseline is 1.8.0_513-b04.
- [Oracle Java downloads](https://www.oracle.com/java/technologies/downloads/) — read 2026-11-18. Lists 27.0.1.1, 25.0.5.1, 21.0.13.1, 17.0.21.1, and 8u513.
- [CISA KEV JSON][kev] — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-21. CVE-2026-114938 is not listed.
- [Ubuntu CVE-2026-114938](https://ubuntu.com/security/CVE-2026-114938) — last updated 20 November 2026. Fixed on 22.04, 24.04, and 26.04 LTS for openjdk-17, 21, and 25. openjdk-27 is fixed only on 26.10.
- [Debian tracker](https://security-tracker.debian.org/tracker/CVE-2026-114938) — bookworm, trixie, and sid fixed. Forky still vulnerable: openjdk-21 21.0.13.0.3+1-1 and openjdk-25 25.0.5+8-1.
- [SUSE CVE-2026-114938](https://www.suse.com/security/cve/CVE-2026-114938.html) — last modified 2026-11-19. SLES 15 SP7 and 16.0 Java 17, 21, and 25 are In progress.
- [Amazon Linux](https://explore.alas.aws.amazon.com/CVE-2026-114938.html) — fixed 2026-11-17. ALAS2-2026-4123 and ALAS2023-2026-3478 through 3481.
- [AlmaLinux ALSA-2026:100568](https://errata.almalinux.org/10/ALSA-2026-100568.html) — 2026-11-19. AlmaLinux 8 and 9 are ALSA-2026:100563 and ALSA-2026:100564.
- [Rocky Linux RLSA-2026:100563](https://errata.rockylinux.org/api/v2/advisories/RLSA-2026:100563) — published 2026-11-19, Rocky Linux 8 only. No Rocky 9 or 10 advisory.
- [Amazon Corretto 17 changelog][corretto] — 17.0.21.1.2, November 17, 2026. The CVE table includes CVE-2026-114938 at 8.1. The 21, 25, and 27 changelogs name 21.0.13.1.2, 25.0.5.1.2, and 27.0.1.1.4.
- [Microsoft Build of OpenJDK, November 2026][ms] — November 18, 2026. 17.0.21.1, 21.0.13.1, and 25.0.5.1 contain the fix.
- [Eclipse Temurin guidance][temurin] — 17.0.21.1+2, 21.0.13.1+2, 25.0.5.1+2, and 27.0.1.1+4. Binaries publish as testing completes.
- [Azul, Java4Shell][azul] — November 17 Zulu builds for 17, 21, 25, and 27. Prime 26.08.110.0 and 26.02.510.0.
- [Red Hat RHSB-2026-018][rh] — updated 2026-11-20 02:37. Critical. The bulletin text still says fixes are being expedited. The CVE page marks the RHEL 8, 9, and 10 OpenJDK packages Fixed, with errata issued 2026-11-18. Red Hat build of Keycloak and the JBoss EAP images are still listed Affected.
- [Keycloak, Java4Shell][kc] — updated 2026-11-19. Tags `26.8.2-1` and `26.8.2-2` still bundle OpenJDK 21.0.13. `26.8.2-3` bundles 21.0.13.1. Pull the image again and recreate the container. The [Keycloak guide](keycloak.md#remediation) has the tag list.
- [GreyNoise Java4Shell activity][grey] — read 2026-11-19. More than 150 exploit-shaped requests from five addresses, no successful intrusion. SecurityWeek's November 19 report is the count.
- [Previdian, CVE-2026-114938](https://previdian.com/CVE-2026-114938) — nine attempts from six addresses on November 18 and 19. The page says the sensors cannot show that a target was compromised.
- [Cloudflare WAF][cf] — published 2026-11-18. Six managed rules, Log by default. No indication of exploitation on Cloudflare's Java.
- [Cloudforce One][cfo] — 2026-11-18 16:56 UTC. One address sent ARTEX traffic and a Java4Shell attempt. The post does not say the attempt succeeded.

[openjdk]: https://openjdk.org/groups/vulnerability/advisories/2026-11-17
[oracle]: https://www.oracle.com/security-alerts/cspunov2026.html
[calif]: https://calif.io/java4shell/
[cisa]: https://www.cisa.gov/news-events/alerts/2026/11/17/critical-java-vulnerability-requires-immediate-patching
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[corretto]: https://github.com/corretto/corretto-17/blob/develop/CHANGELOG.md
[ms]: https://devblogs.microsoft.com/java/java-openjdk-november-2026-critical-patch-update
[temurin]: https://adoptium.net/news/2026/11/temurin-november-2026-cspu-java4shell
[azul]: https://www.azul.com/blog/java4shell-cve-2026-114938-what-it-is-who-is-affected-and-what-to-do-now/
[rh]: https://access.redhat.com/security/vulnerabilities/RHSB-2026-018
[kc]: https://www.keycloak.org/2026/11/java4shell-vulnerability-cve-2026-114938
[grey]: https://java4shell.events.greynoise.io/
[cf]: https://blog.cloudflare.com/java4shell-waf-protection
[cfo]: https://x.com/Cloudforce_One/status/2123098021596725484
