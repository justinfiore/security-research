# Wasmtime: Cranelift sandbox escapes from untrusted Wasm

**Last updated:** 2026-10-26 (America/New_York)

[Main Wasmtime summary](../black-october-2026.md#wasmtime-cranelift-sandbox-escapes-from-untrusted-wasm) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Two Critical Cranelift miscompilation bugs in the [Wasmtime](https://docs.wasmtime.dev/) WebAssembly runtime. Both: GitHub CNA (Bytecode Alliance advisory) CVSS 3.1 9.9 Critical (CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H). NVD has not added its own score (status "Deferred"). Neither is listed in CISA KEV.**

- **[CVE-2026-115889](https://www.cve.org/CVERecord?id=CVE-2026-115889) (GHSA-897f-g5gm-fmxm, RUSTSEC-2026-0380), any architecture.** Cranelift bit-packed SSA value indices into fields that silently overflow in release builds. A very large or specially crafted Wasm function can force type confusion and escape the sandbox on **any architecture** with the default Cranelift backend. Affected: **before 36.0.19**, and **37.0.0 before 43.0.0**. Main already changed this in February 2026 (PR #12613, shipped in 43.0.0 on 2026-03-20) without describing it as a security fix. [Advisory][a889] [CNA][cve889]
- **[CVE-2026-115893](https://www.cve.org/CVERecord?id=CVE-2026-115893) (GHSA-mghf-wjfp-p5xm, RUSTSEC-2026-0379), aarch64 (ARM64) only.** A `br_table` instruction with more than about 256,000 targets is compiled with a conditional branch whose target can be out of range, so execution jumps to an attacker-controlled offset. Every Wasmtime version that supports aarch64 since 2020 is affected up to the fixes: **before 36.0.19**, **37.0.0 before 48.0.7**, and **49.0.0 before 49.0.4**. [Advisory][a893] [CNA][cve893]

**Who is exposed:** services that **compile Wasm modules supplied by someone they do not fully trust**, such as plugin hosts, multi-tenant function platforms and CI or build services that run user modules. The CVSS vector assumes the attacker can supply a module (PR:L). Running only your own trusted modules removes the attacker, not the bug. The reviewed advisories do not name downstream products or embedders. Check each product that bundles Wasmtime with its vendor.

**Worst case:** code execution in the host process that runs Wasmtime, outside the Wasm sandbox, with that process's privileges and data. Maintainers have reported no attacks. [THN][thn]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Which fix applies to which release line](#which-fix-applies-to-which-release-line)
  - [Read-only inventory](#read-only-inventory)
  - [Reachability and evidence](#reachability-and-evidence)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Credited reporters: jaydns (CVE-2026-115889) and ilyas-mallah (CVE-2026-115893). The advisories give no report dates. [Advisory][a889] [Advisory][a893] |
| SSA index change merged on main | 2026-02-18 16:26:23 UTC | PR #12613 widened value fields to 32 bits, presented as a function-size limit fix. [PR #12613][pr12613] |
| Wasmtime 43.0.0 released | 2026-03-20 06:44:27 UTC | First non-LTS release not affected by CVE-2026-115889. Still affected by CVE-2026-115893 on aarch64. [v43.0.0][r43] |
| Security fix PRs merged | 2026-10-19 18:26:19–19:08:18 UTC | #14818 (36.x), #14819 (48.x), #14820 (49.x), #14826 (main), and backport #14821 to the 50.0.0 release branch at 19:00:10 UTC. [PR #14826][pr14826] [PR #14821][pr14821] |
| **36.0.19 released (fixes both)** | 2026-10-19 19:09:53 UTC | GitHub release time; release notes list both advisories. [v36.0.19][r36] |
| **48.0.7 and 49.0.4 released (fix CVE-2026-115893)** | 2026-10-19 19:20:31 UTC and 19:20:37 UTC | GitHub release times. [v48.0.7][r48] [v49.0.4][r49] |
| **Public announcement: advisories GHSA-mghf-wjfp-p5xm and GHSA-897f-g5gm-fmxm** | **2026-10-19 19:21:02 UTC and 19:21:24 UTC** | Repository advisory publication times (GitHub API). [Advisory][a893] [Advisory][a889] |
| RustSec RUSTSEC-2026-0379 issued | 2026-10-20; time/TZ unknown | For CVE-2026-115893. [RustSec][rustsec] |
| Wasmtime 50.0.0 released | 2026-10-20 16:22:46 UTC | Not in either advisory's affected ranges; its release branch received the CVE-2026-115893 backport (#14821) before release. [v50.0.0][r50] [PR #14821][pr14821] |
| CVE records published | 2026-10-23 21:23:27 UTC (CVE-2026-115889); 21:29:33 UTC (CVE-2026-115893) | GitHub CNA. NVD published both 2026-10-23 22:16:58 (NVD API, UTC). [CNA][cve889] [CNA][cve893] [NVD][nvd889] |
| GitHub Advisory Database | 2026-10-23 22:02:20 UTC (GHSA-897f-g5gm-fmxm reviewed) | GHSA-mghf-wjfp-p5xm returned "Not Found" from the global advisory API on 2026-10-26, so Dependabot may not alert for the aarch64 flaw. [GitHub advisory][gad889] |
| CISA KEV | Not listed (catalog 2026.10.23, checked 2026-10-26) | [KEV][kev] |
| Exploitation | None reported | THN (2026-10-26): "the maintainers have not reported any attacks". [THN][thn] |

## Detection

### Which fix applies to which release line

| Wasmtime version | CVE-2026-115889 (any arch) | CVE-2026-115893 (aarch64) | Action |
|---|---|---|---|
| Before 36.0.19 (including 24.x LTS) | Affected | Affected | 36.0.19, or 48.0.7 / 49.0.4 / 50.0.0 |
| 36.0.19 or later 36.x | Fixed | Fixed | None for these flaws |
| 37.0.0 – 42.x | Affected | Affected | 48.0.7 / 49.0.4 / 50.0.0 |
| 43.0.0 – 47.x | Not affected | Affected | 48.0.7 / 49.0.4 / 50.0.0 |
| 48.0.0 – 48.0.6 | Not affected | Affected | 48.0.7 |
| 49.0.0 – 49.0.3 | Not affected | Affected | 49.0.4 |
| 48.0.7, 49.0.4, 50.0.0 and later | Not affected | Fixed | None for these flaws |

Derived from the CNA ranges. [CNA][cve889] [CNA][cve893] Wasmtime supports LTS releases (multiples of 12) for 24 months and other releases for 2 months. Security fixes are only guaranteed for supported releases. [Release policy][policy] THN reports that only the 36, 48, 49 and 50 lines are supported and that 24.x LTS support ended 2026-08-20. THN also reports that ARM64 hosts that updated in April 2026 for an earlier Cranelift advisory (GHSA-jhxm-h53p-jm7w) remain affected by CVE-2026-115893. [THN][thn]

### Read-only inventory

These commands only read project files, binaries or tool versions. They were not exercised on a real Wasmtime deployment. Placeholders: `PROJECT_DIR` (a Rust workspace containing `Cargo.lock`), `BINARY` (a deployed executable). Run as a normal user.

```sh
cd PROJECT_DIR
# Which crates pull in wasmtime, and at which version (needs crate sources in the local cache)
cargo tree -i wasmtime --locked --target all
cargo tree -i cranelift-codegen --locked --target all
# Fallback that reads only the lock file
grep -A1 -E '^name = "wasmtime"$' Cargo.lock
# RustSec check of the lock file (downloads the public advisory database)
cargo audit
# Deployed binaries built with cargo-auditable only
cargo audit bin BINARY
# Wasmtime CLI on PATH
wasmtime --version
# Architecture of each runtime host (aarch64/arm64 matters for CVE-2026-115893)
uname -m
```

`cargo tree -i` errors if the crate is not in the graph; that means "not a direct or transitive dependency of this workspace", not that other projects are clean. Check container images and prebuilt binaries separately. Language bindings and products that bundle Wasmtime (for example the C API or the Bytecode Alliance language bindings) carry their own Wasmtime build. As of 2026-10-26, the latest GitHub releases of `wasmtime-dotnet` (v48.0.2, 2026-09-18) and `wasmtime-rb` (v49.0.2, 2026-10-08) predate the 2026-10-19 fixes. Whether fixed binding releases exist through other channels was not verified. Standalone Cranelift users (without the `wasmtime` crate) are not covered by the advisories' package ranges; map your `cranelift-codegen` version to its Wasmtime release before deciding.

### Reachability and evidence

- Record whether each service compiles modules from untrusted sources (uploads, plugin marketplaces, tenant code, URLs) and whether it uses the default Cranelift compiler.
- Note precompiled-module caches (for example `.cwasm` files from `wasmtime compile` or `Module::serialize`). Modules compiled by an affected Cranelift remain affected code even after the runtime is upgraded.
- No IOCs are published. Signals worth retaining: modules with unusually large function bodies, or `br_table` instructions with very large target counts (CVE-2026-115893 needs more than ~256,000). Inspect stored modules offline with a trusted tool such as `wasm-tools print`, on a separate host, without running them.
- Absence of such modules or of logs does not prove that no escape occurred.

## Remediation

1. **Update the `wasmtime` dependency** to **36.0.19+** (36.x LTS), **48.0.7+**, **49.0.4+** or **50.0.0+**, run `cargo update -p wasmtime`, rebuild, and redeploy every binary and image. Lines 37–47 have no fix; move to a supported line. [Advisory][a889] [Advisory][a893]
2. **Discard and recompile precompiled modules** produced by affected versions, including caches built for aarch64 on other machines.
3. **Restart long-running hosts** so the new engine is loaded.
4. **No workarounds are published in the advisories.** Until fixed, stop accepting modules from untrusted parties, or isolate the compiling and executing process with OS-level sandboxing (separate user, container or VM, no secrets in the process). Those measures limit damage but do not fix the bug.

## Verification

- Re-run the inventory on deployed artifacts and confirm a fixed version on every host, including aarch64 hosts.
- Optional benign control on an isolated test host, not exercised for this guide: fixed releases (36.0.19, 48.0.7, 49.0.4, 50.0.0) add a `br_table` limit of 65,520 targets, so compiling a harmless module whose single `br_table` has 65,521 targets that all branch to the same block fails with "exceeds the implementation limit of 65520". Unfixed releases lack this check (it is absent from v36.0.18, for example). This checks the CVE-2026-115893 fix for that build only; it does not test CVE-2026-115889, and the module stays far below the ~256,000-target trigger. [PR #14826][pr14826]

## Compromise response

- If an affected service compiled untrusted modules, treat the **host process** as potentially compromised: review its outbound connections, file writes, spawned processes and credentials it could read.
- Rotate secrets available to that process (API keys, database credentials, signing keys, cloud tokens).
- Retain the submitted modules and logs for analysis, then rebuild hosts from known-good images if escape is suspected.
- Review whether other tenants' data shared the process or host.

## Sources

- Bytecode Alliance advisories [GHSA-897f-g5gm-fmxm][a889] and [GHSA-mghf-wjfp-p5xm][a893]: impact, affected and fixed versions, CVSS, publication times.
- CVE records (GitHub CNA): [CVE-2026-115889][cve889], [CVE-2026-115893][cve893]; NVD [CVE-2026-115889][nvd889] and [CVE-2026-115893][nvd893].
- Releases [v36.0.19][r36], [v43.0.0][r43], [v48.0.7][r48], [v49.0.4][r49], [v50.0.0][r50]; PRs [#12613][pr12613], [#14826][pr14826], [#14821][pr14821]; [release policy][policy].
- [GitHub Advisory Database entry for GHSA-897f-g5gm-fmxm][gad889]; [RustSec RUSTSEC-2026-0379][rustsec].
- [CISA KEV feed][kev]: neither CVE listed.
- Secondary: [The Hacker News][thn] (version table, support status, no reported attacks).

[a889]: https://github.com/bytecodealliance/wasmtime/security/advisories/GHSA-897f-g5gm-fmxm
[a893]: https://github.com/bytecodealliance/wasmtime/security/advisories/GHSA-mghf-wjfp-p5xm
[cve889]: https://cveawg.mitre.org/api/cve/CVE-2026-115889
[cve893]: https://cveawg.mitre.org/api/cve/CVE-2026-115893
[nvd889]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-115889
[nvd893]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-115893
[gad889]: https://github.com/advisories/GHSA-897f-g5gm-fmxm
[rustsec]: https://rustsec.org/advisories/RUSTSEC-2026-0379.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[r36]: https://github.com/bytecodealliance/wasmtime/releases/tag/v36.0.19
[r43]: https://github.com/bytecodealliance/wasmtime/releases/tag/v43.0.0
[r48]: https://github.com/bytecodealliance/wasmtime/releases/tag/v48.0.7
[r49]: https://github.com/bytecodealliance/wasmtime/releases/tag/v49.0.4
[r50]: https://github.com/bytecodealliance/wasmtime/releases/tag/v50.0.0
[pr12613]: https://github.com/bytecodealliance/wasmtime/pull/12613
[pr14826]: https://github.com/bytecodealliance/wasmtime/pull/14826
[pr14821]: https://github.com/bytecodealliance/wasmtime/pull/14821
[policy]: https://docs.wasmtime.dev/stability-release.html
[thn]: https://thehackernews.com/2026/10/two-critical-wasmtime-flaws-could-let.html
