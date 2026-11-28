# WordPress: WP Rocket writes a PHP file from a beacon report

**Last updated:** 2026-11-28 (America/New_York)

[Main guide](../black-october-2026.md#wordpress-wp-rocket-writes-a-php-file-from-a-beacon-report)

**Patchstack rates [CVE-2026-125812](https://www.cve.org/CVERecord?id=CVE-2026-125812) CVSS 3.1 9.8 Critical.** Patchstack is the CNA. NVD repeats that score and has not scored it itself. The vector NVD prints is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. The CVE record classifies it as CWE-22, path traversal. WP Rocket's own advisory says the same flaw runs arbitrary code with no login. The vendor's range is **3.15 through 3.24.1**, and only when LazyLoad for CSS background images or Self-host Google Fonts is on. The CVE record and NVD say anything before **3.24.2**. WP Rocket says **3.24.2**, released November 19, 2026, fixes it. The changelog line is "Improve validation of cached CSS, font and preconnect files." The changelog, read November 28, lists 3.24.2 as the newest release.

Patchstack's November 27 post says it saw the first exploitation attempt on November 25, 2026, at 15:27:11 UTC, against `admin-ajax.php` with `action=rocket_beacon`, and that the volume rose into automated campaigns on November 26. WP Rocket's advisory, last updated November 27, cites that report. This is not [W3 Total Cache](wordpress-w3tc.md).

**CISA KEV:** Not listed (catalog 2026.11.27, checked 2026-11-28). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to Patchstack | 2026-11-04; time/TZ unknown | Patchstack credits Vorelito. |
| **Patch** | **2026-11-19; time/TZ unknown** | WP Rocket 3.24.2. The changelog does not name the CVE. |
| Patchstack database | 2026-11-23; time/TZ unknown | CVSS 3.1 9.8. Patched in 3.24.2. |
| NVD published | 2026-11-25; time/TZ unknown | Repeats Patchstack's 9.8. No NVD score. |
| First exploitation attempt Patchstack reports | 2026-11-25 15:27:11 UTC | `rocket_beacon`. |
| **Public announcement** | **2026-11-27; time/TZ unknown** | WP Rocket's advisory, last updated that day, and Patchstack's exploitation post. |
| **Last updated** | **2026-11-28 (America/New_York)** | New item. |

## Detection

On each site, read the installed version of WP Rocket. The plugin is sold outside wordpress.org, so the directory listing is not the check. A site that does not have the plugin is outside this flaw. The vendor's range is 3.15 through 3.24.1, and only when at least one of LazyLoad for CSS background images and Self-host Google Fonts is on. Both are off by default. A site below 3.15, or on 3.24.1 with both off, is outside the vendor's stated range. The CVE record still says anything before 3.24.2. Reading the version and the two settings changes no state. A version you cannot read is unknown, not safe.

Patchstack says attempts go to `POST /wp-admin/admin-ajax.php` with `action=rocket_beacon`. It also names unexpected PHP files in `wp-content/wp-rocket-config/`, `wp-content/uploads/`, or `wp-content/`, for example `wp-media-*.php`, and outbound requests to unfamiliar hosts, `nip.io` names, or `trycloudflare.com` tunnels. A log you cannot read is unknown, not clear.

## Remediation

1. Update WP Rocket to **3.24.2 or later**. An active license shows the update under Plugins. An expired license does not receive it until the license is renewed or the zip is installed from the WP Rocket account.
2. If you cannot update yet, turn off **both** LazyLoad for CSS background images and Self-host Google Fonts. On 3.24 and later that is WP Rocket, Page Optimization, Image and Media. On a version before 3.24 it is the Media tab. WP Rocket says both have to be off. Its helper plugin does the same thing and is not the fix.
3. The update does not remove a PHP file or an account an attacker already created.

## Verification

- WP Rocket shows 3.24.2 or later.
- If the site is still below 3.24.2, both named settings are off.
- Do not send a `rocket_beacon` request to test the flaw.

## Compromise response

Patchstack reports exploitation attempts from November 25. If either setting was on while the site ran 3.15 through 3.24.1, look for a PHP file under `wp-content/wp-rocket-config/`, `wp-content/uploads/`, or `wp-content/` that the owner did not place there, and for an administrator the owner did not add. Updating the plugin does not remove either. WP Rocket points to the same Patchstack detection notes.

## Sources

- [WP Rocket, security advisory for CVE-2026-125812](https://wp-rocket.me/docs/wp-rocket-security-advisory-and-mitigation-steps-for-cve-2026-125812/) — last updated November 27, 2026. Versions 3.15 through 3.24.1, and only with LazyLoad for CSS background images or Self-host Google Fonts on. Fixed in 3.24.2, released November 19, 2026. Cites Patchstack's exploitation report.
- [WP Rocket changelog](https://wp-rocket.me/changelog/) — 3.24.2, November 19, 2026: "Improve validation of cached CSS, font and preconnect files." Read November 28, 2026. 3.24.2 is the newest entry.
- [Patchstack, Critical WP Rocket RCE under active attack](https://patchstack.com/articles/critical-wp-rocket-rce-cve-2026-125812-under-active-attack/) — published November 27, 2026. CVSS 9.8. First attempt 2026-11-25 15:27:11 UTC. `action=rocket_beacon`.
- [Patchstack database](https://patchstack.com/database/wordpress/plugin/wp-rocket/vulnerability/wordpress-wp-rocket-plugin-3-24-2-remote-code-execution-rce-vulnerability) — November 23, 2026. CVSS 9.8. Before 3.24.2, patched in 3.24.2. Credit Vorelito. Reported November 4.
- [NVD, CVE-2026-125812](https://nvd.nist.gov/vuln/detail/CVE-2026-125812) — published November 25, 2026. CNA Patchstack, CVSS 3.1 9.8, vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. CWE-22. Before 3.24.2. NVD has not scored it.
- [CVE-2026-125812](https://www.cve.org/CVERecord?id=CVE-2026-125812) — the public CVE.org page still said Reserved when read November 28, 2026. NVD already carries Patchstack's record.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.27, checked 2026-11-28. CVE-2026-125812 is not listed.
