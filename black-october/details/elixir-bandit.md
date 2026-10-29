# Bandit (Elixir and Phoenix web server): unauthenticated denial of service over HTTP/2, HTTP/1.1 and WebSocket

**Last updated:** 2026-10-28 (America/New_York)

[Main Bandit summary](../black-october-2026.md#bandit-elixir-and-phoenix-web-server-unauthenticated-denial-of-service-over-http2-http11-and-websocket) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Eleven High advisories: ten CVEs scored by the Erlang Ecosystem Foundation (EEF, CNA) at CVSS 4.0 8.7 High, except one at 8.2 High, plus one High GitHub advisory with no CVE. Two further Medium (6.3) CVEs were published alongside them. NVD has not scored them (status "Received"); not in CISA KEV.** [Bandit](https://github.com/mtrudel/bandit) is the pure-Elixir HTTP server that new Phoenix applications use by default (since Phoenix 1.7.11), and that Plug applications can run directly. On 2026-10-26 its maintainers published twelve GitHub security advisories, fixed in **Bandit 1.14.0**. On 2026-10-28, a thirteenth advisory added a separate HTTP/2 request-body memory-exhaustion path fixed in **1.14.1**. The High flaws let a **remote, unauthenticated** client exhaust memory or CPU on the BEAM node with small amounts of traffic. [Advisories][advisories] [1.14.0 changelog][changelog] [CVE-2026-116078 advisory][a116078] [Phoenix 1.7.11 changelog][phoenix]

**Worst case:** one client with little bandwidth takes the BEAM node out of memory or keeps every scheduler busy. That stops **every application on the node**, not just the HTTP listener, including LiveView and Channels sessions. The advisories describe denial of service only. The two Medium CVEs are different: [CVE-2026-114216](https://www.cve.org/CVERecord?id=CVE-2026-114216) is request smuggling behind certain proxies, and [CVE-2026-110314](https://www.cve.org/CVERecord?id=CVE-2026-110314) lets a WebSocket client keep invoking handlers after the server closed the session. [Advisories][advisories]

**CISA KEV:** Not listed (catalog 2026.10.28, checked 2026-10-28); none of the twelve CVEs below is in the feed, and GHSA-fmr8-qrvr-4ww5 has no CVE, so KEV cannot list it. CISA's ADP SSVC enrichment marks Exploitation "none" on the ten earlier records that carry it (all except CVE-2026-110314). Several advisories include proof-of-concept code, but no exploitation was reported in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Advisories and scores](#advisories-and-scores)
- [Detection](#detection)
  - [Inventory](#inventory)
  - [Reachability](#reachability)
  - [Runtime signals](#runtime-signals)
- [Remediation](#remediation)
  - [Upgrade to 1.14.1](#upgrade-to-1141)
  - [Workarounds until you can upgrade](#workarounds-until-you-can-upgrade)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/reports | Unknown; GHSA-fmr8-qrvr-4ww5 measurements dated 2026-10-22 | Reporters credited: PJUllrich (most advisories), neilberkman (GHSA-fmr8-qrvr-4ww5 and co-credited on CVE-2026-109584 and CVE-2026-111103), manus-pi (credited in the changelog for CVE-2026-115269 and CVE-2026-108525). CVE-2026-108525 was reserved 2026-10-15 10:45:02 UTC. [Advisories][advisories] [Changelog][changelog] [CVE-2026-108525 JSON][cve108525] |
| Bandit 1.14.0 published on Hex | 2026-10-26 13:12:37 UTC | Fixed release; changelog dated 26 Oct 2026. [Hex][hex] [Changelog][changelog] |
| CVE records published | 2026-10-26 13:29:42–13:35:26 UTC | EEF CNA; CVE-2026-108525 first, CVE-2026-108529 last. [CVE JSON][cve108525] |
| **Public announcement**: GitHub advisories published | 2026-10-26 13:35:21–13:35:41 UTC | Twelve advisories. [Advisories][advisories] |
| NVD | 2026-10-26 from 14:16 UTC (NVD API) | Status "Received"; shows the EEF CVSS 4.0 scores. [NVD][nvd] |
| CISA ADP SSVC | 2026-10-26 | Exploitation: none; Automatable: yes; Technical impact: partial. [CVE JSON][cve108525] |
| CISA KEV | Not listed as of catalog 2026.10.28 (checked 2026-10-28) | [KEV JSON][kev] |

Earlier Bandit advisories (for example the May 2026 WebSocket and chunked-encoding flaws fixed in 1.11.x, and [CVE-2026-105659](https://www.cve.org/CVERecord?id=CVE-2026-105659), 8.7, advisory published 2026-10-12 and fixed in 1.13.0, released 2026-10-15) are not tracked here; 1.14.0 includes their fixes.

## Advisories and scores

All scores are **EEF (CNA) CVSS 4.0** from the CVE records, matching the GitHub advisories. The High vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:H/SC:N/SI:N/SA:N` (8.7) unless noted. The original batch is fixed in **1.14.0**; CVE-2026-116078 is fixed in **1.14.1**. [Advisories][advisories] [CVE records][cve108525]

| CVE / advisory | What a client does | Score | Protocol | Affected | Published workaround |
|---|---|---|---|---|---|
| [CVE-2026-116078](https://www.cve.org/CVERecord?id=CVE-2026-116078) / [GHSA-pxjf-g536-7r93][a116078] | Sends many 1-byte DATA frames to request-body readers; each frame is retained as a separate list element, so memory grows roughly 5–8× the payload | 8.7 High | HTTP/2 | 0.3.1 to <1.14.1 | Disable HTTP/2 |
| [CVE-2026-108525](https://www.cve.org/CVERecord?id=CVE-2026-108525) / [GHSA-c3g7-2pg5-qvwh][a108525] | Floods DATA frames past the receive window on a stream stalled on a large response; frames queue in the stream mailbox until the node runs out of memory | 8.7 High | HTTP/2 | 0.3.1 to <1.14.0 | Disable HTTP/2 |
| [CVE-2026-108529](https://www.cve.org/CVERecord?id=CVE-2026-108529) / [GHSA-j363-h72p-296m][a108529] | Holds thousands of response streams blocked, then sends 9-byte SETTINGS or connection WINDOW_UPDATE frames that each cost quadratic CPU | 8.7 High | HTTP/2 | GHSA: 0.3.6 to <1.14.0; **CVE record: 0.3.4 to <1.14.0** | None published |
| [CVE-2026-109584](https://www.cve.org/CVERecord?id=CVE-2026-109584) / [GHSA-7gfj-7gvq-3xqj][a109584] | HPACK "cookie bomb": a 49 KB header block made the server build a 183 MB cookie value (compression amplification, CWE-409) | 8.7 High | HTTP/2 | 0.3.3 to <1.14.0 | On 1.12.2+, set `max_header_list_size` (e.g. 65,536); or disable HTTP/2 |
| [CVE-2026-110499](https://www.cve.org/CVERecord?id=CVE-2026-110499) / [GHSA-47x4-3fxf-82fr][a110499] | Advertises a 4 GB HPACK table size; the server's encoder table then grows with every response and each lookup gets slower (O(N²)) | 8.7 High | HTTP/2 | 0.3.6 to <1.14.0 | From 0.7.0, cap `max_requests` per HTTP/2 connection; or disable HTTP/2 |
| [CVE-2026-111101](https://www.cve.org/CVERecord?id=CVE-2026-111101) / [GHSA-jwh3-j29h-qfmw][a111101] | Sends a chunked body of 1-byte chunks; 1 MB of payload held about 48 MB, even if the route never reads the body | 8.7 High | HTTP/1.1 | 0.1.0 to <1.14.0 | From 0.7.0, disable HTTP/1 if every client and proxy speaks HTTP/2 |
| [CVE-2026-111103](https://www.cve.org/CVERecord?id=CVE-2026-111103) / [GHSA-2238-pgfc-w82m][a111103] | Puts a stream error in a batch of frames so the connection state rolls back and `max_concurrent_streams`, `max_requests` and the rapid-reset limiter miss streams | **8.2 High** (`AT:P`) | HTTP/2 | 1.9.0 to <1.14.0 | Disable HTTP/2 |
| [CVE-2026-113436](https://www.cve.org/CVERecord?id=CVE-2026-113436) / [GHSA-29cr-8477-rg6r][a113436] | Sends a `content-length` or Host/`:authority` port with thousands of digits; parsing is quadratic, and HPACK lets it be resent for about one byte (124 KB kept a server busy 27.9 s) | 8.7 High | HTTP/1.1 and HTTP/2 | 1.0.0-pre.7 to <1.14.0 | None published |
| [CVE-2026-114213](https://www.cve.org/CVERecord?id=CVE-2026-114213) / [GHSA-cpx7-qf6w-jc63][a114213] | Sends a fragmented WebSocket message as 1-byte continuation frames; memory reaches about 150× `max_fragmented_message_size` (about 1.2–1.4 GB at the 8 MB default) | 8.7 High | WebSocket | 1.11.0 to <1.14.0 | Lower `max_fragmented_message_size` (reduces, does not remove) |
| [CVE-2026-115269](https://www.cve.org/CVERecord?id=CVE-2026-115269) / [GHSA-p2qv-vx88-385x][a115269] | Sends a 9-byte WINDOW_UPDATE or empty SETTINGS before each read timeout, so a request-body read never times out | 8.7 High | HTTP/2 | 1.4.0 to <1.14.0 | Disable HTTP/2 |
| No CVE / [GHSA-fmr8-qrvr-4ww5][afmr8] | Opens unlimited concurrent streams on one connection (default `max_concurrent_streams` was unlimited); 20,000 streams took memory from 73 to 320 MiB | GitHub advisory: CVSS 4.0 8.7 High (the advisory text quotes the reporter's CVSS 3.1 7.5) | HTTP/2 | 0.3.0 to <1.14.0 | Set `max_concurrent_streams`, but this can be bypassed via CVE-2026-111103 before 1.14.0 |
| [CVE-2026-114216](https://www.cve.org/CVERecord?id=CVE-2026-114216) / [GHSA-w5wc-g2hc-g7m2][a114216] | Request smuggling via bare LF/CR in chunk extensions, only behind a proxy that treats bare LF as a line ending | 6.3 Medium (below this guide's threshold) | HTTP/1.1 | 1.12.4 to <1.14.0 | Use HTTP/2 between proxy and Bandit |
| [CVE-2026-110314](https://www.cve.org/CVERecord?id=CVE-2026-110314) / [GHSA-2v5v-8f9v-xh85][a110314] | Ignores the server's WebSocket Close and keeps sending frames that still reach the WebSock handler, bypassing a refusal in `init/1` or a kick/ban | 6.3 Medium (below this guide's threshold) | WebSocket | 0.5.1 to <1.14.0 | Mark state as stopped and ignore later frames in the WebSock |

**Range discrepancy:** for CVE-2026-108529, the GitHub advisory and its text say "from 0.3.6", but the CVE record lists 0.3.4. Both put every 1.x release below 1.14.0 in range, so the difference matters only for 0.3.x. [GHSA-j363-h72p-296m][a108529] [CVE JSON][cve108529]

**Default-value discrepancy:** GHSA-fmr8-qrvr-4ww5 describes the reporter's proposed patch defaulting `max_concurrent_streams` to 100. The shipped 1.14.0 changelog and documentation give a default of **500**, with a default `max_header_list_size` of 262,144 bytes. [GHSA-fmr8-qrvr-4ww5][afmr8] [Changelog][changelog] [Bandit options][options]

## Detection

### Inventory

1. Find every Elixir application that depends on Bandit, directly or through Phoenix. Read-only checks:
   - Source tree: `grep -A1 '"bandit"' mix.lock` shows the locked version; `grep -rn 'Bandit' config/ lib/ mix.exs` shows whether the Phoenix endpoint uses `adapter: Bandit.PhoenixAdapter` or a supervisor starts `{Bandit, ...}`.
   - Built release: `ls _build/prod/rel/*/lib | grep bandit` or, on the deployed host, `ls /path/to/release/lib | grep bandit` (directory name `bandit-<version>`).
   - Running node, if you already use remote shells: `bin/<app> rpc 'IO.puts(Application.spec(:bandit, :vsn))'`. It only reads application metadata.
2. Anything below **1.14.1** is affected by CVE-2026-116078 when it accepts HTTP/2 request bodies. Anything below 1.14.0 is also affected by at least CVE-2026-111101, CVE-2026-113436 and the earlier HTTP/2 flaws. Which others apply depends on the version (see the table).
3. Phoenix applications generated before 1.7.11, or configured with `Phoenix.Endpoint.Cowboy2Adapter`, use Cowboy instead and are **not** affected by these Bandit advisories. Check the endpoint's `adapter:` setting rather than the Phoenix version. [Phoenix 1.7.11 changelog][phoenix]

### Reachability

- **HTTP/2** is enabled by default (`http_2_options: [enabled: true]`). Bandit offers it through ALPN over TLS, and the advisories' proofs of concept also use cleartext HTTP/2 with prior knowledge. If Bandit is reachable only through a proxy or load balancer that speaks **HTTP/1.1** to it, outside clients cannot send HTTP/2 frames to Bandit directly. Check the proxy's upstream protocol: some load balancers can use HTTP/2 or gRPC to targets, and direct exposure of the Bandit port (including internal networks) bypasses the proxy. [Bandit options][options]
- **HTTP/1.1 flaws** (CVE-2026-111101, CVE-2026-113436): a proxy may forward chunked bodies and header values unchanged or may normalize them. Unless you have verified that your proxy re-frames chunked bodies and rejects oversized `content-length`/Host values, treat these as reachable.
- **WebSocket** (CVE-2026-114213, CVE-2026-110314): proxies pass WebSocket frames through, so any public LiveView, Channels or WebSock endpoint is reachable.
- Everything here is pre-authentication. A login page or API key does not protect the server from these flaws.

### Runtime signals

The advisories publish no indicators of compromise. Signals of possible abuse are:

- Sudden BEAM memory growth, OOM kills or container restarts, and scheduler utilisation near 100% with low request rates, in your metrics (for example `:erlang.memory/0`, Telemetry, LiveDashboard or container metrics).
- One client IP holding very long-lived HTTP/2 connections with thousands of streams, or WebSocket connections that receive many tiny frames, in load balancer or proxy logs.
- Requests with very long numeric `content-length` or Host port values, or chunked bodies with very many tiny chunks, if a proxy or WAF logs such details.

Missing signals do not mean the service was not targeted; most deployments do not log HTTP/2 frame-level detail.

## Remediation

### Upgrade to 1.14.1

1. Set `{:bandit, "~> 1.14"}` (or at least `>= 1.14.1`) in `mix.exs`, run `mix deps.update bandit`, and confirm `mix.lock` shows 1.14.1 or later. 1.14.0 keeps 1.13.1's Elixir (~> 1.13), Thousand Island (~> 1.6) and HPAX (~> 1.1) requirements; 1.14.1 is required for CVE-2026-116078. There is no backport to older 1.x or 0.x lines. [CVE-2026-116078 advisory][a116078] [Changelog][changelog]
2. Rebuild the release or container image and redeploy every node. A running BEAM keeps the old code until restarted (or until a hot upgrade that you have tested).
3. **Behaviour changes to test** (from the changelog): HTTP/2 now advertises `max_concurrent_streams` 500 and `max_header_list_size` 262,144 bytes by default, so applications that send very large headers (big cookies or JWTs) may see stream resets. `read_body` over HTTP/2 may return more than `:length` bytes. HTTP/1 request-line parsing is stricter: an absolute-form target with an empty path and a query now gets 400. A server-initiated WebSocket close now closes the connection after a timeout. [Changelog][changelog]

### Workarounds until you can upgrade

These are the advisories' own workarounds. Set them in the Bandit options, which for Phoenix are the `http:` / `https:` keyword lists of the endpoint configuration. [Phoenix adapter][phoenixadapter] [Advisories][advisories]

- **Disable HTTP/2** with `http_2_options: [enabled: false]`. This removes the paths of CVE-2026-116078, -108525, -111103, -115269, -109584 and -110499 and GHSA-fmr8-qrvr-4ww5, and the HTTP/2 route to CVE-2026-113436. CVE-2026-108529 also needs HTTP/2, so this removes it too, although its advisory does not list a workaround. Clients fall back to HTTP/1.1.
- Short of disabling HTTP/2: `http_2_options: [max_requests: 1000, default_local_settings: [max_concurrent_streams: 100, max_header_list_size: 65_536]]` limits CVE-2026-110499 and CVE-2026-109584 and caps streams. Before 1.14.0, CVE-2026-111103 can bypass the stream and request limits. `max_header_list_size` needs 1.12.2+ and `max_requests` 0.7.0+.
- Lower `websocket_options: [max_fragmented_message_size: 65_536]`, or the largest message you need, to shrink CVE-2026-114213's memory ceiling (about 150× the limit).
- **No configuration workaround** exists for CVE-2026-111101 on servers that must accept HTTP/1.1, or for CVE-2026-113436. Rate-limit connections per client at the edge and set memory limits so one node's exhaustion does not cascade, but upgrade.

Changing protocol settings **changes behaviour**; deploy them like any configuration change and confirm clients still connect.

## Verification

- Confirm every deployed release contains `lib/bandit-1.14.1` (or later), or that `Application.spec(:bandit, :vsn)` on the running node returns 1.14.1+.
- Benign functional controls: confirm HTTP/1.1 and HTTP/2 requests succeed, for example `curl -sI --http2 https://your-host/` and `curl -sI --http1.1 https://your-host/`, check `curl -v` output for the negotiated protocol, and confirm LiveView or Channels pages connect.
- If you kept a workaround such as disabling HTTP/2, confirm with `curl -v --http2` that ALPN no longer negotiates `h2`.
- Do not run the advisories' proof-of-concept code against production; it is designed to exhaust the node.

## Compromise response

These flaws cause denial of service; none of the advisories describes code execution or data access. After an incident:

- Preserve load balancer, proxy and application logs and node metrics from the outage window to identify source addresses, then block or rate-limit them at the edge.
- Check for crash-looping nodes and for knock-on effects, such as stalled background jobs or lost in-memory state (sessions, PubSub, caches), on the same BEAM node.
- If you rely on WebSock `{:stop, ...}` for authorization (CVE-2026-110314), review what refused or kicked clients could have done before the connection finally closed.
- If Bandit runs behind a proxy that accepts bare LF line endings (CVE-2026-114216), review proxy and application logs for requests the application saw that the proxy did not log.

## Sources

- [Bandit security advisories][advisories] — all thirteen advisories: descriptions, PoCs, affected ranges, CVSS 4.0 vectors, workarounds, credits and publication times. Individual advisories are linked in the [table](#advisories-and-scores).
- [EEF CNA CVE records][cve108525] (one per CVE, e.g. [CVE-2026-108529 JSON][cve108529]) — CVSS 4.0 scores, affected ranges, publication times, CISA ADP SSVC.
- [NVD][nvd] — status "Received".
- [Bandit 1.14.0 changelog][changelog], [Hex release][hex], [mix.exs][mixexs], [Bandit options][options], [Phoenix adapter docs][phoenixadapter].
- [Phoenix 1.7.11 changelog][phoenix] — Bandit becomes the default for new applications.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.28).

[advisories]: https://github.com/mtrudel/bandit/security/advisories
[a116078]: https://github.com/mtrudel/bandit/security/advisories/GHSA-pxjf-g536-7r93
[a108525]: https://github.com/mtrudel/bandit/security/advisories/GHSA-c3g7-2pg5-qvwh
[a108529]: https://github.com/mtrudel/bandit/security/advisories/GHSA-j363-h72p-296m
[a109584]: https://github.com/mtrudel/bandit/security/advisories/GHSA-7gfj-7gvq-3xqj
[a110499]: https://github.com/mtrudel/bandit/security/advisories/GHSA-47x4-3fxf-82fr
[a111101]: https://github.com/mtrudel/bandit/security/advisories/GHSA-jwh3-j29h-qfmw
[a111103]: https://github.com/mtrudel/bandit/security/advisories/GHSA-2238-pgfc-w82m
[a113436]: https://github.com/mtrudel/bandit/security/advisories/GHSA-29cr-8477-rg6r
[a114213]: https://github.com/mtrudel/bandit/security/advisories/GHSA-cpx7-qf6w-jc63
[a115269]: https://github.com/mtrudel/bandit/security/advisories/GHSA-p2qv-vx88-385x
[afmr8]: https://github.com/mtrudel/bandit/security/advisories/GHSA-fmr8-qrvr-4ww5
[a114216]: https://github.com/mtrudel/bandit/security/advisories/GHSA-w5wc-g2hc-g7m2
[a110314]: https://github.com/mtrudel/bandit/security/advisories/GHSA-2v5v-8f9v-xh85
[cve108525]: https://cveawg.mitre.org/api/cve/CVE-2026-108525
[cve108529]: https://cveawg.mitre.org/api/cve/CVE-2026-108529
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-108525
[changelog]: https://github.com/mtrudel/bandit/blob/1.14.0/CHANGELOG.md
[hex]: https://hex.pm/packages/bandit/1.14.0
[mixexs]: https://github.com/mtrudel/bandit/blob/1.14.0/mix.exs
[options]: https://hexdocs.pm/bandit/1.14.0/Bandit.html
[phoenixadapter]: https://hexdocs.pm/bandit/1.14.0/Bandit.PhoenixAdapter.html
[phoenix]: https://github.com/phoenixframework/phoenix/blob/v1.7.11/CHANGELOG.md
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
