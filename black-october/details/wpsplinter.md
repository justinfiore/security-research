# WPSplinter: firmware-specific detection and Wi-Fi containment

**Last updated:** 2026-10-26 (America/New_York)

[Main guide](../black-october-2026.md#8-wpsplinter-nearby-attackers-can-compromise-vulnerable-routers) · [Changelog](../../CHANGELOG.md)

**Scope:** Broadcom’s legacy WPS Monitor EAP-fragment reassembly on eCos and Linux. An attacker within radio range can reach the parser without the Wi-Fi key or completing WPS enrollment. Memory disclosure and code execution were demonstrated; privileges depend on firmware. No CVE was assigned by Broadcom. [Research][research] [Device guidance][devices]

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Build a device-level inventory](#build-a-device-level-inventory)
  - [Safe evidence collection](#safe-evidence-collection)
- [Remediation](#remediation)
  - [Temporary mitigation must remove the radio attack path](#temporary-mitigation-must-remove-the-radio-attack-path)
  - [Durable repair or replacement](#durable-repair-or-replacement)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date | Evidence and qualification |
|---|---|---|
| Earliest vulnerable SDK code identified | At least 2010 | Researcher’s historical assessment; not a discovery date. [Research][research] |
| Earlier vendor awareness / incomplete fix | 2018; exact day unknown | Researcher reports an incomplete patch and subsequent replacement of WPS Monitor with hostapd. Not a universal OEM firmware fix. [Research][research] |
| Current research discovery | Unknown | No exact discovery day published. |
| Private report: BCM3380/3383/33834, KS-20260718-02 | 2026-07-18 | Researcher timeline; eCos-related platform report. [Research][research] |
| Private report: BCM3390/65xx/68xx, KS-20260727-01 | 2026-07-27 | Second platform report, not a separately assigned CVE. [Research][research] |
| Broadcom response about a patch | 2026-07-28 | OEMs told to contact Broadcom; no general fixed firmware version supplied. [Research][research] |
| ISP / coordination reports | 2026-07-29 | Proximus report, Orange/VOO contact attempts and Belgian coordination; these are not all acknowledgments. [Research][research] |
| Public research / Hexacon presentation | 2026-10-16 | Technical article and conference talk. [Research][research] |
| ISP-specific clarification | 2026-10-20 | Telenet reported unaffected; Proximus disabled WPS fleet-wide in preceding 24 hours; full patching still planned. Orange Belgium investigating. [Research update][research] |
| Fixed firmware available per OEM/ISP branch | No universal matrix established | Obtain confirmation for exact model, hardware revision, firmware and provider; do not treat a 2018 SDK change as proof of deployment. [Device guidance][devices] |

The dated October 20 update takes precedence over the article’s older “none patched” discussion. Proximus’s coordinated mitigation is a specific reported exception, **not evidence that every consumer WPS toggle works**.

## Detection

### Build a device-level inventory

1. Record manufacturer, exact model, hardware revision, region, firmware build and ISP customization from each device label and management interface.
2. Include gateways, bridged modems with active radios, mesh satellites, extenders and spare access points still powered on. Inventory each radio/band rather than only the primary SSID.
3. Compare the complete tuple with the researcher’s [affected-device list][devices]. Entries marked confirmed, likely or unknown are different evidence levels; “ALL” is a researcher list entry, not independently tested proof of every future revision.
4. Ask the OEM/ISP whether that firmware includes legacy `wps_monitor`, which build fixes/removes the parser, and whether its WPS-disable control actually prevents parser execution.
5. Broadcom chip families alone are insufficient: the affected component is software. Conversely, a model missing from the non-exhaustive list is **unknown**, not cleared. [Device guidance][devices]

Examples in the current researcher list include Actiontec C3000A `CAD004-31.165L.13`, Zyxel AX7501-B1 `V5.17(ABPC.8)C0`, and specific ASUS DSL-AC68U builds. Use the live table for your exact device rather than extrapolating from a vendor name. [Device guidance][devices]

### Safe evidence collection

- There is no applicable check in the companion Linux/Python scripts: host packages, TCP listeners and MAC-vendor guesses cannot establish this firmware condition.
- For managed fleets, request OEM evidence or have a qualified analyst inspect an **offline firmware copy** with the researcher’s published YARA guidance. A match is triage, not proof of exploitable deployment; a non-match can reflect packing or a changed binary.
- The researcher also offers radio fingerprinting tools, but they are not a passive read-only inventory equivalent. This guide does not require downloading or running probes against operational access points. [Device guidance][devices]
- Recommended: retain router configuration/audit logs and upstream DNS/firewall telemetry; investigate unexplained DNS servers, remote administration, port forwards, reboots, accounts or firmware changes.
- Such anomalies have many causes. Research demonstrations are not evidence of a particular attack on your network; the reviewed pages do not establish an in-the-wild campaign.
- Normal IP logs may miss activity before network enrollment. No failed Wi-Fi passwords, no suspicious WAN connections, or a normal client list does not rule out radio-layer compromise. [Research][research]

## Remediation

### Temporary mitigation must remove the radio attack path

- Prefer an OEM/ISP-confirmed mitigation for the exact build. Ask Proximus to confirm your BBOX received the fleet control rather than assuming a previously offline device is covered by the October 20 report.
- Do not generalize Telenet’s fleet assessment to a separately purchased router connected behind its gateway, or Orange’s investigation to a completed mitigation. [Research][research]
- Where no validated mitigation exists, recommended containment is to turn off the vulnerable radios and use a confirmed unaffected access point, or power down/replace the device. Ensure mesh/backhaul and guest radios are also disabled.
- Arrange an Ethernet/console administration path before disabling Wi-Fi; verify the control actually stops radio service. Bridge mode alone is not evidence that the radio/parser stopped.
- Changing the Wi-Fi password, enabling stronger normal authentication, hiding the SSID or blocking WAN ports does not address this pre-enrollment radio path. A WPS UI toggle alone is not proof. [Device guidance][devices]

### Durable repair or replacement

1. Install only firmware confirmed by the OEM/ISP for your exact revision and region; preserve the previous build identifier and vendor case/advisory in the asset record.
2. Confirm whether the fix repairs fragment handling, removes the legacy service or migrates to an unaffected implementation. “Firmware current” without WPSplinter-specific confirmation leaves the status unknown.
3. Do not attempt cross-model firmware or assume third-party firmware supports an obsolete platform. The researcher identifies eCos devices with no practical hostapd migration path. [Research][research]
4. Replace unsupported equipment if no verified fix is available. Coordinate ISP-provisioned voice, IPTV, GPON and management requirements before replacing a gateway.
5. Maintain containment until the replacement/updated device is verified. Back up configuration for analysis, but do not automatically restore it if compromise is suspected.

## Verification

- After reboot, record the running firmware, hardware revision and ISP provisioning state and match them to written remediation confirmation.
- Verify all access points and mesh nodes, not only the gateway showing the update. Check that management/provisioning did not re-enable a disabled radio or reinstall old firmware.
- For a temporary radio shutdown, confirm the intended radio service is unavailable using normal wireless discovery and vendor status. A hidden SSID’s absence alone is not proof of shutdown.
- Test ordinary wired/wireless connectivity, DHCP/DNS, voice and other essential services on the repaired deployment without malformed WPS traffic.
- Classify each asset as **vendor-confirmed fixed**, **validated temporary mitigation**, **replaced**, or **unknown**. Preserve an escalation owner for unknown devices.

## Compromise response

- If compromise is plausible, disconnect the router from trusted networks and preserve configuration/logs before reset where feasible; do not expose secrets in an exported support bundle.
- Use the vendor’s trusted recovery/reflash procedure or replace the device. A reboot or factory reset alone is not proof that malicious firmware or persistence was removed.
- Recreate reviewed network settings manually; check DNS, DHCP, forwarding, remote management and administrative accounts against the intended configuration.
- Rotate Wi-Fi keys and router/ISP administration credentials **after** removing the attacker’s access, using a clean device. The research demonstrated extraction of a Wi-Fi pre-shared key. [Research][research]
- Re-enroll authorized clients and investigate internal systems reachable from the compromised router. Do not assume encryption on a website proves the router was harmless or that every TLS session was decrypted.

## Sources

- [WPSplinter device guidance and FAQ][devices] — non-exhaustive firmware list, detection-aid limitations and WPS-disable warning.
- [Quentin Kaiser’s research and October 20 update][research] — private reports, demonstrated impact, SDK history and ISP-specific changes.

[devices]: https://qkaiser.github.io/broadcom-wps/
[research]: https://quentinkaiser.be/security/2026/10/16/one-parser-two-bugs/
