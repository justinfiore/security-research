# Node.js: binary-parser runs code from a parser option

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#nodejs-binary-parser-runs-code-from-a-parser-option) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-11 the maintainer published [GHSA-xmxc-6c22-m377][ghsa] for the `binary-parser` npm package. The maintainer rates it **High, CVSS 3.1 8.1**. The vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`. The page names no CVE. On 2026-11-22 VulnCheck published [CVE-2026-134814](https://www.cve.org/CVERecord?id=CVE-2026-134814) for the same issue and rates it **CVSS 4.0 9.2 Critical** and **CVSS 3.1 8.1 High**, with the same CVSS 3.1 vector. The CVSS 4.0 vector is `CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The maintainer's High and VulnCheck's Critical disagree, and both stay. NVD has not scored it.

An earlier fix, which the advisory calls CVE-2026-1245, checked field names and encodings. Other string options were still copied into the generated parser source. Someone who controls the parser definition, for example a schema loaded from JSON, can put JavaScript in `length`, `lengthInBytes`, `key`, `tag`, `offset`, or the alias passed to `namely()`. That code runs in the Node.js process when the parser is compiled. The maintainer says parsing untrusted bytes with a parser definition the application wrote itself is not this flaw.

Every version **through 2.3.0** is affected. **2.3.1** checks those options as identifier paths and rejects an expression. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-23). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-11; time/TZ unknown** | The maintainer published GHSA-xmxc-6c22-m377. CVSS 3.1 8.1. No CVE. [GHSA][ghsa] |
| CVE record | 2026-11-22; time/TZ unknown | VulnCheck published the record. CVSS 4.0 9.2 and CVSS 3.1 8.1. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-134814) |

## Detection

Read `binary-parser` from the lockfile. **2.3.0 and earlier** are inside the range the advisory names. An application whose parser definition is its own code, and that only feeds untrusted bytes to it, is outside the condition the maintainer names. Reading the lockfile changes no state.

## Remediation

1. Upgrade `binary-parser` to **2.3.1 or later**.
2. A parser definition that used an expression such as `"len - 1"` for `length` has to become a function. 2.3.1 rejects that string.
3. The upgrade does not show whether a parser definition already ran code.

## Verification

- The installed `binary-parser` is **2.3.1 or later**.
- Do not load a crafted parser definition to test it.

## Compromise response

No source read for this entry reports an incident. If the application compiled parser definitions from outside input before the upgrade, review what that process could run and rotate credentials it could read. The upgrade does not undo code that already ran.

## Sources

- [GHSA-xmxc-6c22-m377][ghsa] — keichi, published 2026-11-11. High, CVSS 3.1 8.1. Affected through 2.3.0. Patched in 2.3.1. Names no CVE. Credits Zachariah Mithani.
- [CVE-2026-134814](https://www.cve.org/CVERecord?id=CVE-2026-134814) — VulnCheck, published 2026-11-22. CVSS 4.0 9.2 and CVSS 3.1 8.1. Affected from 0 before 2.3.1.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-23. Not listed.

[ghsa]: https://github.com/keichi/binary-parser/security/advisories/GHSA-xmxc-6c22-m377
