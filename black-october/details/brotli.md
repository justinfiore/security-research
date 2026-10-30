# HTTP2Shell / Node2Shell: detection and remediation

**Last updated:** 2026-10-30 (America/New_York)

[Main Brotli summary and patch matrix](../black-october-2026.md#2-http2shell--node2shell-a-cross-stack-brotli-decoder-vulnerability) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-111497](https://www.cve.org/CVERecord?id=CVE-2026-111497)** is one cross-stack Brotli decoder bug, also called **Brotli2Shell** in [JFrog's 2026-10-25 research](https://research.jfrog.com/post/brotli2shell-beyond-node2shell-and-http2shell/), alongside HTTP2Shell and Node2Shell. Node rates it High; the Google/CNA CVSS 4.0 rating is **9.2 Critical**; [Red Hat][rhbrotli] rates it **Important, CVSS 3.1 8.1** (`AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`) and says there is no public, reliable RCE proof of concept. Malformed compressed data can corrupt process memory, causing disclosure, crashes or RCE. It is not an HTTP/2-specific defect and does not require a public inbound HTTP endpoint. File and buffer processing also matter: the new research reaches FFmpeg through libjxl/JPEG XL metadata, ClickHouse through HTTP bodies, and Apache Arrow/pyarrow through Brotli decoding. The demonstrated outcomes differ; do not label every stack a demonstrated RCE.

**CISA KEV:** [CVE-2026-111497](https://www.cve.org/CVERecord?id=CVE-2026-111497) Listed — added 2026-10-27, federal due date 2026-11-10. The related Node.js CVEs ([CVE-2026-105482](https://www.cve.org/CVERecord?id=CVE-2026-105482), [CVE-2026-105483](https://www.cve.org/CVERecord?id=CVE-2026-105483) and [CVE-2026-106069](https://www.cve.org/CVERecord?id=CVE-2026-106069)) are not listed. CISA's listing establishes reliable evidence of in-the-wild exploitation; the due date binds U.S. federal civilian agencies and is an urgency signal for other organizations. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Map every decoder and input source](#map-every-decoder-and-input-source)
  - [Inventory by language and deployment](#inventory-by-language-and-deployment)
  - [Official researcher detection tools](#official-researcher-detection-tools)
  - [Response-header inventory script](#response-header-inventory-script)
  - [Operational signals and evidence limits](#operational-signals-and-evidence-limits)
  - [Other Node DNS and TLS issues](#other-node-dns-and-tls-issues)
- [Remediation](#remediation)
  - [Contain before the first decoder](#contain-before-the-first-decoder)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and evidence |
|---|---|
| Private discovery/report | Exact date not established in the cited public advisory; Node credits OpenAI Codex Security |
| Node advisory and fixes | 2026-10-21: [Node security release](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases), versions 22.23.4, 24.22.1 and 26.12.1 |
| Public exploit research | 2026-10-22: [Imperva Node2Shell analysis](https://www.imperva.com/blog/node2shell-from-brotli-data-to-remote-code-execution/) |
| Python advisory publication/update | 2026-10-22 / 2026-10-23: [GitHub advisory](https://github.com/advisories/GHSA-9v8h-qqgm-4m35) lists Brotli 1.2.1 and brotlicffi 1.2.1.0 fixes; those advisory dates are not assumed to be their upload dates |
| Google library fixes | 2026-10-21: [Brotli 1.0.10 / 1.1.1 / 1.2.1 release records](https://github.com/google/brotli/releases) |
| Bun fix | 2026-10-22: [Bun 1.4.4](https://github.com/oven-sh/bun/releases/tag/bun-v1.4.4) |
| Bun advisory | 2026-10-23 09:31 UTC: [GHSA-663w-cv8g-jj2p](https://github.com/oven-sh/bun/security/advisories/GHSA-663w-cv8g-jj2p) rates the issue High; affected ≥1.0.21 and <1.4.4 |
| Python package availability | 2026-10-22: first PyPI uploads of [Brotli 1.2.1](https://pypi.org/project/Brotli/1.2.1/) at 13:57 UTC and [brotlicffi 1.2.1.0](https://pypi.org/project/brotlicffi/1.2.1.0/) at 16:19 UTC |
| Envoy downstream fix/advisory | 2026-10-06: [1.39.3 release](https://github.com/envoyproxy/envoy/releases/tag/v1.39.3); [advisory published 2026-10-23](https://github.com/envoyproxy/envoy/security/advisories/GHSA-3wvj-j6qm-62mr). Other branch artifact dates are not established here |
| Istio downstream fixes | [Bulletin ISTIO-SECURITY-2026-007](https://istio.io/latest/news/security/istio-security-2026-007/) dated 2026-10-15; corresponding GitHub release timestamps are 2026-10-16 UTC. Downstream release dates need not match the later Node disclosure |
| Ruby binding fix | 2026-10-24, time/TZ unknown: [maintainer confirms brotli 0.9.1](https://github.com/miyucy/brotli/issues/64) bundles 1.2.1 and rejects unpatched system libraries |
| Java binding advisory | 2026-10-24, time/TZ unknown: [Brotli4j advisory](https://github.com/hyperxpro/Brotli4j/security/advisories/GHSA-x524-jrqf-vwq6) identifies 1.24.0 as fixed; advisory publication is not an exact artifact-availability timestamp |
| PHP extension fix | 2026-10-24 23:49:20 UTC: [php-ext-brotli 0.21.1](https://github.com/kjdev/php-ext-brotli/releases/tag/0.21.1) bundles 1.2.1 |
| PHP Windows package rebuilds | 2026-10-23, time/TZ unknown: the [PHP project](https://www.php.net/archive/2026.php) released Windows packages **8.2.35-1 / 8.3.36-1 / 8.4.27-1 / 8.5.12-1** with Brotli 1.2.1. The `-1` suffix identifies the rebuilt package; the PHP source/runtime version is unchanged. |
| .NET advisory publication | 2026-10-25 19:06:12 UTC: [Microsoft advisory](https://github.com/dotnet/announcements/issues/494) published, identifying fixed runtimes 8.0.33 / 9.0.22 / 10.0.14 and preview 11.0.0-rc.3.26522.148. This is the advisory issue's creation time, not the first availability of every artifact; supersedes earlier reports that no fixed .NET release was established |
| Arrow upstream report | 2026-10-23 23:40:01 UTC: [issue #55166](https://github.com/apache/arrow/issues/55166) reports bundled Brotli 1.0.9 and file-processing exposure; this is a public issue timestamp, not JFrog's private discovery date |
| libjxl source fix | 2026-10-24 17:09:23 UTC: [PR #5062](https://github.com/libjxl/libjxl/pull/5062) merged a Brotli 1.2.1 dependency bump. A source merge is not an FFmpeg or libjxl binary release |
| ClickHouse source fix | 2026-10-25 11:58:00 UTC: [PR #127419](https://github.com/ClickHouse/ClickHouse/pull/127419) merged the Brotli 1.2.1 bump. Its current version information names 26.11.1.749-master and backports 26.10.3.6 / 26.9.26.18 / 26.8.35.17 / 26.3.61.13; these are not evidence of published release artifacts |
| JFrog cross-stack demonstrations and detector | 2026-10-25, time/TZ unknown: [Brotli2Shell research](https://research.jfrog.com/post/brotli2shell-beyond-node2shell-and-http2shell/) reports FFmpeg pointer corruption/crash, ClickHouse crash, .NET native crash and pyarrow infinite loop. Exact private discovery/report dates for these demonstrations are not established |
| MSRC advisory | 2026-10-25 07:00 −07:00 (14:00 UTC): [MSRC CVE-2026-111497][msrcbrotli] rates it Critical (CVSS 3.1 8.1, `AC:H`), publicly disclosed, not exploited; fixed .NET 8/9/10/11 SDKs, Visual Studio 2019/2022/2026 and PowerShell 7.4/7.5/7.6 builds. |
| .NET rollout confirmation / public-branch tracking | 2026-10-25 17:12:45 UTC: [Microsoft maintainer announces rollout](https://github.com/dotnet/runtime/issues/136422#issuecomment-6400646760); at 19:34:16 UTC the [issue was reopened for public-branch ports](https://github.com/dotnet/runtime/issues/136422#issuecomment-6402196766), not because released fixes were withdrawn |
| Linux distribution packages | Debian: [DLA-4855-1](https://lists.debian.org/debian-lts-announce/2026/10/msg00049.html) (bookworm `1.0.9-2+deb12u1`, 2026-10-23 19:09:40 −03:00) and [DSA-6582-1](https://www.debian.org/security/2026/dsa-6582) (trixie `1.1.0-2+deb13u1`, 2026-10-23 21:09:31 UTC); sid fixed in `1.2.0-4.1`, forky still vulnerable ([tracker][debbrotli]). Debian's `nodejs` uses the system library. Amazon Linux 2023: [ALAS2023-2026-3334][alasbrotli] (released 2026-10-24, `1.1.0-1.amzn2023.0.2` backport, Important). Ubuntu: brotli `needs-triage` on every release when reviewed. Red Hat lists only RHSA-2026:87420 (Hardened Images) as fixed. [Red Hat][rhbrotli] Alpine: `brotli` 1.2.1-r0 (edge, 3.24, 3.23) and 1.1.1-r0 (3.21) and `nodejs-current` 26.12.1-r0 marked fixed; release date not established. [Alpine][alpinebrotli] Fedora updates were still in testing/pending on 2026-10-26. |
| ClickHouse backports merged | 2026-10-25 14:10:47 UTC (26.10, PR #127778) through 2026-10-26 06:21:46 / 06:29:01 / 09:02:26 UTC (26.8 #127810, 26.9 #127811, 26.3 #127809). Merged on every listed branch; no release containing them was published when reviewed |
| Downstream release-status recheck | 2026-10-26: [ClickHouse releases](https://github.com/ClickHouse/ClickHouse/releases) do not yet list the four named backport releases; latest published stable is 26.10.2.103 (2026-10-24 04:17:23 UTC). [Arrow issue #55166](https://github.com/apache/arrow/issues/55166) remains open and [PR #55167](https://github.com/apache/arrow/pull/55167) was approved 2026-10-24 but is not merged; latest [Arrow release](https://github.com/apache/arrow/releases) is 26.0.0 (2026-10-09 07:37:33 UTC). Latest [libjxl release](https://github.com/libjxl/libjxl/releases) is 0.12.0 (2026-07-01 21:16:30 UTC), preceding its source fix. Fixed downstream release availability is not established by these records; check the deployed supplier's builds/backports separately |
| Palo Alto Networks advisory | 2026-10-26, updated 2026-10-27: [PAN-OS portfolio status](https://security.paloaltonetworks.com/CVE-2026-111497) identifies conditionally affected PAN-OS 11.2/12.1/12.2 releases and fixed hotfixes or ETAs; it does not affect the management interface, PAN-OS 11.1 or 10.2 |
| x86-64 RCE reproduction and in-the-wild exploit traffic | Post dated 2026-10-25: [ELLIO][ellio] reports reproducing a shell on the official, unmodified Node.js **24.22.0 x86-64** build (plain `node:http`, `node:24.22.0-slim` as root, Express 5.3.0 and Koa 3); 24.22.1 rejected the input. Update dated 2026-10-26: at **15:08 UTC** its sensors received a 23,069,983-byte Brotli request body built for Node.js v24.22.0 x86-64 from 94.154.43.7. ELLIO says the delivery copies public PoCs with an original ROP chain, and that this chain scored 0 of 50 attempts against its own vulnerable target. This is an observed exploitation attempt, not a confirmed compromise |
| CISA KEV addition | 2026-10-27, time/TZ unknown: CISA [added CVE-2026-111497 to KEV](https://www.cisa.gov/news-events/alerts/2026/10/27/cisa-adds-two-known-exploited-vulnerabilities-catalog) based on evidence of active exploitation; federal civilian agencies have a 2026-11-10 due date |

## Detection

### Map every decoder and input source

Inventory runtime-native libraries, Python wheels, Envoy/Istio proxies and other bundled C Brotli consumers, including media workers and database/analytics jobs. Record the deployed image digest and package/build, which party supplies it, and where it decodes untrusted data.

| Path | What to inspect |
|---|---|
| Inbound request body | Middleware/decompressor enabled for `Content-Encoding: br`; do not assume Node's plain HTTP server automatically decodes it |
| Outbound response | `fetch`/HTTP clients, crawlers, preview generators, webhooks and import workers that automatically decode an attacker-controlled response |
| Direct library call | `node:zlib` Brotli decompression or native/Python decode calls accepting uploaded/fetched bytes |
| Proxy/service mesh | Effective request **and response** decompressor filters; the app runtime and proxy are separate patch targets |
| Embedded file data / analytical buffers | FFmpeg → libjxl → JPEG XL `brob` metadata → Brotli; Arrow/pyarrow Parquet pages or direct buffer decompression; ClickHouse `.br` files and Parquet as well as HTTP. A file's outer format or HTTP header need not say Brotli |

From `black-october/`, run only the checks relevant to the deployed environment:

```sh
sh stack-inventory.sh node
sh stack-inventory.sh bun
python3 -I -S python-package-inventory.py /path/to/deployed/site-packages
```

The [stack script](../stack-inventory.sh) reports Node's bundled Brotli string as a clue; patches may be backported without an upstream version bump. Compare the runtime release and vendor fix evidence too. The [Python script](../python-package-inventory.py) reads metadata without imports; pass every real package directory. Neither detects arbitrary statically linked/vendored copies. A scanner matching only `package-lock.json` misses the Node runtime.

### Inventory by language and deployment

Run local inventory only in trusted environments; inspect suspected compromised systems from clean analysis hosts instead. The commands below do not install packages or remediate anything. They require access to the deployed runtime/artifacts, not administrative privileges by default. Replace example paths. Inventory CLI and web/worker runtimes separately.

| Stack | Inventory and exposure | Remediation target / limitation |
|---|---|---|
| Node.js / Bun | `node --version`, `node -p 'process.versions.brotli'`, `bun --version`; inspect request parsers, fetch clients and `node:zlib`. Include CI, desktop/embedded runtimes and image workers | Node **22.23.4 / 24.22.1 / 26.12.1**; Bun **1.4.4**. Replace the bundled runtime, not merely npm dependencies or host `libbrotli` |
| Python | Metadata script above; inspect both `Brotli` and `brotlicffi`, extras and HTTP-client dependencies. A transitive binding can enable client decoding | **Brotli 1.2.1 / brotlicffi 1.2.1.0**. Update every installed binding, wheel, environment and image |
| Java / Scala JVM | Inspect Maven/Gradle/sbt dependency trees, shaded JARs and JNI/native artifacts; the standard JDK has no Brotli codec | **Brotli4j 1.24.0**; **≤1.23.0 affected**. Update wrapper, BOM and every platform-specific `native-*` artifact. JDK or OS updates do not replace native JAR contents. Pure-Java codecs do not automatically inherit the native C exploit |
| C# / .NET | `dotnet --list-runtimes`; inspect application runtime configuration, `BrotliStream`/`BrotliDecoder`, request-decompression middleware and HTTP-client `AutomaticDecompression`. Include containers, self-contained apps and NativeAOT | **8.0.33 / 9.0.22 / 10.0.14**; preview **11.0.0-rc.3.26522.148**. Earlier releases within the advisory's listed branches are affected. Microsoft's [MSRC entry][msrcbrotli] (2026-10-25) rates it **Critical**, CVSS 3.1 **8.1**, publicly disclosed, not exploited, with fixed SDKs **8.0.427 / 9.0.320 / 10.0.403**. MSRC also lists fixed **Visual Studio 2019 16.11.61, 2022 17.14.43, 2026 18.11.2 (18.12 Insiders 3)** and **PowerShell 7.4.22 / 7.5.13 / 7.6.9** builds, which carry their own .NET runtime; request/client decompression is not enabled by default. .NET Framework is excluded by this advisory; assess third-party codecs separately |
| PHP | `php --ri brotli`, `php --ri curl`; inspect PHP-FPM/SAPI separately. Guzzle and libcurl-backed clients can decode responses independently of the extension. On Windows, inventory the downloaded package filename or SHA-256 too: `php -v` cannot distinguish the rebuilt package | **php-ext-brotli 0.21.1** bundles fixed Brotli; **0.21.0** bundled 1.2.0. Official Windows PHP packages require **8.2.35-1 / 8.3.36-1 / 8.4.27-1 / 8.5.12-1**. Patch libcurl's actual decoder separately. A PHP runtime version alone is not a decoder verdict |
| Ruby | Inspect `Gemfile.lock`, native extensions, HTTPX Brotli plugin and curl-backed clients. Standard `Net::HTTP` is not itself a Brotli codec | **brotli gem 0.9.1+**, not every 0.9.x release; 0.9.0 bundled 1.2.0. Rebuild native extensions and separately patch libcurl |
| Go | `go version -m /path/to/binary`, module graph/SBOM and cgo linkage. Brotli is not in the standard library | [andybalholm/brotli **1.2.7**](https://github.com/andybalholm/brotli/issues/82) includes the analogous invalid-stream fix; this does not establish native C RCE in pure Go. Verify the underlying library for cgo and rebuild binaries |
| Rust | `Cargo.lock`, `cargo tree -e features`, native/FFI dependencies and embedded decoder sources; Brotli is not in the standard library | Patch the actual native implementation or follow the pure-Rust project's advisory. No universal Rust crate fixed version is established here; memory-safety and algorithmic findings must not be conflated |
| curl/libcurl, appliances, proxies | `curl --version`, deployed SBOM and vendor build records; record dynamic versus static/bundled libraries | Google library fixes **1.0.10 / 1.1.1 / 1.2.1** or a verified backport. Update/rebuild the owning package. The curl CLI can differ from libcurl loaded by an app |
| FFmpeg / libjxl / JPEG XL | Inspect deployed FFmpeg build configuration and decoder list, libjxl linkage and its actual Brotli dependency; include thumbnailers, transcoders and metadata extraction jobs. Do not open untrusted media for inventory | [libjxl PR #5062](https://github.com/libjxl/libjxl/pull/5062) updates bundled Brotli to **1.2.1**; libjxl can also [use system Brotli](https://github.com/libjxl/libjxl/blob/ddfd9a18fa2156b064d08a319d741d00189dc250/third_party/CMakeLists.txt#L49-L71). No universal fixed FFmpeg/libjxl package version is established here: require supplier evidence for the loaded/linked decoder, not merely a newer FFmpeg executable |
| ClickHouse | Record server version/build and image digest, HTTP ingress that accepts `Content-Encoding: br`, and `.br`/Parquet ingestion from files or object storage. Inspect each server, not just client packages | [PR #127419](https://github.com/ClickHouse/ClickHouse/pull/127419) replaces bundled 1.2.0 with **1.2.1**. Listed backport versions are **26.10.3.6 / 26.9.26.18 / 26.8.35.17 / 26.3.61.13**, but publication was not established on 2026-10-26; verify an available supplier artifact contains the fix before recommending it as released |
| DuckDB | Record DuckDB library/CLI versions in applications, notebooks and data pipelines, and whether they read Brotli-compressed Parquet or other untrusted files | DuckDB bundles its own Brotli copy. [PR #27791](https://github.com/duckdb/duckdb/pull/27791) merged the upstream fix on 2026-10-24, but no fixed DuckDB release is established here. Updating system or Python Brotli does not replace it |
| Apache Arrow / pyarrow | Inventory pyarrow wheel metadata and Arrow C++ libraries independently of the Python `Brotli`/`brotlicffi` packages; inspect Brotli-compressed Parquet, direct buffer APIs and bundled-versus-system dependency records | [Issue #55166](https://github.com/apache/arrow/issues/55166) identifies bundled **1.0.9**; [PR #55167](https://github.com/apache/arrow/pull/55167) remains open on 2026-10-26. No fixed Arrow/pyarrow release is established here. Require a build using fixed Brotli or a verified backport; upgrading the separate Python Brotli binding does not replace Arrow's bundled native copy |
| PAN-OS | On PAN-OS 11.2.4+, run `show system setting brotli`; exposure requires `Enabled: yes`, TLS/SSL decryption and Brotli inspection on the dataplane. The management interface is not affected; PAN-OS 11.1 and 10.2 are unaffected | Upgrade to the fixed hotfix for the deployed branch: 12.2.4-h1; 12.1.4-h13, 12.1.7-h11 or 12.1.10-h3; or 11.2.4-h23, 11.2.7-h23, 11.2.10-h17, 11.2.13-h4 or 11.2.16-h1, subject to the vendor's release availability. Otherwise disable Brotli inspection and test policy impact |

Use supported runtime branches; an old runtime is not a mitigation. In particular, older Node lines can contain the affected decoder, even when omitted from supported-release advisories. Vendor/distribution support and backports must be checked separately; a compatible extension fix does not restore support to an EOL interpreter. Scala.js/Native deployments inherit their actual JavaScript/native decoder risks, not automatically the JVM conclusions.

### Official researcher detection tools

Prefer these researcher-maintained tools over a new local decoder scanner. Review their source, requirements and scope before using them on authorized offline artifacts from a clean analysis host; none was executed for this guide update. Do not run exploit fixtures or decode suspect files to validate a finding.

| Tool / official guidance | What it contributes | Prerequisites and evidence limits |
|---|---|---|
| [JFrog Brotli2Shell contextual scanner](https://github.com/jfrog/vulnerability_scanners/tree/main/brotli2shell_cve_2026_111497) | Potential decoder API usage in JavaScript and Python, Brotli CLI calls and ELF decoder symbols; includes high-level HTTP clients and middleware | Python **3.10+**; JavaScript parsing also requires `tree-sitter` and `tree-sitter-javascript`. Matches are not data-flow analysis or patch checks. Third-party directories are skipped unless explicitly targeted; `.mjs`, `.cjs`, TypeScript, PE/Mach-O and stripped static ELF code are coverage gaps. Review skipped files and JSON evidence; `applicable` is a candidate usage path, not confirmed exploitation, and `not applicable` is not a clean bill of health |
| [Trail of Bits Brotli Checker](https://github.com/trailofbits/brotli-checker) and [scanner guide](https://github.com/trailofbits/brotli-checker/blob/main/docs/usage.md) | Per-copy source fingerprints and supported ELF binary-code matching across dependencies, application packages and unpacked containers; optional caller investigation | Python **3.12–3.15**; standalone scanner uses the standard library, optional Trailmark discovery requires `uv`. The scanner reads files without executing application code or sending network probes. Build/format coverage and resource limits still leave gaps. Its advisory snapshot is dated **2026-10-23**: verify current vendor backports independently |

Keep **component presence → vulnerable build → untrusted-input reachability → observed failure → confirmed compromise** separate. The existing package-metadata and response-header scripts do not cover these native/file-processing paths. Scanner output supplements supplier build evidence; neither a match nor an empty result settles all five questions.

### Response-header inventory script

[`check_brotli.py`](../check_brotli.py) inventories **responses declaring Brotli**, not vulnerable decoders. It uses Python 3.9+ and the standard library only; prefer a supported Python release. No Brotli library is loaded. Run from `black-october/`, as an ordinary user, against authorized safe-to-GET URLs:

```sh
python3 check_brotli.py https://example.com/ https://example.com/assets/app.js
python3 check_brotli.py --file endpoints.txt > results.jsonl 2> summary.txt
python3 check_brotli.py --file - < endpoints.txt
python3 check_brotli.py --help
```

Replace example URLs; `endpoints.txt` is one full HTTP(S) URL per line, with blank lines and `#` comments ignored. Duplicate URLs are removed. Each URL receives two sequential HTTP/1.1 GET probes, advertising `br, identity;q=0, *;q=0` and `gzip, deflate, br`. **Bodies are never read or decompressed**, but GET still invokes server behavior.

| JSONL result | Meaning |
|---|---|
| `BR_ADVERTISED` | A `Content-Encoding` token is `br`, case-insensitively, even on error responses. Neither body validity nor decoder vulnerability is established |
| `NOT_OBSERVED` | A 2xx response did not advertise Brotli for this request only; **not a security pass** |
| `INCONCLUSIVE` | A non-2xx response did not advertise Brotli; redirects and authentication failures cannot clear an endpoint |
| `ERROR` | URL, DNS, TLS, connection or timeout failure; inspect `error` too, because redirect failures preserve already observed header results |

JSONL includes input/current URLs, profile, hop, status and selected headers. Summary counts on stderr are **responses/probes**, not unique endpoints. Exit **0** means probes completed without errors, not safe or patched; **1** means probe errors; **2** means invalid CLI arguments/input file. Protect output and do not put credentials or secrets in URLs.

Redirects are off. Opt-in `--follow-redirects` permits five hops and can contact other hosts, **including private addresses**; review scope first. HTTPS downgrades are refused and certificates verified. Connections are direct, ignoring proxy environment variables; no credentials/cookies are sent or retained. `--timeout 15` changes the per-socket timeout, not a total run deadline. HTTP/2/3, authentication, route/content-size variation and CDN policy can produce different results.

**Neither positive nor negative results establish CVE exposure.** Serving Brotli is encoding, not the vulnerable decoding operation; a site serving no Brotli may still decode incoming requests, fetched responses, files or queued jobs. The checker does not test WAF rejection, versions, actual body content, exploitability or eMudhra distrust. Use it to find compression owners, then perform decoder/path inventory above. Its disposable-local-server regression tests run with `python3 -m unittest -v test_check_brotli.py` from `black-october/`.

### Operational signals and evidence limits

Investigate decompression-associated crashes, unusual child processes, unexpected outbound traffic or modified service files. Correlate request/job IDs with the remote data source and EDR/coredump evidence. A malformed stream rejection can be benign and a successful compromise need not produce a logged error. Do not fetch a suspected malicious response again on production just to reproduce it.

[JFrog's 2026-10-25 demonstrations](https://research.jfrog.com/post/brotli2shell-beyond-node2shell-and-http2shell/) establish the following **tested outcomes**, not universal exploitability or in-the-wild exploitation:

| Consumer | Demonstrated result | Investigation / limit |
|---|---|---|
| FFmpeg → libjxl | Crafted JPEG XL compressed metadata corrupts a pointer and crashes during decoder cleanup | The article uses “instruction-pointer control,” but its detailed evidence shows attacker-controlled pointer corruption and a segmentation fault, **not a complete FFmpeg RCE exploit**. Correlate media-job failures and native decoder/cleanup stacks; do not generalize to builds without this decoder path |
| ClickHouse | One crafted **23 MB** HTTP body with `Content-Encoding: br` crashes the tested server during `BrotliReadBuffer` destruction/state cleanup, interrupting in-flight queries | This is a remotely triggerable DoS demonstration, not demonstrated ClickHouse RCE. Check ingress/job logs and server restarts. The tested size is not a safe lower bound for an input-size rule |
| .NET | A local console application's two-stage decode triggers native `SIGSEGV`, terminating the process rather than raising an ordinary managed exception | Network exposure still requires enabled request/client decompression or explicit APIs accepting attacker input. The open [runtime tracking issue](https://github.com/dotnet/runtime/issues/136422) tracks public-branch ports; it does not override Microsoft's released fixes |
| Apache Arrow / pyarrow | A **534-byte** input causes an indefinite CPU-consuming loop; Brotli **1.2.1** rejects the same input in under a second in JFrog's test | Investigate stuck data-processing jobs, sustained worker CPU and decompressor stacks even without a crash. This establishes DoS, not Arrow RCE. The small input also shows why compressed-input size limits alone are insufficient |

**Observed in-the-wild attempt ([ELLIO][ellio], 2026-10-26 15:08 UTC):** a single HTTP request with a Brotli-coded body of **23,069,983 bytes**, SHA-256 `7fcbdaaecd4419e2930927844f3b772668204737a4e7602a2290c991c93c5c4b`, from **94.154.43.7**, tuned to the official Node.js **v24.22.0 x86-64** binary. ELLIO says the same address also carried PHP2Shell exploits and VPN probing, so treat it as shared mass-exploitation infrastructure, not attribution or a complete blocklist. The chain redirects only stdin before running `/bin/sh`, so a successful attempt may produce no response output; look for follow-on reverse shells or downloads. ELLIO also observed an exposure checker with user agent `Mozilla/5.0 (compatible; node2shell-check/1.0)` sending valid and malformed `Content-Encoding: br` POST bodies; that marks reconnaissance, not exploitation. Per-build offsets mean failed attempts usually crash the worker: a burst of Node worker crashes or restarts after large `br` request bodies is an investigation signal, and on hosts with `systemd-coredump` those cores can hold other users' session data.

These are diagnostic patterns, not unique IOCs. No crash, low CPU, an absent shell, or a passing HTTP-header inventory excludes memory disclosure or another reachable decoder. Preserve suspect inputs without replaying them and investigate from clean systems.

### Other Node DNS and TLS issues

The same Node update fixes **[CVE-2026-105482](https://www.cve.org/CVERecord?id=CVE-2026-105482)** (DNS NUL truncation), **[CVE-2026-105483](https://www.cve.org/CVERecord?id=CVE-2026-105483)** (fullwidth-digit IP identity validation, Node 24/26), and **[CVE-2026-106069](https://www.cve.org/CVERecord?id=CVE-2026-106069)** (resolver/validator disagreement over noncanonical IPs). Trace user-controlled hosts into DNS allowlists and TLS connections independently of Brotli. Keep canonicalized validation and the actual destination consistent; do not disable TLS certificate verification as a workaround. Their public announcement/fix date is 2026-10-21; private discovery dates are not established here.

## Remediation

1. Node: replace/rebuild the deployed runtime with **22.23.4 / 24.22.1 / 26.12.1** or later supported fixes. Bun: **1.4.4** or later. Updating an npm application dependency alone is insufficient.
   Rebuild `bun build --compile` executables too: they embed the runtime. Bun's [vendor advisory](https://github.com/oven-sh/bun/security/advisories/GHSA-663w-cv8g-jj2p) identifies per-request `fetch` option `decompress: false` as containment for that fetch only, not a process-wide workaround or protection for other Brotli APIs.
2. Python: update the locked artifacts for **Brotli 1.2.1** and/or **brotlicffi 1.2.1.0** as applicable, rebuild worker images and restart processes. Inspect dependency resolver constraints; do not leave a second environment unchanged.
3. Native consumers: obtain a build containing the fix from the supplier. The C library has branch fixes **1.0.10 / 1.1.1 / 1.2.1**. Do not use a simple cross-branch “version greater than 1.0.10” test. Distribution packages backport the fix under older version strings: Debian bookworm `1.0.9-2+deb12u1`, trixie `1.1.0-2+deb13u1`; Amazon Linux 2023 `1.1.0-1.amzn2023.0.2`. Ubuntu had not shipped a fix when reviewed. After updating the system library, restart every process that loaded it (including distribution `nodejs` on Debian/Ubuntu, which uses the system copy).
4. Envoy/Istio: update to a supplier-supported release containing the fix; use the [main patch matrix](../black-october-2026.md#2-http2shell--node2shell-a-cross-stack-brotli-decoder-vulnerability) and vendor release evidence. Reconcile control-plane and data-plane versions; roll the proxy workload itself.
5. If delayed, disable the vulnerable decoding path or stop processing untrusted Brotli data. Removing `br` from `Accept-Encoding` alone is inadequate: a malicious peer can send it anyway. Verify whether your client exposes undecoded bytes before relying on a header check; automatic decoding may happen first. Limit exposed input sources where disabling decoding is impossible.

### PAN-OS

Palo Alto Networks rates CVE-2026-111497 Critical (CVSS 4.0 9.2) but describes a narrower PAN-OS exposure: PA-Series and VM-Series firewalls need TLS/SSL decryption **and** Brotli inspection enabled on the dataplane. The management web/API interface is not affected, and PAN-OS 11.1 and 10.2 are unaffected. On 11.2.4 or later, use `show system setting brotli` (or `show system setting brotli-encoding`) and treat `Enabled: yes` as the configuration prerequisite; on 12.1.2+, the Web UI exposes the same setting at **Device → Setup → Content-ID**.

Install the vendor hotfix for the deployed branch: **12.2.4-h1**; **12.1.4-h13, 12.1.7-h11 or 12.1.10-h3**; or **11.2.4-h23, 11.2.7-h23, 11.2.10-h17, 11.2.13-h4 or 11.2.16-h1**, once the vendor has released it. Vendor-listed ETAs are not an installed fix. Until then, disable the inspection engine with `set system setting brotli-encoding disable`, then verify `show system setting brotli` reports `Enabled: no`. This is a configuration change that can alter traffic inspection; test it with approved traffic and preserve normal change control. Palo Alto reports no known malicious exploitation.

**PHP on Windows:** update the official package itself to **8.2.35-1 / 8.3.36-1 / 8.4.27-1 / 8.5.12-1** or a later vendor-confirmed build. The base PHP runtime number is unchanged from the October 21 PHP2Shell release, so `php -v` alone cannot establish that this Brotli rebuild is installed; use the `-1` package suffix and the PHP download's SHA-256. Restart PHP-FPM, Apache, IIS FastCGI, workers and other processes that loaded the replaced DLLs. This covers the bundled Windows dependency, not a separate extension, libcurl, bundled application library or another PHP deployment.

For the newly documented native consumers:

- **FFmpeg/libjxl:** obtain a supplier build whose actual Brotli dependency includes the fix. A libjxl source bump does not update existing FFmpeg packages or static worker images. If unavailable, pause untrusted JPEG XL/media metadata processing or disable the affected path before parsing; filenames, MIME allowlists and outer HTTP encoding alone cannot identify embedded Brotli. Do not attempt to “sanitize” files by feeding them through the vulnerable parser.
- **ClickHouse:** backports are merged on 26.10, 26.9, 26.8 and 26.3 (2026-10-25/26), but no release containing them was published when reviewed. Track [the merged fix and named backports](https://github.com/ClickHouse/ClickHouse/pull/127419) against [published releases](https://github.com/ClickHouse/ClickHouse/releases) and your supplier's build evidence. JFrog's “no patched release” statement describes publication on 2026-10-25; the independent 2026-10-26 check above still does not establish released backport artifacts. Until a fixed build is deployed, reject Brotli HTTP bodies before any decoder and restrict direct origins, **and** pause untrusted `.br`/Parquet ingestion; HTTP-only controls do not cover files.
- **Arrow/pyarrow:** follow [issue #55166](https://github.com/apache/arrow/issues/55166) and [dependency-update PR #55167](https://github.com/apache/arrow/pull/55167). Use a supplier-verified build linked to patched Brotli or a verified backport; do not invent a fixed wheel version or substitute a `Brotli` package upgrade. If no verified build is available, pause affected untrusted file/buffer processing. Resource/time limits can reduce DoS impact but do not fix the native memory-corruption defect.

**Envoy 1.36 and Istio 1.29 are unsupported:** the listed CVE backport does not restore general support. Prefer supported branches. The [cross-stack guidance](https://patchtheplanet.org/brotli) covers Express/Next.js, Python raw-response handling and proxy controls, plus embedded Electron/native clients and font/file decoding. Inspect those consumers even when no public web server is present.

Disabling an Envoy decompressor can pass encoded bytes onward rather than reject them: protect downstream decoders too. Cover both request and response paths and check runtime overrides that could re-enable a filter. Test the effective configuration, not just the edited template.

Inbound WAF controls do not cover outbound decompression. Do not present process sandboxing or egress restrictions as a substitute for fixing memory corruption, though they can limit consequences.

### Contain before the first decoder

At shared CDN/WAF, reverse-proxy and gateway layers, reject unsupported request encodings **before body processing**. Confirm the control itself uses a patched decoder and that header rules execute first. A layer-4 listener or TLS passthrough cannot inspect HTTP headers. A request eventually returning 401/403 does not prove an earlier parser avoided decoding.

- Request **`Content-Encoding`** describes the incoming body; request **`Accept-Encoding`** only negotiates a response. Response **`Content-Encoding`** describes the returned body. Do not confuse these controls.
- For applications allowing only uncompressed/gzip/deflate input, reject unknown, empty, stacked or ambiguous duplicate encoding fields; explicitly permit only the application's supported encodings. If applying a narrower Brotli-only block, parse every field and comma-separated token case-insensitively. Equality with lowercase `br` misses `BR`, `gzip, br` and duplicate-header cases.
- **Reject; do not strip the header.** Stripping the label does not safely transform the bytes. Cover direct origins, IPv4/IPv6, internal callers, alternate ports, early allow rules and route exceptions.
- For Envoy/Istio, identify the Brotli-specific `envoy.filters.http.decompressor` instance, not every codec using that filter name. Disable both direction configs and remove runtime overrides that could re-enable it, or remove that instance. [Envoy API defaults and options](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/http/decompressor/v3/decompressor.proto) and [Istio EnvoyFilter guidance](https://istio.io/latest/docs/reference/config/networking/envoy-filter/) are the source of truth for your deployed version. Pass-through still leaves downstream decoders exposed.
- For fetched responses, use a patched client or documented decoding-disable option. Raw-response checks must precede all body reads/automatic decoding, including redirects and errors. An HTTPS CONNECT egress tunnel cannot inspect the encrypted response. Domain allowlists do not cover compromised upstreams or fraudulent accepted TLS certificates.
- For .NET, follow the [vendor mitigation](https://github.com/dotnet/announcements/issues/494): remove `br` from **existing** request-decompression configuration and Brotli from **existing** client decompression flags. Do not introduce decompression where previously disabled. This does not cover explicit stream decoders.
- For Rust reqwest, [`.no_brotli()`](https://docs.rs/reqwest/latest/reqwest/struct.ClientBuilder.html#method.no_brotli) disables that client path even if a dependency enabled the feature; this is containment guidance, not a claim that all reqwest builds have the C vulnerability. Other codecs/bindings need their own controls.
- Pause untrusted file/font processing and asynchronous decode jobs if they cannot be patched or safely disabled. An upload WAF rule does not cover later decoding of embedded Brotli data.

After patching, rebuild/redeploy every self-contained, statically linked or NativeAOT artifact and replace all workers. A shared .NET runtime update alone cannot replace a decoder linked into a self-contained/AOT executable. Review the separate [eMudhra trust response](emudhra.md#remediation): accepted fraudulent certificates can undermine assumptions about trusted fetch origins, but the two issues have distinct fixes.

## Verification

- Re-run inventory inside each running replica; retain supplier evidence for custom builds and backports.
- With **benign fixtures**, test inbound compressed requests, outbound compressed responses and the direct decode paths your service actually uses. Include uncompressed controls so a broken middleware chain is not mistaken for successful mitigation.
- Include benign JPEG XL metadata, Brotli-compressed Parquet and direct buffer-decode controls where used; verify the actual FFmpeg/libjxl, ClickHouse or Arrow artifact contains the fix. Test deliberately disabled paths reject inputs before decoding, and normal permitted media/data jobs still complete. Do not replay JFrog's crash/hang inputs.
- Confirm decompression is disabled where intended and the application handles unsupported encoding safely; verify no automatic client/proxy decode occurs before the control.
- Verify the other Node DNS/TLS regression fixes through the vendor release, not by merely observing Brotli works. Review worker/proxy rollouts for stale images.
- In a controlled environment, exercise benign `br`, `BR`, stacked and duplicate encoding headers, malformed values and permitted uncompressed/gzip controls. Confirm **where** rejection occurred using gateway/application logs; a 415 alone does not prove the decoder was bypassed.
- Use a controlled upstream returning benign Brotli even without negotiation to test client policy. Cover each supported protocol, direct-origin path and background consumer. The response-header checker is not a substitute for these application-level controls.

## Compromise response

Isolate suspicious workers, preserve logs and snapshots, and map files, tokens and network access available to the compromised account. Rebuild and revoke reachable credentials from a clean system where execution or theft is suspected. The impact can include process secrets even without a shell. An updated runtime is not evidence that pre-update memory or credentials were never disclosed.

## Sources

- [Node security advisory and downloads](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases)
- [Python/native advisory and affected ranges](https://github.com/advisories/GHSA-9v8h-qqgm-4m35)
- [Google Brotli releases](https://github.com/google/brotli/releases)
- [Bun advisory and compiled-executable guidance](https://github.com/oven-sh/bun/security/advisories/GHSA-663w-cv8g-jj2p)
- [Microsoft .NET advisory and runtime/SDK matrix](https://github.com/dotnet/announcements/issues/494)
- [MSRC CVE-2026-111497](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-111497) — Critical rating; .NET SDK, Visual Studio and PowerShell fixed builds
- [Palo Alto Networks PAN-OS portfolio status](https://security.paloaltonetworks.com/CVE-2026-111497) — applicability, hotfixes, temporary mitigation and exploitation status
- [Alpine security tracker](https://security.alpinelinux.org/vuln/CVE-2026-111497) and [DuckDB PR #27791](https://github.com/duckdb/duckdb/pull/27791)
- [Brotli4j wrapper/native-artifact advisory](https://github.com/hyperxpro/Brotli4j/security/advisories/GHSA-x524-jrqf-vwq6)
- [PHP extension 0.21.1 release](https://github.com/kjdev/php-ext-brotli/releases/tag/0.21.1)
- [PHP Windows Brotli rebuild announcement and downloads](https://www.php.net/archive/2026.php)
- [Ruby maintainer fix confirmation](https://github.com/miyucy/brotli/issues/64)
- [Imperva exploit research and test limits](https://www.imperva.com/blog/node2shell-from-brotli-data-to-remote-code-execution/)
- [ELLIO x86-64 RCE reproduction and 2026-10-26 in-the-wild exploit traffic][ellio]
- [JFrog Brotli2Shell research: native/file paths and demonstrated-impact limits](https://research.jfrog.com/post/brotli2shell-beyond-node2shell-and-http2shell/)
- [JFrog official contextual scanner and limitations](https://github.com/jfrog/vulnerability_scanners/tree/main/brotli2shell_cve_2026_111497)
- [Trail of Bits official Brotli Checker and guidance](https://github.com/trailofbits/brotli-checker)
- [ClickHouse fix/backport tracking](https://github.com/ClickHouse/ClickHouse/pull/127419) and [release records](https://github.com/ClickHouse/ClickHouse/releases)
- [libjxl Brotli dependency update](https://github.com/libjxl/libjxl/pull/5062) and [release records](https://github.com/libjxl/libjxl/releases)
- [Apache Arrow bundled-decoder issue](https://github.com/apache/arrow/issues/55166), [proposed dependency update](https://github.com/apache/arrow/pull/55167) and [release records](https://github.com/apache/arrow/releases)
- [.NET rollout and public-branch tracking](https://github.com/dotnet/runtime/issues/136422)
- [Cross-ecosystem patch reporting](https://thehackernews.com/2026/10/brotli-decoder-flaw-behind-nodejs-rce.html)
- [Cross-stack mitigations and support status](https://patchtheplanet.org/brotli)
[rhbrotli]: https://access.redhat.com/security/cve/CVE-2026-111497
[debbrotli]: https://security-tracker.debian.org/tracker/CVE-2026-111497
[alasbrotli]: https://alas.aws.amazon.com/AL2023/ALAS2023-2026-3334.html
[msrcbrotli]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-111497
[alpinebrotli]: https://security.alpinelinux.org/vuln/CVE-2026-111497
[ellio]: https://ellio.tech/en/blog/node2shell-cve-2026-111497-rce-on-stock-nodejs-builds/
