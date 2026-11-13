# Check Point Gaia: a local socket runs a command as root

**Last updated:** 2026-11-12 (America/New_York)

[Back to Check Point summary](../black-october-2026.md#check-point-gaia-a-local-socket-runs-a-command-as-root) · [Changelog](../../CHANGELOG.md)

Gaia is the operating system on Check Point's security gateways and management servers. [CVE-2026-123039](https://www.cve.org/CVERecord?id=CVE-2026-123039) is a local privilege escalation: a process already running on the appliance sends one request to a world-writable socket, and the root daemon runs it.

**Check Point rates CVE-2026-123039 CVSS 3.1 7.8 High.** The vector is `CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. The Gaia Dynamic CLI daemon, `dynamic_server`, listens on `/tmp/dynamic_socket`. On affected products the socket is created mode `0777` and the daemon does not check who connected, so it runs the command string it receives as root. The attack needs code already running on the appliance. Check Point says it observed an active exploit against a couple of dozen customers.

Check Point's [November 12 advisory][blog] says the observed attacks chained this with [PHP2Shell](php2shell.md). Initial access was the Mobile Access Portal, and the socket was the step to root. That activity ran from October 30 through November 4. The first wave, on October 30, targeted Israeli organizations and included destructive activity. A second wave on November 2 targeted organizations in more than one country, and Check Point found no destructive activity in that wave. Check Point says the PHP2Shell fix had been available since October 23, a week before the first wave, and that affected customers were notified the day the investigation started.

The same advisory lists two more flaws that are not this one. [CVE-2026-107484](https://www.cve.org/CVERecord?id=CVE-2026-107484) is 7.3, a privilege escalation in the Gaia Portal backend by an authenticated user, and Check Point marks it not exploited. [CVE-2026-120490](https://www.cve.org/CVERecord?id=CVE-2026-120490) is 3.8 and is below the line this collection tracks.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-12). Check Point reports exploitation of its own. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| PHP2Shell hotfix available | 2026-10-23; time unknown | Check Point says the security fix for the gateway and management was available a week before the attack. [Advisory][blog] |
| First exploitation wave | 2026-10-30; time unknown | Scanning and exploitation from 130.94.19[.]204 against Mobile Access portals, then the local socket. Israeli organizations, with destructive activity in some cases. [Research][research] |
| Second wave | 2026-11-02; time unknown | Organizations in more than one country. Check Point reports no destructive activity in this wave. Activity continued until November 4. [Advisory][blog] |
| SK created | 2026-11-08; time unknown | sk1000362, last modified 2026-11-12. [SK][sk] |
| **Public announcement** | **2026-11-12; time unknown** | The CVE record and the research post. Check Point gives no time. [Record][cve] |
| **Last updated** | **2026-11-12 (America/New_York)** | New item. |

## Detection

1. **Which appliance.** Affected products are Check Point Force firewalls, management and log servers, Multi-Domain Security Management and Multi-Domain Log Server, and Maestro Orchestrator, on R82.20, R82.10, R82, R81.20, R81.10, and R81. Spark firewalls and Smart-1 Cloud are not affected. R81 and R81.10 are end of support.
2. **The socket.** In Expert mode, `ls -l /tmp/dynamic_socket`. A fixed appliance shows `srw-rw----` owned by `root` and group `config` (mode `0660`). Mode `0777` (`srwxrwxrwx`) is the vulnerable socket.
3. **The PHP2Shell chain.** Check Point's research post names these indicators from the investigated intrusion. A match is a reason to investigate, and no match does not clear the appliance.
   - PHP session files under `/opt/CPcvpn-R81.20/tmp/` containing `upload_progress_pwn`, and hundreds of segmentation faults in the portal's Apache and PHP workers.
   - Webshells in the Mobile Access portal template directory, files named `zz*.tpl`, with a hardcoded key `zz2026`, writing uploads to `/tmp/.up.tpl`.
   - A process or binary named `CPconfigdaemon` or `slot_CPconfigdaemon`.
   - Files under `/tmp` or `/temp` with `scanner` or `wiper` in the name, and a note file referencing "Dream Annexation" with no payment demand.
   - Scanning from 130.94.19[.]204 or 130.94.19[.]168.
   - Gaps in firewall traffic logs after the logging daemon crashed.

## Remediation

1. Install the Jumbo Hotfix Accumulator at or above the take Check Point names, and reboot:
   - R82.20, Take 14 or later
   - R82.10, Take 52 or later
   - R82, Take 132 or later
   - R81.20, Take 174 or later

   The CVE record's affected ranges stop one take earlier: R82.20 Take 10 or below, R82.10 Take 50 or below, R82 Take 130 or below, and R81.20 Take 173 or below. Use the SK's floors. Check Point names no Jumbo take for R81 or R81.10, which it marks end of support.
2. The same November Jumbo carries the PHP2Shell fix for the Mobile Access Portal. Install it on every gateway that exposes that portal, not only the ones you know were reached. The PHP2Shell hotfix has its own article, [sk1000302](https://support.checkpoint.com/results/sk/sk1000302), and it requires a reboot.
3. Until the Jumbo is installed, stop `dynamic_server` and keep it from restarting, using the `dbset` commands in [sk1000362][sk]. That disables the Dynamic CLI commands in sk144112. Confirm it stopped with `ps auxw | grep -v grep | grep dynamic_server`. The SK also says how to start it again after the fix.
4. The upgrade does not show whether the socket already ran a command.

## Verification

- `ls -l /tmp/dynamic_socket` shows mode `0660`, not `0777`.
- The installed Jumbo take is at or above the floor for that branch.
- A blocked call is logged. `grep "Rejected connection from unauthorized uid" /var/log/dynamicCli.log` shows the line, and a UID other than the expected one (Check Point's example is 99, `nobody`) is an attempt the fix stopped.
- Do not send a command to the socket to test it.

## Compromise response

Check Point says a couple of dozen unpatched systems in one region were compromised, and that some of the October 30 cases included destructive activity. For an appliance that was internet-facing with the Mobile Access Portal and was below both fixes on October 30:

- Treat it as possibly rooted. The research post describes webshells, a persistent implant (`slot_CPconfigdaemon`, also seen as `CPconfigdaemon`) that steals configuration and tampers with firewall logs, a scanner, and a wiper named `destroy_v6` that overwrites files with zeros before deleting them.
- The post also describes lateral movement from the gateway to a VMware ESXi host over SSH using the `vpxuser` account, with the wiper staged at `/tmp/des`. Review that host, not only the gateway.
- Compare file hashes against the [research post's table][research] rather than trusting a name. Reinstalling the Jumbo does not remove an implant, and it does not restore a file the wiper deleted.
- Rotate credentials the gateway could reach, including the ESXi `vpxuser` account if that host was reachable from it.

## Sources

- [CVE-2026-123039][cve] — Check Point CNA, published 2026-11-12. CVSS 3.1 7.8. Affected Quantum Security Gateway and Quantum Security Management: R82.10 Take 50 or below, R82.20 Take 10 or below, R82 Take 130 or below, R81.20 Take 173 or below.
- [sk1000362][sk] — created 2026-11-08, modified 2026-11-12. The socket, the product list, the Jumbo floors, and the mitigation command. Check Point says it observed an active exploit against a couple of dozen customers.
- [Check Point advisory, November 12, 2026][blog] — the PHP2Shell chain, the October 30 to November 4 window, and the indicators.
- [Check Point Research, PHP2Shell exploitation on Check Point gateway][research] — the two waves, the webshells, the implant, the wiper, and the file hashes.
- [sk1000302](https://support.checkpoint.com/results/sk/sk1000302) — the PHP2Shell hotfix for the gateway web interfaces. Modified 2026-11-11.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-12. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-123039
[sk]: https://support.checkpoint.com/results/sk/sk1000362
[blog]: https://blog.checkpoint.com/security/security-advisory-active-exploitation-of-php2shell-and-local-privilege-escalation
[research]: https://research.checkpoint.com/2026/php2shell-exploitation-on-check-point-gateway/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
