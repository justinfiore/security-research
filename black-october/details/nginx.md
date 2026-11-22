# NGINX: configuration-dependent memory corruption and TLS session forgery

**Last updated:** 2026-11-22 (America/New_York)

[Main NGINX summary](../black-october-2026.md#nginx-configuration-dependent-memory-corruption-and-tls-session-forgery) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**NGINX Open Source 1.30.7 and 1.31.9, released 2026-11-18, fix ten flaws.** F5's [November 18 index](https://my.f5.com/manage/s/article/K000164058) lists them. Five are High or Critical. Researchers call the set nginx2root. Turning HTTP/2 off blocks only two of them.

| CVE | nginx.org | F5 score | What it needs | Range (nginx.org / F5) |
|---|---|---|---|---|
| [CVE-2026-123007](https://www.cve.org/CVERecord?id=CVE-2026-123007) | major | 3.1 8.1 / 4.0 9.2 | HTTP/2 on. Flow control overflows a heap buffer. Rapid7 published a proof of concept. | 1.9.5–1.31.8 |
| [CVE-2026-123633](https://www.cve.org/CVERecord?id=CVE-2026-123633) | medium | 3.1 8.1 / 4.0 9.2 | HTTP/2 plus a proxy, and the worker is low on `worker_connections`. Use after free. | 1.19.7–1.31.8 |
| [CVE-2026-123634](https://www.cve.org/CVERecord?id=CVE-2026-123634) | medium | 3.1 8.1 / 4.0 9.2 | `proxy_pass` with a variable, and an SSI or `mirror` subrequest that resolves the same name. Use after free. | 0.6.18–1.31.8 |
| [CVE-2026-121810](https://www.cve.org/CVERecord?id=CVE-2026-121810) | medium | 3.1 8.1 / 4.0 9.2 | HTTP/3. Use after free. F5 says exploitation also depends on conditions beyond the attacker's control. | 1.25.0–1.31.8 |
| [CVE-2026-113425](https://www.cve.org/CVERecord?id=CVE-2026-113425) | major | 3.1 8.1 / 4.0 9.2 | Configured as a mail proxy. A crafted mail session is a use after free. | 0.5.33–1.31.8 |
| [CVE-2026-118899](https://www.cve.org/CVERecord?id=CVE-2026-118899) | major | 3.1 7.5 / 4.0 8.7 | `listen … ssl` with TLS 1.3. A crafted connection loops the worker while it reads the request body. Denial of service only. | 1.13.0–1.31.8 |

The 8.1 vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`. F5 says code execution on the five memory flaws needs ASLR off or bypassed. Xint says it leaked addresses and ran commands, and it is withholding a Linux SCTP chain it used to reach root from a container. That kernel flaw has no CVE and no public fix, so it is not tracked here. NGINX Plus is **37.3.0.1 and 37.0.8.1** for five of the six. CVE-2026-123633 is fixed one build earlier, in **37.2.0.1 and 37.0.7.1**. R34 through R36 have no fix. F5 names no mitigation for the HTTP/2, HTTP/3, or TLS 1.3 flaws. For the mail proxy, restrict the listener to trusted networks. Four more flaws in the same release are below 7.0, including a stream client-certificate bypass, [CVE-2026-120967](https://www.cve.org/CVERecord?id=CVE-2026-120967), which F5 rates 4.8 and 6.3. Debian trixie and bookworm now have packages: DSA-6642-1 and DLA-4918-1, both November 19. Forky `1.30.6-4` is fixed. Ubuntu's November 19 notice, USN-9159-1, names fixed packages. Red Hat shipped RHEL 10 and two RHEL 9 packages on November 20. [K000163926](https://my.f5.com/manage/s/article/K000163926)

**1.30.6 and 1.31.7, released 2026-10-14, fix four earlier flaws.** For the three memory-corruption bugs, F5 gives CVSS 4.0 9.2 and CVSS 3.1 8.1. For the session forgery, F5 gives CVSS 4.0 8.3 and CVSS 3.1 6.5. nginx.org rates all four medium. Each of those four needs a specific configuration. 1.30.6 and 1.31.7 do not fix CVE-2026-123007. [nginx.org advisories][ngx-adv]

| CVE | Trigger configuration (F5 description) | nginx.org vulnerable range | F5 CNA score | Worst case |
|---|---|---|---|---|
| [CVE-2026-15176](https://www.cve.org/CVERecord?id=CVE-2026-15176) | A `location` with `alias` and `rewrite`, plus `set` or `return` that references `$request_filename`; **or** `$request_filename` in a `log_format` | 0.1.29–1.31.6 | 4.0 9.2 / 3.1 8.1 | Heap overflow in a worker. Restart (DoS); code execution if ASLR is disabled or bypassed |
| [CVE-2026-93479](https://www.cve.org/CVERecord?id=CVE-2026-93479) | A regex `map` whose capture variables are referenced by `root` or an access-log format before the map's output variable; **or** "a non-cacheable variable in a string expression under certain conditions" (http and stream) | 1.31.2–1.31.6 and 1.30.0–1.30.5 | 4.0 9.2 / 3.1 8.1 | Same as above |
| [CVE-2026-97205](https://www.cve.org/CVERecord?id=CVE-2026-97205) | `aio` enabled (`on` or `threads`) **and** SSI pages with `include virtual` | 0.8.11–1.31.6 | 4.0 9.2 / 3.1 8.1 | Use-after-free in a worker. DoS, memory corruption, or code execution if ASLR is disabled or bypassed |
| [CVE-2026-97629](https://www.cve.org/CVERecord?id=CVE-2026-97629) | `ssl_session_cache shared:<name>:<size>` **without** `ssl_session_ticket_key`, which enables automatic ticket-key rotation. Not affected with `ssl_session_tickets off` | 1.23.2–1.31.6 | 4.0 8.3 / 3.1 6.5 | Forged client TLS sessions, which can **bypass client-certificate verification** |

All four are data-plane issues reachable by an unauthenticated remote client. F5 calls the memory bugs "conditions beyond [the attacker's] control" (CVSS AC:H). CISA's ADP SSVC entries record exploitation as "none" (2026-10-15). [CVE records][cve-15176]

The same release also fixed [CVE-2026-95101](https://www.cve.org/CVERecord?id=CVE-2026-95101) (HTTP/3 request-body injection with `proxy_request_buffering on`). F5 scores it CVSS 3.1 5.3 and CVSS 4.0 6.9, below this collection's High threshold, but upgrading to the same releases fixes it too. [CVE-2026-95101 record][cve-95101]

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-18). None of the November 18 CVEs is in the feed. Rapid7 published a proof of concept for CVE-2026-123007. The sources reviewed report no exploitation in the wild. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| nginx 1.30.7 and 1.31.9; F5 out-of-band notice | 2026-11-18; time/TZ unknown | Ten flaws. F5 rates five CVSS 3.1 8.1 and 4.0 9.2, and the TLS 1.3 loop 7.5 and 8.7. [K000164058][k-index] [nginx.org advisories][ngx-adv] |
| CISA KEV | Not listed | Catalog 2026.11.18 checked on 2026-11-18. [KEV][kev] |
| Exploitation evidence | Proof of concept, no in-the-wild report | Rapid7 published a proof of concept for CVE-2026-123007. Xint and Wiz describe code execution in a lab. Neither reports use in the wild. |

**Range discrepancies:** nginx.org lists CVE-2026-97205 as 0.8.11–1.31.6. F5's CVE record and K article list only branches still under technical support (1.30.0–1.30.5 and 1.31.0–1.31.6), because "End of Technical Support" versions are not evaluated. For CVE-2026-15176, F5's K article marks 0.1.29–0.9.9 as vulnerable with no fix. **Treat all older builds as vulnerable.**

## Detection

### Version and product inventory

Run these on each host or container as a user who can run the binary. They only print information.

```sh
nginx -v            # version
nginx -V 2>&1       # version, build options and modules (e.g. --with-threads, --with-file-aio)
ps -eo pid,args | grep '[n]ginx: master'   # which binary and config are actually running
```

- **Open source builds from nginx.org or your own builds:** the October flaws are fixed at 1.30.6 or 1.31.7. The November 18 flaws are fixed at **1.30.7 or 1.31.9**. A build on 1.30.6 or 1.31.7 still has all ten.
- **Distribution packages** use backports, so the upstream version number alone does **not** tell you whether a package is vulnerable. Check your distribution's tracker (see [Distribution packages](#distribution-packages)).
- **NGINX Plus:** run `nginx -v`. For the November 18 set, 37.x before **37.3.0.1 and 37.0.8.1** is vulnerable, and R34 through R36 have no fix. CVE-2026-123633 is fixed in 37.2.0.1 and 37.0.7.1. [K000163926][k123007]
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

1. **Upgrade NGINX Open Source** to **1.30.7** (stable) or **1.31.9** (mainline). Then restart, or do a binary upgrade, so every worker runs the new binary. A `reload` alone keeps running the old binary. 1.30.6 and 1.31.7 fix only the October flaws. [nginx.org advisories][ngx-adv]
2. **NGINX Plus:** upgrade to **37.3.0.1** or **37.0.8.1**. F5 lists **no fix for R34 through R36**, so move to a fixed 37.x release. The October floors, 37.0.5.1 and 37.1.0.1, leave the November flaws in place. [K000163926][k123007]

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

- **Debian:** [DSA-6642-1](https://www.debian.org/security/2026/dsa-6642) (2026-11-19 14:40:29 +0000) fixes trixie in **1.26.3-3+deb13u11**, including CVE-2026-123007 and CVE-2026-123633. [DLA-4918-1](https://www.debian.org/lts/security/2026/dla-4918) (2026-11-19) fixes bookworm in **1.22.1-9+deb12u11** for the same two. Forky and sid are both **1.30.6-4**, marked fixed, with the upstream 1.30.7 fixes backported. The per-CVE tracker page was stale on 2026-11-19 and still showed the older builds. [Debian tracker][deb]
- **Ubuntu:** [USN-9159-1][usn9159] (published 2026-11-19) fixes CVE-2026-123007 and the other November flaws: **1.30.4-7ubuntu1.2** (26.10), **1.28.3-2ubuntu1.13** (26.04 LTS), **1.24.0-2ubuntu7.20** (24.04 LTS), and **1.18.0-6ubuntu14.23** (22.04 LTS). Ubuntu Pro is **1.18.0-0ubuntu1.7+esm5** (20.04), **1.14.0-0ubuntu1.11+esm6** (18.04), **1.10.3-0ubuntu0.16.04.5+esm11** (16.04), and **1.4.6-1ubuntu3.9+esm10** (14.04). Ubuntu's CVE page says 14.04 is not affected by CVE-2026-123007. [USN-8955-1][usn] (published 2026-10-26) is the earlier notice for the October flaws and does not list CVE-2026-123007. [Ubuntu][ubuntu]
- **Red Hat:** [RHSA-2026:100744](https://access.redhat.com/errata/RHSA-2026:100744), issued 2026-11-20, is a Critical nginx update for Red Hat Enterprise Linux 10. [RHSA-2026:100748](https://access.redhat.com/errata/RHSA-2026:100748), issued the same day, covers the RHEL 9 base `nginx` package. [RHSA-2026:100750](https://access.redhat.com/errata/RHSA-2026:100750), also 2026-11-20, covers the `nginx:1.24` module on RHEL 9.8 Extended Update Support. [RHSA-2026:100747](https://access.redhat.com/errata/RHSA-2026:100747), also 2026-11-20, covers the RHEL 8 `nginx:1.24` module (`nginx-1.24.0-3.module+el8.10.0+25364+53b7037a.9`). [RHSA-2026:100745](https://access.redhat.com/errata/RHSA-2026:100745), the same day, covers the RHEL 9 `nginx:1.26` module (`nginx-1.26.3-10.module+el9.9.0+25360+9b756829.4`). Both name CVE-2026-123007. No erratum was found for 3scale. Rocky Linux 8 has [RLSA-2026:100747](https://errata.rockylinux.org/RLSA-2026:100747), issued 2026-11-21. Rocky Linux 9 and 10 followed the same day with RLSA-2026:100748, RLSA-2026:100744, and, for the RHEL 9 `nginx:1.26` module, RLSA-2026:100745. Debian forky is fixed in `1.30.6-4`. SUSE's page still says Pending. [RHSB-2026-019](https://access.redhat.com/security/vulnerabilities/RHSB-2026-019), still dated November 19, says fixes are being expedited. SUSE and Alpine were not rechecked. Remember that backports can make an old version number either safe or, as Debian found for CVE-2026-93479, vulnerable.
- **Bitwarden self-hosted:** Bitwarden's notice, posted 2026-11-19, says the bundled nginx is inside CVE-2026-123007 and CVE-2026-123633 and tells operators to update the instance to **v2026.11.0**. It names a kernel flaw, CVE-2026-72447, that Bitwarden does not ship, so the host still needs its own kernel update. [Bitwarden](https://community.bitwarden.com/t/bitwarden-self-host-patch-available-for-nginx-cve-2026-123007-and-cve-2026-123633/104165)

### Temporary mitigations

F5's mitigations remove the trigger without fixing the code. Test each one, then run `nginx -t` and reload. [F5 K articles][k15176]

- **CVE-2026-15176:** Avoid `alias` in the affected locations, or stop using `$request_filename` (including in `log_format`).
- **CVE-2026-93479:** Use **named** captures instead of numbered ones, and use them only inside the block with the regex match.
- **CVE-2026-97205:** Set `aio off` (the default), or `ssi off`. F5 notes that disabling AIO can slow down large static or media serving.
- **CVE-2026-97629:** Set `ssl_session_tickets off`, load static keys with `ssl_session_ticket_key`, or remove `ssl_session_cache shared:...`. If you use static keys, protect and rotate the key files yourself.

The November 18 configuration mitigations do not replace the upgrade:

- **CVE-2026-123007 and CVE-2026-123633:** turn HTTP/2 off. F5 lists no mitigation of its own.
- **CVE-2026-121810:** turn HTTP/3 off. F5 lists no mitigation.
- **CVE-2026-123634:** do not resolve an upstream name from a variable inside an SSI or `mirror` subrequest.
- **CVE-2026-113425:** restrict the mail-proxy listener to trusted networks. F5 names that as the mitigation.
- **CVE-2026-118899:** F5 lists no mitigation. TLS 1.3 on an `ssl` listener is the trigger.

**Rollback caution:** Reinstalling an older package or image brings back every affected CVE. Pin the fixed versions in image builds.

## Verification

- `nginx -v` on every running instance (and `docker exec ... nginx -v` in containers) shows 1.30.7 or later, 1.31.9 or later, NGINX Plus 37.3.0.1 or 37.0.8.1, or a distribution package version the vendor lists as fixed for CVE-2026-123007. 1.30.6 and 1.31.7 are not enough.
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
- F5, November 18: [K000164058][k-index], [K000163926][k123007] (CVE-2026-123007), [K000163928][k123633] (CVE-2026-123633), [K000163925][k123634] (CVE-2026-123634), [K000163927][k121810] (CVE-2026-121810), [K000163931][k113425] (CVE-2026-113425), [K000163930][k118899] (CVE-2026-118899).
- F5, October 14: [K000162416][k15176] (CVE-2026-15176), [K000162607][k93479] (CVE-2026-93479), [K000162608][k97205] (CVE-2026-97205), [K000162606][k97629] (CVE-2026-97629).
- CVE records: [CVE-2026-15176][cve-15176], [CVE-2026-93479][cve-93479], [CVE-2026-97205][cve-97205], [CVE-2026-97629][cve-97629], [CVE-2026-95101][cve-95101]. [NVD CVE-2026-15176][nvd-15176].
- [Debian DSA-6575-1][dsa], [Debian security tracker][deb], [Ubuntu CVE-2026-93479][ubuntu].
- [CISA KEV feed][kev] (no entries).

[ngx-adv]: https://nginx.org/en/security_advisories.html
[ngx-news]: https://nginx.org/
[changes]: https://nginx.org/en/CHANGES-1.30
[k-index]: https://my.f5.com/manage/s/article/K000164058
[k123007]: https://my.f5.com/manage/s/article/K000163926
[k123633]: https://my.f5.com/manage/s/article/K000163928
[k123634]: https://my.f5.com/manage/s/article/K000163925
[k121810]: https://my.f5.com/manage/s/article/K000163927
[k113425]: https://my.f5.com/manage/s/article/K000163931
[k118899]: https://my.f5.com/manage/s/article/K000163930
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
[deb]: https://security-tracker.debian.org/tracker/CVE-2026-123007
[ubuntu]: https://ubuntu.com/security/CVE-2026-93479
[usn9159]: https://ubuntu.com/security/notices/USN-9159-1
[usn]: https://ubuntu.com/security/notices/USN-8955-1
[usn2]: https://ubuntu.com/security/notices/USN-8955-2
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
