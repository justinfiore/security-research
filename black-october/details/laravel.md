# Laravel: TokenGuard API authentication bypass on MySQL and MariaDB

**Last updated:** 2026-10-26 (America/New_York)

[Main Laravel summary](../black-october-2026.md#laravel-tokenguard-api-authentication-bypass-on-mysql-and-mariadb) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-114509](https://www.cve.org/CVERecord?id=CVE-2026-114509) (GHSA-f9x3-7vq9-cph6): GitHub CNA CVSS 4.0 9.2 Critical (CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N). NVD has not added its own score (status "Awaiting Analysis"). Not listed in CISA KEV.** Laravel's built-in `Illuminate\Auth\TokenGuard` (the guard created by the `token` auth driver) does not reject a non-string API credential. When the user table is on **MySQL or MariaDB**, a crafted value can make the token lookup match an unintended existing user. An **unauthenticated** attacker can then act as that user on every route protected by the guard. Affected: `laravel/framework` **before 12.68.0**, and **13.0.0 before 13.29.0**. [Laravel advisory][ghsa] [CNA][cve]

**Who is affected:** only applications that define a guard with `'driver' => 'token'` in `config/auth.php`, which by default reads an `api_token` request value and compares it with an `api_token` column. The Laravel 13 application skeleton defines only a `session` guard named `web`, so the token guard is opt-in. Laravel Sanctum registers its own `sanctum` driver and Laravel Passport registers its own `passport` driver with a separate guard class. Neither is named in the advisory, and the reviewed sources do not say they are affected. [AuthManager][authmgr] [Skeleton config][skel] [Sanctum][sanctum] [Passport][passport]

**Worst case:** account takeover through the API for the matched user. Hakai Security's analysis says the query returns the first user whose stored token does not start with a digit. Impact therefore depends on what that account can do. [Hakai][hakai]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). A public proof of concept exists; the reviewed sources report no in-the-wild exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Read-only inventory](#read-only-inventory)
  - [Reachability](#reachability)
  - [Log and account review](#log-and-account-review)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private report | Unknown date; before 2026-08-25 | Reported through GitHub's advisory process by KIKOmanasijev (Hristijan Manasijev). [Hakai][hakai] [Laravel advisory][ghsa] |
| Fix commits | 2026-08-25 01:15:08 UTC (13.x) and 01:16:16 UTC (12.x) | Commits `9b21ce0a9b` and `8dbb08bcca` add `is_string()` checks in `TokenGuard`. Git committer timestamps. [13.x fix][c13] [12.x fix][c12] |
| v13.27.0 tagged | 2026-08-25 14:17:39 UTC | First 13.x release containing the fix commit, per Git ancestry checked for this guide and per Hakai. The advisory designates **13.29.0** as patched. [v13.27.0][r1327] [Hakai][hakai] |
| **v12.68.0 released (fixed 12.x)** | 2026-08-25 14:19:59 UTC | GitHub release time. [v12.68.0][r1268] |
| v11.56.1 tagged | 2026-08-25 14:29:04 UTC (commit time) | Tag contains the same fix (`5056ca5379`); no GitHub release page. Not designated by the advisory, and Laravel 11 security support ended 2026-03-12. [Hakai][hakai] [Laravel support policy][policy] |
| **v13.29.0 released (fixed 13.x)** | 2026-08-25 20:58:51 UTC | GitHub release time. [v13.29.0][r1329] |
| **Public announcement: Laravel advisory GHSA-f9x3-7vq9-cph6** | **2026-10-19 13:32:50 UTC** | Repository advisory publication time (GitHub API). [Laravel advisory][ghsa] |
| Hakai Security analysis and public PoC | 2026-10-20; time/TZ unknown | Python exploit and Docker lab published on GitHub. [Hakai][hakai] |
| CVE record published | 2026-10-21 21:49:29 UTC | GitHub CNA; reserved 16:15:06 UTC the same day. NVD published 2026-10-21 22:16:49 (NVD API, UTC). [CNA][cve] [NVD][nvd] |
| GitHub Advisory Database review | 2026-10-23 21:50:27 UTC | Reviewed entry, so Dependabot can alert. [GitHub advisory][gad] |
| CISA KEV | Not listed (catalog 2026.10.23, checked 2026-10-26) | [KEV][kev] |
| Exploitation | None reported in reviewed sources | SecurityOnline (2026-10-23) reports "No confirmed exploitation yet". [SecurityOnline][so] |

## Detection

### Read-only inventory

Run these in each application's deployed root directory (the directory containing `composer.json`, `config/` and `vendor/`), as a user that can read those files. Placeholders: `APP_ROOT`. These commands **only read files**. They were not exercised on a real Laravel deployment.

```sh
cd APP_ROOT
# Version actually installed in vendor/ (reads vendor/composer/installed.json)
composer show laravel/framework | grep -E '^(name|versions)'
# Without Composer on the host (Composer 2 format)
jq -r '.packages[] | select(.name=="laravel/framework") | .version' vendor/composer/installed.json
# Version pinned in the lock file (may differ from vendor/ if a deploy is stale)
composer show --locked laravel/framework | grep -E '^(name|versions)'
```

Check every deployed copy: containers, release directories (for example Envoyer or Deployer `releases/*`), queue-worker and Octane hosts. A 12.x version below **12.68.0**, any 13.x version below **13.29.0**, or any 11.x or older version is in the advisory's affected range.

Then check whether the application uses the token driver and which database stores users:

```sh
cd APP_ROOT
grep -rnE "'driver'[[:space:]]*=>[[:space:]]*'token'" config/
grep -rnE "auth:api|auth:[a-z_]*token|Auth::guard\(" routes/ app/ | head -50
# Print only the connection setting, not the rest of .env (it holds secrets)
grep -E '^DB_CONNECTION=' .env
grep -nE "'(driver|connection)'" config/auth.php config/database.php | head -40
```

A guard named `api` is not necessarily a token guard. What matters is `'driver' => 'token'`. Note the guard's `provider` and that provider's model or table connection; the advisory's condition is a MySQL or MariaDB user store. `sanctum` or `passport` drivers are separate implementations not named by the advisory.

### Reachability

The guard reads the credential from the query string, then the request input (including JSON bodies), then the `Authorization: Bearer` header. [TokenGuard source][tg] Any route protected by a token-driver guard and reachable by an attacker is exposed. List those routes from source (`routes/api.php` and any route group using the guard) rather than running application code on a host you suspect is compromised.

### Log and account review

No vendor IOCs exist. Hakai's analysis shows the crafted credential arriving as a **JSON request body**, which standard web access logs do not record. Access logs alone therefore cannot show exploitation. [Hakai][hakai]

- Identify likely target accounts: per Hakai, the lookup returns the first user whose stored `api_token` does not start with a digit. Review API activity for those users, especially from new IP addresses or clients. A read-only query sketch (replace `USERS_TABLE`, run with a read-only database account):

  ```sql
  SELECT id, email, LEFT(api_token, 1) AS first_char
  FROM USERS_TABLE
  WHERE api_token IS NOT NULL AND api_token NOT REGEXP '^[0-9]'
  ORDER BY id LIMIT 20;
  ```

- Review application audit logs for token-guarded API actions by accounts that do not normally use the API, or bursts of activity as a single user from many sources.
- If request bodies are logged (API gateway, WAF or application request logging), search for `api_token` values that are JSON numbers or arrays instead of strings.

Finding nothing does not prove the application was not exploited.

## Remediation

1. **Upgrade `laravel/framework`** to **12.68.0 or later** (12.x) or **13.29.0 or later** (13.x), for example `composer update laravel/framework --with-dependencies`, then commit the lock file and redeploy. [Laravel advisory][ghsa]
2. **Reload every PHP process** that serves the application: PHP-FPM (or clear OPcache), Laravel Octane workers, and queue workers. Long-running workers keep the old code until restarted.
3. **Laravel 11 and older:** move to a supported release line. Laravel 11 security support ended 2026-03-12. [Laravel support policy][policy] A v11.56.1 tag contains the same fix commit, but the advisory does not designate it. Treat it as an unsupported stopgap.
4. **No vendor workaround is published.** If you cannot upgrade quickly and do not need the token guard, remove it from `config/auth.php` and its routes. Migrating to Sanctum is a design change, not an emergency fix.

## Verification

- Re-run the inventory on the **deployed** artifact (each container image, release directory and worker host) and confirm 12.68.0+ or 13.29.0+.
- Confirm the installed `vendor/laravel/framework/src/Illuminate/Auth/TokenGuard.php` contains `is_string($token)`:

  ```sh
  grep -nF 'is_string($token)' APP_ROOT/vendor/laravel/framework/src/Illuminate/Auth/TokenGuard.php
  ```

- Benign functional control: a request with a valid token still authenticates, and a request with no token or a wrong string token gets 401. Do not send non-string payloads to production.

## Compromise response

- **Rotate all `api_token` values** for users of the token guard, and invalidate any longer-lived credentials or sessions that the API can issue.
- Review changes made through token-guarded routes: profile and email changes, password resets, new API clients, role changes, exported data.
- If the matched account was privileged, treat the application and its data as compromised and investigate further (new admin users, changed settings, uploaded files).
- Preserve web, application and database logs before cleanup.

## Sources

- [Laravel advisory GHSA-f9x3-7vq9-cph6][ghsa]: description, affected and patched versions, CVSS 4.0, publication time.
- [CVE record (GitHub CNA)][cve], [NVD][nvd] and [GitHub Advisory Database][gad]: timestamps and ranges.
- [Fix commit 13.x][c13], [fix commit 12.x][c12], releases [v12.68.0][r1268], [v13.27.0][r1327], [v13.29.0][r1329].
- Framework source: [AuthManager `createTokenDriver`][authmgr], [TokenGuard][tg]; [Laravel 13 skeleton `config/auth.php`][skel]; [Sanctum service provider][sanctum]; [Passport service provider][passport]; [Laravel support policy][policy].
- [CISA KEV feed][kev]: not listed.
- Researcher: [Hakai Security / Yokai analysis][hakai] (root cause, PoC, v13.27.0 and v11.56.1 observations).
- Secondary: [Laravel News][ln], [SecurityOnline][so].

[ghsa]: https://github.com/laravel/framework/security/advisories/GHSA-f9x3-7vq9-cph6
[gad]: https://github.com/advisories/GHSA-f9x3-7vq9-cph6
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-114509
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-114509
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[c13]: https://github.com/laravel/framework/commit/9b21ce0a9bb2b2599978bc0b0df4abea952ad31c
[c12]: https://github.com/laravel/framework/commit/8dbb08bccac1be095dba4a9d259a419620f1e8a5
[r1268]: https://github.com/laravel/framework/releases/tag/v12.68.0
[r1327]: https://github.com/laravel/framework/releases/tag/v13.27.0
[r1329]: https://github.com/laravel/framework/releases/tag/v13.29.0
[authmgr]: https://github.com/laravel/framework/blob/v13.29.0/src/Illuminate/Auth/AuthManager.php
[tg]: https://github.com/laravel/framework/blob/v13.29.0/src/Illuminate/Auth/TokenGuard.php
[skel]: https://github.com/laravel/laravel/blob/13.x/config/auth.php
[sanctum]: https://github.com/laravel/sanctum/blob/4.x/src/SanctumServiceProvider.php
[passport]: https://github.com/laravel/passport/blob/13.x/src/PassportServiceProvider.php
[policy]: https://laravel.com/docs/13.x/releases#support-policy
[hakai]: https://yokai.hakaisecurity.io/en-ghsa-f9x3-7vq9-cph6-authentication-bypass-in-laravel-tokenguard
[ln]: https://laravel-news.com/laravel-token-guard-auth-bypass
[so]: https://securityonline.info/laravel-authentication-bypass-cve-2026-114509-poc
