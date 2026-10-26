# Black October: What Broke, What’s Exposed, and What to Patch

**As of October 26, 2026**

[Security updates](../CHANGELOG.md) · [Hourly maintenance process](MAINTENANCE.md)

“Black October” is an informal label for the unusually dense run of vulnerability disclosures and security incidents this month—particularly the October 19–23 cluster. It is **not one coordinated attack, one vulnerability family, or an official advisory list**.

The concern is justified: several flaws sit below application code, in runtimes, image decoders, and infrastructure components. Updating your application dependencies alone may leave the vulnerable runtime or bundled native library untouched.

This report covers the major disclosures most relevant to developers and operators of personal infrastructure, plus related incidents that require credential rotation rather than a patch. It is not an exhaustive catalog of October CVEs. Some vulnerabilities were fixed earlier but received public technical disclosures or exploitation reports this month.

## Table of contents

- [The short version](#the-short-version)
  - [How to use the impact checks](#how-to-use-the-impact-checks)
  - [What CISA KEV means](#what-cisa-kev-means)
- [Wasmtime: Cranelift sandbox escapes](#wasmtime-cranelift-sandbox-escapes-from-untrusted-wasm)
- [Laravel: TokenGuard API authentication bypass](#laravel-tokenguard-api-authentication-bypass-on-mysql-and-mariadb)
- [Next.js: unauthenticated RCE in use cache and Image Optimization](#nextjs-unauthenticated-rce-in-use-cache-and-image-optimization)
- [Drupal core: Field UI remote code execution](#drupal-core-field-ui-remote-code-execution)
- [NGINX: memory corruption and TLS session forgery](#nginx-configuration-dependent-memory-corruption-and-tls-session-forgery)
- [curl and libcurl: HTTP/2 upload use-after-free](#curl-and-libcurl-use-after-free-when-a-server-resets-an-upload)
- [Linux kernel: PwnEscape - guest-to-host escape](#linux-kernel-pwnescape---guest-to-host-escape-via-ipv4-checksum-metadata)
- [Bricksforge for WordPress: exploited file upload to RCE](#bricksforge-for-wordpress-exploited-unauthenticated-file-upload-to-rce)
- [Gitea: built-in SSH server authentication bypass](#gitea-built-in-ssh-server-authentication-bypass)
- [Langflow: MCP stdio RCE with honeypot exploitation attempts](#langflow-authenticated-rce-via-mcp-stdio-server-configuration)
- [VeloCloud Orchestrator: authenticated SQL injection](#velocloud-orchestrator-authenticated-sql-injection-to-superuser-operator)
- [Siemens Software Center: exploited DLL side-loading](#siemens-software-center-dll-side-loading-exploited-in-clickfix-campaign)
- [PAN-OS: authenticated management interface RCE](#pan-os-authenticated-management-interface-rce)
- [Cisco Secure Email Gateway: AMP attachment path traversal](#cisco-secure-email-gateway-amp-attachment-path-traversal)
- [SiteGuard Server Edition: root command injection](#siteguard-server-edition-root-command-injection-via-statistics-feature)
- [Windows Shell: Mark of the Web bypass](#windows-shell-mark-of-the-web-bypass-zero-day)
- [Ivanti Connect Secure: authentication bypass to command execution](#ivanti-connect-secure-authentication-bypass-to-command-execution)
- [Atlassian Data Center: unauthenticated web-root file read](#atlassian-data-center-unauthenticated-web-root-file-read)
- [AhsayCBS: authentication bypass and command injection chain](#ahsaycbs-authentication-bypass-and-command-injection-chain)
- [NetScaler: SAML memory overflow denial of service](#netscaler-saml-memory-overflow-denial-of-service)
- [FortiMail: unauthenticated file write](#fortimail-unauthenticated-file-write)
- [Zammad: session hijack RCE and root escalation chain](#zammad-session-hijack-rce-and-root-escalation-chain)
- [Tailscale / headscale: Tailworm - SSH findings under review](#tailscale--headscale-tailworm---ssh-and-related-findings-under-review)
- [Microsoft Authenticator for Android: AuthMask - token theft](#microsoft-authenticator-for-android-authmask---token-theft)
- [PHP: PHP2Shell - unauthenticated execution](#php-php2shell---unauthenticated-execution-below-your-application)
  - [The October 23 follow-up](#the-october-23-follow-up-matters)
- [Brotli consumers: HTTP2Shell / Node2Shell / Brotli2Shell - cross-stack decoder corruption](#brotli-consumers-nodejs-bun-python-net-ffmpeg-clickhouse-arrow-and-others-http2shell--node2shell--brotli2shell---cross-stack-decoder-corruption)
  - [Other high-severity Node.js fixes](#other-high-severity-nodejs-fixes-in-the-same-release)
- [GitLab and Ruby: regex compilation becomes code execution](#gitlab-and-ruby-regex-compilation-becomes-code-execution)
  - [GitLab identity vulnerabilities](#related-gitlab-identity-vulnerabilities)
  - [Ruby applications](#ruby-applications-need-their-own-update)
- [Pillow: image-processing memory corruption and command execution](#pillow-untrusted-images-reach-native-memory-corruption-and-command-execution)
- [Plex Media Server: Plex2Shell - exploited remote code execution chain](#plex-media-server-plex2shell---exploited-remote-code-execution-chain)
- [Nextcloud’s built-in Collabora CODE server: unauthenticated command injection](#nextclouds-built-in-collabora-code-server-unauthenticated-command-injection)
- [Linux KSMBD: kernel memory disclosure and denial of service](#linux-ksmbd-kernel-memory-disclosure-and-denial-of-service)
- [Broadcom legacy WPS: WPSplinter - nearby router compromise](#broadcom-legacy-wps-wpsplinter---nearby-router-compromise)
- [HTTP/3 stacks: Header Accordions - compression-driven resource exhaustion](#http3-stacks-header-accordions---compression-driven-resource-exhaustion)
- [BeyondTrust Remote Support: exploited unauthenticated file operations](#beyondtrust-remote-support-exploited-unauthenticated-file-operations)
- [TLS and code-signing trust stores: eMudhra / emSign - CA compromise](#tls-and-code-signing-trust-stores-emudhra--emsign---certificate-authority-compromise)
- [LiteLLM: malicious release and credential theft](#litellm-malicious-release-and-credential-theft)
- [Railway: environment secret exposure](#railway-environment-secret-exposure)
- [What should I patch? A stack-based decision guide](#what-should-i-patch-a-stack-based-decision-guide)

## The short version

- **Patch widely deployed developer and self-hosted stacks too, even without KEV listings:** Next.js, NGINX, curl/libcurl, Drupal, Laravel, Gitea, Langflow, Wasmtime, the Bricksforge WordPress plugin, and Linux VM/sandbox hosts (PwnEscape). Bricksforge and Langflow already face exploitation attempts.
- **Patch KEV-listed edge and enterprise software first.** CISA added FortiMail, Zammad, NetScaler, Ivanti Connect Secure, Windows Shell, PAN-OS, AhsayCBS, Cisco Secure Email Gateway, Atlassian Data Center, SiteGuard, Siemens Software Center and VeloCloud flaws to its Known Exploited Vulnerabilities catalog in October; several require forensic triage, not just patching.
- **Review Tailscale SSH authorization and forwarding.** Tailworm's principal SSH chains require existing authorized access; disable unnecessary forwarding and track official fixes, rather than treating every VPN node as remotely exploitable.
- **Update Microsoft Authenticator on Android**, especially devices with signed-in work accounts. AuthMask requires a malicious local app; patching does not revoke already stolen tokens.
- **Prioritize exposed PHP, GitLab, Plex, and Nextcloud installations using the built-in Collabora CODE server.**
- **Inventory every Brotli decoder**, including Node.js, Bun, Python, .NET, proxies, FFmpeg/libjxl, ClickHouse and Arrow/pyarrow. Untrusted responses, media metadata and analytical files can reach separate bundled copies; a runtime or Python binding update does not patch them all.
- **Update Pillow wherever you process untrusted images**, including thumbnail workers and document pipelines.
- **Check Ruby separately from GitLab.** The underlying regex bugs affect other applications compiling attacker-controlled patterns.
- **Update certificate trust data and rebuild Go applications.** The eMudhra incident affects clients even if your own website uses another certificate authority.
- **If you ran the compromised LiteLLM release or stored secrets in Railway, patching alone is insufficient.**

Severity scores below are attributed where ratings differ. CVSS measures technical severity, not whether exploitation has been observed or whether your particular deployment is reachable.

### How to use the impact checks

The checks below are **read-only inventory checks, not exploit probes**. Run them against your own deployments, including each container, worker, virtual environment, and appliance. Replace example paths with actual deployment paths. A missing command, inaccessible configuration, or absent package in one environment means **unknown for the rest of your infrastructure**, not “safe.”

Interpret results in three steps: **is the component present; does its exact build include the fix; can untrusted input reach the affected feature?** Compare versions within the appropriate release branch and verify vendor backports. Installed files can differ from a still-running process. None of these checks establishes whether a system was previously compromised. If compromise is suspected, inspect a snapshot from a clean system rather than executing its interpreters or application tools.

**Companion files:** Download these alongside the Markdown report. The commands below assume you are in the download directory; use absolute script paths when running as another user. Review the scripts before executing them. They do not install packages, patch services, send exploit payloads, or require API credentials.

| File | Purpose | Requirements |
|---|---|---|
| [stack-inventory.sh](stack-inventory.sh) | PHP settings, Node/Bun/Ruby versions, GitLab information, Nextcloud app list, or Go binary build metadata | POSIX shell and the selected product's tool |
| [python-package-inventory.py](python-package-inventory.py) | Brotli, brotlicffi, Pillow, olefile, and LiteLLM package metadata without importing them | Trusted Python 3.8+; no third-party dependencies |
| [linux-service-inventory.sh](linux-service-inventory.sh) | KSMBD presence, SMB/Plex listeners, and visible RDMA devices | Linux; `ss` for listener inspection |
| [check_brotli.py](check_brotli.py) | Response-header compression inventory; **not a vulnerability verdict**. [Usage and limits](details/brotli.md#response-header-inventory-script) | Python 3.9+; standard library; authorized HTTP(S) GET requests |

An exit status of zero means the requested inventory commands completed, **not that the system is patched**. Nonzero status means the check failed or its input/tool is unavailable. The Linux script may finish with explicitly marked `UNKNOWN` partial results; read its output. Shell checks inspect tools on the current user's PATH, so run inside the correct deployment or set PATH to the intended runtime. Do not run them against a suspected compromised installation; use clean-host snapshot inspection instead.

Each item links to a detailed operational guide. **Last updated** changes only when that item's content changes, not whenever a scheduled review runs. Unknown private-discovery or patch dates are marked explicitly; announcement, release, revocation and deployment are different events. Dates below are in 2026 unless stated otherwise; detailed timelines preserve source timezones.

**Reading the date tables:** `Time/TZ unknown` means the source date is known but its time and timezone have not been established; it does not mean midnight. UTC timestamps retain the precision recorded in the detailed timeline. **Last updated** is the guide's revision timestamp in America/New_York, not a new vulnerability event or a fresh research pass.

### What CISA KEV means

The U.S. Cybersecurity and Infrastructure Security Agency’s [Known Exploited Vulnerabilities catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) lists CVEs with reliable evidence of active exploitation. Each item states its KEV status. **Listed** means CISA has evidence of in-the-wild exploitation; the “added” date is when CISA listed it, not when attacks began, and the due date binds U.S. federal civilian agencies only, though it is a useful urgency signal for everyone. **Not listed** does not mean safe or unexploited: CISA may not have evidence yet, other sources may report exploitation, and issues without a CVE cannot be listed. Statuses reflect the catalog version noted on each item.

<a name="wasmtime-cranelift-sandbox-escapes-from-untrusted-wasm-cve-2026-115889-and-cve-2026-115893"></a>

## Wasmtime: Cranelift sandbox escapes from untrusted Wasm

[Back to TOC](#table-of-contents) · **[Detailed guide](details/wasmtime.md):** [Detection](details/wasmtime.md#detection) · [Remediation](details/wasmtime.md#remediation) · [Verification](details/wasmtime.md#verification) · [Timeline](details/wasmtime.md#timeline)

**CVEs:** [CVE-2026-115889](https://www.cve.org/CVERecord?id=CVE-2026-115889), [CVE-2026-115893](https://www.cve.org/CVERecord?id=CVE-2026-115893)

**[CVE-2026-115889](https://www.cve.org/CVERecord?id=CVE-2026-115889) and [CVE-2026-115893](https://www.cve.org/CVERecord?id=CVE-2026-115893) — GitHub CNA (Bytecode Alliance) CVSS 3.1: 9.9 Critical each; NVD has not scored them**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | Advisories credit external reporters without dates. |
| Non-security fix for CVE-2026-115889 on main | 2026-03-20 06:44:27 UTC | Shipped in Wasmtime 43.0.0 (PR merged 2026-02-18), not described as a security fix. |
| Fixed releases 36.0.19, 48.0.7, 49.0.4 | 2026-10-19 19:09:53–19:20:37 UTC | 36.0.19 fixes both; 48.0.7 and 49.0.4 fix CVE-2026-115893. |
| Public announcement (GHSA-mghf-wjfp-p5xm, GHSA-897f-g5gm-fmxm) | 2026-10-19 19:21:02 and 19:21:24 UTC | Repository advisory publication times. |
| Wasmtime 50.0.0 | 2026-10-20 16:22:46 UTC | Outside both affected ranges; includes the aarch64 backport. |
| CVE records published | 2026-10-23 21:23:27 / 21:29:33 UTC | GitHub CNA. |
| **Last updated** | **2026-10-26 10:18 EDT (UTC−04:00)** | Added from discovery review and primary sources. |

Both bugs are in Cranelift, Wasmtime's default compiler. **CVE-2026-115889** (any architecture): SSA value indices silently overflow when compiling a huge or crafted function, causing miscompilation and type confusion. **CVE-2026-115893** (aarch64/ARM64 only): a `br_table` with more than ~256,000 targets gets an out-of-range branch that jumps to an attacker-chosen offset.

**Worst case:** a malicious Wasm module escapes the sandbox and runs code in the host process with its privileges and secrets.

**Exploitation status:** No attacks reported by the maintainers or in reviewed sources. The attacker must be able to get a module compiled (CVSS PR:L).

**Am I impacted?** Only services that compile Wasm from parties they do not fully trust (plugin hosts, multi-tenant function platforms, build or CI services running user modules). In each Rust workspace run `cargo tree -i wasmtime --locked` or check `Cargo.lock`; check `wasmtime --version`, `uname -m` on runtime hosts, and bundled copies in language bindings and products. Affected for CVE-2026-115889: before 36.0.19 and 37.0.0 to before 43.0.0. Affected for CVE-2026-115893: before 36.0.19, 37.0.0 to before 48.0.7, and 49.0.0 to before 49.0.4.

**Patch:** Move to **36.0.19+**, **48.0.7+**, **49.0.4+** or **50.0.0+**; lines 37–47 and 24.x get no fix. Rebuild, redeploy, restart hosts and recompile cached precompiled modules. No workarounds are published; until patched, stop compiling untrusted modules or isolate the process. GitHub's global advisory database had no entry for the aarch64 flaw on 2026-10-26, so Dependabot may stay silent.

Sources: [GHSA-897f-g5gm-fmxm](https://github.com/bytecodealliance/wasmtime/security/advisories/GHSA-897f-g5gm-fmxm), [GHSA-mghf-wjfp-p5xm](https://github.com/bytecodealliance/wasmtime/security/advisories/GHSA-mghf-wjfp-p5xm), [CNA record CVE-2026-115889](https://cveawg.mitre.org/api/cve/CVE-2026-115889), [CNA record CVE-2026-115893](https://cveawg.mitre.org/api/cve/CVE-2026-115893), [Wasmtime 36.0.19 release](https://github.com/bytecodealliance/wasmtime/releases/tag/v36.0.19), [The Hacker News](https://thehackernews.com/2026/10/two-critical-wasmtime-flaws-could-let.html).

<a name="laravel-tokenguard-api-authentication-bypass-on-mysql-and-mariadb-cve-2026-114509"></a>

## Laravel: TokenGuard API authentication bypass on MySQL and MariaDB

[Back to TOC](#table-of-contents) · **[Detailed guide](details/laravel.md):** [Detection](details/laravel.md#detection) · [Remediation](details/laravel.md#remediation) · [Verification](details/laravel.md#verification) · [Timeline](details/laravel.md#timeline)

**CVEs:** [CVE-2026-114509](https://www.cve.org/CVERecord?id=CVE-2026-114509)

**[CVE-2026-114509](https://www.cve.org/CVERecord?id=CVE-2026-114509) — GitHub CNA CVSS 4.0: 9.2 Critical; NVD has not scored it**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private report | Unknown | Reported via GitHub's advisory process before the August fixes. |
| Fixed releases | 2026-08-25 14:19:59 UTC (12.68.0); 20:58:51 UTC (13.29.0) | Fixes shipped two months before disclosure; v13.27.0 already contains the fix commit, but the advisory designates 13.29.0. |
| Public announcement (Laravel advisory GHSA-f9x3-7vq9-cph6) | 2026-10-19 13:32:50 UTC | Repository advisory publication time. |
| Public PoC (Hakai Security) | 2026-10-20; time/TZ unknown | Technical analysis with Docker lab. |
| CVE record published | 2026-10-21 21:49:29 UTC | GitHub CNA. |
| **Last updated** | **2026-10-26 10:18 EDT (UTC−04:00)** | Added from discovery review and primary sources. |

Laravel's built-in `TokenGuard`, used by any guard with `'driver' => 'token'` (default `api_token` request key and column), accepts a non-string credential. On a MySQL or MariaDB user store, a crafted value makes the lookup match an existing user, so an **unauthenticated** attacker is logged in as that user on token-guarded routes.

**Worst case:** API account takeover of the matched user, which researchers say is the first user whose stored token does not start with a digit. Impact depends on that account's privileges.

**Exploitation status:** A public proof of concept exists. The reviewed sources report no in-the-wild exploitation, and access logs usually cannot show it because the payload travels in a JSON body.

**Am I impacted?** Only if the app defines a `token` driver guard **and** stores users in MySQL/MariaDB. The default Laravel 13 skeleton has only a session guard. Sanctum (`sanctum` driver) and Passport (`passport` driver) use their own guards and are not named in the advisory. In each deployed app root, run `composer show laravel/framework` (or read `vendor/composer/installed.json`) and `grep -rn "'driver' => 'token'" config/`. Affected: below 12.68.0 (including 11.x and older) and 13.0.0 to below 13.29.0.

**Patch:** Update `laravel/framework` to **12.68.0+** or **13.29.0+**, redeploy, and restart PHP-FPM/OPcache, Octane and queue workers. Laravel 11 is past security support; a v11.56.1 tag contains the fix but is not designated by the advisory. No vendor workaround is published. If abuse is suspected, rotate all `api_token` values.

Sources: [Laravel advisory](https://github.com/laravel/framework/security/advisories/GHSA-f9x3-7vq9-cph6), [GitHub CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-114509), [Hakai Security analysis](https://yokai.hakaisecurity.io/en-ghsa-f9x3-7vq9-cph6-authentication-bypass-in-laravel-tokenguard), [v12.68.0](https://github.com/laravel/framework/releases/tag/v12.68.0), [v13.29.0](https://github.com/laravel/framework/releases/tag/v13.29.0), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="nextjs-unauthenticated-rce-in-use-cache-and-image-optimization-ghsa-673q-mjm6-r5xr-and-cve-2026-96889"></a>

## Next.js: unauthenticated RCE in use cache and Image Optimization

[Back to TOC](#table-of-contents) · **[Detailed guide](details/nextjs.md):** [Detection](details/nextjs.md#detection) · [Remediation](details/nextjs.md#remediation) · [Verification](details/nextjs.md#verification) · [Timeline](details/nextjs.md#timeline)

**CVEs:** [CVE-2026-96889](https://www.cve.org/CVERecord?id=CVE-2026-96889), [CVE-2026-94482](https://www.cve.org/CVERecord?id=CVE-2026-94482). The `use cache` RCE (GHSA-673q-mjm6-r5xr) has no CVE assigned.

**GHSA-673q-mjm6-r5xr and GHSA-2464-fhr4-w9xw ([CVE-2026-96889](https://www.cve.org/CVERecord?id=CVE-2026-96889)): Vercel Critical, CVSS 4.0 9.5 each. Red Hat, the CNA for the librsvg CVE, scores CVE-2026-96889 CVSS 3.1 7.8 High. The same release fixes a High DoS, [CVE-2026-94482](https://www.cve.org/CVERecord?id=CVE-2026-94482) (CVSS 4.0 8.2).**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Discovery | Unknown | The finders are not named. The librsvg flaw was reported to Red Hat 2026-09-23 and made public the same day. |
| `sharp` 0.35.5 (fixed librsvg) | 2026-09-27 13:46 UTC | Workaround for the SVG issue. |
| Advance notice | 2026-10-08; time/TZ unknown | "Two Critical and one High" announced, with no details. |
| Advisories and fixed releases | 2026-10-14 17:46–17:47 UTC | `next` 15.5.28 and 16.4.1 on npm by 17:44 UTC. |
| **Last updated** | **2026-10-26 10:18 EDT (UTC−04:00)** | Added from discovery review and primary sources. |

There are two separate RCE paths:

- In 16.x App Router apps that use Cache Components, a `use cache` function that returns multiple typed arrays can be exploited. The flaw comes from React Server Components, and there is no workaround.
- The Image Optimization API passes SVG to `sharp`'s bundled librsvg, which has a use-after-free. Vercel says this is exploitable "when Next.js runs on glibc-based Linux".

Vercel's sources do not say whether apps hosted on Vercel are protected.

**Worst case:** Unauthenticated code execution in the Next.js server process, and theft of its secrets.

**Exploitation:** No in-the-wild reports were found. CISA's SSVC entry for the librsvg CVE records a proof of concept.

**Am I impacted?**

- `use cache` RCE: `next` 16.0.0–16.4.0 with Cache Components.
- SVG RCE: `next` 10.0.0–15.5.27 or 16.0.0–16.4.0 with `sharp` below 0.35.5 on glibc Linux. `images.dangerouslyAllowSVG: true` makes it more likely to be reachable.
- DoS: 13.0.0–15.5.27 or 16.0.0–16.4.0 App Router apps with Server Actions.

Check the deployed `node_modules`, not just the lockfile.

**Patch:** Upgrade to **16.4.1** or **15.5.28**, confirm that the resolved `sharp` is **0.35.5+**, then rebuild and redeploy. Lines before 15.5 have no listed fix. Until you can upgrade, pin `sharp` 0.35.5+ or block sharp's SVG loader. There is no stopgap for `use cache`.

Sources: [GHSA-673q-mjm6-r5xr](https://github.com/vercel/next.js/security/advisories/GHSA-673q-mjm6-r5xr), [GHSA-2464-fhr4-w9xw](https://github.com/vercel/next.js/security/advisories/GHSA-2464-fhr4-w9xw), [Next.js blog](https://nextjs.org/blog/nextjs-security-update-october-14-2026), [CVE-2026-96889 record](https://cveawg.mitre.org/api/cve/CVE-2026-96889), [sharp GHSA-wq5f-xc86-pv6w](https://github.com/advisories/GHSA-wq5f-xc86-pv6w), [React GHSA-xqc2-xf4c-x3h3](https://github.com/facebook/react/security/advisories/GHSA-xqc2-xf4c-x3h3).

<a name="drupal-core-field-ui-remote-code-execution-cve-2026-108097"></a>

## Drupal core: Field UI remote code execution

[Back to TOC](#table-of-contents) · **[Detailed guide](details/drupal.md):** [Detection](details/drupal.md#detection) · [Remediation](details/drupal.md#remediation) · [Verification](details/drupal.md#verification) · [Timeline](details/drupal.md#timeline)

**CVEs:** [CVE-2026-108097](https://www.cve.org/CVERecord?id=CVE-2026-108097), [CVE-2026-108099](https://www.cve.org/CVERecord?id=CVE-2026-108099). Both records were not yet published when checked; the links are generated from Drupal-assigned IDs.

**SA-CORE-2026-014 / [CVE-2026-108097](https://www.cve.org/CVERecord?id=CVE-2026-108097): Drupal Security Team Critical 19/25. No CVE record has been published yet and NVD has no entry, so there is no CNA or NVD score. A related advisory, SA-CONTRIB-2026-218 for Entity List ([CVE-2026-108099](https://www.cve.org/CVERecord?id=CVE-2026-108099)), is also Critical 19/25.**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Discovery | Unknown | Reported by Drew Webber (Drupal Security Team) and Octavio Galland. |
| PSA-2026-10-12 | 2026-10-12 | Announced a release window of 2026-10-14 16:00–21:00 UTC. |
| SA-CORE-2026-014 and core fixes | 2026-10-14 (RSS 16:10 UTC) | 11.4.10 at 16:16 UTC, 10.6.19 at 16:42 UTC, 11.3.19 at 17:10 UTC, 12.0.0-beta2 at 21:57 UTC. |
| SA-CONTRIB-2026-218 (Entity List 3.0.10) | 2026-10-14 (RSS 17:26 UTC) | Release published 15:59 UTC. |
| **Last updated** | **2026-10-26 10:18 EDT (UTC−04:00)** | Added from discovery review and primary sources. |

The flaw is in core's Field UI module. Drupal says core alone cannot be exploited, but "multiple serious exploit paths exist with contributed modules", and at least one of them needs no login. Custom code may also expose it. The contributed modules are not named. Entity List has its own separate RCE with the same pattern.

**Worst case:** Unauthenticated code execution, with all site data readable and modifiable.

**Exploitation:** Drupal rates it "Theoretical", meaning there is no public exploit. No exploitation has been reported. The PSA warned exploits could appear "within hours or days".

**Am I impacted?** Drupal core 8.9.0 up to but not including 10.6.19, 11.0.0 up to 11.3.19, 11.4.0 up to 11.4.10, and 12.0.0-alpha1 up to 12.0.0-beta2 are affected. Entity List below 3.0.10 is affected separately. End-of-life branches (11.2 and older, 10.5 and older, Drupal 8 and 9) have **no fix**.

**Patch:** Update core to **11.4.10**, **11.3.19** or **10.6.19** (or later), or **12.0.0-beta2**. Update Entity List to **3.0.10**, then run `drush updatedb`. Until then, uninstall `field_ui`. Drupal Steward covers only some attack vectors.

Sources: [SA-CORE-2026-014](https://www.drupal.org/sa-core-2026-014), [SA-CONTRIB-2026-218](https://www.drupal.org/sa-contrib-2026-218), [PSA-2026-10-12](https://www.drupal.org/psa-2026-10-12), [Drupal release history](https://updates.drupal.org/release-history/drupal/current).

<a name="nginx-configuration-dependent-memory-corruption-and-tls-session-forgery-cve-2026-15176-cve-2026-93479-cve-2026-97205-and-cve-2026-97629"></a>

## NGINX: configuration-dependent memory corruption and TLS session forgery

[Back to TOC](#table-of-contents) · **[Detailed guide](details/nginx.md):** [Detection](details/nginx.md#detection) · [Remediation](details/nginx.md#remediation) · [Verification](details/nginx.md#verification) · [Timeline](details/nginx.md#timeline)

**CVEs:** [CVE-2026-15176](https://www.cve.org/CVERecord?id=CVE-2026-15176), [CVE-2026-93479](https://www.cve.org/CVERecord?id=CVE-2026-93479), [CVE-2026-97205](https://www.cve.org/CVERecord?id=CVE-2026-97205), [CVE-2026-97629](https://www.cve.org/CVERecord?id=CVE-2026-97629)

**[CVE-2026-15176](https://www.cve.org/CVERecord?id=CVE-2026-15176), [CVE-2026-93479](https://www.cve.org/CVERecord?id=CVE-2026-93479), [CVE-2026-97205](https://www.cve.org/CVERecord?id=CVE-2026-97205): F5 (CNA) CVSS 4.0 9.2 Critical, CVSS 3.1 8.1 High. [CVE-2026-97629](https://www.cve.org/CVERecord?id=CVE-2026-97629): F5 CVSS 4.0 8.3 High, CVSS 3.1 6.5 Medium. nginx.org rates all four "medium".**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Discovery | Unknown | CVE-2026-15176 was found internally by F5. The other three were reported by external researchers. |
| CVE records published | 2026-10-14 14:40 UTC | F5 CNA. |
| nginx 1.30.6 and 1.31.7, NGINX Plus fixes, F5 K articles | 2026-10-14; time/TZ unknown | Plus 37.0.5.1 and 37.1.0.1. |
| Debian DSA-6575-1 | 2026-10-21 15:28 UTC | trixie 1.26.3-3+deb13u10. |
| **Last updated** | **2026-10-26 10:18 EDT (UTC−04:00)** | Added from discovery review and primary sources. |

Each flaw needs a specific configuration:

- **CVE-2026-15176:** `alias` + `rewrite` + `$request_filename` in `set` or `return`, or `$request_filename` in a `log_format`.
- **CVE-2026-93479:** a regex `map` whose captures are used by `root` or log formats, plus a broader trigger F5 does not fully describe.
- **CVE-2026-97205:** `aio` + SSI `include virtual`.
- **CVE-2026-97629:** `ssl_session_cache shared:` without `ssl_session_ticket_key`, which can bypass client-certificate checks.

**Worst case:** For the three memory bugs, a worker crash (DoS), or code execution where ASLR is disabled or bypassed. For CVE-2026-97629, forged TLS sessions that get past mTLS.

**Exploitation:** No reports were found. CISA's SSVC entries say "none".

**Am I impacted?** These upstream versions are vulnerable:

- 0.1.29–1.31.6 (CVE-2026-15176)
- 1.30.0–1.30.5 and 1.31.2–1.31.6 (CVE-2026-93479)
- 0.8.11–1.31.6 (CVE-2026-97205)
- 1.23.2–1.31.6 (CVE-2026-97629)

Then check the running configuration with `nginx -T`, piped to `grep` because the dump can contain secrets. Distribution backports change the picture: Debian found CVE-2026-93479 in its 1.26.3 package. F5 products such as Ingress Controller, Gateway Fabric, Instance Manager and F5 WAF for NGINX are also affected.

**Patch:** Upgrade to **1.30.6** or **1.31.7+**, NGINX Plus **37.0.5.1** or **37.1.0.1** (R33–R36 have no fix), or your vendor's fixed package, then restart. F5's per-CVE configuration mitigations are a stopgap only.

Sources: [nginx.org advisories](https://nginx.org/en/security_advisories.html), [F5 K000162416](https://my.f5.com/manage/s/article/K000162416), [K000162607](https://my.f5.com/manage/s/article/K000162607), [K000162608](https://my.f5.com/manage/s/article/K000162608), [K000162606](https://my.f5.com/manage/s/article/K000162606), [Debian DSA-6575-1](https://lists.debian.org/debian-security-announce/2026/msg00490.html).

<a name="curl-and-libcurl-use-after-free-when-a-server-resets-an-upload-cve-2026-92392"></a>

## curl and libcurl: use-after-free when a server resets an upload

[Back to TOC](#table-of-contents) · **[Detailed guide](details/curl.md):** [Detection](details/curl.md#detection) · [Remediation](details/curl.md#remediation) · [Verification](details/curl.md#verification) · [Timeline](details/curl.md#timeline)

**CVEs:** [CVE-2026-92392](https://www.cve.org/CVERecord?id=CVE-2026-92392)

**[CVE-2026-92392](https://www.cve.org/CVERecord?id=CVE-2026-92392): curl project severity High. CISA ADP CVSS 3.1 8.1 High. The curl CNA record has no CVSS score.**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). The researcher's public report includes a remote code execution PoC; no in-the-wild exploitation has been reported. Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private report to curl | 2026-09-15 (HackerOne, 18:30 UTC) | "Luna with Claude, Anthropic". |
| Debian DSA-6558-1 | 2026-10-14 06:14 UTC | trixie 8.14.1-2+deb13u7. |
| Advisory and curl 8.23.0 | 2026-10-14 08:00 UTC (advisory JSON) | The HackerOne report, with its PoC, was made public 06:40 UTC. CVE published 07:46 UTC. |
| Rock-solid curl 8.20.2, 8.16.2 and 8.14.3 | 2026-10-14; time/TZ unknown | Commercial support customers only. |
| **Last updated** | **2026-10-26 10:18 EDT (UTC−04:00)** | Added from discovery review and primary sources. |

During an HTTP/2 upload, a server reply that resets the stream (`RST_STREAM` with `HTTP_1_1_REQUIRED` or `REFUSED_STREAM`) leaves curl using freed memory. Both the curl tool and libcurl are affected. The attacker must be, or be able to impersonate, the server that receives the upload.

**Worst case:** Code execution in the uploading process, for example a CI job, backup agent or application. curl says this "has been proven", but only when a malicious server knows the exact build, architecture and heap layout, and with a payload of about 23 bytes.

**Exploitation:** A public PoC exists. No exploitation has been reported. CISA's SSVC entry says "poc".

**Am I impacted?** Check for curl or libcurl **8.12.0–8.22.0** that uploads over HTTP/2, which is the default for HTTPS when libcurl is built with HTTP/2 support. Inventory bundled and static copies too, such as Python wheels, language bindings, container base images and vendor agents, because a system package update does not reach them.

**Patch:** Upgrade to **8.23.0** or your distribution's fixed package, rebuild the images and binaries that bundle libcurl, and restart. Until then, force HTTP/1.1 for uploads (`--http1.1` or `CURL_HTTP_VERSION_1_1`), which is curl's option C.

Sources: [curl advisory](https://curl.se/docs/CVE-2026-92392.html), [CVE record](https://cveawg.mitre.org/api/cve/CVE-2026-92392), [HackerOne #4030333](https://hackerone.com/reports/4030333), [Debian DSA-6558-1](https://lists.debian.org/debian-security-announce/2026/msg00472.html), [Rock-solid curl](https://rock-solid.curl.dev/download.html).

<a name="linux-kernel-pwnescape-guest-to-host-escape-via-ipv4-checksum-metadata-cve-2026-99999"></a>

## Linux kernel: PwnEscape - guest-to-host escape via IPv4 checksum metadata

[Back to TOC](#table-of-contents) · **[Detailed guide](details/pwnescape.md):** [Detection](details/pwnescape.md#detection) · [Remediation](details/pwnescape.md#remediation) · [Verification](details/pwnescape.md#verification) · [Timeline](details/pwnescape.md#timeline) · Vulnerability Info Site: [pwn.ai](https://pwn.ai/blog/pwnescape)

**CVEs:** [CVE-2026-99999](https://www.cve.org/CVERecord?id=CVE-2026-99999), [CVE-2026-74580](https://www.cve.org/CVERecord?id=CVE-2026-74580). CVE-2026-74580 is the related Vghost vhost flaw.

**[CVE-2026-99999](https://www.cve.org/CVERecord?id=CVE-2026-99999) — kernel.org CNA CVSS 3.1: 9.3 Critical; Red Hat and Amazon Linux CVSS 3.1: 8.8 Important (PR:L); Ubuntu priority: Medium. Companion [CVE-2026-74580](https://www.cve.org/CVERecord?id=CVE-2026-74580) "Vghost" — kernel.org CNA CVSS 3.1: 8.8 High.**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | 2026-08-20 (to Vercel); 2026-09-04 (to kernel security); time/TZ unknown | Researcher-stated dates. |
| Public netdev patch series | 2026-09-19 to 2026-09-22; time/TZ unknown | Patches were public before the vulnerability was announced. |
| Public announcement | 2026-10-14; time/TZ unknown | Vercel findings post. An earlier X/Twitter mention reported on oss-security was not verified. |
| Upstream stable fixes | 2026-10-15; time/TZ unknown | 5.10.272, 5.15.223, 6.1.190, 6.6.159, 6.12.113, 6.18.57, 7.2.11. Mainline 7.3 released 2026-10-18. |
| CVE published | 2026-10-15 12:19 UTC | kernel.org CNA. |
| Vghost CVE published / write-up | 2026-08-21 16:31 UTC / 2026-10-12, time/TZ unknown | Fixed in 5.10.265, 5.15.216, 6.1.183, 6.6.152, 6.12.104, 6.18.45, 7.1.9 and 7.2. |
| **Last updated** | **2026-10-26 10:18 EDT (UTC−04:00)** | Added from discovery review and primary sources. |

The flaw is in the host kernel's **IPv4 networking stack**, not in KVM. A guest sends crafted virtio-net checksum metadata, and the VMM writes it to a host TAP device. The host then corrupts an already-validated IPv4 header and reads beyond the packet data when it fragments the packet. Red Hat says local attackers can trigger it too.

**Worst case:** the guest escapes to the host. Vercel says the **host-memory leak was demonstrated on its production sandboxes**. The host crash and root command execution were shown **only on the researcher's own KVM and Firecracker machines**.

**Vghost** is a separate vhost bug:

- A user who can open `/dev/vhost-net` or `/dev/vhost-vsock` can become root. Several distributions ship those nodes world-writable (`0666`).
- In device-IOTLB setups (vIOMMU with `iommu_platform`), a guest can write out of bounds into the host's QEMU heap.

**Exploitation status:** No in-the-wild exploitation reported. CISA's SSVC entry records exploitation as "none". Red Hat's page mentions a "KEV active-exploit case", which the KEV feed does not support. A public PoC exists for Vghost.

**Am I impacted?** Highest priority: KVM/QEMU, Firecracker and other virtio-net hosts that run untrusted guests (cloud and VPS hosts, CI VMs, code-execution and AI sandboxes), then multi-user Linux. If a provider runs the host, only the provider can patch it. Distribution kernels keep older base versions (for example RHEL `5.14.0-*`), so **`uname -r` alone does not prove the backport**. Check the vendor's advisory or package changelog and confirm the host has rebooted. When reviewed, Red Hat and Ubuntu had not shipped fixes; Amazon Linux had, and AlmaLinux had kernels in its testing repository.

**Patch:** Boot a kernel that contains the fix: an upstream release listed above or a vendor backport. Drain guests first. Upstream lists no fix for the 5.4, 7.0 or 7.1 series. No workaround has been published. For Vghost, also remove world access to `/dev/vhost-*`, treat the `kvm` group as privileged, and do not give untrusted guests vIOMMU with `iommu_platform`.

Sources: [kernel.org CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-99999), [pwn.ai write-up](https://pwn.ai/blog/pwnescape), [Vercel findings](https://vercel.com/blog/findings-from-the-1-million-dollar-vercel-sandbox-challenge), [Red Hat](https://access.redhat.com/security/cve/cve-2026-99999), [AlmaLinux](https://almalinux.org/blog/2026-10-16-pwnescape-cve-2026-99999), [Vghost CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-74580), [Tencent Vghost write-up](https://matrix.tencent.com/en/2026/10/12/vghost-cve-2026-74580), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="bricksforge-exploited-unauthenticated-file-upload-to-rce-cve-2026-85097"></a>

## Bricksforge for WordPress: exploited unauthenticated file upload to RCE

[Back to TOC](#table-of-contents) · **[Detailed guide](details/bricksforge.md):** [Detection](details/bricksforge.md#detection) · [Remediation](details/bricksforge.md#remediation) · [Verification](details/bricksforge.md#verification) · [Timeline](details/bricksforge.md#timeline)

**CVEs:** [CVE-2026-85097](https://www.cve.org/CVERecord?id=CVE-2026-85097)

**[CVE-2026-85097](https://www.cve.org/CVERecord?id=CVE-2026-85097) — Wordfence (CNA) CVSS 3.1: 9.8 Critical; Patchstack CVSS: 10.0 (figure repeated by The Hacker News); NVD has not scored it**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Patchstack has observed exploitation attempts since 2026-10-07 21:47:17 UTC. Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown; vendor notified 2026-09-03 02:05:26 UTC | Wordfence CNA timeline. |
| Fixed release 3.1.8.10 | Unknown; on or before 2026-10-07 | Vendor says 4.0.0 (2026-09-17) also contains the fix. |
| Public announcement (Wordfence and Patchstack entries) | 2026-10-07; time/TZ unknown | Date-level publication. |
| First observed exploitation attempts | 2026-10-07 21:47:17 UTC | Patchstack telemetry. |
| CVE record published | 2026-10-08 06:42:09 UTC | Wordfence CNA. |
| Further upload fix (4.0.1) and hardening (4.0.2) | 2026-10-08 and 2026-10-13; time/TZ unknown | Vendor changelog; no CVE named for the 4.0.1 issue. |
| **Last updated** | **2026-10-26 10:18 EDT (UTC−04:00)** | Added from discovery review and primary sources. |

Bricksforge, a WordPress plugin that extends the Bricks Builder site builder, validates a Pro Forms upload's MIME type but later trusts the client-supplied `url` in `temporaryFileUploads`. An unauthenticated attacker fetches a nonce, uploads a GIF/PHP polyglot, and has it written to a `.php` path.

**Worst case:** unauthenticated remote code execution as the web server user, leading to web shells, site takeover and data theft.

**Exploitation status:** Patchstack reports automated attempts from 63 IPs against `/wp-json/bricksforge/v1/form_submit` (and once via `admin-ajax.php`), cycling PHP extensions, case and encodings. Attempts are confirmed; the number of successful compromises is not published.

**Am I impacted?** Any WordPress site with Bricksforge **3.1.8.9 or earlier**. On a trusted host run `wp plugin list --name=bricksforge --fields=name,status,version --skip-plugins --skip-themes` from the WordPress root, or read the plugin header from the files. On every site, look for PHP files under `wp-content/uploads`, especially `bricksforge/tmp/` and `login_admin_*.php`.

**Patch:** Update to **3.1.8.10 or later**; prefer the current 4.0.x (4.0.2 at review) because 4.0.1 fixed a further upload issue. If you cannot update, deactivate the plugin or block its form-submission endpoint and AJAX actions. Updating does not remove planted web shells: investigate, remove persistence and rotate WordPress secrets.

Sources: [Wordfence record](https://www.wordfence.com/threat-intel/vulnerabilities/wordpress-plugins/bricksforge/bricksforge-3189-unauthenticated-arbitrary-file-upload-via-temporaryfileuploads-parameter), [Wordfence CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-85097), [Patchstack exploitation report](https://patchstack.com/articles/critical-unauthenticated-arbitrary-file-upload-vulnerability-exploited-in-bricksforge-plugin/), [Bricksforge changelog](https://bricksforge.io/version-changelog/), [The Hacker News](https://thehackernews.com/2026/10/attackers-exploit-cvss-100-bricksforge.html).

<a name="gitea-built-in-ssh-server-authentication-bypass-cve-2026-103059"></a>

## Gitea: built-in SSH server authentication bypass

[Back to TOC](#table-of-contents) · **[Detailed guide](details/gitea.md):** [Detection](details/gitea.md#detection) · [Remediation](details/gitea.md#remediation) · [Verification](details/gitea.md#verification) · [Timeline](details/gitea.md#timeline)

**CVEs:** [CVE-2026-103059](https://www.cve.org/CVERecord?id=CVE-2026-103059)

**[CVE-2026-103059](https://www.cve.org/CVERecord?id=CVE-2026-103059) — CISA ADP CVSS 3.1: 9.1 Critical; Gitea advisory: 9.1 Critical (its text says "high rather than critical"); no score in the Gitea CNA record; NVD has added no score of its own**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | Reporter credited; no date published. |
| Fix merged to `main` (PR #39423) | 2026-09-25 13:22 UTC | Public in the repository before the advisory. |
| Gitea 28.0.0 released | 2026-09-29 23:25 UTC (GitHub tag); blog dated 2026-09-30 | The release after 1.27.3. Gitea dropped the `1.` prefix. |
| Public announcement (GHSA-8pwg-hcgm-54cp) | 2026-10-06 19:16 UTC | First publication of vulnerability details. |
| CVE published | 2026-10-06 19:22 UTC | Gitea CNA. CISA ADP score added 2026-10-07. |
| **Last updated** | **2026-10-26 10:18 EDT (UTC−04:00)** | Added from discovery review and primary sources. |

Gitea's **built-in Go SSH server** looked up the presented key with SQL `LIKE`, which ignores letter case on SQLite. An attacker downloads a victim's public RSA key from `/{username}.keys` and flips letter case until the altered key is usable. They can then forge a private key that Gitea accepts as the victim's.

**Worst case:** an unauthenticated attacker gets git-over-SSH **read and write access as any user with an RSA key**: private repositories, pushes and LFS tokens. The log shows an ordinary key login. Pushing to repositories can also change CI workflows that hold secrets.

**Exploitation status:** No exploitation reported. CISA's SSVC entry rates it Exploitation "none", Automatable "yes".

**Am I impacted?** You are affected if you run **1.27.3 or earlier** with `START_SSH_SERVER = true` and **SQLite**. The **official rootless container image** is affected with no configuration changes.

- MySQL/MariaDB and MSSQL are not addressed by the advisory; treat them as possibly affected.
- **Not affected:** PostgreSQL, **OpenSSH front-ends** (system `sshd` or the `AuthorizedKeysCommand`), SSH certificate login and HTTP signature auth.

Check `gitea --version`, `START_SSH_SERVER` and `DB_TYPE` in `app.ini`, and the image tag.

**Patch:** Upgrade to **28.0.0 or later**; no 1.27.x fix exists. Read the 28.0 breaking changes first (Git 2.25+, new egress proxy). Until you upgrade, disable the built-in server and use OpenSSH, or disable SSH. Review pushes and workflow changes made over SSH during the exposure window.

Sources: [Gitea advisory GHSA-8pwg-hcgm-54cp](https://github.com/go-gitea/gitea/security/advisories/GHSA-8pwg-hcgm-54cp), [Gitea CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-103059), [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-103059), [Gitea 28.0.0 release](https://blog.gitea.com/release-of-28.0.0/), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="langflow-authenticated-rce-via-mcp-stdio-server-configuration-cve-2026-105740-and-cve-2026-105697"></a>

## Langflow: authenticated RCE via MCP stdio server configuration

[Back to TOC](#table-of-contents) · **[Detailed guide](details/langflow.md):** [Detection](details/langflow.md#detection) · [Remediation](details/langflow.md#remediation) · [Verification](details/langflow.md#verification) · [Timeline](details/langflow.md#timeline)

**CVEs:** [CVE-2026-105740](https://www.cve.org/CVERecord?id=CVE-2026-105740), [CVE-2026-105697](https://www.cve.org/CVERecord?id=CVE-2026-105697)

**[CVE-2026-105740](https://www.cve.org/CVERecord?id=CVE-2026-105740) and [CVE-2026-105697](https://www.cve.org/CVERecord?id=CVE-2026-105697) — GitHub CNA CVSS 3.1: 9.9 Critical each; NVD: not yet scored**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Previdian honeypot sensors report exploitation attempts against CVE-2026-105740 since 2026-09-19. Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | Reporters credited; no dates published. |
| Langflow 1.9.0 (partial fix) | 2026-04-14 22:39 UTC | Blocks the REST "Add MCP Server" route only. |
| Langflow 1.10.3 (full fix) | 2026-07-23 16:08 UTC | Fixes the execution sink for both CVEs. |
| Public announcement (GHSA-7w94-79vh-5mr2) | 2026-09-10 15:38 UTC | CVE-2026-105740 advisory, with PoC. |
| First exploitation attempts (Previdian) | 2026-09-19 03:14 UTC | Third-party honeypot. Activity ramped up from 2026-10-11. |
| GHSA-w794-rj3p-xv45 | 2026-09-28 17:26 UTC | CVE-2026-105697 advisory. |
| CVEs published | 2026-10-05 20:16 UTC (105697); 20:46 UTC (105740) | GitHub CNA. |
| **Last updated** | **2026-10-26 10:18 EDT (UTC−04:00)** | Added from discovery review and primary sources. |

Any Langflow user, including a non-admin, can save an MCP server with the **stdio** transport. Langflow runs its command through `bash -c` without validation. The stored command runs again whenever anyone lists the MCP servers.

**1.9.0 blocked only the REST route.** Through 1.10.2, MCP stdio configurations embedded in flows or passed as tweaks still executed (CVE-2026-105697).

**Worst case:** OS command execution as the Langflow process user. Attackers can steal environment secrets such as LLM keys and `LANGFLOW_SECRET_KEY`, and leave a persistent backdoor in MCP settings. With **`LANGFLOW_AUTO_LOGIN=true`**, which the advisory calls the default for affected releases, `/api/v1/auto_login` hands out a token without credentials. In that case the attack needs no account at all.

**Exploitation status:** The evidence comes only from **Previdian's single honeypot sensor**: 4,896 attempts from 34 IPs as of 2026-10-26. Attackers logged in with a **common username and password** and then called `/api/v2/mcp/servers`. Attempts do not show successful compromise. Langflow has not reported exploitation.

**Am I impacted?** Check the installed `langflow`, `langflow-base` and `lfx` versions in every environment and container. Any version **below 1.10.3** is affected. Exposure is highest when auto-login is on, the superuser password is weak or the legacy `langflow`, untrusted users have accounts, or the instance is reachable from the internet. Do not open the MCP Servers page on an unpatched instance to check for stored commands, because loading it re-runs them.

**Patch:** Upgrade to **1.10.3 or later**, preferably the current release. Set `LANGFLOW_AUTO_LOGIN=false` with a strong `LANGFLOW_SUPERUSER_PASSWORD`. Restrict network access and accounts. 1.13 turns auto-login off by default, so prepare the existing superuser account before upgrading to keep access to your flows. If the instance was exposed, review MCP server configurations after upgrading, and rotate secrets, keys and sessions.

Sources: [GHSA-7w94-79vh-5mr2](https://github.com/langflow-ai/langflow/security/advisories/GHSA-7w94-79vh-5mr2), [GHSA-w794-rj3p-xv45](https://github.com/langflow-ai/langflow/security/advisories/GHSA-w794-rj3p-xv45), [GitHub CNA record 105740](https://cveawg.mitre.org/api/cve/CVE-2026-105740), [GitHub CNA record 105697](https://cveawg.mitre.org/api/cve/CVE-2026-105697), [Previdian telemetry](https://previdian.com/CVE-2026-105740), [The Hacker News (secondary)](https://thehackernews.com/2026/10/langflows-critical-authenticated-rce.html), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="velocloud-orchestrator-authenticated-sql-injection-to-superuser-operator-cve-2026-114625"></a>

## VeloCloud Orchestrator: authenticated SQL injection to superuser operator

[Back to TOC](#table-of-contents) · **[Detailed guide](details/velocloud.md):** [Detection](details/velocloud.md#detection) · [Remediation](details/velocloud.md#remediation) · [Verification](details/velocloud.md#verification) · [Timeline](details/velocloud.md#timeline)

**CVEs:** [CVE-2026-114625](https://www.cve.org/CVERecord?id=CVE-2026-114625)

**[CVE-2026-114625](https://www.cve.org/CVERecord?id=CVE-2026-114625): Arista CVSS 3.1 9.9 Critical; Arista CVSS 4.0 9.4 Critical; in CISA KEV**

**CISA KEV:** Listed — added 2026-10-23, federal due date 2026-10-26.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Discovery | Unknown date | Detected by Arista itself. |
| Hosted and Dedicated VCO patched | Unknown; on or before 2026-10-22 | Arista gives no date. |
| Arista Security Advisory 0199 and on-prem fixes | 2026-10-22; time/TZ unknown | Already known to be exploited. CVE published 20:47 UTC. |
| CISA KEV addition | 2026-10-23 (date only) | Due **2026-10-26**; forensic triage required. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

This is a SQL injection flaw in **on-premises** VeloCloud Orchestrator (VCO). Any authenticated user, down to the *Enterprise Read Only* role, can pose as a local "superuser operator" and reach internal-only functions. Arista says no configuration prevents the exposure. Hosted VCO, including Dedicated, has been patched by Arista. VeloCloud Edge and Gateway are not affected.

**Worst case:** Full compromise of the orchestrator host and its data, and through it the SD-WAN edges and gateways it manages.

**Exploitation:** Confirmed by Arista. The observed attacking IPs are 74.82.197.86 and 38.54.50.151. This is the third exploited VCO flaw in CISA KEV in 2026. The Hacker News reports that releases fixing the July and September flaws are still affected by this one.

**Am I impacted?** Check whether you run on-prem VCO on one of these trains below the fixed build:

- 5.2 before **5.2.3.18**
- 6.1 before **6.1.3.10**
- 6.4 before **6.4.2.12**

Arista has not assessed end-of-support releases. Review web access logs for the two IPs, encoded or internal-service path components and high request rates, and look for operator-level actions by low-privilege users.

**Patch:** Upgrade to the fixed build on your train, or contact Arista TAC if your train is unsupported. Until then, restrict the UI to trusted admin networks, block the IPs, and monitor outbound traffic, webshells and admin changes. Preserve VCO, database and system logs before you upgrade if you suspect compromise.

Sources: [Arista Security Advisory 0199](https://www.arista.com/en/support/advisories-notices/security-advisory/24838-security-advisory-0199), [CVE record](https://cveawg.mitre.org/api/cve/CVE-2026-114625), [CISA KEV](https://www.cisa.gov/known-exploited-vulnerabilities-catalog?field_cve=CVE-2026-114625), [The Hacker News](https://thehackernews.com/2026/10/arista-warns-of-critical-velocloud-sql.html).

<a name="siemens-software-center-dll-side-loading-exploited-in-clickfix-campaign-cve-2026-110936"></a>

## Siemens Software Center: DLL side-loading exploited in ClickFix campaign

[Back to TOC](#table-of-contents) · **[Detailed guide](details/siemens-software-center.md):** [Detection](details/siemens-software-center.md#detection) · [Remediation](details/siemens-software-center.md#remediation) · [Verification](details/siemens-software-center.md#verification) · [Timeline](details/siemens-software-center.md#timeline)

**CVEs:** [CVE-2026-110936](https://www.cve.org/CVERecord?id=CVE-2026-110936)

**[CVE-2026-110936](https://www.cve.org/CVERecord?id=CVE-2026-110936): Siemens CVSS 4.0 8.4 High, but Siemens CVSS 3.1 6.7 Medium (both local, high privilege); in CISA KEV**

**CISA KEV:** Listed — added 2026-10-20, federal due date 2026-11-03.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private report | Unknown | Credited to Jose Oregon (Huntress Labs); no date given. |
| Siemens advisory SSA-580366 | 2026-10-15; time/TZ unknown | CVE published 14:01 UTC. |
| Fix V4.0.9.8 added to advisory | 2026-10-17; time/TZ unknown | SSA V1.1. The release date of the build itself is not established. |
| Active exploitation and IOCs | 2026-10-19; time/TZ unknown | Siemens ProductCERT blog post. Exploitation start date unknown. |
| CISA KEV addition | 2026-10-20 (date only) | Due 2026-11-03; no forensic triage required. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

Siemens Software Center versions before V4.0.9.8 load DLLs from an uncontrolled search path. Attackers bundled a **genuine, signed** copy (version 3.5.8.7) with malicious DLLs and delivered it as `AllMyBasic.msi` through the "Romulus" ClickFix campaign.

**Worst case:** Malware runs under a trusted Siemens-signed process on Windows PCs, including PCs that never had Siemens software. Siemens does not describe the payload's full capabilities.

**Exploitation:** Confirmed by Siemens. Siemens says no Siemens system or update channel was breached.

**Am I impacted?** You have two separate things to check:

- **Your own installations:** any Siemens Software Center older than 4.0.9.8.
- **The campaign:** `SiemensSoftwareCenter.exe` running from `AppData\Local\Programs`, started by `msiexec`. Other signs are an `SM Software Provisioning Service` folder, `activate.bak` or `statinfosta.DB` next to the executable, `AppData\Local\FTSuite\ftc.uml`, or connections to `96.62.218[.]59` or `wizardexpensive[.]com`.

A valid Siemens signature does **not** clear a file. The [detail guide](details/siemens-software-center.md#read-only-host-check-powershell) has read-only PowerShell checks.

**Patch:** Update to **V4.0.9.8 or later**. Starting the application installs the update automatically. Download Siemens software only from official sources, and block the published IOCs. Patching your own copy does not stop attackers from dropping an old signed copy, so keep hunting by folder and behaviour. If you find an infection, isolate the PC, stop the process, remove the start-up entry and task, and reset passwords.

Sources: [Siemens SSA-580366](https://cert-portal.siemens.com/productcert/html/ssa-580366.html), [Siemens exploitation blog](https://productcert.siemens.com/news/2026/10/19/active-exploitation-of-cve-2026-110936-in-siemens-software-center/), [CVE record](https://cveawg.mitre.org/api/cve/CVE-2026-110936), [CISA KEV](https://www.cisa.gov/known-exploited-vulnerabilities-catalog?field_cve=CVE-2026-110936).

<a name="pan-os-authenticated-management-interface-rce-cve-2026-0322"></a>

## PAN-OS: authenticated management interface RCE

[Back to TOC](#table-of-contents) · **[Detailed guide](details/pan-os.md):** [Detection](details/pan-os.md#detection) · [Remediation](details/pan-os.md#remediation) · [Verification](details/pan-os.md#verification) · [Timeline](details/pan-os.md#timeline)

**CVEs:** [CVE-2026-0322](https://www.cve.org/CVERecord?id=CVE-2026-0322)

**[CVE-2026-0322](https://www.cve.org/CVERecord?id=CVE-2026-0322) — Palo Alto Networks CVSS 4.0: 8.6 High (8.5 if management is limited to a jump box); NVD CVSS 3.1: 7.2 High; CISA KEV**

**CISA KEV:** Listed — added 2026-10-14, federal due date 2026-10-17.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery | Unknown | Found internally by Palo Alto Networks. |
| Vendor disclosure and most fixes | 2026-10-14 16:00 UTC | Hotfix builds listed for 10.2 through 12.2. |
| CISA KEV addition | 2026-10-14; time/TZ unknown | Federal due date 2026-10-17. |
| PAN-OS 11.2.16 published | 2026-10-15 18:30 UTC | The only fix for 11.2.14–11.2.15. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

A code-injection flaw in the PAN-OS management interface lets an **authenticated** administrator-level attacker run code as **root**. It affects PA-Series and VM-Series firewalls and **Panorama**. Cloud NGFW and Prisma Access are not affected.

**Worst case:** someone who already holds management credentials, or reaches the interface with stolen ones, takes full control of the firewall or Panorama, including its secrets and policy. The vendor does not claim unauthenticated exploitation.

**Exploitation:** Palo Alto Networks reports "very limited exploitation" and lists three source IPs in its advisory FAQ.

**Am I impacted?** Run `show system info` on each firewall and Panorama and compare `sw-version` with the [fixed-build table](details/pan-os.md#inventory-and-version). Then check whether the management interface, or any dataplane interface with a management profile, can be reached from untrusted networks. Exposure to the internet is the highest-risk case.

**Patch:** Upgrade to the fixed build for your branch, for example 12.2.4, 12.1.10-h2, 11.2.16, 11.1.16-h3, 10.2.18-h12, or the listed intermediate hotfixes. There is no workaround. Restrict management access to trusted IPs or a jump box now. Threat IDs 510046/510047 give only limited coverage, and only with management traffic decrypted.

Sources: [Palo Alto Networks advisory](https://security.paloaltonetworks.com/CVE-2026-0322), [CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-0322), [NVD](https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-0322), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="cisco-secure-email-gateway-amp-attachment-path-traversal-cve-2026-76519"></a>

## Cisco Secure Email Gateway: AMP attachment path traversal

[Back to TOC](#table-of-contents) · **[Detailed guide](details/cisco-seg.md):** [Detection](details/cisco-seg.md#detection) · [Remediation](details/cisco-seg.md#remediation) · [Verification](details/cisco-seg.md#verification) · [Timeline](details/cisco-seg.md#timeline)

**CVEs:** [CVE-2026-76519](https://www.cve.org/CVERecord?id=CVE-2026-76519)

**[CVE-2026-76519](https://www.cve.org/CVERecord?id=CVE-2026-76519) — Cisco CVSS 3.1: 9.8 Critical; Cisco SIR: Critical; CISA KEV**

**CISA KEV:** Listed — added 2026-10-14, federal due date 2026-10-17.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery | Unknown | Found by Cisco during internal security scanning. |
| Fixed AsyncOS builds first listed | 2026-09-14 16:00 GMT | September hardening release; it did not name this CVE until 2026-10-14. |
| Cisco learns of exploitation | 2026-10 (exact day not established) | Per Cisco PSIRT. |
| Cisco advisory | 2026-10-14 16:00 GMT | `cisco-sa-esa-afw-zqYJkjxp`. |
| CISA KEV addition | 2026-10-14; time/TZ unknown | Federal due date 2026-10-17. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

A path traversal in how the gateway's AMP **File Reputation** feature handles attachments lets an unauthenticated attacker write files and run commands as **root**, simply by sending an email through the gateway. No recipient needs to click anything.

**Worst case:** root on the mail gateway, with access to mail flow, credentials and cluster SSH keys, which can lead to compromise of other cluster members.

**Exploitation:** Cisco confirms active exploitation. Cisco contacted Secure Email Cloud customers where it found malicious activity.

**Am I impacted?** A physical or virtual Secure Email Gateway is affected only if **File Reputation is enabled on a mail policy** *and* **Content Scanner Tools is older than 25.3.0.5525** (check with `contentscannerstatus`). **Secure Email and Web Manager and Secure Web Appliance are not affected**, though SEWM has separate CVEs in the September hardening release. Run Cisco's `grep "System Security" system_logs` check on every cluster member.

**Patch:** Update Content Scanner Tools to **25.3.0.5525+**, which needs no reboot, or upgrade AsyncOS to **15.5.5-014** or **16.5.0-780**; 16.0 must migrate to a fixed release. There are no workarounds. Secure Email Cloud has already been fixed by Cisco. If the appliance may be compromised, preserve evidence before upgrading and rebuild as Cisco directs.

Sources: [Cisco advisory](https://sec.cloudapps.cisco.com/security/center/content/CiscoSecurityAdvisory/cisco-sa-esa-afw-zqYJkjxp), [Cisco hardening release](https://sec.cloudapps.cisco.com/security/center/content/CiscoSecurityAdvisory/cisco-sa-hardening-esa-dfCrfXkm), [Cisco CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-76519), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="siteguard-server-edition-root-command-injection-via-statistics-feature-cve-2026-106931"></a>

## SiteGuard Server Edition: root command injection via statistics feature

[Back to TOC](#table-of-contents) · **[Detailed guide](details/siteguard.md):** [Detection](details/siteguard.md#detection) · [Remediation](details/siteguard.md#remediation) · [Verification](details/siteguard.md#verification) · [Timeline](details/siteguard.md#timeline)

**CVEs:** [CVE-2026-106931](https://www.cve.org/CVERecord?id=CVE-2026-106931)

**[CVE-2026-106931](https://www.cve.org/CVERecord?id=CVE-2026-106931): JPCERT/CC (CNA) and vendor CVSS 4.0 8.5 High and CVSS 3.0 7.8 High; vendor label 緊急 (urgent) and JVN label "Critical"; in CISA KEV**

**CISA KEV:** Listed — added 2026-10-20, federal due date 2026-10-23.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | The developer reported the flaw to IPA; no date given. |
| Vendor notice to support-contract customers | 2026-09-29; time/TZ unknown | Customers with direct support contracts were told about the flaw and the upgrade or patch. |
| Public vendor advisory, JVN and JPCERT/CC alert | 2026-10-14; time/TZ unknown | Exploitation already confirmed by the vendor. CVE published 04:45 UTC. |
| CISA KEV addition | 2026-10-20 (date only) | Due 2026-10-23; forensic triage required. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

SiteGuard Server Edition is EG Secure Solutions' host-based web application firewall (WAF) for Apache httpd, Nginx and IIS, and is widely used in Japan. Its **statistics feature**, enabled by default, has an OS command injection flaw. The published CVSS vectors are **local, low-privilege** (AV:L/PR:L). The reviewed sources do not explain how attackers in the wild reached the feature.

**Worst case:** Arbitrary OS commands run as **root or SYSTEM** on the web server.

**Exploitation:** The vendor and JVN say exploitation has been confirmed. They publish no IOCs, start date or attribution.

**Am I impacted?** You are affected if you run Ver2.20 or later with statistics enabled and your version is below:

- **Ver8.00 Update 5** for Apache, Nginx and IIS
- **Ver7.00 Update 6** for Apache and Nginx on FreeBSD

IIS Ver3.10 through Ver4.00 Update 4 are not affected. Check the version and the statistics setting in the SiteGuard web administration console.

**Patch:** First, download the diagnostic information (診断情報) from the console and store it elsewhere, because updating may erase attack traces. Then update to the fixed version. If you cannot upgrade, apply the vendor's statistics-file patch, which is also available for end-of-life versions, or disable the statistics feature (JPCERT/CC workaround). Treat affected hosts as possibly compromised.

Sources: [EG Secure Solutions advisory (Japanese)](https://www.eg-secure.co.jp/siteguard/news/alert-202610-1), [JVN#88474777](https://jvn.jp/en/jp/JVN88474777/), [JPCERT-AT-2026-0032](https://www.jpcert.or.jp/at/2026/at260032.html), [CVE record](https://cveawg.mitre.org/api/cve/CVE-2026-106931), [CISA KEV](https://www.cisa.gov/known-exploited-vulnerabilities-catalog?field_cve=CVE-2026-106931).

<a name="windows-shell-mark-of-the-web-bypass-zero-day-cve-2026-96951"></a>

## Windows Shell: Mark of the Web bypass zero-day

[Back to TOC](#table-of-contents) · **[Detailed guide](details/windows-shell.md):** [Detection](details/windows-shell.md#detection) · [Remediation](details/windows-shell.md#remediation) · [Verification](details/windows-shell.md#verification) · [Timeline](details/windows-shell.md#timeline)

**CVEs:** [CVE-2026-96951](https://www.cve.org/CVERecord?id=CVE-2026-96951)

**[CVE-2026-96951](https://www.cve.org/CVERecord?id=CVE-2026-96951) — Microsoft CVSS 3.1: 8.8 High; vendor severity: Important; Microsoft: Exploited: Yes; CISA KEV**

**CISA KEV:** Listed — added 2026-10-13, federal due date 2026-10-16.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | MSRC credits external researchers but gives no report dates. |
| Microsoft disclosure and Windows updates | 2026-10-13 07:00 PDT (UTC−07:00) | October 2026 Patch Tuesday; exploited as a zero-day. |
| CVE record published | 2026-10-13 19:01:26 UTC | Microsoft CNA record. |
| CISA KEV addition | 2026-10-13; time/TZ unknown | Federal due date 2026-10-16. Not the date exploitation started. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

A command-injection flaw in Windows Shell lets a crafted file or link evade **Mark of the Web (MOTW)** protections. The user must open the file or click the link, for example from email or instant messaging. Microsoft also lists Outlook.com, which it fixed on the service side.

**Worst case:** a malicious download or attachment runs without the usual SmartScreen or Protected View warnings, as the signed-in user. It is a bypass that enables a follow-on payload, not user-free remote code execution.

**Exploitation:** Microsoft reports exploitation detected but has published no actor, campaign or IOCs.

**Am I impacted?** Every supported Windows 10, Windows 11 and Windows Server 2012 R2–2025 branch below the October fixed build. Examples: 24H2 `26100.9711`, 25H2 `26200.9711`, 23H2 `22631.7652`, 22H2 `19045.7807`, Server 2022 `20348.5761`, Server 2025 `26100.33650`. Read `CurrentBuild` and `UBR` from the registry as shown in the [detail guide](details/windows-shell.md#establish-exposure). A device that has not reported recently counts as unknown.

**Patch:** Install the October 2026 cumulative update for each branch and reboot. KBs: 24H2/25H2/26H2 KB5127648; 26H1 KB5127646; 23H2 KB5126653; Windows 10 21H2/22H2 KB5126657; 1809/Server 2019 KB5126651; 1607/Server 2016 KB5126868; Server 2022 KB5126655; Server 2025 KB5126646; Server 2012 R2 KB5126836. Attachment filtering and ASR rules reduce risk but do not replace the update.

Sources: [Microsoft advisory](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-96951), [Microsoft CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-96951), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json), [Rapid7 analysis](https://www.rapid7.com/blog/post/em-patch-tuesday-october-2026/).

<a name="ivanti-connect-secure-authentication-bypass-to-command-execution-cve-2026-104935"></a>

## Ivanti Connect Secure: authentication bypass to command execution

[Back to TOC](#table-of-contents) · **[Detailed guide](details/ivanti-connect-secure.md):** [Detection](details/ivanti-connect-secure.md#detection) · [Remediation](details/ivanti-connect-secure.md#remediation) · [Verification](details/ivanti-connect-secure.md#verification) · [Timeline](details/ivanti-connect-secure.md#timeline)

**CVEs:** [CVE-2026-104935](https://www.cve.org/CVERecord?id=CVE-2026-104935), [CVE-2026-111357](https://www.cve.org/CVERecord?id=CVE-2026-111357)

**[CVE-2026-104935](https://www.cve.org/CVERecord?id=CVE-2026-104935) — Ivanti (CNA) CVSS 3.1: 8.6 High (the advisory labels the vector CVSS 3.0); no NVD score of its own; CISA KEV (forensic triage required)**

**CISA KEV:** Listed — added 2026-10-13, federal due date 2026-10-16. The chained root escalation [CVE-2026-111357](https://www.cve.org/CVERecord?id=CVE-2026-111357) is not listed (catalog 2026.10.23).

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Partial internal discovery and fix | 2026-07 (exact day not established) | Ivanti fixed "a portion" in 25.1.3.0 and was backporting it. |
| Exploitation start | 2026-10-03; time/TZ unknown | Earliest exploitation observed by Volexity (UTA0576) against 22.8R2.4. |
| Fixed releases 25.1.1.2 / 22.8R2.5 | 2026-10-05 / 2026-10-12; time/TZ unknown | Release dates from Ivanti's advisory. Volexity says the patches were released October 13. |
| Ivanti public advisory | 2026-10-13; time/TZ not shown | Discloses limited exploitation. |
| CVE record published | 2026-10-13 15:31:07 UTC | CNA metadata. |
| CISA KEV addition | 2026-10-13 (date only) | Due 2026-10-16. |
| Chained privilege escalation [CVE-2026-111357](https://www.cve.org/CVERecord?id=CVE-2026-111357) | 2026-10-15 20:56:58 UTC | Assigned by the MITRE CNA (CVSS 3.1: 7.0); fix not confirmed in reviewed sources. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

A spoofed internal-routing header (`X-DSCGI-PATH`) sent to the public `welcome.cgi` login script reaches a protected CGI. Combined with a file-write race in `wu.cgi`, this lets an unauthenticated attacker execute commands on the Connect Secure VPN appliance.

**Worst case:** Unauthenticated command execution on the VPN edge. In the wild, it was chained with a separate root escalation, and attackers stole LDAP credentials, searched for LAPS passwords and BitLocker keys, sniffed traffic, and exfiltrated data.

**Exploitation status:** Ivanti, CISA and Volexity confirm zero-day exploitation. The chain runs largely in memory and erases log entries, so Ivanti's Integrity Checker Tool **may not detect it**. Confirming compromise requires memory and network forensics.

**Am I impacted?** Check each appliance's running version. Affected versions are **25.1.1.1 and prior, 25.1.2.2 and prior, and 22.8R2.4 and prior**. **22.7R2.14 and prior are not affected.** The CNA description's "before 25.1.3.0" is shorthand; 25.1.1.2 and 22.8R2.5 also fix the issue. Hunt for `welcome.cgi` requests carrying `X-DSCGI-PATH` headers and for Volexity's indicators.

**Patch:** Update to **25.1.1.2**, **25.1.3.0/25.1.3.1** (requires the ISA4500/6500/8500 platform), or **22.8R2.5**. Ivanti recommends that 22.8 customers move to 25.1, because 22.7 and 22.8 reach end of life on 2027-01-31. If compromise is suspected, follow Ivanti's recovery steps (factory reset or rebuild, then reset all passwords, certificates and API keys) and investigate Active Directory.

Sources: [Ivanti advisory](https://hub.ivanti.com/s/article/Security-Advisory-Ivanti-Connect-Secure-CVE-2026-104935?language=en_US), [Ivanti CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-104935), [CISA alert](https://www.cisa.gov/news-events/alerts/2026/10/13/cisa-urges-patching-newly-exploited-vulnerability-ivanti-connect-secure), [Volexity analysis](https://www.volexity.com/blog/2026/10/13/a-series-of-unauthenticated-events-chained-exploitation-of-ivanti-connect-secure-zero-days/), [CVE-2026-111357 record](https://cveawg.mitre.org/api/cve/CVE-2026-111357), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="atlassian-data-center-unauthenticated-web-root-file-read-cve-2026-21589"></a>

## Atlassian Data Center: unauthenticated web-root file read

[Back to TOC](#table-of-contents) · **[Detailed guide](details/atlassian-dc.md):** [Detection](details/atlassian-dc.md#detection) · [Remediation](details/atlassian-dc.md#remediation) · [Verification](details/atlassian-dc.md#verification) · [Timeline](details/atlassian-dc.md#timeline)

**CVEs:** [CVE-2026-21589](https://www.cve.org/CVERecord?id=CVE-2026-21589)

**[CVE-2026-21589](https://www.cve.org/CVERecord?id=CVE-2026-21589): Atlassian CVSS 4.0 9.3 Critical; NVD CVSS 3.1 7.5 High; in CISA KEV**

**CISA KEV:** Listed — added 2026-10-15, federal due date 2026-10-18.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | Not stated in the reviewed sources. |
| Atlassian advisory and fixed releases | 2026-10-05; time/TZ unknown | Out-of-band advisory. CVE published 2026-10-05 21:30 UTC. |
| watchTowr technical analysis | 2026-10-06; time/TZ unknown | Root cause, PoC URLs and a Crowd credential chain. |
| First exploitation attempts | 2026-10-06 (per SANS ISC) | Honeypots saw the published PoC URLs. |
| CISA KEV addition | 2026-10-15 (date only) | Due 2026-10-18; forensic triage required. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

A shared Atlassian web-resource library turns `::` back into `/`. That lets an unauthenticated attacker read any file inside the application's web root, as long as they know its exact path. It cannot list directories or read files outside the Tomcat context. The affected products are Bitbucket, Confluence, Jira Software, Jira Service Management, Bamboo and Crowd Data Center, plus Crucible and Fisheye. Atlassian has patched its Cloud products; no Cloud customer action is required.

**Worst case:** It depends on configuration. watchTowr read the plaintext Crowd application password from Jira's `WEB-INF/classes/crowd.properties`, used it to call Crowd's API, and added a user to `jira-administrators`.

**Exploitation:** Scanning with the published PoC URLs began within about a day of the advisory, and CISA lists the flaw in KEV. A KEV listing does not tell you whether your own instance was read.

**Am I impacted?** Check the exact version of every node, mirror and Crowd server against Atlassian's per-branch fixes. A lower version on a different release line is not fixed. End-of-life Server editions get no fix. Search access, proxy and WAF logs with Atlassian's regex using the [read-only log search](details/atlassian-dc.md#access-log-search-read-only).

**Patch:** Fixed versions by product:

- Bitbucket: 9.4.26, 10.2.8, 10.5.1
- Confluence: 9.2.26, 10.2.19
- Jira Software: 9.12.40, 10.3.26, 11.3.12
- Jira Service Management: 5.12.40, 10.3.26, 11.3.12
- Bamboo: 10.2.24, 12.1.12
- Crowd: 6.3.7, 7.0.3, 7.1.7, 7.2.4
- Crucible and Fisheye: 4.9.15

Until you can upgrade, take the instance off the internet and apply Atlassian's WAF, `RewriteValve` or `urlrewrite.xml` mitigation on every node. If you may have been exposed, rotate secrets stored in the web root.

Sources: [Atlassian advisory](https://confluence.atlassian.com/security/cve-2026-21589-arbitrary-file-access-vulnerability-impacts-multiple-products-1870495748.html), [CVE record](https://cveawg.mitre.org/api/cve/CVE-2026-21589), [NVD](https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-21589), [CISA KEV](https://www.cisa.gov/known-exploited-vulnerabilities-catalog?field_cve=CVE-2026-21589), [watchTowr analysis](https://labs.watchtowr.com/you-wont-hear-about-these-even-in-myths-atlassian-jira-confluence-and-more-pre-auth-arbitrary-file-read-cve-2026-21589), [SANS ISC](https://isc.sans.edu/diary/Scans+for+Atlassian+vulnerablity+CVE202621589/33406/).

<a name="ahsaycbs-authentication-bypass-and-command-injection-chain-cve-2026-105133-and-cve-2026-105134"></a>

## AhsayCBS: authentication bypass and command injection chain

[Back to TOC](#table-of-contents) · **[Detailed guide](details/ahsaycbs.md):** [Detection](details/ahsaycbs.md#detection) · [Remediation](details/ahsaycbs.md#remediation) · [Verification](details/ahsaycbs.md#verification) · [Timeline](details/ahsaycbs.md#timeline)

**CVEs:** [CVE-2026-105133](https://www.cve.org/CVERecord?id=CVE-2026-105133), [CVE-2026-105134](https://www.cve.org/CVERecord?id=CVE-2026-105134)

**[CVE-2026-105133](https://www.cve.org/CVERecord?id=CVE-2026-105133) — VulDB CVSS 3.1: 7.3 High; VulDB CVSS 4.0: 6.9 Medium per the CNA record, 5.5 Medium as displayed by NVD with `E:P`. [CVE-2026-105134](https://www.cve.org/CVERecord?id=CVE-2026-105134) — VulDB CVSS 3.1: 10.0 Critical; CVSS 4.0: 10.0 (CNA) / 9.3 (NVD display). Both in CISA KEV.**

**CISA KEV:** Listed — both CVEs added 2026-10-14, federal due date 2026-10-17.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| CVE records published | 2026-10-04 05:15–05:30 UTC | VulDB CNA; dated its own advisory 2026-10-03. Public exploit stated. |
| Exploitation observed | 2026-10-07 23:20:15 UTC | Huntress; webshells and XMRig miners. |
| v10 hotfix 10.3.4.45 | 2026-10-10 per Ahsay (Huntress: 2026-10-12) | Sources disagree on the date. |
| v7–v9 hotfix 9.15.2.70 | 2026-10-12; time/TZ unknown | v7/v8 first upgrade to 9.15.0.0. |
| CISA KEV addition | 2026-10-14; time/TZ unknown | Federal due date 2026-10-17. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

AhsayCBS is a backup server used mainly by MSPs. Attackers chain the two flaws: an authentication bypass in `checkSysPwd`, then OS command injection via `/rps/api/json/UpdateReceivers.do`. Together they give unauthenticated remote code execution (SYSTEM on the Windows hosts Huntress investigated).

**Worst case:** an attacker fully controls the backup server and can reach customers' backups, add malicious replication receivers, and plant webshells.

**Exploitation:** Huntress observed attacks from October 7, against five organizations by October 8. Ahsay began receiving partner reports on October 9.

**Am I impacted?** The CVE record's range ("up to 10.3.2; 10.3.4 unaffected") is **wrong**. Huntress showed 10.3.4 is affected, and Ahsay says the earlier 10.3.4.0 and 9.15.2.59 patches did not fully fix the flaws. Treat any v7–v10 server without the hotfix as affected, especially if its console is reachable from the internet. Check for the [Ahsay and Huntress IOCs](details/ahsaycbs.md#indicators-to-check-read-only).

**Patch:** v10: apply hotfix **10.3.4.45** or later. v7–v9: apply **9.15.2.70** (v7/v8 first upgrade to 9.15.0.0). Reboot after either. Ahsay says these fully address both CVEs. A later hardening hotfix (Oct 22) and v10.3.6 are additional hardening. If the server shows indicators, rebuild it as Ahsay describes rather than patching in place.

Sources: [Ahsay status and IOCs](https://www.ahsay.com/en/company/announcements/ahsaycbs-vulnerability-status-update), [Ahsay hotfix alert](https://www.ahsay.com/en/company/announcements/patch-cve-105133-105134-update), [VulDB CNA record 105133](https://cveawg.mitre.org/api/cve/CVE-2026-105133), [VulDB CNA record 105134](https://cveawg.mitre.org/api/cve/CVE-2026-105134), [Huntress research](https://www.huntress.com/blog/ahsaycbs-flaws-exploit), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="netscaler-saml-memory-overflow-denial-of-service-cve-2026-88779"></a>

## NetScaler: SAML memory overflow denial of service

[Back to TOC](#table-of-contents) · **[Detailed guide](details/netscaler.md):** [Detection](details/netscaler.md#detection) · [Remediation](details/netscaler.md#remediation) · [Verification](details/netscaler.md#verification) · [Timeline](details/netscaler.md#timeline)

**CVEs:** [CVE-2026-88779](https://www.cve.org/CVERecord?id=CVE-2026-88779), [CVE-2026-88771](https://www.cve.org/CVERecord?id=CVE-2026-88771)

**[CVE-2026-88779](https://www.cve.org/CVERecord?id=CVE-2026-88779) — NetScaler (CNA) CVSS 4.0: 8.7 High; NVD CVSS 3.1: 7.5 High; Citrix severity: High; CISA KEV**

**CISA KEV:** Listed — added 2026-10-04, federal due date 2026-10-07. The companion code-injection flaw [CVE-2026-88771](https://www.cve.org/CVERecord?id=CVE-2026-88771) was listed earlier (added 2026-09-27, due 2026-09-30).

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | Citrix credits JPMorgan Chase, Bishop Fox and watchTowr; no report date. |
| Citrix bulletin CTX697174 and fixed builds | 2026-10-03 (Citrix labels it "PST") | Initial publication with fixed builds for all supported branches. |
| CVE record published | 2026-10-04 02:35:35 UTC | CNA `datePublic` 2026-10-04 02:19 UTC. |
| CISA KEV addition | 2026-10-04 (date only) | Due 2026-10-07. Not the exploitation start date. |
| CISA alert links it to [CVE-2026-88771](https://www.cve.org/CVERecord?id=CVE-2026-88771) | 2026-10-09; time/TZ unknown | CISA says it "may" be used to force a reboot that runs code injected through CVE-2026-88771. |
| Rapid7 chained-intrusion analysis | 2026-10-19; time/TZ unknown | Describes an early-October root compromise using both CVEs. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

A memory-bounds flaw lets an unauthenticated network attacker crash NetScaler ADC or Gateway authentication when the appliance acts as a **SAML Service Provider or Identity Provider**. Appliances without SAML configured do not meet Citrix's precondition.

**Worst case:** On its own, an authentication outage (denial of service) with no data-integrity impact, according to Citrix. In unpatched deployments, attackers have used the crash and reboot to execute commands injected through **CVE-2026-88771**, leading to root, web shells, and configuration and key theft (Rapid7).

**Exploitation status:** CISA lists the CVE in KEV and its ADP SSVC entry shows active exploitation. Rapid7 documents chained use in the wild. The exploitation start date is unknown.

**Am I impacted?** Check `show ns version` (read-only) on every node, including HA pairs and FIPS/NDcPP builds. Affected builds are those **before 14.1-73.41, 13.1-64.28, 14.1-73.41 FIPS, or 13.1-37.282 (FIPS/NDcPP)**. Then search the configuration for `add authentication samlAction` or `add authentication samlIdPProfile`. End-of-life branches are not covered by the bulletin. Customer-managed appliances only; Citrix-managed cloud services are updated by Cloud Software Group.

**Patch:** Upgrade to the fixed build for your branch. This update is separate from the CTX697096 fixes for CVE-2026-88771 through [CVE-2026-88778](https://www.cve.org/CVERecord?id=CVE-2026-88778), and both are needed. If compromise is suspected, preserve evidence before updating, run Citrix's IoC script, and rotate secrets after restoring a known-good backup.

Sources: [Citrix CTX697174](https://support.citrix.com/support-home/kbsearch/article?articleNumber=CTX697174), [NetScaler CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-88779), [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-88779), [CISA alert](https://www.cisa.gov/news-events/alerts/2026/09/27/critical-zero-day-vulnerabilities-exploited-citrix-netscaler-adc-gateway), [Rapid7 analysis](https://www.rapid7.com/blog/post/ra-netscaler-intrusions-chaining-cve-2026-88771-and-cve-2026-88779/), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="fortimail-unauthenticated-file-write-cve-2026-104286"></a>

## FortiMail: unauthenticated file write

[Back to TOC](#table-of-contents) · **[Detailed guide](details/fortimail.md):** [Detection](details/fortimail.md#detection) · [Remediation](details/fortimail.md#remediation) · [Verification](details/fortimail.md#verification) · [Timeline](details/fortimail.md#timeline)

**CVEs:** [CVE-2026-104286](https://www.cve.org/CVERecord?id=CVE-2026-104286)

**[CVE-2026-104286](https://www.cve.org/CVERecord?id=CVE-2026-104286) — Fortinet CVSS 3.1: 9.8 Critical; Fortinet severity: Critical; CISA KEV (forensic triage required)**

**CISA KEV:** Listed — added 2026-10-01, federal due date 2026-10-04.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | Found internally by Fortinet's Product Security team; no date given. |
| Exploitation start | Unknown; by 2026-10-01 | Fortinet reported exploitation in the wild at first publication. |
| Fortinet advisory FG-IR-26-175 | 2026-10-01; time/TZ unknown | Published with workarounds and IoCs; fixes then described as upcoming. |
| CVE record published | 2026-10-01 19:17:38 UTC | CNA metadata. |
| CISA KEV addition | 2026-10-01 (date only) | Due 2026-10-04. Not the exploitation start date. |
| Fixed releases / solution update | 2026-10-05; time/TZ unknown | Advisory "Solution update"; FortiMail Cloud moved to 7.6.7/8.0.2 GA that day. The release date of 7.4.9 was not established. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

A path traversal with NULL-byte mishandling in FortiMail's web interface lets an unauthenticated attacker write arbitrary files on the appliance through crafted HTTP/HTTPS requests. Fortinet's workaround targets the IBE (Identity-Based Encryption) service exposed through webmail.

**Worst case:** Arbitrary file write that Fortinet classifies as unauthorized code or command execution on the mail gateway. Fortinet's IoCs include a root cron command and a rogue remote **archive account**, which suggests a route for persistence and mail exfiltration.

**Exploitation status:** Fortinet confirms exploitation in the wild, and CISA lists the CVE in KEV. Fortinet's IoCs include two IP addresses and specific system-event and encryption-log entries (see the [detail guide](details/fortimail.md#indicators-published-by-fortinet)). Absence of these indicators does not establish that a unit is clean.

**Am I impacted?** Check the firmware of each FortiMail unit (`get system status`, read-only). Fortinet lists **8.0.0–8.0.1, 7.6.0–7.6.6, 7.4.0–7.4.8 and 7.2.0–7.2.9** as affected. The CNA record's machine-readable data conflicts with this and also names 7.0.x; treat 7.0 as unknown. Units are most at risk when IBE is enabled and webmail is reachable from the internet. FortiMail Cloud customers need no action, according to Fortinet.

**Patch:** Upgrade to **8.0.2+, 7.6.7+ or 7.4.9+**. 7.2 has no fix, so move to 7.4 or later. Until you can upgrade, disable IBE or restrict webmail to trusted networks. Patching does not remove attacker persistence. Preserve logs and hunt for the IoCs first.

Sources: [Fortinet FG-IR-26-175](https://fortiguard.fortinet.com/psirt/FG-IR-26-175), [Fortinet CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-104286), [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-104286), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="zammad-session-hijack-rce-and-root-escalation-chain-cve-2026-102489-and-cve-2026-102490"></a>

## Zammad: session hijack RCE and root escalation chain

[Back to TOC](#table-of-contents) · **[Detailed guide](details/zammad.md):** [Detection](details/zammad.md#detection) · [Remediation](details/zammad.md#remediation) · [Verification](details/zammad.md#verification) · [Timeline](details/zammad.md#timeline)

**CVEs:** [CVE-2026-102489](https://www.cve.org/CVERecord?id=CVE-2026-102489), [CVE-2026-102490](https://www.cve.org/CVERecord?id=CVE-2026-102490)

**[CVE-2026-102489](https://www.cve.org/CVERecord?id=CVE-2026-102489) — DIVD CVSS 4.0: 8.7 High (9.4 Critical when chained); NVD CVSS 3.1: 9.8 Critical. [CVE-2026-102490](https://www.cve.org/CVERecord?id=CVE-2026-102490) — DIVD CVSS 4.0: 8.5 High (9.4 Critical when chained); Zammad GHSA CVSS 4.0: 8.5 High; NVD CVSS 3.1: 7.8 High. Both in CISA KEV.**

**CISA KEV:** Listed — both CVEs added 2026-10-02, federal due date 2026-10-05.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| CVE-2026-102489 first reported to Zammad | 2026-08 (exact day not established) | According to Zammad. |
| Exploited against DIVD | 2026-09-21; time/TZ unknown | DIVD says the chain was used to breach its network. |
| DIVD report to Zammad | 2026-09-24; time/TZ unknown | Zammad says it received the LPE technical details only on 2026-10-01. |
| Public announcement | 2026-09-26; time/TZ unknown | DIVD limited disclosure, scanning and owner notification. |
| CVE records published | 2026-09-30 16:21 UTC | CNA `datePublic` 2026-09-29 20:00 UTC. |
| CISA KEV addition (both) | 2026-10-02 (date only) | Due 2026-10-05. Not the exploitation start date. |
| Zammad 7.2.2 (fixes CVE-2026-102490) | 2026-10-08 10:01 UTC (tag) | DEB/RPM local-root fix; GHSA published 10:19 UTC. |
| Zammad 6.5.5 (CVE-2026-102489 stopgap) | 2026-10-15; time/TZ unknown | Emergency fix for the unsupported 6.5 series; requires the new package repository. |
| **Last updated** | **2026-10-26 09:28 EDT (UTC−04:00)** | Added from CISA KEV backlog review and primary sources. |

**CVE-2026-102489** is a session hijack in Zammad that leads to remote code execution as the `zammad` user. It is exploitable on **6.3.0–6.5.4**. The bug is present in 7.0–7.1, but DIVD and Zammad say it cannot be exploited there, and 7.2.0 hardens the code. **CVE-2026-102490** affects only **DEB/RPM (packager.io) installs**: packaged services ran as root and executed files the `zammad` account could write. It affects every packaged version from 1.5.0 up to, but not including, 7.2.2. Source installs and official container images are not affected.

**Worst case:** Chained, the two flaws give an unauthenticated attacker root on the host, plus access to ticket data and stored integration credentials.

**Exploitation status:** DIVD reports the chain was used against its own network on 2026-09-21. CISA lists both CVEs in KEV. On its own, CVE-2026-102490 requires an existing foothold as the `zammad` user.

**Am I impacted?** Check the installed version and install method (`dpkg-query -W zammad`, `rpm -q zammad`, or container image tags; all read-only). Internet-exposed 6.3–6.5 instances are at highest risk. Any packaged install older than 7.2.2 is exposed to the root escalation. Run DIVD's log check for leaked session cookies in error logs. A clean result does not prove the instance was not compromised.

**Patch:** Upgrade self-hosted installs to **7.2.2 or later**. **6.5.5** closes only CVE-2026-102489 and requires switching package repositories. Zammad SaaS needs no action. After suspected compromise, rebuild the host, invalidate sessions, and rotate credentials.

Sources: [DIVD case](https://csirt.divd.nl/DIVD-2026-00015), [CNA record CVE-2026-102489](https://cveawg.mitre.org/api/cve/CVE-2026-102489), [CNA record CVE-2026-102490](https://cveawg.mitre.org/api/cve/CVE-2026-102490), [Zammad GHSA](https://github.com/zammad/zammad/security/advisories/GHSA-p97w-927q-8vxq), [Zammad statement](https://community.zammad.org/t/take-care-local-privilege-escalation-cve-2026-102490-is-reported-as-being-actively-exploited/21297/2), [Zammad 6.5.5](https://zammad.com/en/product/releases/6-5-5), [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json).

<a name="tailworm-tailscale-ssh-and-related-findings-under-review"></a>

## Tailscale / headscale: Tailworm - SSH and related findings under review

[Back to TOC](#table-of-contents) · **[Detailed guide](details/tailworm.md):** [Detection](details/tailworm.md#detection) · [Remediation](details/tailworm.md#remediation) · [Verification](details/tailworm.md#verification) · [Timeline](details/tailworm.md#timeline) · Vulnerability Info Site: [tailworm.com](https://tailworm.com/)

**CVEs:** No Tailworm-specific identifiers established in the reviewed sources.

**Several researcher-rated High findings; no Tailworm-specific CVE or vendor CVSS rating established**

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. No in-the-wild campaign was established in the reviewed sources.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Initial discovery/private reporting | Unknown | Exact dates and coordinated-reporting history not established. |
| Research testing | 2026-10-22–24; time/TZ unknown | Tailscale 1.104.2 and headscale 0.29.5; not complete affected ranges. |
| Serve correction merged | 2026-10-25 00:39:53 UTC | PR 21931 addresses cross-mount capability leakage. |
| Public circulation/vendor response | 2026-10-25; time/TZ unknown | Exact first-publication time unknown; original X headline needs qualification. |
| SSH forwarding correction merged | 2026-10-26 03:08:59 UTC | PR 21942; source merge is not a stable release. |
| Fixed stable release | Not established at 2026-10-26 12:44 UTC | Latest Tailscale stable found was 1.104.2; do not mark it or headscale 0.29.6 fixed for this report. |
| **Last updated** | **2026-10-26 08:47 EDT (UTC−04:00)** | Added with researcher/vendor distinctions and current source-fix status. |

Erica Windisch reports **11 findings across SSH, Serve/Funnel, an experimental connector and headscale/DERP**. This is not 11 confirmed unauthenticated Tailscale SSH vulnerabilities. The principal SSH escalation chains require **an already-authorized source, permitted target access and applicable forwarding**. Ordinary OpenSSH carried over Tailscale is distinct. This developing report is included at the owner's request, with its severity attribution visible.

**Worst case claimed/demonstrated in the lab:** Root-level execution on permitted SSH targets, privileged socket/file operations, credential interception and rogue-node enrollment in the tested configuration. Other findings concern SSRF-like destination access, resource exhaustion or capability-header leakage with different prerequisites. Claimed automated spread remains bounded by access policy; it is not unrestricted access to every tailnet device. No in-the-wild campaign was established in the reviewed primary material.

**Am I impacted?** Inventory the deployed Tailscale/headscale version, whether **embedded Tailscale SSH** is enabled, who can reach which target/local user, and whether forwarding is allowed. Separately inspect Serve/Funnel, experimental connectors and custom DERP/headscale exposure. `tailscale version` is an inventory clue, not a complete vulnerability check. See the [per-finding prerequisites](details/tailworm.md#interpret-the-eleven-findings-separately); some reported paths fail closed or require non-default configuration.

**Action now:** Tailscale recommends **`TS_SSH_DISABLE_FORWARDING=1` in the `tailscaled` service environment**, then restarting the daemon, where forwarding is unnecessary. Preserve another administrative path first. This mitigates forwarding chains, not every finding; tighten SSH scope and remove dangerous Serve socket mappings too. The vendor **does not recommend universally disabling SSH or the VPN**. Follow official release notes for shipped fixes rather than deploying arbitrary development builds or treating a merged PR as complete remediation.

Sources: [researcher report](https://tailworm.com/), [Tailscale engineering response](https://www.reddit.com/r/Tailscale/comments/1xeoj1l/recent_tailscale_vulnerability_reports/), [vendor mitigation](https://www.reddit.com/r/Tailscale/comments/1xeoj1l/comment/19rnk0ct2vkdc/), [SSH correction](https://github.com/tailscale/tailscale/pull/21942), [Serve correction](https://github.com/tailscale/tailscale/pull/21931), [user-provided X lead](https://x.com/IntCyberDigest/status/2114291878720151623).

<a name="authmask-microsoft-authenticator-for-android-token-theft"></a>

## Microsoft Authenticator for Android: AuthMask - token theft

[Back to TOC](#table-of-contents) · **[Detailed guide](details/authmask.md):** [Detection](details/authmask.md#detection) · [Remediation](details/authmask.md#remediation) · [Verification](details/authmask.md#verification) · [Timeline](details/authmask.md#timeline) · Vulnerability Info Site: [enclave.ai](https://enclave.ai/blog/authmask-we-made-microsoft-authenticator-hand-over-tokens)

**CVEs:** [CVE-2026-80097](https://www.cve.org/CVERecord?id=CVE-2026-80097)

**[CVE-2026-80097](https://www.cve.org/CVERecord?id=CVE-2026-80097) — Microsoft CVSS 3.1: 8.6 High; vendor severity: Important**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). No exploitation reported in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | Researcher confirms coordinated reporting, without exact dates. |
| Fixed Android build | 2026-07; day/time/TZ unknown | July availability reported by Cyber Security News; precise rollout date not established in reviewed primary sources. |
| Microsoft public disclosure | 2026-09-08 14:00 UTC | CNA public-disclosure timestamp; not an October zero-day. |
| Fixed-build correction | 2026-09-15; time/TZ unknown | MSRC corrected the fix build number. |
| AuthMask technical research | 2026-10-23; time/TZ unknown | Detailed Enclave disclosure; news lead published October 26. |
| **Last updated** | **2026-10-26 08:43 EDT (UTC−04:00)** | Added from the user-supplied lead and verified primary sources. |

An untrusted app on the same Android device can impersonate an installed Microsoft first-party app when requesting tokens from Authenticator's broker. The demonstrated setup has a signed-in work account. **Zero declared Android permissions does not mean remote exploitation without an installed malicious app.**

**Worst case:** Account-token disclosure and unauthorized delegated access to Microsoft 365 mail, files and calendars, with researcher-demonstrated scopes for changing authentication methods/passkeys. This can enable account persistence; it is not established device-root RCE or extraction of every user's TOTP secrets.

**Am I impacted?** Check the installed **Microsoft Authenticator for Android** version in Android App info or current EMM/Intune inventory, including work/personal profiles. Microsoft lists **6.0.0 through versions before 6.2606.4246** as affected. Check for signed-in work accounts and untrusted local apps; a benign-looking permission list is not clearance. Existing repository inventory scripts do not inspect Android apps; the [detail guide](details/authmask.md#establish-the-affected-device-and-app-profile) includes an optional read-only ADB version query.

**Patch:** Install **6.2606.4246 or a later supported release** through the official app channel and verify the installed build. For suspected abuse, preserve evidence, remove the malicious app, and coordinate Entra token/session revocation and authentication-method review from a clean device. Updating Authenticator alone does not end all existing access.

**Important source disagreement:** Microsoft's FAQ and CVSS **UI:R** require a user authentication flow; Enclave reports no further approval once the work account is signed in. Both require a malicious local app. MSRC's “Exploited: No” is its original-publication assessment, not a current guarantee.

Sources: [Microsoft advisory](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-80097), [Microsoft CNA record](https://cveawg.mitre.org/api/cve/CVE-2026-80097), [Enclave research](https://enclave.ai/blog/authmask-we-made-microsoft-authenticator-hand-over-tokens), [user-provided X lead](https://x.com/The_Cyber_News/status/2114630691896127947).

<a name="1-php2shell-unauthenticated-execution-below-your-application"></a>
<a name="php2shell-unauthenticated-execution-below-your-application"></a>

## PHP: PHP2Shell - unauthenticated execution below your application

[Back to TOC](#table-of-contents) · **[Detailed guide](details/php2shell.md):** [Detection](details/php2shell.md#detection) · [Remediation](details/php2shell.md#remediation) · [Verification](details/php2shell.md#verification) · [Timeline](details/php2shell.md#timeline) · Vulnerability Info Site: [php2shell.com](https://php2shell.com/)

**CVEs:** [CVE-2026-109618](https://www.cve.org/CVERecord?id=CVE-2026-109618), [CVE-2026-109619](https://www.cve.org/CVERecord?id=CVE-2026-109619), [CVE-2026-115560](https://www.cve.org/CVERecord?id=CVE-2026-115560)

**[CVE-2026-109618](https://www.cve.org/CVERecord?id=CVE-2026-109618) and [CVE-2026-109619](https://www.cve.org/CVERecord?id=CVE-2026-109619) — Critical, CVSS 4.0: 9.2 each**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Exploitation evidence exists outside KEV: pre-disclosure attempts and researcher-confirmed honeypot RCE (see below). Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | Not established in the public notices. |
| Advance notice | 2026-10-20; time/TZ unknown | Upcoming emergency release. |
| Public advisories and patches | 2026-10-21; time/TZ unknown | Both emergency PHP fixes released. |
| Earliest reported exploitation attempt | 2026-10-17; time/TZ unknown | Amazon honeypot telemetry, before disclosure; success not established. |
| Exploitation attempts using proofs of concept | 2026-10-21 ~02:00–08:00 UTC | Amazon; before public disclosure. |
| Upload-progress mitigation | 2026-10-23; time/TZ unknown | Separate follow-up issue; full patch not established in the reviewed notice. |
| Confirmed RCE against honeypots | 2026-10-24 15:35 UTC (first shell) | Researcher honeypots running PHP 8.4.26 Apache `mod_php`; consistent with CVE-2026-109618. |
| CISA KEV | Not listed (catalog 2026.10.23) | Checked 2026-10-26. |
| **Last updated** | **2026-10-26 09:27 EDT (UTC−04:00)** | Pre-disclosure exploitation attempts, confirmed honeypot RCE and follow-up fix status. |

These are PHP runtime flaws, not WordPress plugins or Laravel application bugs.

| Vulnerability | What fails | Worst-case result |
|---|---|---|
| **CVE-2026-109618** | Out-of-memory handling interrupts initialization; cleanup subsequently treats partially initialized request data as valid. | **Unauthenticated remote code execution**, with access to the PHP process’s files, credentials, and databases. |
| **CVE-2026-109619** | Request-owned global state survives after its backing memory is freed and can be reused by a later request in the same worker. | **Unauthenticated remote code execution** through stale memory. |

**Affected technology:** PHP serving web requests through Apache `mod_php`, PHP-FPM, CGI, FrankenPHP, or LiteSpeed. Think WordPress, Drupal, Joomla, Nextcloud, Laravel, and custom PHP applications—but inventory the actual runtime.

PHP identifies **`mod_php` as the highest-risk configuration**, with demonstrated exploitation before application code runs. Application authentication therefore cannot be assumed to protect the vulnerable path.

**Patch:** PHP **8.5.12, 8.4.27, 8.3.36, or 8.2.35**, or a distribution package explicitly backporting both fixes. Restart all affected workers. Older upstream branches need a verified vendor backport or migration.

**Exploitation status:** Amazon reported exploitation attempts from 2026-10-17, before disclosure. On 2026-10-24 a researcher documented successful RCE against PHP 8.4.26 `mod_php` honeypots. CISA’s earlier no-observed-success statement predates this evidence. Not in CISA KEV as of catalog 2026.10.23. [Investigate exposed systems from at least 2026-10-17](details/php2shell.md#exploitation-status).

### The October 23 follow-up matters

**[CVE-2026-115560](https://www.cve.org/CVERecord?id=CVE-2026-115560)** is an additional, narrowly conditional RCE risk involving session upload progress. It requires an unusual combination: configuring `php_binary` or `php_serialize`, switching to `php` at runtime, and then starting a session while upload progress remains enabled.

PHP recommends:

```ini
session.upload_progress.enabled=0
```

Apply it in the effective server/PHP configuration and restart workers. **Keep this mitigation even after installing the October 21 emergency releases** until the follow-up fix is available. As of 2026-10-26, PHP had not released a fix, full advisory or severity score for this issue, and its CVE record was not yet published; PHP says the advisory will accompany the next regular release.

**Am I impacted?** Inventory the PHP version and server integration used by each website. If it serves requests with an affected, unpatched PHP build, treat it as a patch candidate even when the application requires login. For a first local inventory:

```sh
sh stack-inventory.sh php
```

**These commands inspect CLI PHP only.** Confirm the web runtime separately using your hosting panel, FPM binary/package, Apache module package, or container build. Inspect its loaded INI files, FPM pool overrides, and per-site configuration; do not publish a `phpinfo()` endpoint. For CVE-2026-115560, check whether upload progress is enabled and whether application code changes `session.serialize_handler` from `php_binary`/`php_serialize` to `php` before `session_start()`. A CLI value alone cannot rule this out. If you cannot establish the effective settings, apply PHP's upload-progress mitigation.

Sources: [PHP advisories, including the October 23 update](https://www.php.net/archive/2026.php), [CISA alert](https://www.cisa.gov/news-events/alerts/2026/10/21/critical-vulnerabilities-php-require-immediate-patching), [Amazon pre-disclosure exploitation report](https://aws.amazon.com/blogs/security/amazon-threat-intelligence-identifies-php2shell-exploitation-prior-to-public-disclosure-in-madpot), [confirmed honeypot RCE](https://github.com/0x4D31/honeypot-data/blob/main/reports/php2shell/2026-10-24-confirmed-rce.md).

<a name="2-http2shell--node2shell-a-cross-stack-brotli-decoder-vulnerability"></a>
<a name="http2shell--node2shell-a-cross-stack-brotli-decoder-vulnerability"></a>

## Brotli consumers (Node.js, Bun, Python, .NET, FFmpeg, ClickHouse, Arrow and others): HTTP2Shell / Node2Shell / Brotli2Shell - cross-stack decoder corruption

[Back to TOC](#table-of-contents) · **[Detailed guide](details/brotli.md):** [Detection](details/brotli.md#detection) · [Remediation](details/brotli.md#remediation) · [Verification](details/brotli.md#verification) · [Timeline](details/brotli.md#timeline) · Vulnerability Info Site: [patchtheplanet.org](https://patchtheplanet.org/brotli), [research.jfrog.com](https://research.jfrog.com/post/brotli2shell-beyond-node2shell-and-http2shell/)

**CVEs:** [CVE-2026-111497](https://www.cve.org/CVERecord?id=CVE-2026-111497), [CVE-2026-105482](https://www.cve.org/CVERecord?id=CVE-2026-105482), [CVE-2026-105483](https://www.cve.org/CVERecord?id=CVE-2026-105483), [CVE-2026-106069](https://www.cve.org/CVERecord?id=CVE-2026-106069)

**[CVE-2026-111497](https://www.cve.org/CVERecord?id=CVE-2026-111497) — Node.js: High; Google’s CVSS 4.0 rating: 9.2 Critical**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Covers the Brotli CVE and the three Node.js CVEs below; no exploitation reported in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/report | Unknown | Not established in the public advisory. |
| Node announcement and patches | 2026-10-21; time/TZ unknown | Node security releases; Google Brotli library fixes also released this day. |
| Bun patch | 2026-10-22; time/TZ unknown | Bun 1.4.4. |
| Python Brotli patch | 2026-10-22 13:57 UTC | First PyPI upload of Brotli 1.2.1. |
| Python brotlicffi patch | 2026-10-22 16:19 UTC | First PyPI upload of brotlicffi 1.2.1.0. |
| Proxy fixes | Varies by component | Separate Envoy/Istio release dates in the detailed timeline; do not infer from Node's date. |
| Java / Ruby binding updates | 2026-10-24; time/TZ unknown | Brotli4j advisory identifies 1.24.0; Ruby maintainer confirms gem 0.9.1 fix. |
| PHP extension patch | 2026-10-24 23:49 UTC | php-ext-brotli 0.21.1 bundles fixed Brotli 1.2.1. |
| .NET advisory | 2026-10-25 19:06:12 UTC | Identifies fixed runtime/SDK builds; publication time is not first artifact availability. |
| JFrog downstream research | 2026-10-25; time/TZ unknown | FFmpeg/libjxl pointer corruption/crash, ClickHouse crash, Arrow/pyarrow loop and .NET native crash. |
| Downstream fix-status check | 2026-10-26 | libjxl and ClickHouse source fixes merged; published fixed artifacts unconfirmed. Arrow dependency-update PR remains open. |
| **Last updated** | **2026-10-26 10:00 EDT (UTC−04:00)** | Media/analytics exposure, demonstrated-impact limits and official detection tools. |

**HTTP2Shell, Node2Shell and Brotli2Shell are names for the same vulnerability, not separate CVEs.** The flaw resides in Google's native Brotli decoder and can affect any application embedding a vulnerable copy. Despite the names, it is **not specific to HTTP/2 or even HTTP**; exposure depends on decoding attacker-controlled Brotli data, including embedded file metadata and analytical buffers.

Malformed Brotli input can overflow an internal buffer in Google’s native decoder.

**Worst case:** **RCE, process-memory disclosure, or denial of service.** Researchers demonstrated RCE on a specific official Node.js Linux ARM64 build; that does not establish universal exploit reliability across every consumer.

**New downstream evidence:** [JFrog's research](https://research.jfrog.com/post/brotli2shell-beyond-node2shell-and-http2shell/) demonstrates pointer corruption and a cleanup crash in **FFmpeg through libjxl's JPEG XL metadata decoding**, a server crash from a **23 MB ClickHouse HTTP body**, an indefinite CPU loop from a **534-byte Arrow/pyarrow input**, and a native **.NET crash**. These are not complete RCE demonstrations for those products. Small inputs can still exhaust workers; HTTP body-size limits do not address every path.

**Affected technology:** Node.js, Bun, Python `Brotli` and `brotlicffi`, modern .NET, native Java/Scala/PHP/Ruby bindings, FFmpeg builds using affected libjxl, ClickHouse, Arrow/pyarrow, and other applications embedding the vulnerable C library. Envoy and Istio are relevant when configured to decompress Brotli. Language presence alone is not exposure: identify the actual decoder and input path. Pure-Go/Java/Rust implementations do not automatically inherit the C exploit.

The important exposure distinction:

- A server can be vulnerable when middleware decodes a request with `Content-Encoding: br`.
- A client or backend worker can be vulnerable when it fetches and automatically decompresses an attacker-controlled response.
- A media/data worker can reach Brotli inside JPEG XL metadata, `.br` files or Parquet, even without an HTTP encoding header. Arrow's bundled decoder is separate from Python's `Brotli` package.
- A plain Node HTTP server does not automatically decompress incoming bodies merely because it uses Node.

**Patch targets:**

| Component | Fixed release |
|---|---|
| Node.js | **22.23.4 / 24.22.1 / 26.12.1** |
| Bun | **1.4.4** |
| Python `Brotli` | **1.2.1** |
| Python `brotlicffi` | **1.2.1.0** |
| Google Brotli C library | **1.0.10 / 1.1.1 / 1.2.1**, depending on branch |
| Envoy | **1.36.12 / 1.37.8 / 1.38.6 / 1.39.3 / 1.40.0** |
| Istio | **1.29.9 / 1.30.6 / 1.31.2** |
| .NET runtime | **8.0.33 / 9.0.22 / 10.0.14**; preview **11.0.0-rc.3.26522.148** |
| Java / Scala `Brotli4j` and `native-*` artifacts | **1.24.0**; update the BOM/wrapper and native artifacts together |
| PHP `php-ext-brotli` | **0.21.1**; assess libcurl's decoder separately |
| Ruby `brotli` gem | **0.9.1+**; **0.9.0 is not fixed** |

**Fixed downstream artifacts not yet established:** [libjxl PR #5062](https://github.com/libjxl/libjxl/pull/5062) and [ClickHouse PR #127419](https://github.com/ClickHouse/ClickHouse/pull/127419) merge Brotli 1.2.1, but a source merge or listed backport number is not proof of a published package. [Arrow PR #55167](https://github.com/apache/arrow/pull/55167) remains open. Require supplier evidence that the deployed build includes fixed Brotli; otherwise pause affected untrusted processing or reject it before decoding. See [per-product inventory and release qualifications](details/brotli.md#inventory-by-language-and-deployment).

**Detection tools:** Use the [JFrog contextual scanner and Trail of Bits Brotli Checker guidance](details/brotli.md#official-researcher-detection-tools) for supported source/binary inspection. Matches identify candidate usage or code copies, not confirmed exploitation; empty results do not prove safety. Neither tool was run for this report.

Microsoft separately rates .NET's impact **8.1 High (CVSS 3.1)** and excludes .NET Framework from its advisory. Default ASP.NET Core/HttpClient configurations do not enable automatic Brotli decompression. Upgrade shared runtimes and restart; **rebuild/redeploy self-contained and NativeAOT apps**, which retain their own decoders. See the [language-by-language inventory and remediation](details/brotli.md#inventory-by-language-and-deployment), including Go/Rust and vendor-backport caveats.

**Envoy 1.36 and Istio 1.29 are unsupported branches**; a fix for this CVE does not restore general security support. Prefer a supported branch. See the [cross-stack guidance](https://patchtheplanet.org/brotli) for embedded clients and temporary decoding controls.

**Do not rely solely on a WAF or removing `br` from `Accept-Encoding`.** A malicious server can still return Brotli data, and an inbound WAF does not protect outbound response decoding.

### Other high-severity Node.js fixes in the same release

| CVE | Impacted behavior | Worst-case result |
|---|---|---|
| **[CVE-2026-105482](https://www.cve.org/CVERecord?id=CVE-2026-105482)** | DNS resolution silently truncates hostnames containing NUL bytes. | Hostname-allowlist bypass; potentially **SSRF or unintended connections**, depending on application logic. |
| **[CVE-2026-105483](https://www.cve.org/CVERecord?id=CVE-2026-105483)** | TLS hostname validation mishandles IP addresses written with fullwidth digits. | **Server impersonation / traffic interception** under the required certificate and connection conditions. Affects 24.x and 26.x. |
| **[CVE-2026-106069](https://www.cve.org/CVERecord?id=CVE-2026-106069)** | TLS validation and the platform resolver interpret noncanonical IPv4 addresses differently. | A connection can authenticate against the wrong IP identity, enabling **server impersonation**. |

The Node.js versions above fix all four high-severity issues.

**Am I impacted?** Check the runtime inside each deployed service, not just its lockfile:

```sh
sh stack-inventory.sh node
sh stack-inventory.sh bun
```

Run only the commands for runtimes you use. Compare with the patch table; for custom builds, confirm the embedded library or vendor backport. Trace incoming decompression middleware, direct Brotli calls, and outbound HTTP clients that automatically decompress responses. An affected decoder that receives attacker-controlled bytes is exposed; compression-only use does not establish exposure to this decoder bug. For Envoy/Istio, inspect the deployed proxy image/SBOM and effective decompressor configuration, including response decompression. An application-level Node update does not update the proxy.

For Python, **`python-package-inventory.py` reads distribution metadata without importing Brotli or Pillow**. Run it with a trusted Python 3.8+ interpreter and the actual deployed `site-packages` directory. `-I -S` avoids ordinary Python startup hooks and environment-based import paths. Supply every relevant package directory as an additional argument; it does not discover them automatically.

```sh
python3 -I -S python-package-inventory.py /path/to/venv/lib/python3.12/site-packages
```

Compare `Brotli` and `brotlicffi` with their fixed releases above. Missing metadata does not rule out vendored libraries, zip imports, system packages, or another virtual environment. Metadata is inventory evidence, not proof of binary integrity.

For optional response-compression inventory, run `python3 check_brotli.py https://example.com/` with your authorized URL. It sends two GET header probes without reading/decompressing bodies. **`BR_ADVERTISED` is not evidence of a vulnerable server, and `NOT_OBSERVED` is not clearance.** See [script usage, JSONL results and operating limits](details/brotli.md#response-header-inventory-script). Establish exposure through deployed versions and decoding paths, then [contain before the first decoder](details/brotli.md#contain-before-the-first-decoder).

For the **three additional Node.js vulnerabilities**, review whether user-controlled URLs/hostnames reach DNS resolution, hostname allowlists, or TLS clients. The NUL-truncation issue concerns DNS/allowlist handling; the two IP-format issues concern TLS identity validation. Even if Brotli is unused, these are independent reasons to install the Node security release.

Sources: [Node.js security release](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases), [Python advisory](https://github.com/advisories/GHSA-9v8h-qqgm-4m35), [HTTP2Shell naming and cross-stack scope](https://www.aikido.dev/blog/python-packages-vulnerable-node2shell-brotli-cve-2026-111497), [cross-ecosystem impact and patch matrix](https://thehackernews.com/2026/10/brotli-decoder-flaw-behind-nodejs-rce.html).

Additional patch sources: [Microsoft .NET advisory](https://github.com/dotnet/announcements/issues/494), [Brotli4j advisory](https://github.com/hyperxpro/Brotli4j/security/advisories/GHSA-x524-jrqf-vwq6), [PHP extension release](https://github.com/kjdev/php-ext-brotli/releases/tag/0.21.1), [Ruby maintainer confirmation](https://github.com/miyucy/brotli/issues/64).

<a name="3-gitlab-and-ruby-regex-compilation-becomes-code-execution"></a>

## GitLab and Ruby: regex compilation becomes code execution

[Back to TOC](#table-of-contents) · **[Detailed guide](details/gitlab-ruby.md):** [Detection](details/gitlab-ruby.md#detection) · [Remediation](details/gitlab-ruby.md#remediation) · [Verification](details/gitlab-ruby.md#verification) · [Timeline](details/gitlab-ruby.md#timeline)

**CVEs:** [CVE-2026-97229](https://www.cve.org/CVERecord?id=CVE-2026-97229), [CVE-2026-110264](https://www.cve.org/CVERecord?id=CVE-2026-110264), [CVE-2026-15723](https://www.cve.org/CVERecord?id=CVE-2026-15723), [CVE-2026-112212](https://www.cve.org/CVERecord?id=CVE-2026-112212)

**[CVE-2026-97229](https://www.cve.org/CVERecord?id=CVE-2026-97229) and [CVE-2026-110264](https://www.cve.org/CVERecord?id=CVE-2026-110264) — Critical, CVSS 3.1: 10.0 each**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Covers all four GitLab CVEs below; no exploitation reported in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/reports | Unknown | Exact dates not established. |
| First GitLab announcement/patches | 2026-10-12; time/TZ unknown | CVE-2026-97229. |
| Second GitLab announcement/patches | 2026-10-21; time/TZ unknown | CVE-2026-110264 and the identity flaws. |
| Partial upstream Ruby fix | 2026-10-22; time/TZ unknown | Ruby 4.0.8 is insufficient for the complete set. |
| Complete upstream Ruby fixes | 2026-10-23; time/TZ unknown | Ruby 4.0.9 / 3.4.12 / 3.3.13. |
| **Last updated** | **2026-10-26 08:36 EDT (UTC−04:00)** | Main-guide date presentation updated. |

Both vulnerabilities involve memory corruption while compiling specially crafted regular expressions.

| CVE | Scope | Worst-case result |
|---|---|---|
| **CVE-2026-97229** | GitLab CE/EE 19.2–19.4 before the October 12 fixes; attacker-controlled patterns in CI/CD configuration. | **Unauthenticated RCE** under the conditions described by GitLab. |
| **CVE-2026-110264** | Much broader: affected GitLab versions extend back to **7.0**. | **Unauthenticated RCE** through an integer overflow in regex compilation. |

A compromised GitLab server can expose source code and accessible CI/CD secrets and enable tampering with builds or deployments. The downstream reach depends on the credentials and permissions available to that installation.

**If you patched on October 12, patch again.** The first release does not cover the October 21 issue.

**GitLab fixes:** **19.5.1, 19.4.3, 19.3.6, 19.2.9, 19.1.9, 19.0.10, or 18.11.13** for the latest RCE. Prefer a currently supported branch; the older backports are not equivalent to receiving every other security fix. Follow GitLab’s required upgrade stops and migration guidance.

GitLab.com was patched by the vendor. GitLab Dedicated customers should verify the vendor’s listed internal release status.

### Related GitLab identity vulnerabilities

The October 21 supported-branch releases also address:

- **[CVE-2026-15723](https://www.cve.org/CVERecord?id=CVE-2026-15723) — High, 8.2:** an authenticated attacker can take over an LDAP-backed account when **OmniAuth SAML and LDAP auto-linking are both enabled**.
- **[CVE-2026-112212](https://www.cve.org/CVERecord?id=CVE-2026-112212) — High, 7.5:** OAuth/OIDC discovery cache poisoning can redirect authentication flows to attacker-controlled infrastructure, risking **credential or authentication-data disclosure**.

For these fixes, use **19.3.6, 19.4.3, or 19.5.1**, or later supported releases.

### Ruby applications need their own update

The underlying Onigmo bugs are not exclusive to GitLab. Ruby applications are exposed when they compile **attacker-controlled regex patterns**, rather than merely matching attacker-controlled text against developer-written patterns.

**Patch:** Ruby **4.0.9, 3.4.12, or 3.3.13**. Ruby 4.0.8 is insufficient for the complete set. Neither regex timeouts nor pattern-length limits reliably mitigate compilation bugs.

**Am I impacted?** For self-managed GitLab, obtain the deployed CE/EE version from the instance's Help page or, on a Linux-package installation:

```sh
sudo sh /path/to/stack-inventory.sh gitlab
# Separately deployed Ruby applications: use their actual runtime/container.
sh stack-inventory.sh ruby
```

Compare GitLab against the October 21 fixed release for its branch; do not stop after checking the narrower October 12 affected range. For other Ruby applications, trace user-supplied patterns into `Regexp.new`/`Regexp.compile` or interpolated regex construction. Matching untrusted text with a fixed developer-supplied pattern is a different condition. A shell's `ruby -v` does not establish GitLab's bundled Ruby version.

For **CVE-2026-15723**, inspect the effective identity configuration for both OmniAuth SAML and LDAP auto-linking; both must be enabled for the described takeover path. For **CVE-2026-112212**, inspect GitLab's discovery endpoints and reverse-proxy/shared-cache behavior; this is not limited to GitLab acting as an external OIDC client. Do not infer safety for either identity issue merely from the RCE patch status of an older backport branch; use a supported release covering all listed fixes.

GitLab now links threat-detection rules from both release notices. Use the [detailed detection guidance](details/gitlab-ruby.md#use-gitlabs-threat-detections) to correlate native worker crashes and suspicious CI/render requests; no alert does not prove no compromise.

Sources: [October 12 GitLab advisory](https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-4-2-released/), [October 21 GitLab advisory](https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-5-1-released/), [Ruby advisory](https://www.ruby-lang.org/en/news/2026/10/23/regexp-fixes-for-gitlab-cves/).

<a name="4-pillow-untrusted-images-reach-native-memory-corruption-and-command-execution"></a>

## Pillow: untrusted images reach native memory corruption and command execution

[Back to TOC](#table-of-contents) · **[Detailed guide](details/pillow.md):** [Detection and affected ranges](details/pillow.md#detection) · [Remediation](details/pillow.md#remediation) · [Verification](details/pillow.md#verification) · [Timeline](details/pillow.md#timeline)

**CVEs:** [CVE-2026-96639](https://www.cve.org/CVERecord?id=CVE-2026-96639), [CVE-2026-112398](https://www.cve.org/CVERecord?id=CVE-2026-112398), [CVE-2026-112900](https://www.cve.org/CVERecord?id=CVE-2026-112900), [CVE-2026-112393](https://www.cve.org/CVERecord?id=CVE-2026-112393), [CVE-2026-112403](https://www.cve.org/CVERecord?id=CVE-2026-112403)

**Multiple vulnerabilities; ratings range from Moderate to Critical**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Covers all five CVEs below; no exploitation reported in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/reports | Unknown | Exact dates not established. |
| Fixed release and release notes | 2026-10-16; time/TZ unknown | Pillow 13.0.0. |
| Individual advisories published | 2026-10-17 UTC; time unknown | Five highlighted advisories, published after the release. |
| Advisory revisions | 2026-10-19 UTC; time unknown | Several advisory records revised, including [CVE-2026-112403](https://www.cve.org/CVERecord?id=CVE-2026-112403) to maintainer High; not another package release. |
| **Last updated** | **2026-10-26 09:27 EDT (UTC−04:00)** | Corrected CVE-2026-112403 maintainer severity. |

Pillow is common in Python upload handlers, thumbnail services, document conversion, and machine-learning pipelines. Several independent paths matter:

| Vulnerability | Trigger / condition | Severity and worst case |
|---|---|---|
| **[CVE-2026-96639](https://www.cve.org/CVERecord?id=CVE-2026-96639)** | Processing successive image frames with different modes reuses incompatible native storage. | **Critical, 9.8:** memory disclosure, crashes, and demonstrated **RCE in specific runtime profiles**. |
| **[CVE-2026-112398](https://www.cve.org/CVERecord?id=CVE-2026-112398)** | Crafted FlashPix images reach JPEG decoding when optional `olefile` support is installed. | **Critical:** heap corruption and potential **RCE**. The published command-execution reproduction uses a constrained, ASLR-disabled environment. |
| **[CVE-2026-112900](https://www.cve.org/CVERecord?id=CVE-2026-112900)** | Attacker-controlled EPS filename passed to installed Ghostscript. | Maintainer **Moderate**, CVE score **9.2**: **command execution**. Filename control—not just malicious image contents—is the important prerequisite. |
| **[CVE-2026-112393](https://www.cve.org/CVERecord?id=CVE-2026-112393)** | Saving compressed TIFF output to an in-memory file object. | Maintainer **High**, CVE score **9.2**: heap corruption; **RCE demonstrated with a separate address-disclosure flaw**. |
| **CVE-2026-112403** | Thumbnailing/draft decoding of crafted lossless JPEGs. | Maintainer **High** (revised), CVE score **9.2** Critical: heap overflow and demonstrated **crash/DoS**; do not treat RCE as established for this specific path. |

**Patch:** **Pillow 13.0.0**, which also fixes additional memory-disclosure and resource-exhaustion bugs. It requires **Python 3.11 or newer**.

Extension filtering alone is insufficient: Pillow recognizes formats from content. Update the actual processing workers and their images, not just the frontend accepting uploads.

**Am I impacted?** Run `python3 -I -S python-package-inventory.py /path/to/worker/site-packages` against every image-processing worker's package directories. If Pillow is present and you cannot verify the 13.0.0 fixes or vendor backports, inspect these paths and prioritize an upgrade:

| Check your application for… | Relevant issue |
|---|---|
| Iterating/seeking through untrusted multi-frame images | CVE-2026-96639 |
| Opening untrusted FlashPix files with `olefile` installed | CVE-2026-112398 |
| Opening EPS with attacker-influenced filenames and Ghostscript available | CVE-2026-112900 |
| Saving compressed TIFF to `BytesIO` or another in-memory file object | CVE-2026-112393 |
| Thumbnail/draft processing of untrusted lossless JPEGs | CVE-2026-112403 |

The metadata script also lists `olefile`. On Linux/macOS, `command -v gs` checks whether Ghostscript is on the worker user's PATH; also inspect configured absolute executable paths. A missing optional dependency only addresses that particular path, not the other Pillow flaws. Do not upload malicious test images to production to establish exposure.

Sources: [Pillow release notes](https://pillow.readthedocs.io/en/stable/releasenotes/13.0.0.html), [multi-frame advisory](https://github.com/python-pillow/Pillow/security/advisories/GHSA-v9pv-5gc8-w2m6), [FlashPix advisory](https://github.com/python-pillow/Pillow/security/advisories/GHSA-5x8w-8jj5-q52h), [additional vulnerability details](https://thehackernews.com/2026/10/critical-flaw-in-pythons-popular-pillow.html).

<a name="5-plex2shell-a-home-server-compromise-chain-is-being-exploited"></a>
<a name="plex2shell-a-home-server-compromise-chain-is-being-exploited"></a>

## Plex Media Server: Plex2Shell - exploited remote code execution chain

[Back to TOC](#table-of-contents) · **[Detailed guide](details/plex2shell.md):** [Detection](details/plex2shell.md#detection) · [Remediation](details/plex2shell.md#remediation) · [Verification](details/plex2shell.md#verification) · [Timeline](details/plex2shell.md#timeline) · Vulnerability Info Site: [zmain.info](https://zmain.info/blog/plex2shell)

**CVEs:** [CVE-2026-96652](https://www.cve.org/CVERecord?id=CVE-2026-96652), [CVE-2026-96654](https://www.cve.org/CVERecord?id=CVE-2026-96654), [CVE-2026-96655](https://www.cve.org/CVERecord?id=CVE-2026-96655), [CVE-2026-96656](https://www.cve.org/CVERecord?id=CVE-2026-96656)

**Researcher’s combined-chain rating: Critical, CVSS 3.1: 9.8**

**CISA KEV:** Listed — all four CVEs added 2026-10-20; federal due date 2026-10-23 for -96654 and -96656, 2026-11-03 for -96652 and -96655.

**Individual CNA (CISA) CVSS 3.1 ratings:** -96652 4.3, -96654 6.5, -96655 4.3 (Medium); -96656 7.2 (High).

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Initial discovery | Unknown | Researcher does not date discovery. |
| Private report | 2026-07-27; time/TZ unknown | All four vulnerabilities. |
| Fixed beta released | 2026-08-03; time/TZ unknown | PMS 1.43.3.10861; Plex Pass beta. |
| Fixed general release | 2026-08-04; time/TZ unknown | Available to everyone; NAS packaging can lag. |
| Vendor security notice | 2026-09-01 18:30 UTC | Plex urges updating to 1.43.3; CVEs not yet published. |
| CISA advisory and CVE records | 2026-09-23 15:39 UTC | VA-26-266-01; CVE records 16:06–16:07 UTC. |
| Public chain disclosure | 2026-10-16; time/TZ unknown | Researcher's technical publication. |
| Exploitation attempts reported | From 2026-10-17; time/TZ unknown | One day after the public proof of concept. |
| Vendor confirms active exploitation | 2026-10-19 20:17 UTC | Plex: “actively and widely exploited.” |
| CISA KEV addition (all four) | 2026-10-20; date only | Due 2026-10-23 for -96654/-96656 and 2026-11-03 for -96652/-96655; forensic triage required for -96656. |
| **Last updated** | **2026-10-26 09:27 EDT (UTC−04:00)** | Vendor-confirmed exploitation, CISA KEV addition and per-CVE ratings. |

The chain combines:

1. **CVE-2026-96652:** unauthenticated SSRF.
2. **[CVE-2026-96654](https://www.cve.org/CVERecord?id=CVE-2026-96654):** plugin-function abuse to obtain the owner’s administrator token.
3. **[CVE-2026-96655](https://www.cve.org/CVERecord?id=CVE-2026-96655):** authenticated SSRF for payload retrieval.
4. **[CVE-2026-96656](https://www.cve.org/CVERecord?id=CVE-2026-96656):** attacker-controlled file placement and execution through the codec path.

**Worst case:** **Unauthenticated RCE** on Plex Media Server, exposing whatever media, mounts, credentials, and network access its service account holds.

**Exploitation status:** Plex confirmed on 2026-10-19 that the chain is being actively and widely exploited, including miners and Linux proxy/backdoor payloads. CISA added all four CVEs to KEV on 2026-10-20. Plex says any server below 1.43.3.10861 that was reachable from the internet may be compromised; see [vendor indicators](details/plex2shell.md#detection).

**Patch:** **Plex Media Server 1.43.3.10861 or later**; use the latest supported release. Check NAS-packaged installations and containers, which may lag upstream. Remove unnecessary public exposure on port 32400.

If an exposed installation remained vulnerable, investigate for compromise. **Installing the update does not remove an existing backdoor.**

**Am I impacted?** In Plex Web, select the actual server and check **Settings → General** for the **Media Server** version—not the web, desktop, or mobile client version. Compare it with **1.43.3.10861**. Repeat for each NAS package/container and verify the running server after updating.

Inspect Plex's Remote Access settings, router port forwards/UPnP mappings, reverse proxies, and VPN access. On a Linux host, run `sh linux-service-inventory.sh` and inspect the TCP 32400 output. It shows local listeners, **not** internet reachability, and a container may live in another network namespace. An unpatched server reachable by an attacker is a priority, including on a LAN. Use deployment history to establish whether it was exposed before patching; a clean-looking current version cannot rule out earlier compromise.

Sources: [researcher disclosure](https://zmain.info/blog/plex2shell), [exploitation reporting and fixed version](https://thehackernews.com/2026/10/hackers-exploit-plex2shell-flaws-to.html), [Plex security notice and exploitation update](https://forums.plex.tv/t/important-security-update-for-plex-media-server-v1-43-2-and-earlier/942319), [CISA KEV](https://www.cisa.gov/known-exploited-vulnerabilities-catalog).

<a name="6-nextclouds-built-in-collabora-code-server-unauthenticated-command-injection"></a>

## Nextcloud’s built-in Collabora CODE server: unauthenticated command injection

[Back to TOC](#table-of-contents) · **[Detailed guide](details/nextcloud-code.md):** [Detection](details/nextcloud-code.md#detection) · [Remediation](details/nextcloud-code.md#remediation) · [Verification](details/nextcloud-code.md#verification) · [Timeline](details/nextcloud-code.md#timeline)

**CVEs:** [CVE-2026-110447](https://www.cve.org/CVERecord?id=CVE-2026-110447)

**[CVE-2026-110447](https://www.cve.org/CVERecord?id=CVE-2026-110447) — Critical, CVSS 4.0: 9.2**

**CISA KEV:** Listed — added 2026-10-23, federal due date 2026-10-26.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Discovery | 2026-09; day/time/TZ unknown | Month established; initial private-report date unknown. |
| Fixed app released | 2026-09-11; time/TZ unknown | richdocumentscode 26.4.303; exact date attributed to reporting. |
| Community warning | 2026-10-03; time/TZ unknown | Predates the formal advisory. |
| Formal advisory | 2026-10-14; time/TZ unknown | Public vendor/CVE disclosure. |
| CISA KEV addition | 2026-10-23; date only | Due 2026-10-26; apply vendor mitigations per BOD 26-04 or discontinue use. Not the exploitation start date. |
| **Last updated** | **2026-10-26 09:27 EDT (UTC−04:00)** | CISA KEV addition. |

This affects the optional **Collabora Online – Built-in CODE Server** app, `richdocumentscode`, rather than every Collabora deployment.

An unauthenticated request to its proxy can execute an OS command **when the bundled CODE server is stopped**—for example, after a restart, crash, or upgrade.

**Worst case:** **RCE as the web-server user**, with potential access to Nextcloud data and credentials. Attacks planting webshells have been reported, and CISA added the flaw to its Known Exploited Vulnerabilities catalog on 2026-10-23 (due 2026-10-26).

**Patch:** `richdocumentscode` **26.4.303 or later**, or **remove the app**. The vendor explicitly warns that **disabling it is insufficient**.

**“Latest compatible” can still be vulnerable:** the app store lists 26.4.104 for Nextcloud 25–29, below the fix threshold. Upgrade EOL Nextcloud or remove the app; do not force an incompatible package. See [supported migration guidance](details/nextcloud-code.md#patch-or-migrate).

Standalone Collabora servers are not affected by this particular flaw. Nextcloud’s PHP runtime still needs the separate PHP2Shell fixes.

**Am I impacted?** Review Nextcloud's Apps administration page for **Collabora Online – Built-in CODE Server**, including disabled apps. From a typical Linux installation, adjusting the account and path:

```sh
sudo -u www-data sh /path/to/stack-inventory.sh nextcloud /var/www/nextcloud/occ
```

Find `richdocumentscode` and its version in both the enabled and disabled lists. Also inspect configured app directories for leftover copies containing its proxy even if the app is not registered. A copy older than **26.4.303** without a verified backport needs updating or removal. Confirm whether your reverse proxy can serve that app's PHP files. Do not stop CODE as a test: the stopped state is the dangerous condition, and an otherwise running server can enter it later. A standalone Collabora deployment without this app does not meet this flaw's component prerequisite.

Sources: [vendor advisory](https://github.com/CollaboraOnline/online/security/advisories/GHSA-g3vx-3m76-fghh), [exploitation reporting](https://www.bleepingcomputer.com/news/security/hackers-exploit-collabora-rce-flaw-to-backdoor-nextcloud-servers/), [CISA KEV](https://www.cisa.gov/known-exploited-vulnerabilities-catalog).

<a name="7-linux-ksmbd-serious-kernel-level-reports-but-not-every-linux-server"></a>
<a name="linux-ksmbd-serious-kernel-level-reports-but-not-every-linux-server"></a>

## Linux KSMBD: kernel memory disclosure and denial of service

[Back to TOC](#table-of-contents) · **[Detailed guide](details/ksmbd.md):** [Detection](details/ksmbd.md#detection) · [Remediation](details/ksmbd.md#remediation) · [Verification](details/ksmbd.md#verification) · [Timeline](details/ksmbd.md#timeline)

**CVEs:** No identifiers established in the reviewed sources; tracked as ZDI-CAN-33774 and ZDI-CAN-33549.

**ZDI-CAN-33774 and ZDI-CAN-33549 — ZDI rating: Critical, 9.0 each**

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. No exploitation reported in the reviewed sources.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery/reports | Unknown | Exact dates not established. |
| Public reports | 2026-10-21; time/TZ unknown | Both KSMBD findings. |
| Dispatch fix queued | 2026-10-21; time/TZ unknown | Maintainer branch; not a released distribution patch. |
| SMB Direct patch posted | 2026-10-23 10:36 UTC | Concrete patch sent to the mailing list. |
| SMB Direct patch reviewed | 2026-10-23 11:02 UTC | Positive review; not proof of delivery to your kernel. |
| Dispatch fix in mainline Git | 2026-10-26 01:47 UTC | Commit 68f410faedaf merged for 7.4-rc1; not yet in a tagged kernel. |
| SMB Direct fix committed | 2026-10-26 10:15 UTC | Maintainer branch (ksmbd-for-next), marked for stable; not yet in mainline. |
| Released kernel/NAS fixes | None established (as of 2026-10-26) | Newest kernel.org releases predate both fixes; no CVE or distribution advisory yet. |
| **Last updated** | **2026-10-26 09:27 EDT (UTC−04:00)** | Upstream fix commits; no released kernel fix yet. |

These affect **KSMBD, the in-kernel SMB server**. They do not imply that ordinary Samba installations or all Linux machines are vulnerable.

| Report | Exposure | Worst-case reported impact |
|---|---|---|
| **ZDI-CAN-33774** | Protocol-dispatch race reachable before authentication; stronger write paths involve share access. | Kernel memory corruption, potentially **RCE**. |
| **ZDI-CAN-33549** | SMB Direct with an RDMA-capable interface and a writable share. | Integer underflow leading to kernel buffer corruption and potentially **RCE**. |

Public demonstrations establish disclosure/crashes, **not successful RCE**. As of October 26, the dispatch-race fix is in mainline Git for 7.4-rc1 and the SMB Direct fix is in the maintainer branch marked for stable backport, but no released mainline, stable, distribution or NAS kernel containing either fix, and no CVE, was established; **a committed fix is not the same as a deployed distribution update**. Software RXE can supply RDMA even without a physical RDMA card. See [prerequisites and fix tracking](details/ksmbd.md#evaluate-the-two-prerequisites-independently).

**Action:** Identify whether you actually use KSMBD. Disable it if unnecessary, restrict access to trusted networks, and obtain an explicit remediation status from your kernel/NAS vendor. Never expose SMB directly to the internet.

**Am I impacted?** Run these read-only checks on the Linux/NAS host, not just inside an application container:

```sh
sh linux-service-inventory.sh
```

A port 445 listener alone does not identify KSMBD; Samba can use it too. Check kernel `CONFIG_SMB_SERVER`, KSMBD service/share configuration, and vendor documentation. An empty RDMA device listing does not settle the first report; RDMA/SMB Direct and a writable share are specific prerequisites for **ZDI-CAN-33549**. For **ZDI-CAN-33774**, assess KSMBD protocol access independently. Ask the vendor to map your exact kernel/firmware build to **both** reports; kernel version strings alone cannot confirm a fix.

Sources: [disclosure overview](https://thehackernews.com/2026/10/two-cvss-90-linux-ksmbd-rce-flaws.html), [October 23 maintainer discussion](https://lists.samba.org/archive/samba-technical/2026-October/141179.html).

<a name="8-wpsplinter-nearby-attackers-can-compromise-vulnerable-routers"></a>
<a name="wpsplinter-nearby-attackers-can-compromise-vulnerable-routers"></a>

## Broadcom legacy WPS: WPSplinter - nearby router compromise

[Back to TOC](#table-of-contents) · **[Detailed guide](details/wpsplinter.md):** [Detection](details/wpsplinter.md#detection) · [Remediation](details/wpsplinter.md#remediation) · [Verification](details/wpsplinter.md#verification) · [Timeline](details/wpsplinter.md#timeline) · Vulnerability Info Site: [qkaiser.github.io](https://qkaiser.github.io/broadcom-wps/)

**CVEs:** No identifiers established in the reviewed sources.

**Broadcom legacy WPS implementation — no CVE or standardized score published**

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. No exploitation reported in the reviewed sources.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Initial discovery | Unknown | Exact day not published. |
| First private report | 2026-07-18; time/TZ unknown | First Broadcom platform report. |
| Second private report | 2026-07-27; time/TZ unknown | Second platform report. |
| Public disclosure | 2026-10-16; time/TZ unknown | Technical research and conference presentation. |
| ISP mitigation update | 2026-10-20; time/TZ unknown | Provider-specific findings, not universal firmware clearance. |
| Fixed firmware releases | Not established | Obtain exact OEM/ISP build confirmation. |
| **Last updated** | **2026-10-26 08:36 EDT (UTC−04:00)** | Main-guide date presentation updated. |

A Wi-Fi attacker within radio range can exploit fragmented WPS message handling **without the network password or completing WPS enrollment**.

**Worst case:** **Memory disclosure and arbitrary code execution**, including root-level execution on demonstrated devices, Wi-Fi password theft, and access to the local network.

The affected component appears across numerous vendors and ISP gateways. **A Broadcom chipset alone does not establish vulnerability**; firmware and hardware revision matter.

**Action:** Check the researcher’s device list and ask the vendor/ISP about this specific issue. Install a confirmed fixed firmware or replace unsupported equipment. Do not assume the ordinary “disable WPS” toggle removes the vulnerable parser.

There is no universal firmware version to recommend. Older eCos-based devices may have no practical migration path.

The researcher's October 20 update reports Telenet unaffected, Proximus fleet-wide WPS mitigation with full patching pending, and Orange Belgium investigating. These are provider-specific findings, not clearance for every device or ordinary WPS toggle; see [temporary mitigation](details/wpsplinter.md#temporary-mitigation-must-remove-the-radio-attack-path).

**Am I impacted?** Record the router/access point's **manufacturer, exact model, hardware revision, firmware build, and ISP customization** from its label and management interface. Compare that tuple with the researcher's device guidance and your vendor's advisory. Include mesh nodes, extenders, and ISP-supplied gateways, not just your primary router.

A listed vulnerable model/build is actionable; an unlisted model is **unknown**, not cleared. Ask the vendor whether its firmware contains the vulnerable Broadcom WPS parser and which build fixes or removes it. Neither a MAC-address vendor lookup nor a “WPS disabled” screen proves remediation. There is no dependable generic read-only Python check for this firmware-level condition; avoid crash/exploit probes against your access point.

Source: [researcher’s WPSplinter advisory and device guidance](https://qkaiser.github.io/broadcom-wps/).

<a name="9-header-accordions-http3-compression-becomes-resource-exhaustion"></a>
<a name="header-accordions-http3-compression-becomes-resource-exhaustion"></a>

## HTTP/3 stacks: Header Accordions - compression-driven resource exhaustion

[Back to TOC](#table-of-contents) · **[Detailed guide](details/header-accordions.md):** [Detection](details/header-accordions.md#detection) · [Remediation](details/header-accordions.md#remediation) · [Verification](details/header-accordions.md#verification) · [Per-component timeline](details/header-accordions.md#timeline) · Vulnerability Info Site: [foxio.io](https://foxio.io/blog/header-accordions-qpack-amplification-attacks-against-http-3-servers)

**CVEs:** [CVE-2025-64702](https://www.cve.org/CVERecord?id=CVE-2025-64702), [CVE-2026-12523](https://www.cve.org/CVERecord?id=CVE-2026-12523), [CVE-2025-13945](https://www.cve.org/CVERecord?id=CVE-2025-13945)

**Multiple implementations; includes [CVE-2025-64702](https://www.cve.org/CVERecord?id=CVE-2025-64702), [CVE-2026-12523](https://www.cve.org/CVERecord?id=CVE-2026-12523), and [CVE-2025-13945](https://www.cve.org/CVERecord?id=CVE-2025-13945)**

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Covers the listed CVEs; component issues without CVEs cannot be listed. No exploitation reported in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Initial discovery | Unknown | Project-report dates are not necessarily discovery dates. |
| Project reports | 2025-11-09–2026-07-13; time/TZ unknown | Multiple implementations; see per-project timeline. |
| quic-go fix | 2025-11-21; time/TZ unknown | 0.57.0. |
| Wireshark fixes listed | By 2025-12-03; time/TZ unknown | 4.6.2 / 4.4.12 in the advisory. |
| quiche fix | 2026-07-14; time/TZ unknown | 0.29.3. |
| lsquic fix | 2026-07-15; time/TZ unknown | 4.9.0. |
| Combined public research | 2026-10-20; time/TZ unknown | Later than several component fixes. |
| Bun fix | 2026-10-22 10:11 UTC | Bun 1.4.4 (GitHub release). |
| Bun advisory | 2026-10-24 00:13 UTC | GHSA-cf8x-9m69-3gg3, vendor-rated High, no CVE; HTTP/3 server and opt-in HTTP/3 fetch client. |
| h3, aioquic/mitmproxy fixes | Not established (as of 2026-10-26) | No fixed releases found; h3 fix PRs still open. |
| **Last updated** | **2026-10-26 09:27 EDT (UTC−04:00)** | Bun HTTP/3 fix and remaining unfixed stacks. |

Small QPACK-compressed header blocks expand into disproportionate memory usage. Affected implementations enforce decoded-header limits too late, incompletely, or not at all.

**Worst case:** **Denial of service** through memory exhaustion, crashes, or CPU pinning—not established RCE or data theft.

Relevant software includes HTTP/3 deployments built on **quic-go, Cloudflare quiche, lsquic, Bun, aioquic/mitmproxy, and Rust’s `h3`**. Include quic-go **clients**, not only servers. Wireshark has a related crash during HTTP/3 capture decryption/dissection with keylog or embedded secrets, rather than a public-server attack surface.

**Fixed versions:** quic-go **0.57.0**, Cloudflare quiche **0.29.3**, lsquic **4.9.0**, Bun **1.4.4** (rebuild `bun build --compile` executables); Wireshark **4.6.2 / 4.4.12**. Several fixes predate October.

For affected stacks without a verified fix, disable HTTP/3 or apply the researcher’s stack-specific mitigation. Bun 1.4.4 fixes this HTTP/3 issue under [its own advisory](https://github.com/oven-sh/bun/security/advisories/GHSA-cf8x-9m69-3gg3), separate from Bun's Brotli advisory; include Bun's opt-in HTTP/3 `fetch` client.

**Am I impacted?** First identify **where HTTP/3 terminates**: CDN, load balancer, reverse proxy, or application. A CDN offering HTTP/3 does not prove that the origin uses it. Check each terminator's HTTP/3 configuration and its deployed library version against the researcher's implementation matrix. For a Go-based server, inspect the deployed executable without running it:

```sh
sh stack-inventory.sh go /path/to/deployed-server
```

Look for `github.com/quic-go/quic-go`, its version, and any replacement module. Missing build metadata is inconclusive; use the product's SBOM/build provenance or vendor advisory. For quiche, lsquic, Bun, Rust `h3`, or Python-based servers, check their corresponding build/lock metadata and actual deployed artifacts. A UDP 443 listener or an `Alt-Svc: h3` header is only a clue, not proof of this vulnerability. Wireshark users should check **Help → About** (or `tshark --version` if installed); its exposure comes from decoding captures, even without running an HTTP/3 server.

Source: [FoxIO research and implementation matrix](https://foxio.io/blog/header-accordions-qpack-amplification-attacks-against-http-3-servers).

<a name="10-beyondtrust-remote-support-an-already-exploited-appliance-vulnerability"></a>
<a name="beyondtrust-remote-support-an-already-exploited-appliance-vulnerability"></a>

## BeyondTrust Remote Support: exploited unauthenticated file operations

[Back to TOC](#table-of-contents) · **[Detailed guide](details/beyondtrust.md):** [Detection](details/beyondtrust.md#detection) · [Remediation](details/beyondtrust.md#remediation) · [Verification](details/beyondtrust.md#verification) · [Timeline](details/beyondtrust.md#timeline)

**CVEs:** [CVE-2026-102764](https://www.cve.org/CVERecord?id=CVE-2026-102764)

**[CVE-2026-102764](https://www.cve.org/CVERecord?id=CVE-2026-102764) — Critical: vendor CVSS 4.0 9.3; NVD CVSS 3.1 9.8**

**CISA KEV:** Listed — added 2026-10-16, federal due date 2026-10-19.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Attacker discovery | Unknown | Not established. |
| Confirmed exploitation | 2026-08-29; time/TZ unknown | Earliest vendor-confirmed activity, not proof of the first-ever attack. |
| Private alert | 2026-09-27; time/TZ unknown | Mandiant's initial note. |
| Vendor detection/reproduction | 2026-09-28; time/TZ unknown | Vendor identified incident and entry vector. |
| Patches released | 2026-10-08; time/TZ unknown | Self-hosted RS and precautionary PRA updates. |
| RS SaaS patching complete | By 2026-10-09; time/TZ unknown | Formal advisory's completion statement. |
| Public disclosure | 2026-10-15; time/TZ unknown | Coordinated advisory and research. |
| CISA KEV addition | 2026-10-16; date only | Due 2026-10-19; apply vendor mitigations per BOD 26-04 or discontinue use. Not the exploitation start date. |
| **Last updated** | **2026-10-26 09:27 EDT (UTC−04:00)** | CISA KEV addition and NVD severity attribution. |

Improper origin validation in internal messaging permits an unauthenticated remote attacker to perform file operations on affected Remote Support appliances.

**Affected:** Remote Support **26.2.3 and earlier**.

**Worst case:** The observed attack chain progressed to **root-level appliance compromise, credential theft, and lateral movement**. These are campaign outcomes, not merely the vendor’s narrow description of the initial file-operation primitive.

**Exploitation status:** Vendor-confirmed exploitation since 2026-08-29; CISA added it to the Known Exploited Vulnerabilities catalog on 2026-10-16 (due 2026-10-19).

**Patch:** Apply **BT26-05-RS**. Versions older than **24.3.1** must first upgrade to a version that can receive the patch. SaaS was patched by BeyondTrust. Privileged Remote Access operators should also follow the vendor’s precautionary guidance for shared code.

**Am I impacted?** In the appliance's administrative interface, record the **Remote Support product version and installed security-patch history**. If it is **26.2.3 or earlier**, verify installation of **BT26-05-RS** rather than assuming a base-version string reflects a hotfix. Check every appliance, including standby/failover nodes. For SaaS, confirm remediation with the vendor; for Privileged Remote Access, follow its separate precautionary guidance.

Review exposure and appliance/security logs back through the reported exploitation period beginning in August, using vendor investigation guidance. Do not run arbitrary scripts on a support appliance or treat a successful login/version query as a compromise check. If patch history is unavailable, ask BeyondTrust to verify the exact appliance build and remediation state.

Sources: [vendor advisory](https://www.beyondtrust.com/trust-center/security-advisories/bt26-05), [observed attack reporting](https://www.bleepingcomputer.com/news/security/beyondtrust-patches-zero-day-exploited-in-attacks-since-august/).

<a name="related-incidents-these-need-more-than-vulnerability-patching"></a>
<a name="am-i-impacted-by-the-related-incidents"></a>
<a name="emudhra--emsign"></a>

## TLS and code-signing trust stores: eMudhra / emSign - certificate-authority compromise

[Back to TOC](#table-of-contents) · **[Detailed guide](details/emudhra.md):** [Detection](details/emudhra.md#detection) · [Remediation](details/emudhra.md#remediation) · [Verification](details/emudhra.md#verification) · [Timeline and corrections](details/emudhra.md#timeline)

**CVEs:** [CVE-2026-111943](https://www.cve.org/CVERecord?id=CVE-2026-111943), [CVE-2026-114820](https://www.cve.org/CVERecord?id=CVE-2026-114820), [CVE-2026-115557](https://www.cve.org/CVERecord?id=CVE-2026-115557)

**Certificate-authority compromise — TLS impersonation and fraudulent code-signing trust.** This incident has no single incident-wide CVSS score; client-specific fixes have their own advisories, including Go **[CVE-2026-111943](https://www.cve.org/CVERecord?id=CVE-2026-111943)**.

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). The CA compromise itself has no CVE; the related Go [CVE-2026-111943](https://www.cve.org/CVERecord?id=CVE-2026-111943), Java [CVE-2026-114820](https://www.cve.org/CVERecord?id=CVE-2026-114820) and Python [CVE-2026-115557](https://www.cve.org/CVERecord?id=CVE-2026-115557) fixes are not listed. Absence from KEV is not evidence that exploitation has not occurred.

Eight intermediate CA private keys were trivially recoverable because of defective key generation. Attackers could issue fraudulent certificates accepted by clients that still trust the affected chains. **Worst case:** intercepted or modified TLS traffic and malicious code accepted under fraudulent signatures, depending on verifier policy and attacker positioning. This is not a general break of TLS cryptography.

**Affected technology:** OS/browser trust stores, Java and Python application bundles, containers, Go binaries, appliances and custom verifiers—not just sites using emSign certificates. Your own use of another certificate authority does not stop your clients from trusting a forged remote certificate.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Private discovery | 2026-10-17 16:27 UTC | Researcher recovered affected CA keys. |
| Private report | 2026-10-17 18:05 UTC | Notification to eMudhra and root programs. |
| OneCRL distribution complete | 2026-10-17 22:59 UTC | Firefox standard configurations; not every relying client. |
| Original intermediates revoked | 2026-10-18 09:24:32–09:38:46 UTC | CA revocation, not universal client enforcement. |
| Public incident record | 2026-10-18 12:06 UTC | Bugzilla incident opened. |
| Cross-certificate revocation | 2026-10-19 14:55 UTC | Sectigo reported completion. |
| Go patches released | 2026-10-19; time/TZ unknown | Go 1.27.3 / 1.26.10; rebuild deployed binaries. |
| Firefox/ESR releases | 2026-10-20; time/TZ unknown | Separate from earlier OneCRL delivery. |
| Android follow-up | 2026-10-21 08:29 UTC | Firefox Android 158.0.2. |
| Java follow-up alert | 2026-10-24; time/TZ unknown | [CVE-2026-114820](https://www.cve.org/CVERecord?id=CVE-2026-114820), Oracle CVSS 3.1 9.1 Critical; earlier emergency builds require further action. |
| CPython key-blocking releases | 2026-10-26; time/TZ unknown | [CVE-2026-115557](https://www.cve.org/CVERecord?id=CVE-2026-115557); runtime protection in `ssl`, separate from CA-bundle updates. |
| Chrome root removal | **Expected** 2026-10-27 morning PDT (UTC−07:00) | Google forecast for Chrome Root Store users; not completed rollout as of this update. |
| **Last updated** | **2026-10-26 09:26 EDT (UTC−04:00)** | Java follow-up, CPython fixes, alternate trust paths and detection guidance. |

Inventory client trust stores as well as your server certificates: operating-system stores, browsers, Java truststores, Python/application CA bundles, containers, and embedded clients can update independently. Match certificate fingerprints/serials and affected issuer chains against the incident record; a name containing “emSign” is not a precise affected-certificate test. Inspect Go build versions with `sh stack-inventory.sh go /path/to/deployed-binary` and compare with the fixed branches above. Updating the installed Go compiler does not repair existing binaries. For third-party appliances or opaque applications, obtain the vendor's trust-update status. A successful TLS connection is not proof that fraudulent chains are rejected.

The affected keys comprise **six TLS and two code-signing intermediates**, plus cross-signs. Include certificates affected by resulting root distrust, not just compromised issuers. Firefox Android needs **158.0.2 or later** for the follow-up. **CA revocation is not proof that a client enforces the block**; test the effective verifier. The vendor's October 26 statement still promises a full root-cause review.

**Remediation:** Update each independently managed trust store and replace certificates chaining through distrusted issuers. Rebuild/redeploy Go binaries with **1.27.3 / 1.26.10 or later supported fixes**; updating only the installed compiler leaves old binaries untouched. Review historical certificate and connection evidence when impersonation is suspected; trust updates cannot undo disclosed credentials or data.

**Do not stop at the first emergency update:**

- **Java / Scala:** require vendor release notes covering **JDK-8395690 / CVE-2026-114820**. The October 24 Oracle alert lists earlier emergency builds as affected. Follow the current [Java update/root-removal guidance](details/emudhra.md#java-and-scala), including the **Debian/Ubuntu Java keystore rebuild**. The [official offline checker](details/emudhra.md#java-use-the-official-offline-checker-with-its-actual-limits) locates named roots; it does not prove application-wide protection.
- **Python:** **3.15.2 / 3.14.10 / 3.13.18 / 3.12.16 / 3.11.18** add key blocking in `ssl`; the last three are source-only upstream releases. Independently update **certifi 2026.10.19**, **pip 26.2.2**, and other bundled tools. See [effective-store inventory and packaging limits](details/emudhra.md#python); native extensions can bypass Python's verifier.
- **Alternate chains:** removing `emSign ECC Root CA - G3` alone does not block Sectigo cross-signs under **AAA Certificate Services**. Check direct anchors and the vendor's current policy, not only root names. [Trust-path guidance](details/emudhra.md#trust-paths-and-what-each-mitigation-changes) distinguishes intermediate blocks, root removal and revocation.
- **Certificate owners:** prepare replacement chains before Google's **expected October 27 morning PDT** root removal. Legitimate certificates under the removed root may fail too. [Central controls and CT](details/emudhra.md#central-controls-ct-and-egress-limits) have coverage limits: a WAF, hostname allowlist or absence of CT evidence does not prove outbound TLS safety.

Sources: [Mozilla incident record](https://bugzilla.mozilla.org/show_bug.cgi?id=2083449), [Go security announcement](https://groups.google.com/g/golang-announce/c/66pojueaQek), [vendor statement](https://emudhra.com/en/post/certificate-security-incident). See the detailed guide for per-runtime checks and vendor trust-distribution guidance.

<a name="litellm"></a>

## LiteLLM: malicious release and credential theft

[Back to TOC](#table-of-contents) · **[Detailed guide](details/litellm.md):** [Detection](details/litellm.md#detection) · [Remediation](details/litellm.md#remediation) · [Verification](details/litellm.md#verification) · [Registry timeline](details/litellm.md#timeline)

**CVEs:** No incident-specific identifiers established in the reviewed sources.

**Supply-chain compromise — credential theft and arbitrary code execution.** This is a malicious release incident, not a software bug with one incident-wide CVSS score.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. This is a malicious-release incident; the vendor confirmed the compromise.

**Affected technology:** all seven **LiteLLM 1.107.0 PyPI wheels** and affected public container images, including floating tags during the incident. The payload included a credential stealer and remote-code loader. **Worst case:** execution as the workload account, stolen cloud/AI/database/CI secrets, and downstream compromise permitted by those credentials and mounts.

The corrected postmortem identifies an **exposed, unrevoked master key**, followed by theft of overprivileged GitHub tokens, as the entry point. Earlier root-cause speculation should not supersede that finding.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Master key exposed | 2026-05-27 18:53:14 UTC | Committed publicly and not revoked. |
| Attacker token extraction | 2026-10-10 21:27:10 UTC | Organization owner's GitHub OAuth token returned. |
| Malicious wheels published | 2026-10-21 11:39:51–11:40:13 UTC | Seven PyPI wheels. |
| Malicious images published | 2026-10-21 11:46:56 UTC | Public container releases. |
| Public discovery | 2026-10-21 12:06:41 UTC | Researcher issue opened. |
| PyPI quarantine | By 2026-10-21 13:23 UTC | Removal does not neutralize cached artifacts. |
| GHCR tags unavailable | By 2026-10-21 13:51 UTC | Different registry containment window. |
| Docker Hub containment | 2026-10-21 14:20 UTC | Affected tags removed or repointed. |
| Corrected postmortem | 2026-10-23 21:00 UTC | Supersedes earlier entry-point theories. |
| Vendor clarifications | 2026-10-24 UTC; time unknown | Clean-artifact and entry-point clarification. |
| Image-signing key changed | 2026-10-24 09:34:13 UTC (1.106.3 release) | New cosign key from commit `e82a3c6`; verifying with the old key fails. Backported to 1.103.8 / 1.104.6 / 1.105.4. |
| Later release 1.106.4 | 2026-10-25 09:32:43 UTC (PyPI) | Latest PyPI version; not a malware-cleanup patch. |
| Cleanup patch | Not applicable | 1.106.2 is a clean rollback target, not host recovery. |
| **Last updated** | **2026-10-26 09:27 EDT (UTC−04:00)** | New signing key and later clean releases. |

Inspect **historical** dependency manifests, CI install logs, registry digests, and deployment records for **1.107.0** and the malicious image digests in the incident guidance. A floating tag or today's package version cannot establish what ran during the incident. On a clean analysis host, run `python3 -I -S python-package-inventory.py /mnt/snapshot/path/to/site-packages` against a read-only mounted snapshot; use the clean host's interpreter, not the snapshot's. Do not run ordinary `python`, `pip`, or the LiteLLM CLI inside a suspected infected environment. Metadata/version matches identify candidates, not trustworthy integrity; compare artifact hashes with the vendor's indicators. If a malicious artifact executed, treat reachable secrets as exposed even when logs show no obvious exfiltration.

PyPI, GHCR and Docker Hub have different removal windows, and **cached artifacts remain dangerous after removal**. The vendor excludes its private enterprise release, not every public image used by an enterprise. The attacker used a signed official pipeline: signing alone did not establish trustworthy source or content. From 1.106.3 (and its backports), [verify images with the vendor's **new cosign key**](details/litellm.md#verification) from commit `e82a3c6` and update pinned keys in admission policies.

**Remediation:** Isolate affected environments and preserve evidence, then rebuild from verified clean artifacts and revoke reachable secrets at their issuers from a clean system. **Do not start with ordinary Python or `pip` in the suspected environment:** startup hooks can rerun malware. **1.106.2** was identified as a clean rollback target, **not a malware cleanup patch**; recovery must also cover detached loaders, poisoned caches, host/shared-mount access and already issued sessions.

Sources: [canonical attack-chain postmortem](https://docs.litellm.ai/blog/security-incident-oct-21-2026-attack-chain), [vendor incident response](https://docs.litellm.ai/blog/security-incident-oct-21-2026), [researcher evidence and vendor follow-up](https://github.com/BerriAI/litellm/issues/47826).

<a name="railway"></a>

## Railway: environment secret exposure

[Back to TOC](#table-of-contents) · **[Detailed guide](details/railway.md):** [Detection](details/railway.md#detection) · [Remediation](details/railway.md#remediation) · [Verification](details/railway.md#verification) · [Timeline and limits](details/railway.md#timeline)

**CVEs:** No incident-specific identifiers established in the reviewed sources.

**Platform-side secret exposure — credential abuse and downstream data/system compromise.** No single incident-wide CVSS score or local package patch describes this incident.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. This is a platform-side incident; the vendor confirmed the exposure.

**Affected technology:** Railway-hosted environment variables and integrations, plus the cloud, database, source-control, registry and API services authorized by those secrets. Attackers accessed internal systems and decrypted a subset of stored variables. **Worst case:** data disclosure, destructive changes or code execution in downstream systems, bounded by credential permissions—not only the Railway workload.

| Event | Date and time (timezone) | Notes |
|---|---|---|
| First reported internal detection | 2026-10-20 13:58 UTC | Not proof of the attacker's first access. |
| Public security disclosure | 2026-10-21 20:44:02 UTC | Page publication metadata/RSS. |
| Confirmed attacker eviction | 2026-10-22 03:32 UTC | Vendor containment claim, not customer credential recovery. |
| Provider recovery guides | 2026-10-22 00:43–00:47 UTC | Blog RSS. |
| Preliminary report | 2026-10-22 23:31:37 UTC | Page metadata/RSS; scope and forensic findings remain preliminary. |
| Deployment/login recovery guides | 2026-10-23 16:30 UTC | Blog RSS. |
| Local software patch | Not applicable | Issuer-side revocation and replacement of exposed credentials required. |
| **Last updated** | **2026-10-26 09:27 EDT (UTC−04:00)** | Exact publication times from vendor metadata. |

From a clean browser/session, review your projects, shared variables, environment-specific variables, deployment history, and Railway's incident notices. Identify credentials stored before October 21 and the external services they authorize. Do not export or print secret values to perform this inventory; variable names, owners, creation/history records, and provider key IDs are sufficient. If you cannot establish whether a still-valid credential was present during the window, include it in the vendor-recommended rotation. Audit the credential's provider for unexpected use; absence of suspicious logs does not prove it was not disclosed. There is no local package-version script that can rule out this server-side exposure.

The vendor's **preliminary** estimate is at most **1.85% of workspaces (approximately 100,000)**; precautionary provider revocations do not prove individual exposure. Include private registry credentials and existing authenticated sessions in recovery. Commits pushed during the deployment pause **were not queued**: explicitly deploy the intended reviewed revision. Source-code-access findings remain unresolved.

**Remediation:** Follow the precautionary recommendation to revoke and replace sensitive variables stored before October 21. Rotate at the **issuing provider**, update every consumer and redeploy, then verify old credentials and sessions no longer work. Editing `DATABASE_URL` or a dashboard variable alone does not change the actual database password. Preserve logs and investigate misuse; rotation cannot recover already exfiltrated data.

Sources: [initial disclosure](https://blog.railway.com/p/security-disclosure-wednesday-october-21st), [preliminary report](https://blog.railway.com/p/preliminary-report-october-security-incident), [deployment recovery guidance](https://blog.railway.com/p/security-disclosure-recommendation-recover-failing-deploys).

---

## What should I patch? A stack-based decision guide

**Apply every matching branch.** Most personal infrastructure uses more than one of these components.

```mermaid
flowchart TD
    A["Inventory hosts, containers, NAS apps, workers and CI"] --> B{"Compromised LiteLLM artifact,<br/>Railway secrets, or compromise indicators?"}
    B -->|Yes| C["Contain and investigate;<br/>rebuild affected systems and rotate secrets"]
    B -->|No| D["Continue stack checks"]
    C --> D

    D --> E{"What do you operate?<br/>Follow every matching branch"}
    E -->|Web apps and runtimes| F["Patch PHP, Node/Bun,<br/>Brotli, Pillow, GitLab, Ruby,<br/>Next.js, Laravel, Drupal and WordPress plugins;<br/>apply PHP upload mitigation"]
    E -->|Servers and appliances| I["Check Plex, Nextcloud CODE,<br/>KSMBD, HTTP/3, BeyondTrust,<br/>NGINX, curl, VM-host kernels<br/>and KEV-listed appliances;<br/>patch or contain affected features"]
    E -->|Media and analytics| O["Check FFmpeg/libjxl,<br/>ClickHouse and Arrow decoders;<br/>verify fixed supplier builds<br/>or pause untrusted processing"]
    E -->|Wi-Fi and Tailscale| J["Verify WPS firmware;<br/>restrict SSH and unneeded forwarding;<br/>track vendor fixes"]
    E -->|Android Authenticator| N["Update Authenticator;<br/>review work-account<br/>token exposure"]

    F --> L["Update trust stores;<br/>rebuild Go binaries"]
    O --> L
    I --> L
    J --> L
    N --> L
    L --> M["Restart/redeploy and verify<br/>the versions actually running"]
```

| Your stack | Minimum action |
|---|---|
| **Wasmtime embedders compiling untrusted Wasm** | Update the `wasmtime` crate to 36.0.19+, 48.0.7+, 49.0.4+ or 50.0.0+ (37–47 have no fix), rebuild and redeploy, recompile cached `.cwasm` modules, and check bundled copies in bindings and products. [Guide](details/wasmtime.md#remediation). |
| **Laravel apps using a `token` driver guard** | Update `laravel/framework` to 12.68.0+ or 13.29.0+ (move off 11.x and older), reload PHP-FPM, Octane and queue workers, and rotate `api_token` values if abuse is suspected. [Guide](details/laravel.md#remediation). |
| **Next.js (self-hosted or Vercel)** | Upgrade `next` to 16.4.1 (16.x) or 15.5.28 (15.x), confirm the resolved `sharp` is 0.35.5+, rebuild and redeploy every artifact; lines before 15.5 have no listed fix. [Guide](details/nextjs.md#remediation). |
| **Drupal** | Update core to 11.4.10, 11.3.19 or 10.6.19 (or later) and Entity List to 3.0.10; until then uninstall `field_ui`; EOL branches get no fix. [Guide](details/drupal.md#remediation). |
| **NGINX Open Source / NGINX Plus / F5 NGINX products** | Upgrade to 1.30.6 or 1.31.7+ (Plus 37.0.5.1 or 37.1.0.1; distro packages per vendor tracker) and restart; check `nginx -T` for alias+rewrite+$request_filename, regex map captures, aio+SSI and shared session cache without ticket keys. [Guide](details/nginx.md#remediation). |
| **curl / libcurl (system, containers, bundled copies)** | Upgrade to curl 8.23.0 or a vendor-fixed package (e.g. Debian 8.14.1-2+deb13u7), rebuild images and binaries that bundle libcurl, restart; stopgap: force HTTP/1.1 for uploads. [Guide](details/curl.md#remediation). |
| **Linux VM and sandbox hosts** | Boot a kernel with the CVE-2026-99999 fix (5.10.272, 5.15.223, 6.1.190, 6.6.159, 6.12.113, 6.18.57, 7.2.11, 7.3 or a vendor backport) plus the CVE-2026-74580 vhost fix; remove world access to /dev/vhost-*. [Guide](details/pwnescape.md#remediation). |
| **WordPress sites with Bricksforge** | Update to 3.1.8.10+ (prefer current 4.0.x), or deactivate the plugin or block its form_submit endpoint; then hunt for PHP files under wp-content/uploads, especially bricksforge/tmp and login_admin_*.php. [Guide](details/bricksforge.md#remediation). |
| **Gitea with the built-in SSH server** | Upgrade to 28.0.0+ (the release after 1.27.3), or switch to OpenSSH or disable SSH until upgraded. [Guide](details/gitea.md#remediation). |
| **Langflow** | Upgrade to 1.10.3+ (1.9.0 is not enough), set LANGFLOW_AUTO_LOGIN=false with a strong superuser password, and keep it off the internet. [Guide](details/langflow.md#remediation). |
| **Arista VeloCloud Orchestrator (on-prem)** | Upgrade to 5.2.3.18, 6.1.3.10 or 6.4.2.12 (or later on the same train), restrict UI access, block 74.82.197.86 and 38.54.50.151, and preserve logs; hosted VCO is already patched by Arista. [Guide](details/velocloud.md#remediation). |
| **Siemens Software Center on Windows** | Update Siemens Software Center to V4.0.9.8+, block the Siemens IOCs, and hunt for SiemensSoftwareCenter.exe under AppData\Local\Programs on PCs that never installed it. [Guide](details/siemens-software-center.md#remediation). |
| **Palo Alto Networks PAN-OS / Panorama** | Restrict the management interface to trusted IPs now and upgrade to the fixed PAN-OS hotfix for your branch (e.g. 11.1.16-h3, 11.2.16, 12.1.10-h2). [Guide](details/pan-os.md#remediation). |
| **Cisco Secure Email Gateway** | Update Content Scanner Tools to 25.3.0.5525+ (or AsyncOS 15.5.5-014/16.5.0-780) and run Cisco's System Security log check on every cluster member. [Guide](details/cisco-seg.md#remediation). |
| **SiteGuard Server Edition** | Download diagnostic info first, then update to Ver8.00 Update 5 (FreeBSD: Ver7.00 Update 6), apply the vendor patch, or disable the statistics feature. [Guide](details/siteguard.md#remediation). |
| **Windows clients and servers** | Install the October 2026 cumulative update (e.g. KB5127648 for 24H2/25H2) and confirm the OS build is at or above the fixed UBR. [Guide](details/windows-shell.md#remediation). |
| **Ivanti Connect Secure** | Update to 25.1.1.2, 25.1.3.0/25.1.3.1 or 22.8R2.5 and do memory/network forensics (the Integrity Checker may miss this chain); 22.7 is not affected. [Guide](details/ivanti-connect-secure.md#remediation). |
| **Atlassian Data Center** | Upgrade every node to a listed fixed version (or apply Atlassian's WAF or rewrite mitigation and cut off internet access), then rotate secrets stored in the web root such as crowd.properties. [Guide](details/atlassian-dc.md#remediation). |
| **AhsayCBS backup servers** | Apply hotfix 10.3.4.45 (v10) or 9.15.2.70 (v7–v9) and reboot, restrict console access, check Ahsay/Huntress IOCs; rebuild if compromised. [Guide](details/ahsaycbs.md#remediation). |
| **NetScaler ADC / Gateway with SAML** | Upgrade to 14.1-73.41, 13.1-64.28, 14.1-73.41 FIPS or 13.1-37.282 (FIPS/NDcPP); also apply CTX697096 fixes, preserving evidence first. [Guide](details/netscaler.md#remediation). |
| **FortiMail** | Upgrade to 8.0.2+, 7.6.7+ or 7.4.9+ (7.2 → 7.4+); until then disable IBE or block internet access to webmail, then check Fortinet's IoCs. [Guide](details/fortimail.md#remediation). |
| **Self-hosted Zammad** | Upgrade to 7.2.2+ (6.5.5 only as a stopgap for CVE-2026-102489; DEB/RPM installs need 7.2.2 for the root escalation), then run DIVD's log check. [Guide](details/zammad.md#remediation). |
| **Tailscale SSH / headscale** | Review per-feature exposure; disable unnecessary SSH forwarding with the vendor's daemon setting and restart safely. Source fixes are merged; a complete fixed stable-release matrix was not established. |
| **Microsoft Authenticator on Android** | Install **6.2606.4246 or a later supported release** in every profile; investigate and revoke exposed work-account tokens where compromise is suspected. |
| **PHP / WordPress / Laravel / Drupal / Joomla** | PHP **8.5.12 / 8.4.27 / 8.3.36 / 8.2.35** or verified backport; disable session upload progress pending the follow-up fix. |
| **Node.js / Bun** | Node **22.23.4 / 24.22.1 / 26.12.1**; Bun **1.4.4**. Rebuild containers and restart workers. |
| **Python** | `Brotli` **1.2.1**, `brotlicffi` **1.2.1.0**, Pillow **13.0.0** where installed. Pillow may require a Python upgrade. |
| **.NET** | Runtime **8.0.33 / 9.0.22 / 10.0.14**, or fixed .NET 11 preview; rebuild self-contained/NativeAOT apps. [Check actual decoding paths](details/brotli.md#inventory-by-language-and-deployment). |
| **Java / Scala / PHP / Ruby native Brotli** | Brotli4j **1.24.0** including native artifacts; PHP extension **0.21.1**; Ruby gem **0.9.1+**. Patch separate libcurl/native copies too. |
| **FFmpeg / libjxl media workers** | Verify the loaded/bundled Brotli fix with your supplier; the libjxl source merge does not patch existing FFmpeg artifacts. Until verified, pause affected untrusted JPEG XL/metadata processing. [Guide](details/brotli.md#remediation). |
| **ClickHouse** | Require a supplier build containing fixed Brotli; listed source backports are not verified released packages. Until patched, reject Brotli HTTP bodies before decoding and pause untrusted `.br`/Parquet ingestion. [Guide](details/brotli.md#inventory-by-language-and-deployment). |
| **Arrow / pyarrow** | Inspect Arrow's own bundled/system Brotli; updating Python `Brotli` alone is insufficient. No fixed wheel is established here: use a verified patched build or pause affected untrusted file/buffer processing. [Guide](details/brotli.md#inventory-by-language-and-deployment). |
| **GitLab** | Latest supported patch release covering October 21; **19.3.6 / 19.4.3 / 19.5.1** also cover the identity flaws above. |
| **Other Ruby applications** | Ruby **3.3.13 / 3.4.12 / 4.0.9**, especially where users supply regex patterns. |
| **Plex** | Media Server **1.43.3.10861 or later**; investigate previously exposed vulnerable servers. |
| **Nextcloud + built-in CODE** | `richdocumentscode` **26.4.303+**, or remove it. **Patch PHP separately.** |
| **KSMBD / Broadcom Wi-Fi** | Obtain an exact vendor fix status; restrict or disable the affected service, or replace unsupported hardware. |
| **HTTP/3** | Upgrade the product to a build containing the fixed QPACK library (Bun **1.4.4** for Bun HTTP/3), or disable affected HTTP/3 support. |
| **BeyondTrust Remote Support** | Apply **BT26-05-RS** and investigate vulnerable appliances exposed during the exploitation window. |
| **All stacks making TLS connections** | [Refresh each effective trust store](details/emudhra.md#runtime-and-application-trust-store-inventory), including embedded copies and alternate chains; rebuild Go with **1.27.3 / 1.26.10+**. Java needs the **CVE-2026-114820** follow-up; CPython `ssl` fixes are **3.15.2 / 3.14.10 / 3.13.18 / 3.12.16 / 3.11.18**. |
| **LiteLLM malicious artifacts** | [Isolate, rebuild and revoke reachable credentials](details/litellm.md#remediation); do not run ordinary Python startup hooks on suspected hosts. A downgrade alone is not recovery. |
| **Railway secrets stored before October 21** | [Rotate at each issuer, update consumers and verify revocation](details/railway.md#remediation); include registry credentials and existing sessions. |

**Before calling remediation finished:**

1. **Verify the deployed artifact, not your laptop’s version.** Check every container, virtual environment, PHP pool, background worker, and NAS package.
2. **Accept verified distribution backports.** An older-looking upstream version can be patched; require the vendor’s advisory or package changelog as evidence.
3. **Restart or redeploy.** Updating files does not replace libraries already loaded into running processes.
4. **Treat compromise separately from exposure.** Patch vulnerable systems; investigate compromised systems and revoke stolen credentials. One does not substitute for the other.
