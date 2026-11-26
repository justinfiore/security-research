# Apache Allura: a ticket runs script in the browser

**Last updated:** 2026-11-26 (America/New_York)

[Main summary](../black-october-2026.md#apache-allura-a-ticket-runs-script-in-the-browser) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Apache Allura is a software forge: it hosts source repositories, tickets, and wiki pages. A ticket can carry script that runs in the browser of whoever opens it.

**The Apache Allura project rates [CVE-2026-135660](https://www.cve.org/CVERecord?id=CVE-2026-135660) critical.** The CVE record, published 2026-11-24, carries that word and no numeric CVSS score from Apache. CISA-ADP added **CVSS 3.1 6.1 Medium** on 2026-11-25, vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:L/I:L/A:N`, and its SSVC says exploitation is none. The two ratings disagree, and both stay. The weakness is CWE-79, script in a web page, in the ticket tracker. **Allura before 1.23.0** is affected. The 1.23.0 release note says the same flaw affects Allura **through 1.22.1**, and that 1.23.0 is the fix. The release note and the CVE record agree on the fixed version and disagree on whether 1.22.1 is the last affected build or merely before 1.23.0. Nothing between them is named. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-26). CISA-ADP's SSVC says exploitation is none. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **1.23.0 released** | **2026-11-23; time/TZ unknown** | The release note is dated Monday, November 23, 2026, and prints no time. [Release][rel] |
| Advisory to the users list | 2026-11-23 22:54 UTC | Dave Brondsema. Severity critical. Affected: before 1.23.0. [Mail][mail] |
| **CVE published** | **2026-11-24 11:31:09 UTC** | The record repeats the mailing-list text and adds no score. [CVE-2026-135660](https://www.cve.org/CVERecord?id=CVE-2026-135660) |
| **CISA-ADP score** | **2026-11-25 18:38:31 UTC** | CVSS 3.1 6.1 Medium. Apache's rating stays critical with no number. SSVC exploitation none. |
| **Last updated** | **2026-11-26 (America/New_York)** | The CISA-ADP score. The fix is still 1.23.0. |

## Detection

Read the running Allura version. 1.22.1 and anything older is in scope. A forge that does not let untrusted people file or edit tickets is a smaller target, and the advisory does not say that configuration is safe.

## Remediation

Upgrade to **Allura 1.23.0 or later**. The project says to upgrade to the prior release first, and to stop running Allura services during the upgrade. Install dependencies with:

```
pip install -r requirements.txt --no-deps --upgrade --upgrade-strategy=only-if-needed
```

1.23.0 also removes the ForgeChat tool. If it was installed, uninstall the package and delete its tool config. That cleanup is not the security fix. The upgrade does not show whether a ticket already ran script in someone's browser.

## Verification

The running forge reports 1.23.0 or later, and the services were restarted after the upgrade. Do not file a ticket that contains script to test it.

## Compromise response

A ticket is visible to whoever the tracker shows it to, which on a public forge can be anyone. If a ticket from before the upgrade contains markup you did not write, treat the sessions of the people who opened it as exposed: passwords and keys typed into that browser afterward are the thing to rotate. The upgrade does not remove a ticket that is already stored.

## Sources

- [Apache Allura 1.23.0 release note][rel] — published Monday, November 23, 2026, no time. Severity critical. Affects Allura through 1.22.1. Fixed in 1.23.0. The upgrade steps are on this page.
- [users@allura.apache.org, 2026-11-23 22:54 UTC][mail] — the same text the CVE record uses. Affected: before 1.23.0.
- [CVE-2026-135660](https://www.cve.org/CVERecord?id=CVE-2026-135660) — published 2026-11-24 11:31:09 UTC. Apache calls it critical and publishes no numeric score. CISA-ADP added CVSS 3.1 6.1 Medium on 2026-11-25 18:38:31 UTC. Affected from 0 before 1.23.0.
- [CISA KEV JSON][kev] — catalog 2026.11.25, released 2026-11-25T19:48:12.4344Z, checked 2026-11-26. Not listed.

[rel]: https://allura.apache.org/posts/2026-allura-1.23.0.html
[mail]: https://lists.apache.org/thread/4v50l6k8blgox9w56b9vs11cso7odwh6
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
