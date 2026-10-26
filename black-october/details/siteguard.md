# SiteGuard Server Edition: root command injection via statistics feature

**Last updated:** 2026-10-26 (America/New_York)

[Main SiteGuard summary](../black-october-2026.md#siteguard-server-edition-root-command-injection-via-statistics-feature-cve-2026-106931) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**CVE-2026-106931: JPCERT/CC (CNA) and vendor CVSS 4.0 8.5 High (CVSS:4.0/AV:L/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N) and CVSS 3.0 7.8 High (AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H). The vendor labels it 緊急 (urgent) and JVN labels it "Critical". Listed in CISA KEV on 2026-10-20.** SiteGuard Server Edition is a host-based web application firewall (WAF) from EG Secure Solutions that is built into Apache httpd, Nginx or IIS. It has an OS command injection flaw (CWE-78) in its **statistics feature**, which is **enabled by default**. Exploitation can run arbitrary OS commands as **root or SYSTEM** on the web server. The vendor says exploitation has been confirmed. [Vendor][vendor] [JVN][jvn] [CNA][cve]

**Read the attack vector carefully.** The published vectors are **local, low-privilege** (AV:L/PR:L). The reviewed sources do not explain how attackers in the wild reached the statistics feature, or whether web traffic passing through the WAF can influence it. Do not assume that the server must be reachable over the internet for it to be at risk, and do not assume it must not be. Treat every affected install as exposed.

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery | Unknown | JVN: "The developer reported this vulnerability to IPA." No discovery date is published. [JVN][jvn] |
| CVE ID reserved | 2026-10-07 04:50:26 UTC | CNA metadata. [CNA][cve] |
| Vendor notification and fixes to support-contract customers | 2026-09-29; time/TZ unknown | The vendor says customers with direct support contracts were told on this date about the flaw and the countermeasures (version upgrade and an individual patch). Public availability of the fix on this date is not established. [Vendor][vendor] [JVN][jvn] |
| Public vendor advisory | 2026-10-14; time/TZ unknown | EG Secure Solutions alert-202610-1. It already states that exploitation is confirmed. [Vendor][vendor] |
| JVN publication and JPCERT/CC alert | 2026-10-14; time/TZ unknown | JVN#88474777 and JPCERT-AT-2026-0032. JPCERT/CC notes the product is widely used in Japan. [JVN][jvn] [JPCERT][jpcert] |
| CVE record published | 2026-10-14 04:45:07 UTC | CNA metadata. NVD published 2026-10-14 05:16:42 UTC. [CNA][cve] [NVD][nvd] |
| Exploitation evidence | Start date unknown; first reported publicly 2026-10-14 | Vendor and JVN say exploitation was confirmed, without giving dates, IOCs or attribution. [Vendor][vendor] [JVN][jvn] |
| CISA KEV addition | 2026-10-20 (date only) | Due 2026-10-23. Forensic triage required under BOD 26-04: Yes. Ransomware use: Unknown. [KEV][kev] |

## Detection

### Affected versions

The flaw affects **Ver2.20 and later**, below these fixed versions, when the statistics feature is enabled. [Vendor][vendor] [CNA][cve]

| Edition | Affected | Fixed |
|---|---|---|
| For Apache httpd, Nginx (non-FreeBSD), IIS | Ver2.20 up to, but not including, **Ver8.00 Update 5** | Ver8.00 Update 5 |
| For Apache httpd and Nginx **on FreeBSD** | Ver2.20 up to, but not including, **Ver7.00 Update 6** | Ver7.00 Update 6 |
| For IIS exception | **Ver3.10 through Ver4.00 Update 4 are not affected**; IIS Ver4.00 Update 5 and later are affected again until Ver8.00 Update 5 | — |

### Inventory steps

1. List every web server where SiteGuard Server Edition is installed, including Apache, Nginx and IIS hosts and FreeBSD systems. Record the edition and exact version and update level from the SiteGuard **web administration console**, or from your asset or licensing records. Versions below Ver2.20 are outside the stated affected range. This guide does not clear them; check end-of-life status with the vendor.
2. In the web administration console, record whether the **statistics feature** is enabled. It is enabled by default.
3. Record who has local or low-privilege access to the host and its SiteGuard data paths, because the published vector requires low local privileges.

The vendor publishes **no IOCs, log signatures or file indicators** in the reviewed sources. This guide therefore offers no command-line check and has not been exercised on a real SiteGuard host. Look for anomalies on the host instead: unexpected child processes of the web server or SiteGuard components, new root or SYSTEM accounts, scheduled tasks or cron jobs, webshells in the document root, and outbound connections. Finding no anomalies does not prove the host is clean.

## Remediation

1. **Preserve evidence first.** The vendor warns that updating or patching **may erase attack traces**. Before you change anything, download the diagnostic information from the web administration console (診断情報 → 診断情報をダウンロード) and store it off the host. [Vendor][vendor] [JPCERT][jpcert]
2. **Update** to Ver8.00 Update 5 (Apache, Nginx, IIS) or Ver7.00 Update 6 (FreeBSD Apache or Nginx) using the vendor's provided media and procedure. [Vendor][vendor]
3. **If you cannot upgrade,** apply the vendor patch that replaces the files used by statistics processing. The patch is also offered for end-of-life versions. Get it through your support desk or reseller. [Vendor][vendor] [JVN][jvn]
4. **Workaround:** JPCERT/CC says that **disabling the statistics feature** avoids the vulnerability. See the vendor's documentation for the procedure. You lose statistics reporting while the feature is off. [JPCERT][jpcert]
5. Updating the WAF module may require restarting the web server. Schedule it, and keep a rollback plan that does not reinstall a vulnerable build.

## Verification

- Confirm that the version shown in the web administration console is at least the fixed version for your edition, on every host.
- If you rely on the workaround, confirm the statistics feature is still disabled after restarts and configuration pushes.
- Run a normal traffic check (a benign page loads, and an expected WAF block still triggers on a test host) to confirm protection still works. Do not attempt command injection against production.

## Compromise response

Because the impact is root or SYSTEM command execution and exploitation is confirmed, treat a host as possibly compromised if it ran an affected version with statistics enabled. CISA requires forensic triage for this entry.

- Keep the diagnostic-information archive, web server and system logs, and a disk or memory image where practical.
- Look for persistence (accounts, keys, services, cron jobs or scheduled tasks, webshells), changes to the WAF configuration that weaken protection, and lateral movement from the web server.
- Rotate secrets stored on or reachable from the host, such as TLS private keys, application credentials and database passwords.
- If you find persistence, rebuild from known-good media instead of cleaning in place. Updating SiteGuard does not remove an attacker who already ran commands.
- Contact the vendor support desk or JPCERT/CC (ew-info@jpcert.or.jp) with findings; JPCERT/CC asks for information.

## Sources

- [EG Secure Solutions advisory (Japanese)][vendor]: affected and fixed versions, patch, evidence preservation, September 29 customer notice, confirmed exploitation.
- [JVN#88474777 (English)][jvn]: CVSS, affected and fixed versions, IPA reporting.
- [JPCERT-AT-2026-0032 (Japanese)][jpcert]: workaround (disable statistics) and update caution.
- [CVE record (JPCERT/CC CNA)][cve] and [NVD][nvd]: per-edition version ranges and timestamps.
- [CISA KEV feed][kev]: dateAdded 2026-10-20, due date 2026-10-23.

[vendor]: https://www.eg-secure.co.jp/siteguard/news/alert-202610-1
[jvn]: https://jvn.jp/en/jp/JVN88474777/
[jpcert]: https://www.jpcert.or.jp/at/2026/at260032.html
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-106931
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-106931
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
