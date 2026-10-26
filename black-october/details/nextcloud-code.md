# Nextcloud built-in CODE server: detect exposure and remove the command-injection path

**Last updated:** 2026-10-26 (America/New_York)

[Main guide](../black-october-2026.md#6-nextclouds-built-in-collabora-code-server-unauthenticated-command-injection) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-110447](https://www.cve.org/CVERecord?id=CVE-2026-110447):** `richdocumentscode` before **26.4.303** permits unauthenticated OS command injection through `proxy.php` **while the bundled CODE server is stopped**. Commands run as the web-server user. Disabling the app is insufficient; update it or remove it. [Vendor advisory][advisory]

## Table of contents

- [Timeline](#timeline)
  - [CISA KEV status](#cisa-kev-status)
- [Detection](#detection)
  - [Identify the app, not merely “Collabora”](#identify-the-app-not-merely-collabora)
  - [Investigate suspicious requests and file changes](#investigate-suspicious-requests-and-file-changes)
- [Remediation](#remediation)
  - [Temporary mitigation before restarting anything](#temporary-mitigation-before-restarting-anything)
  - [Patch or migrate](#patch-or-migrate)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date | Evidence and qualification |
|---|---|---|
| Discovery | September 2026; exact day unknown | October 15 vendor post says discovered and patched a month earlier. [Vendor post][vendor] |
| Initial private report | Unknown | The reviewed vendor sources do not publish the initial report date. |
| Fix committed | 2026-09-09 | Reported by BleepingComputer; a source commit is not an installed app release. [Reporting][reporting] |
| Administrator-reported attacks from | 2026-09-10 | Reports cited by BleepingComputer, not an independently established universal first-exploitation date. [Reporting][reporting] |
| Fix available: richdocumentscode 26.4.303 | 2026-09-11 | Exact release date in BleepingComputer; version confirmed by vendor advisory. [Reporting][reporting] [Advisory][advisory] |
| Public community warning | 2026-10-03 | Earlier warning reported by BleepingComputer; not the formal CVE advisory. [Reporting][reporting] |
| Public advisory / CVE disclosure | 2026-10-14 | Vendor GitHub advisory publication. [Advisory][advisory] |
| Vendor scope clarification | 2026-10-15 | Optional built-in app only, with deployment exclusions. [Vendor post][vendor] |
| CISA KEV addition | 2026-10-23 (date only; time/TZ not published) | Catalog version 2026.10.23; due date **2026-10-26**. KEV addition is not the exploitation start date. [KEV JSON][kev] [CVE record][cve] |

The exact September fix dates above are attributed to reporting, not inferred from the advisory’s October publication. No separate backport branch is documented in the advisory.

### CISA KEV status

CISA added CVE-2026-110447 to the Known Exploited Vulnerabilities catalog with `dateAdded` **2026-10-23** and `dueDate` **2026-10-26**, as “Collabora Online – Built-in CODE Server OS Command Injection Vulnerability” (CWE-78). Its `requiredAction` is to apply mitigations per vendor instructions under CISA’s BOD 26-04 and its “Forensics Triage Requirements,” follow applicable BOD 26-04 cloud-service guidance, or discontinue use of the product if mitigations are unavailable. The entry marks `forensicTriage` **Yes** and `knownRansomwareCampaignUse` **Unknown**. The CVE record’s CISA ADP enrichment now records SSVC exploitation **active**. [KEV JSON][kev] [CVE record][cve]

The due date applies to organizations bound by CISA’s directive; for others it is a prioritization signal. KEV listing confirms known exploitation; it does not add a new fixed version—the vendor remedy remains **26.4.303 or later, or removal**—and it does not date when attacks began.

## Detection

### Identify the app, not merely “Collabora”

1. Inventory Nextcloud instances and their configured app directories, including disabled apps, shared app volumes and old release directories still served by PHP.
2. Look specifically for **Collabora Online – Built-in CODE Server** (`richdocumentscode`). The `richdocuments` Office integration app alone is not the vulnerable bundled server.
3. On a trusted installation, from the `black-october` directory, review and invoke the existing [stack inventory script](../stack-inventory.sh), adjusting the web account and `occ` path:

```sh
sudo -u www-data sh "$(pwd)/stack-inventory.sh" nextcloud /var/www/nextcloud/occ
```

This runs `php occ app:list` using that account’s PHP on PATH. Check **both enabled and disabled lists**. In containers, use the equivalent invocation inside the actual Nextcloud deployment, with the script available there.

- A successful command is inventory only. Do not run `occ` or the suspect PHP runtime during incident forensics; inspect a snapshot using clean tools instead.
- Inspect configured application roots for leftover `richdocumentscode/proxy.php` files not reflected in `app:list`. Verify which roots the reverse proxy/web server actually exposes.
- Check app metadata against deployment provenance; a version field alone cannot prove file integrity.
- Standalone Collabora servers are excluded. The vendor also excludes its standalone Docker/RPM/DEB and normal Nextcloud All-in-One deployments; **putting an affected Nextcloud app in an arbitrary container does not exempt it**. [Vendor post][vendor]
- Do not stop CODE to “test” vulnerability. Restarts, crashes and upgrades can create the exploitable condition later even if CODE is running now. [Advisory][advisory]

### Investigate suspicious requests and file changes

These are recommended operator checks, not claims that every request or changed file proves exploitation:

- Preserve reverse-proxy, web-server and Nextcloud logs; correlate requests to the built-in app’s `proxy.php` with CODE crashes/restarts and unexpected PHP process activity.
- Compare application and web-root files with trusted release artifacts; investigate new PHP files and unexplained modifications in directories writable by the web user.
- Review outbound downloads, command interpreters spawned by web workers, new scheduled tasks, modified users/app passwords and access to configuration or external-storage credentials.
- Administrator reports describe webshells and searches for password databases, wallet files and password-manager artifacts. Ransomware claims were **not independently confirmed** by BleepingComputer. [Reporting][reporting]
- Lack of a Nextcloud login event is not exculpatory: the vulnerable path is unauthenticated. Missing access logs or current absence of a webshell cannot establish no earlier compromise.

## Remediation

### Temporary mitigation before restarting anything

- Block untrusted access to affected app paths at every web ingress, including direct origin and alternate hostnames, or isolate the instance while removing/updating the app. Treat path blocking as a temporary, operator-proposed control that requires verification.
- Do not rely on app disablement, Nextcloud maintenance mode, login requirements, or keeping CODE running. The vendor’s accepted remedies are **upgrade or removal**. [Advisory][advisory]
- If office editing is nonessential, remove the built-in app using supported administration tooling and verify its executable files are no longer served. Preserve suspect files first for investigation.

### Patch or migrate

1. On a trusted installation, use Nextcloud’s Apps administration/update mechanism to install **26.4.303 or later**, and verify completion rather than assuming an update notification means installation succeeded.
2. The app store currently offers **26.4.502** for Nextcloud 30–35; its Nextcloud 25–29 listings still show **26.4.104**, below the fix threshold. “Latest compatible” is therefore not always safe. [App store][store]
3. For EOL **Nextcloud 29 or earlier**, follow the vendor instruction to upgrade Nextcloud or remove this app; do not force-install an incompatible package to evade compatibility checks. [Advisory][advisory]
4. Container/image deployments must update any baked-in app and persistent app volume; ensure a stale image or rollback does not repopulate the vulnerable copy.
5. Restart/redeploy the relevant web workers according to the deployment procedure so old PHP code caches are not retained, keeping exposure blocked until verification is complete.
6. Patch the Nextcloud PHP runtime separately as described in the main guide. The advisory says the fix for **[CVE-2025-66208](https://www.cve.org/CVERecord?id=CVE-2025-66208)** does not prevent this different path. [Advisory][advisory]

## Verification

- Rerun app inventory on a trusted updated instance; confirm all active and inactive copies meet the threshold or have been removed.
- Verify the filesystem and image/volume versions on each web replica; do not inspect only the primary administrative node.
- For removal, use a benign request and web configuration review to confirm the old proxy cannot execute through any public route; a branded error page alone may hide backend execution.
- For an update, test ordinary document opening/editing with a non-sensitive test file, then check logs and service health. Do not send injection payloads or deliberately stop an unpatched CODE server.
- Record the fixed app version, Nextcloud compatibility, worker restart and route verification separately from the historical compromise result.

## Compromise response

- Isolate a suspected instance and preserve database, app/configuration directories and data-volume snapshots; collect off-host logs before retention expires.
- Rebuild from trusted Nextcloud and app artifacts. Removing a webshell or upgrading `richdocumentscode` does not remove other files planted with web-user permissions.
- Restore reviewed user data selectively and compare configuration with a pre-incident baseline. Do not restore an entire suspect web root or app volume.
- From clean systems, revoke affected sessions/app passwords and rotate accessible database, object-store, external-storage and integration credentials after containment. Assess which secrets the web-server user could read.
- Review account changes, shared links and file-access history; involve data owners if private documents may have been read. A patch does not reverse disclosure or unauthorized file changes.

## Sources

- [Collabora advisory][advisory] — affected/fixed versions, stopped-server prerequisite, disablement warning and EOL guidance.
- [Collabora October 15 clarification][vendor] — standalone/AIO exclusions and discovery-month context.
- [October 15 exploitation reporting][reporting] — September dates, administrator observations and unconfirmed ransomware claim.
- [Nextcloud app-store release matrix][store] — current compatible versions, freshly read on the update date.
- [CISA KEV JSON feed][kev] (catalog 2026.10.23) and [CVE record][cve] — KEV dates, required action and CISA ADP exploitation status.

[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-110447
[advisory]: https://github.com/CollaboraOnline/online/security/advisories/GHSA-g3vx-3m76-fghh
[vendor]: https://www.collaboraonline.com/blog/stay-safe-upgrade-everything-regularly/
[reporting]: https://www.bleepingcomputer.com/news/security/hackers-exploit-collabora-rce-flaw-to-backdoor-nextcloud-servers/
[store]: https://apps.nextcloud.com/apps/richdocumentscode
