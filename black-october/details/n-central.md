# N-central: critical vulnerabilities, hotfix 2026.4.1.26

**Last updated:** 2026-11-21 (America/New_York)

[Back to N-central summary](../black-october-2026.md#n-central-critical-vulnerabilities-hotfix-20264126) · [Changelog](../../CHANGELOG.md)

N-able released N-central **2026.4 HF2, build 2026.4.1.26**, on November 10. The release notes say it fixes seven CVEs. On November 12 a second disclosure, called 4EverAble2Shell by the researcher, claims an unauthenticated path to root that still works on that build when the Legacy API is turned on and reachable from the internet. That API is off by default. At 16:00 UTC the same day N-able opened [incident 202613](https://uptime.n-able.com/event/202613) and turned the Intune integration off as a precaution. On November 13 N-able said its investigation had found indicators of compromise and that it is working with those customers. Two research firms report a cryptocurrency miner on production servers, including servers already on 2026.4.1.26.

On November 16 N-able posted **2026.4 HF3, build 2026.4.1.39**. The release notes say it supersedes 2026.4.0.27, 2026.4.0.32, and 2026.4.1.26, and that it permanently removes the Legacy API. They also say Agents and Probes that are not upgraded to HF3 can still be impersonated. Remote control other than Take Control stays disabled, and the Intune integration stays blocked. N-able's blog the same day says data-leakage issues that need an already-privileged account are still open, and that the next release will bring remote control and the Intune integration back.

**N-able published seventeen more records on November 17, three of them CVSS 4.0 Critical.** Every one says "before 2026.4.1 HF3," except the Patch Management flaw, which says the engine is affected before 2.14.4.5829. Huntress says public proof-of-concept code for all seventeen appeared the evening of November 16, and that it has not seen them used in partner environments.

- [CVE-2026-129272](https://www.cve.org/CVERecord?id=CVE-2026-129272), CVSS 4.0 9.3 Critical. A predictable appliance passcode lets a remote attacker with no login impersonate an Agent or Probe. This is the impersonation the release notes tell customers to close by upgrading every Agent and Probe.
- [CVE-2026-129280](https://www.cve.org/CVERecord?id=CVE-2026-129280), CVSS 4.0 9.3 Critical. ServerUI and ServerUI2 SOAP operations do not check the caller's session, permissions, or customer scope. In some cases with no login, an attacker can read device and patch data, test user passwords, send messages to managed agents, and change another customer's settings.
- [CVE-2026-129286](https://www.cve.org/CVERecord?id=CVE-2026-129286), CVSS 4.0 9.2 Critical. A version value in software-update metadata writes a file outside the download directory and runs code as the N-central service account. The attacker has to be able to supply or change that metadata. The vector's Attack Complexity is High.
- [CVE-2026-129274](https://www.cve.org/CVERecord?id=CVE-2026-129274), CVSS 4.0 8.7 High. No login is needed to submit forged results for any customer's remote-execution tasks.
- [CVE-2026-129282](https://www.cve.org/CVERecord?id=CVE-2026-129282), CVSS 4.0 8.7 High. The test-email function takes a logged-in user, checks no permission, and passes the address to the mail program. There is no CSRF protection.
- [CVE-2026-129273](https://www.cve.org/CVERecord?id=CVE-2026-129273), CVSS 4.0 8.6 High. An Audit Export setting runs a command as root. Product administrator required.
- [CVE-2026-129271](https://www.cve.org/CVERecord?id=CVE-2026-129271), CVSS 4.0 8.5 High. Local privilege escalation in the Patch Management Engine, through attacker-controlled metadata. Fixed in Patch Management Component 2.14.4.5829, which is a separate version from the server build.
- [CVE-2026-129281](https://www.cve.org/CVERecord?id=CVE-2026-129281), CVSS 4.0 8.5 High. A user with view-only access to a device sets execution configuration that the Windows agent acts on.
- [CVE-2026-129287](https://www.cve.org/CVERecord?id=CVE-2026-129287), CVSS 4.0 8.3 High. The software-repository parser processes XML external entities. The attacker has to be able to supply or change the repository files.
- [CVE-2026-129275](https://www.cve.org/CVERecord?id=CVE-2026-129275), CVSS 4.0 8.2 High. No login is needed to download any customer's Automation Manager policy, including embedded scripts and parameter values, if the policy identifier is known.
- [CVE-2026-129283](https://www.cve.org/CVERecord?id=CVE-2026-129283), CVSS 4.0 7.1 High. Custom service import processes XML external entities. A logged-in user can read files the service account can read.
- [CVE-2026-129276](https://www.cve.org/CVERecord?id=CVE-2026-129276), [CVE-2026-129277](https://www.cve.org/CVERecord?id=CVE-2026-129277), [CVE-2026-129278](https://www.cve.org/CVERecord?id=CVE-2026-129278), and [CVE-2026-129279](https://www.cve.org/CVERecord?id=CVE-2026-129279), each CVSS 4.0 6.9 Medium. No login: overwrite an appliance's asset data, read or cancel its maintenance actions, alter Take Control task records and the audit log, or enumerate account email addresses from the password-reset response.
- [CVE-2026-129284](https://www.cve.org/CVERecord?id=CVE-2026-129284) and [CVE-2026-129285](https://www.cve.org/CVERecord?id=CVE-2026-129285), each CVSS 4.0 5.3 Medium. A logged-in user points Report Manager or Data Export at an internal address, or one appliance forges another's XMPP action response.

**N-able rates two of the seven CVSS 4.0 Critical and five High.** All seven were published 2026-11-10 by N-able.

- [CVE-2026-125883](https://www.cve.org/CVERecord?id=CVE-2026-125883), CVSS 4.0 9.3 Critical. XXE, described as XML schema poisoning. Affected before 26.4.1. No privileges required.
- [CVE-2026-125881](https://www.cve.org/CVERecord?id=CVE-2026-125881), CVSS 4.0 9.3 Critical. Server-side request forgery in service-import schema validation. Affected before 26.4.1. No privileges required.
- [CVE-2026-125878](https://www.cve.org/CVERecord?id=CVE-2026-125878), CVSS 4.0 8.7 High. The title says OGNL injection leading to code execution. The description says cross-site scripting and resource injection. Both sentences are N-able's. Affected before 26.4.1. Low privileges.
- [CVE-2026-125879](https://www.cve.org/CVERecord?id=CVE-2026-125879), CVSS 4.0 8.6 High. Local privilege escalation to root through a syslog-ng configuration the `nable` user can write. Affected before 26.4.1. High privileges. The vector's Attack Vector is Network.
- [CVE-2026-125882](https://www.cve.org/CVERecord?id=CVE-2026-125882), CVSS 4.0 8.6 High. Path traversal in the file-repository upload, which the release notes call remote code execution. Affected before 26.4.1. High privileges. N-able credits Nate Fair of Sprocket Security.
- [CVE-2026-91000](https://www.cve.org/CVERecord?id=CVE-2026-91000), CVSS 4.0 8.4 High. Missing authentication on an IPC channel, local privilege escalation. Affected before 2026.4.1. The other six records say "before 26.4.1." Both are N-able's.
- [CVE-2026-125880](https://www.cve.org/CVERecord?id=CVE-2026-125880), CVSS 4.0 8.3 High. Stored cross-site scripting through MMS3 patch metadata, in an administrator's browser. Affected before 26.4.1.

The release notes say this build supersedes 2026.4 (2026.4.0.27) and 2026.4 HF1 (2026.4.0.32). Supported upgrades start at 2025.4. Built-in remote control is turned off in this build and comes back in a later fix. Take Control still works.

The incident started 2026-11-09. N-able took hosted N-central offline and told on-premises customers to shut their servers down. At 01:04:27 UTC on 2026-11-11 the status page, incident 202584, said every hosted N-central server across all regions had been upgraded. The same page still says on-premises servers should stay offline until their own upgrade has succeeded, because scanning is underway. The November 10, 05:00 UTC estimate of mid-day is superseded by the published build.

N-central deploys software, runs scripts, and opens remote-control sessions on the machines it manages. Ecoverse under N-able Login stays up at `https://n-able.app`.

The November 12 chain has no CVE of its own. The published proof of concept starts with [CVE-2026-90436](https://www.cve.org/CVERecord?id=CVE-2026-90436), an unauthenticated class instantiation in Apache Axis 1.x, which Apache says is end of life and will not release a fix for. Apache rates it critical in text and publishes no numeric score. CISA's enrichment of that record scores it CVSS 3.1 9.8. The second step is an N-central privilege escalation that no vendor has scored. Previdian tracks the chain as VULN-2026-0009 and scores it 9.8 itself. That score is Previdian's, not N-able's and not Apache's.

**CISA KEV:** Listed — [CVE-2026-90436](https://www.cve.org/CVERecord?id=CVE-2026-90436) added 2026-11-18, federal due date 2026-11-21. Ransomware use Unknown. Forensic triage is required. Catalog 2026.11.18, released 2026-11-18T19:17:41.0354Z. The seven November 10 CVEs and the seventeen November 17 CVEs are not listed. N-able's November 13 update says it has identified indicators of compromise and is working with those customers. It does not say how many, or whether they were hosted or on premises. Huntback reports 21 production N-central servers mining Monero at 12:50 UTC on November 12, 19 of them on build 2026.4.1.26, identified from a public mining pool and checked by requesting each server's login page. Previdian reports exploitation attempts against its own honeypot, which is not a compromised customer. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Researcher publishes Able2Shell | 2026-11-08; time unknown | BleepingComputer says late Sunday, November 8. [BleepingComputer][bc] |
| **Public announcement** | **2026-11-09 15:15:00 UTC** | N-able incident 202561. Hosted N-central taken offline. On-premises servers should be taken offline. No active exploitation seen at that time. [Status][status] |
| Status update | 2026-11-09 19:59:46 UTC | Hotfix being validated. No evidence of active exploitation or unauthorized data access. The event page no longer shows this entry; the November 9 read recorded it. |
| Status update | 2026-11-10 05:00:00 UTC | Hotfix estimated for mid-day November 10 (EST). No indication an environment was impacted. |
| Status update | 2026-11-10 09:46:19 UTC | Aiming for a build around midday EST. Recorded from incident 202561 before the page moved. |
| **Release** | **2026-11-10; time/TZ unknown** | Release notes posted November 10, 2026, by annemayekar. The page says 8:48 pm and does not name the timezone. Build 2026.4.1.26. Seven CVEs. [Notes][notes] |
| Hosted upgrade complete | 2026-11-11 01:04:27 UTC | Incident 202584. Every hosted N-central server, all regions, upgraded. On-premises servers stay offline until their own upgrade succeeds. Scanning still observed. [Event][event] |
| CVE records | 2026-11-10 21:19 to 21:26 UTC | N-able published the seven records. |
| Second disclosure | 2026-11-12 00:00:00 MST (UTC−07:00) | Incident 202609, status Investigating. N-able says the claimed server issue needs Legacy API on and exposed to the internet. Hosted is not affected. [Event 202609][event2] |
| Precautionary restrictions | 2026-11-12 16:00:00 UTC | Incident 202613, status Identified. N-able turned the Intune integration off and, in that first update, said it had seen no signs of compromise. No newer build. [Event 202613][event3] |
| Exploitation reported | 2026-11-12 12:50 UTC | Huntback says a public mining pool listed 21 active `nc_` rigs, and that each address serves an N-central login page. 19 report build 2026.4.1.26. [Huntback][huntback] |
| N-able finds indicators | 2026-11-13 03:50:42 UTC | Incident 202613. N-able says it identified indicators of compromise and is working with those customers. It names no count and no build. [Event 202613][event3] |
| **HF3** | **2026-11-16; time/TZ unknown** | Build 2026.4.1.39. The notes say the Legacy API is permanently removed and that Agents and Probes must be upgraded. [HF3 notes][hf3] |
| **HF4** | **2026-11-21 12:59; timezone not stated** | Build 2026.4.1.40. Remote control and the Intune integration are turned back on. The Java package is updated for CVE-2026-114938. N-able says a CMMC build is not ready. [HF4 notes][hf4] |
| Seventeen more CVE records | 2026-11-17 11:44 to 11:48 UTC | N-able published CVE-2026-129271 through CVE-2026-129287. Three are CVSS 4.0 Critical: 9.3, 9.3, and 9.2. |
| **CISA KEV** | **2026-11-18; time/TZ unknown** | CVE-2026-90436 added. Federal due date 2026-11-21. The seven and the seventeen are not listed. |
| **Last updated** | **2026-11-18 (America/New_York)** | CISA listed the Axis flaw this chain starts from. The build is unchanged. |

## Detection

1. **Version.** 2026.4.1.39 is the build the HF3 notes name. 2026.4.1.26 fixed the seven November 10 CVEs and left the Legacy API in place. Anything earlier than 2026.4.1.39 is not the current fix. The November 10 records say "before 26.4.1" for six of the seven and "before 2026.4.1" for CVE-2026-91000. N-able does not explain the two writings.
2. **Hosted.** N-able's 01:04:27 UTC update on 2026-11-11 says every hosted server, in every region, has been upgraded. Agents and Probes are still the customer's to upgrade.
3. **What the scanning looks like.** N-able does not publish the proof of concept. The questions that match what the server can do are: a new administrator, a script or software job you did not schedule, a remote-control session you did not start, and a configuration import you did not run. Absence of those is not proof the server was not entered.
4. **The November 12 miner.** Huntback publishes these indicators for the campaign it observed. A match is a reason to treat the server as fully compromised. Absence is not a clean bill.
   - Files: `/tmp/.xvd/` or `/var/tmp/.xvd/`, a `serverchild-*.bak` in `/var/opt/n-central/tmp/`, or a symlink at `/var/opt/n-central/flag/flag_default.json`.
   - Persistence: `/etc/systemd/system/xvd.service`, `/etc/cron.d/xvd`, or a crontab line ending `# xvkeep`.
   - A process whose command line contains `--rig-id nc_`, or outbound connections to `157.20.241.16` (port 8080, or TCP 19202 through 19418), `139.99.69.109:10128`, or `79.76.51.56:39100`.
   - POSTs to `/dms/services/ServerUI` whose body is a SOAP fault naming `jline.internal.TerminalLineSettings`.

## Remediation

1. **On premises, upgrade the server to 2026.4.1.40.** HF4's notes say it supersedes 2026.4.1.39, turns remote control and the Intune integration back on, and updates the Java package for CVE-2026-114938. HF3's removal of the Legacy API stays in place. The download is [SD-000146](https://me.n-able.com/s/softwaredownloads/a9jVy0000000LZ7IAM/sd-000146). N-able says a CMMC build of HF4 is not ready, so a CMMC account stays on the earlier guidance.
2. **Upgrade Agents before Probes, and both to 2026.4.1.40.** HF4 says a device that has not moved is the remaining exposure. Hosted and on-premises customers both do this. Also move the Patch Management Engine to 2.14.4.5829 or later: [CVE-2026-129271](https://www.cve.org/CVERecord?id=CVE-2026-129271) names that component version, not the server build. HF3's notes say an Agent or Probe that is not upgraded can still be impersonated, and CVE-2026-129272 is that impersonation, scored 9.3. A Probe on the new build stops talking to an Agent or Patch Management Engine that is still older, and the offline patch cache stops with it. An older Probe keeps talking to a newer Agent, so the Agent can move first.
3. **Hosted servers are upgraded by N-able.** HF3's notes say an NCOD customer does not upgrade the server. Agents and Probes still have to move.
4. **HF4 turns remote control and Intune back on.** That is the change HF3 had left blocked. N-able's November 16 blog still says data-leakage issues that need an already-privileged account are open; HF4's notes do not say those are fixed.
5. **Take Control still works.** Built-in remote control does not. Plan around that.

## Verification

- The server reports 2026.4.1.39, it was not reachable from the network during the upgrade, and the Intune integration is off. HF3 removes the Legacy API setting.
- Agents report 2026.4.1.39 before the Probes do. A Probe and an Agent on 2026.4.1.39 can still use the offline patch cache.
- A machine that should be managed still checks in. Do not replay the proof of concept.

## Compromise response

N-able's earlier updates said it had not seen an environment compromised. Incident 202584 says scanning is being observed and does not repeat that sentence. Incident 202613 said at 16:00 UTC on November 12 that N-able had seen no signs of compromise, and at 03:50:42 UTC on November 13 that it had found indicators of compromise and is working with those customers. That update does not say how many servers, whether they were hosted or on premises, or what was found. Huntback's report is separate: 21 servers it identified from a mining pool, 19 of them on 2026.4.1.26. None of these statements inspects one particular server. A server with any indicator above was root-owned, and the upgrade does not remove a miner or undo a script that already ran.

- Review administrator accounts, script and software jobs, remote-control sessions, and configuration changes from November 8 onward.
- Rotate a credential stored in N-central if that review finds a change you did not make. [CVE-2026-129275](https://www.cve.org/CVERecord?id=CVE-2026-129275) let anyone who knew a policy identifier download an Automation Manager policy, including embedded scripts and parameter values, so treat a secret stored in a policy on a server that was exposed before HF3 as disclosed.
- Do not trust Take Control audit records from before the upgrade. [CVE-2026-129278](https://www.cve.org/CVERecord?id=CVE-2026-129278) let a request with no login alter them.
- The upgrade does not undo a script or a remote session that already ran.

## Sources

- [N-able status, incident 202584][event] — reread 2026-11-12. Start 14:00:00 UTC, status Monitoring. At 01:04:27 UTC on 2026-11-11 every hosted server, all regions, was upgraded. Scanning observed. On-premises servers stay offline until their own upgrade succeeds. Follow-up hotfix still planned. Lists the seven CVEs.
- [N-able status, incident 202609][event2] — read 2026-11-12. Start 2026-11-12 00:00:00 MST, status Investigating. Claims of more flaws in on-premises 2026.4.1 HF2. N-able's initial review: the server issue needs Legacy API on and exposed to the internet. Hosted is not affected. No CVE and no newer build on that page.
- [N-able status, incident 202613][event3] — reread 2026-11-13. Start 2026-11-12 16:00:00 UTC, status Identified. N-able turned the Intune integration off on hosted servers and, where it could, on on-premises servers. The 16:00 UTC update said no signs of compromise. The 03:50:42 UTC update on 2026-11-13 says N-able identified indicators of compromise and is working with those customers. No newer build.
- [Release notes, HF2][notes] — posted November 10, 2026. Build 2026.4.1.26. The seven CVEs, the Agent and Probe order, the supported upgrade paths, and the disabled built-in remote control.
- [Release notes, HF4][hf4] — posted November 21, 2026, 12:59. Build 2026.4.1.40. Supersedes HF3. Turns remote control and Intune back on. Updates Java for CVE-2026-114938. Says a CMMC build is not ready. Download [SD-000146](https://me.n-able.com/s/softwaredownloads/a9jVy0000000LZ7IAM/sd-000146).
- [Release notes, HF3][hf3] — posted November 16, 2026. Build 2026.4.1.39. Supersedes HF2. Permanently removes the Legacy API. Says Agents and Probes that are not upgraded can be impersonated. Lists CVE-2026-129271 through CVE-2026-129287. Remote control other than Take Control stays disabled, and the Intune integration stays blocked. Download [SD-000145](https://me.n-able.com/s/softwaredownloads/a9jVy0000000LXVIA2/sd-000145).
- [CVE-2026-129272](https://www.cve.org/CVERecord?id=CVE-2026-129272), [CVE-2026-129280](https://www.cve.org/CVERecord?id=CVE-2026-129280), [CVE-2026-129286](https://www.cve.org/CVERecord?id=CVE-2026-129286), and CVE-2026-129271, CVE-2026-129273 through CVE-2026-129279, CVE-2026-129281 through CVE-2026-129285, and CVE-2026-129287 — N-able, published 2026-11-17 between 11:44 and 11:48 UTC. Scores in the summary above. Each record links an advisory on `me.n-able.com` that requires a login.
- [Huntress, November 17](https://www.huntress.com/blog/n-able-disables-cloud-services-following-disclosure-of-able2shell-exploit-chains) — says public proof-of-concept code for all seventeen appeared the evening of November 16, and that Huntress has not observed exploitation of them in partner environments. The 9.3, 9.3, and 9.2 scores it repeats are N-able's.
- [N-able remediation update](https://www.n-able.com/blog/n-able-vulnerability-remediation-update) — updated November 16, 2026, 5 pm EST. Says HF3 resolves the authenticated-access vulnerabilities from the first publication and hardens Agent and Probe authentication. Says the data-leakage issues that need a privileged account are still open.
- [CVE-2026-125883](https://www.cve.org/CVERecord?id=CVE-2026-125883), [CVE-2026-125881](https://www.cve.org/CVERecord?id=CVE-2026-125881), [CVE-2026-125878](https://www.cve.org/CVERecord?id=CVE-2026-125878), [CVE-2026-125879](https://www.cve.org/CVERecord?id=CVE-2026-125879), [CVE-2026-125882](https://www.cve.org/CVERecord?id=CVE-2026-125882), [CVE-2026-91000](https://www.cve.org/CVERecord?id=CVE-2026-91000), [CVE-2026-125880](https://www.cve.org/CVERecord?id=CVE-2026-125880) — N-able, published 2026-11-10. Scores in the summary above.
- [BleepingComputer][bc] — the Able2Shell publication and the pre-release build 2026.4.0.31 the researcher tested.
- [The Hacker News](https://thehackernews.com/2026/11/new-n-central-exploits-work-against.html) — November 12. Quotes incident 202609 and attributes probing from 157.20.241.16 to Previdian. Its November 13 follow-up reports the Huntback finding of 21 compromised servers.
- [Huntback][huntback] — read 2026-11-13. 21 production servers mining at 12:50 UTC on 2026-11-12, 19 of them on 2026.4.1.26. Indicators in Detection.
- [Previdian VULN-2026-0009](https://previdian.com/VULN-2026-0009) — read 2026-11-13. Two exploitation attempts against its own sensor, first observed 2026-11-12. Its own CVSS 9.8. Not a compromised customer.
- [CVE-2026-90436](https://www.cve.org/CVERecord?id=CVE-2026-90436) — Apache CNA, published 2026-11-06. Axis 1.x through 1.4, unsupported when assigned, no numeric score from Apache. The CISA-ADP score is 9.8.
- [BleepingComputer, November 12](https://www.bleepingcomputer.com/news/security/new-n-able-4everable2shell-zero-day-exploited-hours-after-poc-released/) — reports both firms. The researcher names and the proof of concept are the researcher's, not N-able's.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, released 2026-11-18T19:17:41.0354Z. CVE-2026-90436 added 2026-11-18, due 2026-11-21. Forensic triage Yes. None of the seven and none of the seventeen is listed.

[event]: https://uptime.n-able.com/event/202584
[event2]: https://uptime.n-able.com/event/202609
[event3]: https://uptime.n-able.com/event/202613
[status]: https://uptime.n-able.com/
[notes]: https://status.n-able.com/2026/11/10/n-central-2026-4-hf2-release-notes/
[hf3]: https://status.n-able.com/2026/11/16/n-central-2026-4-hf3-release-notes/
[hf4]: https://status.n-able.com/2026/11/21/n-central-2026-4-hf4-release-notes/
[bc]: https://www.bleepingcomputer.com/news/security/n-able-takes-cloud-platform-offline-after-30-plus-zero-days-published/
[huntback]: https://huntback.io/blog/ncentral-4everable2shell-miners-on-live-servers
