# WordPress: unauthenticated code execution during a core upgrade

**Last updated:** 2026-10-30 (America/New_York)

[Main WordPress summary](../black-october-2026.md#wordpress-unauthenticated-code-execution-during-a-core-upgrade) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**No CVE is assigned.** Wordfence rates the unauthenticated upgrade-window flaw **CVSS 3.1 8.1 High** (`AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`). WordPress describes it as a weakness in the upgrade process that can lead to remote code execution, without its own score. Patchstack scored the same race `AC:H` and says it would not call the race practical. WordPress 7.1.4 also fixes other issues, most of which need a Contributor account or higher; those are not this flaw.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. Wordfence reports exploit attempts against the predictable staging path, not confirmed compromise. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private report | Unknown | WordPress credits Umut Bayram. No report date is published. |
| WordPress 7.1.4 and backports | 2026-10-28; time/TZ unknown | Security release. Backports through the 4.7 branch. [Release][release] [HelpHub][helphub] |
| Wordfence firewall rule | 2026-10-28 20:30 UTC | Premium, Care and Response customers. Free users receive it 2026-11-27. [Wordfence][wf] |
| Exploitation attempts | From about nine minutes after the firewall rule, through the first 21 hours | Wordfence recorded more than 18,500 requests for staged `setup-config.php` paths. This is probing, not confirmed compromise. [Wordfence][wf] |

## Detection

1. Read the installed WordPress version from `wp-includes/version.php` (`$wp_version`) or **Dashboard → Updates**. A version below the fixed release for its branch is affected: 7.1 before 7.1.4, and the older branches Wordfence lists through 4.7.39. WordPress 4.6 and earlier receive no fix.
2. The flaw applies while a full-package core upgrade unpacks into a predictable, web-reachable directory under `wp-content/upgrade`. A site that never runs core upgrades, or whose upgrade directory is not reachable as PHP, does not present the race. Do not treat "we update rarely" as proof the directory was unreachable.
3. Review web logs for requests to PHP files under `wp-content/upgrade`, especially `setup-config.php`, around core updates since 2026-10-28. Wordfence's count is of probes, not of sites that were compromised. No matching log line is not proof the site was safe.

## Remediation

1. Update to **7.1.4**, or the fixed release for the installed branch. Wordfence lists **7.0.8, 6.9.11, 6.8.12, 6.7.11, 6.6.11, 6.5.14, 6.4.14, 6.3.14, 6.2.15, 6.1.16, 6.0.18, 5.9.20, 5.8.19, 5.7.21, 5.6.23, 5.5.24, 5.4.25, 5.3.27, 5.2.30, 5.1.28, 5.0.31, 4.9.35, 4.8.34 and 4.7.39**. WordPress says only the newest branch is actively supported; 4.6 and earlier get nothing.
2. Confirm the update finished. Automatic background updates are the normal path, but Wordfence says to check **Dashboard → Updates** rather than assume they completed.
3. WordPress 7.1.4 randomizes the staging directory and adds an index guard. A firewall rule is not a substitute: the request hits a staged PHP file without loading WordPress, so a plugin firewall has to run before that file. Wordfence Free does not get its rule until 2026-11-27.
4. Sites on 4.6 or older need an upgrade to a supported release. Do not install WordPress from a third-party archive to reach a version number.

## Verification

- Confirm `$wp_version` matches the fixed release for that branch, then load the site and an authenticated admin page you already use.
- Do not request staged installer paths or run an exploit against a production site to test the race.

## Compromise response

If logs show a request to a PHP file under `wp-content/upgrade` during an upgrade window before the fix, preserve those logs and a copy of `wp-content` before cleanup. Look for new administrator users, unexpected plugins, and PHP files you did not place. Updating closes the race; it does not show whether an earlier request succeeded. Wordfence does not report a confirmed compromise from these probes.

## Sources

- [WordPress 7.1.4 release][release] — security release, the upgrade-process weakness, and the backport statement.
- [WordPress 7.1.4 documentation][helphub] — the race, the count of issues per branch, and that 4.6 and earlier are unsupported.
- [Wordfence, 2026-10-29][wf] — CVSS 3.1 8.1, affected and patched versions, how the staging path works, and the probe counts.
- [Patchstack][patchstack] — unauthenticated race, web-reachable `wp-content/upgrade`, and the same-day backports.
- [CISA KEV JSON feed][kev] — KEV lists only CVEs; this issue has none.

[release]: https://wordpress.org/news/2026/10/wordpress-7-1-4/
[helphub]: https://wordpress.org/documentation/wordpress-version/version-7-1-4/
[wf]: https://www.wordfence.com/blog/2026/10/wordpress-7-1-4-security-release-rce/
[patchstack]: https://patchstack.com/articles/wordpress-7-1-4-security-release
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
