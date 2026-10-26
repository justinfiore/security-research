# curl and libcurl: use-after-free when a server resets an upload

**Last updated:** 2026-10-26 (America/New_York)

[Main curl summary](../black-october-2026.md#curl-and-libcurl-use-after-free-when-a-server-resets-an-upload-cve-2026-92392) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-92392](https://www.cve.org/CVERecord?id=CVE-2026-92392): the curl project rates it severity High. The curl CNA record has no CVSS score. CISA's ADP entry adds CVSS 3.1 8.1 High (`CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`). NVD has added no score of its own. Not listed in CISA KEV (catalog 2026.10.23, checked 2026-10-26). The researcher's report, now public, includes a working remote code execution proof of concept (PoC). No in-the-wild exploitation has been reported.** [curl advisory][adv] [CNA/ADP][cve] [KEV][kev]

**What it is:** During an upload, curl mishandles an HTTP/2 `RST_STREAM` from the **server** with reason `HTTP_1_1_REQUIRED` or `REFUSED_STREAM`. That leads to a use-after-free of a `struct Curl_easy` object. Both the **curl command-line tool and libcurl** are affected. Affected versions are **8.12.0 through 8.22.0**, fixed in **8.23.0**. [curl advisory][adv]

**Attack conditions and worst case:**

- The attacker must control, or be able to impersonate, the **server** that curl is uploading to over HTTP/2.
- The researcher's report gives the trigger as `curl -T <file>`, where the uploaded file contains a line shaped like `<word> <word> <any>` followed by a blank line and is larger than about 135 KB. Their PoC also needed parallel transfers (`-Z`) when PIE/ASLR is enabled. [HackerOne #4030333][h1]
- curl says turning the bug into code execution has been proven, but only if the malicious server knows or can control a long list of things: the exact curl build and structure layout, the architecture, the libc allocator and heap layout, nghttp2 and OpenSSL/TLS 1.3 behaviour, the CA bundle, two parallel transfers calibrated in timing, a libc leak, and a command of about 23 bytes. [curl advisory][adv]
- Worst case: code execution in the process doing the upload. That could be a CI job, backup or sync agent, or any application that uploads with libcurl to an untrusted or compromised HTTP/2 endpoint.

**Embedded copies matter.** curl warns that "libcurl is used by many applications, but not always advertised as such". Patching the system package does not fix copies of libcurl that are bundled or statically linked into language bindings, wheels, container images, appliances or vendor software. [curl advisory][adv]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). The researcher's public report includes a remote code execution PoC; no in-the-wild exploitation has been reported. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory of curl and libcurl copies (read-only)](#inventory-of-curl-and-libcurl-copies-read-only)
  - [Reachability](#reachability)
  - [Logs and indicators](#logs-and-indicators)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Flaw introduced | curl 8.12.0 | Introducing commit `cd9107e0`. [curl advisory][adv] |
| Private report to curl | 2026-09-15 (HackerOne report created 01:21:40 UTC, submitted 18:30:57 UTC) | Reported by "Luna with Claude, Anthropic". [curl advisory][adv] [HackerOne #4030333][h1] |
| CVE ID reserved | 2026-09-16 08:12:53 UTC | Reservation, not disclosure. [CNA][cve] |
| Debian DSA-6558-1 | 2026-10-14 06:14:47 +0000 | trixie fixed in **8.14.1-2+deb13u7**. [DSA-6558-1][dsa] |
| HackerOne report made public | 2026-10-14 06:40:28 UTC | The public report lists attachments named `evil-server.py`, `curl-h2-uaf.tar.gz` and `curl_rce.mov`. They were not downloaded or run for this review. [HackerOne #4030333][h1] |
| CVE record published | 2026-10-14 07:46:15 UTC | curl CNA. NVD published it 08:17 UTC. [CNA][cve] [NVD][nvd] |
| **Public announcement:** curl advisory and **curl 8.23.0** | **2026-10-14 08:00 UTC** (advisory JSON `published`) | "curl 8.23.0 was released on October 14, 2026, coordinated with the publication of this advisory." [curl advisory][adv] [advisory JSON][json] |
| Rock-solid curl 8.20.2, 8.16.2 and 8.14.3 | 2026-10-14; time/TZ unknown | Fixed **commercial** long-term branches, "provided exclusively to current customers with support contracts". [Rock-solid curl][rs] |
| CISA ADP enrichment | 2026-10-15 03:56 UTC | CVSS 3.1 8.1. SSVC: exploitation "poc", automatable "no", technical impact "total". [CNA/ADP][cve] |
| CISA KEV | Not listed | Catalog 2026.10.23 checked on 2026-10-26. [KEV][kev] |
| Exploitation evidence | None found | A public PoC exists, but no exploitation has been reported. |

## Detection

### Inventory of curl and libcurl copies (read-only)

Run these on each host, and inside each container image, as an unprivileged user (or root for a full filesystem scan). They only read package databases and file contents, and they have not been run on a production system.

```sh
# The curl tool: version and whether HTTP2 appears in the Features line
curl -V

# System packages
dpkg -l 'curl' 'libcurl*' 2>/dev/null | grep '^ii'      # Debian/Ubuntu
rpm -qa 'curl' 'libcurl*' 2>/dev/null                   # RHEL/Fedora/SUSE
apk info -v 2>/dev/null | grep -E '^(curl|libcurl)'     # Alpine

# Bundled or vendored shared copies anywhere on the root filesystem
find / -xdev \( -name 'libcurl*.so*' -o -name 'libcurl*.dylib' -o -name 'libcurl*.dll' \) 2>/dev/null

# Version strings in statically linked binaries; replace BINARY with a path
grep -a -o -m1 'libcurl/8\.[0-9]*\.[0-9]*' BINARY
```

Look in these places, which often carry their own libcurl:

- Python wheels such as `pycurl` and `curl_cffi`, under `site-packages/*.libs`
- Node, Ruby, R or PHP extensions built against a bundled copy
- Rust binaries using `curl-sys` with static linking
- Vendor agents and appliances
- Base images that you have not rebuilt since 2026-10-14

A version string is only a hint. Distributions backport fixes (Debian 8.14.1-2+deb13u7 is fixed although its upstream number is "8.14.1"), so check your vendor's advisory for the package you have.

### Reachability

You are exposed only if the vulnerable code **uploads** over **HTTP/2** to a server that an attacker controls or can impersonate:

- The researcher's trigger is `curl -T` (`--upload-file`), which corresponds to `CURLOPT_UPLOAD` in libcurl. The advisory says only "during an upload" and does not say whether POST bodies are also affected, so treat other request bodies sent from a file or callback as possibly in scope: `-d @file`, `--data-binary`, `-F`, `CURLOPT_READFUNCTION` and `CURLOPT_POSTFIELDS`. Prioritise CI pipelines, backup jobs and webhooks that send data to third-party or user-supplied URLs.
- For HTTPS, libcurl negotiates HTTP/2 by default when it is built with HTTP/2 support. Code that forces HTTP/1.1 (`--http1.1` or `CURL_HTTP_VERSION_1_1`) does not reach the HTTP/2 path. [CURLOPT_HTTP_VERSION][httpver]
- Uploads to well-run endpoints you control are lower risk. Uploads to user-supplied URLs, or over networks where TLS validation is disabled (`-k` or `CURLOPT_SSL_VERIFYPEER=0`), are higher risk.

### Logs and indicators

No IOCs are published. Possible signs, none of which proves anything either way:

- curl or upload processes that crash (segfault or abort) after talking to an HTTP/2 server
- HTTP/2 stream resets during uploads to unusual destinations
- Short unexpected commands spawned by processes that use libcurl

The proven exploit needs very precise conditions, so finding nothing proves nothing.

## Remediation

1. **Upgrade** curl and libcurl to **8.23.0** or later, or install your distribution's fixed package (for example Debian trixie **8.14.1-2+deb13u7**, [DSA-6558-1][dsa]). Support customers of commercial rock-solid curl can use 8.20.2, 8.16.2 or 8.14.3. [curl advisory][adv] [Rock-solid curl][rs]
2. **Rebuild** everything that bundles or statically links libcurl: container images, wheels, Rust and Go-cgo binaries, and vendor software (ask the vendor). Restart long-running processes so they load the patched shared library.
3. **If you cannot patch yet**, apply curl's own option C: "Do not use HTTP/2". For example, add `--http1.1` to curl commands that upload, or set `CURLOPT_HTTP_VERSION` to `CURL_HTTP_VERSION_1_1` in applications. Alternatively, apply the upstream fix commit `8b0744af` to your own build (option B). [curl advisory][adv]
4. Keep TLS verification on, and avoid uploading to untrusted or user-supplied URLs from privileged contexts.

**Rollback caution:** Older images and pinned base layers bring back 8.12.0–8.22.0. Search registries for stale tags.

## Verification

- `curl -V` reports 8.23.0+ (or a vendor-fixed package), and the libcurl version in that output matches.
- Re-run the inventory: every `libcurl*.so*` copy and statically linked binary has been updated or rebuilt, and running services were restarted (`lsof` or `/proc/<pid>/maps` show no deleted, outdated `libcurl` mapping).
- Benign functional check: make a normal HTTPS upload to an endpoint you own and confirm it succeeds. **Do not** run the public PoC server.

## Compromise response

- If an affected client uploaded data to a server you do not trust, and you see crashes or unexplained activity, investigate the client host: look for unexpected processes, persistence (cron, systemd, shell profiles) and outbound connections.
- Rotate credentials that the uploading process held, such as CI tokens, cloud keys, and the credentials used for the upload itself.
- Rebuild affected CI runners or containers from clean images instead of cleaning them in place.

## Sources

- [curl advisory CVE-2026-92392][adv] and [JSON][json]: severity, affected and fixed versions, exploit conditions, timeline, credits and recommendations.
- [CVE record with CISA ADP][cve] and [NVD][nvd]: timestamps, CVSS 3.1 8.1 (CISA ADP) and SSVC.
- [HackerOne report #4030333][h1]: trigger preconditions, disclosure time and PoC attachments (not executed).
- [Rock-solid curl downloads][rs], [curl CURLOPT_HTTP_VERSION docs][httpver], [Debian DSA-6558-1][dsa].
- [CISA KEV feed][kev] (no entry).

[adv]: https://curl.se/docs/CVE-2026-92392.html
[json]: https://curl.se/docs/CVE-2026-92392.json
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-92392
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-92392
[h1]: https://hackerone.com/reports/4030333
[rs]: https://rock-solid.curl.dev/download.html
[httpver]: https://curl.se/libcurl/c/CURLOPT_HTTP_VERSION.html
[dsa]: https://lists.debian.org/debian-security-announce/2026/msg00472.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
