# Technical University of Munich: stolen passwords for every myTUM account

**Last updated:** 2026-11-09 (America/New_York)

[Main TUM summary](../black-october-2026.md#technical-university-of-munich-stolen-passwords-for-every-mytum-account) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

The Technical University of Munich says unknown individuals attacked the myTUM portal and stole the central-login password of everyone who had registered there. There is no CVE and no software update for a reader to install.

The notice dated Friday, November 6, 2026, 12:20 p.m. (the page does not name the timezone) says the stolen set includes the password for the TUM account, the name, the home address, and the date of birth. Employees also have a work address and a work phone number in the set. Students may also have a student ID number, a degree program, and a semester count. One of the stolen logins belonged to a TUMonline administrator, and TUM says the attackers used it against that campus system. TUM then took TUMonline offline.

TUM says the access inside TUMonline was largely logged, and that it currently assumes grades and college applications were not taken. It says that investigation is still open. It also says accounts that already had multi-factor authentication were protected from this attack.

TUM suspended the affected accounts, reported the incident to the Bavarian data-protection commissioner, and filed a criminal complaint. The November 6 notice said password-change options would be available by Monday, with instructions at it.tum.de by Monday evening at the latest.

The German IT page published the reset on Saturday, November 7, 2026, 13:00 CET. Change the TUM password if it was not changed since November 5, 2026, 00:00. A password changed since then still counts, for now. The requirement covers every TUM account, not only people who used myTUM. TUM has not set the deadline. The three methods are on the German IT page. A reread of the English and German press pages on November 9 no longer shows the Monday, November 9, 7:00 a.m. status. Both pages again lead with Friday, November 6, 2026, 12:20 p.m., and again say the password-change options will be provided by Monday. That line does not say TUMonline password changes are re-enabled at `https://campus.tum.de/tumonline/`. The German IT page is unchanged and still says signing in to TUMonline is not possible. The TUMonline status entry still says the change is possible immediately. The EduVPN status entry still says a reset is not yet possible. Use the German IT page, not the press lead.

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
| Password reset published | 2026-11-07 13:00 CET (UTC+01:00) | German IT news page. Change the password if it was not changed since 2026-11-05 00:00. Every TUM account, not only myTUM. No deadline yet. [IT news][it-de] |
| English IT page points at the reset | 2026-11-08 05:07 CET (UTC+01:00) | The English news page and the TUMonline status entry say the change is possible immediately and link the German instructions. The English press page was still the November 6 status. The EduVPN entry still says a reset is not yet possible. [English IT news][it] [Status][status] |
| Press page reread | 2026-11-09; time unknown | The English and German press pages no longer show the Monday, November 9, 7:00 a.m. status. Both lead with Friday, November 6, 12:20 p.m., and again say the options will be provided by Monday. The November 9 line that password changes are re-enabled is withdrawn. [Press][notice] |

## Detection

This is TUM's portal, not software you patch.

- A myTUM or TUMonline account that will not sign in matches what TUM said it did: it suspended the affected accounts and took TUMonline offline.
- TUM says it will not ask for a password by email, phone, or letter. A message that does is not this recovery.
- There is no version number to check.

## Remediation

1. Change the TUM password now if it was not changed since **2026-11-05 00:00**. A password changed since then still counts. This applies to every TUM account, including people who never used myTUM. TUM has not set a deadline. Use one of the three methods on the [German IT page](https://www.it.tum.de/it/aktuelles/), updated 2026-11-07 13:00 CET. The English news page now links there; it does not repeat the three methods.
   - Microsoft 365, which TUM recommends: [campus.tum.de Microsoft 365 reset](https://campus.tum.de/tumonline/co_loc_wbmspwreset.init). A person who never set up multi-factor authentication cannot sign in to Microsoft 365 right now. Use the next method.
   - German online ID (eID): [campus.tum.de eID reset](https://campus.tum.de/tumonline/co_loc_wbtumeid.initpwreset).
   - Email, only if the first two are not possible, and only on the campus network or VPN: [campus.tum.de email reset](https://campus.tum.de/tumonline/co_loc_password_reset.main). eduVPN itself now requires multi-factor authentication that cannot be set up while TUMonline is down, so a person without it uses the campus network in person.
2. Do not follow a link in an email, except the reset mail you just requested yourself on the email path. TUM says it will not ask for the password by email, phone, or letter. Type the address, or open the IT page above.
3. Turn on multi-factor authentication when TUMonline accepts a login again. TUM says new TUM multi-factor authentication is not available until then, and that accounts that already had it were protected.
4. If that password was reused anywhere outside TUM, change it there too. Also replace the old password anywhere it is stored, including eduroam, a mail program, and a phone.
5. There is nothing to upgrade. TUMonline login is still down. Other services can take up to 15 minutes to take the new password.

## Verification

- The password was changed through one of the three campus.tum.de forms, after 2026-11-05 00:00, and a service other than TUMonline accepts it. TUMonline itself is still offline.
- Multi-factor authentication is on, or it is waiting because TUMonline is still down. Those are different states.
- The EduVPN status entry that still says a reset is not yet possible is older than the password page. The TUMonline status entry now says the change is possible immediately. Do not treat the EduVPN entry as the current instruction.

## Compromise response

TUM says the password, name, home address, and date of birth were stolen for everyone registered on myTUM. Treat a reused password as exposed on the other service, not only at TUM.

- Change the reused password on personal email, shops, and any other site that used it. TUM names those examples.
- Do not trust a message that uses a degree program or an address to look official, and do not send the password to it-sicherheit@tum.de or anyone else. TUM asks that suspicious messages be reported there. It does not ask for the password.
- TUM's assumption that grades and applications were not taken is TUM's reading of its own logs, and TUM says that reading is not finished.

## Sources

- [TUM notice][notice] — the university's English page, reread 2026-11-09. The lead status is again Friday, November 6, 2026, 12:20 p.m. The Monday, November 9, 7:00 a.m. line is not on the page. The German press page says the same.
- [TUM IT news, German][it-de] — "Informationen zum Passwort Reset." Updated 2026-11-07 13:00 CET. Three reset methods. Applies to every TUM account if the password was not changed since 2026-11-05 00:00.
- [TUM IT news, English][it] — the password-reset article lists the three methods and says signing in to TUMonline is not possible yet. The page footer says "Updated: 2026-11-09 08:46 CET"; that line is the page, not a dated line on the article. The EduVPN block on the same page still says a reset is not yet possible.
- [TUMonline status entry][status] — \"Die Passwortänderung ist ab Sofort möglich,\" with the German IT link. The page shows the event window as 2026-11-03 08:55 through 2026-11-08 09:55, Central European Time, and does not date the sentence itself.

[notice]: https://www.tum.de/en/news-and-events/all-news/press-releases/details/it-security-incident-at-tum
[it]: https://www.it.tum.de/en/it/news-1/
[status]: https://status.it.tum.de/entry/bfc5bb29-06b2-4b0f-afb8-aabcf0104220
[it-de]: https://www.it.tum.de/it/aktuelles/
