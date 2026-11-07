# Apache Thrift: unbounded recursion in the Java skip path

**Last updated:** 2026-11-01 (America/New_York)

[Main Apache Thrift summary](../black-october-2026.md#apache-thrift-unbounded-recursion-in-the-java-skip-path) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-120135](https://www.cve.org/CVERecord?id=CVE-2026-120135) — Apache (CNA) CVSS 4.0: 8.2 High (CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:N/VI:N/VA:H/SC:N/SI:N/SA:N); Apache advisory text: important; NVD status "Received" and has not scored it itself; not in CISA KEV.** This is uncontrolled recursion, CWE-674, in the Java bindings (`org.apache.thrift:libthrift`). `TProtocolUtil.skip()` does not limit recursion depth by default. The CNA marks attack requirements **present** (`AT:P`) and availability impact High, with confidentiality and integrity None. [Advisory][oss] [CNA][cve] [NVD][nvd]

**Attack conditions:** The advisory does not spell out the message that triggers the recursion. The class is the Java helper that walks past fields the receiver does not consume. Treat a Java Thrift server or client that decodes structures from an untrusted peer, on a build before 0.24.0, as in scope until you can show that path is unused. Other language libraries are not named. [Advisory][oss] [CNA][cve]

**Worst case:** the process consumes stack or other resources until it fails. The vector does not claim code execution or data theft. Apache does not describe a bypass of the 0.24.0 limit. [Advisory][oss] [CNA][cve]

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-01). The advisory does not mention exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

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
| Private discovery/report | Unknown | Apache credits Yu Bao (PayPal). No report date is published. [Advisory][oss] |
| `libthrift` 0.24.0 on Maven Central | 2026-07-11 20:59:13 GMT | First release the CNA calls fixed. The timestamp is the jar's Last-Modified header, not the advisory date. [Maven Central][mvn-024] |
| `libthrift` 0.25.0 on Maven Central | 2026-10-01 00:09:24 GMT | Current stable release on the Thrift download page, which says released 2026-SEP-30. [Maven Central][mvn-025] [Download][download] |
| CVE reserved | 2026-10-30 22:21:45 UTC | CNA metadata. [CVE JSON][cve] |
| **Public announcement**: oss-security | 2026-10-30 23:13:23 +0000 | Jens Geyer (Apache). Severity important, CVSS 4.0 8.2, affected before 0.24.0. [oss-security][oss] |
| CVE record published | 2026-10-31 20:33:00 UTC | Apache CNA. NVD lists published 2026-10-31 21:16:53, status "Received". [CVE JSON][cve] [NVD][nvd] |
| CISA KEV | Not listed as of catalog 2026.10.30 (checked 2026-11-01) | [KEV JSON][kev] |

The mailing-list post is the public announcement. The CVE record's publication timestamp is the next day. Do not treat 0.24.0's July artifact date as the disclosure date.

## Detection

1. Find every application that ships `org.apache.thrift:libthrift`, including shaded JARs and generated Java stubs that were compiled against it. Read-only checks:
   - Maven: `mvn dependency:tree -Dincludes=org.apache.thrift:libthrift`
   - Gradle: `gradle dependencies --configuration runtimeClasspath | grep libthrift`
   - Built artifacts: `find /opt/app -name 'libthrift-*.jar'`, or `unzip -l app.jar | grep libthrift`.
   These list dependencies and change nothing. Check what is deployed, not only the source tree.
2. Compare the resolved version with the CNA record:

   | Version | Status | Action |
   |---|---|---|
   | Before 0.24.0 | Affected | Upgrade to 0.24.0 or later. **0.25.0** is the current stable release. |
   | 0.24.0 and later | Fixed, per the CNA | None for this CVE. |

   [CNA][cve] [Advisory][oss] [Download][download]

The CNA range is the Java artifact only (`pkg:maven/org.apache.thrift/libthrift`). A Python, Go, C++, or other Thrift library is not this CVE. A service that speaks Thrift but decodes it in another language is not cleared by a Java upgrade, and it is not implicated by this advisory either.

Apache published **no indicators of compromise**. The described result is resource exhaustion, which looks like a crashed or restarted Java process and not like a distinctive log line. A crash is not proof this CVE was used. Absence of crashes does not prove an exposed old build was not probed.

## Remediation

1. Upgrade `org.apache.thrift:libthrift` to **0.24.0 or later**. Prefer **0.25.0**, which the project lists as the latest stable release (2026-SEP-30). [Advisory][oss] [Download][download]
2. Rebuild and redeploy every artifact, including services that shade the jar. Updating the declared version changes nothing until the running process loads the new jar.
3. Regenerate Java stubs if your build vendors an old `libthrift` inside them. The advisory does not say generated code copies `TProtocolUtil`; check the deployed jar rather than assuming either way.
4. The advisory gives no configuration workaround. Limiting request size at a proxy reduces how large a single frame can be; Apache does not say that prevents deep nesting, so it is not a fix.

## Verification

- Confirm each running artifact contains `libthrift` 0.24.0 or later and does not also contain an older `libthrift` jar. Example: `find /opt/app -name 'libthrift-*.jar'` on the deployed tree. Restart and confirm the process start time is after that deploy.
- As a benign functional control in a **test** environment, complete one ordinary RPC the service is supposed to handle and confirm the expected result. Do not send deeply nested payloads, and do not test against production.

## Compromise response

This advisory describes denial of service, not code execution or theft. A crash alone is not a compromise.

- If the process was reachable and you cannot explain a crash, preserve logs and the heap or crash dump before you restart onto the new jar.
- Restarting onto 0.24.0+ stops this recursion path. It does not explain an earlier outage.

## Sources

- [oss-security announcement, 2026-10-30 23:13:23 +0000][oss] — severity important, CVSS 4.0 8.2, affected before 0.24.0, credit.
- [Apache CNA record][cve] — CVSS 4.0 8.2 vector (`AT:P`, availability High only), CWE-674, Maven package and version range, publication metadata. CISA-ADP added an SSVC block on 2026-11-06: Exploitation none, Automatable no, Technical Impact partial. That block is not a KEV listing and does not change the score.
- [NVD][nvd] — status "Received"; displays Apache's CVSS 4.0 metric and has not scored it itself.
- [Apache Thrift download page][download] — latest stable release 0.25.0, released 2026-SEP-30. Does not mention this CVE.
- [Maven Central `libthrift` 0.24.0][mvn-024] and [0.25.0][mvn-025] — artifact timestamps.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.30).

[oss]: https://www.openwall.com/lists/oss-security/2026/10/31/2
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-120135
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-120135
[download]: https://thrift.apache.org/download
[mvn-024]: https://repo1.maven.org/maven2/org/apache/thrift/libthrift/0.24.0/libthrift-0.24.0.jar
[mvn-025]: https://repo1.maven.org/maven2/org/apache/thrift/libthrift/0.25.0/libthrift-0.25.0.jar
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
