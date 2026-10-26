# HTTP2Shell / Node2Shell: detection and remediation

**Last updated:** 2026-10-26 (America/New_York)

[Main Brotli summary and patch matrix](../black-october-2026.md#2-http2shell--node2shell-a-cross-stack-brotli-decoder-vulnerability) · [Changelog](../../CHANGELOG.md)

**CVE-2026-111497** is one cross-stack Brotli decoder bug with two nicknames. Node rates it High; the Google/CNA CVSS 4.0 rating is **9.2 Critical**. Malformed compressed data can corrupt process memory, causing disclosure, crashes or RCE. It is not an HTTP/2-specific defect and does not require a public inbound HTTP endpoint.

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
| .NET fixes and advisory | 2026-10-25, time/TZ unknown: [Microsoft advisory](https://github.com/dotnet/announcements/issues/494), runtimes 8.0.33 / 9.0.22 / 10.0.14 and preview 11.0.0-rc.3.26522.148. Supersedes earlier reports that no fixed .NET release was established |

## Detection

### Map every decoder and input source

Inventory runtime-native libraries, Python wheels, Envoy/Istio proxies and other bundled C Brotli consumers. Record the deployed image digest and package/build, which party supplies it, and where it decodes untrusted data.

| Path | What to inspect |
|---|---|
| Inbound request body | Middleware/decompressor enabled for `Content-Encoding: br`; do not assume Node's plain HTTP server automatically decodes it |
| Outbound response | `fetch`/HTTP clients, crawlers, preview generators, webhooks and import workers that automatically decode an attacker-controlled response |
| Direct library call | `node:zlib` Brotli decompression or native/Python decode calls accepting uploaded/fetched bytes |
| Proxy/service mesh | Effective request **and response** decompressor filters; the app runtime and proxy are separate patch targets |

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
| C# / .NET | `dotnet --list-runtimes`; inspect application runtime configuration, `BrotliStream`/`BrotliDecoder`, request-decompression middleware and HTTP-client `AutomaticDecompression`. Include containers, self-contained apps and NativeAOT | **8.0.33 / 9.0.22 / 10.0.14**; preview **11.0.0-rc.3.26522.148**. Earlier releases within the advisory's listed branches are affected. Microsoft rates its impact **8.1 High (CVSS 3.1)**; request/client decompression is not enabled by default. .NET Framework is excluded by this advisory; assess third-party codecs separately |
| PHP | `php --ri brotli`, `php --ri curl`; inspect PHP-FPM/SAPI separately. Guzzle and libcurl-backed clients can decode responses independently of the extension | **php-ext-brotli 0.21.1** bundles fixed Brotli; **0.21.0** bundled 1.2.0. Patch libcurl's actual decoder separately. A PHP runtime version alone is not a decoder verdict |
| Ruby | Inspect `Gemfile.lock`, native extensions, HTTPX Brotli plugin and curl-backed clients. Standard `Net::HTTP` is not itself a Brotli codec | **brotli gem 0.9.1+**, not every 0.9.x release; 0.9.0 bundled 1.2.0. Rebuild native extensions and separately patch libcurl |
| Go | `go version -m /path/to/binary`, module graph/SBOM and cgo linkage. Brotli is not in the standard library | [andybalholm/brotli **1.2.7**](https://github.com/andybalholm/brotli/issues/82) includes the analogous invalid-stream fix; this does not establish native C RCE in pure Go. Verify the underlying library for cgo and rebuild binaries |
| Rust | `Cargo.lock`, `cargo tree -e features`, native/FFI dependencies and embedded decoder sources; Brotli is not in the standard library | Patch the actual native implementation or follow the pure-Rust project's advisory. No universal Rust crate fixed version is established here; memory-safety and algorithmic findings must not be conflated |
| curl/libcurl, appliances, proxies | `curl --version`, deployed SBOM and vendor build records; record dynamic versus static/bundled libraries | Google library fixes **1.0.10 / 1.1.1 / 1.2.1** or a verified backport. Update/rebuild the owning package. The curl CLI can differ from libcurl loaded by an app |

Use supported runtime branches; an old runtime is not a mitigation. In particular, older Node lines can contain the affected decoder, even when omitted from supported-release advisories. Vendor/distribution support and backports must be checked separately; a compatible extension fix does not restore support to an EOL interpreter. Scala.js/Native deployments inherit their actual JavaScript/native decoder risks, not automatically the JVM conclusions.

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

### Other Node DNS and TLS issues

The same Node update fixes **CVE-2026-105482** (DNS NUL truncation), **CVE-2026-105483** (fullwidth-digit IP identity validation, Node 24/26), and **CVE-2026-106069** (resolver/validator disagreement over noncanonical IPs). Trace user-controlled hosts into DNS allowlists and TLS connections independently of Brotli. Keep canonicalized validation and the actual destination consistent; do not disable TLS certificate verification as a workaround. Their public announcement/fix date is 2026-10-21; private discovery dates are not established here.

## Remediation

1. Node: replace/rebuild the deployed runtime with **22.23.4 / 24.22.1 / 26.12.1** or later supported fixes. Bun: **1.4.4** or later. Updating an npm application dependency alone is insufficient.
   Rebuild `bun build --compile` executables too: they embed the runtime. Bun's [vendor advisory](https://github.com/oven-sh/bun/security/advisories/GHSA-663w-cv8g-jj2p) identifies per-request `fetch` option `decompress: false` as containment for that fetch only, not a process-wide workaround or protection for other Brotli APIs.
2. Python: update the locked artifacts for **Brotli 1.2.1** and/or **brotlicffi 1.2.1.0** as applicable, rebuild worker images and restart processes. Inspect dependency resolver constraints; do not leave a second environment unchanged.
3. Native consumers: obtain a build containing the fix from the supplier. The C library has branch fixes **1.0.10 / 1.1.1 / 1.2.1**. Do not use a simple cross-branch “version greater than 1.0.10” test.
4. Envoy/Istio: update to a supplier-supported release containing the fix; use the [main patch matrix](../black-october-2026.md#2-http2shell--node2shell-a-cross-stack-brotli-decoder-vulnerability) and vendor release evidence. Reconcile control-plane and data-plane versions; roll the proxy workload itself.
5. If delayed, disable the vulnerable decoding path or stop processing untrusted Brotli data. Removing `br` from `Accept-Encoding` alone is inadequate: a malicious peer can send it anyway. Verify whether your client exposes undecoded bytes before relying on a header check; automatic decoding may happen first. Limit exposed input sources where disabling decoding is impossible.

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
- [Brotli4j wrapper/native-artifact advisory](https://github.com/hyperxpro/Brotli4j/security/advisories/GHSA-x524-jrqf-vwq6)
- [PHP extension 0.21.1 release](https://github.com/kjdev/php-ext-brotli/releases/tag/0.21.1)
- [Ruby maintainer fix confirmation](https://github.com/miyucy/brotli/issues/64)
- [Imperva exploit research and test limits](https://www.imperva.com/blog/node2shell-from-brotli-data-to-remote-code-execution/)
- [Cross-ecosystem patch reporting](https://thehackernews.com/2026/10/brotli-decoder-flaw-behind-nodejs-rce.html)
- [Cross-stack mitigations and support status](https://patchtheplanet.org/brotli)
