# SOGo: a password-recovery question resets the account

**Last updated:** 2026-11-26 (America/New_York)

[Main SOGo summary](../black-october-2026.md#sogo-a-password-recovery-question-resets-the-account) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

SOGo is a web mail and calendar server. [CVE-2026-127111](https://www.cve.org/CVERecord?id=CVE-2026-127111) is in password recovery. A remote attacker who is not logged in can guess the answers to an account's secret questions with no lockout. A correct set of answers returns a recovery token, and that token sets a new password. The record says this takes over an account that does not have TOTP turned on. Every version before **5.12.13** is affected.

The same release fixes [CVE-2026-127131](https://www.cve.org/CVERecord?id=CVE-2026-127131). Someone who already has the password can guess the TOTP code at `/SOGo/connect` with no lockout, because a wrong code does not count as a failed login. VulnCheck is the CNA for both and rates each one **CVSS 4.0 9.1 Critical** and **CVSS 3.1 7.4 High**. The 9.1 vectors are `CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N` and `CVSS:4.0/AV:N/AC:H/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N`. Alinto, the vendor, says the release fixes several vulnerabilities, some critical, and names no score and no CVE. The project said the CVE identifiers would be added once they existed.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-13) for either CVE. Neither record reports exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| SOGo 5.12.13 released | 2026-11-04 09:24:58 UTC | Alinto says several vulnerabilities, some critical, are fixed, and that the CVE identifiers were not assigned yet. [Release][rel] |
| **SOGo 5.12.14** | **2026-11-24; time/TZ unknown** | Limits TOTP and password recovery, and fixes sieve injection, a worker crash, and theme script injection. No CVE yet. Affects 5.12.13. [Release][rel14] |
| **Public CVE records** | **2026-11-12 15:53:16 UTC** | CVE-2026-127111 published. CVE-2026-127131 followed at 15:56:31 UTC. VulnCheck is the CNA. [CVE-2026-127111][cve111] |
| **Last updated** | **2026-11-13 (America/New_York)** | New item. Upgrade SOGo. |

## Detection

1. Read the running version. A package, container, or source build below **5.12.13** is inside both flaws. The nightly `sogo_5.12.13.20261104` is the first build Alinto names as fixed.
2. Password recovery has to be configured for CVE-2026-127111 to be reachable. An account with no secret question is not inside that one. An account with TOTP is still inside CVE-2026-127131, because that one starts from a known password.
3. A reverse proxy log that shows a long run of requests to the password-recovery check, or a long run of failed `/SOGo/connect` attempts that never lock the account, is an indicator to review. Absence of those lines is not a clean bill.

## Remediation

1. Upgrade to **SOGo 5.12.14 or later** and restart the service. 5.12.13 closes the two scored flaws. Alinto's November 24 release says 5.12.14 also limits TOTP attempts and password recovery, and fixes a sieve injection, a worker crash, and script injection through a custom theme. It says those affect every earlier version, including 5.12.13, and that the CVE identifiers are not assigned yet. [5.12.14][rel14]
2. Until the upgrade, turn password recovery off if the deployment does not need it. That does not fix CVE-2026-127131, which needs the password and then guesses the TOTP code.
3. The project's release notes list more fixes in 5.12.13 than the first two records. One of them now has a record. [CVE-2026-130066](https://www.cve.org/CVERecord?id=CVE-2026-130066), published 2026-11-16, is SQL injection in SQLSource contact lookup. VulnCheck rates it **CVSS 4.0 7.1 High** and **CVSS 3.1 6.5 Medium**. A logged-in user places a backslash before a quote in the object name and, on MySQL or MariaDB, reads the user-source table, including password hashes. Every version before 5.12.13 is affected, so the upgrade already covers it. The release notes also name a second SQL injection, a buffer overflow, LDAP filter injection, path traversal, impersonation, and unsafe HTML. Those still have no scores here, and this guide does not assign them.

## Verification

- The running SOGo reports **5.12.13** or later, and the service was restarted after the install.
- A user can still sign in, and a user with TOTP still has to enter a code.
- Do not send a loop of recovery guesses or TOTP guesses to test the lockout.

## Compromise response

Neither Alinto nor VulnCheck publishes an indicator of a password that was already reset. If the server was reachable from the internet while it was below 5.12.13 and password recovery was on, review accounts for a password change the owner did not make, and expire existing sessions after the upgrade. The upgrade does not undo a password that was already changed.

## Sources

- [SOGo 5.12.13 release][rel] — published 2026-11-04 09:24:58 UTC. Alinto says several vulnerabilities, some critical, are fixed in this version or the November 4 nightly, and that CVE identifiers would follow.
- [CVE-2026-127111][cve111] — VulnCheck, published 2026-11-12 15:53:16 UTC. CVSS 4.0 9.1 and CVSS 3.1 7.4. Password recovery before 5.12.13 has no lockout.
- [CVE-2026-127131][cve131] — VulnCheck, published 2026-11-12 15:56:31 UTC. CVSS 4.0 9.1 and CVSS 3.1 7.4. TOTP guesses at `/SOGo/connect` do not count as failed logins.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10, checked 2026-11-13. Neither CVE is listed.

[rel]: https://github.com/Alinto/sogo/releases/tag/SOGo-5.12.13
[rel14]: https://www.sogo.nu/news/2026/sogo-v51214-released.html
[cve111]: https://www.cve.org/CVERecord?id=CVE-2026-127111
[cve131]: https://www.cve.org/CVERecord?id=CVE-2026-127131
