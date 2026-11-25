# Jenkins: November plugin security fixes

**Last updated:** 2026-11-25 (America/New_York)

[Main Jenkins summary](../black-october-2026.md#jenkins-a-sandboxed-pipeline-runs-code-on-the-controller) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Jenkins rates seven issues in its [November 25 advisory][jenkins] High and publishes no numeric score. The High ones are in Pipeline: Groovy, Script Security, Gradle, Warnings, Configuration as Code, Performance, and Rich Text Publisher. Each needs a permission the advisory names. None is a request with no login. This is not the [October core advisory](jenkins-october.md).

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-25) for any of the 21 CVEs. Jenkins reports no exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [The High issues](#the-high-issues)
- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## The High issues

Jenkins labels each of these High. The Medium issues in the same advisory are listed under Remediation and are not the reason for this entry.

- [CVE-2026-136834](https://www.cve.org/CVERecord?id=CVE-2026-136834) (SECURITY-4152), Pipeline: Groovy through 4403.v471713a_cea_19. A non-constant interface field initializer is not sandboxed. Someone who can define and run a sandboxed Pipeline runs code in the controller JVM. Fixed in 4403.4405.va_b_cdb_b_d0b_89f.
- [CVE-2026-136835](https://www.cve.org/CVERecord?id=CVE-2026-136835) (SECURITY-4278), Script Security through 1436.v1082791135e4. A partially qualified `@Builder` name makes Groovy instantiate the named class at compile time, before the sandbox. Jenkins says this needs a suitable class already on that classpath, and that it is an incomplete fix of SECURITY-3925. Fixed in 1436.1438.v3dc5ef7d16f2.
- [CVE-2026-136836](https://www.cve.org/CVERecord?id=CVE-2026-136836) (SECURITY-4075), Gradle through 2.21.1282.v024680ce00a_b_. The controller reads `.mvn/extensions.xml` from a build workspace without blocking external entities. Someone who controls the workspace can read a secret from the controller or make it request a URL. Only controllers with Develocity Maven auto-injection enabled. Fixed in 2.22.1283.v53b_41fe4cb_d9.
- [CVE-2026-136837](https://www.cve.org/CVERecord?id=CVE-2026-136837) (SECURITY-4325), Warnings 13.10251.va_452d3553728 through 13.10365.v85cd7a_c8110b_, both inclusive. An inline Groovy parser is compiled on the controller to validate it, with no sandbox. Someone who can define that parser runs code in the controller JVM. Fixed in 13.10365.10367.v2db_e2de17661. Warnings before 13.10251 is outside the range Jenkins names.
- [CVE-2026-136840](https://www.cve.org/CVERecord?id=CVE-2026-136840) (SECURITY-4429), Configuration as Code 2134.ve13a_2fc90835 through 2147.v8a_8d38668c72, both inclusive, except 2140.2142.v3836c98f1b_30. The validation endpoint resolves variables in a submitted YAML document, including files on the controller, and returns a resolved value in the error. Someone with Overall/SystemRead reads those files. Jenkins says that read can lead to code execution. Only controllers that have granted Overall/SystemRead. Fixed in 2148.v9d0c041b_a_13c.
- [CVE-2026-136842](https://www.cve.org/CVERecord?id=CVE-2026-136842) (SECURITY-4285), Performance through 1024.ve69e11844523. A Taurus XML report sets an external report link to a `javascript:` URL, and the build page keeps it. Someone who controls that report runs script in a browser that opens the page. Jenkins says Content Security Policy on 2.539 and newer, and LTS 2.541.1 and newer, mitigates it. Fixed in 1025.ve64297f8ccb_c.
- [CVE-2026-136854](https://www.cve.org/CVERecord?id=CVE-2026-136854) (SECURITY-4449), Rich Text Publisher through 1.5. A job name is not escaped in an error the Rich Text Portlet shows. Someone with View/Configure permission stores script there. The same Content Security Policy mitigates it. Fixed in 1.6.

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Public advisory and fixes | 2026-11-25; time/TZ unknown | Seven High and four Medium issues across eleven plugins. [Jenkins advisory][jenkins] |

## Detection

1. On each controller, open the plugin manager and record the installed version of Pipeline: Groovy (`workflow-cps`), Script Security, Gradle, Warnings (`warnings-ng`), Configuration as Code, Performance, and Rich Text Publisher.
2. Compare each to the floor in the table below. A plugin that is not installed is outside that issue.
3. The Gradle issue applies only where Develocity Maven auto-injection is enabled. The Configuration as Code issue applies only where Overall/SystemRead is enabled and granted. Record both settings; do not treat a controller that has neither as exposed to those two.

## Remediation

Update each installed plugin to at least the version Jenkins names. Restart if the plugin manager says the update needs one.

| Plugin | High CVE | Update to |
|---|---|---|
| Pipeline: Groovy | CVE-2026-136834 | 4403.4405.va_b_cdb_b_d0b_89f |
| Script Security | CVE-2026-136835 | 1436.1438.v3dc5ef7d16f2 |
| Gradle | CVE-2026-136836 | 2.22.1283.v53b_41fe4cb_d9 |
| Warnings | CVE-2026-136837 | 13.10365.10367.v2db_e2de17661 |
| Configuration as Code | CVE-2026-136840 | 2148.v9d0c041b_a_13c |
| Performance | CVE-2026-136842 | 1025.ve64297f8ccb_c |
| Rich Text Publisher | CVE-2026-136854 | 1.6 |

The same advisory fixes four Medium issues. Update those plugins in the same pass: Nested View to 262.v4e24ddfe477e (CVE-2026-136841), Pipeline DORA Metrics to 43.v0b_b_d09ef2440 (CVE-2026-136845 through CVE-2026-136853), Spira Importer to 58.v33212b_f5b_2d1 (CVE-2026-136843 and CVE-2026-136844), and Subversion to 1349.v15e470a_46048 (CVE-2026-136838 and CVE-2026-136839).

Until the update, keep Item/Configure, Overall/SystemRead, and Pipeline authoring limited to people you trust, and leave Content Security Policy enforced. Those are exposure reductions, not substitutes for the update. Do not submit a crafted Pipeline, XML file, or YAML document to a production controller to test any of these.

## Verification

- Confirm the plugin manager shows each installed plugin at or above the version in the table, and that no update is waiting on a restart.
- Run one trusted Pipeline and one trusted build on a non-production controller after the update. Do not use a crafted script, report, or configuration file as the test.

## Compromise response

If a controller let someone you do not trust define a Pipeline, a Groovy parser, a workspace file, or a configuration document while it was below these floors, preserve the controller audit log and the job configuration history. Review new jobs, changed credentials, and new agent connections. Rotate credentials the controller could read. Where the controller's integrity is uncertain, rebuild it from a known-good backup. The update does not undo a job or a credential that was already changed.

## Sources

- [Jenkins Security Advisory 2026-11-25][jenkins] — severity, affected versions, who can reach each issue, and the fixed versions. Jenkins publishes no numeric score.
- [CVE-2026-136834](https://www.cve.org/CVERecord?id=CVE-2026-136834), [CVE-2026-136835](https://www.cve.org/CVERecord?id=CVE-2026-136835), [CVE-2026-136836](https://www.cve.org/CVERecord?id=CVE-2026-136836), [CVE-2026-136837](https://www.cve.org/CVERecord?id=CVE-2026-136837), [CVE-2026-136840](https://www.cve.org/CVERecord?id=CVE-2026-136840), [CVE-2026-136842](https://www.cve.org/CVERecord?id=CVE-2026-136842), [CVE-2026-136854](https://www.cve.org/CVERecord?id=CVE-2026-136854) — Jenkins CNA records. Each points at the advisory.
- [CISA KEV JSON][kev] — catalog 2026.11.25, released 2026-11-25T19:48:12.4344Z, checked 2026-11-25. None of the 21 is listed.

[jenkins]: https://www.jenkins.io/security/advisory/2026-11-25/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
