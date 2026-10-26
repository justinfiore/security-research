# WolfVision Cynap collaboration systems: unauthenticated WolfProt command injection and shared vSolution Matrix SSH root key

**Last updated:** 2026-10-26 (America/New_York)

[Main WolfVision Cynap summary](../black-october-2026.md#wolfvision-cynap-collaboration-systems-unauthenticated-wolfprot-command-injection-and-shared-vsolution-matrix-ssh-root-key) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

This guide covers two WolfVision advisories for Cynap wireless presentation and collaboration devices, both reported by the National Test Institute for Cybersecurity (NTC). They affect different model sets and need different checks.

**[CVE-2026-59106](https://www.cve.org/CVERecord?id=CVE-2026-59106) — unauthenticated OS command injection in the WolfProt interface (CWE-78). WolfVision and ENISA (CNA): CVSS 4.0 9.3 Critical (CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N) and CVSS 3.1 9.8 Critical (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H); NVD has not scored it.** WolfProt is WolfVision's proprietary control protocol for device management and integration. Insufficient neutralization of user input lets an unauthenticated attacker with network access run operating-system commands **with the privileges of the affected application service**. The vendor does not say whether that service runs as root. The interface is reachable on **TCP 50915** (WolfProt, unencrypted), **TCP 50917** (WolfProt over TLS), and **TCP 80/443** (WebSocket via HTTP/HTTPS), and WolfVision says these services **cannot be disabled**. It affects nearly every Cynap model; see the [version table](#inventory-and-affected-versions). [Advisory][a106] [CVE JSON][cve106]

**[CVE-2026-59107](https://www.cve.org/CVERecord?id=CVE-2026-59107) — shared SSH authentication key in vSolution Matrix file sharing. WolfVision and ENISA (CNA): CVSS 4.0 9.2 Critical (CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N) and CVSS 3.1 9.8 Critical; NVD has not scored it.** A static, shared public key trusted for vSolution Matrix file sharing lets an attacker who obtains the matching private key log in **over SSH as root**. Only devices configured as a **vSolution Matrix main/master station with file sharing enabled** are affected, and only **Cynap Pro and Cynap Core Pro below 1.78a** and the discontinued **Cynap and Cynap Core**. WolfVision lists the weakness as CWE-798; the CNA record lists CWE-797. Both describe hard-coded credentials. The advisory names TCP 50930 as the file-sharing service port. [Advisory][a107] [CVE JSON][cve107]

**Worst case:** for CVE-2026-59106, an unauthenticated attacker on a network that can reach the device runs commands as the WolfProt service and can access, change or disrupt what that service controls. For CVE-2026-59107, an attacker with the shared private key gets a root shell on a Matrix master station. Cynap devices sit in meeting rooms and classrooms and show, record and stream presentation content, so a compromised device can expose that content and serve as a foothold on the network segment it shares with user devices. That last point is an inference from the product's role, not a vendor claim.

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26) for either CVE-2026-59106 or CVE-2026-59107. WolfVision says it is not aware of active exploitation of either flaw; CISA's ADP assessment for CVE-2026-59106 says Exploitation "none". No public exploit code was found in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and affected versions](#inventory-and-affected-versions)
  - [Exposure](#exposure)
  - [Log and configuration review](#log-and-configuration-review)
- [Remediation](#remediation)
  - [Related WolfVision advisories](#related-wolfvision-advisories)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Both advisories credit NTC for coordinated disclosure; no report date is published. [CVE-2026-59106][a106] [CVE-2026-59107][a107] |
| CVEs reserved | 2026-07-02 15:47:36 UTC | ENISA CNA metadata for both CVEs. [CVE-2026-59106 JSON][cve106] [CVE-2026-59107 JSON][cve107] |
| Cynap firmware v2.00c (Cynap Pure (Next Gen), Cynap Bridge) | Build 2026-07-22; announced 2026-08-03 (time/TZ unknown) | Fixed version for CVE-2026-59106 on these models. The firmware history includes "Wolfprot support only encrypted (TLS)"; the release notes do not name the CVE. [Cynap history][hist] [v2.00c news][n200c] |
| Cynap Videobar firmware v1.72e | Build 2026-10-02 (from the firmware history; release date not published) | Fixed version for CVE-2026-59106 on the Videobar. History: "Security updates". [Videobar history][histcvb] |
| Cynap firmware v1.78a (Cynap Pro, Core Pro, Receiver, Pure, Pure Mini, Pure Pro) | Build 2026-10-19; download file last modified 2026-10-21 08:16 GMT | Fixed version for both CVEs on these models. History: "Security Updates", "Improved Matrix Streaming". [Cynap Pro history][histcbr] [Cynap Pure history][histcbp] |
| Cynap firmware v2.00d (Cynap Pure (Next Gen), Cynap Bridge) | Build 2026-10-19; download file last modified 2026-10-21 08:14 GMT | Fixes the related medium-severity advisories on these models (see [below](#related-wolfvision-advisories)). [Cynap history][hist] |
| WolfVision advisory pages | Pages say "Published: 21 September 2026" (time/TZ unknown) | **Date conflict:** the advisories name v1.78a as the fix, but that firmware was built on 2026-10-19 and posted on 2026-10-21. This guide therefore does not treat 2026-09-21 as an established public disclosure date. [CVE-2026-59106][a106] [CVE-2026-59107][a107] |
| **Public announcement (earliest verified)**: CVE-2026-59106 record published | 2026-10-26 13:15:02 UTC | ENISA CNA; references WolfVision's advisory. [CVE JSON][cve106] |
| CVE-2026-59107 record published | 2026-10-26 13:33:12 UTC | ENISA CNA. [CVE JSON][cve107] |
| NVD records published | 2026-10-26 14:16:38 (NVD API, UTC) | Both "Received"; NVD shows only the CNA scores. [NVD 59106][nvd106] [NVD 59107][nvd107] |
| CISA ADP SSVC (CVE-2026-59106) | 2026-10-26 15:04:38 UTC | Exploitation: none; Automatable: yes; Technical impact: total. No ADP entry for CVE-2026-59107 when checked. [CVE JSON][cve106] |
| EU Vulnerability Database | 2026-10-26 (time/TZ not established) | EUVD-2026-109816 (CVE-2026-59106) and EUVD-2026-109828 (CVE-2026-59107). [EUVD][euvd] |
| No fix for discontinued models | Stated in both advisories | Cynap, Cynap Core and Cynap Pure SDM (CVE-2026-59106); Cynap and Cynap Core (CVE-2026-59107). |
| CISA KEV | Not listed as of catalog 2026.10.23 (checked 2026-10-26) | [KEV JSON][kev] |

## Detection

### Inventory and affected versions

1. List every Cynap device: Cynap, Cynap Core, Cynap Pro, Cynap Core Pro, Cynap Pure (and Pure Mini, Pure Pro, Pure SDM, Pure Receiver), Cynap Pure (Next Gen), Cynap Bridge and Cynap Videobar. Include devices in rooms that are rarely used and spares.
2. Record each device's firmware version from your management inventory (for example WolfVision's vSolution Link Pro) or the device's own web interface. These read-only checks were not exercised on a real device for this guide.
3. Compare with the advisories:

   | Model | CVE-2026-59106 (WolfProt) | CVE-2026-59107 (Matrix shared key) |
   |---|---|---|
   | Cynap Pure (Next Gen), Cynap Bridge | Affected below **v2.00c**; fixed in v2.00c | Not listed |
   | Cynap Pro, Cynap Core Pro | Affected below **v1.78a**; fixed in v1.78a | Affected below **v1.78a** when a Matrix master station with file sharing enabled; fixed in v1.78a |
   | Cynap Receiver, Cynap Pure, Cynap Pure Mini, Cynap Pure Pro | Affected below **v1.78a**; fixed in v1.78a | Not listed |
   | Cynap Videobar | Affected below **v1.72e**; fixed in v1.72e | Not listed |
   | Cynap, Cynap Core (discontinued) | **All versions affected; no fix planned** | **All versions affected** when a Matrix master station with file sharing enabled; **no fix planned** |
   | Cynap Pure SDM (discontinued) | **All versions affected; no fix planned** | Not listed |

   "Not listed" means the advisory does not name the model; it is not a vendor statement that the model is unaffected.

4. For CVE-2026-59107, identify which Cynap Pro, Cynap Core Pro, Cynap or Cynap Core devices are configured as a **vSolution Matrix main/master station** and whether **file sharing** is enabled.

### Exposure

- **CVE-2026-59106:** determine which networks can reach TCP 50915, 50917, 80 and 443 on each device. Treat a device as exposed if any untrusted host, such as guest Wi-Fi, BYOD or a general user VLAN, can reach any of those ports. Many deployments put Cynap devices on the same network as presenters' laptops; that layout counts as exposed. Assume exposure if you cannot establish reachability.
- **CVE-2026-59107:** determine which hosts can reach TCP 50930 and SSH on Matrix master stations.
- Scanning only for open ports is reachability evidence. Do not send WolfProt commands or SSH authentication attempts with keys of unknown origin to production devices to test for the flaws.

### Log and configuration review

WolfVision published **no indicators of compromise, request signatures or log patterns**. Without them:

- Review firewall, NetFlow or switch logs for connections to TCP 50915/50917 and 50930 from hosts that are not your control systems (room controllers, vSolution Link Pro servers, other Matrix stations). Look for outbound connections from Cynap devices to unexpected internet destinations.
- Review the device configuration for unexpected changes, such as new network settings, cloud or streaming targets, recording upload destinations or changed administrator settings, against a known-good settings backup or template.
- On Matrix installations, check which stations are configured and whether any unknown station appears.

A clean review does **not** prove a device was not accessed. No indicators are published, device-side logging is limited, and an attacker with command or root access can alter what the device records.

## Remediation

1. **Update firmware** on every supported model:
   - Cynap Pure (Next Gen) and Cynap Bridge: **v2.00c** fixes CVE-2026-59106. Prefer **v2.00d**, which also covers the [related advisories](#related-wolfvision-advisories).
   - Cynap Pro, Cynap Core Pro, Cynap Receiver, Cynap Pure, Cynap Pure Mini, Cynap Pure Pro: **v1.78a** (fixes both CVEs where applicable).
   - Cynap Videobar: **v1.72e**.

   WolfVision's support pages say devices below v1.70e must install sequential version v1.70e first. Download firmware only from WolfVision, back up settings, and schedule the reboot outside meeting or teaching hours. [Cynap Pro support][support]
2. **vSolution Matrix (CVE-2026-59107):** WolfVision says the fix generates a distinct ephemeral key pair per device and Matrix session, removes the static shared key, and no longer allows interactive SSH or root login through this mechanism. **All stations in a Matrix installation must be updated to stay compatible**, so plan the update for the whole Matrix group. [Advisory][a107]
3. **Until you can update, and permanently for discontinued models:**
   - CVE-2026-59106: restrict TCP 50915, 50917, 80 and 443 to trusted hosts only, using a dedicated VLAN or firewall zone. The services cannot be disabled, so network restriction is the only vendor mitigation. Presenters still need whatever access your sharing workflow requires; test before enforcing. [Advisory][a106]
   - CVE-2026-59107: disable vSolution Matrix file sharing if you do not need it, and restrict TCP 50930 to trusted hosts. [Advisory][a107]
   - Changing VLANs or firewall rules **changes state** and can break wireless sharing, room control or Matrix streaming. Confirm management access before you apply them.
4. **Discontinued models (Cynap, Cynap Core, Cynap Pure SDM)** will not be fixed. WolfVision advises decommissioning them when feasible; until then keep them on an isolated segment reachable only by trusted hosts.
5. Updating prevents new exploitation through these flaws. It does not undo changes an attacker already made. Preserve logs and a settings backup from a device you suspect before you update or reset it.

### Related WolfVision advisories

WolfVision's security page lists four more Cynap advisories alongside these two. They are not tracked as separate items here; the same firmware lines fix them, except that Cynap Pure (Next Gen) and Cynap Bridge need **v2.00d** rather than v2.00c:

- [CVE-2026-70379](https://www.cve.org/CVERecord?id=CVE-2026-70379): unauthenticated access to the unencrypted vSolution Matrix RTSP stream from the same network segment. WolfVision severity **High** (CVSS 4.0 7.1; CVSS 3.1 6.5 Medium). Cynap Pro and Core Pro below v1.78a; Cynap and Cynap Core with no fix. The fix restricts stream access but does not encrypt the stream. Its CVE record was not yet published when checked on 2026-10-26. [Advisory][a379]
- [CVE-2026-70380](https://www.cve.org/CVERecord?id=CVE-2026-70380) (MICE service resource exhaustion), [CVE-2026-70381](https://www.cve.org/CVERecord?id=CVE-2026-70381) (unauthorized access to internal web resources) and [CVE-2026-70382](https://www.cve.org/CVERecord?id=CVE-2026-70382) (stored cross-site scripting): WolfVision severity Medium. [Security announcements][secidx]

## Verification

- Confirm the running firmware on every device after the update (v2.00c/v2.00d, v1.78a or v1.72e as applicable), including every station in a Matrix group.
- From a host outside the trusted segment, confirm that TCP 50915, 50917, 80, 443 and (on Matrix master stations) 50930 are no longer reachable where you restricted them, for example with a TCP connection attempt that is refused or times out. From the trusted network, confirm that screen sharing, room control, vSolution Link Pro management and Matrix file sharing still work.
- On Cynap Pure (Next Gen) and Cynap Bridge, the v2.00c history says WolfProt is supported only over TLS. Check that your control systems still connect after the update.
- Do not send command-injection payloads or SSH login attempts to production devices to test the fixes.

## Compromise response

- If you find unexplained connections or configuration changes, isolate the device from user networks, preserve a settings backup and any logs your management tools hold, and contact WolfVision support.
- Restore firmware from WolfVision and settings from a reviewed template rather than the device's current configuration. Replace discontinued units that cannot be fixed.
- Rotate credentials the device stores or uses: administrator passwords, Wi-Fi and 802.1X/WPA2-Enterprise credentials, cloud-storage, streaming and recording-upload accounts, Microsoft Teams or other conferencing accounts, and vSolution Link Pro access.
- Review what was shown, recorded or shared on the device during the suspected window, and hunt for lateral movement from its address into the networks it can reach.

## Sources

- WolfVision advisories: [CVE-2026-59106][a106] and [CVE-2026-59107][a107] — affected and fixed versions, discontinued models, ports, mitigations, CVSS scores and vectors, CWE, "not aware of active exploitation", NTC credit, page publication date. English versions: [CVE-2026-59106][a106en], [CVE-2026-59107][a107en].
- ENISA CNA records: [CVE-2026-59106][cve106] and [CVE-2026-59107][cve107] — affected ranges, scores, CWE-797 for CVE-2026-59107, reservation and publication timestamps, CISA ADP SSVC.
- NVD: [CVE-2026-59106][nvd106], [CVE-2026-59107][nvd107] — status "Received".
- [EU Vulnerability Database][euvd] — EUVD-2026-109816 and EUVD-2026-109828.
- WolfVision firmware histories: [Cynap (Next Gen/Bridge)][hist], [Cynap Pro][histcbr], [Cynap Pure][histcbp], [Cynap Videobar][histcvb]; [v2.00c announcement][n200c]; [Cynap Pro support page][support].
- [WolfVision security announcements][secidx] and [CVE-2026-70379 advisory][a379] — related advisories.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.23).

[a106]: https://wolfvision.com/de/security/cve-2026-59106-2
[a107]: https://wolfvision.com/de/security/cve-2026-59107-1
[a106en]: https://wolfvision.com/en/security/cve-2026-59106
[a107en]: https://wolfvision.com/en/security/cve-2026-59107
[a379]: https://wolfvision.com/en/security/cve-2026-70379
[secidx]: https://wolfvision.com/en/security
[cve106]: https://cveawg.mitre.org/api/cve/CVE-2026-59106
[cve107]: https://cveawg.mitre.org/api/cve/CVE-2026-59107
[nvd106]: https://nvd.nist.gov/vuln/detail/CVE-2026-59106
[nvd107]: https://nvd.nist.gov/vuln/detail/CVE-2026-59107
[euvd]: https://euvd.enisa.europa.eu/vulnerability/EUVD-2026-109816
[hist]: https://firmware.wolfvision.com/Cynap_History.txt
[histcbr]: https://firmware.wolfvision.com/cbr_history.txt
[histcbp]: https://firmware.wolfvision.com/cbp_history.txt
[histcvb]: https://firmware.wolfvision.com/cvb_history.txt
[n200c]: https://wolfvision.com/en/news/firmware-update-v2-00c-for-cynap-systems
[support]: https://wolfvision.com/en/support/cynap-pro
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
