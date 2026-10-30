# Oracle Fusion Middleware, E-Business Suite, Database and MySQL: October 2026 Critical Patch Update

**Last updated:** 2026-10-30 (America/New_York)

[Main Oracle October CPU summary](../black-october-2026.md#oracle-fusion-middleware-e-business-suite-database-and-mysql-october-2026-critical-patch-update) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Oracle's October 2026 Critical Patch Update (CPU), released 2026-10-20, contains **1,295 new security patches** across Oracle's product families. Its risk matrices list **1,209 unique CVEs**. **112 matrix rows (95 unique CVEs) score CVSS 9.0 or higher**, and six CVEs score **10.0**. This guide does not repeat every row. It covers only the most severe flaws that are **remotely exploitable without authentication** in widely deployed products: Fusion Middleware (Access Manager, SOA Suite, WebLogic Server), E-Business Suite (EBS), JD Edwards EnterpriseOne, Oracle Database, MySQL and PeopleSoft PeopleTools. To check other products, read the [full risk matrices][cpu] or their [text form][verbose]. [Oracle CPU][cpu]

**Severity (Oracle CVSS 3.1, from the risk matrices; all are remotely exploitable without authentication):**

- **10.0 Critical (scope changed):** Oracle Access Manager [CVE-2026-87337](https://www.cve.org/CVERecord?id=CVE-2026-87337) (`AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N`); Oracle SOA Suite [CVE-2026-91231](https://www.cve.org/CVERecord?id=CVE-2026-91231), [CVE-2026-91216](https://www.cve.org/CVERecord?id=CVE-2026-91216) and [CVE-2026-91221](https://www.cve.org/CVERecord?id=CVE-2026-91221); EBS Workflow Notification Mailer [CVE-2026-101809](https://www.cve.org/CVERecord?id=CVE-2026-101809); JD Edwards EnterpriseOne Orchestrator [CVE-2026-91299](https://www.cve.org/CVERecord?id=CVE-2026-91299). All except Access Manager use `AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`.
- **9.8 Critical (`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`):** WebLogic Server [CVE-2026-91323](https://www.cve.org/CVERecord?id=CVE-2026-91323) (HTTP) and [CVE-2026-83399](https://www.cve.org/CVERecord?id=CVE-2026-83399) (T3, IIOP); EBS Application Object Library [CVE-2026-101767](https://www.cve.org/CVERecord?id=CVE-2026-101767); and four third-party component CVEs that Oracle scores in the context of its own products: [CVE-2026-75803](https://www.cve.org/CVERecord?id=CVE-2026-75803) (OpenSSL in Database Server), [CVE-2025-15467](https://www.cve.org/CVERecord?id=CVE-2025-15467) (OpenSSL) and [CVE-2026-9547](https://www.cve.org/CVERecord?id=CVE-2026-9547) (curl) in MySQL, and [CVE-2026-33466](https://www.cve.org/CVERecord?id=CVE-2026-33466) (Logstash in PeopleTools).

**Scoring disagreements (third-party CVEs).** The upstream projects rate these four CVEs lower than Oracle does:

- **CVE-2026-75803:** OpenSSL rates it **Low** severity. CISA's ADP score in the CVE record is **9.1** (`C:H/I:H/A:N`).
- **CVE-2025-15467:** OpenSSL rates it **High**. In the CVE record, CISA ADP scores it **8.8** (`UI:R`) and Red Hat ADP scores it **9.8**.
- **CVE-2026-9547:** curl rates it **Low**. CISA ADP scores it **7.4** (`AC:H`).
- **CVE-2026-33466:** Elastic (CNA) scores it **8.1** (`AC:H`). NVD's own score is **9.8**.

For Oracle's own CVEs, NVD shows only Oracle's score (status "Awaiting Analysis" or "Undergoing Analysis"). Oracle publishes no technical root cause for any of them. Only Horizon3.ai has described one (CVE-2026-101767). [Oracle CPU][cpu] [CVE records][cve-87337] [NVD][nvd-91323] [OpenSSL 2026-08-25][ossl-0825] [OpenSSL 2026-01-27][ossl-0127] [curl][curl-9547] [Elastic ESA-2026-29][esa]

**Worst case:** For the 10.0 and 9.8 flaws, Oracle's descriptions say an unauthenticated network attacker can achieve "takeover" of the affected product. The exception is Access Manager: Oracle describes complete read and modify access to Access Manager data, with no availability impact. In the scope-changed cases, Oracle says attacks "may significantly impact additional products". Access Manager is the single sign-on gateway for other applications, and SOA Suite and WebLogic host business integrations. EBS, PeopleSoft and JD Edwards hold financial, HR and payroll data. Horizon3.ai says CVE-2026-101767 lets an attacker run SQL as the EBS `APPS` database user and then run operating system commands as the EBS application account. [Horizon3.ai][h3]

**Out of scope here:** Many other unauthenticated 9.x rows are not detailed in this guide. They include Access Manager [CVE-2026-87251](https://www.cve.org/CVERecord?id=CVE-2026-87251) (9.8, SAML), Identity Manager [CVE-2026-91408](https://www.cve.org/CVERecord?id=CVE-2026-91408) (9.8, T3/IIOP), the Identity Manager Connector LDAP Gateway [CVE-2026-91491](https://www.cve.org/CVERecord?id=CVE-2026-91491) (9.8), further SOA Suite, BPM Suite, WebCenter, Data Integrator and Managed File Transfer 9.8s, WebLogic [CVE-2026-87302](https://www.cve.org/CVERecord?id=CVE-2026-87302) (9.1), Essbase [CVE-2026-91665](https://www.cve.org/CVERecord?id=CVE-2026-91665) (9.8, TCP), APEX [CVE-2026-101521](https://www.cve.org/CVERecord?id=CVE-2026-101521) (9.8), Secure Backup, Solaris, Siebel CRM, Communications and Health Sciences. Check them in the [Fusion Middleware][fmw] and other matrices. Some Oracle Communications patches also fix bundled third-party CVEs that *are* in KEV: Apache Tomcat [CVE-2025-24813](https://www.cve.org/CVERecord?id=CVE-2025-24813) and [CVE-2026-34486](https://www.cve.org/CVERecord?id=CVE-2026-34486), and HTTP/2 Rapid Reset [CVE-2023-44487](https://www.cve.org/CVERecord?id=CVE-2023-44487). They appear only in Oracle's "also addresses" lists, not in the products covered here. [KEV JSON][kev] The Java SE root-distrust alerts are tracked in [emudhra.md](emudhra.md).

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). None of [CVE-2026-87337](https://www.cve.org/CVERecord?id=CVE-2026-87337), [CVE-2026-91231](https://www.cve.org/CVERecord?id=CVE-2026-91231), [CVE-2026-91216](https://www.cve.org/CVERecord?id=CVE-2026-91216), [CVE-2026-91221](https://www.cve.org/CVERecord?id=CVE-2026-91221), [CVE-2026-101809](https://www.cve.org/CVERecord?id=CVE-2026-101809), [CVE-2026-91299](https://www.cve.org/CVERecord?id=CVE-2026-91299), [CVE-2026-91323](https://www.cve.org/CVERecord?id=CVE-2026-91323), [CVE-2026-83399](https://www.cve.org/CVERecord?id=CVE-2026-83399), [CVE-2026-101767](https://www.cve.org/CVERecord?id=CVE-2026-101767), [CVE-2026-75803](https://www.cve.org/CVERecord?id=CVE-2026-75803), [CVE-2025-15467](https://www.cve.org/CVERecord?id=CVE-2025-15467), [CVE-2026-9547](https://www.cve.org/CVERecord?id=CVE-2026-9547) or [CVE-2026-33466](https://www.cve.org/CVERecord?id=CVE-2026-33466) is listed, and no CVE in any of the CPU's risk-matrix rows is listed. **Exploitation attempts against CVE-2026-101767 have begun:** on 2026-10-27 Defused reported that its EBS decoy (honeypot) systems recorded "exploratory exploits" against the flaw that morning; this shows attackers are trying it, not that any real EBS system has been compromised, and no successful exploitation has been reported by Oracle, CISA or another source reviewed. Before that, on 2026-10-21, Waratek and Rescana knew of no in-the-wild exploitation, and CISA's ADP assessments still record "Exploitation: none" for CVE-2026-101767, -101809, -91299, -91323 and -83399 (but "poc" for the upstream OpenSSL CVE-2025-15467 and curl CVE-2026-9547). [Defused][defused] Absence from KEV is not evidence that exploitation has not occurred. Separately, the older PeopleSoft flaw [CVE-2026-35273](https://www.cve.org/CVERecord?id=CVE-2026-35273), fixed by a June Security Alert and not part of this CPU, is Listed — added 2026-06-12, federal due date 2026-06-15 (KEV `knownRansomwareCampaignUse`: Known), and ShinyHunters is exploiting it now (see [Timeline](#timeline)). [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Affected products and versions](#affected-products-and-versions)
  - [Inventory commands (read-only)](#inventory-commands-read-only)
  - [Exposure](#exposure)
  - [Log and host review](#log-and-host-review)
- [Remediation](#remediation)
  - [Interim mitigations](#interim-mitigations)
  - [PeopleSoft: the actively exploited June flaw](#peoplesoft-the-actively-exploited-june-flaw)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown for most CVEs; **2026-07-24** for CVE-2026-101767 (time/TZ unknown) | Horizon3.ai says it disclosed the EBS flaw to Oracle on July 24, 2026. Oracle credits Brandon Peterson, Jimi Sebree and Noah King of Horizon3.ai for CVE-2026-101767 and Co-tang X for CVE-2026-91231. The CPU's credit list does not name a reporter for the other CVEs in this guide. [Horizon3.ai][h3] [Oracle CPU][cpu] |
| PeopleSoft CVE-2026-35273 exploited as a zero-day | 2026-05-27 to 2026-06-09 | Mandiant/GTIG attribute the attacks to UNC6240 (ShinyHunters). Oracle issued Security Alert CVE-2026-35273 (PeopleTools 8.61, 8.62) on 2026-06-10. [GTIG][gtig] [Oracle alert][alert-35273] |
| CVE-2026-35273 added to CISA KEV | 2026-06-12 | Federal due date 2026-06-15. [KEV JSON][kev] |
| Renewed ShinyHunters PeopleSoft campaign | Reported 2026-09-25 | GTIG says the actor bypasses WAF rules by requesting `/%50SEMHUB/` instead of `/PSEMHUB/`, has deployed web shells on dozens of systems, and installs the SIDEEYE backdoor on Windows hosts. [GTIG][gtig] |
| Oracle pre-release announcement | 2026-10-15 | Reported by Waratek, which says it described 1,283 patches; the pre-release itself was not reviewed. [Waratek][waratek] |
| **Public announcement**: October 2026 CPU released | 2026-10-20 (time not stated) | Oracle modification history: "2026-October-20, Rev 1. Initial Release." Patches are delivered through the My Oracle Support patch availability documents linked from the advisory. MySQL 8.4.13 and 9.7.4 release notes are dated the same day. [Oracle CPU][cpu] [MySQL 8.4.13][mysql-8413] [MySQL 9.7 notes][mysql-97] |
| Oracle CPU Revision 2 | 2026-10-26; time/TZ unknown | Oracle updated the CPU to Revision 2, changing Siebel CRM version information and credits. The reviewed CPU counts, impact statements, patch availability and KEV status did not change. Oracle has made no statement about exploitation of CVE-2026-101767 (checked 2026-10-30). The CPU's sentence that attackers "have been successful because targeted customers had failed to apply available Oracle patches" is standing text that also appears in the July 2026 CPU; it is not about this CVE. [Oracle CPU][cpu] |
| CVE records published | 2026-10-20 21:22:48–21:25:18 UTC | Oracle CNA records for the Oracle-assigned CVEs. NVD received them at 22:18–22:20 UTC. [CVE JSON][cve-101767] [NVD][nvd-91323] |
| Horizon3.ai CVE-2026-101767 summary | 2026-10-20 (per Rescana; the page shows no date) | Includes mitigations and behavioural indicators (see [Log and host review](#log-and-host-review)). [Horizon3.ai][h3] [Rescana][rescana] |
| CISA ADP SSVC assessments | 2026-10-21 10:55 UTC (CVE-2026-101767, -91323, -83399); 2026-10-23 11:01 UTC (-91299); 2026-10-24 03:55 UTC (-101809) | Exploitation: none; Automatable: yes; Technical impact: total. No ADP assessment yet for CVE-2026-87337, -91216, -91221 or -91231. [CVE JSON][cve-101767] |
| Analyses report no exploitation of new CVEs | 2026-10-21 | Waratek: "We are not aware of public reports that any vulnerability newly fixed in this CPU has been exploited in the wild." Rescana (CVE-2026-101767): no report of in-the-wild exploitation or a public proof of concept. [Waratek][waratek] [Rescana][rescana] |
| Tenable version-based plugins | 2026-10-21 onward | Nessus 369015 (Access Manager) and 371213 (WebLogic), among others. [Tenable OAM][tenable-oam] [Tenable WebLogic][tenable-wls] |
| **First reported exploitation attempts** (CVE-2026-101767) | Activity "this morning, Oct 27" (time/TZ unknown); reported 2026-10-27 15:15 UTC | Defused said its Oracle EBS decoys recorded "exploratory exploits" against CVE-2026-101767, and that no earlier public report of in-the-wild attempts existed. These were attempts against honeypots. Defused published no victim, success or compromise report; its IOCs are only on its registration-gated Defused Radar console and were not reviewed. [Defused][defused] |
| Censys exposure advisory | 2026-10-28 | Censys counted 2,246 internet-facing EBS web properties (hostname/port pairs). It cannot tell which run an affected release or have the October patch. [Censys][censys] |
| CISA KEV | Not listed as of catalog 2026.10.29 (checked 2026-10-30) | Applies to every CVE in this guide. [KEV JSON][kev] |
| Next Oracle security releases | 2026-11-17 (CSPU), 2026-12-15 (CSPU), 2027-01-19 (CPU) | Oracle now ships security patches on the third Tuesday of every month. [Oracle CPU][cpu] |

## Detection

### Affected products and versions

The table lists the top flaws per product, as given in Oracle's risk matrices. Every row is remotely exploitable without authentication. Oracle lists only versions under Premier or Extended Support. It says earlier versions are "likely" affected too, so treat unsupported releases as affected. Oracle notes that a protocol listed in the matrix covers its secure variant too, so HTTP also means HTTPS. [Oracle CPU][cpu]

| Product (matrix) | CVE | Oracle CVSS 3.1 | Protocol | Component | Affected supported versions |
|---|---|---|---|---|---|
| Oracle Access Manager ([FMW][fmw]) | CVE-2026-87337 | 10.0 | HTTP | Authentication Engine | 12.2.1.4.0, 14.1.2.1.0 |
| Oracle SOA Suite ([FMW][fmw]) | CVE-2026-91231 | 10.0 | HTTP | Adapters | 12.2.1.4.0, 14.1.2.0.0 |
| Oracle SOA Suite ([FMW][fmw]) | CVE-2026-91216, CVE-2026-91221 | 10.0 | T3, IIOP | Fabric Layer | 12.2.1.4.0, 14.1.2.0.0 |
| Oracle WebLogic Server ([FMW][fmw]) | CVE-2026-91323 | 9.8 | HTTP | Core | 12.2.1.4.0, 14.1.1.0.0, 14.1.2.0.0, 15.1.1.0.0 |
| Oracle WebLogic Server ([FMW][fmw]) | CVE-2026-83399 | 9.8 | T3, IIOP | Core | 12.2.1.4.0, 14.1.1.0.0, 14.1.2.0.0, 15.1.1.0.0 |
| EBS: Workflow ([EBS][ebs]) | CVE-2026-101809 | 10.0 | HTTP | Workflow Notification Mailer | 12.2.3–12.2.15 |
| EBS: Application Object Library ([EBS][ebs]) | CVE-2026-101767 | 9.8 | HTTP | Core (TCF servlet `/OA_HTML/AppsTCFServer`, per Horizon3.ai) | 12.2.3–12.2.15 |
| JD Edwards EnterpriseOne Orchestrator ([JDE][jde]) | CVE-2026-91299 | 10.0 | HTTP | E1 IOT Orchestrator Security | 9.2.0.0–9.2.26.5 |
| Oracle Database Server ([DB][db]) | CVE-2026-75803 (OpenSSL) | 9.8 | TLS | RDBMS (OpenSSL) | 19.3–19.32, 23.4.0–23.26.3. Oracle says it also affects **client-only installations**. A separate RDBMS (Python) row scores 6.2 (local) for 21.3–21.23 and 23.x. |
| MySQL Server, MySQL Cluster ([MySQL][mysql]) | CVE-2025-15467 (OpenSSL) | 9.8 | MySQL Protocol | Server: Compiling (OpenSSL) | Server 8.4.0–8.4.12, 9.7.0–9.7.3, 26.7.0–26.7.1; Cluster also 8.0.0–8.0.49 |
| MySQL Server, MySQL Cluster ([MySQL][mysql]) | CVE-2026-9547 (curl) | 9.8 | HTTPS | Server: Compiling (curl) | Same as above |
| MySQL Enterprise Backup ([MySQL][mysql]) | CVE-2025-15467, CVE-2026-9547 | 9.8 | TLS / HTTPS | Enterprise Backup (OpenSSL, curl) | 8.0.0–8.0.49, 8.4.0–8.4.12, 9.7.0–9.7.3, 26.7.0 |
| PeopleSoft Enterprise PeopleTools ([PeopleSoft][ps]) | CVE-2026-33466 (Logstash) | 9.8 | HTTP | Logstash | 8.61–8.63 |

**Notes on the third-party rows.** Oracle's patches for these CVEs also fix bundled CVEs. Oracle lists them as "also addresses" entries, for example eight further OpenSSL CVEs under CVE-2026-75803 in the Database matrix. The upstream descriptions narrow the conditions:

- **CVE-2026-75803:** an application that calls `EVP_Cipher()` on an empty ChaCha20-Poly1305 or AES-OCB ciphertext may accept a forged message.
- **CVE-2025-15467:** a stack buffer overflow when parsing crafted CMS (Auth)EnvelopedData.
- **CVE-2026-9547:** libcurl SCP/SFTP may accept a mismatched host-key type.
- **CVE-2026-33466:** a Logstash archive path traversal through a compromised or attacker-controlled update endpoint.

Oracle does not explain how each one is reachable in its products. Treat Oracle's matrix as the applicability statement, and keep the upstream qualifications in mind when you prioritize. [CVE JSON][cve-75803] [CVE JSON][cve-15467] [CVE JSON][cve-9547] [CVE JSON][cve-33466]

**EBS dependency:** Oracle says EBS exposure also depends on its Database and Fusion Middleware components. It recommends applying the October CPU to those layers too (My Oracle Support Note KA923). The same applies to Enterprise Manager (CPU391). [Oracle CPU][cpu]

### Inventory commands (read-only)

The commands below only read state. Run them as the product's software owner or as a database user with read access. Replace the placeholders (`$ORACLE_HOME`, `$WL_HOME`) with your own paths. They were not exercised on real deployments for this guide.

- **Fusion Middleware and Database homes:** `"$ORACLE_HOME/OPatch/opatch" lspatches` lists the patches installed in a home. Compare the output with the October 2026 patch numbers in the patch availability documents: **CPU360** (Fusion Middleware), **CPU359** (Database), **KA923** (EBS), **CPU417** (JD Edwards), **CPU378** (MySQL), **CPU418** (PeopleSoft). Check every home, including each WebLogic or SOA domain's middleware home, the EBS run and patch file systems, and every database client home.
- **WebLogic version:** source `"$WL_HOME/server/bin/setWLSEnv.sh"` in a shell, then run `java weblogic.version`.
- **Database:** `SELECT banner_full FROM v$version;` and `SELECT patch_id, action, status, description FROM dba_registry_sqlpatch ORDER BY action_time;`
- **EBS release:** `SELECT release_name FROM apps.fnd_product_groups;` returns, for example, `12.2.15`.
- **MySQL:** `SELECT VERSION();`. Where the status variable exists, `SHOW GLOBAL STATUS LIKE 'Tls_library_version';` shows which OpenSSL the server uses. For MySQL Enterprise Backup, run `mysqlbackup --version`.
- **PeopleTools:** `SELECT toolsrel FROM psstatus;`
- **JD Edwards:** check the Tools release of the AIS/Orchestrator server in Server Manager.
- **Scanners:** version-based scanners can help with inventory, for example Tenable Nessus [369015][tenable-oam] (Access Manager) and [371213][tenable-wls] (WebLogic). They compare installed versions and patches. They do not test for the flaws.

### Exposure

- **WebLogic and SOA Suite T3/IIOP:** WebLogic normally serves HTTP, T3 and IIOP on the same listen ports. A rule that opens a WebLogic port for HTTP therefore usually opens T3 and IIOP as well. Find every WebLogic-based server whose listen or administration ports are reachable from untrusted networks, including Managed Servers that host SOA, OAM, OIM, EBS, PeopleSoft (PIA) and JD Edwards components.
- **HTTP paths:** Check whether the Access Manager front end, SOA Suite endpoints, the EBS web tier, and the JD Edwards AIS/Orchestrator server can be reached from the internet. Horizon3.ai notes that the EBS servlet `/OA_HTML/AppsTCFServer` is allowed through the **default** EBS URL firewall configuration. [Horizon3.ai][h3]
- **Database and MySQL:** Find listeners (Oracle Net/TLS, MySQL protocol) that are reachable outside the application tier. Also include client-only database installations, which Oracle says are affected by CVE-2026-75803.
- If you cannot establish whether a system is reachable, treat it as exposed.

### Log and host review

Oracle has published **no indicators of compromise** for any CVE in this CPU. Since 2026-10-27, attackers have been trying CVE-2026-101767 against honeypots (see [Timeline](#timeline)). If an internet-facing EBS web tier was unpatched on or after that date, review it now rather than waiting for a KEV listing. Defused keeps the attempts' IOCs on its registration-gated console; this guide has not reviewed them. For CVE-2026-101767, Horizon3.ai lists three behavioural indicators. Rescana notes that they are researcher guidance, not indicators observed in attacks: [Horizon3.ai][h3] [Rescana][rescana] [Defused][defused]

- Unauthenticated `POST` requests to `/OA_HTML/AppsTCFServer` that instantiate `oracle.apps.jtf.gantt.server.GanttDataServer`, followed by backend database activity.
- SQL reconnaissance (database version, current user, directory objects) shortly after unauthenticated web requests.
- Unexpected files in `$APPLPTMP`, and the `oracle` account spawning `/bin/sh` through the Concurrent Manager.

The class name appears in the request **body**, which standard access logs do not record. Access logs can show only the path, so use WAF, reverse-proxy or IDS body capture for the class name. A read-only first pass over exported EBS web-tier (Oracle HTTP Server) access logs follows. Replace `EXPORTED_ACCESS_LOGS` with your files. The command reads them and changes nothing:

```sh
grep -n 'AppsTCFServer' EXPORTED_ACCESS_LOGS | grep -F 'POST'
```

Legitimate TCF use (for example Gantt-chart features) can also produce these requests. Treat matches from unexpected sources as leads, not proof.

For WebLogic, SOA Suite, Access Manager and JD Edwards, there are no published request signatures. Review these instead:

- shell processes (`/bin/sh`, `bash`, `cmd.exe`) spawned by WebLogic or other Java server processes;
- new or changed deployments, JSP files or domain configuration;
- unexpected administrator logins and new administrative accounts;
- for Access Manager, policy or authentication-scheme changes and new or unexpected sessions for privileged users.

Finding nothing does **not** prove a system is clean. Indicators are scarce, logs may not capture request bodies, and an attacker who gains code execution can alter local logs.

## Remediation

1. **Apply the October 2026 CPU patches** for every affected home, starting with internet-facing Access Manager, SOA Suite, WebLogic, EBS and JD Edwards Orchestrator. Get the exact patch numbers and prerequisites from the patch availability document linked in the [advisory][cpu]: CPU360 (Fusion Middleware), KA923 (EBS), CPU417 (JD Edwards), CPU359 (Database), CPU378 (MySQL) and CPU418 (PeopleSoft). Oracle says it does not test unsupported releases and recommends upgrading them to supported versions. Follow each product's patching procedure. For EBS, that means online patching cycles that also cover the database and the Fusion Middleware technology stack. Back up first, and plan for service restarts.
2. **Database:** The matrix lists 19.3–19.32 and 23.4.0–23.26.3 as affected. This implies, but does not confirm, that the October 2026 Release Updates are the first fixed builds. Confirm in CPU359, and patch client-only homes too.
3. **MySQL:** MySQL 8.4.13 and 9.7.4 were released on 2026-10-20 and follow the affected ranges. Their release notes do not name CVE-2025-15467 or CVE-2026-9547 or mention an OpenSSL or curl update, so confirm the fixed builds in CPU378. No 26.7.2 release appears in the release notes reviewed. The 26.10 index lists 26.10.0 as dated 2026-10-20, but its own page says "2026-09-18 (Early Access Release)". Users of the 26.7 track should confirm their upgrade path with Oracle. If your MySQL packages link the operating system's OpenSSL, the OS OpenSSL update also matters. That last point is an inference from how the server is built, not an Oracle statement. Upgrade MySQL Enterprise Backup separately. [MySQL 8.4.13][mysql-8413] [MySQL 9.7 notes][mysql-97] [MySQL 26.10 notes][mysql-2610]
4. **PeopleTools CVE-2026-33466:** apply the PeopleTools patches in CPU418 to 8.61–8.63. Elastic fixed the upstream Logstash flaw in 8.19.14, 9.2.8 and 9.3.3. [Elastic ESA-2026-29][esa]
5. Restart or redeploy each service after patching. A patched home does not protect a server process that is still running old code.

### Interim mitigations

Oracle publishes **no CVE-specific workarounds** for this CPU. Its general advice is that blocking the network protocols an attack needs, or removing unneeded privileges, "may" reduce risk. It warns that both approaches can break functionality and are not long-term fixes. Test them outside production first. [Oracle CPU][cpu]

- **T3/IIOP (CVE-2026-83399, CVE-2026-91216, CVE-2026-91221):** Use WebLogic network connection filters (`weblogic.security.net.ConnectionFilterImpl`) to deny `t3`, `t3s`, `iiop` and `iiops` from untrusted addresses. Disable IIOP where nothing uses it. Port-level firewalls cannot separate these protocols from HTTP on a shared listen port. [WebLogic connection filters][wls-filter]
- **EBS (CVE-2026-101767):** Horizon3.ai advises removing `/OA_HTML/AppsTCFServer` (`oracle.apps.fnd.tcf.SocketServer`) from the EBS URL firewall allowlist and restricting the web tier to trusted networks. Horizon3.ai says these steps reduce exposure but do not replace patching. [Horizon3.ai][h3] No source reviewed gives a workaround for the Workflow Notification Mailer flaw (CVE-2026-101809).
- **HTTP-only flaws (Access Manager, SOA Suite Adapters, WebLogic CVE-2026-91323, JD Edwards Orchestrator):** Restrict who can reach these endpoints, for example by keeping SOA, Orchestrator and administrative consoles off the internet. An Access Manager front end often has to stay public. If it does, patching is the only control.
- These changes **alter configuration** and can lock out legitimate integrations. Keep a rollback path.

### PeopleSoft: the actively exploited June flaw

The October CPU does **not** fix CVE-2026-35273. It was fixed by Oracle's 2026-06-10 Security Alert for PeopleTools 8.61 and 8.62, and ShinyHunters has been exploiting it again since September by bypassing WAF rules. Apply the Security Alert patch (CPU187). If EMHub is not needed, disable it or remove the PSEMHUB application, as Oracle and Mandiant advise. Mandiant says WAF and path-based blocking are not a substitute for patching. [Oracle alert][alert-35273] [GTIG][gtig]

## Verification

- Re-run `opatch lspatches` and the version queries above on every node, including the EBS patch file system, every WebLogic and SOA managed server, standby databases and client homes. Confirm that the October 2026 patch IDs from the relevant patch availability document are present.
- Confirm that services restarted after patching. Check that start times are later than the patch time.
- From a network you control outside the trusted zone, confirm that T3/IIOP connections are refused where you filtered them. Check that normal HTTP application use, SOA composites, OAM logins, EBS forms and workflows, and JD Edwards orchestrations still work.
- Do not send exploit requests to production. That includes crafted requests to `/OA_HTML/AppsTCFServer` and T3/IIOP deserialization probes. Use version and patch evidence instead.

## Compromise response

- **Preserve first:** before patching or restarting a suspect host, preserve its web-tier, WebLogic and database audit logs and a copy of its domain and application directories. Engage Oracle Support or an incident-response provider.
- **EBS:** If an attacker had code execution as the application account or SQL as `APPS`, all EBS data and stored credentials are exposed. Change the `APPS`/`APPLSYS` and other schema passwords with Oracle's supported procedure (AFPASSWD). Also:
  - review `FND_USER` accounts and responsibilities;
  - review concurrent programs and requests created in the suspect window;
  - check `$APPLPTMP` and the web-tier directories for unexpected files.
- **Access Manager / SOA / WebLogic:** Rotate WebLogic administrator credentials, `boot.properties`, data-source passwords and any keys or secrets stored in the domain. For Access Manager, rotate the keys and agent secrets it holds and review its policies. Assume that sessions issued during the suspect window may be forged, and review access to the applications it protects.
- **Database / MySQL:** Review database audit logs for new accounts, grants and directory objects. Rotate application and administrative credentials.
- **PeopleSoft (CVE-2026-35273):** Follow GTIG's steps:
  - search access logs for `/PSEMHUB/` and percent-encoded variants such as `/%50SEMHUB/`;
  - inspect `PSEMHUB.war` and `PORTAL.war` for unexpected `.jsp`, `.jspx` or `.exe` files (named examples: `x.jsp`, `u.jsp`, `tunnel.jsp`, `Ple64.exe`);
  - check for MeshCentral agents;
  - rotate credentials readable by the PeopleSoft service account.

  GTIG publishes the network indicators. Do not contact that infrastructure. Search for it only in your own logs. [GTIG][gtig]
- If you cannot establish a host's integrity, rebuild it from trusted media and reviewed configuration.

## Sources

- [Oracle Critical Patch Update Advisory, October 2026][cpu] (Rev 2, 2026-10-26) — counts, risk matrices (rows, scores, vectors, protocols, versions), credits, "also addresses" lists, client-only note, workarounds text and the monthly release schedule. Also the [text form][verbose] and [CSAF][csaf], plus the matrix anchors for [Fusion Middleware][fmw], [EBS][ebs], [JD Edwards][jde], [Database][db], [MySQL][mysql] and [PeopleSoft][ps].
- CVE records (Oracle CNA, with CISA ADP): [CVE-2026-87337][cve-87337], [CVE-2026-101767][cve-101767], and the same API for the other Oracle-assigned CVEs. Upstream records: [CVE-2026-75803][cve-75803] (OpenSSL), [CVE-2025-15467][cve-15467] (OpenSSL, with CISA and Red Hat ADP scores), [CVE-2026-9547][cve-9547] (curl) and [CVE-2026-33466][cve-33466] (Elastic). NVD: [CVE-2026-91323][nvd-91323] (status and source of scores).
- Upstream severity: [OpenSSL advisory 2026-08-25][ossl-0825] (CVE-2026-75803, Low), [OpenSSL advisory 2026-01-27][ossl-0127] (CVE-2025-15467, High), [curl CVE-2026-9547][curl-9547] (Low), [Elastic ESA-2026-29][esa] (Logstash fixes).
- [Horizon3.ai: CVE-2026-101767][h3] — root cause, TCF servlet, mitigations, indicators, and the 2026-07-24 report date.
- [Waratek, 2026-10-21][waratek] and [Rescana, 2026-10-21][rescana] — no reported exploitation of newly fixed CVEs, and context on ShinyHunters.
- [Defused on X, 2026-10-27][defused] — first public report of exploitation attempts ("exploratory exploits") against CVE-2026-101767, recorded by its EBS decoys. Secondary reports (BleepingComputer, SecurityWeek, 2026-10-28) add no further primary evidence.
- [Censys advisory, 2026-10-28][censys] — 2,246 internet-facing EBS web properties, excluding honeypots; patch status not visible in scan data.
- [Oracle Security Alert CVE-2026-35273][alert-35273] and [Mandiant/GTIG, 2026-09-25][gtig] — the PeopleSoft campaign, WAF bypass, indicators and remediation.
- [CISA KEV JSON feed][kev] — catalog 2026.10.29. None of the CVEs in this guide are listed. CVE-2026-35273 is listed.
- MySQL release notes: [8.4.13][mysql-8413], [9.7 index][mysql-97], [26.10 index][mysql-2610].
- [WebLogic network connection filters][wls-filter]; Tenable Nessus [369015][tenable-oam] and [371213][tenable-wls].
- [SecurityWeek, 2026-10-22][secweek] — secondary report of the CPU's size (citing Tenable's count of 1,209 CVEs).

[cpu]: https://www.oracle.com/security-alerts/cpuoct2026.html
[verbose]: https://www.oracle.com/security-alerts/cpuoct2026verbose.html
[csaf]: https://www.oracle.com/docs/tech/security-alerts/cpuoct2026csaf.json
[fmw]: https://www.oracle.com/security-alerts/cpuoct2026.html#AppendixFMW
[ebs]: https://www.oracle.com/security-alerts/cpuoct2026.html#AppendixEBS
[jde]: https://www.oracle.com/security-alerts/cpuoct2026.html#AppendixJDE
[db]: https://www.oracle.com/security-alerts/cpuoct2026.html#AppendixDB
[mysql]: https://www.oracle.com/security-alerts/cpuoct2026.html#AppendixMSQL
[ps]: https://www.oracle.com/security-alerts/cpuoct2026.html#AppendixPS
[cve-87337]: https://cveawg.mitre.org/api/cve/CVE-2026-87337
[cve-101767]: https://cveawg.mitre.org/api/cve/CVE-2026-101767
[cve-75803]: https://cveawg.mitre.org/api/cve/CVE-2026-75803
[cve-15467]: https://cveawg.mitre.org/api/cve/CVE-2025-15467
[cve-9547]: https://cveawg.mitre.org/api/cve/CVE-2026-9547
[cve-33466]: https://cveawg.mitre.org/api/cve/CVE-2026-33466
[nvd-91323]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-91323
[ossl-0825]: https://openssl-library.org/news/secadv/20260825.txt
[ossl-0127]: https://openssl-library.org/news/secadv/20260127.txt
[curl-9547]: https://curl.se/docs/CVE-2026-9547.html
[esa]: https://discuss.elastic.co/t/logstash-8-19-14-9-2-8-9-3-3-security-update-esa-2026-29/385816
[h3]: https://horizon3.ai/attack-research/vulnerabilities/cve-2026-101767/
[waratek]: https://waratek.com/news/oracle-releases-the-october-2026-critical-patch-update/
[rescana]: https://www.rescana.com/post/oracle-e-business-suite-cve-2026-101767-prepare-now
[defused]: https://x.com/DefusedCyber/status/2115099999973364147
[censys]: https://censys.com/advisory/cve-2026-101767
[alert-35273]: https://www.oracle.com/security-alerts/alert-cve-2026-35273.html
[gtig]: https://cloud.google.com/blog/topics/threat-intelligence/shinyhunters-renewed-mass-exploitation-campaign-targeting-oracle-peoplesoft
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[mysql-8413]: https://dev.mysql.com/doc/relnotes/mysql/8.4/en/news-8-4-13.html
[mysql-97]: https://dev.mysql.com/doc/relnotes/mysql/9.7/en/
[mysql-2610]: https://dev.mysql.com/doc/relnotes/mysql/26.10/en/
[wls-filter]: https://docs.oracle.com/en/middleware/standalone/weblogic-server/14.1.1.0/scprg/developing-applications-weblogic-security-service.pdf
[tenable-oam]: https://www.tenable.com/plugins/nessus/369015
[tenable-wls]: https://www.tenable.com/plugins/nessus/371213
[secweek]: https://www.securityweek.com/oracle-patches-over-1200-vulnerabilities-with-october-2026-cpu
