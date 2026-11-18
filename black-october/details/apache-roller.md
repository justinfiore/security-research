# Apache Roller: an Atom entry reads a file, and a link creates an administrator

**Last updated:** 2026-11-17 (America/New_York)

[Back to Roller summary](../black-october-2026.md#apache-roller-an-atom-entry-reads-a-file-and-a-link-creates-an-administrator) · [Changelog](../../CHANGELOG.md)

Apache Roller is a Java blog server. Release 6.1.7, announced November 11, fixes fifteen flaws. Two are at 7.0 or higher.

**Apache rates [CVE-2026-105153](https://www.cve.org/CVERecord?id=CVE-2026-105153) CVSS 3.1 7.7 High** (`CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:N/A:N`). The advisory says Important. An account with no weblog permissions submits an Atom entry. The parser allows external parameter entities and external DTD subsets, so the server reads a file it can read or requests a URL the attacker names. The parse happens before the per-weblog authorization check and before the check of whether AtomPub is enabled, so a default installation is reachable. Affected: 4.0 through 6.1.6. Kaya Emre Arikan reported it.

**Apache rates [CVE-2026-118411](https://www.cve.org/CVERecord?id=CVE-2026-118411) CVSS 3.1 8.8 High** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`). The advisory says Important. The request-token check applied only to POST, and administrative actions also accepted GET. A logged-in administrator who opens a link the attacker controls runs one, including creating an administrator. Affected: 5.0.1 through 6.1.6. The CVE record was still Reserved on November 12; the score and the range are from the advisory. hataehoon reported it.

A third flaw, [CVE-2026-123374](https://www.cve.org/CVERecord?id=CVE-2026-123374), is the other one Apache rates Important: the XML-RPC client deserializes a weblog-update ping response, so the ping target can run code. The advisory gives no number. It affects 4.0 through 6.1.6. David Joudelat reported it.

On November 17 Apache published [CVE-2026-129448](https://www.cve.org/CVERecord?id=CVE-2026-129448) and rates it **CVSS 3.1 9.8 Critical** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`). The advisory says it is the same vulnerability as [CVE-2026-82384](https://www.cve.org/CVERecord?id=CVE-2026-82384), which listed only 6.1.5. The new record covers **4.0.0 through 6.1.4**: the XML-RPC endpoint accepts vendor extension types and deserializes them before authenticating the requester, so a remote attacker with no account can run code. Apache writes: "This issue is being actively exploited." The fix it names is **6.1.6 or later**, which disables the extension types and rejects XML-RPC requests when the feature is disabled. 6.1.7, the release this guide already recommends, is past that floor. Turning XML-RPC off in the administration UI is not enough on an older build, because the request is deserialized before that setting is checked. Until the upgrade, set `enabledForExtensions` to `false` in `WEB-INF/web.xml`, or remove the `/roller-services/xmlrpc` servlet mapping, and restart. n0mi1k found it and Matt Raible reported the wider range. It is not in KEV.

The project lists twelve more, nine Moderate and three Low. None of those is 7.0 or higher. 6.1.7 is the fix for all fifteen. Planet is off by default after the upgrade, and the entry editor applies the Limited role to each entry.

**CISA KEV:** Not listed (catalog 2026.11.17, checked 2026-11-18) for CVE-2026-105153, CVE-2026-118411, CVE-2026-82384, or CVE-2026-129448. Apache says CVE-2026-129448, the same flaw as CVE-2026-82384, is being actively exploited. That statement is Apache's, not a KEV listing. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Project post | 2026-11-10; time unknown | Dave Johnson says 6.1.7 fixes fifteen flaws and to upgrade now. The advisories were not up yet. [Post][post] |
| **Public announcement and fix** | **2026-11-11 03:14 UTC** | The CVE-2026-105153 advisory. The 8.8 advisory is timestamped 03:17 UTC and the deserialization advisory 03:18 UTC the same day. [Advisory][adv105153] |
| **CVE-2026-129448** | **2026-11-17 11:02:58 UTC** | Apache says the XML-RPC deserialization flaw, the same one as CVE-2026-82384, covers 4.0.0 through 6.1.4 and is being actively exploited. Fixed in 6.1.6. [Advisory][adv129448] |
| **Last updated** | **2026-11-17 (America/New_York)** | Exploitation statement and the wider range. The upgrade stays 6.1.7. |

## Detection

1. **Version.** 6.1.7 or later is the fix for the November 11 flaws and is past the 6.1.6 floor Apache names for CVE-2026-129448. 6.1.6 and earlier, back to 4.0, are inside CVE-2026-105153. The 8.8 flaw starts at 5.0.1. CVE-2026-129448 covers 4.0.0 through 6.1.4, and CVE-2026-82384 covers 6.1.5, so every release through 6.1.5 is inside the deserialization flaw.
2. **AtomPub and XML-RPC.** Turning AtomPub off does not take a server out of CVE-2026-105153. Turning XML-RPC off in the administration UI does not take a server through 6.1.5 out of the deserialization flaw. Both advisories say the request is parsed before that check.
3. **Accounts.** Any authenticated account can submit the Atom entry. The deserialization flaw needs no account. The 8.8 flaw needs an administrator to open a link.

## Remediation

1. Upgrade to **6.1.7 or later**. There is no patched older line. 6.1.6 fixes the deserialization flaw and not the November 11 flaws. The project says the fix for an older release is to upgrade.
2. Until the upgrade, set `enabledForExtensions` to `false` in `WEB-INF/web.xml`, or remove the `/roller-services/xmlrpc` servlet mapping, and restart. That is Apache's temporary step for CVE-2026-129448. It does not close the Atom flaw or the link flaw.
3. Read the [release notes](https://github.com/apache/roller/blob/roller-6.1.7/CHANGES.md) first. Planet is off by default, and the entry editor applies the Limited role to each entry.
4. Rebuild the search index after the upgrade. The project says the old index holds commenter email addresses.
5. The upgrade does not show whether an entry already read a file, a request already ran code, or an administrator account was already created.

## Verification

- The running Roller reports 6.1.7 or later.
- A weblog that should be reachable still answers. Do not submit an Atom entry or a link built for these flaws.

## Compromise response

Apache says CVE-2026-129448 is being actively exploited and publishes no indicator: no address, no request, and no file name.

- Review administrator accounts created while a build through 6.1.6 was running.
- A server through 6.1.5 that was reachable on `/roller-services/xmlrpc` before the upgrade is the one Apache says is being exploited. The upgrade does not show whether a request already ran code.
- The upgrade does not remove an account already created or a file already read. Rotate a credential that file held.

## Sources

- [CVE-2026-105153 advisory][adv105153] — David M. Johnson, 2026-11-11 03:14 UTC. Important, CVSS 3.1 7.7. Affected 4.0 through 6.1.6. Fixed in 6.1.7.
- [CVE-2026-118411 advisory](https://lists.apache.org/thread/q2h1r9v5qqofxh8qds58dtqrhf85ll60) — 2026-11-11 03:17 UTC. Important, CVSS 3.1 8.8. Affected 5.0.1 through 6.1.6.
- [CVE-2026-123374 advisory](https://lists.apache.org/thread/577orljt8673gcvcv6nvwo2tnvykyxmt) — 2026-11-11 03:18 UTC. Important, no numeric score. Affected 4.0 through 6.1.6.
- [Project post][post] — November 10, 2026. Lists all fifteen with the project's severity and the behavior changes.
- [CVE-2026-105153](https://www.cve.org/CVERecord?id=CVE-2026-105153) — Apache CNA, published 2026-11-11. Same 7.7 score.
- [CVE-2026-129448 advisory][adv129448] — Arnout Engelen, 2026-11-17 11:02:58 UTC. Critical, CVSS 3.1 9.8. Same flaw as CVE-2026-82384. Affected 4.0.0 through 6.1.4. "This issue is being actively exploited." Fixed in 6.1.6.
- [CISA KEV][kev] — catalog 2026.11.17, released 2026-11-17T17:53:15.5664Z, checked 2026-11-18. None of the four is listed.

[adv105153]: https://lists.apache.org/thread/w7dsz19261myrcwx8ssbwr67hc1wfosj
[adv129448]: https://seclists.org/oss-sec/2026/q4/731
[post]: https://rollerweblogger.org/project/entry/apache-roller-6-1-7
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
