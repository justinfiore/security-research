# CryptoPayment Gateway: unauthenticated settings and file deletion

**Last updated:** 2026-11-03 (America/New_York)

[Main CryptoPayment Gateway summary](../black-october-2026.md#cryptopayment-gateway-unauthenticated-settings-and-file-deletion) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-81648](https://www.cve.org/CVERecord?id=CVE-2026-81648): WPScan (CNA) CVSS 3.1 10.0 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H). NVD has not scored it.** Versions **1.2.1 through 1.2.2** of the CryptoPayment Gateway WordPress plugin do not check authorization on `vendor/cryptd/ajax.php`. WPScan says an unauthenticated caller can read and overwrite the payment-gateway settings and delete an arbitrary file. The settings include wallet addresses and a wallet key. WPScan's proof shows the key comes back encrypted from the settings call, then in cleartext from the same router's decrypt function. 1.2.2 is the latest version. WPScan lists **no known fix**. WordPress.org closed the plugin on **2026-08-28** and says the reason is a security issue. [WPScan][wpscan] [CVE record][cve] [Plugin page][wporg]

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03). Defused Cyber said on 2026-11-02 that it was recording exploitation attempts, not that a site had been confirmed compromised. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | Credited to Pedro Pinho. [WPScan][wpscan] |
| WPScan published | 2026-09-10; time/TZ unknown | No known fix. CVSS 3.1 10.0. [WPScan][wpscan] |
| CVE record published | 2026-09-13; time/TZ unknown | WPScan CNA. NVD published the record the same day and has not scored it. [CVE record][cve] [NVD][nvd] |
| Plugin closed | 2026-08-28; time/TZ unknown | WordPress.org: closed, "Reason: Security Issue." The page does not say whether that closure is this CVE. Last listed version is 1.2.2. [Plugin page][wporg] |
| Exploitation attempts reported | 2026-11-02 18:37 UTC | Defused Cyber said it was observing attempts and that the requests came from hosts marketed as anonymous VPS hosting. It did not publish a confirmed compromise or the request contents. [Defused][defused] |

## Detection

Read the plugin header. Do not load the plugin, and do not request `ajax.php`.

```sh
grep -H -m1 -iE '^[[:space:]*]*Version:' WP_ROOT/wp-content/plugins/cryptopayment-gateway/cryptopayment-gateway.php
```

**1.2.1 and 1.2.2** are the versions WPScan names. An older or unreadable header is **unknown**, not safe: the directory no longer offers a download, so a copy on disk may not match a published tag. The directory being closed does not remove a copy that is already installed. An inactive plugin is still files on disk.

Look for the files WPScan names, without requesting them:

- `wp-content/plugins/cryptopayment-gateway/vendor/cryptd/ajax.php`
- `wp-content/plugins/cryptopayment-gateway/vendor/cryptd/upload.php`

In the web server access log, a `POST` to either path is the request WPScan describes. Absence of those lines does not show the plugin was never reached: logs rotate, and a deleted `wp-config.php` is itself a sign the delete function ran.

## Remediation

1. **Deactivate and delete the plugin.** There is no patched release. Do not reinstall 1.2.2 from a saved copy.
2. **Move funds** off any wallet whose address or key was stored in the plugin, from a device that did not run this site. Treat the stored key as exposed even if you have not seen a transaction you do not recognize. WPScan's proof reads it without an account.
3. **Restore `wp-config.php` from a copy you trust** if it is missing or newer than your last deploy, and rotate the database password it contains. A missing config file sends visitors to the installer.
4. Removing the plugin does not undo a settings change or a deleted file, and it does not expire a wallet key that was already read.

## Verification

- `wp-content/plugins/cryptopayment-gateway/` is gone, and the site still loads without it.
- A payment page no longer offers this gateway. Point a replacement gateway at a **new** wallet. Do not paste the old key into it.
- `wp-config.php` matches the copy you restored, and a normal page does not redirect to `/wp-admin/setup-config.php`.

## Compromise response

If the plugin was installed while it was reachable, including after you have deleted it:

- Compare outgoing wallet transactions with your own records. A match to an address you did not set is an indicator, not the full set of thefts.
- Check the plugin's stored settings if you still have a database copy: a wallet address you did not configure means the settings call was used.
- Look for a new administrator user and for PHP files added under `wp-content/uploads`.
- Rotate WordPress salts and administrator passwords, and review SSH and hosting credentials if `wp-config.php` was replaced through the installer.

## Sources

- [WPScan][wpscan] — CVSS 3.1 10.0, versions 1.2.1–1.2.2, no known fix, published 2026-09-10. The proof names `ajax.php` and `upload.php`.
- [CVE-2026-81648][cve] — WPScan CNA, published 2026-09-13.
- [NVD CVE-2026-81648][nvd] — NVD has not scored it. Published 2026-09-13.
- [WordPress.org plugin page][wporg] — closed 2026-08-28, reason "Security Issue." Last version listed is 1.2.2.
- [Defused Cyber][defused] — 2026-11-02 18:37 UTC, exploitation attempts, no confirmed compromise in the post.
- [The Hacker News][thn] — 2026-11-03, repeats the WPScan and Defused statements.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30, not listed.

[wpscan]: https://wpscan.com/vulnerability/9b1490a0-1381-4d22-8086-f75aade4e898/
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-81648
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-81648
[wporg]: https://wordpress.org/plugins/cryptopayment-gateway/
[defused]: https://x.com/DefusedCyber/status/2117325160608870613
[thn]: https://thehackernews.com/2026/11/attackers-target-unpatched.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
