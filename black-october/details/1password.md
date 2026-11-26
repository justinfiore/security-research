# 1Password: account records were copied from the backend

**Last updated:** 2026-11-25 (America/New_York)

[Main summary](../black-october-2026.md#1password-account-records-were-copied-from-the-backend) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

1Password says an attacker reached some of its backend systems and copied account records for a subset of customers. The post says vault contents, the items in them, and the keys that protect them were not accessed. There is nothing for a customer to update in the app.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** This is an incident at a password manager, not a flaw in software you patch. 1Password says it does not store the account password or the Secret Key, so a copy of the backend records cannot open a vault by itself.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [What was copied](#what-was-copied)
- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## What was copied

1Password says the downloaded records, for a subset of users, include:

- Names and the email addresses used to sign in.
- Account and user identifiers, and account creation and last sign-in times.
- Public keys, which 1Password says are public by design.
- Secure Remote Password protocol parameters, which 1Password says cannot be used to access the account.
- Tokens present in certain emailed links for invitations, provisioning, and account recovery.
- Other non-secret account metadata, such as version and file numeric identifiers.

A provisioning invite is used for the SCIM Bridge or Hosted Provisioning. 1Password says a small number of users were in that state during the incident and have been notified. The token completes an invitation or a recovery only together with an SSO sign-in or a code sent to the registered email address. 1Password says the token cannot open the account by itself, and that it lengthened those codes from six numeric digits to ten alphanumeric characters.

The attacker also copied source code from private repositories and reached the CI/CD system. 1Password says the source code is not customer data and holds no user secrets, and that it has rotated internal credentials that may have been exposed. It says it found no evidence of a user account takeover that used an exposed provisioning token.

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Investigation starts | 2026-11-19; time unknown | An employee's corporate GitHub account. [1Password][blog] |
| **Public announcement** | **2026-11-25; time unknown** | Account records for a subset of customers. Vaults not accessed. [1Password][blog] |
| **Last updated** | **2026-11-25 (America/New_York)** | New item. Nothing to install. |

## Detection

1. An unexpected email, text, or call about a 1Password invitation or an account recovery you did not start matches what 1Password warns about. The message is not itself proof that your record was in the copied set.
2. 1Password says the users whose invitation or recovery token was copied have been notified. A notice you did not receive is not proof your record was left out: the copied set also includes names and email addresses for a subset 1Password does not name.
3. 1Password publishes no indicator, no count of affected accounts, and no way for a customer to look up whether their record was copied.

## Remediation

There is no customer-side patch. 1Password says you do not need to update anything in the account, and that the apps and services are working normally.

1. Treat an unexpected invitation or recovery email as hostile until you opened 1Password yourself. 1Password says it will never ask for the account password or the Secret Key. Enter those only in the official app, or on 1password.com after you typed the address yourself. The Secret Key is needed only the first time you sign in on a new device or browser.
2. If 1Password notified you that an invitation or recovery token was copied, finish or cancel that invitation from a session you started, not from the email.
3. Do not send the account password or the Secret Key to anyone who cites this incident, including a message that looks like support.

## Verification

- The account password and the Secret Key were not given to anyone who asked for them because of the incident.
- A recovery or an invitation you did not start was not completed from the email that announced it.

## Compromise response

1Password says vault contents were not available to the attacker, and that it found no account takeover that used an exposed token. It does not say how many accounts were in the copied set. Changing the account password does not retract a name or an email address that was already copied, and it does not expire a Secret Key. Rotate a credential that lived only in a 1Password item if your own review finds a reason to; the post does not ask for that. Report a message you believe is using the copied addresses to support@1password.com.

## Sources

- [1Password, November 25, 2026][blog] — investigation began November 19. An employee's GitHub account pushed code that downloaded account records for a subset of customers. Vaults, items, and vault keys were not accessed. No CVE and no score.
- [CISA KEV JSON][kev] — catalog 2026.11.25, checked 2026-11-25. No CVE to match.

[blog]: https://1password.com/blog/update-on-nov-2026-security-incident
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
