# OpenJDK: Java4Shell - a Base64 string corrupts memory

**Last updated:** 2026-11-17 (America/New_York)

[Main Java4Shell summary](../black-october-2026.md#openjdk-java4shell---a-base64-string-corrupts-memory) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Vulnerability Info Site: [calif.io](https://calif.io/java4shell/)

OpenJDK is the Java runtime behind Oracle Java SE and the other Java distributions. On November 17 the OpenJDK Vulnerability Group and Oracle published a fix for a flaw in the hardware-accelerated Base64 decoder. Calif, which found it, calls it Java4Shell.

**Oracle and the OpenJDK Vulnerability Group rate [CVE-2026-114938](https://www.cve.org/CVERecord?id=CVE-2026-114938) CVSS 3.1 8.1 High.** The vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`. Calif rates the same flaw **CVSS 4.0 9.2 Critical**. Oracle is the CNA. The OpenJDK matrix marks Java 17, 21, 25, and 27, and not standard Java 8 or 11. Oracle's risk matrix lists Oracle Java SE **8u511b33-perf**, **17.0.21.0.3**, **21.0.13.0.3**, **25.0.5.0.3**, and **27.0.1.0.3**, Oracle GraalVM for JDK 17.0.21.0.3 and 21.0.13.0.3, and GraalVM Enterprise Edition 21.3.20.0.3. The 8u build is the Enterprise Performance Pack. Oracle's note says the flaw is reached by supplying data to the component's APIs, such as through a web service, and not through an untrusted applet.

Calif says the bug is in HotSpot's x86-64 Base64 intrinsic, from OpenJDK **17.0.6** on, and only on a CPU with AVX-512 VBMI. ARM64 is not affected. A string of 64 `A` characters and one `=` makes the decoder write past the output array. In older OpenJDK 17 the trigger is 128 `A` characters. Calif says that overwrite can leak heap memory and, with heap grooming, run code. It says it showed unauthenticated code execution in Keycloak, Jira, Confluence, JFrog Artifactory, Jenkins, and PingFederate, and authenticated code execution in Kafka, Solr, Elasticsearch, Gerrit, and Spinnaker. It is withholding the product-specific exploits. CISA's November 17 alert calls the flaw critical and says crafted Base64 input could crash the JVM and allow unauthenticated remote code execution. CISA does not publish a score.

The same OpenJDK advisory lists four more flaws at 7.0 or higher: [CVE-2026-114939](https://www.cve.org/CVERecord?id=CVE-2026-114939) and [CVE-2026-114940](https://www.cve.org/CVERecord?id=CVE-2026-114940) at 7.4, and [CVE-2026-114941](https://www.cve.org/CVERecord?id=CVE-2026-114941) and [CVE-2026-114942](https://www.cve.org/CVERecord?id=CVE-2026-114942) at 7.0. OpenJFX [CVE-2026-86144](https://www.cve.org/CVERecord?id=CVE-2026-86144) is 7.5. Oracle's Java matrix gives 7.5 to CVE-2026-86144 and 7.4 to CVE-2026-114939, and it does not print a row for the other three.

Oracle's download page lists the replacement builds **17.0.21.1**, **21.0.13.1**, **25.0.5.1**, **27.0.1.1**, and **8u513**. The 17.0.21.1 release notes are dated November 17, 2026, and the security baseline for the 17 family is `17.0.21.1+4`. Calif says other distributions built from the same OpenJDK code carry the flaw: Amazon Corretto, Eclipse Temurin, Microsoft Build of OpenJDK, Azul Zulu, BellSoft Liberica, SAP SapMachine, and Red Hat OpenJDK. This run did not find a fixed build number for those. A runtime bundled inside an application or a container image does not move when the system JDK does.

**CISA KEV:** Not listed (catalog 2026.11.17, checked 2026-11-18). CISA published an alert the same day and did not add the CVE. Calif and CISA do not report exploitation in the wild. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Last updated** | **2026-11-17 (America/New_York)** | New item. Install the November 17 Java build. |

## Detection

1. **Build.** `java -version` on Oracle JDK. 17.0.21.0.3, 21.0.13.0.3, 25.0.5.0.3, 27.0.1.0.3, and 8u511-perf are the builds Oracle names. The replacement builds end in `.1` (8u513 for the performance pack and for standard Java 8). A build older than 17.0.6 is outside Calif's range. Standard Java 8 and Java 11 are outside the OpenJDK matrix for this CVE. They are inside CVE-2026-114939 and CVE-2026-114940.
2. **CPU.** On Linux, the four flags `avx512f`, `avx512bw`, `avx512vbmi`, and `bmi2` all have to be present. ARM64 is not affected. A container inherits the host CPU.
3. **Bundled runtimes.** A product that ships its own JVM does not show up as a system JDK. CISA names container images and appliances. Keycloak, Jira, Confluence, Artifactory, Jenkins, and PingFederate are the products Calif says it reached without a login. That list is Calif's, not Oracle's.
4. A host missing one of the four flags is outside the decoder bug. It can still be inside the other November 17 Java flaws.

## Remediation

1. Install Oracle JDK **17.0.21.1, 21.0.13.1, 25.0.5.1, or 27.0.1.1**, or **8u513** for the Enterprise Performance Pack, and restart every process that loaded the old runtime. Rebuild a container image that bundles Java.
2. For Corretto, Temurin, Microsoft, Zulu, Liberica, SapMachine, and Red Hat OpenJDK, install that vendor's build of the November 17 fix. This run did not find those build numbers. Do not treat the Oracle build number as theirs.
3. Until that build is running, Calif says start the JVM with `-XX:-UseBASE64Intrinsics`, or with `-XX:UseAVX=2` on x86-64 only. OpenJDK on ARM does not recognize the second flag and fails to start. Oracle's advisory and the OpenJDK advisory do not mention either flag.
4. CISA's temporary control is to restrict and validate Base64 at the application boundary and limit unauthenticated access. That is not the fix.
5. The restart does not show whether a request already corrupted memory.

## Verification

- `java -version` reports 17.0.21.1, 21.0.13.1, 25.0.5.1, 27.0.1.1, or 8u513, or the vendor's fixed build.
- A service process was started after that install. A JVM that was already running is still the old one.
- Do not send the 64-`A` string at a service to confirm the bug.

## Compromise response

CISA says to look for rogue runtimes, unexpected JVM crashes, and suspicious Java processes. It publishes no indicator. Calif does not report exploitation in the wild.

The update does not show whether a request already ran code. A service Calif lists, on an affected JVM and an AVX-512 VBMI host, that crashed or spawned a process before the update needs a review of what ran afterward.

## Sources

- [OpenJDK Vulnerability Advisory: 2026/11/17][openjdk] — last update 2026-11-17 17:44 UTC. CVE-2026-114938 is CVSS 3.1 8.1 in hotspot/compiler, affecting 17, 21, 25, and 27. Four more are 7.0 or 7.4. OpenJFX CVE-2026-86144 is 7.5.
- [Oracle Critical Security Patch Update, November 2026][oracle] — Rev 1, 2026-November-17. Java SE risk matrix: CVE-2026-114938 is 8.1, remote, no authentication, Note 1. Credits Quang Luong of Calif.io and Albert Yang.
- [CVE-2026-114938](https://www.cve.org/CVERecord?id=CVE-2026-114938) — Oracle CNA, published 2026-11-17. Same 8.1 score and the same affected builds.
- [Calif, Java4Shell][calif] — CVSS 4.0 9.2. OpenJDK 17.0.6 and newer, x86-64 with AVX-512 VBMI. Product list and the two startup flags.
- [CISA alert][cisa] — November 17, 2026. Calls the flaw critical. Points at Oracle's advisory. Not a KEV listing.
- [JDK 17.0.21.1 release notes](https://www.oracle.com/java/technologies/javase/17-0-21-1-relnotes.html) — release date November 17, 2026. Full version 17.0.21.1+4. Security baseline for the 17 family is that build. The 11 baseline listed there is 11.0.33.1+4 and the 8 baseline is 1.8.0_513-b04.
- [Oracle Java downloads](https://www.oracle.com/java/technologies/downloads/) — read 2026-11-18. Lists 27.0.1.1, 25.0.5.1, 21.0.13.1, 17.0.21.1, and 8u513.
- [CISA KEV JSON][kev] — catalog 2026.11.17, released 2026-11-17T17:53:15.5664Z, checked 2026-11-18. CVE-2026-114938 is not listed.

[openjdk]: https://openjdk.org/groups/vulnerability/advisories/2026-11-17
[oracle]: https://www.oracle.com/security-alerts/cspunov2026.html
[calif]: https://calif.io/java4shell/
[cisa]: https://www.cisa.gov/news-events/alerts/2026/11/17/critical-java-vulnerability-requires-immediate-patching
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
