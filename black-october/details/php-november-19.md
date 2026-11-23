# PHP: the November 19 security releases

**Last updated:** 2026-11-22 (America/New_York)

[Main PHP November 19 summary](../black-october-2026.md#php-the-november-19-security-releases) · [PHP2Shell](php2shell.md) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-19 PHP released **8.6.0, 8.5.13, 8.4.28, 8.3.37, and 8.2.36**. The PHP project's GitHub advisories rate seven of the flaws **Critical, CVSS 4.0 9.2**, and three **High**. Each Critical vector is `CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N` unless the row below says otherwise. PHP says the highest severity needs a non-default configuration or an uncommon setup. The October 21 builds, 8.5.12, 8.4.27, 8.3.36, and 8.2.35, do not include these fixes. This is the release that was scheduled for 14:00 to 14:30 UTC. It is not a new [PHP2Shell](php2shell.md).

| CVE | Score | Fixed in | What it does |
| --- | --- | --- | --- |
| [CVE-2026-115560](https://www.cve.org/CVERecord?id=CVE-2026-115560) | Critical, 9.2 | 8.2.36, 8.3.37, 8.4.28, 8.5.13, 8.6.0 | Session upload progress writes with one serializer and a later read uses another. A mismatched decoder can treat part of a session key as an object. Code execution needs a gadget chain. |
| [CVE-2026-126714](https://www.cve.org/CVERecord?id=CVE-2026-126714) | Critical, 9.2. The vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. | the same five | An interrupted write to a file-backed session leaves a prefix of the new session and a suffix of the old one. A later `session_start()` can deserialize objects. Depthfirst calls this phpAfterShell. |
| [CVE-2026-129289](https://www.cve.org/CVERecord?id=CVE-2026-129289) | Critical, 9.2, same Low-complexity vector | the same five | PHP-FPM or LSAPI keeps a connection and leaves unread body bytes. Those bytes can be a second FastCGI request the front end never made. |
| [CVE-2026-129182](https://www.cve.org/CVERecord?id=CVE-2026-129182) | Critical, 9.2 | 8.5.13 and 8.6.0 | A fatal error during shutdown puts the last backtrace back after the executor has cleared it. The next request on that worker can use the freed memory. |
| [CVE-2026-129474](https://www.cve.org/CVERecord?id=CVE-2026-129474) | Critical, 9.2 | 8.5.13 and 8.6.0 | Collecting arguments for a `__call()` backtrace reads freed memory. PHP 8.5 enables fatal-error backtraces by default. `php.ini-production` sets `zend.exception_ignore_args=1`, which blocks this path. |
| [CVE-2026-129481](https://www.cve.org/CVERecord?id=CVE-2026-129481) | Critical, 9.2 | 8.3.37, 8.4.28, 8.5.13, 8.6.0 | Session shutdown stops before it releases the script filename. The next request on that worker frees it again. PHP 8.2 does not have the field. |
| [CVE-2026-129496](https://www.cve.org/CVERecord?id=CVE-2026-129496) | Critical, 9.2 | the five from 8.2.36 | A diagnostic written to a PHP error log during startup keeps a pointer to a timezone cache that startup memory then frees. |
| [CVE-2026-129291](https://www.cve.org/CVERecord?id=CVE-2026-129291) | High, 8.8. `CVSS:4.0/AV:L/AC:H/AT:P/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H` | the five from 8.2.36, and only from 8.2.7 | With `catch_workers_output` on, the FPM master can call a function through a freed worker record. The attacker already runs code in a worker. The master is commonly root. |
| [CVE-2026-128064](https://www.cve.org/CVERecord?id=CVE-2026-128064) | High, 8.2 | the five from 8.2.36 | A URL whose scheme is mixed-case `HTTPS` or `FTPS` can send data in plaintext. |
| [CVE-2026-127960](https://www.cve.org/CVERecord?id=CVE-2026-127960) | High, 8.7. `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:H/SC:N/SI:N/SA:N` | the five from 8.2.36, from 8.2.28, 8.3.18, 8.4.5, and 8.5.0 | Folded HTTP response headers can make a worker stop answering. |

The same builds fix more flaws the advisories rate Medium, including [CVE-2026-129538](https://www.cve.org/CVERecord?id=CVE-2026-129538) in PHP-CGI and [CVE-2026-129292](https://www.cve.org/CVERecord?id=CVE-2026-129292) on the FPM status page. They do not change the upgrade.

Depthfirst's write-up, published 2026-11-19, says the November 19 builds are still vulnerable to CVE-2026-126714, including `master`. PHP's advisory for that CVE, published the same day, says the opposite: the fix truncates the session file before the write, and the patched versions are the five builds above. Use the vendor's patched versions. The two pages disagree, and this guide does not treat the researcher's range as the fixed range.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-22) for any CVE in this table. [CVE-2026-109618](https://www.cve.org/CVERecord?id=CVE-2026-109618) and [CVE-2026-109619](https://www.cve.org/CVERecord?id=CVE-2026-109619) stay listed under [PHP2Shell](php2shell.md). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Advance notice | 2026-11-18; time/TZ unknown | PHP scheduled the release for 2026-11-19, 14:00 to 14:30 UTC, and said the highest severity is Critical. [Archive][archive] |
| **Public announcement and fixes** | **2026-11-19; the advisories are timestamped from 14:05:55 UTC** | 8.6.0, 8.5.13, 8.4.28, 8.3.37, and 8.2.36. [Changelog][changelog] |
| Depthfirst write-up | 2026-11-19; time/TZ unknown | Says the session-file fix does not close CVE-2026-126714. PHP's advisory says it does. [depthfirst][depth] |
| **Google Cloud bulletin** | **2026-11-20; time unknown** | GCP-2026-090. Managed PHP images for App Engine, Cloud Run, and Cloud Run functions are not published yet. [GCP-2026-090][gcp] |
| **Last updated** | **2026-11-22 (America/New_York)** | Google Cloud customers set `session.upload_progress.enabled = 0` now. |

## Detection

Inventory the web runtime, not only the CLI binary. The [PHP2Shell guide](php2shell.md#inventory-the-web-runtime-not-only-cli-php) has the checks. A build below the row for its branch is inside this release. A distribution package can carry the fix under a different version number, and only the package advisory shows that.

The conditions differ:

- CVE-2026-115560 needs session upload progress and two different serializers for the same stored session.
- CVE-2026-126714 needs the `files` session handler, which is the default, plus a way to interrupt a write. Turning upload progress off removes one input and does not fix an application that stores attacker-controlled session data.
- CVE-2026-129289 needs a front end that keeps the backend connection, such as nginx with `fastcgi_keep_conn on`, and an application that opens `php://input` without reading it all.
- CVE-2026-129291 needs local code execution in an FPM worker, `catch_workers_output`, and the epoll backend.

## Remediation

1. Upgrade to **8.6.0, 8.5.13, 8.4.28, 8.3.37, or 8.2.36** on the branch you run, and restart every worker. PHP 8.1 and earlier are end of life and get no build.
2. Keep `session.upload_progress.enabled=0` where the feature is not needed. PHP's advisory for CVE-2026-126714 says that removes one input path and is not the fix.
3. The October 21 builds leave every row in the table in place.
4. On Google Cloud, bulletin [GCP-2026-090][gcp], published 2026-11-20, says the managed PHP images are not published yet. It names App Engine Standard (second-generation PHP 7.2 through 8.5), App Engine Flexible, Cloud Run, and Cloud Run functions. Until the image arrives:
   - Set `session.upload_progress.enabled = 0` where the application does not track upload progress. Google says this mitigates the primary path for CVE-2026-126714 in particular. It also says to move `session.save_handler` off `files` where that is feasible.
   - A container you build, on Cloud Run or an App Engine flexible custom runtime, can move to PHP 8.2.36, 8.3.37, 8.4.28, or 8.5.13 now and does not have to wait.
   - App Engine standard on PHP 8.2 through 8.5, and Cloud Run services and functions with automatic base image updates, receive the patched runtime once Google publishes it. Apply the setting above until then.
   - App Engine flexible on the managed runtime, Cloud Run jobs and worker pools, Cloud Functions (1st gen), and a deployment pinned to a patch string have to be rebuilt after Google publishes the image.
   - PHP 7.2 through 8.1 get no patch. Move to 8.2 or later, or apply the settings above. Google says no upstream patch will be released for 8.1 or earlier.

## Verification

- The web SAPI's `php -v`, or the package the service actually loads, is one of the five builds.
- Restart the workers and confirm the site answers. Do not send a truncated session write.

## Compromise response

PHP does not report exploitation of this release. A worker that exited while writing a session, on a build older than these, is a lead and is not proof. The upgrade does not show whether a request already ran code.

## Sources

- [PHP 8 changelog][changelog] — 8.6.0, 8.5.13, 8.4.28, 8.3.37, and 8.2.36, each dated 19 Nov 2026, each naming the GHSA and the CVE.
- [GHSA-658j-r8rw-q6mx](https://github.com/php/php-src/security/advisories/GHSA-658j-r8rw-q6mx) — CVE-2026-115560, Critical, CVSS 4.0 9.2. Patched in the five builds.
- [GHSA-fm2m-fjf5-v3cp](https://github.com/php/php-src/security/advisories/GHSA-fm2m-fjf5-v3cp) — CVE-2026-126714, Critical, CVSS 4.0 9.2. "The fix truncates the session file to zero before writing the replacement data."
- [GHSA-qc49-hpvq-g2w6](https://github.com/php/php-src/security/advisories/GHSA-qc49-hpvq-g2w6), [GHSA-2fjv-p558-g82m](https://github.com/php/php-src/security/advisories/GHSA-2fjv-p558-g82m), [GHSA-8mjj-2r7p-4hg2](https://github.com/php/php-src/security/advisories/GHSA-8mjj-2r7p-4hg2), [GHSA-g3vh-838c-65v7](https://github.com/php/php-src/security/advisories/GHSA-g3vh-838c-65v7), [GHSA-gr4f-wgx5-jpfv](https://github.com/php/php-src/security/advisories/GHSA-gr4f-wgx5-jpfv), [GHSA-jm4m-qfqx-967m](https://github.com/php/php-src/security/advisories/GHSA-jm4m-qfqx-967m), [GHSA-f6gg-rchx-xw8j](https://github.com/php/php-src/security/advisories/GHSA-f6gg-rchx-xw8j), [GHSA-mmf9-xm3v-hg2x](https://github.com/php/php-src/security/advisories/GHSA-mmf9-xm3v-hg2x) — the other six Critical and three High advisories, published 2026-11-19.
- [depthfirst, phpAfterShell][depth] — published 2026-11-19. Says the current 8.2 through 8.6 trees, including the November 19 ordering, are still vulnerable.
- [Google Cloud, GCP-2026-090][gcp] — published 2026-11-20. Managed images for App Engine, Cloud Run, and Cloud Run functions are not published yet. Names `session.upload_progress.enabled = 0` as the immediate mitigation for CVE-2026-126714.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, checked 2026-11-22. None of these CVEs is listed.

[gcp]: https://docs.cloud.google.com/support/bulletins#gcp-2026-090

[archive]: https://www.php.net/archive/2026.php#2026-11-18-1
[changelog]: https://www.php.net/ChangeLog-8.php
[depth]: https://depthfirst.com/research/phpaftershell
