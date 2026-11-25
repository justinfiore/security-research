# FinCEN: unauthorized access to a limited set of systems

**Last updated:** 2026-11-25 (America/New_York)

[Main summary](../black-october-2026.md#fincen-unauthorized-access-to-a-limited-set-of-systems) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

FinCEN's Bank Secrecy Act E-Filing site says the bureau is investigating a cybersecurity incident that resulted in unauthorized access to a limited subset of its systems. As a precaution it has taken some systems offline. The E-Filing website stays up, and some services on it may not. There is nothing for a filer to install.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** This is an incident at a Treasury bureau, not a flaw in software you patch. The banner does not say what was read, when the access started, or who did it.

A Reuters report on November 25 quotes a FinCEN official: the Treasury is working with the FBI, CISA, and outside examiners, and "while forensic analysis remains ongoing, there is no evidence of any breach of the Bank Secrecy Act or beneficial ownership databases." This guide did not see that statement on a FinCEN page. The Record says Treasury and FinCEN did not answer its questions, and that no one has claimed the incident.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Exceptive relief** | **2026-11-24; time unknown** | Order FIN-2026-R002. Filings otherwise due November 18 through December 29, 2026 are due no later than December 30, 2026. [Order][order] |
| **Banner on E-Filing** | **2026-11-25; time unknown** | Unauthorized access to a limited subset of systems. Some systems offline. [E-Filing][bsa] |
| Public reports | 2026-11-25; time unknown | The Verge, The Record, and Reuters. Reuters quotes the official on the two databases. |
| **Last updated** | **2026-11-25 (America/New_York)** | New item. Nothing to install. |

## Detection

1. A filing that fails, or a service the E-Filing site says is unavailable, matches what the banner describes. A failure is not by itself evidence that a filing was read.
2. FinCEN has not published an indicator, a list of affected filings, or a notice to individual institutions beyond the banner and the deadline relief.
3. Do not treat an email or a call that asks for a filing credential, a suspicious-activity report, or beneficial-ownership data as FinCEN because of this incident. The bureau has not said it will contact filers that way.

## Remediation

There is no customer-side patch.

1. Use the deadline relief in [FinCEN's November 24 order][order]. It covers two groups: a financial institution that as of November 18, 2026 used Secure Data Transfer Mode for BSA reports, and a reporting company or individual who must file a beneficial-ownership report or update a FinCEN ID. A submission otherwise due November 18 through December 29, 2026 is due no later than December 30, 2026. The order calls it a service disruption and says the hotline is not affected.
2. A suspicious-activity report that cannot wait goes to the Financial Institutions Hotline, 1-866-556-3974. The banner says that line is not affected.
3. Do not upload a copy of a report to a third-party site, or resend it to an address the banner does not name, to get around the outage.

## Verification

- A filing that was blocked has a new deadline from the order, or it was sent by the hotline when it could not wait.
- The E-Filing account password was not given to anyone who asked for it because of the incident.

## Compromise response

FinCEN has not said that any institution's filings were read. The Reuters statement, which this guide did not confirm on a FinCEN page, says there is no evidence the Bank Secrecy Act or beneficial-ownership databases were breached, and that the review is not finished. Until FinCEN says otherwise, do not tell customers that a specific report was or was not taken. Rotate a credential that was stored only for E-Filing if the institution's own review finds a reason to; the banner does not ask for that.

## Sources

- [BSA E-Filing System][bsa] — the banner: unauthorized access to a limited subset of systems, some systems taken offline, the site still up, deadlines extended, hotline 1-866-556-3974. Read 2026-11-25.
- [FinCEN, Temporary, Limited Exceptive Relief, November 24, 2026][order] — order FIN-2026-R002. Two groups of filers. Submissions otherwise due November 18 through December 29, 2026 are due no later than December 30, 2026. The order calls it a service disruption.
- [Reuters, via Al Arabiya, November 25, 2026](https://english.alarabiya.net/News/united-states/2026/11/25/us-fincen-takes-some-systems-offline-after-cyber-incident-official-says) — quotes a FinCEN official on the FBI and CISA review, and on no evidence of a breach of the Bank Secrecy Act or beneficial-ownership databases.
- [The Record, November 25, 2026](https://therecord.media/treasury-fincen-takes-systems-offline-after-cyber-incident) — Treasury and FinCEN did not comment; no claim of responsibility.
- [The Verge](https://www.theverge.com/policy/1041957/fincen-treasury-cybersecurity-incident) — the early report of the banner.
- [CISA KEV JSON][kev] — catalog 2026.11.25, checked 2026-11-25. No CVE to match.

[bsa]: https://bsaefiling.fincen.gov/
[order]: https://www.fincen.gov/news/news-releases/temporary-limited-exceptive-relief-certain-bank-secrecy-act-corporate-transparency-act-submissions/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
