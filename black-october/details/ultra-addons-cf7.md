# Ultra Addons for Contact Form 7: unauthenticated file deletion

**Last updated:** 2026-11-02 (America/New_York)

[Main Ultra Addons summary](../black-october-2026.md#ultra-addons-for-contact-form-7-unauthenticated-file-deletion) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-102435](https://www.cve.org/CVERecord?id=CVE-2026-102435): Wordfence (CNA) CVSS 3.1 9.8 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H). NVD has not scored it.** Through **3.5.54**, `_getObjAttr` does not check the file path. Wordfence says an unauthenticated visitor can delete an arbitrary file, and that deleting `wp-config.php` is a path to code execution. Two conditions are required: the PDF Generator add-on is active, and a Contact Form 7 form is configured to generate a PDF. The deletion uses a `WPCF7_Submission` object destructor. Wordfence says the fix is **3.5.55**. The current WordPress.org release is **3.5.57** (changelog date 2026-11-01), which says it improved PDF filename sanitization. [Wordfence][wf] [CNA][cve] [Readme][readme]

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03). Wordfence does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | Credited to Sawyer. [Wordfence][wf] |
| Wordfence published | 2026-11-02; time/TZ unknown | CVSS 3.1 9.8. Patched version 3.5.55. [Wordfence][wf] |
| CVE record published | 2026-11-02 20:17:26 UTC | Wordfence CNA, via NVD's published timestamp. [NVD][nvd] |
| Plugin 3.5.57 | 2026-11-01; time/TZ unknown | Changelog: "Improved: PDF filename sanitization and secure mPDF content handling." It does not name the CVE. [Readme][readme] |

## Detection

Read the plugin header. Do not load the plugin.

```sh
grep -H -m1 -iE '^[[:space:]*]*Version:' WP_ROOT/wp-content/plugins/ultimate-addons-for-contact-form-7/ultimate-addons-for-contact-form-7.php
```

**3.5.54 and earlier** are affected. The described path also needs the PDF Generator add-on active and a form set to generate a PDF. A site that never enabled that add-on is outside the path Wordfence describes. An inactive copy of the plugin is still files on disk; update or remove it.

## Remediation

1. Update to **3.5.55 or later**. 3.5.57 is the current WordPress.org release.
2. Until then, turn off the PDF Generator add-on. That removes the condition Wordfence names. It is not a fix.
3. Updating does not restore a file that was already deleted. If `wp-config.php` is missing, the site is down until that file is restored from a copy you trust, and the database password in it should be rotated.

## Verification

- The version header reads 3.5.55 or later.
- Submit a form that still generates a PDF and confirm the file is written where you expect. Do not send an object payload.

## Compromise response

If the PDF Generator was on while the plugin was 3.5.54 or earlier:

- Check that `wp-config.php` and other files outside the upload directory are still the ones you deployed.
- Look for a new administrator user and for PHP files added under `wp-content/uploads`.
- A deleted `wp-config.php` is itself the indicator. Restoring it from the old copy puts the old database password back.

## Sources

- [Wordfence vulnerability record][wf] — CVSS 3.1 9.8, through 3.5.54, patched in 3.5.55, PDF Generator required.
- [CVE-2026-102435][cve] — Wordfence CNA.
- [NVD CVE-2026-102435][nvd] — published 2026-11-02.
- [Plugin readme, trunk][readme] — stable tag 3.5.57, changelog date 2026-11-01.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30, not listed.

[wf]: https://www.wordfence.com/threat-intel/vulnerabilities/id/187777a4-3438-489c-ad3b-7e16753189d6?source=cve
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-102435
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-102435
[readme]: https://plugins.svn.wordpress.org/ultimate-addons-for-contact-form-7/trunk/readme.txt
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
