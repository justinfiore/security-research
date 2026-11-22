# NukeViet: a contact message runs script in the administrator's browser

**Last updated:** 2026-11-22 (America/New_York)

[Main NukeViet summary](../black-october-2026.md#nukeviet-a-contact-message-runs-script-in-the-administrators-browser) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-08-30 hoaquynhtim99 published [GHSA-662q-v5rm-78gm](https://github.com/nukeviet/nukeviet/security/advisories/GHSA-662q-v5rm-78gm). GitHub, the CNA, rates [CVE-2026-94565](https://www.cve.org/CVERecord?id=CVE-2026-94565) **CVSS 3.1 9.3 Critical**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:N`. The CVE record was published on 2026-11-20. mrlihd is credited as the reporter. The advisory does not report exploitation.

NukeViet's input filter, `NukeViet\Core\Request::filterTags()`, splits a tag's attributes on an ASCII space only. A browser also splits them on `/`. A contact message that puts `/` immediately before an event-handler name makes the filter see `/onerror`, which does not start with `on`, so the denylist misses it. The browser treats the slash as a separator and runs `onerror`. The message is stored and rendered without output encoding in the administration panel, which sends no Content Security Policy. The script runs in the same origin as the panel, in the session of an administrator who opens the message. The advisory says that can persist a super-administrator account and can reach code execution through administrator functions.

The record says the Contact module is affected from the **3.x** line until **4.6.01**. The advisory's affected versions are **3.x and 4.x**, patched in **4.6.01**. A visitor does not need an account. The advisory's reproduction uses the contact form's CAPTCHA, so a site that has removed the Contact module is outside the path the advisory describes.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-22). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Advisory published | 2026-08-30; time/TZ unknown | GitHub advisory GHSA-662q-v5rm-78gm. Fixed in 4.6.01. [Advisory][ghsa] |
| **Public announcement** | **2026-11-20; time/TZ unknown** | GitHub published the CVE record. [CVE-2026-94565](https://www.cve.org/CVERecord?id=CVE-2026-94565) |

## Detection

Read the NukeViet version. **4.6.01 and later** is outside the range the record names. **3.0.0 through 4.6.00** is inside it. A site that does not run the Contact module is outside the path the advisory describes. Reading the version changes no state.

## Remediation

1. Upgrade to **NukeViet 4.6.01 or later**. The release that carries the fix is 4.6.01.
2. There is no configuration workaround in the advisory. Removing the Contact module takes away the form the advisory uses, and the filter the advisory describes is applied to virtually all POST data, so removing the module is not a substitute for the upgrade.

## Verification

- The installed NukeViet is **4.6.01 or later**.
- Do not submit a crafted contact message to test it.

## Compromise response

The advisory does not report exploitation. The upgrade does not remove an administrator account that was already created, and it does not undo a change an administrator's browser already made. Review administrator accounts you did not create, and review contact messages stored before the upgrade.

## Sources

- [GHSA-662q-v5rm-78gm][ghsa] — published 2026-08-30 by hoaquynhtim99. Critical, CVSS 3.1 9.3. Affected 3.x and 4.x. Patched in 4.6.01. Reporter mrlihd.
- [CVE-2026-94565](https://www.cve.org/CVERecord?id=CVE-2026-94565) — published 2026-11-20. GitHub is the CNA. CVSS 3.1 9.3, `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:N`. Affected from 3.0.0 before 4.6.01. CWE-79.
- [NukeViet 4.6.01 release](https://github.com/nukeviet/nukeviet/releases/tag/4.6.01) — the fixed release, linked from the CVE record.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-22. Not listed.

[ghsa]: https://github.com/nukeviet/nukeviet/security/advisories/GHSA-662q-v5rm-78gm
