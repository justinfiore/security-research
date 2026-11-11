# Chainalysis: password hashes and live tokens exposed

**Last updated:** 2026-11-10 (America/New_York)

[Main Chainalysis summary](../black-october-2026.md#chainalysis-password-hashes-and-live-tokens-exposed) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Chainalysis says an external actor used offensive agentic techniques to reach its systems and internal tools. There is no CVE. KEV does not apply.

The October 30 notice said the exposed data was user IDs, full names, email addresses, and organization role labels, and that Chainalysis had found no evidence of access to investigation content, passwords, MFA secrets, or session tokens.

The November 4 updates withdraw that limit. At 9:50 a.m. EST Chainalysis said an on-path attack exposed a subset of customer passwords, that it had contained that vector, and that it was locking those accounts. At 11:00 p.m. EST it said names, usernames, password hashes, and live tokens for all Chainalysis users were exposed. It also said it had found no evidence that investigation content was accessed or that attribution data was manipulated. The same day it took KYT, other address-screening products, and the login page offline after seeing abnormal activity, and it notified customers whose KYT accounts appeared to have been accessed without authorization.

The November 6 update, 3:30 a.m. EST, says restoration of KYT and Address Screening has started, in phases. Once access returns, every user must reset their password and rotate API keys before registering transactions. Reactor and Data Solutions were still offline. Chainalysis asks customers to send trusted IP addresses for an allowlist.

The November 7 update, 1:50 p.m. EST, says Reactor, KYT (the UI and the API), and Address Screening are back online, with extra security measures. Chainalysis is emailing customers the reconnection steps. The November 10 update, 3:00 a.m. EST, says Data Solutions is back online and that customers are being brought back as quickly as Chainalysis can. The password reset and the API-key rotation from the earlier updates still stand.

Chainalysis does not say how the actor got in, does not name the actor, and does not say whether the password hashes can be cracked. The October 30 notice says this incident is not the Binance theft.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. Chainalysis says customer accounts were exposed and that it is locking accounts that appear to have been accessed. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Incident noticed | 2026-10; day not stated | Chainalysis says it detected the actor this month. [Notice][notice] |
| First customer notice | 2026-10-30; time/TZ unknown | User IDs, names, emails, and role labels. No evidence then of credential or token access. |
| Products taken offline | 2026-11-02; time/TZ unknown | Reactor and Data Solutions. KYT kept running and monitored. |
| On-path passwords | 2026-11-04 09:50 EST (UTC−05:00) | A subset of customer passwords. Those accounts locked. |
| Hashes and tokens | 2026-11-04 23:00 EST (UTC−05:00) | Names, usernames, password hashes, and live tokens for all users. Discovered Monday, November 2, and published in this update. |
| KYT offline | 2026-11-04 10:30 EST (UTC−05:00) | After abnormal activity. Login page offline too. |
| Restoration started | 2026-11-06 03:30 EST (UTC−05:00) | KYT and Address Screening, in phases. Password and API-key reset required. |
| Reactor, KYT, and Address Screening online | 2026-11-07 13:50 EST (UTC−05:00) | Extra security measures. Reconnection instructions by email. Data Solutions is not in this update. |

## Detection

This is Chainalysis's platform, not software you patch.

- Read the notice Chainalysis sent your organization. The November 4 9:50 a.m. mail names accounts whose passwords were exposed. A later mail names KYT accounts that appear to have been accessed.
- KYT, Address Screening, Reactor, or Data Solutions being unreachable is the vendor's shutdown, not a fault in your integration.
- A password reset prompt for a Chainalysis account, during the window when Chainalysis said resets were not yet possible, is worth treating as untrusted until it matches the notice.

## Remediation

1. When Chainalysis restores access, reset every Chainalysis password and rotate every Chainalysis API key before registering transactions. Chainalysis says this is required.
2. If a Chainalysis password was reused anywhere else, reset it there too. Chainalysis says the on-path attack exposed a subset of passwords, and it does not publish the list.
3. Send trusted IP addresses to support@chainalysis.com or your account team if you have not. Chainalysis is building an allowlist for the restoration.
4. There is nothing to upgrade on your side. The October 30 finding, that credentials were not exposed, is no longer the current notice.

## Verification

- Each user can sign in only after a password reset, and each API integration works only after the key was rotated.
- KYT, Address Screening, or Reactor access returns only through the reconnection steps in the November 7 email, from an address you submitted. Data Solutions is not in that update, so it can still be offline.

## Compromise response

Chainalysis says it has no evidence that investigation content was accessed or that attribution data was changed. That is Chainalysis's finding about its own data, not a finding about your other systems.

- Treat every Chainalysis password and API key as exposed, including keys that only registered transactions.
- Reset any other account that reused a Chainalysis password. The notice says some passwords were exposed in a form an on-path attacker could read, and that the hashes and live tokens cover all users.
- Review Chainalysis audit history for searches and cases you did not run, once the product is back. Absence of a mail from Chainalysis is not proof your account was untouched.

## Sources

- [Chainalysis security incident notice][notice] — the vendor's page. Updates on 2026-10-30, 2026-11-02, 2026-11-04 (three), 2026-11-06 03:30 EST, and 2026-11-07 13:50 EST. Read 2026-11-07.

[notice]: https://www.chainalysis.com/blog/security-incident-october-30/
