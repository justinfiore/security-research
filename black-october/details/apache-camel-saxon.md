# Apache Camel: camel-saxon XQuery XML external entity processing

**Last updated:** 2026-10-26 (America/New_York)

[Main Apache Camel summary](../black-october-2026.md#apache-camel-camel-saxon-xquery-xml-external-entity-processing) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-90885](https://www.cve.org/CVERecord?id=CVE-2026-90885) — Apache (CNA) CVSS 3.1: 7.5 High (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N); Apache Camel advisory severity: High; NVD has not scored it (status "Received"); not in CISA KEV.** This is an XML external entity (XXE) flaw, CWE-611, in the `camel-saxon` component (`org.apache.camel:camel-saxon`). `XQueryBuilder`, which evaluates the `xquery` expression language and the `xquery:` component, built its default Saxon `Configuration` with the XML parser left at its defaults, so a DOCTYPE was accepted and external entities were resolved. [Advisory][advisory] [CNA][cve] [NVD][nvd]

**Attack conditions:** Camel's own type converters harden the parser when they turn a `String`, `byte[]` or `InputStream` body into a `javax.xml.transform.Source`, so those bodies were **not** affected. The flaw is reached only when the message body is **already a `Source` that still has to be parsed** (a stream-based `Source`) when an XQuery expression or `xquery:` endpoint evaluates it. Apache gives two examples: a route that calls `convertBodyTo(Source.class)` before the XQuery step, and a component or processor earlier in the route that sets the body to a stream-based `Source`. No non-default option is needed; the vulnerable default `Configuration` is used whenever the route does not supply its own. [Advisory][advisory]

**Worst case:** an external sender whose XML reaches XQuery in that form can **read files readable by the Camel process** and make the process **send requests to hosts named in the document** (server-side request forgery). The CVSS vector rates confidentiality impact High and integrity and availability None. [Advisory][advisory] [CNA][cve]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Apache's advisory does not mention exploitation, CISA's ADP SSVC assessment in the CVE record says Exploitation "none", and no public exploit or exploitation report was found in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and affected versions](#inventory-and-affected-versions)
  - [Reachability: is the vulnerable path used?](#reachability-is-the-vulnerable-path-used)
  - [Log and network review](#log-and-network-review)
- [Remediation](#remediation)
  - [Upgrade](#upgrade)
  - [Workarounds until you can upgrade](#workarounds-until-you-can-upgrade)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Apache credits Leon Zlobecki; no report date is published. The CVE record's `source.discovery` is "UNKNOWN". [Advisory][advisory] [CNA][cve] |
| JIRA issue CAMEL-24691 created | 2026-09-11 17:21:49 UTC | Titled "camel-saxon - align XQueryBuilder with secure XML parsing defaults". [JIRA][jira] |
| CVE reserved | 2026-09-14 08:19:08 UTC | CNA metadata. [CVE JSON][cve] |
| CAMEL-24691 resolved | 2026-09-22 07:10:17 UTC | Fix versions 4.18.5, 4.22.2, 4.23.0. Fixes: main PR #26344 (commit `9c23b68`), 4.22.x backport PR #26728 (`0d0ed8b`), 4.18.x backport PR #26730 (`ed513f3`). [JIRA][jira] [Advisory][advisory] |
| Camel 4.18.5 on Maven Central | 2026-10-06 (Maven Central file timestamp 10:41:18 GMT) | First fixed 4.18.x release. The timestamp is the repository file's Last-Modified header, not an Apache release announcement. [Maven Central][mvn] |
| Camel 4.23.0 on Maven Central | 2026-10-11 (file timestamp 16:05:07 GMT) | Fixed. [Maven Central][mvn] |
| Camel 4.22.2 on Maven Central | 2026-10-17 (file timestamp 16:02:28 GMT) | First fixed 4.22.x release. Apache notes that 4.22.1 had already been cut when the fix was backported, so **4.22.1 is affected**. [Maven Central][mvn] [Advisory][advisory] |
| **Public announcement**: Apache Camel advisory | 2026-10-22 (time/TZ unknown) | The advisory page shows "Published October 22, 2026". [Advisory][advisory] |
| oss-security announcement | 2026-10-23 07:42:06 +0000 | Posted by Andrea Cosentino (Apache) with the CVSS 3.1 7.5 vector and affected ranges. [oss-security][oss] |
| CVE record published | 2026-10-26 14:47:03 UTC | Apache CNA. NVD lists it as published 2026-10-26 15:16:45 (NVD API, UTC), status "Received". [CVE JSON][cve] [NVD][nvd] |
| CISA ADP SSVC assessment | 2026-10-26 15:29:02 UTC | Exploitation: none; Automatable: yes; Technical impact: partial. [CVE JSON][cve] |
| CISA KEV | Not listed as of catalog 2026.10.23 (checked 2026-10-26) | [KEV JSON][kev] |

## Detection

### Inventory and affected versions

1. Find every application, integration service or container that ships `org.apache.camel:camel-saxon`, including Camel Spring Boot and Camel Quarkus applications and fat JARs. Read-only ways to see the **resolved** version:
   - Maven: `mvn dependency:tree -Dincludes=org.apache.camel:camel-saxon`
   - Gradle: `gradle dependencies --configuration runtimeClasspath | grep camel-saxon`
   - Built artifacts: `unzip -l app.jar | grep camel-saxon` for a Spring Boot fat JAR, or `find /opt/app -name 'camel-saxon-*.jar'` for an unpacked deployment.
   These list dependencies and change nothing; the build-tool commands may download metadata into your local cache. Check what is deployed, not only the source tree.
2. Compare the resolved `camel-saxon` version with the CNA record:

   | Release line | Status | Action |
   |---|---|---|
   | 4.23.x | 4.23.0 fixed | None needed |
   | 4.22.x | 4.22.0–4.22.1 affected | 4.22.2 or later |
   | 4.19.x–4.21.x | Affected; end of life, **no fix** | Move to 4.22.2+ or 4.23.0+ |
   | 4.18.x | 4.18.0–4.18.4 affected | 4.18.5 or later |
   | 4.15.x–4.17.x | Affected; end of life, **no fix** | Move to a fixed supported line |
   | 4.0.x–4.14.x | Affected; end of life, **no fix** | Move to a fixed supported line |
   | 3.x and 2.x | Outside the CNA's listed range, but Apache says the code path "was already present in the 2.x and 3.x releases" | Treat as affected and unfixed; migrate |

   [CNA][cve] [Advisory][advisory]
3. Camel Quarkus has its own version numbers. Check which `camel-saxon` it resolves rather than comparing the Camel Quarkus version with the table.

### Reachability: is the vulnerable path used?

An affected `camel-saxon` JAR on the classpath is not enough. The flaw needs all of the following:

- The route evaluates XQuery: the `xquery(...)` expression or predicate in Java DSL, `<xquery>` in XML/YAML DSL, or an `xquery:` endpoint URI. Search route sources and configuration read-only, for example `grep -rnE 'xquery' src/ config/`.
- The body that reaches XQuery is **already a `javax.xml.transform.Source`** that still needs parsing (`StreamSource`, `SAXSource` and similar). Look for `convertBodyTo(Source.class)` or a `StreamSource`/`SAXSource` type before the XQuery step, and for components or custom processors upstream that set such a body. Apache says `String`, `byte[]` and `InputStream` bodies were protected by Camel's own converters. [Advisory][advisory]
- The route does not set its own Saxon `Configuration` (the `configuration` option of the endpoint or language). If it does, the fix does **not** change it: check that configuration's parse options yourself (see [Workarounds](#workarounds-until-you-can-upgrade)).
- The XML can come from an untrusted sender, for example over HTTP, JMS/AMQP/Kafka, file or FTP pickup, or email.

If you cannot rule out one of these conditions, treat the route as reachable.

### Log and network review

Apache published **no indicators of compromise**. XXE use usually shows up indirectly:

- Inbound XML messages that contain `<!DOCTYPE` with `SYSTEM` or `PUBLIC` identifiers, or `<!ENTITY ... SYSTEM`, in message archives, dead-letter queues, broker retention or tracing logs (for example Camel message history or tracing, if you enabled them).
- Outbound connections from the Camel host to unexpected hosts or to internal metadata services (such as `169.254.169.254`) in egress firewall, proxy or DNS logs, especially at the times such messages were processed.
- XQuery results or downstream messages that contain local file content (`/etc/passwd`, configuration files, keys).

Absence of these signs does **not** prove the path was not abused: many deployments do not keep message bodies, and file-reading XXE need not cause any outbound connection.

## Remediation

### Upgrade

1. Upgrade `camel-saxon` (normally the whole Camel BOM) to **4.23.0** or later, or within its line to **4.22.2+** or **4.18.5+**. Lines 4.19–4.21, 4.15–4.17 and 4.14 and earlier will not get a fix; move them to a supported fixed line. [Advisory][advisory]
2. Rebuild and redeploy every artifact. Updating `pom.xml` or `build.gradle` changes nothing until the running process uses the new JAR.
3. **Behaviour change:** after the fix, a body that reaches XQuery as an already-built `Source` and carries **any** DOCTYPE is rejected with a parse error. Bodies without a DOCTYPE are unaffected. Test routes that legitimately receive XML with a DOCTYPE; Apache records this in the 4.23 upgrade guide. [Advisory][advisory]
4. The fix hardens only Camel's **default** Saxon `Configuration`. A `Configuration` supplied through the `configuration` option, or through `XQueryBuilder.setConfiguration`, is used unchanged. If you supply one for any reason, apply the hardening below to it as well. [Advisory][advisory]
5. Fixing the related camel-xpath flaw [CVE-2026-85250](https://www.cve.org/CVERecord?id=CVE-2026-85250) (fixed in 4.18.5, 4.22.1 and 4.23.0) does not fix this one; in particular **4.22.1 fixes CVE-2026-85250 but not CVE-2026-90885**. This guide does not separately track CVE-2026-85250. [Advisory][advisory]

### Workarounds until you can upgrade

Apache documents two interim measures: [Advisory][advisory] [CNA][cve]

- Do not evaluate XQuery over a body that is already a `javax.xml.transform.Source` when it carries XML from an untrusted sender. For example, remove a `convertBodyTo(Source.class)` before the XQuery step, or convert the body to `String` first so that Camel's hardened converter parses it. Test that the route still works; this is a code change.
- Set the endpoint's or language's `configuration` option to a Saxon `Configuration` whose parse options **refuse a DOCTYPE declaration** and **disable external general entities, external parameter entities and external DTD loading**. Apache names these as the `disallow-doctype-decl`, `external-general-entities`, `external-parameter-entities` and `load-external-dtd` parser features, which is what the fixed releases now apply by default.

Egress filtering of the Camel host limits request-forgery and out-of-band exfiltration, but does not stop local file content being read into the XQuery result. It is not a fix.

## Verification

- Confirm the `camel-saxon` JAR inside each running artifact or container image is 4.18.5+, 4.22.2+ or 4.23.0+ (for example `unzip -l app.jar | grep camel-saxon` on the deployed JAR), and that the service was restarted.
- For routes that supply their own `Configuration`, review the code to confirm the four parser features above are set.
- As a benign functional control in a **test** environment, send a well-formed XML message without a DOCTYPE through the XQuery route and confirm the expected result. On a fixed build in a test environment, a message whose already-built `Source` body contains only a harmless internal DOCTYPE (no external identifiers) should be rejected with a parse error, as Apache describes. Do not send external-entity payloads that reference real files or hosts, and do not test against production.

## Compromise response

- If you find DOCTYPE/external-entity messages or unexplained outbound requests from Camel hosts, preserve message stores, broker data and logs before changing routes.
- Assume any file the Camel process could read may have been disclosed. Rotate credentials it could read: `application.properties`/`application.yaml` secrets, keystores and truststores, database and broker passwords, cloud credentials (including those reachable via instance metadata), and API tokens.
- Review internal services the host can reach for requests that came from it, since the flaw also allows server-side request forgery.
- Patch, then add XML-content monitoring for DOCTYPE declarations on untrusted inputs.

## Sources

- [Apache Camel advisory CVE-2026-90885][advisory] — description, attack conditions, affected and fixed versions, end-of-life lines, workarounds, fix commits, 4.22.1 note, relationship to CVE-2026-85250, Published October 22, 2026, severity High, credit.
- [Apache CNA record][cve] — CVSS 3.1 7.5 vector, CWE-611, Maven package and version ranges, publication metadata, CISA ADP SSVC.
- [NVD][nvd] — status "Received"; displays Apache's 7.5 as a secondary score.
- [JIRA CAMEL-24691][jira] — creation and resolution dates, fix versions.
- [Fix PR #26344 (main)][pr-main], [backport PR #26728 (4.22.x)][pr-422], [backport PR #26730 (4.18.x)][pr-418].
- [Maven Central `camel-saxon`][mvn] — release artifact timestamps.
- [oss-security post, 2026-10-23][oss] — Apache's mailing-list announcement.
- [SecurityOnline (secondary)][so] — reports no exploitation in the advisories and no confirmed public proof of concept.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.23).

[advisory]: https://camel.apache.org/security/CVE-2026-90885.html
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-90885
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-90885
[jira]: https://issues.apache.org/jira/browse/CAMEL-24691
[pr-main]: https://github.com/apache/camel/pull/26344
[pr-422]: https://github.com/apache/camel/pull/26728
[pr-418]: https://github.com/apache/camel/pull/26730
[mvn]: https://repo1.maven.org/maven2/org/apache/camel/camel-saxon/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[oss]: https://www.openwall.com/lists/oss-security/2026/10/23/6
[so]: https://securityonline.info/apache-camel-vulnerabilities-xxe-october-2026
