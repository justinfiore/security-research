# Langflow: unauthenticated login bypass and code execution

**Last updated:** 2026-11-04 (America/New_York)

[Main Langflow IBM summary](../black-october-2026.md#langflow-unauthenticated-login-bypass-and-code-execution) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

IBM's October 28, 2026 bulletin, modified October 29, covers a different set of flaws from the [MCP stdio pair](langflow.md) already fixed in 1.10.3. IBM rates two of them **CVSS 3.1 9.8 Critical** and one **8.8 High**. The affected range is Langflow OSS **1.0.0 through 1.12.8**. The only fix IBM names is **1.13.0**. NVD has not published its own scores. IBM lists no workaround. On November 4 the project published **1.13.1** and **1.12.9**. The 1.12.9 notes say that release backports the 1.13.1 fixes. Neither note names these CVEs, and IBM's bulletin still stops at 1.13.0.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-02). IBM does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [What each CVE covers](#what-each-cve-covers)
- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## What each CVE covers

| CVE | IBM CVSS 3.1 | Account | What IBM says |
|---|---|---|---|
| [CVE-2026-93680](https://www.cve.org/CVERecord?id=CVE-2026-93680) | 9.8 Critical | None | Improper authentication lets a remote attacker bypass security restrictions. The bulletin summary calls this an incomplete remediation of an auto-login control. |
| [CVE-2026-110186](https://www.cve.org/CVERecord?id=CVE-2026-110186) | 9.8 Critical | None | Improper control of code generation lets a remote attacker run arbitrary code. The bulletin summary calls this unauthenticated remote code execution through model-context-protocol tool enumeration. |
| [CVE-2026-110193](https://www.cve.org/CVERecord?id=CVE-2026-110193) | 8.8 High | Low-privileged | A signed-in user can make the Agentic Assistant generate or submit component code with unblocked patterns, and that code runs on the server. |
| [CVE-2026-110192](https://www.cve.org/CVERecord?id=CVE-2026-110192) | 6.5 Medium | Authenticated | Insufficiently protected credentials. The bulletin summary calls this operator-injected API key exposure reachable without the intended authorization. Not the reason to rush; it rides along with 1.13.0. |

The same bulletin also lists three Hono dependency flaws, [CVE-2026-84363](https://www.cve.org/CVERecord?id=CVE-2026-84363), [CVE-2026-84364](https://www.cve.org/CVERecord?id=CVE-2026-84364), and [CVE-2026-84365](https://www.cve.org/CVERecord?id=CVE-2026-84365). GitHub scores those 5.3 to 6.5. They are not the reason to upgrade.

IBM does not say whether turning auto-login off removes the two 9.8 flaws. Do not treat that setting as a fix. The [MCP stdio item](langflow.md) is separate: its full fix is 1.10.3, and 1.13.0 also covers it.

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery | Unknown | The bulletin does not name a reporter or a private-report date. |
| Langflow 1.13.0 released | 2026-10-22 21:20 UTC | GitHub tag `v1.13.0`. The release notes do not name these CVEs. Official packages default `LANGFLOW_AUTO_LOGIN` to false. [Release][rel113] |
| Langflow 1.12.8 released | 2026-10-22 17:08 UTC | Same day, earlier. IBM lists it as the last affected release. [Release][rel1128] |
| IBM bulletin | 2026-10-28; time/TZ unknown | Initial publication. The page's modified date is now 29 October 2026. IBM says that edit clarified the fixed version and installation steps. The affected range and the fix, 1.13.0, did not change. [Bulletin][ibm] |
| CVE records published | 2026-10-29; time unknown | IBM CNA. Records updated the same day. [CVE-2026-93680][cve-93680] |
| Langflow 1.12.9 and 1.13.1 | 2026-11-04 01:39:07 UTC and 03:14:15 UTC | 1.12.9's notes say it backports the 1.13.1 fixes, including `fix(security)` commits. Neither note names these CVEs. IBM's bulletin, still dated 29 October 2026, does not mention either release. [1.13.1][rel1131] [1.12.9][rel1129] |

## Detection

1. Read `langflow`, `langflow-base`, and `lfx` from installed package metadata or the image tag. Do not import Langflow to learn the version.
2. Any of those below 1.13.0, through 1.12.8, is inside IBM's range. A build already at 1.10.3 or later is fixed for the [MCP stdio pair](langflow.md) and is still inside this range. **1.12.9** is newer than the last version IBM lists as affected. IBM has not said 1.12.9 is fixed.
3. IBM published no compromise indicators and no request paths. A version in the range is exposure. The Centre for Cybersecurity Belgium says a proof of concept exists for CVE-2026-93680; this guide has not reviewed that code and does not link it.

## Remediation

1. Upgrade `langflow`, `langflow-base`, and `lfx` together to **1.13.1 or later**. `pip install langflow --upgrade`, or pull a 1.13.1 or later image, then restart. 1.13.0 is the only version IBM's bulletin names. 1.13.1 is the current release on that line and includes later security fixes the 1.13.0 notes do not. Do not move a 1.13 deployment back to 1.12.9: that tag is a backport for people who cannot leave the 1.12 line, and IBM has not said it fixes these CVEs.
2. 1.13.0 turns auto-login off by default and refuses to start without a superuser password. Set `LANGFLOW_SUPERUSER_PASSWORD` before the upgrade so existing flows stay reachable. An explicit `LANGFLOW_AUTO_LOGIN=true` still overrides the new default.
3. IBM lists no workaround. Do not leave 1.12.8 or earlier reachable from an untrusted network while you wait.
4. The same upgrade is the current recommendation on the [MCP stdio item](langflow.md). You do not need two upgrades.

## Verification

- Package metadata or the running image tag shows 1.13.1 or later for `langflow`, `langflow-base`, and `lfx`. 1.13.0 meets the version IBM names and does not include the November 4 fixes. 1.12.9 is not a substitute unless you are staying on the 1.12 line and accept that IBM has not called it fixed.
- `LANGFLOW_AUTO_LOGIN` is not set to true unless you intend the old behavior.
- Sign in through the normal login page after the restart. Do not send an exploit payload.

## Compromise response

If an untrusted client could reach a build through 1.12.8, treat the process account as exposed. Rotate `LANGFLOW_SECRET_KEY`, the superuser password, provider API keys, and database credentials stored on that host. Review accounts created while auto-login was on. The upgrade stops the paths IBM describes. It does not show whether they were used.

## Sources

- [IBM bulletin 7294467][ibm] — 1.0.0 through 1.12.8, fix 1.13.0, no workaround. Initial publication 28 October 2026. Modified 29 October 2026; that edit did not change the versions.
- [CVE-2026-93680][cve-93680] — IBM CNA, CVSS 3.1 9.8, no account.
- [CVE-2026-110186][cve-110186] — IBM CNA, CVSS 3.1 9.8, no account.
- [CVE-2026-110193][cve-110193] — IBM CNA, CVSS 3.1 8.8, low-privileged account.
- [Langflow 1.13.0][rel113] — 2026-10-22 21:20 UTC. Notes do not name these CVEs. The only version IBM names as fixed.
- [Langflow 1.12.8][rel1128] — 2026-10-22 17:08 UTC. Last release IBM lists as affected.
- [Langflow 1.13.1][rel1131] — 2026-11-04 03:14:15 UTC. Later `fix(security)` commits. The notes do not name CVE-2026-93680 or CVE-2026-110186.
- [Langflow 1.12.9][rel1129] — 2026-11-04 01:39:07 UTC. The notes say it backports the 1.13.1 fixes. IBM's affected range still ends at 1.12.8 and does not mention this tag.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30, not listed.

[ibm]: https://www.ibm.com/support/pages/node/7294467
[cve-93680]: https://www.cve.org/CVERecord?id=CVE-2026-93680
[cve-110186]: https://www.cve.org/CVERecord?id=CVE-2026-110186
[cve-110193]: https://www.cve.org/CVERecord?id=CVE-2026-110193
[rel113]: https://github.com/langflow-ai/langflow/releases/tag/v1.13.0
[rel1128]: https://github.com/langflow-ai/langflow/releases/tag/v1.12.8
[rel1131]: https://github.com/langflow-ai/langflow/releases/tag/v1.13.1
[rel1129]: https://github.com/langflow-ai/langflow/releases/tag/v1.12.9
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
