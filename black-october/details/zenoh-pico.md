# Eclipse Zenoh: a timestamp corrupts memory

**Last updated:** 2026-11-18 (America/New_York)

[Main Zenoh summary](../black-october-2026.md#eclipse-zenoh-a-timestamp-corrupts-memory) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-130603](https://www.cve.org/CVERecord?id=CVE-2026-130603) is a missing length check in Eclipse Zenoh's **zenoh-pico** implementation. The Eclipse Foundation is the CNA and rates it **CVSS 4.0 9.3 Critical**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. Versions **0.7.2-rc before 1.10.2** do not check the Zenoh identifier length while reading a timestamp. A length greater than 16 writes past a 16-byte buffer, and the following zero-fill is handed a negative length that becomes a large unsigned size. A truncated timestamp can read past the buffer or trip an assertion. Eclipse says a remote sender who can deliver a crafted message on an accepted transport can corrupt memory and crash the process, and that code execution is possible in a build without the usual binary protections. The fix is **1.10.2**. The full Zenoh implementation, the `zenoh` crate and library, is not this flaw.

**CISA KEV:** Not listed (catalog 2026.11.17, checked 2026-11-18). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix committed | 2026-10-28; the release is the public date | Pull request 1345, "Check for ZID bounds when deserializing timestamps." [Release][rel] |
| zenoh-pico 1.10.2 | 2026-10-28 10:26:09 UTC | The release notes do not name the CVE. [Release][rel] |
| **Public announcement** | **2026-11-17; time unknown** | CVE record published. NVD published 2026-11-17 14:17:47 UTC. |
| **Last updated** | **2026-11-18 (America/New_York)** | New item. Upgrade zenoh-pico. |

## Detection

Find the library, not the application version string. A firmware image can ship zenoh-pico without saying so.

```sh
# Cargo
cargo tree -p zenoh-pico 2>/dev/null || true
# A system or vendored copy
find . -name 'zenoh-pico*' -o -name 'libzenoh_pico*' 2>/dev/null | head
```

| Package | Affected | Fixed |
|---|---|---|
| zenoh-pico | 0.7.2-rc before 1.10.2 | 1.10.2 |

A process that links a zenoh-pico older than 1.10.2 and accepts Zenoh messages from a network is inside the record. One that only uses the full Zenoh implementation is outside it. A build you cannot identify is unknown, not safe.

## Remediation

1. Upgrade zenoh-pico to **1.10.2 or later**.
2. Rebuild every firmware image and application that vendors the library, and restart the process that loaded it. Installing the package on a build machine does not update a device that already has the old library.
3. Eclipse publishes no workaround.

## Verification

- `cargo tree -p zenoh-pico` shows 1.10.2 or later, or the vendored copy matches that tag.
- Restart the service and confirm it comes back. Do not send a crafted timestamp.

## Compromise response

Eclipse publishes no indicator and does not report exploitation. A crash in a process that speaks Zenoh, with no other explanation, is a lead. It is not proof the message was this flaw. The upgrade does not show whether a message already corrupted memory.

## Sources

- [CVE-2026-130603](https://www.cve.org/CVERecord?id=CVE-2026-130603) — CNA Eclipse Foundation. Published 2026-11-17. CVSS 4.0 9.3. Affected from 0.7.2-rc before 1.10.2. Fixed in 1.10.2.
- [zenoh-pico 1.10.2][rel] — published 2026-10-28 10:26:09 UTC. Includes "Check for ZID bounds when deserializing timestamps" and does not name the CVE.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.17, read 2026-11-18. CVE-2026-130603 is not in it.

[rel]: https://github.com/eclipse-zenoh/zenoh-pico/releases/tag/1.10.2
