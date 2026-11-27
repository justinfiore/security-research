# LIVE555: a crafted description reads past a buffer

**Last updated:** 2026-11-27 (America/New_York)

[Main guide](../black-october-2026.md#live555-a-crafted-description-reads-past-a-buffer)

**VulnCheck rates [CVE-2026-137587](https://www.cve.org/CVERecord?id=CVE-2026-137587) CVSS 4.0 7.1 High and CVSS 3.1 7.1 High.** The vectors are `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:P/VC:L/VI:N/VA:H/SC:N/SI:N/SA:N` and `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:L/I:N/A:H`. The weakness is CWE-125. `parseVorbisOrTheoraConfigStr()` trusts a 16-bit length from the description. A malicious RTSP server, or a crafted Vorbis or Theora configuration in a proxied SDP description, can crash the client or leak heap memory. The record says LIVE555 Streaming Media **before 2026.08.25**. Live Networks' own changelog for 2026.08.25 says the fix is a bug in `VorbisAudioRTPSource` that could let a malicious SDP description crash an RTP client, reported by Tristan. The record does not report exploitation.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-27). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix released | 2026-08-25; time/TZ unknown | Changelog: a malicious SDP description could crash an RTP client. [Changelog][log] |
| **Public announcement** | **2026-11-26; time/TZ unknown** | VulnCheck published CVE-2026-137587. CVSS 4.0 7.1 and CVSS 3.1 7.1. [CVE][cve] |
| **Last updated** | **2026-11-27 (America/New_York)** | New item. The fix is 2026.08.25. |

## Detection

Read the LIVE555 version the application was built against. The record says **before 2026.08.25**. A player or proxy that never opens an RTSP stream from a server you do not trust, and never proxies an SDP description from one, is outside the path the record names. Reading the version changes no state. A build that does not report its version is unknown, not safe.

## Remediation

1. Rebuild against LIVE555 **2026.08.25 or later** and restart the player or proxy. The changelog entry for that date is the fix Live Networks published.
2. Until then, do not open an RTSP stream from a server you do not trust, and do not proxy an SDP description from one.
3. The record does not name a distribution package. A packaged build that still says a version before 2026.08.25 is inside the range.

## Verification

- The running binary was built from LIVE555 2026.08.25 or later.
- Do not point a client at a crafted description to test it.

## Compromise response

The record describes a crash or a heap leak in the client, not a write. A player that crashed while opening an untrusted stream should be restarted from the fixed build. The record publishes no indicator.

## Sources

- [CVE-2026-137587][cve] — VulnCheck, published 2026-11-26. CVSS 4.0 7.1 and CVSS 3.1 7.1. Affected before 2026.08.25.
- [LIVE555 changelog][log] — 2026.08.25: a bug in `VorbisAudioRTPSource` could let a malicious SDP description crash an RTP client.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-27. CVE-2026-137587 is not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-137587
[log]: https://download.live555.com/changelog.txt
