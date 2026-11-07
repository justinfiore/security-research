# Firefox: a layout bug can run code from a web page

**Last updated:** 2026-11-07 (America/New_York)

[Back to Firefox summary](../black-october-2026.md#firefox-a-layout-bug-can-run-code-from-a-web-page) · [Changelog](../../CHANGELOG.md)

**Mozilla rates [CVE-2026-120572](https://www.cve.org/CVERecord?id=CVE-2026-120572) High.** [MFSA 2026-123][mfsa], announced 2026-11-03, gives the advisory and this one issue that rating. The CNA record publishes no numeric score and no vector. NVD shows **CVSS 3.1 8.8 High** from CISA-ADP, `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`, with CWE-119. The description is one sentence: incorrect boundary conditions in the Layout: Block and Inline component, fixed in Firefox **159.0.1**. Neither Mozilla nor the CVE record says which versions before 159.0.1 are affected, and neither names Firefox ESR or Thunderbird. The release notes for 159.0.1, first offered to Release channel users on November 3, list the advisory as a security fix and do not describe the bug. Bug 2079035 is not public. This is not the [eMudhra](emudhra.md) certificate distrust and not the [Edge](edge-pwn2own.md) Pwn2Own chain.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-07). Mozilla does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Public announcement and fix | 2026-11-03; time/TZ unknown | MFSA 2026-123. Firefox 159.0.1, first offered to Release channel users the same day. [MFSA][mfsa] [Release notes][notes] |
| CVE record | 2026-11-03 14:17:35 UTC | Mozilla CNA. No numeric score. Unaffected at 159.0.1. Updated 16:15:28 UTC the same day. [CVE][cve] |
| CISA-ADP score | 2026-11-03; time/TZ unknown | NVD shows CVSS 3.1 8.8 High from CISA-ADP. The CVE.org page does not print that score. [NVD][nvd] |
| **Last updated** | **2026-11-07 (America/New_York)** | New item. |

## Detection

1. Read the running Firefox version. In the browser, Help, About Firefox, which also starts an update check. From a shell, `firefox --version` prints the version of the binary on `PATH`, which may not be the profile that is open.
2. Mozilla's record says 159.0.1 is unaffected and does not name the first affected version. Treat a Release channel build below 159.0.1 as inside the advisory. A build that does not report a version is unknown, not safe.
3. Firefox ESR and Thunderbird are not in MFSA 2026-123. ESR 153.6 and Thunderbird 153.6 are the October 27 advisories, a different set of fixes. Do not treat an ESR version number as this patch, and do not treat this patch as covering those advisories.
4. Mozilla publishes no log signature. A quiet crash log does not show the page was not opened.

## Remediation

1. Update Firefox to **159.0.1 or later** on the Release channel, then relaunch so the new binary is the one running. The release notes say 159.0.1 was first offered on November 3.
2. Mozilla publishes no workaround. Not opening untrusted pages is not a control the advisory states.
3. The update does not show whether a page already ran code.

## Verification

- Help, About Firefox reports **159.0.1 or later**, and the same string comes from the binary that users launch. A package-manager version and a separately installed binary can disagree; check the one that is running.
- Firefox ESR is a different product line. Confirming 159.0.1 does not confirm ESR 153.6.

## Compromise response

Mozilla does not report exploitation, and the bug is not public. If a host shows code execution you cannot account for and Firefox was below 159.0.1, treat that as a lead, not as proof this CVE was used. Preserve the process list from a clean system, then update Firefox. The update does not remove a payload that already ran.

## Sources

- [MFSA 2026-123][mfsa] — announced 2026-11-03. Impact high. One issue, CVE-2026-120572, impact high. Fixed in Firefox 159.0.1.
- [Firefox 159.0.1 release notes][notes] — first offered to Release channel users on November 3, 2026. Lists the advisory as a security fix and does not describe the bug.
- [CVE-2026-120572][cve] — Mozilla CNA, published 2026-11-03 14:17:35 UTC. No CVSS in the CNA container. Unaffected at 159.0.1. No affected range below that.
- [NVD][nvd] — CISA-ADP CVSS 3.1 8.8 High, CWE-119. Published 2026-11-03.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.06, checked 2026-11-07).

[mfsa]: https://www.mozilla.org/en-US/security/advisories/mfsa2026-123/
[notes]: https://www.firefox.com/firefox/159.0.1/releasenotes/
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-120572
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-120572
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
