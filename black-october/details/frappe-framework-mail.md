# Frappe Framework: a signed-in user sends mail as someone else

**Last updated:** 2026-11-20 (America/New_York)

[Main Frappe summary](../black-october-2026.md#frappe-framework-a-signed-in-user-sends-mail-as-someone-else) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-19 Frappe published [GHSA-vwqr-4mjv-ffrm][ghsa]. The project rates it **High, CVSS 3.1 8.5**. The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:L/I:H/A:N`. No CVE is assigned. The advisory says the email endpoints accepted a signed-in user who was not supposed to send mail, including a Website User. That user can send through the site's configured account, make the message look like it came from another sender, and attach files they are not allowed to read. Frappe says the flaw has been exploited in the wild. It names no workaround.

Affected releases are **everything before 15.127.1**, and **16.0.0 through 16.60.0**. The fixes are **15.127.1** and **16.60.1**. Frappe is the base of ERPNext, so an ERPNext site is on one of these lines.

This is not [Frappe Ghost](frappe-ghost.md), which is a different application by a different author.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. Frappe says the flaw has been exploited in the wild and does not say against which sites. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fixes** | **2026-11-19; time/TZ unknown** | GHSA-vwqr-4mjv-ffrm. Fixed in 15.127.1 and 16.60.1. [Advisory][ghsa] |

## Detection

Read the installed Frappe version from the site's app list, not from a page the site returns. A site before 15.127.1, or on 16.0.0 through 16.60.0, is inside the range. A Website User account is enough. The advisory does not say a logged-out visitor can do this.

## Remediation

1. Upgrade Frappe to **15.127.1 or 16.60.1** or later and restart the workers and the web process.
2. There is no workaround. Do not leave a reachable site on an affected build.
3. The upgrade does not show whether a message was already sent.

## Verification

- The running app is 15.127.1, 16.60.1, or later.
- A user who should still be able to send mail still can. Do not send a crafted request.

## Compromise response

Frappe says the flaw has been exploited and does not name the sites. Review the outgoing mail log for a sender the account's owner did not use, and for attachments the sender should not have been able to read. The upgrade does not unsend a message.

## Sources

- [GHSA-vwqr-4mjv-ffrm][ghsa] — Frappe, published 2026-11-19. High, CVSS 3.1 8.5. No CVE. Exploited in the wild. Fixed in 15.127.1 and 16.60.1. No workaround.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20. Not applicable: no CVE.

[ghsa]: https://github.com/frappe/frappe/security/advisories/GHSA-vwqr-4mjv-ffrm
