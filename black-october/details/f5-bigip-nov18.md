# F5 BIG-IP: six flaws crash the traffic process

**Last updated:** 2026-11-18 (America/New_York)

[Main BIG-IP summary](../black-october-2026.md#f5-big-ip-six-flaws-crash-the-traffic-process) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

F5 published six flaws on November 18. Each one lets a request with no login terminate the Traffic Management Microkernel, which is the process that handles the traffic, and F5 says each one may also run code. F5 rates every one **CVSS 3.1 9.8 Critical** and **CVSS 4.0 9.3 Critical**. F5 is the CNA. Each one needs a specific iRule or a specific APM policy on a virtual server. A virtual server without that configuration is outside that flaw. F5 lists no workaround for any of the six, and the only fixes are engineering hotfixes.

This is not the September APM flaw, [CVE-2026-94127](https://www.cve.org/CVERecord?id=CVE-2026-94127), which F5 says has been exploited and which is a different record.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-18) for any of the six. CISA's enrichment of CVE-2026-123637, dated 2026-11-18, says exploitation is none. F5's advisories do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-18 15:00 UTC** | K000164058 indexes 22 articles. CVE-2026-123637's record says `datePublic` 15:00 UTC. [F5][index] |
| **Last updated** | **2026-11-18 (America/New_York)** | New item. Install the hotfix for the configuration you run. |

## Detection

The six are not one range. Read the version, then read the virtual server's iRules and APM policy.

| CVE | The configuration that exposes it | Product |
|---|---|---|
| [CVE-2026-123637](https://www.cve.org/CVERecord?id=CVE-2026-123637) | APM provisioned, and a per-request policy with both the Client Information agent and Endpoint Security agents | BIG-IP APM |
| [CVE-2026-116953](https://www.cve.org/CVERecord?id=CVE-2026-116953) | An iRule uses `GENERICMESSAGE::route` on client traffic | BIG-IP, all modules, and BIG-IP Next for Kubernetes |
| [CVE-2026-120285](https://www.cve.org/CVERecord?id=CVE-2026-120285) | An HTTP profile and an iRule that uses `PSC::ip_address` | BIG-IP, all modules, BIG-IP CNF, and BIG-IP Next for Kubernetes |
| [CVE-2026-120292](https://www.cve.org/CVERecord?id=CVE-2026-120292) | An HTTP profile and an iRule that uses `MR::message route` | BIG-IP, all modules, and BIG-IP Next for Kubernetes |
| [CVE-2026-120722](https://www.cve.org/CVERecord?id=CVE-2026-120722) | An iRule uses `DNS::scrape` on client traffic | BIG-IP DNS and BIG-IP Next for Kubernetes |
| [CVE-2026-121805](https://www.cve.org/CVERecord?id=CVE-2026-121805) | An iRule uses `PEM::subscriber` on client traffic | BIG-IP PEM, BIG-IP CNF, and BIG-IP Next for Kubernetes |

F5's CVE record for CVE-2026-123637 names these affected floors, and says a version past the end of technical support was not evaluated:

| Branch | Affected | First engineering hotfix |
|---|---|---|
| 21.x | 21.1.0 | BIGIP-21.1.0.4.0.19.3-ENG |
| 17.5 | 17.5.0 and 17.5.1 | BIGIP-17.5.1.11.0.61.12-ENG and BIGIP-17.5.1.10.0.80.35-ENG |
| 17.1 | 17.1.0 through 17.1.3 | BIGIP-17.1.3.7.0.21.4-ENG and BIGIP-17.1.3.6.0.14.20-ENG |

The other five name their own hotfix builds in the article for that CVE. BIG-IP Next for Kubernetes is 2.4.0–2.4.2, 2.3.0–2.3.4, and 2.2.0–2.2.5, fixed in BNK-2.4.2-EHF1, BNK-2.3.4-EHF1, and BNK-2.2.5-EHF1 for CVE-2026-116953. A virtual server that does not use the command or the policy is outside that one flaw and can still be inside another.

## Remediation

1. Install the engineering hotfix named in the article for each flaw your configuration matches. F5 says these builds do not get the testing of a scheduled release, and that a system already on a custom hotfix needs a new one from F5 support. K000164239 is F5's note on that.
2. F5 lists no workaround and no mitigation for the six.
3. The same day's index has more articles, including ten for NGINX. Those are not these six. NGINX's HTTP/2 fix is [tracked separately](nginx.md).

## Verification

The running version matches the hotfix named for that branch and that flaw. Do not send a request to test the crash.

## Compromise response

F5 does not report exploitation, and CISA's same-day enrichment says none. A traffic process that restarted on its own, on a virtual server with one of these configurations, is the thing to look at. The hotfix does not show whether a request already ran code. F5 says the management plane is not exposed by these six.

## Sources

- [K000164058][index] — November 18, 2026. The index of 22 articles, including the six.
- [CVE-2026-123637](https://www.cve.org/CVERecord?id=CVE-2026-123637) — F5, published 2026-11-18T15:23:26Z, public at 15:00 UTC. CVSS 3.1 9.8 and CVSS 4.0 9.3. Workaround: none. Credit Sina Kheirkhah of watchTowr.
- [K000163937](https://my.f5.com/manage/s/article/K000163937) — the APM article the CVE record cites.
- [K000163946](https://my.f5.com/manage/s/article/K000163946) — CVE-2026-121805. Read November 18. Same scores, BIG-IP PEM, engineering hotfixes only, no mitigation.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, released 2026-11-18T19:17:41.0354Z. None of the six is listed.

[index]: https://my.f5.com/manage/s/article/K000164058
