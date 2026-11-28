# n8n: an expression escapes the sandbox

**Last updated:** 2026-11-27 (America/New_York)

[Main guide](../black-october-2026.md#n8n-an-expression-escapes-the-sandbox)

n8n published [GHSA-w6f8-8qh4-h3j4][ghsa] on 2026-11-26 at 08:17:19 UTC. GitHub rates it **High, CVSS 4.0 7.7**. The vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:L/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. Attack requirements are Present, and the privilege required is Low. No CVE is assigned. The API returns no CWE.

n8n evaluated workflow expressions in a sandboxed V8 isolate. A flaw in how the bundled V8 engine internalized certain strings let a crafted expression corrupt memory and escape that isolate. A user who could create and run workflows could run arbitrary code in the main n8n process, with the privileges of the n8n service user. The advisory does not report exploitation.

The same day's [security post][post], 2026-11-26 09:40:45 UTC, names higher floors than the advisory. The advisory's patched ranges are npm **2.49.2 or later** and Docker image **3.4.0 or later**, plus pointer-compression images **2.47.6-pc**, **2.48.3-pc**, and **3.2.2-pc**. The post says the fixes landed in stable **2.49.7**, beta **2.50.2**, v3 **3.4.1**, and v1 **1.123.102**. Use the post's floor for the line you run. This is not the [credential-guard bypass](n8n-credential-guard.md).

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. The advisory does not report exploitation. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| First named build | 2026-11-19 08:24:13 UTC | GitHub tag `n8n@2.49.2`, marked pre-release. The advisory later names this npm floor. |
| Docker image 3.4.0 | 2026-11-24 08:11 UTC | Docker Hub tag `3.4.0` and `3.4.0-pc`. The advisory names 3.4.0 as the Docker floor. |
| **Public announcement** | **2026-11-26 08:17:19 UTC** | GHSA-w6f8-8qh4-h3j4. CVSS 4.0 7.7. No CVE. [Advisory][ghsa] |
| Security post | 2026-11-26 09:40:45 UTC | Names 2.49.7, 2.50.2, 3.4.1, and 1.123.102. [Post][post] |
| **Last updated** | **2026-11-27 (America/New_York)** | New item. |

## Detection

Read the version of every self-hosted n8n process and of the image it runs. n8n Cloud is outside the action the post names: it says cloud is patched automatically.

| Line | Advisory floor | Post's floor, 2026-11-26 |
|---|---|---|
| npm, stable 2.49 | 2.49.2 or later | 2.49.7 |
| npm, beta | not named separately | 2.50.2 |
| Docker `n8nio/n8n` | 3.4.0 or later | 3.4.1 |
| v1 | not in the advisory's npm range | 1.123.102 |
| pointer-compression image | 2.47.6-pc, 2.48.3-pc, or 3.2.2-pc | the post does not name a `-pc` tag |

A version you cannot read is unknown, not safe. Reading the version changes no state. An instance where nobody but a fully trusted operator can create or edit a workflow does not meet the condition the advisory names, and the advisory still says to upgrade.

## Remediation

1. Upgrade the line you run to the post's floor or later, then restart every process: stable **2.49.7**, beta **2.50.2**, v3 **3.4.1**, or v1 **1.123.102**. The [upgrade guide](https://docs.n8n.io/hosting/installation/updating/) is the vendor's procedure.
2. A pointer-compression image goes to **2.47.6-pc**, **2.48.3-pc**, or **3.2.2-pc** or later. Those tags are in the advisory. GitHub has no release named exactly that, and Docker Hub has the later `2.49.7-pc` and `3.4.1-pc` tags.
3. Until the restart, the advisory's workaround is to keep workflow creation and editing to fully trusted users. It says that does not remediate the flaw.

## Verification

- Each running process reports the floor for its line or a later version.
- Do not save an expression to test the escape.

## Compromise response

The advisory does not report exploitation. A workflow saved by someone who should not have been able to edit one is the place to look. The upgrade does not remove a workflow, a credential, or a file that expression already wrote. The advisory publishes no indicator.

## Sources

- [GHSA-w6f8-8qh4-h3j4][ghsa] — published 2026-11-26 08:17:19 UTC. CVSS 4.0 7.7. npm below 2.49.2, Docker below 3.4.0, and the three `-pc` tags. No CVE. No exploitation statement.
- [Security update, 26 November 2026][post] — 2026-11-26 09:40:45 UTC. Names 2.49.7, 2.50.2, 3.4.1, and 1.123.102. Three other advisories in the same post are Medium.
- [n8n@2.49.2](https://github.com/n8n-io/n8n/releases/tag/n8n%402.49.2) — published 2026-11-19 08:24:13 UTC, pre-release.
- [n8n@2.49.7](https://github.com/n8n-io/n8n/releases/tag/n8n%402.49.7) — published 2026-11-26 07:23:34 UTC.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.27. KEV lists CVEs, and this advisory has none.

[ghsa]: https://github.com/n8n-io/n8n/security/advisories/GHSA-w6f8-8qh4-h3j4
[post]: https://community.n8n.io/t/security-update-26-november-2026/331111
