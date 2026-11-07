# WordPress plugins: four unauthenticated Critical flaws

**Last updated:** 2026-11-06 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-plugins-four-unauthenticated-critical-flaws) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Four plugins, four CVEs, each scored Critical by its CNA. They are not one bug. A site is affected only by the plugins it has installed. None is the [WordPress core upgrade-window](wordpress-upgrade-window.md) flaw.

**[CVE-2026-107622](https://www.cve.org/CVERecord?id=CVE-2026-107622): Wordfence rates BuddyForms CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Through **2.10.5**, a logged-out caller can create a BuddyForms form with an attacker-chosen role for new users, then register through that form as an administrator. Wordfence says this needs "Anyone can register" and at least one public BuddyForms form on a page. **Fixed in 2.10.6.**

**[CVE-2026-120844](https://www.cve.org/CVERecord?id=CVE-2026-120844): Patchstack rates miniOrange OAuth Single Sign On – SSO (OAuth Client) CVSS 3.1 9.8 Critical**, the same unauthenticated vector. Through **7.1.3**, incorrect privilege assignment allows privilege escalation. The CVE record does not say how. Patchstack's page says the required privilege is Unauthenticated, and its generic blurb says a low-privilege user can become an admin. **Fixed in 7.1.4.** The slug is `miniorange-login-with-eve-online-google-facebook`.

**[CVE-2026-119516](https://www.cve.org/CVERecord?id=CVE-2026-119516): Patchstack rates Radius Booking CVSS 3.1 9.8 Critical**, unauthenticated. Through **1.0.20**, untrusted data is deserialized (CWE-502). Patchstack does not publish the parameter. **Fixed in 1.0.21.** Object injection is not, by itself, code execution. It becomes code execution only if a suitable class is already loadable.

**[CVE-2026-114630](https://www.cve.org/CVERecord?id=CVE-2026-114630): Wordfence rates ELEX WordPress HelpDesk & Customer Ticketing System CVSS 3.1 9.1 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:H`. Through **3.3.8**, an unauthenticated caller stores a path on a ticket, then calls a factory-reset URL that deletes that path. Wordfence says deleting `wp-config.php` can lead to code execution. Confidentiality impact is None on the score: the flaw deletes a file, it does not read one. The reset URL is guarded by `is_admin()`, which checks the request type, not a capability. **Fixed in 3.3.9.** The slug is `elex-helpdesk-customer-support-ticket-system`.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-06) for any of the four. Wordfence and Patchstack do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private report, Radius Booking | 2026-10-17; time/TZ unknown | Patchstack credits hhhai. [Patchstack][ps-radius] |
| Patchstack pages | 2026-11-04; time/TZ unknown | Both pages say published 4 Nov 2026. The CVE records are later. |
| Wordfence public pages | 2026-11-05; time/TZ unknown | Wordfence says publicly published November 5 for both plugins. |
| **Public CVE records** | **2026-11-06** | Patchstack records 08:00:31 UTC. Wordfence records 11:17 UTC. |
| CISA KEV | Not listed | Catalog 2026.11.06, checked 2026-11-06. |

## Detection

On a trusted copy of the site, read the installed versions. Do not run this on a host you suspect is compromised; read the files from a snapshot instead.

```sh
wp plugin list --fields=name,status,version --format=csv
```

If WP-CLI is not available, read the `Version:` line in each plugin's main file:

| Plugin | Slug | Affected | Fixed |
|---|---|---|---|
| BuddyForms | `buddyforms` | through 2.10.5 | 2.10.6 |
| miniOrange OAuth SSO | `miniorange-login-with-eve-online-google-facebook` | through 7.1.3 | 7.1.4 |
| Radius Booking | `radius-booking` | through 1.0.20 | 1.0.21 |
| ELEX HelpDesk | `elex-helpdesk-customer-support-ticket-system` | through 3.3.8 | 3.3.9 |

A plugin that is installed and inactive can still be reachable if its code loads. Confirm each one. A site with none of the four is outside this entry.

BuddyForms still needs "Anyone can register" and a public form. ELEX still needs the support shortcode to be how the first step is described; Wordfence says the nonce is exposed through `[wsdesk_support]`. Those conditions narrow exposure. They are not a patch.

## Remediation

1. Update BuddyForms to **2.10.6 or later**, miniOrange OAuth SSO to **7.1.4 or later**, Radius Booking to **1.0.21 or later**, and ELEX HelpDesk to **3.3.9 or later**.
2. If a plugin is unused, remove it instead of leaving an affected copy inactive.
3. The updates do not delete an administrator account BuddyForms already created, do not restore a file ELEX already deleted, and do not undo an object that Radius Booking already instantiated.

## Verification

- `wp plugin get <slug> --field=version` shows the fixed version or later for each installed plugin.
- Load one page that uses the plugin. Do not submit the requests the advisories describe.

## Compromise response

No source publishes an indicator or a confirmed compromise.

- For BuddyForms, look for administrator accounts created after 2026-11-05 that you did not make, and for unexpected `buddyforms` form posts.
- For ELEX, look for a missing `wp-config.php` or another file you did not delete, and for tickets whose attachment path is not under the upload directory.
- For Radius Booking, look for PHP errors that name an unexpected class during a booking request. A class name in a log is a lead, not proof.
- For the miniOrange plugin, look for role changes on accounts that sign in through that OAuth client. Patchstack does not name the parameter.

## Sources

- [Wordfence, BuddyForms][wf-buddy] — CVE-2026-107622, 9.8, fixed in 2.10.6. Publicly published November 5, 2026.
- [Wordfence, ELEX HelpDesk][wf-elex] — CVE-2026-114630, 9.1, fixed in 3.3.9. Publicly published November 5, 2026.
- [Patchstack, miniOrange OAuth][ps-mini] — CVE-2026-120844, 9.8, fixed in 7.1.4. Page dated 4 Nov 2026. Required privilege Unauthenticated.
- [Patchstack, Radius Booking][ps-radius] — CVE-2026-119516, 9.8, fixed in 1.0.21. Reported 17 Oct 2026, page dated 4 Nov 2026.
- [CVE-2026-107622](https://www.cve.org/CVERecord?id=CVE-2026-107622), [CVE-2026-114630](https://www.cve.org/CVERecord?id=CVE-2026-114630), [CVE-2026-120844](https://www.cve.org/CVERecord?id=CVE-2026-120844), [CVE-2026-119516](https://www.cve.org/CVERecord?id=CVE-2026-119516).

[wf-buddy]: https://www.wordfence.com/threat-intel/vulnerabilities/id/2e83e654-f8a6-44a6-a687-92606331309e?source=cve
[wf-elex]: https://www.wordfence.com/threat-intel/vulnerabilities/id/2151249a-8e7a-4c7b-89ff-5058942368fb?source=cve
[ps-mini]: https://patchstack.com/database/wordpress/plugin/miniorange-login-with-eve-online-google-facebook/vulnerability/wordpress-oauth-single-sign-on-sso-oauth-client-plugin-7-1-3-privilege-escalation-vulnerability?_s_id=cve
[ps-radius]: https://patchstack.com/database/wordpress/plugin/radius-booking/vulnerability/wordpress-radius-booking-booking-calendar-for-appointments-services-plugin-1-0-20-php-object-injection-vulnerability?_s_id=cve
