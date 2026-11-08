# Control Web Panel: login bypass and root commands on the loopback API

**Last updated:** 2026-11-06 (America/New_York)

[Main Control Web Panel summary](../black-october-2026.md#control-web-panel-login-bypass-and-root-commands-on-the-loopback-api) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

VulnCheck disclosed ten flaws in Control Web Panel (CWP, formerly CentOS Web Panel) on 2026-11-03. VulnCheck is the CNA. NVD has not scored them. The vendor changelog does not name the CVEs.

**[CVE-2026-73696](https://www.cve.org/CVERecord?id=CVE-2026-73696): VulnCheck CVSS 4.0 8.6 High and CVSS 3.1 8.1 High.** Before webpanel 1.12, the user-panel login redirect does not stop the request, so an unauthenticated caller continues into the panel. VulnCheck says a hosting username is enough. Fixed in 1.12, released 2026-09-08. The vendor's note for that release is "Security improvements."

**[CVE-2026-73695](https://www.cve.org/CVERecord?id=CVE-2026-73695), [CVE-2026-73697](https://www.cve.org/CVERecord?id=CVE-2026-73697), and [CVE-2026-77876](https://www.cve.org/CVERecord?id=CVE-2026-77876): VulnCheck CVSS 4.0 8.7 High and CVSS 3.1 8.8 High.** Before 1.16, the user-panel dispatcher includes a file named by the `module` parameter, the `phpini_editor` module writes a chosen path and runs a command, and `protected_directory` runs a command from a file name. The CVE records say the caller needs access to the module. VulnCheck says that, before 1.12, the missing `exit()` makes that access unauthenticated, and that the chain reaches root. Fixed in 1.16. The changelog has no 1.16 entry; VulnCheck dates the build 2026-09-29.

**[CVE-2026-77879](https://www.cve.org/CVERecord?id=CVE-2026-77879): VulnCheck CVSS 4.0 8.4 High and CVSS 3.1 7.1 High.** Before 1.16, the loopback API's `access_token()` check interpolates caller input into a query that runs as MySQL root, so the check can be forged. Fixed in 1.16. The record was updated 2026-11-07 and still says before 1.16.

**[CVE-2026-77880](https://www.cve.org/CVERecord?id=CVE-2026-77880): VulnCheck CVSS 4.0 8.5 High and CVSS 3.1 7.8 High.** Before 1.16, the loopback `/newpass/` route runs a shell command as root from the `user` parameter. Fixed in 1.16.

**[CVE-2026-77877](https://www.cve.org/CVERecord?id=CVE-2026-77877), [CVE-2026-77878](https://www.cve.org/CVERecord?id=CVE-2026-77878), and [CVE-2026-104080](https://www.cve.org/CVERecord?id=CVE-2026-104080): VulnCheck CVSS 4.0 8.5 High.** The CVSS 3.1 score on each is 7.8 High. Before 1.29, several routes on the loopback API at `127.0.0.1:2302` do not require a token, the database-restore route runs a command as root, and `/valid_token/` runs `grep` as root with the raw `user` value. The records say an attacker who can reach that service. VulnCheck says the service listens on localhost, and that the user-panel bugs are how a remote caller reaches it. Fixed in 1.29, released 2026-10-31. The changelog's security note for 1.27, the day before, is a review of the admin panel and both APIs; it does not name these routes. [CVE-2026-104080](https://www.cve.org/CVERecord?id=CVE-2026-104080) was updated 2026-11-07 and still says before 1.29.

**[CVE-2026-77881](https://www.cve.org/CVERecord?id=CVE-2026-77881): VulnCheck CVSS 4.0 6.8 Medium and CVSS 3.1 5.5 Medium.** Before 1.29, the same unauthenticated loopback route reads the database as MySQL root. It is in this entry because it ships in the same disclosure. It is not a High score.

VulnCheck says it reproduced an unauthenticated path to `uid=0` in a lab on 2026-08-18, and that it decoded 1.30 on 2026-11-02 and found all ten fixed. It does not report a customer compromise for these ten. It does say a backdoored `cwpsrv` is a separate incident, CWPdoor, with no CVE and no link to these flaws.

The records and the blog disagree on two ceilings. The [CVE-2026-104080](https://www.cve.org/CVERecord?id=CVE-2026-104080) record says before 1.29. Some mirrors of that record say before 1.30. VulnCheck's disclosure says 1.29 fixed it and 1.30 did not reopen it. The [CVE-2026-73696](https://www.cve.org/CVERecord?id=CVE-2026-73696) record scores 8.6 and 8.1 and says the bypass needs a low-privileged user. An earlier copy of the same record scored 9.3 and 9.1 and said no privileges. This guide uses the JSON published by the CVE service on 2026-11-07.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-06) for any of the ten. VulnCheck does not report exploitation of these ten on a customer server. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Lab reproduction | 2026-08-18; time/TZ unknown | VulnCheck says an unauthenticated request reached `uid=0` in a docker lab. [VulnCheck][vc] |
| Partial fixes | 2026-09-08 and 2026-09-29; time/TZ unknown | 1.12 closes the unauthenticated entry. 1.16 fixes the user-panel modules and two API sinks. Four API bugs remain. [VulnCheck][vc] [changelog][log] |
| Remaining fixes | 2026-10-31; time/TZ unknown | 1.29. The changelog date is 31/10/2026. [changelog][log] |
| **Public announcement** | **2026-11-03; time/TZ unknown** | VulnCheck's disclosure. CVE records published 2026-11-02. [VulnCheck][vc] |
| Record updates | 2026-11-07 00:24 UTC and 00:25 UTC | [CVE-2026-77879](https://www.cve.org/CVERecord?id=CVE-2026-77879) and [CVE-2026-104080](https://www.cve.org/CVERecord?id=CVE-2026-104080). Scores and the 1.16 / 1.29 ceilings are unchanged from the 2026-11-03 update. |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-06) | None of the ten. [KEV][kev] |

## Detection

On the CWP host, as root. This only reads.

```sh
cat /usr/local/cwpsrv/htdocs/admin/admin/version.php 2>/dev/null
/usr/local/cwpsrv/htdocs/resources/scripts/update_cwp --version 2>/dev/null
ss -lnt | awk '$4 ~ /:2302$/ || $4 ~ /:2304$/'
```

The version file is one place CWP stores `webpanel_version`. If neither command prints a version, read the version the admin panel shows and record the check as incomplete rather than clear. A version below 1.29 is inside at least the loopback-API flaws. A version below 1.12 is also inside the unauthenticated login bypass.

Port 2302 is the user-panel API and 2304 is the external API. A listener on `127.0.0.1` only is what VulnCheck describes. A listener on any other address means the API is reachable beyond localhost; that is a wider exposure than the disclosure assumes, not a different bug.

Do not send the module-name traversal or a shell metacharacter to the panel. The version is enough to decide whether to update.

## Remediation

1. **Update Control Web Panel to 1.29 or later.** The changelog now lists 1.30.1, released 03/11/2026, as a security and stability update, and the page footer says the current version is 1.30.4. VulnCheck's November 3 disclosure still says 1.29 or later contains the ten fixes, and it does not assign a new CVE to 1.30.1. Use the panel's own update. A jump across many versions may need more than one update; the vendor's update log is the record of what ran.
2. There is no vendor workaround for the ten flaws. Keeping the panel off the internet reduces who can reach the user panel. It does not fix a server that is still below 1.29, and it does not matter for an attacker who already has a hosting account on that server.
3. Updating does not remove a PHP file the `phpini_editor` module already wrote, and it does not undo a command the loopback API already ran as root.

## Verification

- The version check prints **1.29 or later**.
- Open the admin panel and confirm it still loads. Do not request a module name containing `../`, and do not post a `user` value containing a quote.

## Compromise response

VulnCheck does not publish an indicator for these ten flaws. If the panel was reachable while the version was below 1.12, treat an unauthenticated path to root as possible. If it was below 1.29 and any hosting account existed, treat a command as root as possible.

- Preserve `/var/log/cwp/` and the panel web-server logs before cleanup.
- Look for PHP files under account homes and under `/usr/local/cwpsrv/` whose timestamps you cannot explain. A file there is a lead, not proof of these CVEs.
- Review new accounts, new SSH keys, and cron files. CWPdoor, the backdoor reported the same week, hides in `cwpsrv` and is not fixed by this update. A clean version string does not clear that backdoor.
- If a command ran as root, rebuild the host. Rotating panel passwords on a host that already ran attacker code does not finish the job.

## Sources

- [VulnCheck, CWP2Shell][vc] — public disclosure 2026-11-03. Ten CVEs, the version each fix landed in, and the lab reproduction. No customer compromise claimed for these ten.
- [CWP changelog][log] — 1.12 on 08/09/2026 ("Security improvements"), 1.27 and 1.29 and 1.30 on 30/10/2026 and 31/10/2026. Reread 2026-11-08: 1.30.1 released 03/11/2026, and the footer says current version 1.30.4. No CVE IDs.
- [CVE-2026-73696][cve696] — VulnCheck CNA, published 2026-11-02, updated 2026-11-03. CVSS 4.0 8.6, CVSS 3.1 8.1. Before 1.12.
- [CVE-2026-73695][cve695] — CVSS 4.0 8.7, CVSS 3.1 8.8. Before 1.16.
- [CVE-2026-104080][cve080] — CVSS 4.0 8.5, CVSS 3.1 7.8. Before 1.29. Updated 2026-11-07; the ceiling is still 1.29.
- [CISA KEV][kev] — catalog 2026.11.06. None of the ten is listed.

[vc]: https://www.vulncheck.com/blog/control-web-panel-pre-auth-module-dispatch-rce
[log]: https://control-webpanel.com/changelog
[cve696]: https://www.cve.org/CVERecord?id=CVE-2026-73696
[cve695]: https://www.cve.org/CVERecord?id=CVE-2026-73695
[cve080]: https://www.cve.org/CVERecord?id=CVE-2026-104080
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
