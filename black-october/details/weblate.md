# Weblate: a lookalike email resets the password

**Last updated:** 2026-11-25 (America/New_York)

[Main plugin summary](../black-october-2026.md#weblate-a-lookalike-email-resets-the-password) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-13 Weblate published [GHSA-6hph-c9x9-4mcv][ghsa]. Weblate rates it **Critical, CVSS 3.1 9.1**. The vector on that page is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. The page names no CVE. On 2026-11-22 VulnCheck published [CVE-2026-134838](https://www.cve.org/CVERecord?id=CVE-2026-134838) for the same issue and rates it **CVSS 4.0 9.1 Critical** and **CVSS 3.1 7.4 High**. The CVSS 4.0 vector is `CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N`. The CVSS 3.1 vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:N`. Weblate's 9.1 and VulnCheck's 7.4 disagree, and both stay. NVD has not scored it.

Password reset compares email addresses with the database collation, which treats some distinct Unicode addresses as the same. The reset link is then sent to the address the attacker typed, not to the address stored on the account. Someone who controls a lookalike mailbox, such as one that differs by a dotless i, receives the link and sets a new password. Weblate says the same matching also affects identity and invitation association, and that the demonstrated reset does not bypass an existing second factor. It needs a collation that equates the two addresses, and an account that can be recovered by email.

Every version **before 2026.11** is affected. **2026.11**, released 2026-11-02, compares addresses safely and sends the link to the stored address. **2026.11.1**, released 2026-11-05, adds an upgrade check that lists legacy lookalike identities under account security findings. Weblate's advisory says to upgrade to 2026.11.1 as well, remove unauthorized associations, and reset affected credentials. No source read for this entry reports exploitation.

**A second Critical flaw is in a later release.** [GHSA-rg57-5c8r-3p43](https://github.com/WeblateOrg/weblate/security/advisories/GHSA-rg57-5c8r-3p43), published 2026-11-13, is CVSS 3.1 9.1 and has no CVE. A project administrator can keep a GitHub App push setting the product clears, and the installation token is then sent to a push host the administrator chose. The token can act on the repositories that installation may touch, until it expires. Affected is **2026.7 before 2026.11.2**. A site that does not use a GitHub App is outside it. 2026.11.1, which closes the lookalike-email flaw, does not close this one.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-25). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| 2026.11 | 2026-11-02 18:55:03 UTC | The release notes list the lookalike-email fix. [Release][rel] |
| 2026.11.1 | 2026-11-05 08:40:14 UTC | Adds the lookalike-identity check. [Release][rel1] |
| **Public announcement** | **2026-11-13; time/TZ unknown** | Weblate published GHSA-6hph-c9x9-4mcv. CVSS 3.1 9.1. No CVE. [GHSA][ghsa] |
| CVE record | 2026-11-22; time/TZ unknown | VulnCheck published the record. CVSS 4.0 9.1 and CVSS 3.1 7.4. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-134838) |
| **GitHub App token** | **2026-11-13; time/TZ unknown** | GHSA-rg57-5c8r-3p43, CVSS 3.1 9.1. Fixed in 2026.11.2. No CVE. |

## Detection

Read the installed Weblate version. **Anything before 2026.11** is inside the range both pages name. A site that already requires a second factor is outside the reset chain Weblate demonstrated; the advisory still names identity and invitation association. Reading the version changes no state.

## Remediation

1. Upgrade to **2026.11.2 or later** and run the migrations. 2026.11 closes the email comparison. 2026.11.1 lists the leftover lookalike identities. 2026.11.2 clears the stored GitHub App push settings that send the installation token. A site on 2026.11.1 still has that second flaw if it uses a GitHub App.
2. In account security findings, remove associations you do not recognize, and reset the password on an account that had one.
3. Requiring a second factor limits the reset chain Weblate demonstrated. It is not a substitute for the upgrade.

## Verification

- The running version is **2026.11.2 or later**, and the migrations have run.
- Do not send a password reset to a lookalike address to test it.

## Compromise response

No source read for this entry reports an incident. Review account security findings for lookalike verified email identities, remove the ones you do not recognize, and reset those passwords. The upgrade does not undo a password that was already changed.

## Sources

- [GHSA-6hph-c9x9-4mcv][ghsa] — Weblate, published 2026-11-13. Critical, CVSS 3.1 9.1, `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. Affected before 2026.11. Names no CVE. Credits oss-scanner.
- [CVE-2026-134838](https://www.cve.org/CVERecord?id=CVE-2026-134838) — VulnCheck, published 2026-11-22. CVSS 4.0 9.1 and CVSS 3.1 7.4. Affected from 0 before 2026.11. Credits Zachariah Mithani (AploSec).
- [Weblate 2026.11][rel] — released 2026-11-02. The security-fixes list names the lookalike-email fix.
- [Weblate 2026.11.1][rel1] — released 2026-11-05. Adds the upgrade check for legacy lookalike identities.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-23. Not listed.

[ghsa]: https://github.com/WeblateOrg/weblate/security/advisories/GHSA-6hph-c9x9-4mcv
[rel]: https://github.com/WeblateOrg/weblate/releases/tag/weblate-2026.11
[rel1]: https://github.com/WeblateOrg/weblate/releases/tag/weblate-2026.11.1
