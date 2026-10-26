# BeyondTrust BT26-05: patch appliances and investigate brokered access

**Last updated:** 2026-10-26 (America/New_York)

[Main guide](../black-october-2026.md#10-beyondtrust-remote-support-an-already-exploited-appliance-vulnerability) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-102764](https://www.cve.org/CVERecord?id=CVE-2026-102764):** improper origin validation in Remote Support internal messaging permits unauthenticated file operations. **Remote Support ≤26.2.3** is affected; **BT26-05-RS** covers versions **24.3.1–26.2.3**. Observed root compromise and lateral movement are attack-chain outcomes, not merely the initial file-operation primitive. [Advisory][advisory] [Mandiant][mandiant]

## Table of contents

- [Timeline](#timeline)
  - [CISA KEV status and severity attribution](#cisa-kev-status-and-severity-attribution)
- [Detection](#detection)
  - [Inventory appliance state and historical exposure](#inventory-appliance-state-and-historical-exposure)
  - [Hunt off-box evidence first](#hunt-off-box-evidence-first)
- [Remediation](#remediation)
  - [Patch-first for unconfirmed incidents; preserve and isolate suspected compromise](#patch-first-for-unconfirmed-incidents-preserve-and-isolate-suspected-compromise)
  - [Temporary containment and operational safety](#temporary-containment-and-operational-safety)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date | Evidence and qualification |
|---|---|---|
| Earliest exploitation confirmed by vendor | 2026-08-29 | One SaaS RS instance and one self-hosted appliance; not proof that no earlier/other attack occurred. [Vendor response][response] |
| Initial discovery / private alert | 2026-09-27 to 2026-09-28 | Mandiant sent a non-specific note September 27; vendor hunt detected the SaaS incident and reproduced the entry vector September 28. [Vendor response][response] |
| Detailed private findings shared | 2026-09-30 | Mandiant shared self-hosted findings; vendor had also validated a test fix by this date. [Vendor response][response] |
| Fix available: self-hosted RS / precautionary PRA | 2026-10-08 | BT26-05 patches released; PRA shares code but vendor had not demonstrated exploitation there. [Vendor response][response] |
| SaaS rollout / completion statement | 2026-10-08 / by 2026-10-09 | Blog dates RS/PRA rollout October 8; formal advisory says all RS SaaS patched as of October 9. Preserve this distinction. [Response][response] [Advisory][advisory] |
| Public advisory, CVE and Mandiant analysis | 2026-10-15 | Coordinated disclosure; **not** the patch-release date. [Response][response] [Mandiant][mandiant] |
| Vendor response update | 2026-10-16, 12:00 p.m. EDT | Vendor then knew of two impacted customers and no adversary activity since August; this is a dated observation, not fleet-wide clearance. [Response][response] |
| CISA KEV addition | 2026-10-16 (date only; time/TZ not published) | Due date **2026-10-19**. KEV addition is not the exploitation start date (vendor-confirmed exploitation dates to 2026-08-29). [KEV JSON][kev] [CVE record][cve] |

The attacker’s initial vulnerability discovery date is unknown. PRA’s patch is precautionary; do not relabel it as confirmed vulnerable solely because it shares code.

### CISA KEV status and severity attribution

CISA lists CVE-2026-102764 in the Known Exploited Vulnerabilities catalog as “BeyondTrust Remote Support Authentication Bypass by Spoofing Vulnerability” (CWE-290), with `dateAdded` **2026-10-16** and `dueDate` **2026-10-19**. Its `requiredAction` is to apply mitigations per vendor instructions under CISA’s BOD 26-04 and its “Forensics Triage Requirements,” follow applicable BOD 26-04 cloud-service guidance, or discontinue use of the product if mitigations are unavailable. The entry marks `forensicTriage` **Yes** and `knownRansomwareCampaignUse` **Unknown**. The KEV entry covers **Remote Support** only; it does not change PRA’s precautionary status. [KEV JSON][kev] [CVE record][cve]

Severity differs by issuer: BeyondTrust (CNA) rates it **Critical, CVSS 4.0 9.3**; NVD’s 2026-10-16 analysis adds **Critical, CVSS 3.1 9.8** (`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`). [Advisory][advisory] [NVD][nvd]

## Detection

### Inventory appliance state and historical exposure

1. In each appliance’s administrative interface, record **product, base version, installed security patches and update history**. Confirm **BT26-05-RS** explicitly; a hotfix may not change the base-version string.
2. Include standby/failover appliances, disaster-recovery images and otherwise forgotten public addresses. Review when each was exposed before its actual patch date.
3. For SaaS, obtain tenant-specific vendor confirmation and preserve incident communications. Vendor-managed patching does not answer whether credentials or sessions were exposed before patching. [Mandiant][mandiant]
4. For PRA, confirm installation of the product-specific precautionary BT26-05 patch through vendor tooling; do not attempt to install an RS patch on PRA. [Vendor response][response]
5. The companion Linux/stack scripts are **not appliance compromise checks**. Do not run arbitrary shells or diagnostic scripts on the appliance; use supported exports and vendor-assisted preservation.

### Hunt off-box evidence first

Mandiant recommends treating internet-reachable, vulnerable appliances from the exploitation window as potentially compromised until reviewed. Retain logs from **at least August 29 through the real containment/patch date**, extending earlier where deployment history or evidence warrants. [Mandiant][mandiant]

- Collect SIEM/syslog, reverse-proxy/WAF and perimeter logs plus `/login` session, team activity and user audit reports. On-appliance logs were deleted in the observed campaign. [Response][response]
- Correlate unrecognized administrator logins with support tickets, MFA records and normal locations; residential/VPN origins are investigation context, not definitive attribution.
- Hunt `user_changed` events raising Jump Item or Team roles, unapproved new users/API accounts/security providers, and changes to syslog/outbound-event destinations. Review support sessions and file transfers following those changes. [Mandiant][mandiant]
- Compare web requests against known product routes; investigate unknown PHP paths, unusual WebSocket upgrades and log-forwarding gaps bounded by a session.
- Mandiant observed SAWFLY `mangoapi.php`, BARECLAW `ingredi_ws`, a root-owned SUID `dbus-authd`, `post_boot.d/zz-root-persist`, and altered sudoers/HAProxy configuration. Have vendor/forensic responders inspect preserved artifacts with the published hashes/YARA, not by executing them. [Mandiant][mandiant]
- Names, paths and infrastructure can change between victims. A normal external port scan can miss a proxy-routed local backdoor; a 404 response can conceal a webshell. Negative IOC searches do not establish clean state. [Mandiant][mandiant]

## Remediation

### Patch-first for unconfirmed incidents; preserve and isolate suspected compromise

1. For self-hosted RS **24.3.1–26.2.3**, apply **BT26-05-RS** through `/appliance`, or confirm automatic installation actually completed. If unavailable, open a BeyondTrust support case citing BT26-05. [Advisory][advisory]
2. Below **24.3.1**, follow the supported upgrade path to a patchable release, then apply the hotfix. Do not reconnect an upgraded but still-unpatched intermediate version. [Mandiant][mandiant]
3. The public customer-portal notice says vulnerable versions were withdrawn and **25.1.7** retained as an upgrade stepping stone. That is **not a safe final version without the patch**; consult support for the supported path. [Portal notice][portal]
4. For newer base releases, obtain explicit vendor confirmation of inclusion rather than assuming this historical patch-package range defines every later release’s state.
5. Apply the separate precautionary PRA patch immediately where relevant. SaaS operators need no local appliance installation, but should complete credential/configuration review according to exposure. [Response][response] [Mandiant][mandiant]

### Temporary containment and operational safety

- Restrict `/login` and `/appliance` administration to trusted networks; limit other exposure to required support traffic. Administrative allowlisting alone is **not** a fix for the internal messaging flaw.
- For suspected compromise, preserve snapshots/disk and available memory before reboot or configuration changes where feasible. Request preservation through support for B Series hardware or SaaS.
- Isolate at the perimeter so appliance configuration remains available for review. Restrict egress to approved update/licensing and necessary organizational endpoints, and retain denied-connection logs. [Mandiant][mandiant]
- Coordinate interruption with help-desk owners; terminate active support sessions and disable new sessions, Jump Clients/Jumpoints and API access as directed by incident responders. Disable rather than delete evidence-bearing objects.
- MFA and network restrictions reduce further abuse but do not remove persistence already installed on an appliance. [Mandiant][mandiant]

## Verification

- Record installed BT26-05 patch evidence for every active and failover appliance, or vendor confirmation that a later supported build includes the fix.
- Confirm the upgraded appliance restarted/redeployed as required and no recovery/failover path reintroduces an unpatched image. Verify the base version alone is not being used as the closure criterion.
- Test a normal authorized representative session, required Jump connectivity and approved integrations after containment decisions; do not use an exploit probe to prove the patch.
- Generate a benign administrative/audit event and confirm timely receipt in the off-box SIEM; alert on forwarding gaps and retain alerts closed by automated triage for hunting. [Response][response]
- Compare users, roles, Jump Items, group/session policies, security providers, API accounts and outbound destinations with an approved pre-exposure baseline.
- Close separate records for **patch applied**, **exposure removed**, **compromise investigation**, and **credential/session remediation**. A vendor-managed SaaS patch closes only the first item.

## Compromise response

- Open a **Sev 1 support request citing “BT26-05”** for evidence of exploitation; obtain the vendor’s threat-hunting package through its trust portal. [Response][response]
- Mandiant recommends **rebuilding confirmed or unknown-compromise appliances** from a clean, fully patched image. Host persistence can survive reboot and configuration reset; deleting known webshells is insufficient. [Mandiant][mandiant]
- Restore a configuration predating the exposure window, or review a newer backup while fully isolated before reconnecting. Issue a new TLS certificate and redeploy Jump Clients, Jumpoints and representative consoles from the rebuilt appliance. [Mandiant][mandiant]
- Revoke sessions and old enrollments. Rotate brokered/stored credentials at their target systems **after** patching/rebuilding and containment, so new credentials are not immediately recaptured.
- Include appliance and `/login` administrators, API secrets, directory bind credentials, SAML signing keys, Vault/integrated vault credentials, SMTP/ITSM/outbound-event integrations, and credentials typed into sessions during the window. Track dependencies without exporting secret values. [Mandiant][mandiant]
- Hunt every downstream endpoint accessed in suspicious support sessions, including file transfers and privilege changes; review new MFA registrations and use of accounts outside managed support sessions.

## Sources

- [BT26-05 advisory][advisory] — affected range, hotfix eligibility and SaaS completion date.
- [Vendor response, updated October 16][response] — exact incident/patch dates, PRA qualification and support escalation.
- [Mandiant investigation and remediation][mandiant] — observed artifacts, phased response, rebuild and rotation guidance.
- [Customer portal notice][portal] — public upgrade notice read successfully; the full KB0024066 article requires customer login and was **not accessible** in this review.
- [CISA KEV JSON feed][kev], [CVE record][cve] and [NVD record][nvd] — KEV dates/required action, CISA ADP exploitation status and NVD’s CVSS 3.1 score.

[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-102764
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-102764
[advisory]: https://www.beyondtrust.com/trust-center/security-advisories/bt26-05
[response]: https://www.beyondtrust.com/blog/entry/bt26-05
[mandiant]: https://cloud.google.com/blog/topics/threat-intelligence/armory-castle-exploits-beyondtrust
[portal]: https://beyondtrustcorp.service-now.com/csm?id=csm_kb_article&sysparm_article=KB0024066
