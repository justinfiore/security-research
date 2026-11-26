# Symfony: a request header picks the proxy, and a CSV crashes PHP

**Last updated:** 2026-11-26 (America/New_York)

[Main Symfony summary](../black-october-2026.md#symfony-a-request-header-picks-the-proxy-and-a-csv-crashes-php) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On November 25 Symfony released 8.1.12, 7.4.24, 6.4.51, and 5.4.57. GitHub rates six of the flaws in that release High. Symfony is the CNA. The scores are CVSS 4.0. The same releases fix more flaws GitHub rates Moderate, and those are not repeated here.

**CISA KEV:** Not listed (catalog 2026.11.25, released 2026-11-25T19:48:12.4344Z, checked 2026-11-26) for any of the six. The advisories do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

| CVE | GitHub | Score | What it does | Affected |
|---|---|---|---|---|
| [CVE-2026-134792](https://www.cve.org/CVERecord?id=CVE-2026-134792) | [GHSA-cjfx-x9pc-q4rx](https://github.com/symfony/symfony/security/advisories/GHSA-cjfx-x9pc-q4rx) | 8.3 | A `Proxy` header chooses the proxy | `symfony/http-client` before 5.4.57, 6.4.51, 7.4.24, or 8.1.12 |
| [CVE-2026-133757](https://www.cve.org/CVERecord?id=CVE-2026-133757) | [GHSA-v6qm-94rx-6x93](https://github.com/symfony/symfony/security/advisories/GHSA-v6qm-94rx-6x93) | 8.2 | A redirect gets the wrapped client's credentials | 5.4.48–5.4.56, 6.4.16–6.4.50, 7.1.9–7.4.23, and 8 before 8.1.12 |
| [CVE-2026-133761](https://www.cve.org/CVERecord?id=CVE-2026-133761) | [GHSA-4xg9-mw5c-qq5p](https://github.com/symfony/symfony/security/advisories/GHSA-4xg9-mw5c-qq5p) | 8.7 | A CSV header crashes PHP | `symfony/serializer` before those four releases |
| [CVE-2026-134791](https://www.cve.org/CVERecord?id=CVE-2026-134791) | [GHSA-5vf6-gchv-cmcr](https://github.com/symfony/symfony/security/advisories/GHSA-5vf6-gchv-cmcr) | 8.7 | An unclosed comment hangs the lexer | `symfony/expression-language` 7.2.0–7.4.23 and 8 before 8.1.12 |
| [CVE-2026-133760](https://www.cve.org/CVERecord?id=CVE-2026-133760) | [GHSA-fvvg-g68p-p6q9](https://github.com/symfony/symfony/security/advisories/GHSA-fvvg-g68p-p6q9) | 8.7 | Nested short ternaries hang the parser | 5.4.54–5.4.56, 6.4.48–6.4.50, 7.4.21–7.4.23, and 8.1.9–8.1.11 |
| [CVE-2026-133743](https://www.cve.org/CVERecord?id=CVE-2026-133743) | [GHSA-8cww-v5fg-2mf9](https://github.com/symfony/symfony/security/advisories/GHSA-8cww-v5fg-2mf9) | 7.0 | A forwarded header changes `asset()` | `symfony/http-kernel` before those four releases |

The 8.3 vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:L/VA:N/SC:N/SI:N/SA:N`. The 8.2 vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`. Both 8.7 denial-of-service vectors are `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:H/SC:N/SI:N/SA:N`. The 7.0 vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:N/VI:L/VA:N/SC:H/SI:H/SA:N`. Symfony's own blog pages do not print the numbers. GitHub does.

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
| Earlier expression-parser fix | 2026-10; exact day not restated here | CVE-2026-109449. Its nesting check is what CVE-2026-133760 hangs. [Symfony][cve760] |
| Earlier forwarded-header fix | 2026-11-04; time unknown | CVE-2026-123339, fixed in 7.4.23 and 8.1.11. CVE-2026-133743 says that fix left the cause in place. [Symfony][cve743] |
| **Public announcement and fixes** | **2026-11-25; time unknown** | 8.1.12, 7.4.24, 6.4.51, and 5.4.57. GitHub published the advisories the same day. [GHSA][ghsa792] |
| Drupal notes the gap | 2026-11-25 16:48 UTC | Drupal 11.4.14 says the Symfony security update is not in that build. 10.6.23 says the same at 16:51 UTC, for the 6.4 line. [Drupal][drupal] |
| **Last updated** | **2026-11-26 (America/New_York)** | New item. |

## Detection

1. From the project root, `composer show 'symfony/*'` and read the installed version of `http-client`, `serializer`, `expression-language`, and `http-kernel`. A lockfile that still names 7.4.23 is inside CVE-2026-133760 and CVE-2026-133743.
2. CVE-2026-134792 needs a worker that runs HTTP under the CLI SAPI and copies request headers into `$_SERVER`. Symfony names spiral/roadrunner-http, baldinof/roadrunner-bundle, and php-pm. An application served by php-fpm or mod_php is outside that one flaw. It is not outside the other five.
3. CVE-2026-133743 needs the main request to arrive from `127.0.0.1`, which is a TLS terminator, reverse proxy, or cache on the same host, plus a page that renders an inline fragment. php-fpm and mod_php receiving the request directly are outside it.
4. CVE-2026-133757 needs `NoPrivateNetworkHttpClient` (or, on 8.1, `DnsResolvingHttpClient`) wrapping a client that has default credentials.

## Remediation

1. Upgrade the four packages to **8.1.12, 7.4.24, 6.4.51, or 5.4.57** on the line you already run, then redeploy every worker that loaded the old code. `composer update 'symfony/*'` is the usual command. 7.4.23 and 8.1.11 are not enough.
2. A Drupal site on 11.4.14, 11.3.23, or 10.6.23 still needs this upgrade. Those release notes say the Symfony update shipped the same day is not included. Follow Drupal's own note on third-party dependencies.
3. Rotate a long-lived credential that an outgoing client could have sent on a redirect. The upgrade does not get it back.
4. The Moderate flaws in the same releases are fixed by the same four versions. This guide does not list them.

## Verification

- `composer show symfony/http-client symfony/serializer symfony/expression-language symfony/http-kernel` reports one of the four fixed versions, in every deployed environment.
- The workers were restarted after the deploy. A lockfile change does not replace a running process.
- Do not send a `Proxy` header or a CSV built to crash the process.

## Compromise response

If a CLI worker was reachable before the upgrade, assume an outgoing `http://` request made while it handled a request may have gone to a proxy the caller chose, with its credentials. Rotate those credentials. A cached page that rendered an inline fragment may contain an `asset()` URL pointing at another host. Purge that cache. The advisories do not name a log line.

## Sources

- [GHSA-cjfx-x9pc-q4rx][ghsa792] — published 2026-11-25. High, CVSS 4.0 8.3. CVE-2026-134792.
- [Symfony, CVE-2026-134792](https://symfony.com/blog/cve-2026-134792-httpclient-lets-the-proxy-header-of-a-request-choose-the-proxy-of-outgoing-requests-in-cli-sapi-http-workers) — November 25, 2026. Names RoadRunner and php-pm. No numeric score on the page.
- [GHSA-v6qm-94rx-6x93](https://github.com/symfony/symfony/security/advisories/GHSA-v6qm-94rx-6x93) — High, 8.2. CVE-2026-133757.
- [GHSA-4xg9-mw5c-qq5p](https://github.com/symfony/symfony/security/advisories/GHSA-4xg9-mw5c-qq5p) — High, 8.7. CVE-2026-133761. 448 KB on an 8 MB stack.
- [GHSA-5vf6-gchv-cmcr](https://github.com/symfony/symfony/security/advisories/GHSA-5vf6-gchv-cmcr) — High, 8.7. CVE-2026-134791.
- [GHSA-fvvg-g68p-p6q9][cve760] — High, 8.7. CVE-2026-133760. The incomplete fix for CVE-2026-109449.
- [Symfony, CVE-2026-133743][cve743] — November 25, 2026. The incomplete fix for CVE-2026-123339. GitHub scores it 7.0.
- [Drupal 11.4.14][drupal] — created 2026-11-25 16:48 UTC. Says the Symfony security update is not in the release.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-26. None of the six is listed.

[ghsa792]: https://github.com/symfony/symfony/security/advisories/GHSA-cjfx-x9pc-q4rx
[cve760]: https://github.com/symfony/symfony/security/advisories/GHSA-fvvg-g68p-p6q9
[cve743]: https://symfony.com/blog/cve-2026-133743-inline-fragments-let-forwarded-headers-change-the-urls-of-asset-and-absolute-url-incomplete-fix-for-cve-2026-123339
[drupal]: https://www.drupal.org/project/drupal/releases/11.4.14
