# WordPress: two plugins run code or raise a role

**Last updated:** 2026-11-27 (America/New_York)

[Main guide](../black-october-2026.md#wordpress-two-plugins-run-code-or-raise-a-role)

**Patchstack rates two flaws Critical.** Patchstack is the CNA. The records were published 2026-11-27. Patchstack's own pages are dated November 25 and call the first one Medium priority.

- **[CVE-2026-134963](https://www.cve.org/CVERecord?id=CVE-2026-134963)** — WPMasterToolKit, code injection, **CVSS 3.1 9.9 Critical**, vector `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`. The record says through **2.26.1** and names **2.26.2** as unaffected. Patchstack's page says the required privilege is Contributor. The record's vector says Low. Patchstack calls it Medium priority.
- **[CVE-2026-136115](https://www.cve.org/CVERecord?id=CVE-2026-136115)** — MemberPress Discord Addon, privilege escalation, **CVSS 3.1 9.8 Critical**, vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Through **1.1.5**. Patchstack's page says no official patch is available and that the required privilege is Unauthenticated. It calls the entry High priority.

Neither page describes the request. No source read for this entry reports exploitation. This is not the [November 26 set](wordpress-nov26.md).

**CISA KEV:** Not listed (catalog 2026.11.27, checked 2026-11-27) for either. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Patchstack pages | 2026-11-25; time/TZ unknown | Both entries. WPMasterToolKit names 2.26.2. MemberPress Discord Addon names no patch. |
| **Public announcement** | **2026-11-27; time/TZ unknown** | Patchstack published the two CVE records. 9.9 and 9.8. |
| **Last updated** | **2026-11-27 (America/New_York)** | New item. |

## Detection

On each site, read the installed version of WPMasterToolKit (`wpmastertoolkit`) and MemberPress Discord Addon (`expresstechsoftwares-memberpress-discord-add-on`). A plugin that is not installed is outside that flaw. The ranges are through 2.26.1 and through 1.1.5. Reading the version changes no state. A version you cannot read is unknown, not safe.

## Remediation

1. Update WPMasterToolKit to **2.26.2 or later**.
2. MemberPress Discord Addon has no patched version on the page read 2026-11-27. Remove it, or keep it off a site where a visitor should not be able to raise a role. Deactivating it is the control the page leaves you.
3. The update does not remove an account or a role that was already created.

## Verification

- WPMasterToolKit shows 2.26.2 or later.
- MemberPress Discord Addon is absent, or the site owner has accepted that there is no fix.
- Do not send a request to test either flaw.

## Compromise response

No source read for this entry reports exploitation. Look for an administrator or a role the owner did not add. Removing the plugin does not remove that account.

## Sources

- [Patchstack, WPMasterToolKit](https://patchstack.com/database/wordpress/plugin/wpmastertoolkit/vulnerability/wordpress-wpmastertoolkit-plugin-2-26-1-arbitrary-code-execution-vulnerability-2) — page dated 2026-11-25. CVSS 9.9. Through 2.26.1, patched in 2.26.2. Required privilege Contributor. Medium priority.
- [CVE-2026-134963](https://www.cve.org/CVERecord?id=CVE-2026-134963) — Patchstack, published 2026-11-27. CVSS 3.1 9.9. CWE-94. Unaffected from 2.26.2.
- [Patchstack, MemberPress Discord Addon](https://patchstack.com/database/wordpress/plugin/expresstechsoftwares-memberpress-discord-add-on/vulnerability/wordpress-memberpress-discord-addon-plugin-1-1-5-privilege-escalation-vulnerability) — page dated 2026-11-25. CVSS 9.8. Through 1.1.5. No official patch. Required privilege Unauthenticated. High priority.
- [CVE-2026-136115](https://www.cve.org/CVERecord?id=CVE-2026-136115) — Patchstack, published 2026-11-27. CVSS 3.1 9.8. CWE-266. No unaffected version in the record.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.27, checked 2026-11-27. Neither CVE is listed.
