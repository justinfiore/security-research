# Apache MINA: unsafe Java deserialization in the 3.0 codec

**Last updated:** 2026-11-06 (America/New_York)

[Main Apache MINA summary](../black-october-2026.md#apache-mina-unsafe-java-deserialization-in-the-30-codec) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-118636](https://www.cve.org/CVERecord?id=CVE-2026-118636) — Apache (CNA) CVSS 3.1: 9.8 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H); Apache advisory text: critical; NVD status "Received" and has not scored it itself; not in CISA KEV.** This is unsafe deserialization, CWE-502, in `JavaNativeMessageDecoder` in the MINA 3.0 codec module (`org.apache.mina:mina-core`). The decoder calls `ObjectInputStream.readObject()` on frame bytes with no class filter. Apache tags the issue **unsupported when assigned**: the 3.0.0 branch is inactive, and Apache will not release a version that fixes it. [Advisory][oss] [CNA][cve] [NVD][nvd]

**Attack conditions:** An application has to put this decoder in front of an untrusted peer. The advisory does not say the class is enabled by default, and it does not describe a configuration flag that turns it on. A deployment that never uses `JavaNativeMessageDecoder` is outside the described path. The CNA's default status for the product is unaffected, and the only affected range is the 3.0 line. [Advisory][oss] [CNA][cve]

**Worst case:** gadget-chain remote code execution in the process that decodes those frames, with the privileges of that process. The CVSS vector rates confidentiality, integrity and availability High. A gadget chain is not the same thing as a published exploit; Apache does not name one. [Advisory][oss] [CNA][cve]

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-01). The advisory does not mention exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and affected versions](#inventory-and-affected-versions)
  - [Reachability](#reachability)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Apache credits Nguyen Cuong. No report date is published. [Advisory][oss] |
| CVE reserved | 2026-10-28 17:16:55 UTC | CNA metadata. [CVE JSON][cve] |
| MINA 3.0.0-M2 on Maven Central | 2013-07-27 07:03:35 GMT | File Last-Modified of `mina-core-3.0.0-M2.jar`. There is no `3.0.0` release artifact (HTTP 404). [Maven Central][mvn-m2] |
| MINA 2.2.10 on Maven Central | 2026-10-14 02:35:25 GMT | Current artifact Apache's download page calls "stable (Java 8+)". The timestamp is the repository file's Last-Modified header, not a security release for this CVE. [Maven Central][mvn-2210] [Downloads][downloads] |
| **Public announcement**: oss-security and announce@ | 2026-10-31 08:01:38 +0000 | Emmanuel Lécharny (Apache). Severity critical, CVSS 3.1 9.8, affected 3.0.0 through 3.0.0-M2, no fix planned. [oss-security][oss] |
| CVE record published | 2026-10-31 20:17:11 UTC | Apache CNA. NVD lists published 2026-10-31 21:16:53, status "Received". [CVE JSON][cve] [NVD][nvd] |
| CISA KEV | Not listed as of catalog 2026.10.30 (checked 2026-11-01) | [KEV JSON][kev] |

## Detection

### Inventory and affected versions

1. Find every application that ships `org.apache.mina:mina-core`, including shaded JARs. Read-only ways to see the **resolved** version:
   - Maven: `mvn dependency:tree -Dincludes=org.apache.mina:mina-core`
   - Gradle: `gradle dependencies --configuration runtimeClasspath | grep mina-core`
   - Built artifacts: `find /opt/app -name 'mina-core-*.jar'`, or `unzip -l app.jar | grep mina-core` for a fat JAR.
   These list dependencies and change nothing; the build-tool commands may download metadata into your local cache. Check what is deployed, not only the source tree.
2. Compare the resolved version with the CNA record and Apache's download page:

   | Line | Status | Action |
   |---|---|---|
   | 3.0.0 through 3.0.0-M2 | Affected. Branch inactive. **No fix will be released.** Maven Central's latest 3.0 artifact is 3.0.0-M2 (2013); there is no 3.0.0 jar. | Stop using this decoder. Move to the latest 2.2.x (`mina-core` **2.2.10** on the download page). |
   | 2.2.x, 2.1.x, 2.0.x | CNA `defaultStatus` is unaffected. The advisory names only the 3.0 codec class. | Not this flaw. Stay on a current 2.2.x build for other reasons; 2.2.10 is what the project site lists as stable. |
   | Apache FtpServer, SSHD, Vysper | Separate products. The advisory does not name them. | Do not treat them as affected by this CVE. |

   [CNA][cve] [Advisory][oss] [Downloads][downloads]

The CNA version range is written `3.0.0` through `3.0.0-M2` with `versionType` maven. Read it as the 3.0 milestone line Apache describes, not as a claim that a final 3.0.0 jar exists. Maven Central has 3.0.0-M1 and 3.0.0-M2 only.

### Reachability

An affected `mina-core` JAR is not enough. The advisory's condition is that the application puts `JavaNativeMessageDecoder` in front of an untrusted peer. Search route and codec configuration read-only, for example `grep -RIn 'JavaNativeMessageDecoder' --include='*.java' --include='*.xml' .`. If that class is not referenced and no untrusted peer talks to a MINA 3.0 codec, the described path is not in use. If you cannot rule that out, treat the service as reachable.

Apache published **no indicators of compromise**. A successful gadget chain would look like unexpected child processes or outbound connections from the MINA process, not like a distinctive log line. Absence of those signs does not prove the decoder was not abused.

## Remediation

Apache's recommendation is to use the latest Apache MINA **2.2.x** branch. It does not plan a fixed 3.0 release. [Advisory][oss]

1. Remove `mina-core` 3.0.0-M1 and 3.0.0-M2 from every build. Depend on **2.2.10** (or a later 2.2.x release, if one appears) and rebuild.
2. The 2.x and 3.0 APIs are not the same generation. Moving a codec off `JavaNativeMessageDecoder` is an application change, not a drop-in jar swap. Do not leave the 3.0 jar on the classpath "just in case."
3. Redeploy and restart every process that loaded the 3.0 jar. Changing `pom.xml` does nothing until the running process uses the new artifact.
4. Until that deploy, do not expose a MINA 3.0 listener that uses `JavaNativeMessageDecoder` to an untrusted network. There is no configuration workaround in the advisory.

A serialization filter (`jdk.serialFilter` / `ObjectInputFilter`) is a general Java control. Apache does not document it as a fix for this class, so do not treat it as one.

## Verification

- Confirm the deployed artifact contains `mina-core` 2.2.10 (or another 2.2.x jar) and does **not** contain `mina-core-3.0.0-M1` or `mina-core-3.0.0-M2`. Example: `find /opt/app -name 'mina-core-*.jar'` on the deployed tree, then restart and confirm the process start time is after that deploy.
- Confirm application sources no longer reference `JavaNativeMessageDecoder`.
- As a benign functional control in a **test** environment, complete one ordinary protocol session the service is supposed to handle and confirm the expected result. Do not send gadget-chain payloads, and do not test against production.

## Compromise response

- If a MINA 3.0 service using this decoder was reachable by untrusted peers, preserve logs and the process image before you replace the jar.
- Assume the process's privileges were available to a remote caller: rotate credentials it could read, and review child processes, cron or scheduled tasks, and new listeners on that host.
- Replacing the jar does not remove a backdoor already written.

## Sources

- [oss-security announcement, 2026-10-31 08:01:38 +0000][oss] — severity critical, CVSS 3.1 9.8, affected versions, unsupported-when-assigned, recommendation to use 2.2.x, credit.
- [Apache announce@ thread][announce] — same text.
- [Apache CNA record][cve] — CVSS 3.1 9.8 vector, CWE-502, Maven package and version range, publication metadata. CISA ADP SSVC, added 2026-11-06T13:45:59Z, says Exploitation none, Automatable yes, Technical Impact total. That is not a KEV listing.
- [NVD][nvd] — status "Received"; displays Apache's 9.8 as the available CVSS 3.1 metric and has not scored it itself.
- [Apache MINA download page][downloads] — lists Mina 2.2.10 as stable (Java 8+). Does not mention this CVE.
- [Maven Central `mina-core` 2.2.10][mvn-2210] and [3.0.0-M2][mvn-m2] — artifact timestamps. 3.0.0 returns HTTP 404.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.30).

[oss]: https://www.openwall.com/lists/oss-security/2026/10/31/3
[announce]: https://lists.apache.org/thread/h76nwcrkvsffhsk2kq6cjzc6srtnty7x
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-118636
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-118636
[downloads]: https://mina.apache.org/downloads-mina_2_2.html
[mvn-2210]: https://repo1.maven.org/maven2/org/apache/mina/mina-core/2.2.10/mina-core-2.2.10.jar
[mvn-m2]: https://repo1.maven.org/maven2/org/apache/mina/mina-core/3.0.0-M2/mina-core-3.0.0-M2.jar
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
