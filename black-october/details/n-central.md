# N-central: critical vulnerabilities, hotfix 2026.4.1.26

**Last updated:** 2026-11-11 (America/New_York)

[Back to N-central summary](../black-october-2026.md#n-central-critical-vulnerabilities-hotfix-20264126) · [Changelog](../../CHANGELOG.md)

N-able released N-central **2026.4 HF2, build 2026.4.1.26**, on November 10. The release notes say it fixes seven CVEs, and N-able's status page says servers should stay offline until the upgrade has succeeded. N-able is now observing scanning that matches the published proof of concept. A follow-up hotfix is still coming.

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

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-10) for any of the seven CVEs. N-able says it is observing scanning associated with the published proof of concept, and its earlier updates said it had not seen an environment compromised. Scanning is not the same statement as a successful intrusion. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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

## Detection

1. **Version.** 2026.4.1.26 is the build the release notes name. Anything earlier, including 2026.4.0.27 and 2026.4.0.32, is not this fix. The CVE records say "before 26.4.1" for six of the seven and "before 2026.4.1" for CVE-2026-91000. N-able does not explain the two writings.
2. **Hosted.** N-able's 01:04:27 UTC update on 2026-11-11 says every hosted server, in every region, has been upgraded. Agents and Probes are still the customer's to upgrade.
3. **What the scanning looks like.** N-able does not publish the proof of concept. The questions that match what the server can do are: a new administrator, a script or software job you did not schedule, a remote-control session you did not start, and a configuration import you did not run. Absence of those is not proof the server was not entered.

## Remediation

1. **On premises, upgrade the server to 2026.4.1.26 while it is still offline, then bring it back.** The download is [SD-000143](https://me.n-able.com/s/softwaredownloads/a9jVy0000000LUHIA2/sd-000143). A CMMC account uses [SD-000144](https://me.n-able.com/s/softwaredownloads/a9jVy0000000LVtIAM/sd-000144). Supported paths are 2025.4, 2026.1, 2026.2, 2026.3, 2026.3.1 HF1 through HF4, 2026.4.0.27, and 2026.4.0.32. Anything older goes to one of those first. N-able's words are to keep the server offline until the upgrade has succeeded.
2. **Upgrade Agents before Probes, and both to 2026.4.1.26.** Hosted and on-premises customers both do this. A Probe on 2026.4.1.26 stops talking to an Agent or Patch Management Engine that is still older, and the offline patch cache stops with it. An older Probe keeps talking to a newer Agent, so the Agent can move first. The updated Patch Management Engine is pushed separately and needs no action.
3. **Hosted servers are upgraded.** The 01:04:27 UTC update on 2026-11-11 says all regions are done. Agents and Probes still have to move.
4. **A follow-up hotfix is still planned.** N-able says it will carry further security updates. 2026.4.1.26 is the build that addresses the most critical November 9 vulnerabilities, not the last build in this response.
5. **Built-in remote control does not work on this build.** Take Control does. Plan around that until N-able says the built-in feature is back.

## Verification

- The server reports 2026.4.1.26, and it was not reachable from the network during the upgrade.
- Agents report 2026.4.1.26 before the Probes do. A Probe and an Agent on 2026.4.1.26 can still use the offline patch cache.
- A machine that should be managed still checks in. Do not replay the proof of concept.

## Compromise response

N-able's earlier updates said it had not seen an environment compromised. The current page says scanning is being observed and does not repeat that sentence. Neither statement inspects one on-premises server.

- Review administrator accounts, script and software jobs, remote-control sessions, and configuration changes from November 8 onward.
- Rotate a credential stored in N-central if that review finds a change you did not make.
- The upgrade does not undo a script or a remote session that already ran.

## Sources

- [N-able status, incident 202584][event] — reread 2026-11-11. Start 14:00:00 UTC, status Monitoring. At 01:04:27 UTC on 2026-11-11 every hosted server, all regions, was upgraded. Scanning observed. On-premises servers stay offline until their own upgrade succeeds. Follow-up hotfix still planned. Lists the seven CVEs.
- [Release notes][notes] — posted November 10, 2026. Build 2026.4.1.26. The seven CVEs, the Agent and Probe order, the supported upgrade paths, and the disabled built-in remote control.
- [CVE-2026-125883](https://www.cve.org/CVERecord?id=CVE-2026-125883), [CVE-2026-125881](https://www.cve.org/CVERecord?id=CVE-2026-125881), [CVE-2026-125878](https://www.cve.org/CVERecord?id=CVE-2026-125878), [CVE-2026-125879](https://www.cve.org/CVERecord?id=CVE-2026-125879), [CVE-2026-125882](https://www.cve.org/CVERecord?id=CVE-2026-125882), [CVE-2026-91000](https://www.cve.org/CVERecord?id=CVE-2026-91000), [CVE-2026-125880](https://www.cve.org/CVERecord?id=CVE-2026-125880) — N-able, published 2026-11-10. Scores in the summary above.
- [BleepingComputer][bc] — the Able2Shell publication and the pre-release build 2026.4.0.31 the researcher tested.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10, checked 2026-11-10. None of the seven is listed.

[event]: https://uptime.n-able.com/event/202584
[status]: https://uptime.n-able.com/
[notes]: https://status.n-able.com/2026/11/10/n-central-2026-4-hf2-release-notes/
[bc]: https://www.bleepingcomputer.com/news/security/n-able-takes-cloud-platform-offline-after-30-plus-zero-days-published/
