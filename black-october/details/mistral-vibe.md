# Mistral Vibe: a repository Git setting runs a program before the trust prompt

**Last updated:** 2026-11-05 (America/New_York)

[Back to Mistral Vibe summary](../black-october-2026.md#mistral-vibe-a-repository-git-setting-runs-a-program-before-the-trust-prompt) · [Changelog](../../CHANGELOG.md)

VulnCheck rates [CVE-2026-122135](https://www.cve.org/CVERecord?id=CVE-2026-122135) CVSS 4.0 8.6 High (CVSS 3.1 8.8) in Mistral Vibe before 3.0.3. Opening a repository that sets `gpg.program` and `log.showSignature`, and that contains a signed commit, makes `git log` run that program when Vibe collects project context, before the trust prompt. The changelog line for the fix shipped in **3.0.3 on 2026-10-26**. VulnCheck published the CVE on 2026-11-04. Two older High flaws in the same product, fixed in September, are named below and are not this bug.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05) for CVE-2026-122135 or the two September CVEs. VulnCheck does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| 2.25.7 | 2026-09-22 | VulnCheck says [CVE-2026-122134](https://www.cve.org/CVERecord?id=CVE-2026-122134) is fixed before 2.25.7. The 2.25.7 changelog does not name the CVE. |
| 3.0.3 | 2026-10-26 | Changelog: "Automatic project context no longer runs repository-configured Git signature verification programs." That is the sentence that matches CVE-2026-122135. The changelog does not print the CVE. |
| CVE records | 2026-11-04 20:36 UTC | VulnCheck published CVE-2026-122135, and the same day CVE-2026-122134 and CVE-2026-122133. |
| **Last updated** | **2026-11-05 (America/New_York)** | New item. The fix is 3.0.3, which is older than the CVE record. |

## Detection

1. This is the **mistral-vibe** package and the Vibe desktop or CLI that embeds it, before **3.0.3**. A checkout of the GitHub repository is the same product. `vibe --version`, or the installed package version, is the check. 3.0.3 and later already contain the signature-program fix.
2. The record's condition is a repository the user opens. The repository sets `gpg.program` and `log.showSignature`, and it has a signed commit. Vibe runs `git log` while collecting project context, and Git then runs `gpg.program`, before Vibe asks whether the folder is trusted. A repository you wrote yourself is not an attack. A repository you cloned is the case the record describes.
3. [CVE-2026-122134](https://www.cve.org/CVERecord?id=CVE-2026-122134) is a different bug, fixed before 2.25.7: a repository-configured Git clean or process filter runs when Vibe starts and asks `git status`. [CVE-2026-122133](https://www.cve.org/CVERecord?id=CVE-2026-122133) is fixed before 2.25.5, only on Windows, and runs a `git.exe` placed in the repository root. 3.0.3 is after both. A host still below 2.25.7 is inside all three ranges.
4. Neither VulnCheck nor the changelog publishes a log line that means the program ran. A session that started is not that evidence.

## Remediation

1. Upgrade to **3.0.3 or later**. The changelog dates 3.0.3 to 2026-10-26. The current GitHub release line has moved past it; 3.0.3 is the floor for this CVE, not a requirement to stay on 3.0.3.
2. There is no vendor workaround in the CVE record. Not opening a repository you do not trust is how you avoid the condition. It is not a fix for a Vibe build before 3.0.3.
3. Upgrading does not undo a program that already ran when a repository was opened.

## Verification

- `vibe --version`, or the installed `mistral-vibe` package, is **3.0.3 or later**. A changelog on the web that mentions the fix is not the binary on the machine.
- Opening a repository still asks before Vibe treats the folder as trusted. The record says the old build ran the program before that question. The question returning is not, by itself, proof of the version.
- A repository whose `.git/config` sets `gpg.program` to a path you did not set is a reason to look at that repository. It is not proof Vibe ran it.

## Compromise response

- If Vibe before 3.0.3 opened a repository you did not write, the record says a program named by that repository may have run as you, before you answered the trust prompt.
- The record does not name files read or changed. A quiet session log does not show that the program did not run.
- Credentials that Vibe or the user account could read from that machine are the ones to rotate if you cannot account for the repository. The upgrade does not expire them.

## Sources

- [CVE-2026-122135][cve] — VulnCheck, published 2026-11-04. CVSS 4.0 8.6 and CVSS 3.1 8.8. Affected from 0 before 3.0.3. User interaction is active (3.1: required).
- [VulnCheck advisory][vc] — same description. Credit: Francisco Rosales (Manifold Security). Patch commit `7bb48f213ac677f943d5c791199ed3dddf302f00`.
- [Changelog at 3.0.3][log] — dated 2026-10-26. "Automatic project context no longer runs repository-configured Git signature verification programs." The file does not name the CVE.
- [CVE-2026-122134][cve134] and [CVE-2026-122133][cve133] — VulnCheck, 2026-11-04. Fixed before 2.25.7 and before 2.25.5. Not the 3.0.3 bug.
- [CISA KEV JSON feed][kev] — none of the three listed (catalog 2026.11.04, checked 2026-11-05).

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-122135
[vc]: https://www.vulncheck.com/advisories/mistral-vibe-before-3.0.3-rce-via-repository-configured-gpg-program
[log]: https://github.com/mistralai/mistral-vibe/blob/v3.0.3/CHANGELOG.md?plain=1#L113
[cve134]: https://www.cve.org/CVERecord?id=CVE-2026-122134
[cve133]: https://www.cve.org/CVERecord?id=CVE-2026-122133
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
