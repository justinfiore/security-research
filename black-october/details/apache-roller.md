# Apache Roller: an Atom entry reads a file, and a link creates an administrator

**Last updated:** 2026-11-12 (America/New_York)

[Back to Roller summary](../black-october-2026.md#apache-roller-an-atom-entry-reads-a-file-and-a-link-creates-an-administrator) · [Changelog](../../CHANGELOG.md)

Apache Roller is a Java blog server. Release 6.1.7, announced November 11, fixes fifteen flaws. Two are at 7.0 or higher.

**Apache rates [CVE-2026-105153](https://www.cve.org/CVERecord?id=CVE-2026-105153) CVSS 3.1 7.7 High** (`CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:N/A:N`). The advisory says Important. An account with no weblog permissions submits an Atom entry. The parser allows external parameter entities and external DTD subsets, so the server reads a file it can read or requests a URL the attacker names. The parse happens before the per-weblog authorization check and before the check of whether AtomPub is enabled, so a default installation is reachable. Affected: 4.0 through 6.1.6. Kaya Emre Arikan reported it.

**Apache rates [CVE-2026-118411](https://www.cve.org/CVERecord?id=CVE-2026-118411) CVSS 3.1 8.8 High** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`). The advisory says Important. The request-token check applied only to POST, and administrative actions also accepted GET. A logged-in administrator who opens a link the attacker controls runs one, including creating an administrator. Affected: 5.0.1 through 6.1.6. The CVE record was still Reserved on November 12; the score and the range are from the advisory. hataehoon reported it.

A third flaw, [CVE-2026-123374](https://www.cve.org/CVERecord?id=CVE-2026-123374), is the other one Apache rates Important: the XML-RPC client deserializes a weblog-update ping response, so the ping target can run code. The advisory gives no number. It affects 4.0 through 6.1.6. David Joudelat reported it.

The project lists twelve more, nine Moderate and three Low. None of those is 7.0 or higher. 6.1.7 is the fix for all fifteen. Planet is off by default after the upgrade, and the entry editor applies the Limited role to each entry.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-12) for CVE-2026-105153 or CVE-2026-118411. The advisories do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Last updated** | **2026-11-12 (America/New_York)** | New item. |

## Detection

1. **Version.** 6.1.7 or later is the fix. 6.1.6 and earlier, back to 4.0, are inside CVE-2026-105153. The 8.8 flaw starts at 5.0.1.
2. **AtomPub.** Turning AtomPub off does not take a server out of CVE-2026-105153. The advisory says the parse happens before that check.
3. **Accounts.** Any authenticated account can submit the Atom entry. The 8.8 flaw needs an administrator to open a link.

## Remediation

1. Upgrade to **6.1.7 or later**. There is no patched older line. The project says the fix for an older release is to upgrade.
2. Read the [release notes](https://github.com/apache/roller/blob/roller-6.1.7/CHANGES.md) first. Planet is off by default, and the entry editor applies the Limited role to each entry.
3. Rebuild the search index after the upgrade. The project says the old index holds commenter email addresses.
4. The upgrade does not show whether an entry already read a file or an administrator account was already created.

## Verification

- The running Roller reports 6.1.7 or later.
- A weblog that should be reachable still answers. Do not submit an Atom entry or a link built for these flaws.

## Compromise response

The advisories publish no indicator.

- Review administrator accounts created while a build through 6.1.6 was running.
- The upgrade does not remove an account already created or a file already read. Rotate a credential that file held.

## Sources

- [CVE-2026-105153 advisory][adv105153] — David M. Johnson, 2026-11-11 03:14 UTC. Important, CVSS 3.1 7.7. Affected 4.0 through 6.1.6. Fixed in 6.1.7.
- [CVE-2026-118411 advisory](https://lists.apache.org/thread/q2h1r9v5qqofxh8qds58dtqrhf85ll60) — 2026-11-11 03:17 UTC. Important, CVSS 3.1 8.8. Affected 5.0.1 through 6.1.6.
- [CVE-2026-123374 advisory](https://lists.apache.org/thread/577orljt8673gcvcv6nvwo2tnvykyxmt) — 2026-11-11 03:18 UTC. Important, no numeric score. Affected 4.0 through 6.1.6.
- [Project post][post] — November 10, 2026. Lists all fifteen with the project's severity and the behavior changes.
- [CVE-2026-105153](https://www.cve.org/CVERecord?id=CVE-2026-105153) — Apache CNA, published 2026-11-11. Same 7.7 score.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-12. Neither scored CVE is listed.

[adv105153]: https://lists.apache.org/thread/w7dsz19261myrcwx8ssbwr67hc1wfosj
[post]: https://rollerweblogger.org/project/entry/apache-roller-6-1-7
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
