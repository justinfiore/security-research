# Penpot: a logged-in user takes over any file, and an SVG export runs a command

**Last updated:** 2026-11-08 (America/New_York)

[Main Penpot summary](../black-october-2026.md#penpot-a-logged-in-user-takes-over-any-file-and-an-svg-export-runs-a-command) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Penpot is an open-source design tool. Self-hosted installs and Penpot Cloud both run it. The project published a batch of advisories on November 5. One is Critical. The current release, 2.18.6, is the floor that covers the November set. An older Critical flaw, command execution through an SVG export, is fixed in 2.17.2.

**GitHub rates [GHSA-8qqw-wm58-45v7](https://github.com/penpot/penpot/security/advisories/GHSA-8qqw-wm58-45v7) Critical, 9.9.** The header score is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`. The body says the same vector is 9.6, and 10.0 when self-registration is on, which the project says is the default. The GitHub page says no CVE is known. Voke Cyber's earlier page assigned [CVE-2026-17613](https://www.cve.org/CVERecord?id=CVE-2026-17613) and, at the time it wrote, said there was no fix. From v1.20 through the develop commit the advisory names, a logged-in user calls `import-binfile` with another file's id. The check is on the caller's own project. The call overwrites that file and moves it into the caller's project. The advisory says the same pattern lets the caller subscribe to another file's live changes, and it rates that part about 7.7. The header says the patch is 2.18.0. The body says the fix pull request merged on August 5 and does not name the release that first shipped it.

Four more advisories in the same November 5 batch are High, and the GitHub pages say no CVE is known:

- [GHSA-pf4p-35w6-gcqc](https://github.com/penpot/penpot/security/advisories/GHSA-pf4p-35w6-gcqc) is CVSS 3.1 7.7. Before 2.18.6, a logged-in user passes a file path as a Transit value to the thumbnail endpoint and reads that file back as a media asset. The advisory says the files include `PENPOT_SECRET_KEY`, which signs sessions. The fix is 2.18.6.
- [GHSA-v9r9-h77c-55m2](https://github.com/penpot/penpot/security/advisories/GHSA-v9r9-h77c-55m2) is CVSS 3.1 7.1. Through 2.18.2, a member who leaves a team keeps the file role and can still rename the file and read its summary. The fix is 2.18.3.
- [GHSA-ffhp-m958-qxvr](https://github.com/penpot/penpot/security/advisories/GHSA-ffhp-m958-qxvr) is CVSS 3.1 7.6. Through 2.18.2, a `.penpot` import stores an SVG without the sanitizer, and the sanitizer misses an `x:href` alias. A viewer who opens the asset runs script in the Penpot origin. The fix is 2.18.3. The body of that advisory was written when no fixed release existed. The header now names 2.18.3.
- [GHSA-82p2-67qr-4rwf](https://github.com/penpot/penpot/security/advisories/GHSA-82p2-67qr-4rwf) is CVSS 3.1 7.6. On 2.18.0 and 2.18.1, a namespace-prefixed `script` element in an uploaded SVG survives the sanitizer. The fix is 2.18.2.

**GitHub rates [GHSA-4f36-m4hj-cv86](https://github.com/penpot/penpot/security/advisories/GHSA-4f36-m4hj-cv86) Critical, 9.9,** published September 25, and the page names [CVE-2026-105691](https://www.cve.org/CVERecord?id=CVE-2026-105691). A logged-in user sets a text fill color to a shell substitution. Exporting that file as SVG runs the command in the exporter. The body says a public share link makes the same export reachable without a login. The header says affected below 2.17.1 and patched in 1.17.2. The body says affected through 2.17.1 and fixed in 2.17.2. 2.17.2 is the version that exists. 1.17.2 is not a current Penpot release.

2.18.6 is the current release, tagged November 4, and it is the floor that covers the November advisories. 2.17.2 covers the exporter and not the November set.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08). The file-takeover page says no CVE is known, so it cannot be listed. The advisories do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| In-place import added | 2025-07-22; time/TZ unknown | The `file-id` parameter the takeover uses. [Takeover advisory][takeover] |
| Exporter advisory | 2026-09-25; time/TZ unknown | GitHub published the command-injection advisory and named CVE-2026-105691. [Exporter advisory][export] |
| Penpot 2.18.6 | 2026-11-04 17:11 UTC | Current release. The thumbnail advisory names this as the fix. [Releases][rel] |
| **Public announcement** | **2026-11-05; time/TZ unknown** | The project published the takeover advisory and the four High advisories. [Takeover advisory][takeover] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-08) | [KEV][kev] |

## Detection

This reads the version you are running. It does not call `import-binfile` or export an SVG.

The image tag is `penpotapp/frontend`, `penpotapp/backend`, and `penpotapp/exporter`. Penpot Cloud is the vendor's to patch. A self-hosted install prints its version on the login page and in the frontend image tag.

- **2.18.6 or later** is the floor the November advisories name.
- **2.18.3 through 2.18.5** still has the thumbnail file read.
- **2.18.0 and 2.18.1** still have the SVG sanitizer bypasses and the leftover team role.
- **2.17.2 through 2.17.x** has the exporter fix and not the November set.
- **Through 2.17.1** still has the exporter command injection, on the range the body names.

A single-user install is outside the cross-team takeover only while it stays single-user. The thumbnail read and the exporter do not need a second team.

## Remediation

1. Upgrade a self-hosted install to **2.18.6 or later**, frontend, backend, and exporter together, and recreate the containers. 2.18.3 fixes the SVG bypasses and the leftover role, and it does not fix the thumbnail read.
2. The advisories list no workaround. Turning off public registration does not close the flaws for users who already have accounts. The body of the exporter advisory says a public share link reaches the export without a login, so disabling share links is not a fix either.
3. The upgrade does not give a file back to the team it was taken from, and it does not show whether an export already ran a command. If the install was below 2.18.6 and any account could log in, rotate `PENPOT_SECRET_KEY` and end sessions. The thumbnail advisory says that key signs sessions.

## Verification

- The running frontend, backend, and exporter images are 2.18.6 or later, after the containers were recreated.
- A user can still open a file they own. Do not call `import-binfile` with another file's id, and do not export a file whose fill color contains shell syntax, to test the check.

## Compromise response

The advisories do not publish a log line. A file whose project changed without its owner moving it is the takeover indicator. An exporter process that ran a shell around an SVG export is the command indicator. Neither log is guaranteed to exist.

If any account could log in before 2.18.6:

- Move a file that left its team back, and treat its contents as attacker-controlled.
- Rotate `PENPOT_SECRET_KEY`, database credentials, and any key that was on the backend filesystem.
- End sessions. A session signed with the old key stays valid until you do.

## Sources

- [GHSA-8qqw-wm58-45v7][takeover] — the project, published 2026-11-05. Critical. The header score is CVSS 3.1 9.9. The body says 9.6, and 10.0 with open registration. Says no CVE is known. Header patched version is 2.18.0.
- [CVE-2026-17613][cve17613] — the identifier Voke Cyber assigned to the same takeover. Its page said there was no fix. The project has since published 2.18.0 as the patched version.
- [GHSA-pf4p-35w6-gcqc][thumb] — the project, published 2026-11-05. High, CVSS 3.1 7.7. Before 2.18.6. Thumbnail path read.
- [GHSA-v9r9-h77c-55m2][leave] — the project, published 2026-11-05. High, CVSS 3.1 7.1. Through 2.18.2, patched in 2.18.3.
- [GHSA-ffhp-m958-qxvr][svg] — the project, published 2026-11-05. High, CVSS 3.1 7.6. Through 2.18.2, patched in 2.18.3.
- [GHSA-82p2-67qr-4rwf][xss] — the project, published 2026-11-05. High, CVSS 3.1 7.6. 2.18.0 and 2.18.1, patched in 2.18.2.
- [GHSA-4f36-m4hj-cv86][export] — the project, published 2026-09-25. Critical, CVSS 3.1 9.9. Names CVE-2026-105691. Header and body disagree on the patched version; 2.17.2 is the release that exists.
- [Penpot releases][rel] — 2.18.6 tagged 2026-11-04 17:11 UTC. 2.17.2 is an earlier tag.
- [CISA KEV JSON][kev] — catalog 2026.11.06, checked 2026-11-08. CVE-2026-105691 is not listed.

[takeover]: https://github.com/penpot/penpot/security/advisories/GHSA-8qqw-wm58-45v7
[thumb]: https://github.com/penpot/penpot/security/advisories/GHSA-pf4p-35w6-gcqc
[leave]: https://github.com/penpot/penpot/security/advisories/GHSA-v9r9-h77c-55m2
[svg]: https://github.com/penpot/penpot/security/advisories/GHSA-ffhp-m958-qxvr
[xss]: https://github.com/penpot/penpot/security/advisories/GHSA-82p2-67qr-4rwf
[export]: https://github.com/penpot/penpot/security/advisories/GHSA-4f36-m4hj-cv86
[cve17613]: https://www.cve.org/CVERecord?id=CVE-2026-17613
[rel]: https://github.com/penpot/penpot/releases
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
