# llama.cpp: an RPC peer writes below a buffer

**Last updated:** 2026-11-26 (America/New_York)

[Main guide](../black-october-2026.md#llamacpp-an-rpc-peer-writes-below-a-buffer)

**VulnCheck rates [CVE-2026-137567](https://www.cve.org/CVERecord?id=CVE-2026-137567) CVSS 3.1 9.8 Critical and CVSS 4.0 9.3.** The vectors are `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H` and `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The weakness is CWE-787, an out-of-bounds write, in the ggml RPC server. A peer that can open the port learns a buffer's address with `BUFFER_GET_BASE`, then sends `RPC_CMD_COPY_TENSOR` with a destination that has no elements and a pointer below that buffer. The copy then writes a heap address the peer chose. VulnCheck says that can crash the server or run code. The RPC protocol has no login. Builds **b11450 before b12658** are affected. The project does not score it. ggml-org's [RPC README](https://github.com/ggml-org/llama.cpp/blob/master/tools/rpc/README.md) says the backend is a proof of concept, fragile and insecure, and says never to run the RPC server on an open network or in a sensitive environment. The default bind is `127.0.0.1:50052`. Binding anywhere else prints a warning that the feature is not secure. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix released | 2026-11-24 00:56:59 UTC | b12658. Pull request 32651. The release note does not name a CVE. [b12658][b12658] |
| **Public announcement** | **2026-11-26; time/TZ unknown** | VulnCheck published CVE-2026-137567. CVSS 3.1 9.8 and CVSS 4.0 9.3. [CVE][cve] |
| **Last updated** | **2026-11-26 (America/New_York)** | New item. Update an RPC worker to b12658. |

## Detection

An install that does not run `ggml-rpc-server` is outside this flaw. The RPC backend is off unless the build used `-DGGML_RPC=ON`. Read the startup line: it prints `endpoint` and the version. **b11450 before b12658** is inside the range the record names. A worker whose endpoint is not `127.0.0.1` is reachable by whatever can route to port 50052, which is the default. Reading the process list and the banner changes no state. A worker that is not listening is not this flaw, and a missing banner means unknown, not safe.

## Remediation

1. Update every RPC worker to **b12658 or later**. That is the first build the record names as outside the range. The release says the wire format did not change.
2. Keep the worker on `127.0.0.1`, or on a link only the head node can reach. The README says not to run it on an open network. There is no login and no TLS to turn on.
3. The update does not show whether a peer already wrote the heap.

## Verification

- `ggml-rpc-server` reports **b12658 or later**, or the host does not run it.
- The endpoint is `127.0.0.1`, or a firewall limits it to the head node.
- Do not send a crafted `COPY_TENSOR` to test it.

## Compromise response

No source read for this entry reports an incident. A worker that was reachable before the update could already have run code as the user that started it. That user can read the models and the devices the worker exposes. The update does not undo a write that already landed.

## Sources

- [CVE-2026-137567][cve] — VulnCheck, published 2026-11-26. CVSS 3.1 9.8 and CVSS 4.0 9.3. Affected from b11450 before b12658. Credits Min P. Hong (SEWORKS). Names no exploitation.
- [b12658][b12658] — ggml-org, published 2026-11-24 00:56:59 UTC. Pull request 32651 adds one validation step on the RPC server. The note does not name a CVE.
- [RPC README](https://github.com/ggml-org/llama.cpp/blob/master/tools/rpc/README.md) — never run the RPC server on an open network or in a sensitive environment. The example endpoint is `127.0.0.1:50052`.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, released 2026-11-25T19:48:12.4344Z, checked 2026-11-26. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-137567
[b12658]: https://github.com/ggml-org/llama.cpp/releases/tag/b12658
