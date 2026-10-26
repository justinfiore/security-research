# Supermicro BMC firmware: IPMI and RMCP+ session flaws can lead to BMC administrator access

**Last updated:** 2026-10-26 (America/New_York)

[Main Supermicro BMC summary](../black-october-2026.md#supermicro-bmc-firmware-ipmi-and-rmcp-session-flaws-can-lead-to-bmc-administrator-access) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Eight CVEs in Supermicro baseboard management controller (BMC) firmware, reported by runZero. The top issue, [CVE-2026-18450](https://www.cve.org/CVERecord?id=CVE-2026-18450), is Critical 9.8 according to Supermicro but High 8.1 according to runZero. Four more are High. None is in CISA KEV.** Supermicro's advisory of 2026-10-26 lists the CVEs with CVSS 3.1 scores and lists fixed BMC firmware for 402 board SKUs. Two SKUs show the fix as "TBD", and the table lists no X9 or X10 boards, although runZero observed some of the flaws on X9 and X10. All eight CVE records are still **RESERVED** (not published) at CVE.org, and NVD has no entries. The CVE.org links below therefore do not yet resolve to published records. [Supermicro][smc] [runZero blog][blog]

The two sources agree on every score except CVE-2026-18450:

| CVE | Supermicro CVSS 3.1 | runZero CVSS 3.1 | What an attacker needs | Worst case (per runZero unless noted) | Generations runZero lists |
|---|---|---|---|---|---|
| [CVE-2026-18450](https://www.cve.org/CVERecord?id=CVE-2026-18450) — unprotected IPMI commands accepted on active RMCP+ sessions | **9.8 Critical** (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H) | **8.1 High** (AV:N/**AC:H**/PR:N/UI:N/S:U/C:H/I:H/A:H) | Network access to UDP 623 and the ID of a live RMCP+ session, which an on-path observer can see. runZero's AC:H reflects that need. It calls guessing predictable IDs off-path "not firmly established", and Supermicro disputed that impact. | Injects unsigned, unencrypted IPMI commands that run at the privilege of the hijacked session (CWE-306). Supermicro: "execute arbitrary commands on an active session". | X9 (X9DRT-HF), X10, X11, X12 (X12SPI), H13, X13 (2401MS). runZero: BMCs "prior to X14". |
| [CVE-2026-65220](https://www.cve.org/CVERecord?id=CVE-2026-65220) — RAKP role-byte privilege escalation | 8.8 High (AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H) | 8.8 High (same) | Credentials for any enabled low-privilege IPMI account with LAN IPMI messaging, plus an enabled Administrator account | A session raised to **Administrator** (users, power, boot, OEM commands). The attacker can also promote their own account permanently. | X10DSC+, X11DPT-PS, H13 (F401MS; exact level unconfirmed). X13 2401MS firmware is listed as affected but not confirmed on hardware. |
| [CVE-2026-18449](https://www.cve.org/CVERecord?id=CVE-2026-18449) — SMCRAKP hard-coded key | 7.5 High (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N) | 7.5 High (same) | Optional **SMCRAKP** mode enabled (it is off by default) and the username of an enabled account | On ATEN-based firmware (X10–X13, H13): administrative IPMI access without the password. On X14, the handshake completes but commands are rejected; RAKP Message 4 still gives an offline password-verification value. Supermicro describes the issue as allowing an attacker to "crack a password hash". | X10, X11, X12 (X12SPI), H13 (F401MS, E401MS), X13 (2401MS, C301MS), X14 (5601MS) |
| [CVE-2026-65219](https://www.cve.org/CVERecord?id=CVE-2026-65219) — out-of-order RAKP Message 3 | 7.4 High (AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:N) | 7.4 High (same) | UDP 623 and the stored password of the empty-username user record 0: a single character on the observed X11DPT-PS, empty on the H13. With SMCRAKP enabled, the fixed key replaces that password. | No password needed for a **restricted** IPMI session that can activate **Serial-over-LAN**, the host's serial console (BIOS, boot loader, OS serial login). It does not give the full administrative command set. | X11DPT-PS (4101MS), H13 (F401MS). Not X14 (5601MS 01.06.07). It gives nothing extra on X10DSC+. |
| [CVE-2026-65211](https://www.cve.org/CVERecord?id=CVE-2026-65211) — OEM command reads and writes physical memory | 7.2 High (AV:N/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:H) | 7.2 High (same) | An IPMI Administrator session, which CVE-2026-18449 or CVE-2026-65220 can supply | Arbitrary read/write of BMC physical memory, even with **System Lockdown** on. That means code execution and persistent control of the BMC, and disclosure of resident cleartext passwords. | X13 (2401MS) |
| [CVE-2026-65213](https://www.cve.org/CVERecord?id=CVE-2026-65213) — X14 file-apply command injection | 6.6 Medium (AC:H/PR:H; Supermicro's vector string is printed as `CVSS:3.1:/AV:N/...`) | 6.6 Medium | IPMI Administrator | Root command execution on the BMC | X14 (5601MS) |
| [CVE-2026-65210](https://www.cve.org/CVERecord?id=CVE-2026-65210) — OEM file read | 4.9 Medium (AV:N/AC:L/PR:H/UI:N/S:U/C:H/I:N/A:N) | 4.9 Medium | IPMI Administrator | Reads any BMC file: `/etc/shadow`, SSH host private keys, and the stored configuration, whose account passwords are protected only by a firmware-static AES key | X13 (2401MS), H13SSF (E401MS) |
| [CVE-2026-18451](https://www.cve.org/CVERecord?id=CVE-2026-18451) — time-seeded HTML5 KVM token | 3.1 Low (AV:N/AC:H/PR:N/UI:R/S:U/C:L/I:N/A:N) | 3.1 Low | A live administrator iKVM session and an estimate of when it was opened | Takes over that console session (keyboard, video, mouse, media redirection) | X13 (2401MS). runZero's summary says BMCs "prior to X14". |

**Worst case:** the flaws chain. An attacker who can reach UDP 623 and holds any low-privilege IPMI account can become Administrator (CVE-2026-65220). Where SMCRAKP is enabled, the account password is not needed at all (CVE-2026-18449). From Administrator, the attacker can then read BMC files and credentials (CVE-2026-65210) or write BMC memory for persistent control (CVE-2026-65211, X13) or root command execution (CVE-2026-65213, X14). BMC control includes power, boot, console, virtual media and user administration for the host. runZero notes that these OEM paths depend on compatible firmware. Supermicro's advisory does not map each CVE to individual boards. runZero found the issues "with the help of AI tools" and confirmed them on the hardware and firmware named above. Its blog separately lists other leads it could **not** reproduce on real hardware. This guide does not treat those as vulnerabilities.

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Supermicro says it "is not aware of any malicious use of these vulnerabilities in the wild", and runZero reports no exploitation; runZero's public advisories include enough protocol detail to reproduce several issues. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory boards and firmware](#inventory-boards-and-firmware)
  - [Fixed firmware by board family](#fixed-firmware-by-board-family)
  - [Exposure and configuration](#exposure-and-configuration)
  - [Logs and network indicators](#logs-and-network-indicators)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| runZero discovery | 2026-07-18 (CVE-2026-18450, CVE-2026-18451); 2026-07-28 (CVE-2026-65219); 2026-07-29 (CVE-2026-65220); 2026-08-12 (CVE-2026-65210, CVE-2026-65211); 2026-08-22 (CVE-2026-65213); time/TZ unknown | "Initial findings discovered and documented" in each runZero advisory. The CVE-2026-18449 advisory gives no timeline, so its discovery date is **unknown**. [runZero advisories][adv] |
| CVE IDs reserved by runZero | 2026-07-21 (time/TZ unknown) | Per runZero, CVE-2026-65210, -65211, -65213, -65219 and -65220 were reserved, plus -65216 and -65218, which were later replaced. Several advisories list this reservation before their stated discovery date, and this guide reproduces those dates as published. |
| Supermicro notified | 2026-07-24 (CVE-2026-18450, CVE-2026-18451); 2026-07-31 (CVE-2026-65219, CVE-2026-65220); 2026-08-27 (CVE-2026-65210, CVE-2026-65211, CVE-2026-65213); time/TZ unknown | runZero advisory timelines |
| Supermicro reserves CVE-2026-18450 and CVE-2026-18451 | 2026-08-06 (time/TZ unknown) | These replace runZero's CVE-2026-65216 and CVE-2026-65218. [CVE-2026-18450 advisory][a18450] [CVE-2026-18451 advisory][a18451] |
| CVE record management transferred to Supermicro | 2026-10-23 (time/TZ unknown) | For CVE-2026-65210, -65211, -65213, -65219 and -65220 (runZero timelines) |
| **Public announcement**: runZero "Lights Out" update and advisories | 2026-10-26 09:00 EDT (13:00 UTC) | Blog update and each advisory are stamped "Updated October 26, 2026, 9:00am EDT". The advisory page metadata shows `2026-10-26T09:00:00-04:00`. [Blog][blog] |
| Supermicro advisory, version 1.0 "First issuance" | 2026-10-26 (time/TZ unknown) | Lists fixed BMC firmware per board, with two SKUs "TBD". Supermicro says it "is currently testing and validating affected products", so confirm availability on each board's download page. [Supermicro][smc] |
| CVE records | Not published as of 2026-10-26 | The CVE Services ID lookup returns state `RESERVED` for all eight. The record API returns "CVE_RECORD_DNE", and the NVD API returns no results. [CVE ID lookup][cveid] [NVD][nvd] |
| CISA KEV | Not listed as of catalog 2026.10.23 (checked 2026-10-26) | [KEV JSON][kev] |

## Detection

### Inventory boards and firmware

1. Find every Supermicro server, blade, multi-node, edge system, switch (SSE-) and chassis management module (CMM). Your asset system may record only the chassis model, so get the **motherboard model** too. From the host OS, `sudo dmidecode -t baseboard` reports the board's "Product Name" (read-only). The BMC web dashboard also shows the board model and the BMC firmware version. [X13/H13/B13 BMC manual][manual]
2. Read the full BMC firmware version from the web UI dashboard (or Component Info), or with an authenticated Redfish GET of `/redfish/v1/Managers/1` (the standard `FirmwareVersion` property). From the host, `sudo ipmitool mc info` shows a "Firmware Revision" through the local in-band interface. That value may show only major.minor (for example `1.74`), which is not enough to compare against fixes such as 01.74.26. These commands only read; this guide did not run them against real hardware.
3. Compare each board with the [fixed-firmware summary below](#fixed-firmware-by-board-family). Then look up the exact SKU in [Supermicro's advisory table][smc], which is the authority.
4. Treat as **not fixed**: any board whose version is below its row; the two "TBD" SKUs; and any board absent from the table. That includes X9 and X10, which runZero observed as affected by CVE-2026-18450 (X9, X10), CVE-2026-18449 (X10) and CVE-2026-65220 (X10DSC+).

### Fixed firmware by board family

This is a summary of Supermicro's 402-row table (one row per board SKU), grouped by board family by this guide. Version numbers are per SKU, so a family range does not tell you the fix for your board. Use the [vendor table][smc] for the exact value.

| Family (board prefix) | SKUs listed | Fixed BMC firmware in the vendor table |
|---|---|---|
| X14 | 57 | 01.00.21.08 – 01.12.04.00 (four-part versions, e.g. 01.07.20.00, 01.11.06.01, 01.12.04.00) |
| X13 | 49 | 01.03.10 – 01.14.07. **MBD-X13SEW-TF-OS1: TBD** |
| X12 | 69 | 1.07.05 – 01.16.01 (e.g. X12SDV 01.11.07, X12ST* 01.06.18, many X12SP*/X12DP* 01.07.2x–01.08.2x). **MBD-X12DGU: TBD** |
| X11, including C9X299 | 108 | 01.74.26 (68), 03.75.35 (26), 03.78.08 (11), 01.74.13 (X11OPi-CPU, -CL), 01.02.04 (X11DPFF-SNR) |
| H14 | 12 | 01.07.01.06 – 01.11.04.05 |
| H13 | 21 | 01.05.08 – 01.13.18 |
| H12 | 23 | 01.04.13 – 01.11.11, but **03.10.51** for eight SKUs (H12SSW-NT/-NTR/-NTL/-iN/-iNL, H12DST-B, H12SST-PS, H12DSU-iN) |
| H11 | 9 | 01.52.26 |
| M11SDV / M12SWA | 5 / 1 | 03.17.07 / 01.06.34 |
| A3 | 9 | 01.05.34 or 01.08.09 |
| Blade and multi-node boards (B12, BH12, B13, B14, B3, B4, BH4) | 20 | 01.07.07.01 – 01.16.01 |
| G1/G2 boards | 4 | 01.14.07 (G1), 01.11.04.05 (G2DMH-GI) |
| R12SPD / R13SPD | 3 | 51.05.11.00 |
| SSE-T switches | 10 | 01.00.09 (T7132 models), 01.04.18 (T8164/T8196 models) |
| CMM-6 (MBB-/MBM-) | 2 | 01.04.07 |
| X9, X10 | **0** | **No fix listed.** runZero observed CVE-2026-18450, -18449 and -65220 on these generations. |

### Exposure and configuration

- **IPMI over LAN (UDP 623):** on X13/H13/B13 firmware, Supermicro's manual lists "IPMI LAN Port: ON (623)" by default, and both IPv4 and IPv6 are enabled by default. Every network CVE here except CVE-2026-18451 needs UDP 623. Find out which networks can reach each BMC address, over IPv4 and IPv6. The BMC LAN selection defaults to **Failover**: the BMC uses the dedicated port when it is connected and otherwise answers on the **shared host NIC**, which can put it on a production network. [Manual][manual] [Feature guide][feature]
- For an opt-in reachability check from a non-management segment against your own BMC addresses, `nmap -sU -p 623 --script ipmi-version <bmc-ip>` sends one standard, unauthenticated IPMI "Get Channel Authentication Capabilities" request and reports whether IPMI answers. It does not log in or exploit anything. **Do not** run credential, RAKP-hash or vulnerability checks against production BMCs. runZero's [oobscan][oobscan] tool includes default-credential and RAKP-hash features, and runZero suggests it for test gear.
- Also note TCP 623 (virtual media), the web UI on 80/443 (it serves the HTML5 KVM involved in CVE-2026-18451), SSH on 22 and KVM on 5900. Supermicro's long-standing guidance is to keep BMCs on an isolated management network, not the internet. [Best practices][bp]
- **SMCRAKP:** check whether it is enabled. CVE-2026-18449 applies only when it is. The setting is under Configuration → BMC Settings → SMC RAKP in the web UI, and Redfish exposes `/redfish/v1/Managers/1/Oem/Supermicro/SMCRAKP` (Supermicro documents the PATCH form that sets `Mode`). [Manual][manual] [Redfish guide][redfish]
- **Accounts:** list IPMI users (web UI, or `sudo ipmitool user list 1` from the host, which only reads). Note every enabled non-Administrator account, because CVE-2026-65220 needs only one of them. Note also whether monitoring tools keep RMCP+ sessions open, since CVE-2026-18450 needs a live session.

### Logs and network indicators

Supermicro and runZero published **no IoCs**. Treat the following as hunting ideas, not signatures.

- In the BMC's maintenance and health event logs, and in any syslog the BMC forwards, look for user creation, privilege or password changes, LAN or channel configuration changes, SOL or KVM activation, configuration restores and firmware updates that nobody can account for.
- In flow logs and firewalls, look for UDP 623 traffic to BMCs from anything other than your management hosts.
- With full packet capture on the management network, the advisories describe traffic that should be rare. This guide derived these from runZero's technical write-ups and has not tested them as detections:
  - RMCP+ session packets with both the "authenticated" and "encrypted" payload bits clear on sessions that negotiated cipher suite 3 or 17 (CVE-2026-18450). Legitimate cipher-suite-0 sessions also clear these bits.
  - RAKP Message 3 (payload type 0x14) with no preceding RAKP Message 1 (0x12) for the session (CVE-2026-65219).
  - RAKP Message 1 with a requested-role byte whose upper nibble is 0x2–0xF (CVE-2026-65220).
  - Use of OEM NetFn 0x30 command 0xAE with sub-commands 0x2E or 0x22 (CVE-2026-65210, CVE-2026-65211).
- A clean review proves little. BMC logs are small and local, an Administrator-level attacker can change them, and many sites capture no IPMI traffic. Treat a BMC that ran affected firmware with UDP 623 reachable from untrusted networks as **unknown**, not clean.

## Remediation

1. **Update BMC firmware** to at least the version in Supermicro's table for your exact board, using the firmware on that board's Supermicro download page and its release notes. Supermicro says "all affected Supermicro motherboard SKUs will require a BMC update", and also that it is still testing and validating products. If the listed version is not yet downloadable, contact Supermicro support. You can update through the BMC web UI (Maintenance → Firmware Management) or Supermicro Update Manager (`sum ... -c UpdateBmc`). **System Lockdown blocks firmware updates**, so it must be turned off for the update and back on afterwards. The BMC restarts, which interrupts remote console and monitoring but not the host OS. Back up the BMC configuration first, and update only from images you downloaded from Supermicro. [Supermicro][smc] [Manual][manual]
2. **Isolate BMC networks now**, whatever your patch status. Put BMCs on a dedicated management VLAN or network that only jump hosts and management servers can reach, never on the internet. Set the LAN selection to **Dedicated** where a dedicated port exists, so the BMC cannot fail over onto a shared production NIC. Use the BMC's **IP Access Control** to accept only management addresses. Block UDP 623 at network boundaries, over IPv6 too. [Best practices][bp]
3. **Disable IPMI over LAN where you do not use it**: Configuration → Network → Port → IPMI LAN Port (UDP 623). This removes the network path for every RMCP+ issue here. It also disables **Serial-over-LAN**, and it breaks tools that talk IPMI over the network: `ipmitool -I lanplus`, IPMIView, SUM or SSM in IPMI mode, and IPMI-based monitoring. The web UI and Redfish keep working. Test this on one unit first. [Manual][manual]
4. **Reduce the remaining preconditions until patched:**
   - Disable SMCRAKP if it is enabled (CVE-2026-18449). This brings back the standard IPMI 2.0 RAKP behavior that discloses password hashes, so use long, unique BMC passwords.
   - Remove or disable unneeded low-privilege IPMI accounts (CVE-2026-65220).
   - Keep IPMI monitoring sessions on the isolated network (CVE-2026-18450).
   - Close iKVM sessions when you finish with them (CVE-2026-18451).
5. **Unfixed boards** (X12DGU, X13SEW-TF-OS1, X9, X10 and anything else not in the table): apply steps 2–4, ask Supermicro for a fix or support status, and plan replacement where no fix will come. This guide found no Supermicro statement about X9/X10 support status.
6. Each of these settings **changes state** and can cut off remote management. Before you change one, confirm you still have another way in: console access, the dedicated port, or hands on site.

## Verification

- Re-read the BMC firmware version (web UI or Redfish) on every node, including each node of multi-node and blade systems, and confirm it is at or above the vendor table value for that SKU.
- From a non-management host, confirm UDP 623 (IPv4 and IPv6), TCP 623 and the web UI do not answer where you restricted them. From the management network, confirm normal administration still works.
- Confirm SMCRAKP, IPMI LAN Port and IP Access Control are set as you intended, and that the IPMI user list contains only expected accounts.
- Do not send RAKP, session-injection or OEM-command test packets to production BMCs, and do not run public exploit or proof-of-concept code against them.

## Compromise response

- If you find unexplained BMC activity, preserve the BMC event logs, forwarded syslog, a configuration backup and any packet capture before you change anything. Escalate to Supermicro support or an incident-response provider. A compromised BMC survives host OS reinstallation.
- **Rotate credentials.** CVE-2026-65210 exposes `/etc/shadow`, the SSH host private keys and the stored configuration, whose account passwords runZero says are protected only by a firmware-static AES key. CVE-2026-65211 exposes cleartext passwords in memory. Change every BMC account password, and every other system that reused one of them. Also change the LDAP/AD, RADIUS, SNMPv3 and SMTP credentials configured on the BMC. Replace the BMC's TLS certificate and, where possible, its SSH host keys.
- **Rebuild the BMC from trusted firmware.** Memory-write or root access (CVE-2026-65211, CVE-2026-65213) can give persistent control. Reflash fixed firmware obtained from Supermicro, restore only a reviewed configuration (or reconfigure from factory defaults), and recreate accounts. If you cannot establish the BMC's integrity, ask Supermicro about recovery or board replacement.
- **Investigate the host.** An attacker with Administrator or SOL access could have changed boot settings, mounted virtual media, used the serial console, or, through BMC drive passthrough, reached host storage outside the OS. Review the host's boot configuration, BIOS settings and OS integrity, and hunt for lateral movement from BMC addresses.

## Sources

- [Supermicro advisory, BMC firmware, October 26, 2026 (1)][smc] — CVE list, Supermicro CVSS 3.1 scores and vectors, the per-board fixed-firmware table (402 SKUs, two TBD), the remediation statement, "not aware of any malicious use", and version 1.0 dated 2026-10-26.
- [runZero, "Lights Out: The server in your server, exposed and disclosed"][blog] — 2026-10-26 09:00 EDT update. Covers the chaining summary, runZero's 8.1 rating for CVE-2026-18450, findings it could not reproduce and functionality Supermicro calls intended, and detection guidance.
- runZero advisories: [CVE-2026-18450][a18450], [CVE-2026-18449][a18449], [CVE-2026-65219][a65219], [CVE-2026-65220][a65220], [CVE-2026-65210][a65210], [CVE-2026-65211][a65211], [CVE-2026-65213][a65213], [CVE-2026-18451][a18451] — vectors, affected firmware observed, preconditions and timelines.
- [CVE Services ID lookup (example: CVE-2026-18450)][cveid] and [NVD API][nvd] — all eight are RESERVED and unpublished, and NVD has no entries (checked 2026-10-26).
- [CISA KEV JSON feed][kev] — none listed (catalog 2026.10.23).
- Supermicro documentation: [X13/H13/B13 BMC user manual][manual] (default ports, LAN selection, SMC RAKP, System Lockdown, firmware update), [Redfish configuration examples][redfish] (SMCRAKP, IP Access Control), [BMC security best practices][bp] and the [BMC firmware security feature guide][feature].
- [runZero oobscan][oobscan] — active scanning tool. It was not reviewed in depth or run for this guide.

[smc]: https://www.supermicro.com/en/support/security_BMC_IPMI_Oct_2026_1
[blog]: https://www.runzero.com/blog/lights-out-exposed/
[adv]: https://www.runzero.com/advisories
[a18450]: https://www.runzero.com/advisories/smc-ipmi-auth-bypass-cve-2026-18450/
[a18449]: https://www.runzero.com/advisories/smc-rakp-key-cve-2026-18449/
[a65219]: https://www.runzero.com/advisories/smc-rakp-bypass-cve-2026-65219/
[a65220]: https://www.runzero.com/advisories/smc-priv-esc-cve-2026-65220/
[a65210]: https://www.runzero.com/advisories/smc-fileread-cve-2026-65210/
[a65211]: https://www.runzero.com/advisories/smc-memaccess-cve-2026-65211/
[a65213]: https://www.runzero.com/advisories/smc-cmdinj-cve-2026-65213/
[a18451]: https://www.runzero.com/advisories/smc-kvm-token-cve-2026-18451/
[cveid]: https://cveawg.mitre.org/api/cve-id/CVE-2026-18450
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-18450
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[manual]: https://www.supermicro.com/manuals/other/BMC_IPMI_X13_H13_B13.pdf
[redfish]: https://www.supermicro.com/manuals/other/redfish-user-guide-4-0/Content/general-content/bmc-configuration-examples.htm
[bp]: https://www.supermicro.com/products/nfo/files/IPMI/Best_Practices_BMC_Security.pdf
[feature]: https://www.supermicro.com/products/nfo/files/IPMI/BMC_Server_Management_Feature_Guide.pdf
[oobscan]: https://github.com/runZeroInc/oobscan
