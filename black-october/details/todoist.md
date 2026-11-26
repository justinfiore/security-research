# Todoist: customer records were copied from production

**Last updated:** 2026-11-26 (America/New_York)

[Main summary](../black-october-2026.md#todoist-customer-records-were-copied-from-production) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Todoist says an attacker reached its production systems on November 23 and copied customer information. There is nothing to install. If Todoist emailed you, follow that email. If it did not, Todoist says there is nothing to do.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** This is an incident at a hosted task manager, not a flaw in software you patch. Todoist has not established how the first credential was stolen. Its leading theory, which it says is unconfirmed, is that an employee's device was compromised.

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

Todoist splits the affected accounts into four groups. The counts are approximate and overlap is minimal.

- **About 6% of users.** Email addresses, salted SHA1 password hashes, and account creation dates. These are accounts whose passwords had not changed since Todoist stopped using SHA1 more than ten years ago. Todoist says a review of new sign-in sessions found no indication the attacker signed in to these accounts. Google and Apple sign-in passwords were not in the copy. An email about a hash on an account that signs in with Google or Apple refers to a separate Todoist password.
- **About 0.003%.** Todoist API tokens and Slack integration tokens. For a smaller subset, the API token was used to read project, task, and comment data through `/sync`.
- **About 0.001%.** Excerpts of tasks, comments, attachment names, project names, and project descriptions that matched searches for credentials, including seed phrases, private keys, API tokens, and service credentials. Manual searches asked for the first 200 to 320 characters. A later automated scanner asked for up to 700 characters from the start of a field and up to 500 of the match. Todoist says some commands timed out and that it cannot be certain what was retrieved, so it is reporting every search.
- **About 0.001%.** From mailboxes connected through the Todoist for Outlook add-in: subjects, senders, the first 255 characters of a message, and attachment names, types, sizes, and links. The requests asked for the 10 most recent messages and for keyword searches of up to 25 or 50 results. They did not ask for a full message body.

The attacker could also read Todoist's source code. Todoist says it found no changes to application code.

The same intrusion reached Twist, which Doist also runs. Twist's notice, last updated November 26, says the attacker read Twist's databases on November 23. About 3,600 users had a connected-app token copied, for Zapier, GitLab, Make, Slack, Todoist, Calendly, Google Calendar, and five custom Jira apps. About 3,080 of those tokens were used to look up a profile. About 10 were used to read workspace content. Twelve password hashes were copied, two of them salted SHA-1, and Twist reset every account that still used SHA-1. One workspace was given an attacker administrator for about three and a half minutes, and one member's direct messages were read. GitHub-integration records and the key that encrypted the stored GitHub tokens were read. Twist deleted every saved GitHub connection and replaced that key. Last recorded Twist activity was 12:38 UTC on November 23. Revocation of the Todoist, Calendly, and Google Calendar tokens began at 09:26 UTC on November 26. [Twist][twist]

## Timeline

All times below are UTC, from Todoist's notice.

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Stolen credential used | 2026-11-22 14:04 UTC | Workflows in three repositories were changed to collect more credentials. [Todoist][notice] |
| Production access | 2026-11-23 09:08 UTC onward | Databases and commands, after an employee work account was taken over at 06:33–06:54 UTC. |
| Records downloaded | 2026-11-23 12:45–12:51 UTC | Email addresses and the legacy hashes. |
| Content searched | 2026-11-23 13:05–17:12 UTC | Tokens, Outlook mailboxes, and credential-like task content. |
| Todoist starts investigating | 2026-11-23 17:01 UTC | An unexpected administrator account. Access removed by 17:42 UTC. |
| Outlook add-in disabled | 2026-11-24 05:06 UTC | The affected add-in. A replacement uses newer Microsoft APIs. |
| **Public announcement** | **2026-11-24 17:11 UTC** | This article. Email to affected customers began at 17:52 UTC and finished 2026-11-25 09:39 UTC. |
| Notice expanded | 2026-11-25 17:51 UTC | The `/sync` reads, the search terms, and the Outlook request limits. |
| Slack tokens revoked | 2026-11-25 17:23 UTC | Affected Slack integration tokens. |
| **Twist notice** | **2026-11-26; page says last updated that day** | Same intrusion. Connected-app tokens, twelve hashes, one workspace, one member's direct messages. [Twist][twist] |
| **Last updated** | **2026-11-26 (America/New_York)** | Twist is the same incident. Nothing to install. |

## Detection

1. The notice comes from `no-reply@notify.todoist.com`. Todoist says it will not ask for a password or ask you to install software because of this incident.
2. No email is Todoist's statement that your account was not in the copied set. The email, when it arrives, names which group you are in. There is no public lookup.
3. Todoist publishes no file hash, address, or other indicator a customer can search for.

## Remediation

There is no customer-side patch. Todoist says it disabled affected passwords, revoked API tokens, disconnected OAuth applications, and ended active sessions for the accounts it identified.

1. If the email says the password was disabled, reset it from the account email address. If that password was reused anywhere else, change it there too. Todoist has stopped accepting the old SHA1 hashes.
2. Reconnect Slack, and reconnect the Outlook add-in if you used it. The replacement may show as unverified until Microsoft finishes verification, and a work or school account may block it until then.
3. Replace a Todoist API token used in a script. The new token is under **Settings → Integrations → Developer** on the web.
4. Revoke a secret that was written into a task, a comment, or a project: an API key, a token, a recovery phrase, or a private key. Deleting the text does not invalidate a secret that was already copied. Restrict or replace a shared link that was in that content.
5. On Twist, reconnect an app that was disconnected, set a new password if Twist reset it, and change that password anywhere it was reused. Replace a personal Twist API token used in a script. Twist's mail comes from `noreply@twist.com` or `no-reply@notify.todoist.com`. No Twist email means Twist says there is nothing to do.

## Verification

- The email's steps are done, or no email arrived and nothing was changed because of a message from another address.
- A password that was reused has been changed on the other service.
- A secret that lived in a task or a comment has been revoked at the service that issued it.

## Compromise response

Todoist says it found no sign-in to the accounts whose hashes were copied. That review does not cover a secret the searches returned. Treat a seed phrase, a private key, or an API token that was in a matching task as exposed, and move funds or rotate the key at the service that issued it. A hash being copied is not the same as the password being known. Report a message you believe is using the copied addresses through [Todoist's incident contact](https://www.todoist.com/contact?area=incident).

## Sources

- [Todoist, Security incident in November 2026][notice] — published 2026-11-24 17:11 UTC, updated 2026-11-25 17:51 UTC. Stolen development credential, production access on November 23, and the four groups above. The page now points Twist customers at the Twist notice. No CVE and no score.
- [Twist, Security Incident in November 2026][twist] — same intrusion. About 3,600 connected-app tokens, about 3,080 profile lookups, about 10 workspace reads, 12 password hashes, one workspace, and one member's direct messages. Last activity 2026-11-23 12:38 UTC. OAuth revocation for Todoist, Calendly, and Google Calendar began 2026-11-26 09:26 UTC.
- [CISA KEV JSON][kev] — catalog 2026.11.25, released 2026-11-25T19:48:12.4344Z, checked 2026-11-26. No CVE to match.

[twist]: https://twist.com/help/articles/security-incident-in-november-2026-GWVMx3pxa

[notice]: https://www.todoist.com/help/todoist/get-started/security-incident-in-november-2026-cG0EIACNU
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
