# Zammad: session hijack RCE and root escalation chain

**Last updated:** 2026-10-26 (America/New_York)

[Main Zammad summary](../black-october-2026.md#zammad-session-hijack-rce-and-root-escalation-chain-cve-2026-102489-and-cve-2026-102490) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Two CVEs, both in CISA KEV, with different scope and fixes:**

- **CVE-2026-102489, session fixation/hijack → RCE as the `zammad` user.** DIVD (CNA) CVSS 4.0: **8.7 High** on its own ("GENERAL" scenario) and **9.4 Critical** when chained with CVE-2026-102490. NVD CVSS 3.1: **9.8 Critical**. NVD displays only DIVD's chained 9.4 score. The flaw is exploitable on **Zammad 6.3.0 through 6.5.4**. The bug is present in 7.0.0–7.1.x but, according to DIVD and Zammad, cannot be exploited there.
- **CVE-2026-102490, improper privilege management → local root.** This affects **DEB/RPM packages built with packager.io only**. DIVD CVSS 4.0: **8.5 High** on its own and **9.4 Critical** when chained. Zammad's GitHub advisory: CVSS 4.0 **8.5 High**. NVD CVSS 3.1: **7.8 High**. An attacker who can already run code or write files as the `zammad` service account can become root, because packaged services started as root and executed `zammad`-writable files. Source installs and official container images are not affected. Fixed in **7.2.2**.

Chained, the two CVEs give remote unauthenticated root on the host. DIVD reports that its own network was breached this way.

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| CVE-2026-102489 first reported to Zammad | 2026-08 (exact day not established) | Zammad says it "first received a report about this issue in August 2026" and analysed it then. [Zammad statement][statement] [Zammad advisory][advisory] |
| Exploitation against DIVD | 2026-09-21; time/TZ unknown | DIVD: "Vulnerability abused to breach DIVD." BleepingComputer (secondary) reports that both CVEs were chained, followed by data access and exfiltration. [DIVD case][divd-case] [BleepingComputer][bc] |
| DIVD analysis and reproduction | 2026-09-22 to 2026-09-23; time/TZ unknown | [DIVD case][divd-case] |
| Zammad 7.2.0 released | 2026-09-23 (release page); tag commit 2026-09-23 05:04:19 UTC | Zammad says 7.2.0 includes hardening of the CVE-2026-102489 code. It does **not** fix CVE-2026-102490. [Releases][releases] [Git tag][tag720] [Zammad advisory][advisory] |
| Reported to Zammad by DIVD | 2026-09-24; time/TZ unknown | Zammad says it had not received technical details for CVE-2026-102490 until after it became public. [DIVD case][divd-case] [Zammad statement][statement] |
| Public announcement (DIVD limited disclosure) | 2026-09-26; time/TZ unknown | DIVD "created a limited disclosure", began internet scanning, and notified owners. Zammad describes this date as public disclosure. [DIVD case][divd-case] [Zammad statement][statement] |
| CNA public date | 2026-09-29 20:00 UTC | `datePublic` in both DIVD CVE records. [CVE-2026-102489 JSON][cve89] [CVE-2026-102490 JSON][cve90] |
| CVE records published | 2026-09-30 16:21:19 UTC (102489); 16:21:20 UTC (102490) | CNA metadata. [CVE-2026-102489 JSON][cve89] [CVE-2026-102490 JSON][cve90] |
| Zammad public statement | 2026-10-01 12:16:59 UTC | Community post: CVE-2026-102489 does not affect 7.0+, and no details had yet been received for CVE-2026-102490. At 19:48:04 UTC the same day, Zammad said it had received the details. [Zammad statement][statement] |
| CISA KEV addition (both CVEs) | 2026-10-02 (date only) | Due 2026-10-05; forensic triage required under BOD 26-04: **Yes**. The KEV date is not when exploitation began. [KEV JSON][kev] |
| Zammad security advisory page | 2026-10-05 (page date) | Says a fix for CVE-2026-102490 is still in progress. This was superseded by 7.2.2. [Zammad advisory][advisory] |
| **CVE-2026-102490 fixed: Zammad 7.2.2** | 2026-10-08; tag commit 10:01:57 UTC; GHSA published 10:19:43 UTC | DEB/RPM fix. GHSA-p97w-927q-8vxq lists `<= 7.2.1` as vulnerable and 7.2.2 as patched. [7.2.2 release][r722] [Git tag][tag722] [GHSA][ghsa] |
| **CVE-2026-102489 emergency fix: Zammad 6.5.5** | 2026-10-15; time/TZ unknown | Fix for the unsupported 6.5 series, which hardens the WebSocket server. Available only from a **new package repository**. Zammad still recommends 7.2.2. [6.5.5 release][r655] |

## Detection

### Which CVE applies to which install

| Install | CVE-2026-102489 (remote) | CVE-2026-102490 (local root) |
|---|---|---|
| 6.3.0–6.5.4, any install method | **Exploitable** (6.5.5 is the emergency fix) | Affected if installed from DEB/RPM |
| 7.0.0–7.1.x | Bug present but not exploitable (DIVD/Zammad) | Affected if installed from DEB/RPM |
| 7.2.0–7.2.1 | Hardened | Affected if installed from DEB/RPM |
| 7.2.2+ | Not affected | Fixed |
| Earlier than 6.3.0 | **Unknown** in the CNA record | Affected from 1.5.0 if installed from DEB/RPM; earlier than 1.5.0 is unknown |
| Source install or official container image | Depends on version, as above | Not affected (CNA, GHSA) |
| Zammad SaaS | No action required (Zammad) | No action required (Zammad) |

**Range disagreements to keep in mind:**

- For CVE-2026-102489, the CNA's machine-readable range is `6.3.0` to `<6.5.4`, while its text and the DIVD case say "6.3.0 to 6.5.4". Zammad shipped a 6.5 fix only in 6.5.5, so **treat 6.5.4 as affected**.
- The "not exploitable" 7.x upper bound is given as 7.1.2 in the CNA text but as 7.1.3 on the DIVD case page and in the CNA's `unknown` range.
- The DIVD case page still lists the LPE as "v1.5.0 to v7.1.0-alpha". The later CNA record, the DIVD CVE page, and the GHSA say every packaged version earlier than 7.2.2 is affected.

### Read-only inventory

Run on the Zammad host as a user that can read the package database. These commands change nothing. They were not exercised against a real Zammad deployment for this guide.

```sh
# Debian/Ubuntu package install
dpkg-query -W -f='${Package} ${Version}\n' zammad 2>/dev/null
# RHEL/SUSE package install
rpm -q zammad 2>/dev/null
# Container installs: list running Zammad images and tags
docker ps --format '{{.Image}}' 2>/dev/null | grep -i zammad
```

No output means **unknown** for that install method, not "unaffected". Check source installs from the deployed tree's version files, and check every host, including staging.

### Log indicators (CVE-2026-102489)

DIVD publishes a [log-check script][ioc] that searches Zammad and nginx logs (`/var/log/zammad`, `/var/log/nginx`, including `.gz`) for **session material leaked into error output**: lines matching `ERROR -- :` followed by `"Cookie"=>"` or `@clients={`. An equivalent read-only search, run as root or the log owner, is:

```sh
zgrep -En 'ERROR -- :.*("Cookie"=>"|@clients=\{)' /var/log/zammad/*.log* 2>/dev/null | cut -c1-240
```

Matches can include live session cookies. Handle the output as sensitive and do not paste it into tickets. DIVD itself notes that a clean result does not rule out compromise. Also look for unfamiliar processes, files, and sessions.

### Host indicators (CVE-2026-102490)

On packaged installs, look for files in the Zammad installation directory that the `zammad` account modified unexpectedly, unexpected root processes or cron/systemd changes after service restarts, and new SSH keys or accounts. The vendor has published no specific IoC list for the LPE.

## Remediation

1. **Self-hosted, all install methods:** upgrade to **Zammad 7.2.2 or later** using the [package/Docker update documentation][update]. Back up the database and attachments first. Package upgrades restart services. 7.2.2 fixes the LPE, and the CVE-2026-102489 hardening has been in place since 7.2.0.
2. **If you cannot leave 6.5 immediately:** install **6.5.5** to close CVE-2026-102489. It requires switching to Zammad's new package repository ([migration instructions][repo]). Zammad does not state that 6.5.5 fixes CVE-2026-102490, so packaged 6.5.x installs should still be treated as exposed to the local root escalation. Plan the move to 7.2.2.
3. **Temporary risk reduction:** take internet-exposed 6.3–6.5 instances offline or restrict them to trusted networks, as DIVD advises. Restrict shell and file access on the host to trusted administrators.
4. **Container and source installs:** CVE-2026-102490 does not apply to them, but they still need a version that is not exploitable for CVE-2026-102489.

## Verification

- Re-run the read-only inventory and confirm **7.2.2+** (or **6.5.5** as a stopgap for CVE-2026-102489 only) on every node and image actually running, not just the one pulled or downloaded.
- Confirm that the package came from the official Zammad repository, and that 6.5.5 came from the new repository.
- Run a normal agent login, ticket view, and live-update (WebSocket) check. Do not replay hijacked sessions or attempt local privilege escalation to "prove" the fix.

## Compromise response

- If CVE-2026-102489 indicators or other signs appear, assume code execution as `zammad` on 6.3–6.5. On packaged installs, also **assume root on the host**, because the two CVEs were chained in the wild. Preserve logs and a disk image before changes.
- Rebuild compromised hosts from a clean OS image and reinstall the fixed Zammad version. Do not trust in-place cleanup after root compromise.
- Invalidate all Zammad sessions, rotate agent and admin passwords, API tokens, and integration secrets (mail/IMAP/SMTP, LDAP, third-party channels), and database credentials. Review ticket and attachment data for exfiltration and notify affected parties as required.
- Hunt for lateral movement from the Zammad host. DIVD describes rapid follow-on access to other services after the chain.

## Sources

- [DIVD case DIVD-2026-00015][divd-case], [CVE-2026-102489 page][divd89], [CVE-2026-102490 page][divd90], and [IoC script][ioc] — timeline, scenarios, ranges, and detection.
- [CNA record CVE-2026-102489][cve89] and [CNA record CVE-2026-102490][cve90] — DIVD CVSS 4.0 scenarios, ranges, publication times.
- NVD [CVE-2026-102489][nvd89] and [CVE-2026-102490][nvd90] — NVD CVSS 3.1 scores (9.8 / 7.8).
- [Zammad community statement][statement], [Zammad security advisory][advisory], [GHSA-p97w-927q-8vxq][ghsa], [7.2.2 release][r722], [6.5.5 release][r655], [release list][releases].
- [CISA KEV JSON feed][kev] — dateAdded, dueDate, requiredAction.
- [BleepingComputer (secondary)][bc] — DIVD breach reporting.

[divd-case]: https://csirt.divd.nl/DIVD-2026-00015
[divd89]: https://csirt.divd.nl/CVE-2026-102489
[divd90]: https://csirt.divd.nl/CVE-2026-102490
[ioc]: https://csirt.divd.nl/downloads/DIVD-2026-00015/cve-2026-102489_ioc_check_script_v2.sh
[cve89]: https://cveawg.mitre.org/api/cve/CVE-2026-102489
[cve90]: https://cveawg.mitre.org/api/cve/CVE-2026-102490
[nvd89]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-102489
[nvd90]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-102490
[statement]: https://community.zammad.org/t/take-care-local-privilege-escalation-cve-2026-102490-is-reported-as-being-actively-exploited/21297/2
[advisory]: https://zammad.com/en/advisories/cve-2026-102489-cve-2026-102490
[ghsa]: https://github.com/zammad/zammad/security/advisories/GHSA-p97w-927q-8vxq
[r722]: https://zammad.com/en/product/releases/7-2-2
[r655]: https://zammad.com/en/product/releases/6-5-5
[releases]: https://zammad.com/en/product/releases/
[tag720]: https://github.com/zammad/zammad/tree/7.2.0
[tag722]: https://github.com/zammad/zammad/tree/7.2.2
[update]: https://docs.zammad.org/en/latest/install-update.html
[repo]: https://docs.zammad.org/en/latest/install/host-upgrade-repo-migration.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[bc]: https://www.bleepingcomputer.com/news/security/divd-says-zammad-zero-days-enabled-ai-driven-network-breach/
