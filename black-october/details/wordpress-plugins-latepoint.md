# WordPress plugins: LatePoint customer account takeover

**Last updated:** 2026-11-07 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-plugins-latepoint-customer-account-takeover) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

One plugin, one CVE. It is not the [November 7 upload and role-deletion pair](wordpress-plugins-nov7.md), the [four plugins from November 6](wordpress-plugins-nov6.md), or the [core upgrade-window](wordpress-upgrade-window.md) flaw. A site is affected only if LatePoint is installed.

**[CVE-2026-118066](https://www.cve.org/CVERecord?id=CVE-2026-118066): Wordfence rates LatePoint through 5.7.6 CVSS 3.1 9.1 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. Wordfence is the CNA. NVD has not scored it. The query builder treats the literal strings `IS NULL` and `IS NOT NULL` as SQL operators and concatenates them, instead of binding them as a value. A logged-out caller can send `params[password_reset_token]=IS NOT NULL` to the public password-change route. That matches every customer who has a reset token and resolves to the lowest-id customer, then overwrites that customer's password. Wordfence says the same request pattern on the public booking route returns a name and email, and that the caller can start the password-reset window themselves. When the site uses WordPress users as customers, the linked subscriber or customer-role account is taken over too. That is a LatePoint customer, not a WordPress administrator.

Wordfence's page was publicly published on 2026-11-06. The NVD record is 2026-11-07. Wordfence says the fix is **5.7.7**. The WordPress.org directory, read 2026-11-07, offers **5.7.8**, updated 2026-11-03, with 100,000+ active installs. The 5.7.7 changelog (November 2) says "Hardened the security of the plugin" and credits Wordfence. The 5.7.8 changelog (November 3) says "Addressed a security bug" and credits Wordfence again. Neither changelog names this CVE, and neither says which note is this flaw. 5.7.7 is the floor Wordfence names. 5.7.8 is the version the directory currently ships.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-07). Wordfence does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| 5.7.6 published | 2026-10-26; time/TZ unknown | Last affected version Wordfence names. Its own changelog says "Hardened the security of the plugin" and does not name this CVE. |
| 5.7.7 published | 2026-11-02; time/TZ unknown | Wordfence's patched version. Changelog: hardened, props to Wordfence. Does not name the CVE. |
| 5.7.8 published | 2026-11-03 11:47 GMT | Current directory version. Changelog: "Addressed a security bug. Props to WordFence." Does not say this is a second flaw. |
| Wordfence page | 2026-11-06; time/TZ unknown | Publicly published and last updated that day. CVSS 3.1 9.1. [Wordfence][wf] |
| NVD record | 2026-11-07; time/TZ unknown | NVD says it is not prioritizing enrichment. The CVE.org page was still Reserved when read the same day. |

## Detection

On a trusted copy of the site, read the installed version. Do not run this on a host you suspect is compromised; read the files from a snapshot instead.

```sh
wp plugin list --fields=name,status,version --format=csv
```

If WP-CLI is not available, read the `Version:` line in `wp-content/plugins/latepoint/latepoint.php`.

| Plugin | Slug | Affected | Fixed |
|---|---|---|---|
| LatePoint | `latepoint` | through 5.7.6 | 5.7.7 or later |

A plugin that is installed and inactive can still be reachable if its code loads. A site without LatePoint is outside this entry. The directory copy is 5.7.8. An install on 5.7.7 is at the floor Wordfence names; the 5.7.8 note does not say 5.7.7 is still affected.

## Remediation

1. Update LatePoint to **5.7.7 or later**. The directory version on 2026-11-07 is 5.7.8.
2. The update does not restore a customer password already overwritten, and it does not restore a linked WordPress user's password.
3. Wordfence does not list a configuration workaround. Taking the public booking pages offline is a containment step, not a fix.

## Verification

- `wp plugin get latepoint --field=version` prints 5.7.7 or later.
- Load the site's front page and the booking page. Do not send the `IS NOT NULL` request the advisory describes.

## Compromise response

No source publishes an indicator or a confirmed compromise.

- Look for a LatePoint customer whose password changed without a matching reset email, and for a booking account you do not recognize.
- When the site uses WordPress users as customers, the linked account is a subscriber or a customer role, not an administrator. A new administrator is a different incident.
- Reset the password of any customer account that changed during the window the site was on 5.7.6 or earlier. The update does not do that.

## Sources

- [Wordfence, LatePoint][wf] — CVE-2026-118066, CVSS 3.1 9.1 Critical, through 5.7.6, fixed in 5.7.7. Publicly published 2026-11-06. Researcher Jakub Herman.
- [NVD, CVE-2026-118066](https://nvd.nist.gov/vuln/detail/CVE-2026-118066) — published 2026-11-07. NVD has not scored it and says enrichment is not scheduled. CNA is Wordfence.
- [LatePoint on WordPress.org](https://wordpress.org/plugins/latepoint/) — version 5.7.8, updated 2026-11-03 11:47 GMT, 100,000+ active installs. Read 2026-11-07. The 5.7.7 and 5.7.8 changelogs credit Wordfence and do not name the CVE.
- [CVE-2026-118066](https://www.cve.org/CVERecord?id=CVE-2026-118066) — the CVE.org page was still Reserved when read on 2026-11-07. The NVD and Wordfence pages are the records used here.

[wf]: https://www.wordfence.com/threat-intel/vulnerabilities/wordpress-plugins/latepoint-2/appointment-booking-plugin-576-unauthenticated-authentication-bypass-via-account-takeover-via-is-not-null-sentinel-in-password-reset-token-parameter
