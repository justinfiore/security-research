# Mitel OpenScape: a request with no login reaches the platform

**Last updated:** 2026-11-27 (America/New_York)

[Main guide](../black-october-2026.md#mitel-openscape-a-request-with-no-login-reaches-the-platform)

Mitel published [MISA-2026-0013][adv] on 2026-11-18, revision 1.0. It rates three flaws in the Platform component of OpenScape 4000 and OpenScape 4000 Manager **Critical**. The advisory still says a CVE identifier has been requested and is not yet assigned. MITRE published the three records on 2026-11-27 and repeats Mitel's scores.

- **[CVE-2026-137724](https://www.cve.org/CVERecord?id=CVE-2026-137724)** (MTLVULN-1785) is **CVSS 3.1 10.0 Critical**, vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`. Missing authentication. A request with no login obtains sensitive information and unauthorized access to the system.
- **[CVE-2026-137721](https://www.cve.org/CVERecord?id=CVE-2026-137721)** (MTLVULN-1786) is **CVSS 3.1 10.0 Critical**, the same vector. Insufficient parameter sanitization. A request with no login runs commands in the context of the system.
- **[CVE-2026-137723](https://www.cve.org/CVERecord?id=CVE-2026-137723)** (MTLVULN-1793) is **CVSS 3.1 9.6 Critical**, vector `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`. The same class of command injection, and the attacker needs adjacent network access.

Neither Mitel nor the records name the service inside the Platform component. The release notes sit in KB000129263, which requires a Mitel login. This guide did not read that article. Mitel does not report exploitation. This is not [MiCollab](micollab.md).

**CISA KEV:** Not listed (catalog 2026.11.27, checked 2026-11-27) for any of the three. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-18; time/TZ unknown** | MISA-2026-0013 revision 1.0. Internal IDs only. Three Critical scores. [Advisory][adv] |
| **CVE records** | **2026-11-27 05:22:26 UTC through 05:33:03 UTC** | MITRE published CVE-2026-137721, CVE-2026-137723, and CVE-2026-137724. Scores match Mitel's table. The advisory text was not updated. |
| **Last updated** | **2026-11-27 (America/New_York)** | New item. |

## Detection

Read the installed version of OpenScape 4000 and of OpenScape 4000 Manager. Mitel's affected ranges are:

| Product | Affected |
|---|---|
| OpenScape 4000 | V11 R0.22 through V11 R2.11, and V10 R1.68 and earlier |
| OpenScape 4000 Manager | V11 R0.22 through V11 R2.11, and V10 R1.34, V10 R1.42, V10 R1.54, and V10 R1.68 |

The CVE records describe the Manager's V10 range as V10 R1.34 through V10 R1.68. Mitel's table lists those four builds. A version this table does not list is unknown, not safe. A product Mitel has marked End of Support is outside the advisory's statement, and that is not the same as fixed. Reading the version changes no state.

## Remediation

1. Upgrade OpenScape 4000 and OpenScape 4000 Manager to **V11 R2.14 or later**.
2. On V11 R1.26, Mitel provides **PLT HF5**. Upgrade to that release and apply the hotfix, or move to a later release.
3. On older releases, Mitel provides a patch for OpenScape 4000 **V10 R0.28 through V11 R0.22** and for OpenScape 4000 Manager **V10 R1.34 through V11 R0.22**. Upgrade to one of those releases and apply the patch.
4. The release notes and the hotfix are in [KB000129263][kb]. That article requires a Mitel login. A partner can supply it.
5. Until the update, Mitel says enabling Security Mode restricted access prevents exploitation. The steps are in the same article. That mode is not a substitute for V11 R2.14.

## Verification

- Each system shows V11 R2.14 or later, or the hotfix or patch Mitel names for that older release.
- Do not send a request to test the missing authentication.

## Compromise response

Mitel does not report exploitation. A system that was reachable before the update should be reviewed for an account, a setting, or a process the owner did not add. The update does not remove one. The advisory publishes no indicator.

## Sources

- [MISA-2026-0013][adv] — first issued and last updated 2026-11-18, revision 1.0. Three Critical scores. CVE identifiers not yet printed on the page. Fixed in V11 R2.14, with PLT HF5 and an older patch. Security Mode is the workaround.
- [CVE-2026-137724](https://www.cve.org/CVERecord?id=CVE-2026-137724) — MITRE, published 2026-11-27 05:33:03 UTC. CVSS 3.1 10.0. CWE-306. MTLVULN-1785.
- [CVE-2026-137721](https://www.cve.org/CVERecord?id=CVE-2026-137721) — MITRE, published 2026-11-27 05:22:26 UTC. CVSS 3.1 10.0. CWE-78. MTLVULN-1786.
- [CVE-2026-137723](https://www.cve.org/CVERecord?id=CVE-2026-137723) — MITRE, published 2026-11-27 05:29:05 UTC. CVSS 3.1 9.6. CWE-78. Adjacent network. MTLVULN-1793.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.27, checked 2026-11-27. None of the three is listed.

[adv]: https://www.mitel.com/support/security-advisories/mitel-product-security-advisory-misa-2026-0013
[kb]: https://mitel.service-now.com/mitel?id=kb_article&sys_id=3843741e3b209350b2eb202a85e45a08
