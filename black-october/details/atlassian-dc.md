# Atlassian Data Center: unauthenticated web-root file read

**Last updated:** 2026-10-26 (America/New_York)

[Main Atlassian Data Center summary](../black-october-2026.md#atlassian-data-center-unauthenticated-web-root-file-read-cve-2026-21589) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-21589](https://www.cve.org/CVERecord?id=CVE-2026-21589): Atlassian CVSS 4.0 9.3 Critical; NVD CVSS 3.1 7.5 High (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N). Listed in CISA KEV on 2026-10-15.** An unauthenticated remote attacker can read specific files inside the web application root of **Bitbucket, Confluence, Jira Software, Jira Service Management, Bamboo and Crowd Data Center, plus Crucible and Fisheye**. The attacker must know the file's exact name and path. The flaw does not list directories, and researchers found it cannot reach files outside the Tomcat context, such as `/etc/passwd`. The **worst case depends on configuration**. watchTowr showed that a Jira instance using Crowd stores the Crowd application name and plaintext password in `WEB-INF/classes/crowd.properties`. Reading that file let them call Crowd's API and add a user to `jira-administrators`. Atlassian says its affected Cloud products are patched and need no customer action. [Advisory][adv] [CNA][cve] [NVD][nvd] [watchTowr][wt]

The two scores measure different things. Atlassian's 4.0 vector sets the subsequent-system impact to High (SC:H/SI:H/SA:H). NVD's 3.1 vector scores only confidentiality of the vulnerable system (C:H, I:N, A:N). Both are shown here because the item qualifies for this guide under either score.

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and fixed versions](#inventory-and-fixed-versions)
  - [Exposure](#exposure)
  - [Access-log search (read-only)](#access-log-search-read-only)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | The reviewed sources do not say who found the flaw or when it was reported. CVE ID reserved 2026-01-01 00:00:40 UTC, which is a bulk-reservation timestamp and not a discovery date. [CNA][cve] |
| Atlassian advisory and fixed releases | 2026-10-05; time/TZ unknown | "Advisory Release Date 05 Oct 2026"; out-of-band. Fixed versions are listed below. [Advisory][adv] |
| CVE record published | 2026-10-05 21:30:00 UTC | CNA metadata. NVD published 2026-10-05 22:16:58 UTC. [CNA][cve] [NVD][nvd] |
| Technical analysis and PoC URLs | 2026-10-06; time/TZ unknown | watchTowr Labs traced the flaw to `::`→`/` unescaping in `atlassian-plugins-webresource`. The watchTowr intelligence page is timestamped 2026-10-06 11:41 UTC. [watchTowr][wt] [Intel][wtintel] |
| First observed exploitation attempts | 2026-10-06 (per SANS: "starting yesterday" in the 2026-10-07 diary) | SANS ISC honeypots saw the watchTowr PoC URLs coming from DigitalOcean IPs. Help Net Security reports that Previdian saw attempts "late Tuesday" (2026-10-06). [SANS][sans] [Help Net][helpnet] |
| VulnCheck KEV listing | 2026-10-07; time/TZ unknown | Reported by Infosecurity Magazine (secondary). The VulnCheck entry itself was not reviewed. [Infosecurity][infosec] |
| CISA KEV addition | 2026-10-15 (date only) | Due 2026-10-18. Forensic triage required under BOD 26-04: Yes. Ransomware use: Unknown. [KEV][kev] |
| CNA record last updated | 2026-10-19 18:26:40 UTC | Record metadata. NVD was last modified 2026-10-26 10:10:00 UTC. [CNA][cve] [NVD][nvd] |

## Detection

### Inventory and fixed versions

Record the product, exact version and every node of each self-managed instance, including Bitbucket mirrors and mirror-farm nodes, Crowd, and any Fisheye or Crucible server. Use each product's administration "System information"/About page or your configuration-management records. A version that is lower than a listed fix but on a **different release line** is not fixed. Atlassian recommends moving to "the fixed LTS version or later". [Advisory][adv]

| Product | Fixed versions (Atlassian) | Introduced in (CNA text) |
|---|---|---|
| Bitbucket Data Center | 9.4.26, 10.2.8, 10.5.1 | >= 4.6.0 |
| Confluence Data Center | 9.2.26, 10.2.19 | >= 5.10.0 |
| Jira Software Data Center | 9.12.40, 10.3.26, 11.3.12 | >= 7.1.0 |
| Jira Service Management Data Center | 5.12.40, 10.3.26, 11.3.12 | >= 3.1.0 |
| Bamboo Data Center | 10.2.24, 12.1.12 | >= 7.0.1 |
| Crowd Data Center | 6.3.7, 7.0.3, 7.1.7, 7.2.4 | >= 2.11.0 |
| Crucible | 4.9.15 | Not stated |
| Fisheye | 4.9.15 | Not stated |

The advisory names Data Center editions, Crucible and Fisheye. It does not separately list the end-of-life **Server** editions and offers no Server fix. If you still run a Server edition of a listed product, its status is **unknown or unpatched**. Restrict access to it and plan a migration rather than assuming it is safe.

### Exposure

Any network path to the web interface is enough, because the flaw needs no login. Atlassian says that public instances, "including those with user authentication", should be cut off from external access until patched or mitigated. Separately, record whether Jira, Confluence, Bitbucket or Bamboo integrate with **Crowd**, and which secrets are stored inside the web application (for example `WEB-INF/classes/crowd.properties`). That determines whether a file read could lead to an identity compromise. [Advisory][adv] [watchTowr][wt]

### Access-log search (read-only)

Atlassian's detection guidance has two options. You can URL-decode each request line (up to two passes) and look for `..` next to `/`, `\` or `::`. Or you can run the vendor regex against the raw log lines. The following command uses the vendor regex without the leading `(?is).*` and trailing `.*` and adds `-i`. It **only reads files**. Run it on the node or on a copy of its logs, as a user that can read the logs. Replace `LOG_GLOB` with your actual access-log paths. Common defaults are `<install>/logs/access_log.*` for Jira, `<install>/logs/conf_access_log.*` for Confluence and `<home>/log/atlassian-bitbucket-access*.log` for Bitbucket; confirm the paths locally. Also check reverse-proxy, load-balancer and WAF logs, which may keep requests that the application normalized or never logged.

```sh
grep -P -i -H '(?:/|\\|::|%(?:25)*(?:2f|5c)|(?::|%(?:25)*3a){2})(?:\.|%(?:25)*2e){2}(?:/|\\|::|%(?:25)*(?:2f|5c)|(?::|%(?:25)*3a){2}|;|%(?:25)*3b|$)' LOG_GLOB
```

The pattern was checked against synthetic log lines only, not against a real Atlassian product. Pay closest attention to matches containing `/download/resources/` or `/s/.../_/download/resources/` with `..::` segments and an HTTP **200** response. For example, SANS observed `..::..::WEB-INF::web.xml` and `WEB-INF::urlrewrite.xml`. Requests for `crowd.properties` or other configuration files matter more than `web.xml` probes. Compare source IPs with the published scanner lists: SANS lists 13 DigitalOcean addresses, and The Hacker News reports three Previdian addresses. These addresses are leads, not complete IOCs. [SANS][sans] [THN][thn]

**Limits:** benign software can also produce traversal-looking strings. Logs may be rotated, sampled or missing query details. The absence of matches does **not** prove that no file was read, especially before the logging you now have was in place or behind a TLS-terminating proxy that you did not check.

## Remediation

1. **Upgrade every node** to a fixed version on its release line, or to a later release, using the product's supported upgrade procedure. Follow the product's clustered or rolling-upgrade guidance for Data Center. Atlassian no longer releases binary patches; fixes ship as maintenance releases. Back up the instance and database first, and check app (plugin) compatibility before upgrading. [Advisory][adv]
2. **Until you can patch,** remove the instance from internet access where possible. Then apply one of Atlassian's mitigations [Advisory][adv]:
   - A WAF or reverse-proxy rule using Atlassian's regex (all products).
   - Tomcat `RewriteValve` with a `rewrite.config` file (Confluence, JSM, Jira, Bamboo, Crowd). This means stopping the node, editing `conf/server.xml`, adding `rewrite.config` under the product's `WEB-INF`, and restarting the node.
   - A `urlrewrite.xml` rule at the top of the file (Bitbucket, including mirrors and mirror-farm nodes).
   Use the exact text from the advisory; do not retype it from this guide. Make backups of each edited file. Mitigations change configuration, need restarts, and **must be repeated on every node**. An upgrade can overwrite files you edited, so manage that change deliberately.
3. If the instance stores credentials in the web root (for example Crowd application credentials in `crowd.properties`) and was ever exposed while vulnerable, **rotate those credentials** after patching. See [Compromise response](#compromise-response).

## Verification

- Confirm each node reports a fixed version after restart. Compare the running cluster version shown in the admin UI with your inventory, including mirrors and Crowd.
- If you used a mitigation instead of an upgrade, Atlassian says to test that your rule blocks `..` next to `/`, `\` or `::` and their encoded forms. Do that **only on your own test or staging instance**, using a harmless path that cannot reveal sensitive content. Do not run the public PoC or the watchTowr detection generator against production or third-party systems. The guidance in this repository was not exercised against a real Atlassian product.
- Check normal functions after the change: login, page and issue loading, static web resources and repository browsing. A broad WAF rule can break legitimate URLs.

## Compromise response

CISA requires BOD 26-04 forensic triage for this entry. If you find matching requests with successful responses, or the instance was exposed while vulnerable and you cannot rule out a read, take these steps:

- Preserve access logs from the application, proxy and WAF, plus the instance's configuration, before you upgrade or rotate anything.
- Find out which web-root files contain secrets. Rotate Crowd application passwords, integration tokens and any credentials stored in the web root. Then review Crowd and product audit logs for new users, `*-administrators` group changes, and API activity from unexpected IPs, following watchTowr's demonstrated chain. [watchTowr][wt]
- Review downstream systems those credentials could reach. Remember that a file read can enable a later login; it does not have to leave a trace on the Atlassian host itself.
- Patching stops new reads but does not undo stolen credentials or accounts that were added.

## Sources

- [Atlassian advisory][adv]: affected products, fixed versions, Atlassian CVSS, mitigations, log-search guidance and Cloud status.
- [CVE record (Atlassian CNA)][cve] and [NVD][nvd]: publication timestamps, per-branch fixes, "introduced in" versions and the NVD 3.1 score.
- [CISA KEV feed][kev]: dateAdded 2026-10-15, due date 2026-10-18, forensic triage requirement.
- [watchTowr Labs analysis][wt] and [watchTowr intelligence page][wtintel]: root cause and the Crowd credential chain.
- [SANS ISC diary][sans]: observed exploitation attempts and source IPs.
- Secondary: [Help Net Security][helpnet], [The Hacker News][thn], [Infosecurity Magazine][infosec].

[adv]: https://confluence.atlassian.com/security/cve-2026-21589-arbitrary-file-access-vulnerability-impacts-multiple-products-1870495748.html
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-21589
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-21589
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[wt]: https://labs.watchtowr.com/you-wont-hear-about-these-even-in-myths-atlassian-jira-confluence-and-more-pre-auth-arbitrary-file-read-cve-2026-21589
[wtintel]: https://watchtowr.com/intelligence/atlassian-jira-confluence-arbitrary-file-read-cve-2026-21589
[sans]: https://isc.sans.edu/diary/Scans+for+Atlassian+vulnerablity+CVE202621589/33406/
[helpnet]: https://www.helpnetsecurity.com/2026/10/07/exploitation-critical-atlassian-flaw-cve-2026-21589
[thn]: https://thehackernews.com/2026/10/atlassian-data-center-flaw-draws.html
[infosec]: https://www.infosecurity-magazine.com/news/critical-vulnerability-atlassian/
