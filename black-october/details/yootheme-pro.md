# YOOtheme Pro: unauthenticated file write through the image handler

**Last updated:** 2026-11-05 (America/New_York)

[Back to YOOtheme Pro summary](../black-october-2026.md#yootheme-pro-unauthenticated-file-write-through-the-image-handler) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-102785](https://www.cve.org/CVERecord?id=CVE-2026-102785): Joomla! Project (CNA) CVSS 4.0 10.0 Critical (`CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H/E:A/AU:Y`). Wordfence scores the WordPress theme CVSS 3.1 9.8 Critical.** The GitHub advisory database repeats the CNA's 10.0 and lists no package. NVD has not scored it. YOOtheme Pro 5.0.0 through 5.0.52 publishes a signed image URL. Anyone who can read that URL can reuse the signature, add image operations the signature does not cover, and write a file outside the cache directory. The CNA says the written file is a PNG/PHP polyglot in a public media directory. The changelog entry is one line: "Fix unauthenticated remote code execution via image handler." [Changelog][cl] [CNA][cve] [Wordfence][wf]

The CNA product field names the Joomla extension. Wordfence's record is the WordPress theme, same version range, patched in 5.0.53. JPCERT/CC's November 5 weekly report covers both. Unit 42's note says "WordPress running Joomla," which is not a product configuration; the webshells it describes are in a WordPress uploads folder. [JPCERT][jpcert] [Unit 42][u42]

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05). Unit 42 reports webshells written in the wild. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Fix released | 2026-10-21; time/TZ unknown | YOOtheme Pro 5.0.53. The changelog names CVE-2026-102785. [Changelog][cl] |
| CVE record published | 2026-10-22 12:36:43 UTC | Joomla! Project CNA. CVSS 4.0 10.0. Product field is the Joomla extension, 5.0.0-5.0.52. [CNA][cve] |
| Wordfence entry | 2026-10-22; time/TZ unknown | WordPress theme, CVSS 3.1 9.8. Patched in 5.0.53. [Wordfence][wf] |
| Unit 42 exploitation note | 2026-10-26 | First webshell two days after the patch. Automated JPEG/PHP polyglots in the WordPress uploads folder, then an ALFA Team webshell. [Unit 42][u42] |
| JPCERT/CC weekly report | 2026-11-05; time/TZ unknown | Covers October 25–31. Says Palo Alto Networks confirmed attacks against the fixed vulnerability, on Joomla and WordPress. [JPCERT][jpcert] |
| **Last updated** | **2026-11-05 (America/New_York)** | New item. |

## Detection

1. YOOtheme Pro is a theme, not a plugin. On WordPress the stylesheet is `wp-content/themes/yootheme/style.css`. On Joomla the template is `templates/yootheme`. Read the `Version:` header from the files. Do not load the theme to learn the version.
2. Versions **5.0.0 through 5.0.52** are affected. 5.0.53 is the fix the changelog names. The CNA's affected range is written as one string, `5.0.0-5.0.52`, not as an open interval.
3. A site that never published a YOOtheme image URL has no signature to reuse. The sources do not say the handler is unreachable in that case, so treat a present 5.0.0–5.0.52 copy as affected.
4. Unit 42's WordPress indicators, from the October 26 note:
   - Files named `yt` plus seven hex characters and `.php` under `wp-content/uploads/`.
   - A response body containing `WPCONFIG`.
   - A follow-on directory `wp-content/uploads/ALFA_DATA/alfacgiapi/` with `.htaccess`, `perl.alfa`, `py.alfa`, `bash.alfa`, and `aspx.aspx`.
   - Requests whose query string contains `FromFile=php://input` and `Save=wp-content/uploads/`.
   Unit 42 says the write returns HTTP 500 and the file is still written. A 500 in the log is not, by itself, this attack.
5. Unit 42 does not publish a Joomla path. On Joomla, look for unexpected PHP under the template's media cache and under the site's public media directory. Absence of the WordPress names does not clear a Joomla site.

Read-only checks from the site root. Run them against a copy if you already suspect the host:

```sh
# WordPress
grep -H -m1 -iE '^[[:space:]*]*Version:' wp-content/themes/yootheme/style.css
find wp-content/uploads -type f -regextype posix-extended -regex '.*/yt[0-9a-f]{7}\.php$' -exec ls -l --time-style=full-iso {} +
find wp-content/uploads -type d -name ALFA_DATA -exec ls -laR {} +
# Joomla
grep -H -m1 -iE '<version>' templates/yootheme/templateDetails.xml
```

## Remediation

1. Update YOOtheme Pro to **5.0.53 or later** on every WordPress and Joomla site that has it, including inactive copies and staging sites. One changelog covers both.
2. Install the update from YOOtheme's own channel. The public image handler is how the flaw is reached; do not fetch the theme through an image URL on the site.
3. There is no configuration switch in the changelog. Taking the site offline until 5.0.53 is running is the mitigation the sources support.
4. Updating does not delete a file the handler already wrote. Search for the indicators above before treating the site as clean.

## Verification

- The theme header reads 5.0.53 or a later 5.0.x. A copy left in a backup directory or an inactive theme is still the old code.
- The searches above return no `yt` plus seven hex characters `.php` file and no `ALFA_DATA` directory. A clean search does not prove a shell was never written under another name.
- Web server logs no longer show `FromFile=php://input` against the YOOtheme cache route. Older lines remain evidence for the compromise-response steps.

## Compromise response

- Unit 42 says the first-stage file runs a command from `?c=` with no password, and that an operator then uploaded an ALFA Team webshell and tried to install gsocket. Treat a matching file as code execution, not as a failed upload.
- Remove the planted files only after you have copied them and the logs. Rotate the WordPress or Joomla administrator passwords, the database password, and any API keys the site could read. A webshell can read `wp-config.php` or Joomla's `configuration.php`.
- The scanner address Unit 42 names is `168.144.251.199`. The operator traffic came through residential proxies, so that one address is not the whole set.
- Unit 42 publishes SHA-256 hashes for four files under `ALFA_DATA/alfacgiapi/`: `bash.alfa` `1bbacae70b0e11e051783879bb63f667b4ee88b6b5676eabc7b09ea9afbc113c`, `aspx.aspx` `6c0643d21f74c6d7eb3a441eb167ab7c544c191dcaab6bb1f09d43cd0d8a15e1`, `py.alfa` `a2b2d11669115dab24ee1f82295fce67f1f93e316efe11a2c95018491e5cc484`, `perl.alfa` `f82fd317860454606003aa9dc7efde284d851424730e229f19c50d60206311b8`. A hash match is that kit. A mismatch is not a clean host.

## Sources

- [YOOtheme Pro changelog][cl] — 5.0.53, October 21, 2026: "CVE-2026-102785: Fix unauthenticated remote code execution via image handler." No later 5.0.x security entry was on the page when read.
- [CVE-2026-102785][cve] — Joomla! Project, published 2026-10-22 12:36:43 UTC. CVSS 4.0 10.0. Affected `5.0.0-5.0.52`. The description is the signature reuse and the PNG/PHP polyglot. The reference is yootheme.com, not a dedicated advisory.
- [GHSA-8w8j-f6ph-29mm][ghsa] — GitHub Advisory Database, unreviewed, October 22, 2026. Repeats the CNA text and the 10.0 score. No package and no patched version.
- [Wordfence][wf] — WordPress theme, CVSS 3.1 9.8, published October 22, 2026, patched in 5.0.53.
- [Unit 42 timely threat intel, 2026-10-26][u42] — webshells, the HTTP 500 write, file names, the ALFA kit hashes, and `168.144.251.199`.
- [JPCERT/CC Weekly Report 2026-11-05][jpcert] — item 12. Joomla and WordPress. Says Palo Alto Networks confirmed exploitation.
- [CISA KEV JSON feed][kev] — CVE-2026-102785 not listed (catalog 2026.11.04, checked 2026-11-05).

[cl]: https://yootheme.com/changelog
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-102785
[ghsa]: https://github.com/advisories/GHSA-8w8j-f6ph-29mm
[wf]: https://www.wordfence.com/threat-intel/vulnerabilities/wordpress-themes/UNKNOWN-CVE-2026-10077/yootheme-pro-500-5052-unauthenticated-arbitrary-file-upload
[u42]: https://github.com/PaloAltoNetworks/Unit42-timely-threat-intel/blob/main/2026-10-26-exploitation-of-CVE-2026-102785.txt
[jpcert]: https://www.jpcert.or.jp/wr/2026/wr261105.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
