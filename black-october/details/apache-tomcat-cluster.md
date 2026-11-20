# Apache Tomcat: a cluster node joins without being checked

**Last updated:** 2026-11-20 (America/New_York)

[Main Tomcat summary](../black-october-2026.md#apache-tomcat-a-cluster-node-joins-without-being-checked) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Apache Tomcat is the Java application server. When several Tomcat servers run as a cluster, they share session state, and the cluster can be secured with TLS using a pre-shared key (TLS-PSK). On TLS 1.3 that key exchange does not check who the other node is.

Apache rates [CVE-2026-133325](https://www.cve.org/CVERecord?id=CVE-2026-133325) **Critical**. Apache is the CNA. The record gives the word "critical" and no numeric CVSS score. A node that has no credential can join a cluster that is secured with TLS 1.3 and TLS-PSK. Apache says the flaw is a key exchange without entity authentication, CWE-322. The affected builds are **11.0.28 to 11.0.29**, **10.1.62**, and **9.0.124**. The fixes are **11.0.30**, **10.1.63**, and **9.0.125**, and Apache's security pages mark all three **not yet released**. Until they are, Apache says to switch the cluster to TLS 1.2.

A cluster that does not use TLS-PSK, and a cluster that uses TLS-PSK on TLS 1.2, is outside the condition Apache names. A Tomcat that is not in a cluster is outside it too. Tomcat 10.0 is end of life and is not in the affected list.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-20). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to the Tomcat security team | 2026-11-16; time/TZ unknown | Reported by Mike Read (GitHub: Michael-JRead). [Apache][sec11] |
| **Public announcement** | **2026-11-19; time/TZ unknown** | Apache's security pages list the flaw as Critical and the fixed builds as not yet released. [Apache][sec11] |
| **Last updated** | **2026-11-20 (America/New_York)** | New item. Switch an affected cluster to TLS 1.2 until the fixed build ships. |

## Detection

Read the running version, not the package you meant to install. The affected builds are exactly **11.0.28**, **11.0.29**, **10.1.62**, and **9.0.124**. A build outside those is outside the range Apache names.

The flaw only applies where the cluster is secured with TLS-PSK and that channel is negotiated as TLS 1.3. A server that is not clustered, or whose cluster channel is plain TCP or TLS 1.2, is not in the condition Apache describes. The version check does not show whether a node already joined.

## Remediation

| Line | What Apache says | Source |
|---|---|---|
| 11.0.28 to 11.0.29 | Fixed in **11.0.30**, marked not yet released. Until then, switch the cluster to TLS 1.2. | [security-11][sec11] |
| 10.1.62 | Fixed in **10.1.63**, marked not yet released. Until then, switch the cluster to TLS 1.2. | [security-10][sec10] |
| 9.0.124 | Fixed in **9.0.125**, marked not yet released. Until then, switch the cluster to TLS 1.2. | [security-9][sec9] |
| Any other build | Apache's record marks it unaffected. | [CVE record][cve] |

1. On an affected build, switch the cluster's TLS-PSK channel to **TLS 1.2** now, and restart the cluster. Apache's own recommendation is that switch. The fixed builds are not on the download pages yet: 11.0.30, 10.1.63, and 9.0.125 all return 404 from the download CDN.
2. When 11.0.30, 10.1.63, or 9.0.125 is released, upgrade to it and restart. The CVE record text says "9.0.123 (when released)" and "TLS 1.2 and PLDS-PSK"; the security pages, which are newer than that text, say 9.0.125 and TLS 1.2. Follow the security pages.
3. Switching the protocol does not remove a node that already joined, and it does not undo a session that node already read or wrote.

## Verification

- The running build is one Apache lists as unaffected, or the cluster channel no longer negotiates TLS 1.3.
- Sessions still replicate between the nodes you trust after the change.
- Do not stand up a node without the key to test whether it is accepted.

## Compromise response

Apache does not report exploitation. A cluster that was on an affected build, secured with TLS-PSK on TLS 1.3, and reachable by a host you do not account for should be treated as one whose session state may have been read or changed.

Look for a cluster member you did not deploy. The protocol change does not evict one. Sessions that were live while the channel was exposed should be expired, and a credential that lived in one should be rotated. The upgrade, when it ships, does not do that.

## Sources

- [Apache Tomcat 11 security][sec11] — "Critical: Cluster TLS-PSK configured to use TLS 1.3 does not validate peer." Affects 11.0.28 to 11.0.29. Fixed in 11.0.30, marked not yet released. Until then, switch to TLS 1.2. Reported 2026-11-16, made public 2026-11-19. Commit 2e6c85ba.
- [Apache Tomcat 10 security][sec10] — the same text. Affects 10.1.62. Fixed in 10.1.63, marked not yet released. Commit 8dcddccc.
- [Apache Tomcat 9 security][sec9] — the same text. Affects 9.0.124. Fixed in 9.0.125, marked not yet released. Commit 8dac862e.
- [CVE-2026-133325][cve] — Apache Software Foundation, CWE-322, severity given as the word "critical" with no CVSS score. Names 11.0.29, 10.1.62, and 9.0.124, and recommends TLS 1.2 or 11.0.30, 10.1.63, or 9.0.123 when released. Credit: Mike Read (GitHub: Michael-JRead).
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-20. CVE-2026-133325 is not listed.

[sec11]: https://tomcat.apache.org/security-11.html
[sec10]: https://tomcat.apache.org/security-10.html
[sec9]: https://tomcat.apache.org/security-9.html
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-133325
