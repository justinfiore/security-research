# Presenton: desktop app leaves the local API unauthenticated

**Last updated:** 2026-11-01 (America/New_York)

[Main Presenton summary](../black-october-2026.md#presenton-desktop-app-leaves-the-local-api-unauthenticated) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-120191](https://www.cve.org/CVERecord?id=CVE-2026-120191) — VulDB (CNA) CVSS 3.1 7.3 High (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:L`); the same record's CVSS 4.0 base score is 6.9 Medium.** Presenton does not publish its own score. The desktop build through 0.9.11-beta starts with authentication off, so any local caller can reach the app's API, settings, and private files. Docker and other self-hosted deployments keep authentication on unless an operator sets `DISABLE_AUTH`.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-02). VulDB calls the public write-up a proof of concept and does not report attacks. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | The reviewed sources do not establish a private-report date before the public GitHub issue. |
| Public report | 2026-10-05; time/TZ unknown | GitHub issue 972 describes the desktop default. The reporter calls it Critical. Presenton does not. [Issue 972][issue] |
| Fix merged | 2026-10-12 12:00 UTC | Pull request 980 requires a per-launch desktop credential before the account-authentication bypass. [Commit][commit] |
| Fixed release | 2026-10-26 14:56 UTC | v0.9.12-beta includes that pull request. The release notes do not name the CVE. [Release][release] |
| CVE published | 2026-11-01 01:00 UTC | VulDB CNA. The record names 0.9.11-beta as affected and 0.9.12-beta as unaffected. [CVE record][cve] |

## Detection

1. Inventory Presenton desktop installs (Windows, macOS, and Linux) and their exact version from the installer, package, or the app's own about information. Do not launch an untrusted copy merely to read its version.
2. Treat desktop builds through **0.9.11-beta** as affected. The official desktop app left `DISABLE_AUTH` unset, and the Electron process then treated that as authentication off. A self-hosted Docker or browser deployment is not this default: its middleware authenticates API and private-file routes unless an operator set `DISABLE_AUTH`.
3. The listeners bind to `127.0.0.1`, usually starting at port 40000. A page in the same user session can still send requests there. VulDB's "network" score does not mean the service is on the internet.
4. Presenton did not publish compromise indicators. A running old desktop app is exposure, not proof that settings or keys were read.

## Remediation

1. Upgrade the desktop app to **0.9.12-beta or later** from [presenton.ai/download](https://presenton.ai/download) or the project's GitHub release, then quit and relaunch so the old process is gone.
2. Until that build is running, quit the desktop app before opening untrusted pages in the same user session. Setting `DISABLE_AUTH` is not a workaround: the flaw is that the desktop app forces authentication off.
3. Do not set `DISABLE_AUTH` on a Docker or self-hosted deployment. Those installs authenticate by default and are outside the affected range in the CVE record.
4. Do not test a live install by calling its local API from a browser. Confirm the version instead.

## Verification

- Confirm the running desktop app is 0.9.12-beta or later, not only that the installer was downloaded.
- After the upgrade, open a presentation and confirm ordinary generation still works. The fix keeps desktop use without an account login; Electron supplies a credential that outside callers do not have.
- On a self-hosted deployment, confirm `DISABLE_AUTH` is unset or not a true value. That check is separate from this CVE.

## Compromise response

If an affected desktop app was running while the user browsed untrusted pages, treat API keys and provider settings stored in that profile as exposed. Revoke those keys at the issuer (OpenAI, Gemini, Anthropic, and any other configured provider), replace them in the app, and review presentation files and export output for changes you did not make. Upgrading stops new local callers. It does not undo a read or a settings change that already happened.

## Sources

- [CVE-2026-120191][cve] — VulDB CNA scores, affected and unaffected versions, and the patch commit.
- [VulDB VDB-429530][vuldb] — same CNA entry; proof-of-concept status; upgrade recommendation.
- [Presenton issue 972][issue] — reporter's description of the desktop default. The Critical label there is the reporter's, not Presenton's.
- [Pull request 980][pr] — project description of the desktop credential check.
- [Commit 44c8a611][commit] — fix merged 2026-10-12 12:00 UTC.
- [v0.9.12-beta][release] — fixed release, 2026-10-26 14:56 UTC.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30 status.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-120191
[vuldb]: https://vuldb.com/vuln/429530
[issue]: https://github.com/presenton/presenton/issues/972
[pr]: https://github.com/presenton/presenton/pull/980
[commit]: https://github.com/presenton/presenton/commit/44c8a61122b21f17642d717b0c4d6f2c54c0f180
[release]: https://github.com/presenton/presenton/releases/tag/v0.9.12-beta
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
