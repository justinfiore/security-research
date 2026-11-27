# RealVNC: a UDP connection runs code before login

**Last updated:** 2026-11-27 (America/New_York)

[Main RealVNC summary](../black-october-2026.md#realvnc-a-udp-connection-runs-code-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

RealVNC published [RVNC-2026-001][adv] on 2026-11-20. It rates the flaw **Critical, CVSS 9.8**. The advisory says the CVE ID was pending. MITRE published [CVE-2026-137738](https://www.cve.org/CVERecord?id=CVE-2026-137738) on 2026-11-27 and scores it **CVSS 3.1 9.8 Critical**, vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. A UDP connection can run code before login, or crash the software. RealVNC says that on certain platforms the code runs as root. It does not name those platforms. TCP-only direct connections are not exposed. Cloud-hosted connectivity and manually configured direct connections, including offline and on-premises installs, are.

RealVNC says it is not aware of active exploitation. The record does not report exploitation.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-27). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-20; time/TZ unknown** | RVNC-2026-001. CVE pending. Critical, CVSS 9.8. [Advisory][adv] |
| Advisory page updated | 2026-11-25 11:14; timezone not stated on the page | The published and last-updated fields on the page still say 20 November 2026. |
| **CVE record** | **2026-11-27; time/TZ unknown** | MITRE published CVE-2026-137738. CVSS 3.1 9.8. [CVE][cve] |

## Detection

Read the version of each RealVNC application. The advisory's affected ranges are:

| Application | Affected |
|---|---|
| RealVNC Viewer (Windows, macOS, Linux) | 8.4.0 through 8.6.1 |
| RealVNC Classic Viewer | 6.4.0 through 7.18.2 |
| RealVNC Server | 6.4.0 through 7.19.0 |
| RealVNC Connect App | 8.6.1 and earlier |
| RealVNC On-Demand Assist | 3.4.1 and earlier |
| RealVNC Viewer for iOS | 3.7.0 through 4.9.5 |
| RealVNC Viewer for Android | 3.5.0 through 4.9.5 |
| RealVNC Server for iOS | 2.8.1 and earlier |
| RealVNC Server for Android | 2.8.3 and earlier |

A deployment that uses only TCP direct connections is outside the path the advisory names. A version this table does not list is unknown, not safe. Reading the version changes no state.

## Remediation

1. Update each application to the build the advisory names, and remove older copies of On-Demand Assist that users downloaded:
   - RealVNC Viewer **8.6.2**
   - RealVNC Connect App **8.6.2**
   - RealVNC Classic Viewer **7.18.3**
   - RealVNC Server **7.19.1**
   - RealVNC On-Demand Assist **3.5.0**
   - RealVNC Viewer for iOS and Android **4.9.6**
   - RealVNC Server for iOS **2.8.2**
   - RealVNC Server for Android **2.8.4**
2. Mobile applications should update from the store. Confirm the version after the update.
3. Until the update, TCP-only direct connections are the path the advisory says is not exposed. That is not a substitute for the build.

## Verification

- Each installed application shows the fixed version above.
- Do not send a crafted UDP packet to test it.

## Compromise response

RealVNC does not report exploitation. A server that was reachable over UDP before the update should be reviewed for a process or an account the owner did not add. The update does not remove one. The advisory publishes no indicator.

## Sources

- [RVNC-2026-001][adv] — published 2026-11-20. Critical, CVSS 9.8. CVE pending at publication. Fixed builds listed above. No active exploitation known to RealVNC.
- [CVE-2026-137738][cve] — MITRE, published 2026-11-27. CVSS 3.1 9.8 Critical. CWE-787.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-27. CVE-2026-137738 is not listed.

[adv]: https://help.realvnc.com/hc/en-us/articles/40824627217949-Security-Advisory-UDP-based-connection-vulnerability
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-137738
