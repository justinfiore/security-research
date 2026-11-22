# ASP.NET: Idunno.AntiCsrf runs code from a form field

**Last updated:** 2026-11-22 (America/New_York)

[Main plugin summary](../black-october-2026.md#aspnet-idunnoanticsrf-runs-code-from-a-form-field) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-19 Mandiant published [CVE-2026-131914](https://www.cve.org/CVERecord?id=CVE-2026-131914) for the abandoned ASP.NET module `Idunno.AntiCsrf`. Mandiant is the CNA and rates it **CVSS 4.0 9.3 Critical**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N/E:A`. NVD has not scored it.

The module checks a double-submit cookie against a form field. On a `POST` it deserializes that form field with a .NET `ObjectStateFormatter` that has no cryptographic key, and it does this before it compares the result with the cookie. A request with no login, and with any non-empty value in the CSRF cookie, runs code as the IIS worker process (`w3wp.exe`). Mandiant's advisory [MNDT-2026-0048][mndt] says active exploitation in the wild has been observed, and names no actor, victim, date, or indicator.

Every version through **0.9.1 Beta** (file version `0.9.1.0`) is affected. That is the last release, dated December 2008, and the project has no maintainer. There is no patch.

This is not [.NET Framework](dotnet-framework.md).

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-22). Mandiant says exploitation has been observed, and that statement is separate from a KEV listing. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Last release | 2008-12; day unknown | `0.9.1 Beta`. CodePlex is retired. [MNDT-2026-0048][mndt] |
| Root-cause analysis | 2026-11-04; time/TZ unknown | FLARE, during incident response. [MNDT-2026-0048][mndt] |
| **Public announcement** | **2026-11-19 01:29:12 UTC** | Mandiant published the CVE record and the advisory. CVSS 4.0 9.3. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-131914) |

## Detection

Search `Web.config` for `Idunno.AntiCsrf.AntiCsrfModule` under `<httpModules>` and `<modules>`, and for a `<csrfSettings>` element. Search each application's `bin/` for `Idunno.AntiCsrf.dll`. A site that has neither is outside this entry. A rebuild of the source keeps the same sink and will not match the hashes below, so the name is the check.

Mandiant publishes three hashes for the known binaries. A match confirms the published build. A miss does not clear a renamed or rebuilt copy.

| Build | Size | SHA-256 |
|---|---|---|
| `0.9.1.0`, official 2008 release | 69,632 | `da1efcfed182597ee946a9ef2895dfdfeab2bdff16855aeef01656d8158ead06` |
| Rebuild of the `0.9.1 Beta` source, Release | 69,632 | `c5c994891783453ae85f3ef8efb48592b7c560aeb56f531ee9ea5736518246eb` |
| Rebuild of the `0.9.1 Beta` source, Debug | 70,144 | `aa7bbad4a7ebc38519955ac65517716569508ee4f61fc2f1276086940501e9bf` |

Reading the configuration and hashing the file change no state.

## Remediation

1. There is no patch. Remove the module: delete the `<add>` entries for `Idunno.AntiCsrf.AntiCsrfModule` from `<httpModules>` and `<modules>`, remove the `<csrfSettings>` section and element, remove code that references `ISuppressCsrfCheck` or `[SuppressCsrfCheck]`, and delete `Idunno.AntiCsrf.dll` from `bin/`.
2. Replace it with a supported anti-forgery mechanism. Mandiant names `System.Web.Helpers.AntiForgery`, WebForms `Page.ViewStateUserKey` with MAC-verified ViewState, or ASP.NET Core's `IAntiforgery`.
3. Removing the module does not undo a request that already ran code.

## Verification

- No `Web.config` still names `Idunno.AntiCsrf`, and no `bin/` still contains the DLL.
- The replacement anti-forgery check rejects a form post that arrives without its token. Do not send a crafted object to test the old module.

## Compromise response

Mandiant says exploitation has been observed and gives no indicator. Where the module was present, rotate secrets in `Web.config` and `applicationHost.config`, including `<machineKey>` keys and database credentials, and look for files you did not put in the web root. Removing the DLL does not end a process that already started.

## Sources

- [MNDT-2026-0048][mndt] — Mandiant, published 2026-11-18 per its timeline. CVSS 4.0 9.3 Critical. Affected through 0.9.1 Beta. No patch. Says active exploitation has been observed, with no actor or indicator. Hashes for three builds.
- [CVE-2026-131914](https://www.cve.org/CVERecord?id=CVE-2026-131914) — Mandiant, published 2026-11-19T01:29:12.970Z. The record repeats the score and the affected range.
- [CodePlex archive](https://codeplexarchive.org/project/AntiCSRF) — the retired project page.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-22. Not listed.

[mndt]: https://github.com/mandiant/Vulnerability-Disclosures/blob/master/2026/MNDT-2026-0048.md
