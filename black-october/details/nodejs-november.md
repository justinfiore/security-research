# Node.js: an HTTPS request can read another connection's memory

**Last updated:** 2026-11-11 (America/New_York)

[Main Node.js summary](../black-october-2026.md#nodejs-an-https-request-can-read-another-connections-memory) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**OpenJS rates [CVE-2026-123864](https://www.cve.org/CVERecord?id=CVE-2026-123864) CVSS 3.0 8.1 High** (`CVSS:3.0/AV:N/AC:H/PR:N/UI:N/S:C/C:L/I:L/A:H`). A re-entrancy flaw in the HTTPS parser lets a client who is not logged in read memory that belongs to other connections, including TLS private keys and other users' requests. The Node.js project rates the same flaw High and does not publish a numeric score. NVD had not scored it on November 11.

The same release fixes six more flaws the project rates High and does not score. [CVE-2026-123863](https://www.cve.org/CVERecord?id=CVE-2026-123863) is a reachable assertion that aborts an HTTP/2 server, on 24.x and 26.x. [CVE-2026-123865](https://www.cve.org/CVERecord?id=CVE-2026-123865) leaks memory and file descriptors when a protocol error arrives during shutdown. [CVE-2026-123866](https://www.cve.org/CVERecord?id=CVE-2026-123866) can send freed response memory to a peer. [CVE-2026-126051](https://www.cve.org/CVERecord?id=CVE-2026-126051) terminates a TLS server that uses a deferred handshake hook, on 24.x and 26.x. [CVE-2026-123872](https://www.cve.org/CVERecord?id=CVE-2026-123872) lets a TLS 1.2 client change the server name during renegotiation and carry an existing client certificate to a host it was not authorized for. [CVE-2026-123874](https://www.cve.org/CVERecord?id=CVE-2026-123874) is a use after free when a client resets a file download served with `respondWithFile()` or `respondWithFD()`, on 24.x and 26.x.

The release also fixes six Medium and three Low flaws. One Medium, [CVE-2026-123828](https://www.cve.org/CVERecord?id=CVE-2026-123828), writes one byte past a heap buffer when an application passes an attacker-controlled origin to `session.altsvc()`. The project says the highest severity in the release is High. It does not report exploitation of any of the sixteen.

The CVE record for CVE-2026-123864 says every release before **22.23.5**, from **23.0.0** before **24.22.3**, and from **25.0.0** before **26.13.1** is affected. The advisory names the active lines: 22.x, 24.x, and 26.x. It also says an end-of-life line is affected and gets no fix. Cleartext `node:http` is not affected by the memory disclosure. The trigger needs a handler that calls `res.flushHeaders()` before the request body ends and later calls `res.end()` with a non-empty chunk. Reading the leaked memory needs a route that echoes or stores a request body.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-11) for any of the sixteen. The advisory does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-11-11 18:17:56 UTC** | CVE-2026-123864 published. The advisory and the three release posts are the same day. [Advisory][adv] |
| CVE records | 2026-11-11; time unknown | OpenJS lists all sixteen. [CNA][cna] |
| CISA KEV | Not listed (catalog 2026.11.10, checked 2026-11-11) | [KEV][kev] |
| **Last updated** | **2026-11-11 (America/New_York)** | New item. |

## Detection

This only reads the version string. It does not send a request.

```sh
node --version
```

A 22.x build below **v22.23.5**, a 24.x build below **v24.22.3**, or a 26.x build below **v26.13.1** is inside the release. A build at one of those three versions or later on the same line is outside it. A 20.x, 18.x, or other end-of-life line has no fix in this release.

`node --version` answers the process you just ran. A service can run a different binary, a container image, or a version bundled inside another product. Check the binary that process actually executes, not only the one on `PATH`.

Several of the HTTP/2 flaws need an HTTP/2 server, and CVE-2026-123864 needs HTTPS plus a handler that flushes headers before the body ends. A version inside the range is the fact this check can establish. Whether that process serves HTTP/2 or has such a handler is a separate question, and a version check does not answer it.

## Remediation

1. Upgrade each active line and restart every process that loaded the old binary. **22.x goes to 22.23.5 or later, 24.x to 24.22.3 or later, and 26.x to 26.13.1 or later.**
2. The advisory names no workaround. Restarting is part of the fix: a process keeps running the binary it loaded.
3. An end-of-life line, including 20.x and 18.x, gets no build in this release. Move it to an active line.
4. A container image, a bundled runtime, and a version installed by a hosting panel do not move because the system `node` did. Rebuild or upgrade each of those on its own.
5. The upgrade does not show whether a request already read memory from another connection.

## Verification

- `node --version` on the binary the service runs reports **v22.23.5**, **v24.22.3**, or **v26.13.1** or later on that line, and the process was started after the upgrade.
- A route the service already serves still answers. Do not send a request built to trigger the parser.

## Compromise response

The advisory publishes no indicator. If a Node.js HTTPS server inside the affected range was reachable while it flushed headers before the request body ended, treat TLS private keys and request bodies as exposed.

- Replace the TLS private keys that server used, and issue new certificates.
- Rotate credentials and session secrets that passed through request bodies on that server.
- Preserve access logs from before the upgrade. The advisory does not say the leak leaves a log line.

## Sources

- [November 11, 2026 security releases][adv] — Node.js project. Sixteen flaws: seven High, six Medium, three Low. Fixed in 22.23.5, 24.22.3, and 26.13.1. The project publishes no numeric score and reports no exploitation.
- [CVE-2026-123864][cve864] — OpenJS CNA, published 2026-11-11 18:17:56 UTC. CVSS 3.0 8.1 High. Affected before 22.23.5, from 23.0.0 before 24.22.3, and from 25.0.0 before 26.13.1.
- [OpenJS CNA advisories][cna] — lists the sixteen November 11 records.
- [v22.23.5](https://nodejs.org/en/blog/release/v22.23.5/), [v24.22.3](https://nodejs.org/en/blog/release/v24.22.3/), [v26.13.1](https://nodejs.org/en/blog/release/v26.13.1/) — release posts.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-11. None of the sixteen is listed.

[adv]: https://nodejs.org/en/blog/vulnerability/november-2026-security-releases
[cve864]: https://www.cve.org/CVERecord?id=CVE-2026-123864
[cna]: https://cna.openjsf.org/security-advisories.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
