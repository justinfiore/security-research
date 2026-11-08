# imgproxy: an ICO image can crash the worker or run code

**Last updated:** 2026-11-08 (America/New_York)

[Main imgproxy summary](../black-october-2026.md#imgproxy-an-ico-image-can-crash-the-worker-or-run-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

imgproxy decodes images that a caller sends it. Its ICO loader reads a size field from that file and uses it as a memory allocation. On 4.0.0 through 4.0.15 the addition of a fixed header length wraps a 32-bit size, so the process allocates a few bytes and then writes the image past that allocation. GitHub rates that Critical. Two more ICO flaws, both High, crash the worker: one by allocating about 4 GB, and one by writing a reconstructed BMP header past a tiny buffer. That second one is still present in 4.0.16.

**GitHub rates [GHSA-hff9-5pqw-6w9f](https://github.com/imgproxy/imgproxy/security/advisories/GHSA-hff9-5pqw-6w9f) CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. VulnCheck assigned [CVE-2026-123614](https://www.cve.org/CVERecord?id=CVE-2026-123614) on 2026-11-08 and scores the same flaw CVSS 4.0 9.3 and CVSS 3.1 9.8. The GitHub advisory page still says no CVE is known. GitHub says a crafted image can terminate the process or lead to remote code execution through heap corruption. VulnCheck says the same overflow can crash the process or achieve code execution. Neither report says a deployment was compromised.

The two companion flaws:

- [CVE-2026-123616](https://www.cve.org/CVERecord?id=CVE-2026-123616) is [GHSA-mmq5-xm89-9pfg](https://github.com/imgproxy/imgproxy/security/advisories/GHSA-mmq5-xm89-9pfg). GitHub rates it CVSS 3.1 7.5 High. VulnCheck rates it CVSS 4.0 8.7 and CVSS 3.1 7.5. The ICO loader passes `data_size` to the allocator with no upper bound, so a 23-byte ICO can make a worker try to allocate about 4 GB. Affected from 3.3.0 before 4.0.16. Fixed in 4.0.16.
- [CVE-2026-123615](https://www.cve.org/CVERecord?id=CVE-2026-123615) is [GHSA-494m-4556-wf5p](https://github.com/imgproxy/imgproxy/security/advisories/GHSA-494m-4556-wf5p). GitHub rates it CVSS 3.1 7.5 High. VulnCheck rates it CVSS 4.0 8.7 and CVSS 3.1 7.5. With a tiny declared size, the loader reads and writes past the buffer while rebuilding a BMP header, and glibc aborts the worker. Affected from 3.3.0 through 4.0.16. Fixed in 4.0.17. **4.0.16 is not enough for this one.**

All three need no login and no user interaction. They need a deployment that decodes an image the caller supplies, which is what imgproxy is for. The GitHub pages for all three still say no CVE is known. The CVE records are the VulnCheck publication of those same advisories.

Two earlier High flaws are already fixed in older builds, and they are not the reason to stop at 4.0.16:

- [CVE-2026-115581](https://www.cve.org/CVERecord?id=CVE-2026-115581), [GHSA-55vq-g34m-xp8f](https://github.com/imgproxy/imgproxy/security/advisories/GHSA-55vq-g34m-xp8f), CVSS 3.1 7.5. The custom BMP loader writes past its row buffer. 4.0.0 through 4.0.11. Fixed in 4.0.12.
- [CVE-2026-115582](https://www.cve.org/CVERecord?id=CVE-2026-115582), [GHSA-8w7m-q6hg-mfqm](https://github.com/imgproxy/imgproxy/security/advisories/GHSA-8w7m-q6hg-mfqm), CVSS 3.1 7.5. The source-address guard treats `100.64.0.0/10` as public, so a caller-chosen source URL can reach a CGNAT address even when private source addresses are denied. Through 4.0.11. Fixed in 4.0.12.

4.0.21, released 2026-11-02, says it fixed several more vulnerabilities in the BMP and ICO loaders and names no CVE. 4.0.22, released 2026-11-05, says it fixed minor bugs in the BMP loader. The current release when checked on 2026-11-08 is 4.0.22.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08). The advisories do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix commit for the overflow and the unbounded allocation | 2026-09-28 16:50 UTC | `a821b6a4cb07`, "Fix segfaults during invalid ICO load." [Commit][commit16] |
| imgproxy 4.0.16 | 2026-09-28 17:51 UTC | "Fixed several vulnerabilities in ICO image loader." This is the floor for CVE-2026-123614 and CVE-2026-123616. It is still affected by CVE-2026-123615. [Release][rel16] |
| Fix commit for the out-of-bounds header write | 2026-09-30 15:28 UTC | `39fd9e844a8a`, "ICO BMP payload size check." [Commit][commit17] |
| imgproxy 4.0.17 | 2026-09-30 16:10 UTC | "Fixed a possible out-of-bounds read in the ICO image loader." The floor for CVE-2026-123615. [Release][rel17] |
| **Public announcement** | **2026-10-06 15:30 UTC** | DarthSim published the three GitHub advisories. The Critical one is 15:30:41 UTC. The out-of-bounds one is 15:29:47 UTC. The allocation one is 15:28:16 UTC. Each page still says no CVE is known. [Critical][ghsa614] [OOB][ghsa615] [Allocation][ghsa616] |
| GitHub Advisory Database | 2026-10-30 22:57 UTC | The Critical advisory was reviewed and published to the database. The other two were published the same evening. |
| imgproxy 4.0.21 | 2026-11-02 17:06 UTC | "Fixed several vulnerabilities in BMP and ICO loaders." No CVE named. [Release][rel21] |
| imgproxy 4.0.22 | 2026-11-05 12:41 UTC | "Minor bugs in bmp image loader." The current release when checked. [Release][rel22] |
| CVE records | 2026-11-08; time/TZ unknown | VulnCheck published CVE-2026-123614, CVE-2026-123615, and CVE-2026-123616. The record date has no time of day. [CVE-2026-123614][cve614] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-08) | [KEV][kev] |

## Detection

This reads the version you are running. It does not send an image.

```sh
docker exec CONTAINER imgproxy --version
```

Replace `CONTAINER` with the name from `docker ps`. A binary install prints the same string:

```sh
imgproxy --version
```

- **4.0.17 or later** has the fix for all three ICO flaws. 4.0.22 is the current release.
- **4.0.16** fixes the integer overflow and the unbounded allocation. It does not fix the out-of-bounds header write.
- **4.0.0 through 4.0.15** are inside the Critical flaw.
- **3.3.0 through 3.30.x** are inside the two High ICO flaws and outside the Critical one, which starts at 4.0.0. There is no 3.x release that fixes them. Move to 4.0.17 or later.
- An image tag of `latest` is not a version. Read the string the binary prints.

A deployment that only fetches source images from addresses you control, and never decodes a caller-supplied file, is outside the ICO path. The default is to decode what the request names. The version check still matters if that can change.

## Remediation

1. Upgrade to **4.0.17 or later**, and recreate the container. A running container keeps the old image. 4.0.22 is current. 4.0.16 is not the fix for CVE-2026-123615.
2. A 3.x install has no backport. Move it to 4.0.17 or later. Read the [4.0 upgrade notes](https://docs.imgproxy.net/) before you do: 4.0 changed configuration names.
3. The advisories list no workaround. Refusing `image/x-icon` and `image/vnd.microsoft.icon` at a proxy in front of imgproxy only helps if imgproxy never sees the bytes. imgproxy detects ICO from the file header, not from the content type the caller sends, so a content-type filter is not the fix.
4. The upgrade does not show whether a worker already crashed or ran a payload. It does not restore an image that was being processed.

## Verification

- `imgproxy --version` prints 4.0.17 or later after the container or process was restarted.
- A request your application already makes, for an image you host, still returns the processed image. Do not send a crafted ICO to test the check.

## Compromise response

A crash of the imgproxy process is what the High flaws do on purpose, so a restart by itself is not a sign of compromise. The Critical flaw's code-execution claim is what the overflow can reach, and neither GitHub nor VulnCheck reports that it was used.

If the process runs as a user that can read application secrets, and you have reason to think a caller sent images you did not expect:

- Replace that deployment from a known image rather than restarting the old container.
- Rotate credentials that the imgproxy process could read, including cloud keys mounted into the container.
- Keep the source-address guard on (`IMGPROXY_ALLOW_PRIVATE_SOURCE_ADDRESSES` unset or false) so a source URL cannot reach your own network. 4.0.12 is the floor for the CGNAT gap in that guard.

## Sources

- [GHSA-hff9-5pqw-6w9f][ghsa614] — GitHub, published 2026-10-06. CVSS 3.1 9.8. 4.0.0 through 4.0.15, fixed in 4.0.16. The page says no CVE is known.
- [CVE-2026-123614][cve614] — VulnCheck, published 2026-11-08. CVSS 4.0 9.3 and CVSS 3.1 9.8. Same flaw. Fixed at 4.0.16.
- [GHSA-mmq5-xm89-9pfg][ghsa616] — GitHub, published 2026-10-06. CVSS 3.1 7.5. 3.3.0 through 4.0.15, fixed in 4.0.16.
- [CVE-2026-123616][cve616] — VulnCheck, published 2026-11-08. CVSS 4.0 8.7 and CVSS 3.1 7.5.
- [GHSA-494m-4556-wf5p][ghsa615] — GitHub, published 2026-10-06. CVSS 3.1 7.5. 3.3.0 through 4.0.16, fixed in 4.0.17.
- [CVE-2026-123615][cve615] — VulnCheck, published 2026-11-08. CVSS 4.0 8.7 and CVSS 3.1 7.5.
- [GHSA-55vq-g34m-xp8f][ghsa581] — BMP loader, CVE-2026-115581, CVSS 3.1 7.5, fixed in 4.0.12.
- [GHSA-8w7m-q6hg-mfqm][ghsa582] — CGNAT source guard, CVE-2026-115582, CVSS 3.1 7.5, fixed in 4.0.12.
- [imgproxy 4.0.16][rel16], [4.0.17][rel17], [4.0.21][rel21], [4.0.22][rel22] — release notes.
- [CISA KEV JSON][kev] — catalog 2026.11.06, checked 2026-11-08. None of these CVEs is listed.

[ghsa614]: https://github.com/imgproxy/imgproxy/security/advisories/GHSA-hff9-5pqw-6w9f
[ghsa615]: https://github.com/imgproxy/imgproxy/security/advisories/GHSA-494m-4556-wf5p
[ghsa616]: https://github.com/imgproxy/imgproxy/security/advisories/GHSA-mmq5-xm89-9pfg
[ghsa581]: https://github.com/imgproxy/imgproxy/security/advisories/GHSA-55vq-g34m-xp8f
[ghsa582]: https://github.com/imgproxy/imgproxy/security/advisories/GHSA-8w7m-q6hg-mfqm
[cve614]: https://www.cve.org/CVERecord?id=CVE-2026-123614
[cve615]: https://www.cve.org/CVERecord?id=CVE-2026-123615
[cve616]: https://www.cve.org/CVERecord?id=CVE-2026-123616
[commit16]: https://github.com/imgproxy/imgproxy/commit/a821b6a4cb07a1bf2bb9077431d1c1e734d79917
[commit17]: https://github.com/imgproxy/imgproxy/commit/39fd9e844a8a46084161502e993d5a3c16ccf28d
[rel16]: https://github.com/imgproxy/imgproxy/releases/tag/v4.0.16
[rel17]: https://github.com/imgproxy/imgproxy/releases/tag/v4.0.17
[rel21]: https://github.com/imgproxy/imgproxy/releases/tag/v4.0.21
[rel22]: https://github.com/imgproxy/imgproxy/releases/tag/v4.0.22
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
