# Technical University of Munich: stolen passwords for every myTUM account

**Last updated:** 2026-11-07 (America/New_York)

[Main TUM summary](../black-october-2026.md#technical-university-of-munich-stolen-passwords-for-every-mytum-account) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

The Technical University of Munich says unknown individuals attacked the myTUM portal and stole the central-login password of everyone who had registered there. There is no CVE and no software update for a reader to install.

The notice dated Friday, November 6, 2026, 12:20 p.m. (the page does not name the timezone) says the stolen set includes the password for the TUM account, the name, the home address, and the date of birth. Employees also have a work address and a work phone number in the set. Students may also have a student ID number, a degree program, and a semester count. One of the stolen logins belonged to a TUMonline administrator, and TUM says the attackers used it against that campus system. TUM then took TUMonline offline.

TUM says the access inside TUMonline was largely logged, and that it currently assumes grades and college applications were not taken. It says that investigation is still open. It also says accounts that already had multi-factor authentication were protected from this attack.

TUM suspended the affected accounts, reported the incident to the Bavarian data-protection commissioner, and filed a criminal complaint. It says password-change options will be available by Monday, and that the instructions will be at it.tum.de by Monday evening at the latest. This guide was written on Saturday, November 7, before that Monday.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. TUM says the passwords were stolen. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-06 12:20; timezone not stated on the page** | TUM notice, status line "Friday, November 6, 2026, 12:20 p.m." [Notice][notice] |
| TUMonline taken offline | Date not stated separately | After the stolen administrator login was used. Same notice. |
| Password-change options | Promised by Monday; not published when this guide was written | TUM says instructions will be at it.tum.de by Monday evening at the latest. |

## Detection

This is TUM's portal, not software you patch.

- A myTUM or TUMonline account that will not sign in matches what TUM said it did: it suspended the affected accounts and took TUMonline offline.
- TUM says it will not ask for a password by email, phone, or letter. A message that does is not this recovery.
- There is no version number to check.

## Remediation

1. Change the TUM password when TUM publishes the method. TUM said that would be available by Monday, with instructions at [it.tum.de](https://www.it.tum.de/en/it/news-1/).
2. Turn on multi-factor authentication. TUM says accounts that already had it were protected.
3. If that password was reused anywhere outside TUM, change it there now. Do not wait for TUM's reset page.
4. There is nothing to upgrade.

## Verification

- The account signs in only after the password change TUM describes, and multi-factor authentication is on.
- TUMonline still being offline is the state TUM described. It is not a sign the notice was withdrawn.

## Compromise response

TUM says the password, name, home address, and date of birth were stolen for everyone registered on myTUM. Treat a reused password as exposed on the other service, not only at TUM.

- Change the reused password on personal email, shops, and any other site that used it. TUM names those examples.
- Do not trust a message that uses a degree program or an address to look official, and do not send the password to it-sicherheit@tum.de or anyone else. TUM asks that suspicious messages be reported there. It does not ask for the password.
- TUM's assumption that grades and applications were not taken is TUM's reading of its own logs, and TUM says that reading is not finished.

## Sources

- [TUM notice][notice] — the university's page. Status line 2026-11-06 12:20 p.m., timezone not stated. Read 2026-11-07.
- [TUM IT news][it] — the page TUM names for the Monday password instructions. Not yet the reset procedure when this guide was written.

[notice]: https://www.tum.de/en/news-and-events/all-news/press-releases/details/it-security-incident-at-tum
[it]: https://www.it.tum.de/en/it/news-1/
