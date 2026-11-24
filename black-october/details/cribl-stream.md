# Cribl Stream: a collector response runs code

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#cribl-stream-a-collector-response-runs-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-23 Cribl published five CVE records for self-hosted Cribl Stream and Cribl Edge. Cribl v4.21, released 2026-11-18, is the fix. The notices use CVSS 4.0. The CSAF files also carry CVSS 3.1, and the two versions disagree on one of them.

[CVE-2026-115899](https://www.cve.org/CVERecord?id=CVE-2026-115899) is code injection in REST Collector pagination. **Cribl rates it CVSS 4.0 9.3 Critical and CVSS 3.1 9.8 Critical.** The vectors are `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N` and `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Someone who controls the pagination data an existing REST Collector reads can run code as the Worker service account, when that Collector uses response-based pagination and processes the data during a job. Cribl is the CNA.

[CVE-2026-115873](https://www.cve.org/CVERecord?id=CVE-2026-115873) is code injection in the nested expression compiler. **Cribl rates it CVSS 3.1 9.9 Critical and CVSS 4.0 8.7 High.** The vectors are `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H` and `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. A user with Read Only access to one Worker Group who can reach the Leader API runs code as the Leader service account. Both scores stay.

Three more are High on CVSS 4.0. [CVE-2026-115900](https://www.cve.org/CVERecord?id=CVE-2026-115900) is 8.7: a Worker that already has a distribution credential sends a heartbeat that bypasses Leader REST authentication. Where mTLS is required, the attacker also needs an accepted client certificate. [CVE-2026-115901](https://www.cve.org/CVERecord?id=CVE-2026-115901) is 8.5: a crafted sign-in link runs script in an existing Cribl session and discloses that session's token. [CVE-2026-115903](https://www.cve.org/CVERecord?id=CVE-2026-115903) is 7.1, and it is in Cribl Edge: Read Only access to the file APIs reads files the Edge process can read.

**Self-hosted Cribl Stream 4.20.4 and earlier, and Cribl Edge 4.20.4 and earlier, are affected.** Cribl says 4.20.4 was Cloud-only and is the same as 4.20.3 for an on-premises install. **4.21** is the fix for both. Cribl manages a Cloud Leader's upgrade. A managed Edge node still has to be upgraded, and upgrading only the Leader does not fix the Edge node. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.23, checked 2026-11-23) for any of the five. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Cribl 4.21 | 2026-11-18; time/TZ unknown | The release that contains the fixes. The CVE records came later. [Trust Center][trust] |
| **Public announcement** | **2026-11-23 08:25:07 UTC** | CSAF initial release for all five. The Trust Center notice is 08:57 AM the same day, and it does not name a timezone. [cribl-2026-0007][c7] |

## Detection

Read the running version on the Leader, on each Worker, and on each Edge node. **4.20.4 and earlier** is inside the range. A deployment that is not Cribl Stream or Cribl Edge is outside it. Cribl Cloud's Leader is Cribl's to upgrade; the version that matters there is the Edge node. Reading the version changes no state.

The REST Collector flaw needs a Collector that uses response-based pagination. The expression-compiler flaw needs a GroupRead user who can reach the Leader API. Neither condition being absent is proof the build is fixed.

## Remediation

1. Upgrade self-hosted Cribl Stream to **4.21 or later**.
2. Upgrade Cribl Edge nodes to **4.21 or later**. On a managed Edge deployment, upgrade a self-hosted Leader first, then the Edge nodes. Upgrading only the Leader leaves the Edge flaw in place.
3. Cribl manages a Cloud Leader. The Edge nodes on that deployment still need the upgrade.
4. The upgrade does not show whether a job already ran code, or whether a Leader session was already taken.

## Verification

- The running Leader, Worker, and Edge versions are **4.21 or later**.
- Do not send a crafted pagination response or a crafted heartbeat to test it.

## Compromise response

No source read for this entry reports an incident. If a REST Collector reads pagination from a service you do not trust, review what that Worker account could reach before the upgrade. The upgrade does not undo a job that already ran.

## Sources

- [Cribl Trust Center notice][trust] — published 2026-11-23 08:57 AM, timezone not stated. Five CVEs. Affected through 4.20.4. Fixed in 4.21. The notice scores CVSS 4.0 only.
- [cribl-2026-0007][c7] — CVE-2026-115899. CVSS 4.0 9.3 and CVSS 3.1 9.8. Initial release 2026-11-23T08:25:07Z. Fixed in 4.21.0.
- [cribl-2026-0006][c6] — CVE-2026-115873. CVSS 3.1 9.9 and CVSS 4.0 8.7. Same release time. Fixed in 4.21.0.
- [CVE-2026-115899](https://www.cve.org/CVERecord?id=CVE-2026-115899) — Cribl, published 2026-11-23. Both scores. Affected from 0 through 4.20.4.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T19:43:55.7979Z, checked 2026-11-23. None of the five is listed.

[trust]: https://trust.cribl.io/notifications
[c7]: https://csaf.cribl.io/2026/cribl-2026-0007.json
[c6]: https://csaf.cribl.io/2026/cribl-2026-0006.json
