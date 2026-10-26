# Cisco Secure Email Gateway: AMP attachment path traversal

**Last updated:** 2026-10-26 (America/New_York)

[Main Cisco Secure Email Gateway summary](../black-october-2026.md#cisco-secure-email-gateway-amp-attachment-path-traversal-cve-2026-76519) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-76519](https://www.cve.org/CVERecord?id=CVE-2026-76519) — Cisco CVSS 3.1: 9.8 Critical (`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`); Cisco SIR: Critical; CWE-23 (relative path traversal). Bug ID CSCwu56223.** The flaw is in how the **Advanced Malware Protection (AMP) File Reputation** feature handles email attachments. An **unauthenticated, remote** attacker who **sends an email with a crafted attachment** through an affected gateway can write arbitrary files and **execute commands as root** on the underlying OS. No login, and no click by a recipient, is required. Cisco has confirmed active exploitation. NVD shows only Cisco's score; no separate NVD score was found. **Worst case:** root on the mail gateway, which gives access to mail flow and quarantines, credentials, and cluster SSH keys that can be used to compromise other cluster members.

**CISA KEV:** Listed — added 2026-10-14, federal due date 2026-10-17. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Which configurations are affected](#which-configurations-are-affected)
  - [Read-only CLI checks](#read-only-cli-checks)
  - [Off-box evidence](#off-box-evidence)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery | Unknown | Cisco says the flaw "was found during internal security scanning." The CVE ID was reserved on 2026-08-19 12:02:03 UTC; that is when the ID was reserved, not when the flaw was found. [Cisco advisory][cisco] [CVE JSON][cve] |
| Fixed AsyncOS releases first listed | 2026-09-14 16:00 GMT | The **September 2026 hardening release** advisory lists the same first-fixed Secure Email Gateway releases (15.5.5-014, 16.5.0-780) and a CWE-23 grouping CVE ([CVE-2026-76440](https://www.cve.org/CVERecord?id=CVE-2026-76440)). It did not name CVE-2026-76519 until revision 1.1 on 2026-10-14. When each build was actually available to download was not established. [Hardening advisory][hardening] |
| Content Scanner Tools 25.3.0.5525 | Date unknown | This updated package carries the fix to all supported releases. Its release date is not stated. [Cisco advisory][cisco] |
| Cisco learns of exploitation | 2026-10 (exact day not established) | "In October 2026, the Cisco PSIRT became aware of active exploitation." [Cisco advisory][cisco] |
| Cisco public advisory | 2026-10-14 16:00 GMT | `cisco-sa-esa-afw-zqYJkjxp`, version 1.0 Final. On the same day, hardening advisory v1.1 added a link to it. [Cisco advisory][cisco] [Hardening advisory][hardening] |
| CVE record published | 2026-10-14 16:07:51 UTC | Cisco CNA record. [CVE JSON][cve] |
| CISA KEV addition | 2026-10-14 (date only) | `dueDate` 2026-10-17, ransomware use "Unknown", forensic triage "Yes". [KEV JSON][kev] |

## Detection

### Which configurations are affected

Cisco Secure Email Gateway (ESA), **physical and virtual**, is affected when it runs a vulnerable AsyncOS release and **both** of these conditions are true:

1. **File Reputation** (part of AMP) is enabled and assigned to a mail policy. Check this in the web UI under **Mail Policies → Incoming Mail Policies → Advanced Malware Protection** (and also under **Outgoing Mail Policies**), looking for **Enable File Reputation** on each policy.
2. **Content Scanner Tools** is older than **25.3.0.5525**.

**Not affected, per Cisco:** **Secure Email and Web Manager (SEWM/SMA)** and **Secure Web Appliance**. SEWM *is* affected by other CVEs in the separate [September 2026 hardening release][hardening] (fixed in SEWM 15.5.5-006 and 16.5.0-429), so patch it on its own schedule. **Secure Email Cloud Gateway:** Cisco has deployed a fixed Content Scanner Tools and says customers need take no action. Cisco has directly contacted Cloud customers where it found malicious activity.

### Read-only CLI checks

Run these from an administrator CLI session (SSH) on **each** appliance, including every cluster member. They display state only and change nothing. They were not run against a real appliance for this review.

```text
version
contentscannerstatus
grep "System Security" system_logs
```

- `version` shows the AsyncOS release. `contentscannerstatus` shows the Content Scanner Tools version; anything below `25.3.0.5525` is vulnerable when File Reputation is enabled.
- The `grep` command is Cisco's own IOC check. The result means:
  - "Suspected compromise indicator was found": treat the appliance as compromised.
  - "Security scan did not complete": contact Cisco TAC.
  - "No compromise indicator was found": no indicator detected; still patch.

### Off-box evidence

After root-level exploitation, an attacker can erase on-device evidence, so a clean `grep` result is **not** proof of safety. Cisco recommends checking network and firewall logs **outside** the appliance for unexpected uploads from the gateway to external IPs or downloads from malicious IPs. Also look for unusual outbound SSH or HTTPS from the appliance and unexpected administrative logins. Correlate any of this with inbound messages that carried unusual attachments. Cisco published no network IOCs in this advisory.

## Remediation

1. **Fastest fix on every supported release:** update **Content Scanner Tools to 25.3.0.5525 or later**. No AsyncOS upgrade or restart is needed. With automatic updates enabled, no action is needed once the update applies. Otherwise run `contentscannerupdate` at the CLI, or enable automatic updates under **Security Services → Service Updates → Edit Update Settings**, then commit.
2. **AsyncOS fixed releases:** 15.5 → **15.5.5-014**; 16.0 → *migrate to a fixed release*; 16.5 → **16.5.0-780**. Cisco strongly recommends that releases earlier than 16.5 migrate to **16.5.0-780**. The upgrade reboots the appliance, so plan it across cluster members.
3. Cisco states **there are no workarounds**. Disabling File Reputation would remove one of the required conditions, but Cisco does not list that as a mitigation, and it removes malware protection. Do not use it as a substitute for updating.
4. Apply Cisco's hardening guidance: keep the appliance off direct internet management access, separate the mail and management interfaces, filter management traffic, disable HTTP/FTP and other unused services, and send logs to an external server.
5. **If the appliance may be compromised, do not upgrade first.** Cisco warns that upgrading a compromised instance destroys forensic data and logs. Follow **Compromise response**.

## Verification

- Re-run `contentscannerstatus` and confirm the version is 25.3.0.5525 or later; after an upgrade, run `version` and confirm the AsyncOS build is a fixed release. Repeat on every cluster member.
- Confirm the File Reputation and AMP service status is healthy, and that a known-benign test message with a harmless attachment is delivered and scanned normally. Do **not** send crafted traversal attachments.
- Re-run `grep "System Security" system_logs` after the update and keep the output with your change record.

## Compromise response

Follow Cisco's recommendations:
- **Physical appliances:** contact Cisco TAC, with remote access enabled for the investigation.
- **Virtual appliances:**
  1. Record forensic data first.
  2. Deploy a **new VM on a fixed release**.
  3. Rebuild the configuration **without importing old configuration files**.
  4. Renew all credentials and cryptographic material on the appliance.
  5. Monitor the new appliance for anomalies.
- **Clusters:** exploitation can expose the private SSH keys used between cluster members, so restore **every member of any cluster that contains a compromised appliance**.

Beyond the appliance:
- Rotate LDAP/SAML/SMTP-auth credentials, TLS keys and certificates, and API and integration credentials configured on the gateway.
- Review quarantined and relayed mail for tampering or disclosure.
- Investigate onward access from the gateway into your mail servers and directory.

CISA marks this KEV entry as requiring forensic triage under BOD 26-04 for covered agencies. [Cisco advisory][cisco] [KEV JSON][kev]

## Sources

- [Cisco advisory cisco-sa-esa-afw-zqYJkjxp][cisco]: affected conditions, fixed releases, Content Scanner Tools fix, IOCs, recovery, products not affected.
- [Cisco September 2026 hardening advisory][hardening]: first publication of the same fixed builds; SEWM fixed releases for its separate CVEs.
- [Cisco CNA record][cve]: affected versions list, timestamps, CISA ADP SSVC.
- [NVD][nvd]: shows only Cisco's score.
- [CISA KEV JSON feed][kev]: dates and required action.

[cisco]: https://sec.cloudapps.cisco.com/security/center/content/CiscoSecurityAdvisory/cisco-sa-esa-afw-zqYJkjxp
[hardening]: https://sec.cloudapps.cisco.com/security/center/content/CiscoSecurityAdvisory/cisco-sa-hardening-esa-dfCrfXkm
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-76519
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-76519
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
