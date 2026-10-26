# Vertiv Avocent ACS8000 and ACS800 console servers: unauthenticated root command injection via the wsserver terminal WebSocket

**Last updated:** 2026-10-26 (America/New_York)

[Main Avocent ACS summary](../black-october-2026.md#vertiv-avocent-acs8000-and-acs800-console-servers-unauthenticated-root-command-injection-via-the-wsserver-terminal-websocket) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-65184](https://www.cve.org/CVERecord?id=CVE-2026-65184) — runZero (CNA) CVSS 3.1: 9.8 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H), CWE-78; no Vertiv advisory or score found; NVD has not scored it (status "Received"); not in CISA KEV.** runZero's advisory says the `wsserver` terminal-bridge daemon on Vertiv Avocent ACS8000 console servers runs as **root** and builds a shell command from client-supplied WebSocket fields, which it passes to `system()` and `popen()` without quoting, escaping or character-set validation. The daemon's public-key session path performs no appliance-session check. `wsserver` listens on loopback TCP 2000, and the appliance's Apache configuration proxies it to the network at **`/termviewer`** with no `Require`, `AuthType` or client-certificate check, unlike the neighbouring `/plugin/avtrans` and `/plugin/fileTransfer` locations. runZero therefore says `/termviewer` is reachable **without authentication** and that the only prerequisite is network reach to the appliance web port. [runZero advisory][rz] [CVE JSON][cve]

**Affected products and versions:** the CNA record lists only **Avocent ACS8000, versions through 2.32.4**. runZero's Lights Out blog says the **ACS8000 and ACS800** running firmware 2.32.4 are affected. Vertiv's release notes say each firmware release applies to both models and ships the same image (`firmware-acs8-<version>.fl`), which supports treating the ACS800 as affected too. runZero found the flaw through **firmware analysis and a virtualized target running ACS8000 firmware 2.32.4**, and says it has **not yet been fully validated on a live device**. [Lights Out blog][blog] [2.32.6 release notes][rn6]

**Worst case:** an unauthenticated attacker who can reach the appliance's web interface runs arbitrary commands as root. runZero says that gives full control of the console server, including access to every serial console and managed device it fronts. Console servers usually sit on out-of-band management networks with privileged access to switch, router, server and PDU consoles, so a compromised unit is a pivot into infrastructure management.

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). No exploitation and no public exploit code were reported in the reviewed sources through 2026-10-26; runZero says the finding is not yet validated on a live device. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and affected versions](#inventory-and-affected-versions)
  - [Exposure](#exposure)
  - [Log and configuration review](#log-and-configuration-review)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| ACS8xxx firmware 2.32.4 released | 2026-05-29 (time/TZ unknown) | The version runZero analysed. [2.32.4 release notes][rn4] |
| Private discovery | 2026-07-18 (time/TZ unknown) | runZero: "Initial findings discovered and documented". Credited to HD Moore of runZero, "with the help of AI tools". [runZero advisory][rz] |
| CVE reserved | 2026-07-21 20:14:34 UTC | runZero CNA metadata. [CVE JSON][cve] |
| ACS8xxx firmware 2.32.5 released | 2026-08-10 (time/TZ unknown) | OpenSSH 10.4p1 and functional fixes. Released **before** runZero notified Vertiv, and its notes mention no wsserver or viewer security change. Not a confirmed fix. [2.32.5 release notes][rn5] |
| Vendor notified | 2026-08-27 (time/TZ unknown) | runZero timeline. [runZero advisory][rz] |
| Vendor acknowledged receipt | 2026-09-02 (time/TZ unknown) | runZero timeline. [runZero advisory][rz] |
| ACS8xxx firmware 2.32.6 released | 2026-09-15 (time/TZ unknown) | Current latest release on Vertiv's download page. Its notes list "Security enhancements to the serial viewer subsystem" but do not name CVE-2026-65184, wsserver or `/termviewer`. **Whether 2.32.6 fixes this CVE is unconfirmed.** [2.32.6 release notes][rn6] [Downloads][dl] |
| **Public announcement**: runZero advisory and Lights Out blog update | 2026-10-26; CNA `datePublic` 14:00:00 UTC | The CVE record's `datePublic` is 2026-10-26T14:00:00Z. The advisory page shows "Updated October 26, 2026, 12:00am EDT"; the blog's "October 26, 2026 update" has no time. [runZero advisory][rz] [Lights Out blog][blog] [CVE JSON][cve] |
| CVE record published | 2026-10-26 14:07:08 UTC | runZero CNA. Affected: ACS8000 0 through 2.32.4. [CVE JSON][cve] |
| NVD record published | 2026-10-26 15:16:41 (NVD API, UTC) | Status "Received"; NVD shows only runZero's 9.8. [NVD][nvd] |
| Vendor advisory | None found (checked 2026-10-26) | No Vertiv security bulletin for this CVE was found on Vertiv's security support center or the ACS8000 download page. [Vertiv security][vsec] [Downloads][dl] |
| CISA KEV | Not listed as of catalog 2026.10.23 (checked 2026-10-26) | [KEV JSON][kev] |

## Detection

### Inventory and affected versions

1. List every Avocent ACS8000 and ACS800 appliance, including cellular/LTE models, lab units and spares that may be powered on. Include units managed through Vertiv DSView or other management software.
2. Record the running firmware version. Vertiv's installer/user guide shows it in the web UI under **Expert tab → System → Information**. The RESTful API also reports installed firmware at the `/system/firmware/version` resource (API guide hosted by a reseller). [Installer/user guide][guide] [API guide][api] Neither check was exercised on a real appliance for this guide.
3. Compare with the sources:

   | Firmware | Status from reviewed sources |
   |---|---|
   | 2.32.4 and earlier (ACS8000) | **Affected** per the CVE record ("0 through 2.32.4"). runZero analysed only 2.32.4; earlier releases are included by the CVE range, not by separate testing. |
   | 2.32.4 and earlier (ACS800) | **Treat as affected.** The CVE record names only ACS8000, but runZero's blog names ACS800 and Vertiv ships one image for both. |
   | 2.32.5 | **Unknown, treat as affected.** Released before the vendor was notified; no relevant security change listed. |
   | 2.32.6 | **Unknown.** "Security enhancements to the serial viewer subsystem" may or may not address this flaw; neither Vertiv nor runZero ties the release to the CVE. |

4. Network asset-discovery tools can help find console servers you did not know about. A result that only reports a model or version string is inventory evidence, not proof of exploitability or of a fix.

### Exposure

- Identify which networks can reach the appliance's web UI (HTTP/HTTPS). The installer/user guide says the **Security Profile** determines whether HTTP and HTTPS access are enabled; check the profile on each unit rather than assuming defaults. Check whether the web ports are reachable from the internet, from user networks or from anything other than a dedicated management network. Treat a unit as exposed if you cannot establish its reachability. [Installer/user guide][guide]
- Check the appliance's own **IPv4/IPv6 Filter Table** (IP filtering) and any upstream firewall rules for what they actually permit to the web ports.
- Do not send requests to `/termviewer` to test reachability. A WebSocket handshake to that path from an untrusted host is an exploitation step, not a safe probe.

### Log and configuration review

Neither runZero nor Vertiv published indicators of compromise, request signatures or log patterns. Without them:

- In reverse-proxy, firewall or NetFlow logs, look for connections to the appliance's web ports from sources outside the management network, especially WebSocket upgrade requests to `/termviewer` from hosts that are not administrator workstations. Logs on the appliance itself may be short-lived and are under root's control after compromise.
- Compare the current configuration (users, groups, authentication servers, SSH keys, security profile, IP filter tables, routes, IPSec and cellular settings) with a known-good backup. Look for new local users, changed authentication methods, or new outbound connections from the appliance.
- Review access logs on the devices behind the console server for unexpected console sessions, configuration changes or password resets that coincide with time windows you cannot account for.

A clean review does **not** prove the unit was not compromised. Root access lets an attacker alter or delete local logs, and no indicators have been published.

## Remediation

1. **Restrict web access now.** Allow the appliance's HTTP/HTTPS ports only from a dedicated management network or jump host, using upstream firewalls and the appliance's IP filter tables. Do not expose the web UI to the internet. Where the web UI is not needed, consider disabling HTTP/HTTPS access in the Security Profile and managing the unit over SSH, the serial console or your management software. runZero says the only prerequisite is network reach to the web port, so removing web reachability should block this path; that is an inference from runZero's description, not a vendor-validated mitigation. Changing the security profile or IP filters **changes state** and can lock you out: keep console or out-of-band access available. [Installer/user guide][guide]
2. **Patch availability is unconfirmed.** No source reviewed names a fixed version. Vertiv's latest release, **2.32.6** (2026-09-15), lists "Security enhancements to the serial viewer subsystem" and is the newest firmware available. Moving to 2.32.6 is reasonable, but do not treat it as remediation of CVE-2026-65184 or relax network restrictions until Vertiv or runZero confirms the fix. Ask Vertiv support (or your reseller) for a written statement of the fixed version. [2.32.6 release notes][rn6] [Vertiv security][vsec]
3. Follow Vertiv's upgrade path: the 2.32.x release notes say the firmware must be upgraded from **2.14.4 or later**; units on 2.0.3 or earlier must step through 2.12.4 and 2.14.4, and units on 2.4.2–2.12.4 through 2.14.4. Download firmware only from Vertiv and check the published SHA-256 checksum. Back up the configuration first and expect a reboot, which interrupts console sessions. [2.32.6 release notes][rn6] [Downloads][dl]
4. Patching or filtering prevents new exploitation through this path. It does not remove accounts, keys or other changes an attacker already made. Preserve logs and a configuration backup before you upgrade a unit you suspect.

## Verification

- Confirm the running firmware version on every unit (web UI **System → Information** or the API's `/system/firmware/version`), and record it against Vertiv's eventual fixed-version statement.
- From a host outside the management network, confirm that the appliance's web ports are not reachable (for example, a TCP connection attempt is refused or times out). From the management network, confirm normal login, serial-session and power-management functions still work.
- Do not send WebSocket or command-injection payloads to `/termviewer` on production units, and do not run untrusted proof-of-concept code.

## Compromise response

- If you find unexplained access or changes, isolate the console server's network interfaces (including cellular), preserve logs and a configuration export, and engage Vertiv support or an incident-response provider. Root-level command execution means configuration review alone may not reveal changes to the operating system.
- If the appliance's integrity cannot be established, reinstall firmware from Vertiv and restore a reviewed configuration rather than the current one.
- Rotate every credential the appliance stores or brokers: local and administrator passwords, TACACS+/RADIUS/LDAP and Kerberos secrets, SNMP communities, SSH keys, Duo or other MFA integration secrets, PDU credentials, and any target-device credentials used for console login or hostname discovery.
- Treat devices reachable through its serial ports and PDUs as potentially accessed: review their configurations and logs, and change console passwords on them.

## Sources

- [runZero advisory for CVE-2026-65184][rz] — root cause, `/termviewer` Apache pass-through, root privileges, CVSS 9.8, firmware-analysis/virtualized-target qualification, credits and disclosure timeline.
- [runZero Lights Out blog, October 26 update][blog] — names ACS8000 and ACS800 on firmware 2.32.4 and repeats the live-device qualification.
- [CVE record (runZero CNA)][cve] — affected ACS8000 0 through 2.32.4, CWE-78, `datePublic`, reservation and publication timestamps.
- [NVD][nvd] — status "Received", NVD publication time.
- Vertiv ACS8xxx release notes: [2.32.6][rn6], [2.32.5][rn5], [2.32.4][rn4] — both models share one image, release dates, "serial viewer subsystem" note, upgrade path; and the [ACS8000 download page][dl].
- [Vertiv ACS800/8000 installer/user guide][guide] and [API guide][api] — firmware-version location, Security Profile HTTP/HTTPS settings, IP filter tables.
- [Vertiv security support center][vsec] — no bulletin found for this CVE.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.23).

[rz]: https://www.runzero.com/advisories/avocent-acs8000-wsserver-cmdinj-cve-2026-65184/
[blog]: https://www.runzero.com/blog/lights-out-exposed/
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-65184
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-65184
[rn6]: https://downloads2.vertivco.com/SerialACS/ACS8000/v2.32.6%20September%202026/ACS%208xxx%20Release%20Notes%20v2.32.6.pdf
[rn5]: https://downloads2.vertivco.com/SerialACS/ACS8000/v2.32.5%20August%202026/ACS%208xxx%20Release%20Notes%20v2.32.5.pdf
[rn4]: https://downloads2.vertivco.com/SerialACS/ACS8000/v2.32.4%20May%202026/ACS%208xxx%20Release%20Notes%20v2.32.4.pdf
[dl]: https://www.vertiv.com/en-us/support/software-download/it-management/avocent-acs-8000-advanced-control-systems-software-downloads
[guide]: https://www.vertiv.com/49c8dd/globalassets/shared/avocent-acs-8000-installer-userguide.pdf
[api]: https://www.42u.com/pdf/API-Guide_Avocent_ACS-8000_ACS-800.pdf
[vsec]: https://www.vertiv.com/en-us/support/security-support-center
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
