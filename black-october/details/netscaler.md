# NetScaler: SAML memory overflow denial of service

**Last updated:** 2026-10-26 (America/New_York)

[Main NetScaler summary](../black-october-2026.md#netscaler-saml-memory-overflow-denial-of-service-cve-2026-88779) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-88779](https://www.cve.org/CVERecord?id=CVE-2026-88779) — NetScaler (CNA) CVSS 4.0: 8.7 High; NVD CVSS 3.1: 7.5 High; Citrix bulletin severity: High; in CISA KEV.** A memory-buffer bounds error (CWE-119) lets an unauthenticated network attacker crash NetScaler ADC or NetScaler Gateway authentication processing. This causes a **denial of service**, and Citrix rates no confidentiality or integrity impact. It applies only when the appliance is configured as a **SAML Service Provider** (`add authentication samlAction`) or a **SAML Identity Provider** (`add authentication samlIdPProfile`). The flaw is not RCE on its own. However, CISA and Rapid7 describe attackers using it to **force a crash/reboot** that executes code previously injected through **[CVE-2026-88771](https://www.cve.org/CVERecord?id=CVE-2026-88771)**, so treat it as part of a compromise chain on unpatched appliances.

**CISA KEV:** Listed — added 2026-10-04, federal due date 2026-10-07. The companion code-injection flaw [CVE-2026-88771](https://www.cve.org/CVERecord?id=CVE-2026-88771) was listed earlier (added 2026-09-27, due 2026-09-30). [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and precondition](#inventory-and-precondition)
  - [Crash and chain indicators](#crash-and-chain-indicators)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | CNA `source.discovery`: UNKNOWN. Citrix credits JPMorgan Chase, Bishop Fox and watchTowr. CVE reserved 2026-09-10 07:14:57 UTC, which is a reservation date, not a report date. [Bulletin][ctx] [CVE JSON][cve] |
| Citrix security bulletin CTX697174 and fixed builds | 2026-10-03 (Citrix changelog labels the date "PST") | Initial publication, with fixed builds listed for every supported branch. The KB page metadata shows "Created 10-04-2026 02:03" without a timezone. [Bulletin][ctx] |
| CNA public date | 2026-10-04 02:19 UTC | `datePublic`, which is 2026-10-03 evening Pacific time. [CVE JSON][cve] |
| CVE record published | 2026-10-04 02:35:35 UTC | CNA metadata. NVD's published timestamp is 2026-10-04 04:16:43 (NVD API, UTC). [CVE JSON][cve] [NVD][nvd] |
| CISA KEV addition | 2026-10-04 (date only) | Due 2026-10-07; forensic triage under BOD 26-04: **No**; ransomware use: Unknown. The KEV date is not when exploitation began. [KEV JSON][kev] |
| Exploitation start | Unknown | KEV and the CISA ADP SSVC entry ("Exploitation: active", 2026-10-04) establish exploitation but not its start date. [KEV JSON][kev] [CVE JSON][cve] |
| CISA alert update linking CVE-2026-88771 | 2026-10-09; time/TZ unknown | CISA says attackers "may" use CVE-2026-88779 to force a reboot that accelerates execution of code injected via CVE-2026-88771. [CISA alert][cisa] |
| Bulletin page last modified | 2026-10-12 06:19 (timezone not shown) | The bulletin changelog lists no entries after 2026-10-03. [Bulletin][ctx] |
| Rapid7 intrusion analysis | 2026-10-19 (updated 2026-10-22); time/TZ unknown | Describes an early-October compromise of an affected 14.1 appliance that chained CVE-2026-88771 and CVE-2026-88779 to gain root, deploy web shells, and exfiltrate configuration. [Rapid7][rapid7] |

## Detection

### Inventory and precondition

1. List every customer-managed NetScaler ADC/Gateway, including VPX, MPX, SDX instances, FIPS/NDcPP builds, **both nodes of HA pairs**, and NetScaler instances used by Secure Private Access hybrid deployments. Citrix-managed cloud services are updated by Cloud Software Group.
2. Record the running build with the read-only NetScaler CLI command `show ns version`, or use NetScaler Console inventory. Compare it with Citrix's fixed builds:

   | Branch | Affected | Fixed |
   |---|---|---|
   | ADC and Gateway 14.1 | before 14.1-73.41 | 14.1-73.41 and later |
   | ADC and Gateway 13.1 | before 13.1-64.28 | 13.1-64.28 and later 13.1 releases |
   | ADC 14.1-FIPS | before 14.1-73.41 FIPS | 14.1-73.41 FIPS and later |
   | ADC 13.1-FIPS and 13.1-NDcPP | before 13.1-37.282 | 13.1-37.282 and later |

   The bulletin covers only supported versions. Treat end-of-life branches as **unknown, not cleared**, and plan to migrate them.
3. Check whether the SAML precondition is met. From the NetScaler shell, as a nsroot/admin user, run this read-only search of the saved configuration:

   ```sh
   grep -E '^add authentication (samlAction|samlIdPProfile)' /nsconfig/ns.conf
   ```

   Saved configuration can differ from running configuration. You can also review the running configuration with the read-only CLI command `show ns runningConfig`. No match means the precondition is absent, but only for this appliance and only for its current configuration. These commands were not exercised on a real appliance for this guide.

### Crash and chain indicators

- Look for unexpected authentication-process crashes, core dumps, and appliance reboots, especially `nsaaad` crashes followed by Pitboss-initiated reboots, which Rapid7 observed. Correlate them with authentication requests whose username fields contain shell syntax such as `${IFS}`, `;` or `fetch`/`curl` commands. That pattern is the CVE-2026-88771 log-poisoning half of the chain.
- Rapid7's chain IoCs include `/nsconfig/.slap/`, `/nsconfig/.relay/`, `/flash/.nsvm/`, `/var/tmp/.s2loot/`, `/var/tmp/.ux/`, and web shells under `/var/netscaler/logon/LogonPoint/custom/` (`.slap.receiver`, `.ctxs.receiver`, `receiver.deb`). They also include a setuid `/bin/sh` and Apache aliases mapping `receiver.v2.min*.css`. Use `ls -la`/`stat`, which are read-only, and compare against Rapid7's hashes and IP addresses. [Rapid7][rapid7]
- Run Citrix's NetScaler Console indicator-of-compromise script and review CISA's SIGMA rules. watchTowr (secondary) relays a Citrix note that the latest script can report a false positive about suspicious `nobody` processes. [CISA alert][cisa] [watchTowr FAQ][wt]
- Forward logs to a SIEM. CISA notes that local NetScaler logs rotate quickly. Missing crashes or IoCs do not prove the appliance is clean.

## Remediation

1. Upgrade every affected appliance, including both HA nodes, to the fixed build for its branch listed above. This requires a reboot and planned downtime. Appliances already patched for the earlier CTX697096 bulletin (CVE-2026-88771 through [CVE-2026-88778](https://www.cve.org/CVERecord?id=CVE-2026-88778)) **still need this separate update** if they use SAML, and the reverse also applies. [Bulletin][ctx] [watchTowr FAQ][wt]
2. **If compromise is suspected, preserve evidence before updating**, because CISA warns that updates may reduce forensic visibility.
3. Interim mitigation: watchTowr (secondary) reports that Citrix offers Global Deny List signatures for specific intermediate builds with Virtual patching enabled in NetScaler Console. The Citrix blog describing this returned HTTP 403 during this review, so confirm the details with Citrix before relying on them. Removing SAML SP/IdP configuration also removes the precondition, but it breaks SSO.

## Verification

- Confirm with `show ns version` that each node in production, including HA secondaries after failover, runs the fixed build or later.
- Test a normal SAML SP or IdP login after the upgrade. Do not send malformed SAML traffic to production appliances to "test" the fix.
- Re-run the IoC script and the file checks after patching. Patching does not remove implants.

## Compromise response

Follow CISA's guidance: preserve forensic evidence, restore a **known-good backup that predates the compromise** or rebuild, and rotate all restored secrets, including local account passwords, key-encryption keys, and SSL certificates/private keys. Rapid7 also advises inspecting both HA nodes, rotating LDAP/RADIUS bind credentials and other secrets exposed through `/nsconfig`, and hunting internally for scanning from NetScaler addresses and for the listed C2 infrastructure. Treat internet-facing appliances that were vulnerable during the campaign window as potentially compromised. [CISA alert][cisa] [Rapid7][rapid7]

## Sources

- [Citrix bulletin CTX697174][ctx] — affected and fixed builds, SAML precondition, CVSS 4.0, credits, changelog.
- [NetScaler CNA record][cve] and [NVD][nvd] — scoring attribution (8.7 v4.0 CNA; 7.5 v3.1 NVD) and publication times.
- [CISA KEV JSON feed][kev] and [CISA NetScaler alert (updated 2026-10-09)][cisa] — KEV entry and the CVE-2026-88771 relationship.
- [Rapid7 intrusion analysis][rapid7] — observed chaining and IoCs.
- [watchTowr FAQ (secondary)][wt] — interim mitigation and IoC-script note. [Citrix blog][ctxblog] was not accessible (HTTP 403).

[ctx]: https://support.citrix.com/support-home/kbsearch/article?articleNumber=CTX697174
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-88779
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-88779
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[cisa]: https://www.cisa.gov/news-events/alerts/2026/09/27/critical-zero-day-vulnerabilities-exploited-citrix-netscaler-adc-gateway
[rapid7]: https://www.rapid7.com/blog/post/ra-netscaler-intrusions-chaining-cve-2026-88771-and-cve-2026-88779/
[wt]: https://watchtowr.com/intelligence/citrix-netscaler-cve-2026-88779-faq
[ctxblog]: https://community.citrix.com/techzone-blogs/110_security-updates/understanding-and-addressing-cve-2026-88779-in-citrix-netscaler-adc-and-citrix-netscaler-gateway/
