# WordPress: three plugins run a script from a field

**Last updated:** 2026-11-27 (America/New_York)

[Main guide](../black-october-2026.md#wordpress-three-plugins-run-a-script-from-a-field)

**Patchstack rates three flaws CVSS 3.1 7.1 High.** Each vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:L/I:L/A:L`. The weakness is CWE-79. Patchstack's own pages call each one Medium priority and say a visitor has to do something, such as open a page, before the script runs. The CVE records say no login is required.

- **[CVE-2026-135005](https://www.cve.org/CVERecord?id=CVE-2026-135005)** — SiteOrigin Widgets Bundle, stored XSS, through **1.76.0**, fixed in **1.77.0**.
- **[CVE-2026-134711](https://www.cve.org/CVERecord?id=CVE-2026-134711)** — Listdom, reflected XSS, through **6.4.0**, fixed in **6.5.0**.
- **[CVE-2026-134474](https://www.cve.org/CVERecord?id=CVE-2026-134474)** — Opti-Behavior, DOM-based XSS, through **1.11.0**, fixed in **1.11.1**.

The records were published 2026-11-26. Patchstack's pages for the first two are dated November 24. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-27) for any of the three. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Patchstack pages | 2026-11-24; time/TZ unknown | SiteOrigin and Listdom entries. [SiteOrigin][so] [Listdom][ld] |
| **Public announcement** | **2026-11-26; time/TZ unknown** | Patchstack published the three CVE records. Each CVSS 3.1 7.1. |
| **Last updated** | **2026-11-27 (America/New_York)** | New item. |

## Detection

On each site, read the installed version of SiteOrigin Widgets Bundle, Listdom, and Opti-Behavior. A plugin that is not installed is outside that flaw. The ranges are through 1.76.0, through 6.4.0, and through 1.11.0. Reading the version changes no state. A version you cannot read is unknown, not safe.

## Remediation

1. Update SiteOrigin Widgets Bundle to **1.77.0 or later**.
2. Update Listdom to **6.5.0 or later**.
3. Update Opti-Behavior to **1.11.1 or later**.
4. A site that has none of the three has nothing to update for this entry.

## Verification

- Each installed plugin is at or above the version above.
- Do not submit a script to test it.

## Compromise response

A stored script survives the update. Review pages and widgets saved by SiteOrigin Widgets Bundle before the update for a script nobody placed there. The records publish no indicator.

## Sources

- [CVE-2026-135005](https://www.cve.org/CVERecord?id=CVE-2026-135005) — Patchstack, published 2026-11-26. CVSS 3.1 7.1. SiteOrigin Widgets Bundle through 1.76.0, fixed in 1.77.0.
- [CVE-2026-134711](https://www.cve.org/CVERecord?id=CVE-2026-134711) — Patchstack, published 2026-11-26. CVSS 3.1 7.1. Listdom through 6.4.0, fixed in 6.5.0.
- [CVE-2026-134474](https://www.cve.org/CVERecord?id=CVE-2026-134474) — Patchstack, published 2026-11-26. CVSS 3.1 7.1. Opti-Behavior through 1.11.0, fixed in 1.11.1.
- [Patchstack, SiteOrigin][so] and [Patchstack, Listdom][ld] — dated November 24. Both say Medium priority and that a visitor has to act.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-27. None of the three is listed.

[so]: https://patchstack.com/database/wordpress/plugin/so-widgets-bundle/vulnerability/wordpress-siteorigin-widgets-bundle-plugin-1-76-0-cross-site-scripting-xss-vulnerability?_s_id=cve
[ld]: https://patchstack.com/database/wordpress/plugin/listdom/vulnerability/wordpress-listdom-plugin-6-4-0-cross-site-scripting-xss-vulnerability?_s_id=cve
