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
| Python package availability | 2026-10-22: first PyPI uploads of [Brotli 1.2.1](https://pypi.org/project/Brotli/1.2.1/) at 13:57 UTC and [brotlicffi 1.2.1.0](https://pypi.org/project/brotlicffi/1.2.1.0/) at 16:19 UTC |
| Envoy downstream fix/advisory | 2026-10-06: [1.39.3 release](https://github.com/envoyproxy/envoy/releases/tag/v1.39.3); [advisory published 2026-10-23](https://github.com/envoyproxy/envoy/security/advisories/GHSA-3wvj-j6qm-62mr). Other branch artifact dates are not established here |
| Istio downstream fixes | [Bulletin ISTIO-SECURITY-2026-007](https://istio.io/latest/news/security/istio-security-2026-007/) dated 2026-10-15; corresponding GitHub release timestamps are 2026-10-16 UTC. Downstream release dates need not match the later Node disclosure |

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

### Operational signals and evidence limits

Investigate decompression-associated crashes, unusual child processes, unexpected outbound traffic or modified service files. Correlate request/job IDs with the remote data source and EDR/coredump evidence. A malformed stream rejection can be benign and a successful compromise need not produce a logged error. Do not fetch a suspected malicious response again on production just to reproduce it.

### Other Node DNS and TLS issues

The same Node update fixes **CVE-2026-105482** (DNS NUL truncation), **CVE-2026-105483** (fullwidth-digit IP identity validation, Node 24/26), and **CVE-2026-106069** (resolver/validator disagreement over noncanonical IPs). Trace user-controlled hosts into DNS allowlists and TLS connections independently of Brotli. Keep canonicalized validation and the actual destination consistent; do not disable TLS certificate verification as a workaround. Their public announcement/fix date is 2026-10-21; private discovery dates are not established here.

## Remediation

1. Node: replace/rebuild the deployed runtime with **22.23.4 / 24.22.1 / 26.12.1** or later supported fixes. Bun: **1.4.4** or later. Updating an npm application dependency alone is insufficient.
2. Python: update the locked artifacts for **Brotli 1.2.1** and/or **brotlicffi 1.2.1.0** as applicable, rebuild worker images and restart processes. Inspect dependency resolver constraints; do not leave a second environment unchanged.
3. Native consumers: obtain a build containing the fix from the supplier. The C library has branch fixes **1.0.10 / 1.1.1 / 1.2.1**. Do not use a simple cross-branch “version greater than 1.0.10” test.
4. Envoy/Istio: update to a supplier-supported release containing the fix; use the [main patch matrix](../black-october-2026.md#2-http2shell--node2shell-a-cross-stack-brotli-decoder-vulnerability) and vendor release evidence. Reconcile control-plane and data-plane versions; roll the proxy workload itself.
5. If delayed, disable the vulnerable decoding path or stop processing untrusted Brotli data. Removing `br` from `Accept-Encoding` alone is inadequate: a malicious peer can send it anyway. Verify whether your client exposes undecoded bytes before relying on a header check; automatic decoding may happen first. Limit exposed input sources where disabling decoding is impossible.

**Envoy 1.36 and Istio 1.29 are unsupported:** the listed CVE backport does not restore general support. Prefer supported branches. The [cross-stack guidance](https://patchtheplanet.org/brotli) covers Express/Next.js, Python raw-response handling and proxy controls, plus embedded Electron/native clients and font/file decoding. Inspect those consumers even when no public web server is present.

Disabling an Envoy decompressor can pass encoded bytes onward rather than reject them: protect downstream decoders too. Cover both request and response paths and check runtime overrides that could re-enable a filter. Test the effective configuration, not just the edited template.

Inbound WAF controls do not cover outbound decompression. Do not present process sandboxing or egress restrictions as a substitute for fixing memory corruption, though they can limit consequences.

## Verification

- Re-run inventory inside each running replica; retain supplier evidence for custom builds and backports.
- With **benign fixtures**, test inbound compressed requests, outbound compressed responses and the direct decode paths your service actually uses. Include uncompressed controls so a broken middleware chain is not mistaken for successful mitigation.
- Confirm decompression is disabled where intended and the application handles unsupported encoding safely; verify no automatic client/proxy decode occurs before the control.
- Verify the other Node DNS/TLS regression fixes through the vendor release, not by merely observing Brotli works. Review worker/proxy rollouts for stale images.

## Compromise response

Isolate suspicious workers, preserve logs and snapshots, and map files, tokens and network access available to the compromised account. Rebuild and revoke reachable credentials from a clean system where execution or theft is suspected. The impact can include process secrets even without a shell. An updated runtime is not evidence that pre-update memory or credentials were never disclosed.

## Sources

- [Node security advisory and downloads](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases)
- [Python/native advisory and affected ranges](https://github.com/advisories/GHSA-9v8h-qqgm-4m35)
- [Google Brotli releases](https://github.com/google/brotli/releases)
- [Imperva exploit research and test limits](https://www.imperva.com/blog/node2shell-from-brotli-data-to-remote-code-execution/)
- [Cross-ecosystem patch reporting](https://thehackernews.com/2026/10/brotli-decoder-flaw-behind-nodejs-rce.html)
- [Cross-stack mitigations and support status](https://patchtheplanet.org/brotli)
