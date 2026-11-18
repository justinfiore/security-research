# Confluence Data Center: a SOAP fault runs code

**Last updated:** 2026-11-18 (America/New_York)

[Main Confluence summary](../black-october-2026.md#confluence-data-center-a-soap-fault-runs-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-90436](https://www.cve.org/CVERecord?id=CVE-2026-90436) is in Apache Axis 1.x, which Confluence uses for its XML-RPC and SOAP APIs. A SOAP fault names a class. Axis loads that class, and runs its static initializer, before it checks that the class is one Axis itself uses. Apache says a suitable class on the application's classpath leads to remote code execution, and that authentication configured on the service does not run in time to stop it.

Apache is the CNA. It rates the flaw **critical** in text and publishes no numeric score. Axis 1 is end of life, and Apache says it will not ship a fixed 1.x release. The choices Apache names are to move to another SOAP engine, such as Axis 2, or to build Axis with [commit 41f3b4e](https://github.com/apache/axis-axis1-java/commit/41f3b4e8d04e310ca81f86b92630ab2c11d608bd). CISA's enrichment of the same record scores it **CVSS 3.1 9.8 Critical** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`). NVD has not scored it.

Atlassian rates the same flaw **CVSS 4.0 9.3 Critical** for Confluence (`CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`). Confluence Data Center **1.x through 9.x** is affected when **Remote API (XML-RPC & SOAP)** is turned on. That setting has been off by default for new installations since Confluence 3.0, and Confluence 10 removed the feature. Atlassian Cloud is not affected. The fix Atlassian names is **9.2.28**.

This is not the [October file-read](atlassian-dc.md), CVE-2026-21589. The N-central chain that starts from the same Axis flaw is tracked with [N-central](n-central.md).

**CISA KEV:** Not listed (catalog 2026.11.17, checked 2026-11-18). Rapid7 says that on November 13 its MDR service detected exploitation of this flaw against Confluence Data Center in a customer environment, from 192.238.253.176, 5.133.47.243, 163.182.68.109, and 104.13.106.166. Its November 17 update also names `*.trycloudflare.com`, `wpefh-192-238-253-176.free.pinggy.net`, and `webhook.site`. Rapid7 says not seeing those does not clear an environment. CISA's SSVC record, dated 2026-11-10, says exploitation is none, and that record predates Rapid7's detection. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Apache announcement | 2026-11-06 15:32 UTC | Robert Lazarski posted the notice to java-user. Severity: critical. Axis 1.x through 1.4. No fixed release. Credit: José Apari-Pantigozo, OKIOK. [Announce][announce] |
| CVE record published | 2026-11-06 15:37:55 UTC | Apache CNA. Updated 2026-11-10 18:37:36 UTC, which is the CISA-ADP score and SSVC, not a new description. [CVE][cve] |
| Atlassian advisory | 2026-11-09 22:00 PST (UTC−08:00) | Confluence Data Center only. Fixed version 9.2.28. Page last modified 2026-11-10. [Advisory][adv] |
| Rapid7 detection | 2026-11-13; time/TZ unknown | Exploitation against Confluence Data Center in one customer environment. Published 2026-11-16. [Rapid7][r7] |
| Rapid7 indicator update | 2026-11-17; time/TZ unknown | Adds `*.trycloudflare.com`, a pinggy.net host, and `webhook.site` to the four addresses. [Rapid7][r7] |
| **Last updated** | **2026-11-18 (America/New_York)** | The new indicators. The fix is unchanged. |

## Detection

1. Read the Confluence version on every node. **10.0 and later** removed the Remote API and Atlassian says those versions are not affected. **9.2.28** is the only fixed version Atlassian names on the 9.x line. A 9.x build below that, and every 8.x and earlier Data Center build, is inside the advisory's affected list.
2. The setting that makes Confluence reachable is **Remote API (XML-RPC & SOAP)**, under General Configuration, Further Configuration (`/admin/viewspacesconfig.action`). Off is the default for a new installation since Confluence 3.0. A site that has never turned it on is outside the condition Atlassian describes.
3. Request `<base_url>/plugins/servlet/soap-axis1/confluenceservice-v2`. Atlassian says a working mitigation returns HTTP 403. A page that mentions `confluenceservice-v2` or an AXIS service means the API is still answering. Do not send a SOAP fault to test it.
4. Atlassian says it cannot tell you whether an instance was already used this way, and it publishes no log signature. A 403 now does not show whether the endpoint answered earlier.

## Remediation

1. Upgrade Confluence Data Center to **9.2.28 or later** on the 9.2 line, or to **10.0 or later**, where the Remote API is gone. Restart every node.
2. If you cannot upgrade yet, clear the Remote API checkbox and save. Atlassian says the change takes effect without a restart, and that scripts, automations, and add-ons that use XML-RPC or SOAP stop working. Test that on a non-production site first.
3. Do not wait for an Axis 1.4.1. Apache says it will not release one. Rebuilding Axis yourself is the option Apache offers to someone who ships Axis; it is not the path Atlassian documents for Confluence.
4. Confluence Cloud, on an `atlassian.net` domain, needs no action for this advisory.

## Verification

- The running build is **9.2.28 or later**, or **10.0 or later**, on every node, and the nodes were restarted after the upgrade.
- Or the Remote API checkbox is clear, and the SOAP URL returns HTTP 403.
- A page that should still work, one that does not depend on XML-RPC or SOAP, still loads.
- Do not post a crafted SOAP fault at the service.

## Compromise response

Atlassian publishes no indicator for this flaw and says to have the local security team check affected instances. Rapid7 names four source addresses from the November 13 detection: 192.238.253.176, 5.133.47.243, 163.182.68.109, and 104.13.106.166. Its November 17 update adds three more: any host under `trycloudflare.com`, `wpefh-192-238-253-176.free.pinggy.net`, and `webhook.site`. A hit in the access log is a reason to investigate. No hit is not a clean result. If the Remote API was on and reachable while the build was below 9.2.28, review administrator accounts, add-ons, and scheduled jobs for changes nobody made, and rotate credentials stored in Confluence. The upgrade does not remove an add-on or an account that was already created. The N-central miner paths in the [N-central guide](n-central.md#detection) are for that product, not for Confluence.

## Sources

- [Atlassian advisory][adv] — release date Tue, Nov 9 2026 22:00 PST. CVSS 4.0 9.3. Confluence Data Center 1.x through 9.x when the Remote API is on. Fixed in 9.2.28. Removed in 10.0. Cloud is not affected. Last modified Nov 10, 2026.
- [Apache announcement][announce] — 2026-11-06 15:32 UTC. Critical, no number. Axis 1.x through 1.4, unsupported when assigned. No fixed release.
- [CVE-2026-90436][cve] — Apache CNA, published 2026-11-06 15:37:55 UTC. CISA-ADP CVSS 3.1 9.8, added 2026-11-10. SSVC exploitation: none.
- [Rapid7][r7] — published 2026-11-16. On November 13, Rapid7 MDR detected exploitation against Confluence Data Center in a customer environment. Four source addresses. Absence of those addresses does not clear an environment.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, checked 2026-11-16. CVE-2026-90436 is not listed.

[r7]: https://www.rapid7.com/blog/post/etr-rapid7-detected-exploitation-of-cve-2026-90436-against-atlassian-confluence-data-center-n-able-n-central-also-exploited/
[adv]: https://confluence.atlassian.com/security/cve-2026-90436-remote-code-execution-in-confluence-data-center-1874560038.html
[announce]: https://lists.apache.org/thread/8slf0j9gz35z56t0glt5h0ncwlbn4bdz
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-90436
