# SHIRASAGI: authenticated command injection in open-data harvest

**Last updated:** 2026-11-05 (America/New_York)

[Back to SHIRASAGI summary](../black-october-2026.md#shirasagi-authenticated-command-injection-in-open-data-harvest) · [Changelog](../../CHANGELOG.md)

JPCERT/CC rates [CVE-2026-118869](https://www.cve.org/CVERecord?id=CVE-2026-118869) CVSS 3.0 8.8 High (CVSS 4.0 8.7) in SHIRASAGI v1.19.0 through v1.21.0. A logged-in user who can edit an open-data harvest import can put a shell command in the harvest URL. The project fixed it in **v1.21.1**, published with [JVN#55454512][jvn] on 2026-11-05. The same advisory's cross-site scripting flaw, [CVE-2026-117679](https://www.cve.org/CVERecord?id=CVE-2026-117679), is 5.4 and is not a separate High item.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05). JVN does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| JVN and project page | 2026-11-05; time/TZ unknown | [JVN#55454512][jvn] and the [project page][proj]. Fixed version v1.21.1. |
| **Last updated** | **2026-11-05 (America/New_York)** | New item. |

## Detection

1. This is the SHIRASAGI CMS, versions **v1.19.0 through v1.21.0** for the command injection. v1.18.2 and earlier do not have the vulnerable harvest implementation. The project says the open-data harvest feature is absent, or present and safe, on those older versions.
2. The attacker must already log in to the CMS admin screen and must be allowed to manage open-data datasets and their harvest. The project says the site also has to have open data set up. A public visitor is not the condition in the advisory.
3. The project describes the input as the harvest import URL. A value such as a shell metacharacter in that field is the shape they published. A URL that is only a normal dataset address is not, by itself, evidence of the flaw.
4. JVN publishes no log signature. An import that completed is not evidence a command did or did not run.

## Remediation

1. Upgrade to **v1.21.1**. That is the version the project and JVN name for both flaws in the advisory. The command-injection commit the project lists is [`98eca875`](https://github.com/shirasagi/shirasagi/commit/98eca87586f4a6f74114fdfa7a6b88d3e49af029). Applying that commit without the release is the project's alternative, not a different fix.
2. The project warns that moving from v1.14.2 or earlier to a current release crosses a CMS incompatibility documented in the [v1.15.0 release](https://www.ss-proj.org/release/836.html). Read that note before jumping versions. v1.19.0 through v1.21.0 are already past it.
3. There is no workaround on the JVN page. Removing a user's permission to edit harvest imports reduces who can send the URL. It does not fix v1.21.0.
4. Upgrading does not undo a command that already ran.

## Verification

- The running SHIRASAGI version is **v1.21.1 or later**. A copy of the commit on a tree that is otherwise v1.21.0 is the project's alternative only if that commit is the one that landed.
- A harvest URL stored before the upgrade is still the URL. Review ones you cannot account for; the upgrade does not delete them.
- An import that still fetches a dataset you configured is not evidence the command injection remains.

## Compromise response

- The advisory says the logged-in user can execute OS commands. If an account that can manage harvests was not yours, treat the host as one where a command may have run.
- Review harvest import URLs and the accounts that can edit them. Remove accounts you cannot account for. The upgrade does not expire their sessions.
- The advisory does not name files read or changed. A quiet import log does not show that a shell command did not run.

## Sources

- [JVN#55454512][jvn] — published 2026-11-05. CVE-2026-118869 is CVSS 3.0 8.8 and CVSS 4.0 8.7, v1.19.0 through v1.21.0. Fixed in v1.21.1. CVE-2026-117679 is 5.4 / 5.1, v1.12.0 through v1.21.0, fixed in the same release.
- [SHIRASAGI project page][proj] — the command injection needs a logged-in user who can edit an open-data harvest import URL, then click import. v1.18.2 and earlier are not affected. Commit `98eca875` is the fix they list for the command injection.
- [CVE-2026-118869][cve] — JPCERT/CC CNA, published 2026-11-05. Affected v1.19.0 through v1.21.0.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.04, checked 2026-11-05).

[jvn]: https://jvn.jp/en/jp/JVN55454512/
[proj]: https://www.ss-proj.org/support/1743.html
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-118869
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
