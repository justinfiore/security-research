# ACF Extended: unauthenticated code execution and account takeover

**Last updated:** 2026-11-03 (America/New_York)

[Main ACF Extended summary](../black-october-2026.md#acf-extended-unauthenticated-code-execution-and-account-takeover) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Two plugins share this name. **Advanced Custom Fields: Extended** is the free plugin (`acf-extended`, about 100,000 active installs). **Advanced Custom Fields: Extended PRO** (`acf-extended-pro`) is sold by the same author and is not on WordPress.org. Updating one does not update the other. Both need **0.9.2.8**. Stopping at 0.9.2.7 leaves the October flaws in place, and stopping the free plugin at 0.9.2.6 leaves an older Critical privilege escalation.

**[CVE-2026-94267](https://www.cve.org/CVERecord?id=CVE-2026-94267): WPScan (CNA) published no CVSS score. WPScan's own page scores it 9.0 Critical (`CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:C/C:H/I:H/A:H`). CISA's ADP entry copies that 9.0 vector. Wordfence scores the same CVE 9.8 Critical (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`).** Both plugins before **0.9.2.8** do not check a capability when a front-end form updates a post. WPScan says a visitor can overwrite the posts that store the plugin's own field definitions, and that overwrite leads to code execution. The site has to publish a form whose post-update action maps both the target and the content to values the visitor submits. WPScan will show its proof of concept on 2026-11-21. [WPScan][wpscan-rce] [CVE record][cve-rce] [Wordfence][wf-rce]

**[CVE-2026-120534](https://www.cve.org/CVERecord?id=CVE-2026-120534): Wordfence (CNA) CVSS 3.1 9.8 Critical (`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`).** PRO through **0.9.2.6** passes form configuration into `call_user_func_array` in `render_field`. Wordfence says an unauthenticated attacker can call WordPress functions. One path needs the administrator to turn on the non-default `shortcode_preview` setting. The other needs the server to lack OpenSSL functions, so ACF Pro's `acf_decrypt` falls back to unverified base64. The free plugin is not in this record. Wordfence says the fix is **0.9.2.7**. The CVE record was published 2026-11-03; Wordfence's page says the issue was publicly published 2026-09-14, and WPScan lists the same PRO issue as published 2026-09-14 and fixed in 0.9.2.7. [Wordfence][wf-pro] [CVE record][cve-pro]

**[CVE-2026-94268](https://www.cve.org/CVERecord?id=CVE-2026-94268): WPScan published no CVSS score. WPScan's page and CISA's ADP entry both score it 8.1 High (`CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`). Wordfence scores it 9.8 Critical (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`).** On **0.9.2.7 only**, both plugins, the front-end update-user action checks the target at one stage and acts on a different target at the next. WPScan says a visitor can take the administrator account and receive a session, if the site publishes two forms whose targets come from the visitor. Wordfence's shorter text does not state that condition. [WPScan][wpscan-admin] [Wordfence][wf-admin]

**[CVE-2026-94262](https://www.cve.org/CVERecord?id=CVE-2026-94262): WPScan published no CVSS score. CISA's ADP entry scores it 8.1 High (`CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`). Wordfence scores it 7.3 High (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:L`).** On **0.9.2.7 only**, both plugins, the same update-user action checks authorization only when the target is an administrator. A visitor can overwrite a non-administrator account and obtain a session, if the form maps its target to a visitor-supplied value. [Wordfence][wf-user]

The free plugin has two older Critical flaws that 0.9.2.8 also covers, because they were fixed earlier:

- **[CVE-2026-8809](https://www.cve.org/CVERecord?id=CVE-2026-8809): Wordfence (CNA) CVSS 3.1 9.8 Critical.** Free plugin through **0.9.2.5**. A public form with a Create User action that maps a role field lets a visitor create an administrator. Fixed in **0.9.2.6**. The record does not name PRO. [WPScan][wpscan-old] [CVE record][cve-old]
- **[CVE-2025-13486](https://www.cve.org/CVERecord?id=CVE-2025-13486): Wordfence (CNA) CVSS 3.1 9.8 Critical.** Free plugin **0.9.0.5 through 0.9.1.1**. `prepare_form()` passes visitor input to `call_user_func_array()`. Fixed in **0.9.2**. The record does not name PRO. [WPScan][wpscan-2025]

**CISA KEV:** Not listed (catalog 2026.11.03, checked 2026-11-03) for [CVE-2026-94267](https://www.cve.org/CVERecord?id=CVE-2026-94267), [CVE-2026-120534](https://www.cve.org/CVERecord?id=CVE-2026-120534), [CVE-2026-94268](https://www.cve.org/CVERecord?id=CVE-2026-94268), [CVE-2026-94262](https://www.cve.org/CVERecord?id=CVE-2026-94262), [CVE-2026-8809](https://www.cve.org/CVERecord?id=CVE-2026-8809), or [CVE-2025-13486](https://www.cve.org/CVERecord?id=CVE-2025-13486). No source reviewed here reports exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| CVE-2025-13486 published | 2025-12-03 06:47:46 UTC | Free plugin 0.9.0.5–0.9.1.1. WPScan had published the issue 2025-12-02. Fixed in 0.9.2. [CVE record][cve-2025] |
| CVE-2026-8809 published | 2026-05-28 22:27:27 UTC | Free plugin through 0.9.2.5. Fixed in 0.9.2.6. [CVE record][cve-old] |
| PRO dynamic-render issue published | 2026-09-14; time/TZ unknown | Wordfence's page date and WPScan's plugin list. The CVE record came later. Fixed in PRO 0.9.2.7. [Wordfence][wf-pro] |
| 0.9.2.8 released | 2026-10-19; time/TZ unknown | Vendor changelog date is `19/10/2026`. The free-plugin notes name capability checks and shortcode restrictions. They do not name CVE-2026-94267. [Changelog][changelog] |
| WPScan published the 0.9.2.8 issues | 2026-10-21; time/TZ unknown | CVE-2026-94267, CVE-2026-94268, and CVE-2026-94262. Proofs of concept are withheld until 2026-11-21. [WPScan][wpscan-rce] |
| CVE records for the October issues | 2026-10-23 06:00 UTC | WPScan CNA. The records contain no CVSS score. [CVE-2026-94267][cve-rce] |
| CVE-2026-120534 published | 2026-11-03 04:43:09 UTC | Wordfence CNA, PRO through 0.9.2.6, CVSS 3.1 9.8. [CVE record][cve-pro] |

## Detection

Read the plugin header. Do not load the plugin, and do not submit a form to test it.

```sh
grep -H -m1 -iE '^[[:space:]*]*Version:' \
  WP_ROOT/wp-content/plugins/acf-extended/acf-extended.php \
  WP_ROOT/wp-content/plugins/acf-extended-pro/acf-extended-pro.php
```

The PRO file name can differ. If the header grep finds nothing, search the plugin directories for the version string rather than guessing the file:

```sh
grep -R -n -m1 -iE '^[[:space:]*]*Version:' \
  WP_ROOT/wp-content/plugins/acf-extended \
  WP_ROOT/wp-content/plugins/acf-extended-pro
```

A missing directory means that edition is not installed. An unreadable header is **unknown**, not safe.

| Installed version | Free (`acf-extended`) | PRO (`acf-extended-pro`) |
|---|---|---|
| Below 0.9.2 | CVE-2025-13486 if the version is 0.9.0.5–0.9.1.1, plus CVE-2026-8809 and CVE-2026-94267 | CVE-2026-120534 and CVE-2026-94267. The 2025 record does not name PRO |
| 0.9.2 through 0.9.2.5 | CVE-2026-8809 and CVE-2026-94267 | CVE-2026-120534 and CVE-2026-94267 |
| 0.9.2.6 | CVE-2026-94267. CVE-2026-8809 is fixed | CVE-2026-120534 and CVE-2026-94267 |
| 0.9.2.7 | CVE-2026-94267, CVE-2026-94268, and CVE-2026-94262 | Same three. CVE-2026-120534 is fixed |
| 0.9.2.8 or later | None of these | None of these |

The October flaws need a front-end form whose action takes its target from the visitor. A site with the plugin and no such form does not meet the condition WPScan states. Do not treat "we do not remember building one" as proof: the form configuration is stored in posts, which is the object CVE-2026-94267 overwrites. An inactive plugin is still files on disk.

## Remediation

1. Update **both** installed editions to **0.9.2.8 or later**. The free plugin updates from WordPress.org. PRO updates from the vendor. 0.9.2.7 is not the current fix.
2. There is no vendor workaround in the records reviewed. Removing a public form that maps its target to visitor input removes the condition WPScan names. It does not fix the code, and it does not help a copy that is still on a version affected by CVE-2026-8809 or CVE-2025-13486.
3. Updating does not undo a post that was overwritten, an administrator that was created, or a password that was changed. See [Compromise response](#compromise-response).

## Verification

- Both headers, where the directory exists, read **0.9.2.8** or later.
- A page that uses an ACF Extended form still loads, and a form you already use still accepts a normal submission.
- Do not submit WPScan's proof, including after 2026-11-21, against a production site.

## Compromise response

If a vulnerable version was reachable, including after you have updated it:

- Compare administrator accounts with a known list. CVE-2026-8809 creates one. CVE-2026-94268 changes an existing one and issues a session.
- Review password-reset and user-update times for accounts that did not request a change.
- Look for posts that store ACF Extended field groups and were modified without an editor session. CVE-2026-94267's path is an overwrite of those posts, then code execution. Also look for new PHP files under `wp-content/uploads` and for unexpected scheduled tasks.
- Rotate administrator passwords and WordPress salts if any of those checks hit, or if the logs that would show it are gone.

Absence of a new administrator is not proof the post-overwrite path was unused.

## Sources

- [WPScan, CVE-2026-94267][wpscan-rce] — 9.0 Critical, both plugins before 0.9.2.8, published 2026-10-21, proof withheld until 2026-11-21.
- [CVE-2026-94267][cve-rce] — WPScan CNA, published 2026-10-23 06:00:21 UTC, no CNA score. CISA ADP 9.0.
- [Wordfence, CVE-2026-94267][wf-rce] — 9.8 Critical, patched in 0.9.2.8.
- [Wordfence, CVE-2026-120534][wf-pro] — PRO through 0.9.2.6, 9.8 Critical, patched in 0.9.2.7, page date 2026-09-14.
- [CVE-2026-120534][cve-pro] — Wordfence CNA, published 2026-11-03 04:43:09 UTC.
- [WPScan, CVE-2026-94268][wpscan-admin] — 8.1 High, 0.9.2.7 only, fixed in 0.9.2.8.
- [Wordfence, CVE-2026-94268][wf-admin] — 9.8 Critical for the same issue.
- [Wordfence, CVE-2026-94262][wf-user] — 7.3 High. CISA ADP scores the same CVE 8.1.
- [WPScan, CVE-2026-8809][wpscan-old] — free plugin, fixed in 0.9.2.6, CVSS 9.8.
- [CVE-2026-8809][cve-old] — Wordfence CNA, published 2026-05-28, through 0.9.2.5.
- [WPScan, CVE-2025-13486][wpscan-2025] — free plugin 0.9.0.5–0.9.1.1, fixed in 0.9.2.
- [CVE-2025-13486][cve-2025] — Wordfence CNA, published 2025-12-03.
- [ACF Extended changelog][changelog] — 0.9.2.8 dated 19/10/2026. The free-plugin notes name capability checks. They do not name these CVEs.
- [CISA KEV JSON feed][kev] — catalog 2026.11.03. None of these CVEs is listed.

[wpscan-rce]: https://wpscan.com/vulnerability/9c8f45c1-cd85-4a9c-be77-88801d8143ce/
[cve-rce]: https://www.cve.org/CVERecord?id=CVE-2026-94267
[wf-rce]: https://www.wordfence.com/threat-intel/vulnerabilities/detail/advanced-custom-fields-extended-0927-unauthenticated-remote-code-execution
[wf-pro]: https://www.wordfence.com/threat-intel/vulnerabilities/id/b8a7a925-2b9e-43bc-b649-c7ec518e063c?source=cve
[cve-pro]: https://www.cve.org/CVERecord?id=CVE-2026-120534
[wpscan-admin]: https://wpscan.com/vulnerability/eccfab3c-e7cc-4623-9c20-4cd6c32f8422/
[wf-admin]: https://www.wordfence.com/threat-intel/vulnerabilities/detail/advanced-custom-fields-extended-0927-unauthenticated-privilege-escalation-via-account-takeover
[wf-user]: https://www.wordfence.com/threat-intel/vulnerabilities/detail/advanced-custom-fields-extended-0927-unauthenticated-arbitrary-non-admin-account-takeover
[wpscan-old]: https://wpscan.com/vulnerability/37581baa-b6c2-4584-95af-aba986fd8053
[cve-old]: https://www.cve.org/CVERecord?id=CVE-2026-8809
[wpscan-2025]: https://wpscan.com/vulnerability/05e6170d-7e78-4cc8-bf3c-e5072e0aaa0d
[cve-2025]: https://www.cve.org/CVERecord?id=CVE-2025-13486
[changelog]: https://www.acf-extended.com/changelog
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
