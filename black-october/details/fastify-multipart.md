# Fastify: an upload writes a file, and the parser hangs

**Last updated:** 2026-11-16 (America/New_York)

[Main Fastify summary](../black-october-2026.md#fastify-an-upload-writes-a-file-and-the-parser-hangs) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

OpenJS Foundation published four High flaws in the Fastify upload stack on November 16. OpenJS is the CNA for all four, and each is **CVSS 3.1 7.5 High**.

[CVE-2026-124289](https://www.cve.org/CVERecord?id=CVE-2026-124289) is the one that writes a file. In `@fastify/multipart` **7.4.0 through 10.1.8**, with `attachFieldsToBody` on, `saveRequestFiles()` treats any object that has a `file` and a `buffer` as an upload. A request with no login can send that object as JSON. The bytes land in the temporary directory, the upload limits are skipped, and the filename is kept as the client sent it, including `../`. An application that uses that filename as the destination, which the project's own README example does, writes outside the directory. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:N`. **10.1.9** is the fix.

[CVE-2026-110710](https://www.cve.org/CVERecord?id=CVE-2026-110710) fills the disk. The cleanup of files saved by `saveRequestFiles()` runs from a response hook that listens for `finish` and `error`. A client that finishes the upload and then disconnects, before the handler writes the reply, makes the response emit `close` instead. The hook never runs, and the files stay. Versions **3.0.0 through 10.1.3** are affected, and **10.1.4** is the first release that fixes this one. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H`. 10.1.9 includes it.

The other two are in `@fastify/busboy`, the parser `@fastify/multipart` uses. [CVE-2026-128835](https://www.cve.org/CVERecord?id=CVE-2026-128835): a part whose headers never end is counted as open forever, so one request of about a hundred bytes hangs the handler, and the hang survives the client disconnecting. [CVE-2026-124724](https://www.cve.org/CVERecord?id=CVE-2026-124724): once the part limit is reached, a truncated extra part raises an error nobody listens for, and the process exits. Both affect busboy **before 3.2.6**. The current release is **3.2.6**, published 2026-11-16. The second one was shown through `@fastify/multipart` 10.1.2 through 10.1.4, and the record says it reaches any consumer that sets a finite part limit.

An application that never calls `saveRequestFiles()` does not hit the first two. It still uses the parser, so the busboy pair applies. This is not the [http-proxy path rewrite](fastify-http-proxy.md).

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
| `@fastify/multipart` 10.1.4 | 2026-10-15 10:40:04 UTC | Fixes the leftover files. Still inside the file-write range. [npm][npm] |
| `@fastify/busboy` 3.2.6 | 2026-11-16 09:37:49 UTC | Fixes both parser flaws. [npm][busboy] |
| `@fastify/multipart` 10.1.9 | 2026-11-16 11:11:17 UTC | Current release. First release that fixes the file write. [GitHub release][rel] |
| **Public announcement** | **2026-11-16; NVD published 13:17 and 14:17 UTC** | Four advisories the same day. [GHSA-gmhr-r4mc-w935][write] |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. Update `@fastify/multipart` and `@fastify/busboy`. |

## Detection

```sh
npm ls @fastify/multipart --all
```

| Package | Affected | Fixed |
|---|---|---|
| `@fastify/multipart` file write, CVE-2026-124289 | 7.4.0 through 10.1.8, with `attachFieldsToBody` | 10.1.9 |
| `@fastify/multipart` leftover files, CVE-2026-110710 | 3.0.0 through 10.1.3, when it calls `saveRequestFiles()` | 10.1.4; current 10.1.9 |
| `@fastify/busboy` hang and crash, CVE-2026-128835 and CVE-2026-124724 | before 3.2.6 | 3.2.6 |

A tree below 10.1.9 that calls `saveRequestFiles()` with `attachFieldsToBody` is inside the file write. A tree that never saves uploads still needs busboy 3.2.6.

## Remediation

1. Upgrade `@fastify/multipart` to **10.1.9 or later** and `@fastify/busboy` to **3.2.6 or later**, then restart the process. 10.1.4 fixes only the leftover files.
2. Until then: call `saveRequestFiles()` only after confirming the request is multipart, and reduce each filename to its basename. For the leftover files, call `cleanRequestFiles()` from a `close` handler on the raw response. For the hang, set Fastify's handler timeout. The crash has no complete workaround, because it happens inside the parser.
3. The upgrade does not delete files a disconnected client already left, and it does not restore a file the file-write flaw already replaced. Clear the upload temporary directory and review files written on November 16.

## Verification

`npm ls @fastify/multipart @fastify/busboy` reports 10.1.9 or later and 3.2.6 or later in the tree you deploy. Do not send a JSON body or a truncated part to test it.

## Compromise response

The file write can replace a file whose path the application builds from the upload name. The other three fill the disk, hang handlers, or crash the process. No source reports exploitation. After upgrading, remove stranded temporary files and check for files written outside the upload directory on November 16. A file there is a lead, not proof.

## Sources

- [GHSA-gmhr-r4mc-w935][write] — OpenJS, published 2026-11-16. CVE-2026-124289, CVSS 3.1 7.5. `@fastify/multipart` 7.4.0 before 10.1.9.
- [CVE-2026-124289](https://www.cve.org/CVERecord?id=CVE-2026-124289) — OpenJS Foundation, published 2026-11-16. Same score and range.
- [GHSA-r9rg-mfh6-f225](https://github.com/fastify/fastify-multipart/security/advisories/GHSA-r9rg-mfh6-f225) — OpenJS, published 2026-11-16. CVE-2026-110710, CVSS 3.1 7.5. 3.0.0 before 10.1.4.
- [GHSA-pvmq-3jr9-v5qh](https://github.com/fastify/busboy/security/advisories/GHSA-pvmq-3jr9-v5qh) — OpenJS, published 2026-11-16. CVE-2026-128835, CVSS 3.1 7.5. `@fastify/busboy` before 3.2.6.
- [GHSA-wh8h-qr34-3rj3](https://github.com/fastify/busboy/security/advisories/GHSA-wh8h-qr34-3rj3) — OpenJS, published 2026-11-16. CVE-2026-124724, CVSS 3.1 7.5. `@fastify/busboy` 1.0.0 before 3.2.6.
- [npm, `@fastify/multipart`][npm] — 10.1.4 published 2026-10-15 10:40:04 UTC. Latest 10.1.9, published 2026-11-16 11:11:17 UTC.
- [npm, `@fastify/busboy`][busboy] — 3.2.6 published 2026-11-16 09:37:49 UTC.
- [GitHub release v10.1.9][rel] — published 2026-11-16 11:09:48 UTC.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. None of the four CVEs is in it.

[write]: https://github.com/fastify/fastify-multipart/security/advisories/GHSA-gmhr-r4mc-w935
[npm]: https://www.npmjs.com/package/@fastify/multipart
[busboy]: https://www.npmjs.com/package/@fastify/busboy
[rel]: https://github.com/fastify/fastify-multipart/releases/tag/v10.1.9
