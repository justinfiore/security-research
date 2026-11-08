# WordPress plugins: checkout role, password reset, and file deletion

**Last updated:** 2026-11-08 (America/New_York)

[Main plugin summary](../black-october-2026.md#wordpress-plugins-checkout-role-password-reset-and-file-deletion) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Three plugins, three CVEs, each scored Critical by Wordfence. They are not one bug. They are not the [November 6 set](wordpress-plugins-nov6.md), the [November 7 set](wordpress-plugins-nov7.md), [LatePoint](wordpress-plugins-latepoint.md), or the [core upgrade-window](wordpress-upgrade-window.md) flaw. A site is affected only by the plugin it has installed. Each one has a fixed version.

**[CVE-2026-119075](https://www.cve.org/CVERecord?id=CVE-2026-119075): Wordfence rates Registration Form for WooCommerce through 1.1.4 CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. The My Account form checks a submitted role against an allow list. The checkout form does not: `validate_checkout_fields()` stores `$_POST['user_roles']`, and the new account is created with that role. A logged-out caller checking out can register as an administrator. Wordfence published the record on November 6 and updated it November 7. The fix is **1.1.5**. The directory changelog for 1.1.5, dated 06-11-2026, says "Prevented privilege escalation via the user role submitted at checkout." The directory version on November 8 is 1.1.5, updated 2026-11-06 15:48 GMT.

**[CVE-2026-104014](https://www.cve.org/CVERecord?id=CVE-2026-104014): Wordfence rates Naimur Email OTP Verification for WooCommerce through 2.1.0 CVSS 3.1 9.8 Critical.** The same vector. The password-reset endpoint trusts a database row that says the email was verified. It does not check when, bind the row to a session, or require a reset token. Starting a reset and not finishing it leaves the row, and the cleanup cron has no handler, so the row stays. A logged-out caller who knows the email and reads the nonce the plugin prints on the account page for logged-out visitors sets a new password and receives a logged-in session cookie. Wordfence says that is a full site takeover if the account is an administrator. The record was published November 6 and updated November 7. The fix is **2.1.1**. The directory version on November 8 is **2.1.2**, updated 2026-11-02. That changelog does not name this CVE. 2.1.2 is later than 2.1.1.

**[CVE-2026-122041](https://www.cve.org/CVERecord?id=CVE-2026-122041): Wordfence rates Checkout Field Editor for WooCommerce (Pro) through 3.8.0 CVSS 3.1 9.1 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:H`. Confidentiality is None: the flaw deletes a file, it does not read one. `ajax_remove_uploaded()` is open to logged-out callers and checks only a nonce. The checkout page prints that nonce when a file-upload field is configured. A caller who has the nonce can delete any attachment by id. The record was published November 6 and updated November 7. The fix is **3.8.1**. This is a commercial plugin. The directory does not host it. Themehigh's product page is the vendor link Wordfence cites.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08) for any of the three. Wordfence does not report exploitation of these three. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Naimur 2.1.2 on the directory | 2026-11-02 21:09 GMT | Later than the 2.1.1 fix. The changelog does not name CVE-2026-104014. [Directory API][api-naimur] |
| Registration Form 1.1.5 | 2026-11-06 15:48 GMT | The changelog says it prevented the checkout role escalation. [Directory API][api-reg] |
| **Public CVE records** | **2026-11-06; time/TZ unknown** | Wordfence. Each page says published November 6 and last updated November 7. [Registration][wf-reg] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-08) | [KEV][kev] |

## Detection

On a trusted copy of the site, read the installed versions. Do not run this on a host you suspect is compromised; read the files from a snapshot instead.

```sh
wp plugin list --fields=name,status,version --format=csv
```

| Plugin | Slug | Affected | Fixed |
|---|---|---|---|
| Registration Form for WooCommerce | `registration-form-for-woocommerce` | through 1.1.4 | 1.1.5 |
| Naimur Email OTP Verification for WooCommerce | `naimur-email-otp-for-woocommerce` | through 2.1.0 | 2.1.1 |
| Checkout Field Editor for WooCommerce (Pro) | sold by Themehigh, not the directory | through 3.8.0 | 3.8.1 |

A plugin that is installed and inactive can still load. Confirm each one. A site with none of the three is outside this entry. Checkout Field Editor Pro is not the free Checkout Field Editor plugin.

## Remediation

1. Update Registration Form for WooCommerce to **1.1.5 or later**. The directory copy on November 8 is 1.1.5.
2. Update Naimur Email OTP Verification to **2.1.1 or later**. 2.1.2 is on the directory and is later than the fix.
3. Update Checkout Field Editor for WooCommerce Pro to **3.8.1 or later**, from Themehigh. Until that build is installed, remove the file-upload field from checkout. That removes the printed nonce. It does not fix the handler, and a nonce already copied still works until it expires.
4. The update does not restore a password already changed, an administrator account already created, or an attachment already deleted.

## Verification

- `wp plugin get registration-form-for-woocommerce --field=version` is 1.1.5 or later, and the Naimur slug is 2.1.1 or later.
- The Pro plugin's own version line is 3.8.1 or later. Do not send `user_roles` at checkout, finish someone else's password reset, or call `thwcfe_remove_uploaded` to test it.

## Compromise response

Wordfence does not publish a confirmed compromise for these three.

- For the registration form, look for administrator accounts created from a checkout since November 6.
- For Naimur, look for a password change on an account that did not finish a reset, and for a session cookie issued to a logged-out caller.
- For the checkout field editor, look for attachments missing since November 6. The update does not bring a deleted file back.

## Sources

- [Wordfence, Registration Form][wf-reg] — CVE-2026-119075, 9.8, through 1.1.4, fixed in 1.1.5. Published November 6, updated November 7.
- [Wordfence, Naimur][wf-naimur] — CVE-2026-104014, 9.8, through 2.1.0, fixed in 2.1.1. Published November 6, updated November 7.
- [Wordfence, Checkout Field Editor Pro][wf-cfe] — CVE-2026-122041, 9.1, through 3.8.0, fixed in 3.8.1. Confidentiality impact None.
- [Registration Form changelog][api-reg] — 1.1.5, 2026-11-06, "Prevented privilege escalation via the user role submitted at checkout."
- [Naimur directory API][api-naimur] — version 2.1.2, updated 2026-11-02. The changelog does not name the CVE.
- [CISA KEV JSON][kev] — catalog 2026.11.06, checked 2026-11-08. None of these CVEs is listed.

[wf-reg]: https://www.wordfence.com/threat-intel/vulnerabilities/id/714d10b0-526c-4347-a369-85fc32ef3478
[wf-naimur]: https://www.wordfence.com/threat-intel/vulnerabilities/id/b29918de-22a2-424f-ad86-ad83874ca81a
[wf-cfe]: https://www.wordfence.com/threat-intel/vulnerabilities/id/a0b5f2ae-8cd9-4363-9d68-8a59f81a061b
[api-reg]: https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&request%5Bslug%5D=registration-form-for-woocommerce
[api-naimur]: https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&request%5Bslug%5D=naimur-email-otp-for-woocommerce
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
