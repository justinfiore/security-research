# SAP: suspicious activity on GitHub

**Last updated:** 2026-11-27 (America/New_York)

[Main SAP incident summary](../black-october-2026.md#sap-suspicious-activity-on-github) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

SAP confirmed a security incident on 2026-11-27. BleepingComputer quotes SAP: it detected suspicious activity, took urgent action to protect customers, and, based on its investigation so far, has found no evidence of unauthorized access to customer business data. SAP's statement to BleepingComputer does not say when the activity started, what was reached, or whether source code was changed.

Der Spiegel reported the same day, from an internal memo and unnamed sources, that SAP tracks the incident as "Project Granite," that employees were told to keep the details confidential, and that attackers stole employee authentication tokens and used them to copy and modify source code on GitHub. German news agency dpa, reviewing staff messages, reported that the activity was found on GitHub and that SAP limited GitHub access, suspended automated development work, and replaced signing keys. Those details are not in the statement SAP gave BleepingComputer. This guide does not treat them as confirmed.

No CVE is assigned. There is no patch for a customer system in the statement SAP gave. This is not the [November patch day](../black-october-2026.md#sap-november-patch-day---unauthenticated-code-execution-in-web-dispatcher-icm-and-gateway) and not [SAP NetWeaver Visual Composer](../black-october-2026.md#sap-netweaver-visual-composer-low-privileged-access-to-backend-operations-on-connected-systems).

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. SAP says it has found no evidence of unauthorized access to customer business data. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Der Spiegel report | 2026-11-26; time/TZ unknown | Internal memo. "Project Granite." Token theft and GitHub code changes attributed to unnamed sources. [Der Spiegel][spiegel] |
| **SAP statement** | **2026-11-27 04:56 AM; timezone of the article timestamp not stated** | BleepingComputer. Suspicious activity confirmed. No evidence of unauthorized access to customer business data. [BleepingComputer][bc] |

## Detection

Nothing in the confirmed statement names a customer system, a product version, or an indicator. A SAP product on a customer's network is not, on this statement, something to inventory for this incident.

## Remediation

1. Nothing to install. SAP's statement does not name a customer patch.
2. Do not rotate a credential, and do not trust a changed binary, because a news article says source code was modified. That claim is not in SAP's statement. If SAP later names a repository or a release, follow that notice.
3. Do not give a password or a token to a caller who cites this incident.

## Verification

- There is no customer-side check in the statement SAP gave.

## Compromise response

SAP says its investigation so far has found no unauthorized access to customer business data. It does not say the investigation is finished. The GitHub claims remain unverified by this guide. There is no published indicator.

## Sources

- [BleepingComputer, 2026-11-27][bc] — SAP's statement: suspicious activity, urgent action to protect customers, no evidence of unauthorized access to customer business data.
- [Der Spiegel][spiegel] — the "Project Granite" memo and the token and source-code claims, from unnamed sources. Not confirmed in SAP's statement.
- [SecurityWeek](https://www.securityweek.com/sap-confirms-cyberattack-source-code-reportedly-compromised) — SAP told SecurityWeek the same sentence on customer business data. The GitHub details are attributed to dpa and Der Spiegel.

[bc]: https://www.bleepingcomputer.com/news/security/sap-confirms-security-incident-after-suspicious-github-activity/
[spiegel]: https://www.spiegel.de/netzwelt/sap-wird-opfer-von-hackerangriff-a-6648b5ce-5d74-48dc-86ea-9469705bb91d
