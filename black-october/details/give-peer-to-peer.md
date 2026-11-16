# WordPress: Give Peer-to-Peer reads the database and changes a team before login

**Last updated:** 2026-11-16 (America/New_York)

[Main Give Peer-to-Peer summary](../black-october-2026.md#wordpress-give-peer-to-peer-reads-the-database-and-changes-a-team-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Give - Peer-to-Peer is a paid add-on for the GiveWP donation plugin. It is not on WordPress.org: the plugin API returns 404 for the slug `give-peer-to-peer`. Wordfence is the CNA for both flaws and rates each **CVSS 3.1 7.5 High**.

[CVE-2026-82568](https://www.cve.org/CVERecord?id=CVE-2026-82568) is a time-based SQL injection through the `sort` parameter, affected from the beginning through **2.9.3**. A request with no login can append SQL and read the database. Wordfence says it needs at least one Peer-to-Peer campaign to exist. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N`.

[CVE-2026-82663](https://www.cve.org/CVERecord?id=CVE-2026-82663) is an authorization bypass, affected from the beginning through **2.9.5**. Someone who knows a campaign ID and a team ID, and who is not logged in, can change that team's name, story, goal, access, and notification settings, set its profile image, and upload a media file WordPress allows, stored as an attachment with no parent. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:N`.

Wordfence says the two can be combined to run code with no login. It does not describe that combination. NVD has not published its own score for either record.

The vendor changelog for **2.9.4**, dated 2026-09-08, says it hardened team updates (CVE-2026-82663) and campaign sorting (CVE-2026-82568). Wordfence's own records disagree with that for the second flaw: the SQL injection is patched in 2.9.4, and the authorization bypass is patched in **2.9.6**. The current changelog entry is **2.9.7**, dated 2026-10-27, and it does not mention either CVE. 2.9.4 is therefore not the release to install.

This is not [Advanced Form Integration](advanced-form-integration.md), [Estatik](estatik.md), or the [November 6 set](wordpress-plugins-nov6.md).

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-16). Neither CVE is in the feed. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Give Peer-to-Peer 2.9.4 | 2026-09-08; time/TZ unknown | Changelog says both CVEs were hardened. Wordfence says only the SQL injection is fixed here. [Nexcess changelog][log] |
| Give Peer-to-Peer 2.9.6 | 2026-10-14; time/TZ unknown | Wordfence's patched version for the authorization bypass. The changelog does not name the CVE. [Wordfence][wf2] |
| Give Peer-to-Peer 2.9.7 | 2026-10-27; time/TZ unknown | Current changelog entry. It does not name either CVE. [Nexcess changelog][log] |
| Wordfence pages | 2026-11-14; time/TZ unknown | Publicly published November 14. Last updated November 15. [Wordfence][wf1] |
| **Public announcement** | **2026-11-15; time/TZ unknown** | Wordfence published both CVE records. NVD's published time for each is 2026-11-15 10:16 UTC. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. Update Give Peer-to-Peer. |

## Detection

On a trusted copy of the site, read the installed version. Do not run this on a host you suspect is compromised; read the files from a snapshot instead.

```sh
wp plugin list --fields=name,status,version --format=csv
```

If WP-CLI is not available, read the `Version:` line in `wp-content/plugins/give-peer-to-peer/give-peer-to-peer.php`. The slug is the one Wordfence publishes; confirm the directory name on the site.

| Plugin | Slug | Affected | Fixed |
|---|---|---|---|
| Give - Peer-to-Peer | `give-peer-to-peer` | SQL injection through 2.9.3; authorization bypass through 2.9.5 | 2.9.6 for both, per Wordfence; current changelog entry 2.9.7 |

A plugin that is installed and inactive can still be reachable if WordPress loads its code. A site without the add-on is outside this entry. The SQL injection needs a campaign to exist; a site with the add-on installed and no campaign is not known to be safe from the authorization bypass.

## Remediation

1. Update Give - Peer-to-Peer to **2.9.7 or later**. 2.9.6 is the first version Wordfence calls fixed for both flaws. 2.9.4 fixes only the SQL injection.
2. If the add-on is unused, remove it instead of leaving an affected copy inactive.
3. The update does not show whether a query already read the database, or whether a team or an upload was already changed.

## Verification

- `wp plugin get give-peer-to-peer --field=version` shows 2.9.6 or later.
- Open one campaign page. Do not send the `sort` value or the team-update request the advisories describe.

## Compromise response

No source publishes an indicator or a confirmed compromise. Look for team names, stories, goals, and profile images that changed without a fundraiser editing them, and for media attachments with no parent post. A changed team is a lead, not proof. The SQL injection can read the database; if you cannot rule that out, rotate the database password and the authentication keys in `wp-config.php`.

## Sources

- [CVE-2026-82568](https://www.cve.org/CVERecord?id=CVE-2026-82568) — Wordfence, published 2026-11-15. CVSS 3.1 7.5. Affected through 2.9.3. The `sort` parameter. Needs one campaign.
- [CVE-2026-82663](https://www.cve.org/CVERecord?id=CVE-2026-82663) — Wordfence, published 2026-11-15. CVSS 3.1 7.5. Affected through 2.9.5. Needs a campaign ID and a team ID.
- [Wordfence, CVE-2026-82568][wf1] — publicly published November 14, 2026. Patched in 2.9.4.
- [Wordfence, CVE-2026-82663][wf2] — publicly published November 14, 2026. Patched in 2.9.6.
- [Nexcess changelog, Give Peer-to-Peer][log] — 2.9.4 on 2026-09-08 names both CVEs. 2.9.7 on 2026-10-27 is the newest entry and does not.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. Neither CVE is in it.

[wf1]: https://www.wordfence.com/threat-intel/vulnerabilities/id/8b68d24c-a963-4316-a8f3-8dc6a494e016?source=cve
[wf2]: https://www.wordfence.com/threat-intel/vulnerabilities/id/f424258a-367d-43cb-b66b-1f898391a0ea?source=cve
[log]: https://docs.nexcess.com/software/changelogs/give/give-peer-to-peer/
