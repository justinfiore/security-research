# Cleverbridge: payment card data was copied

**Last updated:** 2026-11-22 (America/New_York)

[Main summary](../black-october-2026.md#cleverbridge-payment-card-data-was-copied) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Cleverbridge sells and bills software for other companies. Its incident page says that on November 4, 2026 it detected unauthorized activity, took affected systems offline, and brought them back the same day. The investigation then found that a third party copied payment card data stored on the platform. Notices to affected people began on November 20. There is nothing to install. A cardholder who was notified checks that card and tells the issuer.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** This is an incident at the checkout platform, not a flaw in an application you patch.

The incident page does not say which card fields were copied. It says affected people should read the notice sent to them. BleepingComputer's November 22 report quotes one such notice: the copied data includes the card number, the expiry date, and the card security code (CVV/CVC), and "no other personal data (for example your name, contact or billing details) were copied." The notice names the last digits of the affected card. This guide did not see that notice. A separate report, which this guide also did not verify against a notice, says a different notice lists contact details and says the security code was not copied. Cleverbridge has not said publicly why the notices would differ, so this guide does not pick one list of fields as the only one.

Cleverbridge says the incident was not ransomware and that no system was encrypted. It has not said how the party got in, how long the access lasted, how many people are affected, or which of its clients' customers were notified. It says it notified data protection authorities, law enforcement, the card networks, and its payment partners, and that TransUnion's Cyberscout sends the notices and offers credit or identity monitoring where that is available. It says it will never ask for a card number, a password, or a security code by email, phone, or text.

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
| Detection and containment | 2026-11-04; time unknown | Unauthorized activity. Systems taken offline and brought back the same day. [Cleverbridge][cb] |
| **Notices begin** | **2026-11-20; time unknown** | Affected individuals, where Cleverbridge judged it appropriate. |
| **Public report** | **2026-11-22 10:43; timezone not stated on the page** | BleepingComputer. The page prints 10:43 AM and no zone. Quotes a notice that names the card number, expiry, and security code. [BleepingComputer][bc] |
| **Last updated** | **2026-11-22 (America/New_York)** | New item. Check the card and tell the issuer. |

## Detection

1. Read the notice, if one arrived. It names the last digits of the affected card. A purchase through Cleverbridge that got no notice is not on the list Cleverbridge has published, and this guide cannot confirm that every affected person was reached.
2. Check that card's statements for a charge you do not recognize. Cleverbridge does not publish a list of fraudulent charges.
3. Do not treat an email that asks for the card number, a password, or a security code as Cleverbridge. Cleverbridge says it will not ask for those.

## Remediation

There is no customer-side patch.

1. If a notice arrived, tell the card issuer about the incident and follow what the issuer says. The issuer may replace the card. Checking the statement does not replace the card.
2. Use the credit or identity monitoring the notice offers, where it offers one. Cleverbridge says that is available in some places and not all.
3. A company that sells through Cleverbridge points its customers at the notice rather than collecting card details itself. Cleverbridge has not published which clients' customers were notified.

## Verification

- A notified cardholder has told the issuer, or has confirmed the card was replaced.
- A charge that is not recognized has been reported to the issuer. Absence of such a charge so far is not a finding that the card was not copied.

## Compromise response

Treat the card named in the notice as exposed from November 4, not from the date of the notice. Cleverbridge has not said whether any copied card has been used, so a clean statement today does not close it. The public page and the quoted notice disagree on whether contact details were copied; until Cleverbridge says which notice applies, do not assume a billing address was or was not taken.

## Sources

- [Cleverbridge, Incident Update and FAQs][cb] — detection on 2026-11-04, systems back the same day, card data copied, notices from November 20. Does not name the card fields. Says it was not ransomware.
- [BleepingComputer, November 22, 2026][bc] — quotes a customer notice that names the card number, expiry date, and CVV/CVC, and says name, contact, and billing details were not copied. Says Cleverbridge did not answer how many customers were affected.
- [CISA KEV JSON][kev] — catalog 2026.11.20, checked 2026-11-22. No CVE to match.

[cb]: https://grow.cleverbridge.com/incident-update
[bc]: https://www.bleepingcomputer.com/news/security/cleverbridge-warns-hackers-stole-credit-card-numbers-cvvs-in-data-breach
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
