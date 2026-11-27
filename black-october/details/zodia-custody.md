# Zodia Custody: client contact records were read

**Last updated:** 2026-11-26 (America/New_York)

[Main guide](../black-october-2026.md#zodia-custody-client-contact-records-were-read)

**No vendor or CNA has published a CVSS score, and no CVE is assigned.** Zodia Custody's chief executive says that on November 23 the company detected attempts to probe its platform, took the business-to-business API offline as a precaution, added security measures, and restored it. On November 24, monitoring found that an unauthorized party had read limited client information: organisation details that were already public and, for a small number of clients and employees, a business contact name and email address. Zodia says it contacted clients and informed regulators, and that the investigation so far has found no unauthorized transactions. The statement does not say how the party got in, how many people are affected, or whether private keys were read. It does not say the API was the way in.

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
| Probing detected | 2026-11-23; time/TZ unknown | The B2B API was taken offline, then restored. The statement does not say the API was the entry point. [Zodia][stmt] |
| Records read | 2026-11-24; time/TZ unknown | Public organisation details, plus a business contact name and email for a small number of clients and employees. |
| **Public announcement** | **2026-11-26; time/TZ unknown** | Statement by Richard Clark, also posted by @ZodiaCustody. No unauthorized transactions found so far. |
| **Last updated** | **2026-11-26 (America/New_York)** | New item. Nothing to install. |

## Detection

Zodia says it contacted the clients it identified. A client that received no notice has no check to run. There is no public list of affected accounts, and the statement names no indicator. Absence of a notice is not proof a record was not read.

## Remediation

1. There is nothing to install.
2. Do not approve an API change, a new user, or a transfer because a message cites this notice or the Standard Chartered acquisition. Confirm it through a contact you already use.
3. Zodia's statement does not ask clients to rotate a key. A key that never left the client is not in the records the statement names.

## Verification

- The only statement is the one on zodia-custody.com, or the post from @ZodiaCustody.
- A request that arrived some other way is not this notice.

## Compromise response

Zodia says the investigation has found no unauthorized transactions. That is the status as of the statement, not a finding that no later transaction will use a copied name. A business email and a real employee name are enough for a message that looks internal. The statement does not say private keys were copied, and it does not say they were not.

## Sources

- [Zodia Custody statement][stmt] — Richard Clark. Probing on November 23. Limited client information identified on November 24. No unauthorized transactions as of the statement. No CVE.
- [@ZodiaCustody](https://x.com/ZodiaCustody/status/2125909059551236101) — the same statement, posted 2026-11-26 11:06 AM (timezone not stated on the page read here).
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25. Not applicable: no CVE is assigned.

[stmt]: https://zodia-custody.com/statement-on-recent-security-incident/
