# Header Accordions: identify HTTP/3 decoders and contain resource exhaustion

**Last updated:** 2026-10-26 (America/New_York)

[Main guide](../black-october-2026.md#9-header-accordions-http3-compression-becomes-resource-exhaustion) · [Changelog](../../CHANGELOG.md)

**Scope:** implementation-specific QPACK/HTTP/3 resource exhaustion, not established RCE. Include HTTP/3 **clients as well as servers** for quic-go, and analyst workstations decoding HTTP/3 captures in Wireshark. The named research groups findings with different disclosure and patch dates. [Research][research] [quic-go advisory][go]

## Timeline

| Component / event | Report date | Public announcement | Fix availability and source |
|---|---|---|---|
| quic-go / CVE-2025-64702 | 2025-11-09 | Advisory 2025-12-11 | **0.57.0**, released 2025-11-21. [Research][research] [Advisory][go] |
| Wireshark / CVE-2025-13945 | 2025-11-14 | Advisory 2025-12-03 | **4.6.2 / 4.4.12** listed by December 3 advisory; research explicitly dates 4.6.2 release December 3. [Research][research] [Advisory][wireshark] |
| Cloudflare quiche / CVE-2026-12523 | 2025-11-15 | Advisory 2026-07-14 | **0.29.3**, released 2026-07-14. [Research][research] [Advisory][quiche] |
| hyperium h3 | 2025-12-04 | In combined research 2026-10-20; earliest separate public date not established | No fixed release as of 2026-10-26; latest `h3` release is 0.0.8 (2025-05-06). December 5, 2025 issue closure was not a shipped fix; new issue #379 and fix PRs #377/#378 (opened 2026-10-22) remain open. [Research][research] [h3 issue][h3issue] |
| Bun (no CVE) | 2026-05-24 | Combined research 2026-10-20; Bun advisory **GHSA-cf8x-9m69-3gg3** 2026-10-24 00:13 UTC | **1.4.4**, GitHub release 2026-10-22 10:11 UTC. Advisory rates it **High** (no CVSS score or CVE published); affected `>= 1.3.14, < 1.4.4`. [Bun advisory][bun] [Release][bunrel] |
| aioquic / mitmproxy | 2026-07-13 | In combined research 2026-10-20; earliest separate public date not established | No verified fixed version as of 2026-10-26: no aioquic commit after 1.7.0 (2026-10-16), and mitmproxy 12.3.0 / 12.3.1 (2026-10-22 / 2026-10-25) changelogs list no HTTP/3 header-limit fix. [Research][research] [mitmproxy changelog][mitmlog] |
| lsquic | 2026-07-13 | Separate public advisory date unknown | **4.9.0**, released 2026-07-15; no CVE in research. [Research][research] |
| Combined “Header Accordions” research | Discovery date unknown | **2026-10-20** | Article’s visible byline/timeline date; fetched metadata saying October 26 is not a new initial-disclosure date. [Research][research] |

Report dates are the researcher’s vendor/project reporting dates; the article does not establish that every report was private. Exact initial discovery/private-report dates beyond those events remain unknown. The fresh read retains a matrix explicitly labeled **“as of October 20”**: it does not prove no project shipped a fix afterward. Bun has since shipped one (1.4.4); the reviewed project sources showed no later fixed release for h3 or aioquic/mitmproxy as of 2026-10-26.

## Detection

### Locate every decoder that untrusted peers can reach

1. Identify where HTTP/3 terminates: CDN, load balancer, reverse proxy, application, or outbound HTTP client. A CDN’s HTTP/3 offering does not imply an HTTP/3 origin.
2. Inventory the actual terminating executable/image and dependency provenance, including embedded libraries and replacement/fork modules. Product names alone do not determine the bundled fix.
3. For trusted Go build tools, from the `black-october` directory, use the existing [stack inventory script](../stack-inventory.sh) to inspect deployed binaries without running those binaries:

```sh
sh stack-inventory.sh go /path/to/deployed-server
```

4. Look for `github.com/quic-go/quic-go` and any replacement. Missing build metadata is inconclusive; obtain the vendor SBOM or build record. Repeat for outbound clients that negotiate HTTP/3.
5. For Rust/quiche/h3, lsquic and Bun, inspect lockfiles **and deployed build/image provenance**; for Python, inspect the environment supplying aioquic/mitmproxy. The companion Python inventory script does not list these packages.
6. Check UDP listeners, load-balancer configuration and HTTP/3 negotiation. `Alt-Svc: h3` is a discovery hint, not proof of vulnerable decoding or of the selected library.

### Component-specific interpretation

| Component | Affected condition / evidence | Action target |
|---|---|---|
| quic-go | **≤0.56.0**, HTTP/3 server **or client**; compressed-size limit alone is insufficient. [Advisory][go] | 0.57.0+ or verified product backport. |
| Cloudflare quiche | Earliest affected 0.1.0; 0.29.3 is first fixed; both frame preallocation and incorrect decoded-size accounting. [Advisory][quiche] | 0.29.3+; not Google’s similarly named QUICHE. |
| lsquic | Research demonstrates missing cumulative/header-set limits in pre-fix implementation. [Research][research] | Product containing 4.9.0+ or verified backport; check custom callbacks too. |
| Bun | Vendor: **`>= 1.3.14, < 1.4.4`**; `Bun.serve` with `http3: true` (off by default) **and** the opt-in HTTP/3 `fetch` client. `bun build --compile` executables embed the runtime. [Bun advisory][bun] | 1.4.4+; rebuild compiled executables with it. |
| aioquic / mitmproxy / h3 | Research lists aioquic 1.7.0, mitmproxy 12.2.3 and h3 0.0.8 test fingerprints, not exhaustive affected ranges. [Research][research] | Confirm later product fix explicitly or use mitigation below. |
| Wireshark | **4.6.0–4.6.1 / 4.4.0–4.4.11**; HTTP/3 dissection when decrypting with a keylog or capture-embedded secrets. [Advisory][wireshark] | 4.6.2 / 4.4.12 or later supported release, including TShark. |

The research found Google QUICHE, IIS and ngtcp2/nghttp3 unaffected in its tests; do not turn that into a universal guarantee for custom applications. In particular, nghttp3’s field-section setting is signaling-only and application enforcement still matters. [Research][research]

### Look for denial-of-service evidence

- Recommended: correlate HTTP/3 connections with RSS growth, cgroup OOM events, restarts, latency, CPU saturation and Rust `HeaderMap` panic messages.
- A large decoded allocation may occur before a normal request is logged. Low request counts or a small wire-byte total do not establish that resource use is benign.
- Published amplification ratios are experimental results for particular stacks/configurations, not universal production thresholds. Neither OOM nor an HTTP 431 response alone proves exploitation.
- The reviewed research does not establish a live attack campaign. Wireshark’s advisory explicitly says it was unaware of exploits at publication. [Research][research] [Wireshark][wireshark]

## Remediation

### Temporary controls when fix status is unknown

- Disable affected HTTP/3 server support at the actual terminator; retain supported HTTP/2 or HTTP/1.1. Remove stale HTTP/3 advertisements **and** stop accepting HTTP/3—removing `Alt-Svc` alone does not block known clients.
- Where appropriate, deny the terminator’s QUIC UDP endpoint at ingress while preserving intended TCP HTTPS. Check alternate ports/addresses; coordinate other UDP users before broad filtering.
- For quic-go clients, disable HTTP/3 in the affected transport until patched; an inbound WAF cannot protect outbound response decoding. [quic-go][go]
- Follow researcher guidance: until upgraded to Bun 1.4.4, **do not expose Bun HTTP/3** (and avoid Bun’s HTTP/3 `fetch` client against untrusted servers, per Bun’s advisory); run mitmproxy with **`--set http3=false`**, and configure a suitably small **`max_field_section_size`** for h3. Validate the effective setting and normal workload rather than assuming every advertised limit is enforced. [Research][research]
- Bound memory, concurrency and restart behavior as impact controls, not cures. A single connection can be sufficient in demonstrated cases; rate limiting alone is not dependable. [Research][research]

### Deploy the fixed implementation

1. Upgrade/rebuild the product against the relevant fixed library and redeploy all terminating replicas and outbound clients; updating an installed compiler or lockfile alone is insufficient.
2. Confirm any vendor backport covers incremental decoded-size accounting and the component’s other finding, such as quiche frame preallocation. Do not copy one generic header-size setting across stacks.
3. For Bun, use **1.4.4 or later**: Bun’s HTTP/3 advisory names 1.4.4 as the fix, which enforces a decoded header-set limit (default 16 KB, `--max-http-header-size`; oversize requests get `431`) and caps HTTP/3 `fetch` response headers at 256 KB. The same release also carries Bun’s separate Brotli fix, but verify against the HTTP/3 advisory rather than inferring coverage from the Brotli advisory, and do not assume upgrading stock lsquic repairs Bun’s custom header callbacks. [Bun advisory][bun] [Research][research]
4. Update analyst Wireshark/TShark installations before opening suspect captures, including workstation packages and analysis containers. Keep capture secrets access-controlled.

## Verification

- Record the running image digest/build and embedded fixed-library version on every edge and client deployment; check loaded processes were replaced.
- Verify ordinary HTTP/3 negotiation and successful benign requests if enabled; if disabled, verify authorized clients fall back to TCP and cannot negotiate HTTP/3 through a bypass route.
- In isolated staging only, use normal application-limit tests to confirm bounded rejection and healthy memory/latency; do not replay published amplification payloads on production.
- Check error metrics, RSS, OOM counts and restart rates under normal traffic after rollout. An enforced limit should not break legitimate authentication/cookie headers.
- Verify Wireshark’s actual installed version via **Help → About** or trusted `tshark --version`; merely removing decryption secrets from one capture does not patch the analyzer.

## Compromise response

- A QPACK-triggered outage alone is **not evidence of stolen credentials or RCE**. Preserve logs/captures and resource metrics, contain traffic, then restore availability using patched or HTTP/3-disabled processes.
- Repeatedly restarting an exposed vulnerable process is not remediation. Investigate lost in-flight work, partial application operations and failover behavior after an OOM/crash.
- Rebuilding an otherwise trusted service is a reliable way to deploy the corrected artifact; a full forensic rebuild or secret rotation needs additional compromise evidence, not merely this DoS finding.
- If independent intrusion evidence exists, isolate and follow the affected service’s incident process; keep packet captures and TLS keylogs restricted because they can contain sensitive data.

## Sources

- [FoxIO research][research] — per-project timeline, mitigation matrix and tested implementation limits.
- [quic-go advisory][go], [Cloudflare quiche advisory][quiche], [Wireshark advisory][wireshark] — exact ranges, public advisory dates and important client/capture scope.
- [Bun advisory GHSA-cf8x-9m69-3gg3][bun] and [Bun 1.4.4 release][bunrel] — Bun affected range, fixed version, client scope and compiled-executable caution.
- [hyperium h3 issue #379][h3issue] and [mitmproxy changelog][mitmlog] — post-October 20 fix status for the remaining stacks.

[bun]: https://github.com/oven-sh/bun/security/advisories/GHSA-cf8x-9m69-3gg3
[bunrel]: https://github.com/oven-sh/bun/releases/tag/bun-v1.4.4
[h3issue]: https://github.com/hyperium/h3/issues/379
[mitmlog]: https://github.com/mitmproxy/mitmproxy/blob/main/CHANGELOG.md
[research]: https://foxio.io/blog/header-accordions-qpack-amplification-attacks-against-http-3-servers
[go]: https://github.com/quic-go/quic-go/security/advisories/GHSA-g754-hx8w-x2g6
[quiche]: https://github.com/cloudflare/quiche/security/advisories/GHSA-4fgf-9xrr-88gf
[wireshark]: https://www.wireshark.org/security/wnpa-sec-2025-07.html
