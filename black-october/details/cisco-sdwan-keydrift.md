# Cisco Catalyst SD-WAN: KeyDrift exploitation of authentication bypass

**Last updated:** 2026-10-29 (America/New_York)

[Main Cisco Catalyst SD-WAN summary](../black-october-2026.md#cisco-catalyst-sd-wan-keydrift-authentication-bypass-and-key-theft) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-20127](https://www.cve.org/CVERecord?id=CVE-2026-20127) — Cisco CVSS 3.1 10.0 Critical (`AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`).** Cisco Catalyst SD-WAN Controller, Manager and Validator can let an unauthenticated remote attacker bypass peering authentication and obtain an internal high-privileged non-root account. Cisco PSIRT reports limited exploitation; Cisco Talos links historical UAT-11473 activity to the flaw and documents KeyDrift malware that collects control-plane keying material and provides persistent backdoor access.

**CISA KEV:** Not listed (catalog 2026.10.28, checked 2026-10-29). Cisco reports limited exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Cisco advisory and initial fixed releases | 2026-02-25 16:00 GMT | Cisco published `cisco-sa-sdwan-rpa-EHchtZk`. [Cisco advisory][cisco] |
| Talos KeyDrift report and Cisco advisory revision | 2026-10-28 17:32; 21:54 (timezones not established by source) | Talos published historical UAT-11473 findings; Cisco revision 2.1 links that report and confirms limited exploitation. [Talos][talos] [Cisco advisory][cisco] |

## Detection

1. Inventory Cisco Catalyst SD-WAN Control Components (formerly vSmart, vManage and vBond) in on-prem and hosted deployments; compare every release to Cisco's fixed-release table.
2. On internet-exposed Controllers, inspect `/var/log/auth.log` for `Accepted publickey for vmanage-admin` from unknown or unauthorized IPs. Compare the IPs with documented System IPs in the Manager UI. Preserve `request admin-tech` output for Cisco TAC rather than changing a suspect node in place.
3. Validate control-connection peering events against maintenance windows, expected public and system IPs, expected peer types and associated change records. Treat unexplained `vmanage` peering as suspicious.
4. Talos publishes KeyDrift artifact names including `conf_sshd`, `rsshd`, `libdssl.so`, `aaamgrd`, `/var/tmp/vdaemon.bin` and `/var/tmp/vdaemon.conf`. Search offline copies of logs and file metadata where available; absence of these names does not prove no compromise.

## Remediation

1. Upgrade to a fixed Cisco Catalyst SD-WAN release: 20.9 → **20.9.8.2**; 20.11 → **20.12.6.1**; 20.12 → **20.12.5.3** or **20.12.6.1**; 20.13–20.15 → **20.15.4.2**; 20.16–20.18 → **20.18.2.1**. Releases earlier than 20.9 require migration to a supported fixed release. [Cisco advisory][cisco]
2. Before the upgrade, restrict ports 22 and 830 to known controller and administrative IPs using ACLs, security groups or firewalls. This is a temporary mitigation, not a substitute for patching.
3. Follow Cisco's SD-WAN hardening guidance: keep control components off unsecured networks, filter access, disable unused services and send logs to an external system.

## Verification

- Confirm each control component reports a fixed release and that the upgrade matrix supports the deployed topology.
- Verify authorized controllers and edges reconnect normally after the maintenance window. Do not attempt authentication-bypass probes.
- Recheck external access rules and confirm logs arrive at the external retention system.

## Compromise response

Treat a suspected affected controller as a potential fabric-level compromise. Preserve logs and configuration evidence, engage Cisco TAC, rotate credentials and secrets accessible to the controller, and review control-plane peers and configuration changes. Talos reports KeyDrift can intercept and stage data-plane keying material; patching alone does not remove persistence or invalidate previously collected keys.

## Sources

- [Cisco advisory][cisco] — impact, fixed releases, detection and mitigation guidance, and limited-exploitation statement.
- [Cisco Talos KeyDrift report][talos] — observed UAT-11473 activity, artifacts and post-compromise guidance.
- [CISA KEV JSON feed][kev] — catalog 2026.10.28 status.

[cisco]: https://sec.cloudapps.cisco.com/security/center/content/CiscoSecurityAdvisory/cisco-sa-sdwan-rpa-EHchtZk
[talos]: https://blog.talosintelligence.com/uat-11473-keydrift/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
