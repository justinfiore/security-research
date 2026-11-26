# Bithumb: groupware access copied customer identity records

**Last updated:** 2026-11-26 (America/New_York)

[Main summary](../black-october-2026.md#bithumb-groupware-access-copied-customer-identity-records) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Bithumb says an unauthorized party reached Daou Office, its internal mobile groupware, and copied personal information and files. The November 25 update of the same notice says that access ran from 13:49 KST on October 12 to 15:22 KST on October 27, not the one hour on October 27 the October 29 notice described. The people now named are customers, employees of partner companies, and current and former staff. Bithumb has not published a new count. The October 29 notice had said 6,444 customers and 715 staff.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** This is an incident at one exchange, not a flaw in software you patch. Bithumb says the groupware is separate from the exchange accounts and the customer database, and that it has not found those systems directly reached. It also says the vulnerability that allowed the access has been fixed, and it does not name the product version or the flaw.

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
| Access began | 2026-10-12 13:49 KST (UTC+09:00) | November 25 update. The October 29 notice had said October 27, 11:28 KST. [Notice][notice] |
| Access ended | 2026-10-27 15:22 KST (UTC+09:00) | Same update. The earlier notice had ended the window at 12:27 KST that day and said detection was at 12:14 KST. [Notice][notice] |
| First public notice | 2026-10-29 17:49:43; timezone of the page stamp not stated | 6,444 customers and 715 staff. [October notice][oct] |
| **Revised notice** | **2026-11-25 18:00:05; timezone of the page stamp not stated** | Longer window, more people, 19 data categories. No new headcount. [Notice][notice] |
| **Last updated** | **2026-11-26 (America/New_York)** | New item. Nothing to install. |

## Detection

1. Bithumb's lookup page, linked from the notice, is how a customer checks whether their own records were in the copy. A negative result is what that page returns; it is not a statement about every file the groupware held.
2. Bithumb says it will email and text the people whose records were copied, naming the categories for that person. The categories it lists are member number, name, mobile number, email, date of birth, resident registration number, passport number, driver's license number, bank account number, address, gender, nationality, copies of identity documents, occupation, employer name, employer phone, employer address, transaction history, and wallet address. Not every person had every category.
3. A call, a text, or a message that asks for a password, a one-time code, an OTP reset, a remote-control app, or a change of withdrawal address is the secondary fraud the notice warns about. Bithumb says it does not ask for a password or a verification code by phone, text, or messenger, and it does not ask someone to enter one through a link.

## Remediation

There is no customer-side patch, and there is no Bithumb software version to install.

1. Check the lookup page from the notice, or ask Bithumb's own support line (1661-5566), before acting on a message about the incident.
2. Turn on the two-factor authentication the Bithumb app already offers, if it is not already on. That does not undo a copy of an identity document.
3. Do not give a password, an OTP, or a seed phrase to anyone who cites this incident. Report a listing scam to the channel the notice names, `listing.bithumb.com/scam`.
4. Someone whose identity-document copy was taken should use the reissue and identity-theft steps Bithumb says it will send them, and can also use Korea's personal-information report center (118, privacy.kisa.or.kr) and dispute mediation (1833-6972).

## Verification

- The lookup was done on the page the notice links, not on a page from an unsolicited message.
- No password or one-time code was sent to a caller because of the notice.

## Compromise response

Bithumb says it has not found the exchange service or the customer database directly reached, and that it is watching withdrawals. It has not said how the groupware was entered beyond "a vulnerability," and it has not said the review is finished. Do not tell a customer that a specific wallet or a specific trade was or was not copied until the lookup or Bithumb's own notice for that person says so. Changing the Bithumb login password does not replace a passport number that was already copied.

## Sources

- [Bithumb notice 1655458, November 25 update][notice] — page stamp 2026-11-25 18:00:05. Access from October 12 13:49 KST through October 27 15:22 KST. Customers, partner staff, and current and former employees. Nineteen categories. Exchange systems and the customer database not found directly reached. The vulnerability is described as fixed, with no product name.
- [Bithumb notice 1655458, October 29 text][oct] — first registration stamp 2026-10-29 17:49:43. The one-hour window on October 27, 6,444 customers and 715 staff. Read 2026-11-26; the unparameterized URL still served this older text.
- [Yonhap, November 25, 2026](https://www.yna.co.kr/view/AKR20261125176100002) — reports the revised window and that Bithumb did not publish a new headcount. Used only to confirm the notice, not as the source of the facts above.
- [CISA KEV JSON][kev] — catalog 2026.11.25, checked 2026-11-26. No CVE to match.

[notice]: https://feed.bithumb.com/notice/1655458?format=html&tick=20261125-1035
[oct]: https://feed.bithumb.com/notice/1655458
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
