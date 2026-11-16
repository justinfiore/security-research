# Ruby httpx: a JSON response builds an object

**Last updated:** 2026-11-16 (America/New_York)

[Main httpx summary](../black-october-2026.md#ruby-httpx-a-json-response-builds-an-object) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

The Ruby `httpx` gem decodes a JSON response body. [CVE-2026-129784](https://www.cve.org/CVERecord?id=CVE-2026-129784): when the `oj` gem is loaded and `multi_json` is not, `HTTPX::Response#json` calls `Oj.load` with no mode. Oj's default mode is `:object`, and a response can name a Ruby class and set its instance variables. Whoever controls the URL passed to `HTTPX.get(url).json` controls that object. JFrog, the CNA, says a matching gadget chain can run code. JFrog rates it **CVSS 3.1 8.5 High**. The vector is `CVSS:3.1/AV:N/AC:H/PR:L/UI:N/S:C/C:H/I:H/A:H`.

Only **1.9.0** is affected. **1.9.1**, released 2026-11-13, is the fix. An application that does not have `oj` loaded, or that has `multi_json` loaded, does not take this branch.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-16). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| httpx 1.9.0 | 2026-10-14 10:15:49 UTC | The affected release. [RubyGems][gem] |
| httpx 1.9.1 | 2026-11-13 16:39:28 UTC | The fix. Commit `eeb785d3250e`. [RubyGems][gem] |
| **Public announcement** | **2026-11-16; NVD published 11:16 UTC** | JFrog published the CVE record. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. Update httpx. |

## Detection

```sh
bundle show httpx
gem list httpx oj multi_json
```

httpx 1.9.0 together with `oj` and without `multi_json` is the affected combination. 1.9.0 without `oj` does not take the branch. Any other httpx version is outside the record.

## Remediation

1. Upgrade `httpx` to **1.9.1 or later** and redeploy.
2. The record names no workaround. Removing `oj`, or loading `multi_json`, avoids the branch, and that is an inference from the description rather than a vendor workaround.
3. The upgrade does not show whether a response already built an object.

## Verification

`bundle show httpx` reports 1.9.1 or later. Do not point the client at a server to test it.

## Compromise response

No source reports exploitation. The condition is a server the application already fetches. If that server is not yours and the application was on 1.9.0 with `oj`, review what the process could have run and rotate credentials it could read. The upgrade does not undo that.

## Sources

- [CVE-2026-129784](https://www.cve.org/CVERecord?id=CVE-2026-129784) — JFrog, published 2026-11-16. CVSS 3.1 8.5. httpx 1.9.0 before 1.9.1. Credit Natan Nehorai, JFrog Vulnerability Research.
- [httpx 1.9.1](https://github.com/HoneyryderChuck/httpx/releases/tag/v1.9.1) — published 2026-11-13 16:38:57 UTC.
- [Fix commit eeb785d3250e](https://github.com/HoneyryderChuck/httpx/commit/eeb785d3250eee9379494fb62c37c315a31e327c) — "json: fix oj integration to avoid RCE mode."
- [RubyGems, httpx][gem] — 1.9.0 created 2026-10-14, 1.9.1 created 2026-11-13.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. CVE-2026-129784 is not in it.

[gem]: https://rubygems.org/gems/httpx
