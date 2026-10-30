# NGINX: configuration-dependent memory corruption and TLS session forgery

**Last updated:** 2026-10-30 (America/New_York)

[Main NGINX summary](../black-october-2026.md#nginx-configuration-dependent-memory-corruption-and-tls-session-forgery) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**NGINX Open Source 1.30.6 (stable) and 1.31.7 (mainline), released 2026-10-14, fix four flaws that qualify as High or Critical under F5's scores: three heap memory-corruption bugs in worker processes and one TLS session-forgery bug. For the three memory-corruption bugs, F5 (the CNA) gives CVSS 4.0 9.2 Critical and CVSS 3.1 8.1 High. For the session forgery, F5 gives CVSS 4.0 8.3 High and CVSS 3.1 6.5 Medium. nginx.org rates all four "medium". NVD has added no score of its own. None is listed in CISA KEV (catalog 2026.10.23, checked 2026-10-26).** Each flaw needs a **specific configuration**, so check the configuration as well as the version. [nginx.org advisories][ngx-adv] [nginx.org news][ngx-news]

| CVE | Trigger configuration (F5 description) | nginx.org vulnerable range | F5 CNA score | Worst case |
|---|---|---|---|---|
| [CVE-2026-15176](https://www.cve.org/CVERecord?id=CVE-2026-15176) | A `location` with `alias` and `rewrite`, plus `set` or `return` that references `$request_filename`; **or** `$request_filename` in a `log_format` | 0.1.29–1.31.6 | 4.0 9.2 / 3.1 8.1 | Heap overflow in a worker. Restart (DoS); code execution if ASLR is disabled or bypassed |
| [CVE-2026-93479](https://www.cve.org/CVERecord?id=CVE-2026-93479) | A regex `map` whose capture variables are referenced by `root` or an access-log format before the map's output variable; **or** "a non-cacheable variable in a string expression under certain conditions" (http and stream) | 1.31.2–1.31.6 and 1.30.0–1.30.5 | 4.0 9.2 / 3.1 8.1 | Same as above |
| [CVE-2026-97205](https://www.cve.org/CVERecord?id=CVE-2026-97205) | `aio` enabled (`on` or `threads`) **and** SSI pages with `include virtual` | 0.8.11–1.31.6 | 4.0 9.2 / 3.1 8.1 | Use-after-free in a worker. DoS, memory corruption, or code execution if ASLR is disabled or bypassed |
| [CVE-2026-97629](https://www.cve.org/CVERecord?id=CVE-2026-97629) | `ssl_session_cache shared:<name>:<size>` **without** `ssl_session_ticket_key`, which enables automatic ticket-key rotation. Not affected with `ssl_session_tickets off` | 1.23.2–1.31.6 | 4.0 8.3 / 3.1 6.5 | Forged client TLS sessions, which can **bypass client-certificate verification** |

All four are data-plane issues reachable by an unauthenticated remote client. F5 calls the memory bugs "conditions beyond [the attacker's] control" (CVSS AC:H). CISA's ADP SSVC entries record exploitation as "none" (2026-10-15). [CVE records][cve-15176]

The same release also fixed [CVE-2026-95101](https://www.cve.org/CVERecord?id=CVE-2026-95101) (HTTP/3 request-body injection with `proxy_request_buffering on`). F5 scores it CVSS 3.1 5.3 and CVSS 4.0 6.9, below this collection's High threshold, but upgrading to the same releases fixes it too. [CVE-2026-95101 record][cve-95101]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Version and product inventory](#version-and-product-inventory)
  - [Configuration check with nginx -T (read-only)](#configuration-check-with-nginx--t-read-only)
  - [Logs](#logs)
- [Remediation](#remediation)
  - [F5 products that embed NGINX](#f5-products-that-embed-nginx)
  - [Distribution packages](#distribution-packages)
  - [Temporary mitigations](#temporary-mitigations)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Discovery or report | Unknown dates | CVE-2026-15176 was "discovered internally by F5". F5 credits Matt Suiche (Tolmo), Mateusz Gierblinski and LemonTea for CVE-2026-93479, PhiNode Labs for CVE-2026-97629, and cyberlancer for CVE-2026-97205. [K000162416][k15176] [K000162607][k93479] [CHANGES][changes] |
| CVE IDs reserved | 2026-07-08 22:14 UTC (CVE-2026-15176); 2026-09-30 (the other three) | Reservation, not disclosure. [CVE records][cve-15176] |
| **Public announcement:** CVE records published by F5 | **2026-10-14 14:40:26–14:40:28 UTC** | All five CVEs from this release. NVD published them 15:17 UTC. [CVE records][cve-15176] [NVD][nvd-15176] |
| nginx 1.30.6 and 1.31.7 released; F5 K articles published | 2026-10-14; time/TZ unknown | Fixed in both branches. F5 published K000162416, K000162607, K000162608 and K000162606 on Oct 14. [nginx.org news][ngx-news] [CHANGES][changes] |
| F5 fixed releases for NGINX Plus and related products | Listed in the 2026-10-14 K articles | NGINX Plus 37.0.5.1 and 37.1.0.1, plus other products (see [Remediation](#f5-products-that-embed-nginx)). Release dates are not stated. [K000162416][k15176] |
| CISA ADP SSVC | 2026-10-15 | Exploitation: none. Automatable: no. [CVE records][cve-15176] |
| Debian DSA-6575-1 | 2026-10-21 15:28:43 +0000 | Fixes trixie (1.26.3-3+deb13u10). Debian says the CVE-2026-93479 code reached trixie through an earlier security backport. [DSA-6575-1][dsa] [Debian tracker][deb] |
| nginx 1.31.8 (mainline) | 2026-10-21 | Not a security release. [nginx.org news][ngx-news] |
| K000162607 (CVE-2026-93479) updated | 2026-10-23 | Credits expanded; the CVE record was updated 21:51 UTC. [K000162607][k93479] |
| CISA KEV | Not listed | Catalog 2026.10.23 checked on 2026-10-26. [KEV][kev] |
| Exploitation evidence | None found | No public exploitation reports in the reviewed sources. |

**Range discrepancies:** nginx.org lists CVE-2026-97205 as 0.8.11–1.31.6. F5's CVE record and K article list only branches still under technical support (1.30.0–1.30.5 and 1.31.0–1.31.6), because "End of Technical Support" versions are not evaluated. For CVE-2026-15176, F5's K article marks 0.1.29–0.9.9 as vulnerable with no fix. **Treat all older builds as vulnerable.**

## Detection

### Version and product inventory

Run these on each host or container as a user who can run the binary. They only print information.

```sh
nginx -v            # version
nginx -V 2>&1       # version, build options and modules (e.g. --with-threads, --with-file-aio)
ps -eo pid,args | grep '[n]ginx: master'   # which binary and config are actually running
```

- **Open source builds from nginx.org or your own builds:** vulnerable below 1.30.6 (stable) or 1.31.7 (mainline).
- **Distribution packages** use backports, so the upstream version number alone does **not** tell you whether a package is vulnerable. Check your distribution's tracker (see [Distribution packages](#distribution-packages)).
- **NGINX Plus:** run `nginx -v`. R33–R36 and 37.0.0–37.0.4 (and 37.1.0) are listed as vulnerable. [K000162416][k15176]
- Do not forget NGINX inside containers, Kubernetes ingress and gateway controllers, appliances, and F5 products (see the table under [Remediation](#f5-products-that-embed-nginx)). The community **ingress-nginx** project is not covered by F5's advisories, and its status was not established in this review.

### Configuration check with nginx -T (read-only)

`nginx -T` tests the configuration and prints every loaded config file. It does **not** reload or restart the running server.

- Run it as the same user and with the same binary and `-c` path as the master process found above. That is usually root, because it must read certificates. Inside a container, use `docker exec <container> nginx -T` or `kubectl exec <pod> -- nginx -T`, replacing the placeholders.
- `nginx -t` and `-T` can create log files that do not exist yet, but they make no other change.
- The full dump can include secrets, such as `auth_basic_user_file` paths, upstream credentials in headers, and API keys. **Pipe it straight to `grep` instead of saving or sharing it.**

This command has not been run on a production system:

```sh
sudo nginx -T 2>&1 | grep -nE '^# configuration file|^\s*(location|alias|rewrite|set|return|log_format|access_log|root|map|aio|ssi|ssl_session_cache|ssl_session_ticket_key|ssl_session_tickets|ssl_verify_client)\b|\$request_filename|\$[1-9]\b'
```

How to read the matches (the `# configuration file` lines show which file each match comes from):

- **CVE-2026-15176:** Look for a `location` that has both `alias` and `rewrite`, where `set` or `return` in that context uses `$request_filename`. Also look for any `log_format` that contains `$request_filename`.
- **CVE-2026-93479:** Look for `map` blocks with regex keys (`~` or `~*`) whose numbered captures (`$1`…`$9`) are used in `root`, `log_format` or `access_log` paths. F5 also names a broader trigger ("a non-cacheable variable in a string expression under certain conditions"), so **no grep can rule this flaw out**. Rely on the version. This applies only to 1.30.0–1.30.5 and 1.31.2–1.31.6 upstream, but Debian has shown that backports can add it to older version numbers.
- **CVE-2026-97205:** Look for `aio on` or `aio threads` together with `ssi on` anywhere the SSI pages contain `<!--# include virtual=... -->`. To find such pages, search your document roots read-only, replacing `DOCROOT`: `grep -rl 'include virtual' DOCROOT`.
- **CVE-2026-97629:** Look for `ssl_session_cache shared:...` with **no** `ssl_session_ticket_key` and **no** `ssl_session_tickets off`. This matters most where `ssl_verify_client on` or `optional` is the access control.

### Logs

F5 has published no IOCs. A worker that crashes and restarts shows up in the error log as a line like `worker process <pid> exited on signal 11` (or signal 6). In the access log, look for odd rewritten or encoded URIs that hit `alias` locations, and for bursts of requests to SSI pages. Read-only example, replacing `ERROR_LOG`:

```sh
grep -nE 'exited on signal (6|11)' ERROR_LOG
```

For CVE-2026-97629, compare successful mTLS-protected requests with expected client-certificate subjects, if you log `$ssl_client_s_dn` or `$ssl_client_verify`. Finding nothing proves nothing: crashes can have other causes, and a successful code-execution attempt may not crash anything.

## Remediation

1. **Upgrade NGINX Open Source** to **1.30.6** (stable) or **1.31.7** or later (mainline, now 1.31.8). Then restart, or do a binary upgrade, so every worker runs the new binary. A `reload` alone keeps running the old binary. [nginx.org advisories][ngx-adv]
2. **NGINX Plus:** upgrade to **37.0.5.1** or **37.1.0.1**. F5 lists **no fix for R33–R36**, so move to a fixed 37.x release. [K000162416][k15176]

### F5 products that embed NGINX

This table is a summary of F5's K articles. Ranges vary by CVE, so check each article for your product.

| Product | Fixed in (per F5) | Notes |
|---|---|---|
| NGINX Instance Manager | 2.24.0 | 2.18.0–2.23.0 vulnerable |
| F5 WAF for NGINX | 5.16.0 or 5.14.2 | 5.9.0–5.15.0 vulnerable |
| F5 DoS for NGINX | 4.11.0 | 4.8.0–4.10.0 vulnerable |
| NGINX Gateway Fabric | 2.8.0 | 2.1.0–2.7.2 vulnerable |
| NGINX Ingress Controller | 5.7.0 | 5.6.0–5.6.3 vulnerable. For CVE-2026-93479, F5 also lists 5.0.0–5.6.3, 4.0.0–4.0.1, 3.7.1–3.7.2 and LTS 2026-lts-r3–r8 as vulnerable, with **no fix** for the 4.x, 3.x and LTS lines |
| NGINX App Protect WAF and DoS | No fix listed | Vulnerable ranges are listed |
| BIG-IP, BIG-IQ, F5OS, BIG-IP Next, F5 Distributed Cloud, NGINX One Console, F5 AI Gateway | Not applicable | F5 says not vulnerable |

Sources: [K000162416][k15176], [K000162607][k93479], [K000162608][k97205], [K000162606][k97629].

### Distribution packages

- **Debian:** [DSA-6575-1][dsa] (2026-10-21) fixes trixie in **1.26.3-3+deb13u10**, and sid/forky has 1.30.6-2. When checked, the Debian tracker still showed **bookworm as vulnerable**. [Debian tracker][deb]
- **Ubuntu:** [USN-8955-1][usn] (published 2026-10-26) fixes CVE-2026-15176, CVE-2026-93479, CVE-2026-95101, CVE-2026-97205 and CVE-2026-97629 in **1.30.4-7ubuntu1.1** (26.10), **1.28.3-2ubuntu1.12** (26.04 LTS), **1.24.0-2ubuntu7.19** (24.04 LTS) and **1.18.0-6ubuntu14.22** (22.04 LTS). CVE-2026-15176's HTTP/3 issue is limited to 26.04 and 26.10, and CVE-2026-97629's session-ticket issue to 24.04, 26.04 and 26.10. Ubuntu 20.04 and older were still "Needs evaluation" when the tracker was checked. [Ubuntu][ubuntu]
- For other distributions (Red Hat, SUSE, Alpine and so on), check their trackers. Their status was not reviewed here. Remember that backports can make an old version number either safe or, as Debian found for CVE-2026-93479, vulnerable.

### Temporary mitigations

F5's mitigations remove the trigger without fixing the code. Test each one, then run `nginx -t` and reload. [F5 K articles][k15176]

- **CVE-2026-15176:** Avoid `alias` in the affected locations, or stop using `$request_filename` (including in `log_format`).
- **CVE-2026-93479:** Use **named** captures instead of numbered ones, and use them only inside the block with the regex match.
- **CVE-2026-97205:** Set `aio off` (the default), or `ssi off`. F5 notes that disabling AIO can slow down large static or media serving.
- **CVE-2026-97629:** Set `ssl_session_tickets off`, load static keys with `ssl_session_ticket_key`, or remove `ssl_session_cache shared:...`. If you use static keys, protect and rotate the key files yourself.

**Rollback caution:** Reinstalling an older package or image brings back every affected CVE. Pin the fixed versions in image builds.

## Verification

- `nginx -v` on every running instance (and `docker exec ... nginx -v` in containers) shows 1.30.6+, 1.31.7+, NGINX Plus 37.0.5.1 or 37.1.0.1, or a distribution package version the vendor lists as fixed.
- The running master process started after the upgrade. Compare `ps -o lstart= -p <master-pid>` with the upgrade time, replacing `<master-pid>`.
- If you applied mitigations instead, re-run the read-only `nginx -T | grep` check above and confirm the trigger patterns are gone.
- Benign functional check: request a normal page, an SSI page and an `alias`-served file on an instance you own, and confirm they behave as expected. Run an mTLS-protected request with and without a valid client certificate. Do not send crafted overflow payloads.

## Compromise response

- If workers crashed repeatedly on an affected configuration, or you see unexplained behaviour, treat the host as possibly compromised. Code execution would run as the worker user (often `www-data` or `nginx`).
- Look for webshells in document roots, changed config or include files, new modules, unexpected outbound connections from worker processes, and new cron or systemd units.
- If code execution is suspected, rotate the TLS private keys and any upstream credentials that NGINX can read. If you rely on mTLS and were exposed to CVE-2026-97629, review what was accessed through client-certificate-protected locations.
- Rebuild suspect hosts or images from a clean source rather than patching them in place.

## Sources

- [nginx.org security advisories][ngx-adv], [nginx.org news][ngx-news], [CHANGES for 1.30.x][changes]: nginx.org severities, ranges, credits and release dates.
- F5: [K000162416][k15176] (CVE-2026-15176), [K000162607][k93479] (CVE-2026-93479), [K000162608][k97205] (CVE-2026-97205), [K000162606][k97629] (CVE-2026-97629): scores, product tables and mitigations.
- CVE records: [CVE-2026-15176][cve-15176], [CVE-2026-93479][cve-93479], [CVE-2026-97205][cve-97205], [CVE-2026-97629][cve-97629], [CVE-2026-95101][cve-95101]. [NVD CVE-2026-15176][nvd-15176].
- [Debian DSA-6575-1][dsa], [Debian security tracker][deb], [Ubuntu CVE-2026-93479][ubuntu].
- [CISA KEV feed][kev] (no entries).

[ngx-adv]: https://nginx.org/en/security_advisories.html
[ngx-news]: https://nginx.org/
[changes]: https://nginx.org/en/CHANGES-1.30
[k15176]: https://my.f5.com/manage/s/article/K000162416
[k93479]: https://my.f5.com/manage/s/article/K000162607
[k97205]: https://my.f5.com/manage/s/article/K000162608
[k97629]: https://my.f5.com/manage/s/article/K000162606
[cve-15176]: https://cveawg.mitre.org/api/cve/CVE-2026-15176
[cve-93479]: https://cveawg.mitre.org/api/cve/CVE-2026-93479
[cve-97205]: https://cveawg.mitre.org/api/cve/CVE-2026-97205
[cve-97629]: https://cveawg.mitre.org/api/cve/CVE-2026-97629
[cve-95101]: https://cveawg.mitre.org/api/cve/CVE-2026-95101
[nvd-15176]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-15176
[dsa]: https://lists.debian.org/debian-security-announce/2026/msg00490.html
[deb]: https://security-tracker.debian.org/tracker/CVE-2026-93479
[ubuntu]: https://ubuntu.com/security/CVE-2026-93479
[usn]: https://ubuntu.com/security/notices/USN-8955-1
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
