# Ivanti Connect Secure: authentication bypass to command execution

**Last updated:** 2026-10-26 (America/New_York)

[Main Ivanti Connect Secure summary](../black-october-2026.md#ivanti-connect-secure-authentication-bypass-to-command-execution-cve-2026-104935) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-104935](https://www.cve.org/CVERecord?id=CVE-2026-104935) — Ivanti (CNA) CVSS 3.1: 8.6 High (`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:L/A:L`); Ivanti's advisory labels the same vector "CVSS:3.0"; NVD has no score of its own; in CISA KEV and exploited as a zero-day.** An authentication bypass by spoofing (CWE-290) in the Ivanti Connect Secure (ICS) VPN lets a remote unauthenticated attacker execute arbitrary commands. Volexity found the CVE covers two flaws:

- an authentication bypass: a request to the public `/dana-na/auth/url_default/welcome.cgi` carrying an `X-DSCGI-PATH` header is routed to a protected CGI;
- a race-condition file write and execution in `wu.cgi`.

In the wild, attackers chained it with a separate **root privilege escalation**, the `dsinvoked`/DSCache flaw. MITRE later assigned that flaw **[CVE-2026-111357](https://www.cve.org/CVERecord?id=CVE-2026-111357)** (MITRE CNA CVSS 3.1: 7.0 High). It is **not fixed** by the CVE-2026-104935 updates, and its fix status was not established in the reviewed sources.

**CISA KEV:** Listed — added 2026-10-13, federal due date 2026-10-16. The chained root escalation [CVE-2026-111357](https://www.cve.org/CVERecord?id=CVE-2026-111357) is not listed (catalog 2026.10.23). [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory](#inventory)
  - [Request and host indicators](#request-and-host-indicators)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Partial internal discovery and fix in 25.1.3.0 | 2026-07 (exact day not established) | Ivanti says it found "a portion" of the vulnerability internally and patched it in the July release 25.1.3.0. It was backporting the fix when exploitation occurred. [Advisory][ivanti] |
| Exploitation start (earliest known) | 2026-10-03; time/TZ unknown | Volexity: UTA0576 repeatedly exploited the chain from October 3 against a fully patched 22.8R2.4 appliance. [Volexity][volexity] |
| Volexity investigation begins | 2026-10-05; time/TZ unknown | Network Security Monitoring customer. [Volexity][volexity] |
| Fixed release 25.1.1.2 | 2026-10-05 (released, per Ivanti); time/TZ unknown | For 25.1.1.x on ISA6000/ISA8000 physical and ISA4000/6000/8000 virtual. [Advisory][ivanti] |
| Indicators shared privately | 2026-10-10 | Volexity says indicators were available to its customers from this date (TIB-20261012). [Volexity][volexity] |
| Fixed release 22.8R2.5 | 2026-10-12 (released, per Ivanti); time/TZ unknown | Bridge release for customers who cannot move to 25.1 immediately. [Advisory][ivanti] |
| Ivanti public advisory | 2026-10-13; page shows "Created Oct 13, 2026 1:59:25 PM" with no timezone | Discloses the CVE and limited in-the-wild exploitation. Last modified 8:29:44 PM the same day (Volexity blog link added to the FAQ). Volexity says the patches were released October 13, which differs from Ivanti's own release dates for 25.1.1.2 and 22.8R2.5. [Advisory][ivanti] [Volexity][volexity] |
| CVE record published | 2026-10-13 15:31:07 UTC | CNA metadata (reserved 2026-10-02 17:07:30 UTC). NVD's published timestamp is 2026-10-13 16:17:11 (NVD API, UTC). [CVE JSON][cve] [NVD][nvd] |
| CISA KEV addition and CISA alert | 2026-10-13 (date only) | Due 2026-10-16; forensic triage under BOD 26-04: **Yes**; ransomware use: Unknown. CISA reports credential theft and data exfiltration. [KEV JSON][kev] [CISA alert][cisa] |
| CVE-2026-111357 (chained privilege escalation) published | 2026-10-15 20:56:58 UTC | MITRE CNA lists 22.8R2.4 as affected and the status of other versions as unknown. Not in KEV as of the 2026-10-23 feed release. [CVE-2026-111357 JSON][cve-pe] |

## Detection

### Inventory

1. List every ICS appliance and VM (physical ISA, virtual, and cloud), including clustered nodes. Record each node's running version (not just staged packages) from the admin console or your asset inventory. Viewing the version is read-only. No ICS appliance was available to exercise this check for this guide.
2. Compare with Ivanti's table:

   | Code line | Affected | Resolved |
   |---|---|---|
   | 25.1.1.x (ISA6000/ISA8000 physical; ISA4000/6000/8000 virtual) | 25.1.1.1 and prior | **25.1.1.2** |
   | 25.1.2.x / 25.1.3.x (ISA4500/6500/8500 platform) | 25.1.2.2 and prior | **25.1.3.0, 25.1.3.1** |
   | 22.8 | 22.8R2.4 and prior | **22.8R2.5** |
   | 22.7 | Not affected (22.7R2.14 and prior) | — |

   **Correction to a common shorthand:** the CNA description says "before version 25.1.3.0", but that is not the only fix. **25.1.1.2** and **22.8R2.5** also resolve the issue. The 25.1.3.0 line requires the new ISA4500/6500/8500 platform or the 25.1.3.0 template. NVD's configuration encodes the same split (25.1.0.0 up to but not including 25.1.1.2; 25.1.2.0 up to but not including 25.1.3.0; 22.8R2–R2.4).
3. Note that **22.7 and 22.8 reach end of life on 2027-01-31**, according to Ivanti.

### Request and host indicators

- Search reverse-proxy, load-balancer, or ICS web logs for unusual volumes of requests to `/dana-na/auth/url_default/welcome.cgi`, especially requests carrying an `X-DSCGI-PATH` header such as `/home/webserver/htdocs/dana/fb/smb/wu.cgi` or `/home/runtime/tmp/<md5>`. Volexity advises alerting on mismatches between the URL path and `X-DSCGI-PATH`, because attackers may switch to other paths. Default ICS logs may not record headers, so header visibility usually depends on upstream logging.
- Volexity's host artifacts include `/tmp/pu.txt`, `/tmp/rq5.py` and `/tmp/rr.py` (deleted after use), and a hidden `/data/.icscap/` directory with packet captures. They also include a `dsstatmond` process sniffing LDAP/HTTP/FTP/telnet ports, and the infrastructure IP `108.165.147[.]64`. Full indicators are on [Volexity's GitHub][volexity-iocs].
- Watch for downstream activity from the appliance: LDAP queries for LAPS or BitLocker attributes, Kerberoasting, password spraying, and use of the ICS LDAP service account.
- **The Integrity Checker Tool (ICT) may not detect this.** The chain patches libraries in memory, restores DSCache, and selectively deletes entries from `/home/runtime/dlogs/debuglog` and `/var/log/audit/audit.log`. CISA states that confirming compromise needs network and memory forensics. A clean ICT result or missing log entries do not prove the appliance is clean. [CISA alert][cisa] [Volexity][volexity]

## Remediation

1. Update to a resolved version for your code line: **25.1.1.2**, **25.1.3.0/25.1.3.1** (new platform), or **22.8R2.5**. Ivanti recommends that 22.8 customers move to 25.1. Download from the Ivanti License System. Expect a reboot and follow the [25.x Upgrade and Migration Compatibility Guide][migrate].
2. The chained privilege escalation (CVE-2026-111357) has no fix confirmed in the reviewed sources. Track Ivanti's advisories, because patching CVE-2026-104935 removes the remote entry point Volexity observed but not that local flaw.
3. Ivanti and CISA list no workaround for CVE-2026-104935. If you cannot update, restrict exposure of the appliance's web interface where operationally possible and prioritize forensic review. KEV's required action includes discontinuing the product if mitigations are unavailable.

## Verification

- Confirm the running version on every node after the upgrade, and confirm that clustered nodes match.
- Run the external ICT, keeping in mind its blind spot for this chain, and check that normal VPN logins and SSO work.
- Do not send spoofed `X-DSCGI-PATH` requests to production appliances to "test" the fix.

## Compromise response

If compromise is suspected, follow Ivanti's [recovery steps][recovery] as summarized by CISA:

1. Back up the configuration.
2. Factory-reset and upgrade, or rebuild virtual and cloud instances on the latest version.
3. Restore the configuration.
4. **Reset passwords for all accounts** (domain, administrator, local).
5. Revoke and reissue stored certificates.
6. Reset stored API keys and license-server credentials.

Because the attackers extracted LDAP bind credentials and hunted for LAPS passwords and BitLocker keys, rotate the ICS service-account credentials and any exposed LAPS or BitLocker secrets. Also investigate the Active Directory environment, not only the appliance. Capture memory and network evidence before rebooting if possible, because the exploit chain is largely in-memory. [CISA alert][cisa] [Volexity][volexity]

## Sources

- [Ivanti security advisory][ivanti] — affected and resolved versions, release dates, FAQ on July partial fix and exploitation.
- [Ivanti CNA record][cve] and [NVD][nvd] — CVSS 3.1 8.6 attribution, publication times, configuration ranges.
- [CISA KEV JSON feed][kev] and [CISA alert][cisa] — KEV entry, ICT limitation, recovery steps.
- [Volexity analysis][volexity] and [Volexity IoCs][volexity-iocs] — exploitation timeline, chain mechanics, detection guidance.
- [CVE-2026-111357 record][cve-pe] — chained privilege escalation.
- [Rapid7 ETR (secondary)][rapid7] — resolved-version summary.

[ivanti]: https://hub.ivanti.com/s/article/Security-Advisory-Ivanti-Connect-Secure-CVE-2026-104935?language=en_US
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-104935
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-104935
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[cisa]: https://www.cisa.gov/news-events/alerts/2026/10/13/cisa-urges-patching-newly-exploited-vulnerability-ivanti-connect-secure
[volexity]: https://www.volexity.com/blog/2026/10/13/a-series-of-unauthenticated-events-chained-exploitation-of-ivanti-connect-secure-zero-days/
[volexity-iocs]: https://github.com/volexity/threat-intel/tree/main/2026/2026-10-13%20Ivanti
[cve-pe]: https://cveawg.mitre.org/api/cve/CVE-2026-111357
[migrate]: https://hub.ivanti.com/s/article/Ivanti-Connect-Secure-25-x-Upgrade-and-Migration-Compatibility-Guide
[recovery]: https://forums.ivanti.com/s/article/Ivanti-Connect-Secure-22-8x-and-25x-Recovery-Steps
[rapid7]: https://www.rapid7.com/blog/post/etr-ivanti-connect-secure-zero-day-exploited-in-the-wild-cve-2026-104935
