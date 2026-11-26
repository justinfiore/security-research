# Check Point SmartConsole: a login token is an administrator

**Last updated:** 2026-11-26 (America/New_York)

[Main plugin summary](../black-october-2026.md#check-point-smartconsole-a-login-token-is-an-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Check Point Security Management and Multi-Domain Security Management let SmartConsole log in with an application token. Check Point rates [CVE-2026-16232](https://www.cve.org/CVERecord?id=CVE-2026-16232) **Critical, CVSS 4.0 9.3**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. Check Point is the CNA. It publishes no CVSS 3.1 score.

A request with no login obtains that token and uses it to log in with full administrator privileges, then changes the security policy and the security configuration. Remote exploitation needs the Management Server reachable from the internet and Trusted Clients left unrestricted. Check Point said in July that it was exploited against a handful of customers in that configuration, and that Smart-1 Cloud was already protected.

**R82.10 Take 36 and below, R82 Take 118 and below, and R81.20 Take 158 and below** are affected. The CVE record also lists **R81.10, R81, R80.30, R80.20, R80.10, R80, and R77.30**, and [sk185169](https://support.checkpoint.com/results/sk/sk185169) names no take for those. R81.10 and R81 are end of support. The fix is in the Jumbo Hotfix Accumulator starting at **R82.10 Take 36, R82 Take 118, and R81.20 Take 158**. The article was created 2026-07-19 and last modified 2026-09-24.

GreyNoise's [November 23 report](https://www.greynoise.io/blog/check-point-security-management-servers-intrusion-campaign) describes a later campaign it calls GT13. Between October 20 and October 26 it saw a script for this flaw launch more than 100 management tasks, including copying the firewall database and the Internal CA and unloading security policies, and on October 26 a certificate task sent to 24 management servers. GreyNoise says it could not determine when or how those servers were first reached, and that its visibility ended November 2. That report names no new affected version and no new fix. On November 25 Check Point told BleepingComputer it is aware of the activity in that article, that the attackers used CVE-2026-16232, and that they used an adaptation of the public Metasploit module. Check Point says the vulnerability and the protections are not new.

The same July advisory lists two more flaws in the same Jumbo. Check Point rates [CVE-2026-62144](https://www.cve.org/CVERecord?id=CVE-2026-62144) CVSS 4.0 9.3, a management authentication bypass and privilege escalation, and says it was not exploited. [CVE-2026-62145](https://www.cve.org/CVERecord?id=CVE-2026-62145) is CVSS 4.0 7.5, a local privilege escalation in the Gaia WebUI, and is below this collection's admission line. This entry is not [CVE-2026-123039](../black-october-2026.md#check-point-gaia-a-local-socket-runs-a-command-as-root), the November Gaia socket flaw.

**CISA KEV:** Listed — added 2026-07-22, federal due date 2026-07-25. Ransomware use is Unknown and forensic triage is required. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Article created | 2026-07-19; time/TZ unknown | [sk185169][sk]. |
| **Public announcement and fix** | **2026-07-22 13:53:09 UTC** | [CVE-2026-16232][cve] published. CVSS 4.0 9.3. The [advisory][blog] is the same day and names no time. |
| KEV | 2026-07-22; time/TZ unknown | Added, due 2026-07-25. [KEV][kev] |
| Article last modified | 2026-09-24; time/TZ unknown | sk185169. The Jumbo floors are unchanged. |
| **Later exploitation reported** | **2026-11-23; time/TZ unknown** | [GreyNoise][gn]. Activity it dates October 17 through November 2, against 24 management servers. The post prints no time. |
| **Check Point confirms that campaign** | **2026-11-25; time unknown** | Told BleepingComputer the attackers used CVE-2026-16232 and an adaptation of the public Metasploit module. No new fix. [BleepingComputer][bc] |
| **Last updated** | **2026-11-26 (America/New_York)** | Check Point confirmed the October campaign. The Jumbo floors are unchanged. |

## Detection

Read the Jumbo Hotfix Accumulator take on the Security Management or Multi-Domain Security Management server. **R82.10 at Take 36 or below, R82 at Take 118 or below, and R81.20 at Take 158 or below** are inside the range the CVE record names, and so is a server still on R81.10, R81, or an older release through R77.30. A server that restricts Trusted Clients to specific addresses, and is not reachable from the internet, is outside the condition Check Point names for remote exploitation. Reading the take changes no state.

In SmartConsole, under Logs & Monitor, search the audit log for `Authentication method: application token` and for `Authentication method: Password based application token`. Check Point says to treat a password-based application token from an administrator or address you do not recognize as suspicious. Those queries do not show that the Jumbo is installed.

## Remediation

1. Install the Jumbo Hotfix Accumulator at **R82.10 Take 36, R82 Take 118, or R81.20 Take 158** or later, and reboot. R81.10, R81, and the older releases through R77.30 have no named take.
2. Until that take is in, limit Trusted Clients to addresses you trust, and do not leave the type as Any. Also restrict management access to those addresses and confirm the implied rules for control connections are enabled.
3. The Jumbo does not show whether an application token already changed the policy, and it does not remove a certificate or a file that was copied.

## Verification

- The installed Jumbo take is at or above the floor for that version.
- Trusted Clients does not list Any.
- Do not request an application token to test the login.

## Compromise response

GreyNoise says the tasks it saw copied the firewall database and the Internal CA, minted a certificate named `pivot.p12`, and unloaded security policies, and that one server's error output referenced `/usr/lib/.libproc.so` in `/etc/ld.so.preload`. Review audit events for an application-token login you cannot account for, a policy unload, and a certificate you did not create. The Jumbo does not undo any of those. Check Point's July article lists six addresses to search for events before 2026-07-23: 151.241.99.207, 151.241.99.233, 158.62.198.182, 192.142.10.99, 139.28.37.250, and 194.213.18.137. GreyNoise's November report does not say those addresses were used in the later campaign.

## Sources

- [sk185169][sk] — Check Point, created 2026-07-19, last modified 2026-09-24. Fixed from R82.10 Take 36, R82 Take 118, and R81.20 Take 158. No take named for R81.10, R81, or older.
- [July 22 advisory][blog] — Check Point. CVSS 4.0 9.3. Exploited against a handful of customers whose management was exposed without IP restrictions. Smart-1 Cloud already protected.
- [CVE-2026-16232][cve] — Check Point Software Ltd., published 2026-07-22 13:53:09 UTC. CVSS 4.0 9.3. CWE-287.
- [GreyNoise, November 23][gn] — GT13. A script for this flaw used against management servers between October 20 and October 26. Visibility ended November 2. No new version and no new fix.
- [BleepingComputer, November 25][bc] — Check Point says the attackers used CVE-2026-16232 and an adaptation of the public Metasploit module, and that the vulnerability and the protections are not new.
- [CISA KEV JSON][kev] — catalog 2026.11.24, released 2026-11-24T17:47:46.199Z, checked 2026-11-25. Listed 2026-07-22, due 2026-07-25. Ransomware use Unknown.

[sk]: https://support.checkpoint.com/results/sk/sk185169
[blog]: https://blog.checkpoint.com/security/security-advisory-action-required-active-exploitation-of-check-point-smartconsole-authentication-bypass-cve-2026-16232
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-16232
[gn]: https://www.greynoise.io/blog/check-point-security-management-servers-intrusion-campaign
[bc]: https://www.bleepingcomputer.com/news/security/hackers-compromise-check-point-servers-in-22-organizations/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
