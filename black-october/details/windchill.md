# PTC Windchill and FlexPLM: a new deserialization patch

**Last updated:** 2026-11-12 (America/New_York)

[Back to Windchill summary](../black-october-2026.md#ptc-windchill-and-flexplm-a-new-deserialization-patch) · [Changelog](../../CHANGELOG.md)

PTC Windchill and FlexPLM hold product data. [CVE-2026-126325](https://www.cve.org/CVERecord?id=CVE-2026-126325) is a new deserialization flaw, published November 11, with a patch the same day. It is not the June or August flaw on the same trust-center page.

**PTC rates it CVSS 3.1 9.0 Critical** (`CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:C/C:H/I:H/A:H`) **and CVSS 4.0 9.2 Critical** (`CVSS:4.0/AV:N/AC:H/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N/AU:Y/RE:M/U:Amber`). The description says the flaw may be exploited through deserialization of untrusted data, and that it can run code. The record lists these builds as affected, with a default status of unaffected:

- Windchill: 11.0 M030, 11.1 M020, 11.2.1.0, 12.0.2.0, 12.1.2.0, 13.0.2.0, 13.1.0.0, 13.1.1.0, 13.1.2.0, 13.1.3.0, 13.1.4.0.
- FlexPLM: the same list through 13.1.3.0. FlexPLM 13.1.4.0 is not in the record.

PTC's trust-center change log for November 11, 2026 at 10:30 AM ET says a patch is available, that a Windchill administrator should apply it, and that a system PTC hosts is already patched. The instructions are in support article [CS483249](https://www.ptc.com/en/support/article/CS483249), which the CVE record also cites. That article requires a PTC login. No public page names the fixed build, so this guide does not invent one.

Two earlier records sit on the same trust-center page and are not this one. [CVE-2026-12569](https://www.cve.org/CVERecord?id=CVE-2026-12569) was published June 18. [CVE-2026-77645](https://www.cve.org/CVERecord?id=CVE-2026-77645) was published August 20 and stops at 13.1.3.0. The new record adds 13.1.4.0 for Windchill.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-12). The trust-center page publishes indicators of compromise for the earlier incident and does not say this CVE is being exploited. Those indicators are not a statement about CVE-2026-126325. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Earlier flaw, CVE-2026-12569 | 2026-06-18; time unknown | A different record. Patches followed in June and July. [Trust center][trust] |
| Earlier flaw, CVE-2026-77645 | 2026-08-20 9:00 PM ET (UTC−04:00) | A different record. The trust-center log gives that time. [Trust center][trust] |
| **Public announcement and patch** | **2026-11-11 10:30 AM ET (UTC−05:00)** | Change log. The CVE record was published the same day and gives no time. [Trust center][trust] |
| **Last updated** | **2026-11-12 (America/New_York)** | New item. |

## Detection

1. **Who hosts it.** PTC says a system it hosts is already patched. A system you host is the one that still needs the patch.
2. **Version.** Compare the installed build with the list above. A build the record does not name is not, on this record, affected. 13.1.4.0 is in the new record.
3. **The fixed build.** CS483249 is the only page that can say which patch level is the fix, and it needs a login. A version check against the affected list cannot show that the patch is in.

## Remediation

1. If PTC hosts the system, PTC says no action is required.
2. If you host it, have a Windchill administrator install the patch from [CS483249](https://www.ptc.com/en/support/article/CS483249). PTC says to apply it as soon as possible. This guide does not name a build the public pages do not name.
3. The patch does not show whether a request already ran code.

## Verification

- PTC confirms a hosted system, or the administrator recorded the CS483249 patch as installed.
- A function the system already performs still works. Do not send a deserialization payload.

## Compromise response

The trust-center page's indicators belong to the earlier incident. PTC does not publish indicators for CVE-2026-126325.

- Review application logs for requests and child processes of the Windchill service that you do not recognize.
- The patch does not remove a webshell already written. The earlier indicators on the trust-center page are a place to start looking, and finding none of them does not clear this CVE.

## Sources

- [CVE-2026-126325][cve] — PTC CNA, published 2026-11-11. CVSS 3.1 9.0 and CVSS 4.0 9.2. Affected builds listed above. Cites CS483249.
- [PTC trust center][trust] — change log entry 2026-11-11 10:30 AM ET. Patch available, PTC-hosted systems already patched, self-hosted systems should apply it.
- [CS483249](https://www.ptc.com/en/support/article/CS483249) — the support article. Requires a PTC login. Not read.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-12. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-126325
[trust]: https://www.ptc.com/en/about/trust-center/advisory-center/active-advisories/windchill-flexplm-rce-vulnerability
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
