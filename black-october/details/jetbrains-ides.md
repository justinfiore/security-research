# JetBrains IDEs: a project file runs code in Safe Mode

**Last updated:** 2026-11-07 (America/New_York)

[Main IDE summary](../black-october-2026.md#jetbrains-ides-a-project-file-runs-code-in-safe-mode) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

JetBrains published a large set of IDE flaws on 2026-11-06. Two are Critical, and several more are High. Each one is a project the IDE opens, not a service you expose. This is not [Hub](jetbrains-hub.md) and not [Datalore](datalore.md).

**[CVE-2026-123831](https://www.cve.org/CVERecord?id=CVE-2026-123831): JetBrains (CNA) rates CLion CVSS 3.1 9.6 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:H`. Before CLion **2026.2** and **2026.1.4**, code execution was possible in Safe Mode through Meson project settings. [CVE-2026-123832](https://www.cve.org/CVERecord?id=CVE-2026-123832) is the same 9.6 score, fixed before **2026.2**: code execution in Safe Mode through a JSON compilation database. Safe Mode is the mode IntelliJ-platform IDEs use for a project you have not trusted. The record says the attack needs no privileges and that a user has to interact. The version field on both records contains a line break (`2026.2, \n2026.1.4` on the first). Read it as two fixed builds, which is how JetBrains writes a fix on two release lines. NVD has not scored them.

Five IntelliJ IDEA flaws are High and local. The vector on these is `CVSS:3.1/AV:L/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`, score **7.8**, unless noted:

- [CVE-2026-123838](https://www.cve.org/CVERecord?id=CVE-2026-123838), fixed before **2026.3**: code execution in Safe Mode through a UI Designer form file.
- [CVE-2026-123293](https://www.cve.org/CVERecord?id=CVE-2026-123293), fixed before **2026.3** and **2026.2.4**: code execution in an untrusted project through the Terraform tool path.
- [CVE-2026-123837](https://www.cve.org/CVERecord?id=CVE-2026-123837), fixed before **2026.3** and **2026.2.1**: command injection in an untrusted project through a Tomcat run configuration on WSL.
- [CVE-2026-123304](https://www.cve.org/CVERecord?id=CVE-2026-123304), fixed before **2026.3**: code execution in an untrusted project through a configured ShellCheck path.
- [CVE-2026-123853](https://www.cve.org/CVERecord?id=CVE-2026-123853), fixed before **2026.3** and **2026.2.2**: code execution in Safe Mode through a project-controlled JVM.

The same publication includes more IDE flaws below 7.0, and High flaws in other products, including WebStorm and PyCharm. This entry tracks the Critical CLion pair and the 7.8 IntelliJ flaws above. A project you already trust is outside the condition the records describe. Opening it is the user interaction.

**Fixed builds differ by product and by line.** JetBrains' issues-fixed page, read 2026-11-07, does not list these CVEs. The CVE records are the source for the scores and the versions. There is no single build that covers every IDE.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-07) for any of these CVEs. JetBrains does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | The CVE records name no finder and no report date. |
| **Public announcement** | **2026-11-06** | CLion records at 16:09:58 and 16:09:59 UTC. The IntelliJ records are the same day, from 10:27 UTC through 16:10 UTC. [CVE-2026-123831][cve] |
| Patch | The fixed builds above; release timestamps not on the records | The issues-fixed page does not list them. |

## Detection

In the IDE, open About and read the build line. Compare the product and the release line, not a single number.

| IDE | Inside the flaw | Fixed |
|---|---|---|
| CLion, 2026.1 line | before 2026.1.4, for the Meson flaw | 2026.1.4 or later on that line |
| CLion, 2026.2 line | before 2026.2, for both Critical flaws | 2026.2 or later |
| IntelliJ IDEA | before 2026.3, and before the line-specific build named on each record | 2026.3 or later covers all five 7.8 flaws |

A build on 2026.2.4 is outside the Terraform flaw and still inside the flaws fixed only in 2026.3. Safe Mode does not put CLion outside CVE-2026-123831 or CVE-2026-123832. The records say the code runs in Safe Mode.

## Remediation

1. Update CLion to **2026.2 or later**, or to **2026.1.4 or later** if you stay on the 2026.1 line. 2026.1.4 is the floor the Meson record names. The JSON compilation database flaw names only 2026.2.
2. Update IntelliJ IDEA to **2026.3 or later**. That one build is the floor for all five 7.8 flaws. A 2026.2 build fixes only the flaws whose record names that line.
3. JetBrains publishes no workaround on the records. Refusing to open a project you do not trust avoids the condition. It is not a fix for a project you already open, and Safe Mode is not a workaround for the two CLion flaws.
4. The update does not undo a command a project file already ran.

## Verification

- About shows CLion **2026.2 or later**, or **2026.1.4 or later** on the 2026.1 line, and IntelliJ IDEA **2026.3 or later**.
- Open one project you already trust. Do not open a project sent to you in order to test these records.

## Compromise response

JetBrains does not publish an indicator. If a developer opened an untrusted project in an affected build:

- Ask which project, and whether the IDE was in Safe Mode. For the two CLion flaws, Safe Mode is not protection.
- Look for a process the IDE started that is not the build the developer ran.
- If that project could name a program path, treat the developer account as exposed to whatever that program was. The records do not name a file to search for.

## Sources

- [CVE-2026-123831][cve] — JetBrains CNA. Published 2026-11-06 16:09:58 UTC. CVSS 3.1 9.6. CLion before 2026.2 and 2026.1.4. CWE-829.
- [CVE-2026-123832](https://www.cve.org/CVERecord?id=CVE-2026-123832) — 9.6 Critical. CLion before 2026.2. JSON compilation database. Published 2026-11-06 16:09:59 UTC.
- [CVE-2026-123838](https://www.cve.org/CVERecord?id=CVE-2026-123838), [CVE-2026-123293](https://www.cve.org/CVERecord?id=CVE-2026-123293), [CVE-2026-123837](https://www.cve.org/CVERecord?id=CVE-2026-123837) — IntelliJ IDEA, 7.8 High. Published 2026-11-06.
- [JetBrains issues fixed](https://www.jetbrains.com/privacy-security/issues-fixed/) — read 2026-11-07. It does not list these CVEs.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-123831
