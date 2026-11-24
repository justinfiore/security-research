# Optimizely: a flaw in Experimentation served malware to customer sites

**Last updated:** 2026-11-24 (America/New_York)

[Main Optimizely summary](../black-october-2026.md#optimizely-a-flaw-in-experimentation-served-malware-to-customer-sites) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Optimizely Web Experimentation is a script that customer sites load from Optimizely's CDN. On November 16 an attacker used a flaw in that product to add JavaScript to some customer projects, and the sites then served it to visitors.

**MITRE rates [CVE-2026-132224](https://www.cve.org/CVERecord?id=CVE-2026-132224) CVSS 4.0 7.1 High.** The vector is `CVSS:4.0/AV:N/AC:H/AT:N/PR:L/UI:N/VC:N/VI:H/VA:N/SC:H/SI:H/SA:N`. The record, published 2026-11-18, says Web Experimentation before 2026-11-17 mishandles the account signup flow, and that attacker-controlled code ends up in the Project JavaScript of some `cdn.optimizely.com` assets. Optimizely's status page says an unauthorized party exploited a vulnerability in Experimentation, that Optimizely has fixed it, and that it removed the injected code. Scott Helme of Report URI counted 188 infected scripts across 178 organizations, including Zoom, the BBC, CNN, Salesforce, and GitLab. The script replaced cryptocurrency wallet addresses, captured card numbers, and on iPhones and iPads loaded the Coruna and DarkSword exploit kits. Helme says one of the 188 scripts was still malicious at 21:52 UTC on November 16, and that the earliest hijacked script he found was that morning. The Hacker News says Smartsheet's snippet was reinfected after the cleanup, so removing the code once did not keep the attacker out.

**CISA KEV:** Listed — [CVE-2026-132224](https://www.cve.org/CVERecord?id=CVE-2026-132224) added 2026-11-24, federal due date 2026-11-27. Ransomware use Unknown. Forensic triage is required. Catalog 2026.11.24, released 2026-11-24T17:47:46.199Z. CISA's required action is the vendor's mitigation for a cloud service, or to stop using the product if that mitigation is not available. The listing date is not when the scripts were served. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Malicious scripts served | 2026-11-16, from early morning; time/TZ unknown | Helme's earliest hijacked script. [Report URI][helme] |
| One script still malicious | 2026-11-16 21:52 UTC | Helme, of 188 scripts. |
| **Optimizely statement** | **2026-11-17 01:02 UTC** | Status page: vulnerability fixed, code removed, accounts secured. [Status][status] |
| Optimizely update | 2026-11-18 14:49 UTC | The flaw was in the Web Experimentation account signup flow. Optimizely says it was detected and closed within three hours, that fewer than 5% of customers were affected, and that it contacted every Web Experimentation customer. [Status][status] |
| CVE record | 2026-11-18 | MITRE published CVE-2026-132224. CVSS 4.0 7.1 High. Affected before 2026-11-17. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-132224) |
| **CISA KEV** | **2026-11-24; catalog released 17:47:46 UTC** | Added. Federal due date 2026-11-27. Ransomware use Unknown. Forensic triage required. [KEV][kev] |
| **Last updated** | **2026-11-24 (America/New_York)** | The CVE and the KEV listing. The customer action is unchanged. |

## Detection

1. A site that loads a script from `cdn.optimizely.com` uses the product. The snippet name is a number, such as `cdn.optimizely.com/js/6395285578973184.js`.
2. Helme's copies of the malicious script loaded `https://1688360[.]cc/track.js`, some of them after a Base64 decode, and one variant carried the payload inline. A saved copy of the page from November 16 that contains `1688360` or `track.js` loaded the kit.
3. Optimizely has not published a list of affected projects. Not seeing the string does not clear a site, because the code was removed during the day.

## Remediation

1. There is no customer-side patch. Optimizely says it fixed the vulnerability and removed the code. A site owner cannot apply that fix.
2. If Optimizely contacted you, follow that notice. It says it secured affected accounts and added protections against unauthorized code being delivered.
3. A visitor who entered a card number or copied a wallet address on an affected site on November 16 should check the statement and the transaction. The site owner cannot see that from the server logs alone.

## Verification

- The live snippet no longer contains `1688360` or `track.js`. That check says nothing about what the same URL served on November 16.
- Do not request the malicious host to confirm the payload.

## Compromise response

Helme reports verified cryptocurrency transactions to the attacker's wallets on November 16: 0.08298 BTC to `19g9rZcPeiz8rUvyWpTRyXXhPnjsWrc3kW`, 17.02 LTC to `ltc1q3wp7g6ds0ggg6fl6kncpa4sepn0q3qfacgred5`, and 662.9 USDT plus 184 TRX to `THvs6p56XkUiMkJeSc51cAP64u2RsTYqxa`. BleepingComputer also lists 0.074 ETH to `0xC4026b06D82b0F0B363eda0642D61CfbDc17884e`.

A site that served the script should treat card data entered that day as exposed and follow its own breach process. Removing the script does not undo a transaction or a card number that already left. The Hacker News report of a reinfection means one cleanup pass is not the end of the check.

## Sources

- [Optimizely status, Web Experimentation Security Incident][status] — posted 2026-11-17 01:02 UTC. Vulnerability fixed, injected code removed, accounts secured. Affects Web Experimentation snippet delivery.
- [Report URI, Scott Helme][helme] — November 16. 188 scripts, 178 organizations. Payload behavior and the wallet addresses.
- [BleepingComputer][bc] — Lawrence Abrams, November 16, 09:12 PM. Confirms the script on Zoom, CNN, BBC, Salesforce, GitLab, and others, and lists the wallet totals.
- [The Hacker News](https://thehackernews.com/2026/11/hijacked-optimizely-scripts-served-card.html) — November 17. Smartsheet's snippet reinfected after cleanup.
- [CVE-2026-132224](https://www.cve.org/CVERecord?id=CVE-2026-132224) — MITRE, published 2026-11-18. CVSS 4.0 7.1 High. Web Experimentation before 2026-11-17. The record links Optimizely's incident report and the status page.
- [CISA KEV JSON][kev] — catalog 2026.11.24, released 2026-11-24T17:47:46.199Z, checked 2026-11-24. CVE-2026-132224 added 2026-11-24, due 2026-11-27. Ransomware use Unknown. Forensic triage Yes.

[status]: https://status.optimizely.com/incidents/ftw0fh9wx43z
[helme]: https://blog.report-uri.com/worlds-largest-brands-infected-with-malware-via-optimizely/
[bc]: https://www.bleepingcomputer.com/news/security/optimizely-supply-chain-attack-infects-major-brands-sites-with-malware/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
