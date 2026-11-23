# Routinator: an rsync server can crash the validator

**Last updated:** 2026-11-23 (America/New_York)

[Main plugin summary](../black-october-2026.md#routinator-an-rsync-server-can-crash-the-validator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-23 NLnet Labs published two records for Routinator, the RPKI relying-party software. NLnet Labs is the CNA for both.

[CVE-2026-119068](https://www.cve.org/CVERecord?id=CVE-2026-119068) is **High, CVSS 3.1 7.5**. The vector is `CVSS:3.1/AV:N/AC:H/PR:L/UI:N/S:C/C:H/I:H/A:L`. An rsync server sends diagnostic data that Routinator collects line by line. If that data has no line break and keeps coming, Routinator runs out of memory and crashes. The title says the crash is the result. The score's confidentiality and integrity are both High, and the record does not say what is read or changed.

[CVE-2026-119069](https://www.cve.org/CVERecord?id=CVE-2026-119069) is **Medium, CVSS 3.1 5.3**. The vector is `CVSS:3.1/AV:N/AC:H/PR:L/UI:N/S:C/C:H/I:H/A:L`. When Routinator rejects a publication point partway through and falls back to the stored copy, it keeps the data it had already processed instead of dropping it. It is in this entry because the same release fixes it. It does not meet the High bar on its own.

The CVE records mark only **0.16.2** unaffected and do not name the first affected version. **0.16.2**, published 2026-11-23, is the fix for both. The vendor text files the records link, under `nlnetlabs.nl/downloads/krill/`, returned HTTP 404 when read on 2026-11-23. The release notes name both CVEs. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.23, checked 2026-11-23) for CVE-2026-119068 or CVE-2026-119069. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-23 12:43:45 UTC** | Routinator 0.16.2. Both records are the same day. [Release][rel] |

## Detection

Read the Routinator version from the binary or the package. **Anything before 0.16.2** is the range the release fixes. The CVE records name only 0.16.2 as unaffected, so they do not say an older line is outside it. Reading the version changes no state.

## Remediation

1. Upgrade Routinator to **0.16.2 or later** and restart it.
2. The upgrade does not show whether a publication point already left data behind, and it does not restore a validator that already crashed.

## Verification

- The running Routinator is **0.16.2 or later**.
- Do not point it at an rsync server you do not operate to test it.

## Compromise response

No source read for this entry reports an incident. If Routinator crashed before the upgrade while fetching from an rsync server you do not trust, restart it on 0.16.2 and refresh the local RPKI cache. The record does not name an indicator.

## Sources

- [Routinator 0.16.2][rel] — published 2026-11-23T12:43:45Z. Names CVE-2026-119068 (pull 1171) and CVE-2026-119069 (pull 1170).
- [CVE-2026-119068](https://www.cve.org/CVERecord?id=CVE-2026-119068) — NLnet Labs, published 2026-11-23. CVSS 3.1 7.5. Unaffected at 0.16.2. Credits Anthropic, Ada Logics, and Aymen Benlamari.
- [CVE-2026-119069](https://www.cve.org/CVERecord?id=CVE-2026-119069) — NLnet Labs, published 2026-11-23. CVSS 3.1 5.3. Unaffected at 0.16.2.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T12:54:37.9646Z, checked 2026-11-23. Neither is listed.

[rel]: https://github.com/NLnetLabs/routinator/releases/tag/v0.16.2
