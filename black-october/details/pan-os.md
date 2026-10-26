# PAN-OS: authenticated management interface RCE

**Last updated:** 2026-10-26 (America/New_York)

[Main PAN-OS summary](../black-october-2026.md#pan-os-authenticated-management-interface-rce-cve-2026-0322) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-0322](https://www.cve.org/CVERecord?id=CVE-2026-0322) — Palo Alto Networks CVSS 4.0: 8.6 High (CVSS-BT, `AV:N/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:H/…/E:A`), or 8.5 High when management access is limited to a jump box (`AV:A`); vendor urgency: HIGHEST. NVD CVSS 3.1: 7.2 High (`AV:N/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:H`). CWE-94.** This is a code-injection flaw in the PAN-OS **management interface**. An **authenticated** attacker with network access to that interface can run arbitrary code **as root**. It applies to PA-Series and VM-Series firewalls and to **Panorama** (virtual and M-Series). **Cloud NGFW and Prisma Access are not affected.** Palo Alto Networks reports "very limited exploitation." **Worst case:** someone holding high-privilege management credentials (PR:H), or a session to that effect, takes root on the firewall or Panorama. From there they could reach traffic, VPN and authentication secrets, and change policy. On Panorama, that could extend to managed firewalls. Unauthenticated exploitation is **not** claimed.

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and version](#inventory-and-version)
  - [Management-interface exposure](#management-interface-exposure)
  - [Log and IOC review](#log-and-ioc-review)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Discovered internally and credited to Suraj Siddharudh (internal reporter); no date is given. The CVE ID was reserved on 2025-11-03 20:46:23 UTC; that is when the ID was reserved, not evidence of when the bug was found. [PAN advisory][pan] [CVE JSON][cve] |
| Palo Alto Networks public disclosure | 2026-10-14 16:00 UTC | Advisory "Initial Publication," with fixed hotfix builds listed for 12.2, 12.1, 11.2 (except 11.2.16), 11.1 and 10.2. The exact time each build became downloadable is not stated. [PAN JSON][pan-json] |
| CVE record published | 2026-10-14 17:26:52 UTC | Palo Alto Networks CNA record. [CVE JSON][cve] |
| CISA KEV addition | 2026-10-14 (date only) | `dueDate` 2026-10-17, ransomware use "Unknown", forensic triage "Yes". [KEV JSON][kev] |
| PAN-OS 11.2.16 released | 2026-10-15 18:30 UTC | Advisory timeline: "11.2.16 has been published." This is the only fix for 11.2.14 through 11.2.15. [PAN JSON][pan-json] |
| Threat Prevention coverage | Date unknown | Threat IDs 510046 and 510047 in Applications and Threats content 9159-10287 and later. Palo Alto Networks calls the coverage limited, and it requires decrypting management traffic. [PAN advisory][pan] |
| Exploitation evidence | Start date unknown | "Very limited exploitation has been observed targeting the Palo Alto Networks management interface." The advisory FAQ lists source IPs tied to exploit attempts. [PAN advisory][pan] |

## Detection

### Inventory and version

1. List every PA-Series and VM-Series firewall **and every Panorama** (virtual and M-Series). Cloud NGFW and Prisma Access need no action, according to the vendor.
2. Record the running PAN-OS version. In the GUI it appears under **Dashboard → General Information**. From the CLI, as a read-only operational command over an existing administrative session:

   ```text
   show system info | match sw-version
   ```

   Compare the result with the fixed builds for your minor-version range:

   | Branch | Running | Minimum fixed build |
   |---|---|---|
   | 12.2 | 12.2.0 through 12.2.3 | 12.2.4 |
   | 12.1 | 12.1.8 through 12.1.10-h\* | 12.1.10-h2 |
   | 12.1 | 12.1.5 through 12.1.7-h\* | 12.1.7-h8 (or 12.1.10-h2) |
   | 12.1 | 12.1.2 through 12.1.4-h\* | 12.1.4-h12 (or 12.1.10-h2) |
   | 11.2 | 11.2.14 through 11.2.15 | 11.2.16 |
   | 11.2 | 11.2.11 through 11.2.13-h\* | 11.2.13-h3 (or 11.2.16) |
   | 11.2 | 11.2.8 through 11.2.10-h\* | 11.2.10-h15 (or 11.2.16) |
   | 11.2 | 11.2.5 through 11.2.7-h\* | 11.2.7-h21 (or 11.2.16) |
   | 11.2 | 11.2.0 through 11.2.4-h\* | 11.2.4-h22 (or 11.2.16) |
   | 11.1 | 11.1.14 through 11.1.16-h\* | 11.1.16-h3 |
   | 11.1 | 11.1.11 through 11.1.13-h\* | 11.1.13-h15 (or 11.1.16-h3) |
   | 11.1 | 11.1.8 through 11.1.10-h\* | 11.1.10-h35 (or 11.1.16-h3) |
   | 11.1 | 11.1.7 through 11.1.7-h\* | 11.1.7-h11 (or 11.1.16-h3) |
   | 11.1 | 11.1.5 through 11.1.6-h\* | 11.1.6-h39 (or 11.1.16-h3) |
   | 11.1 | 11.1.0 through 11.1.4-h\* | 11.1.4-h37 (or 11.1.16-h3) |
   | 10.2 | 10.2.17 through 10.2.18-h\* | 10.2.18-h12 |
   | 10.2 | 10.2.14 through 10.2.16-h\* | 10.2.16-h11 (or 10.2.18-h12) |
   | 10.2 | 10.2.11 through 10.2.13-h\* | 10.2.13-h26 (or 10.2.18-h12) |
   | 10.2 | 10.2.8 through 10.2.10-h\* | 10.2.10-h41 (or 10.2.18-h12) |
   | 10.2 | 10.2.0 through 10.2.7-h\* | 10.2.7-h38 (or 10.2.18-h12) |

   Older, unsupported PAN-OS versions must move to a supported fixed version. The vendor says no special configuration is needed to be affected. This command was not run on a real device for this review.

### Management-interface exposure

Palo Alto Networks rates the risk **highest when the management interface is reachable from internet IP addresses**. The jump-box-only score of 8.5 still rates High, so restricting access lowers the risk but does not remove it.

- Review the **MGT port's Permitted IP Addresses** (Device → Setup → Interfaces → Management) **and every Interface Management Profile** attached to dataplane interfaces (Network → Network Profiles → Interface Mgmt), including GlobalProtect portal/gateway interfaces that also allow HTTPS or SSH management. Do this for Panorama too.
- Confirm from **outside** your network that the management web UI and SSH are not reachable. Use an authorized external attack-surface inventory or your firewall's own logs; do not send probes to third-party systems.
- Because exploitation requires authentication, list administrator accounts, their roles and authentication profiles, recent admin logins, and API keys. A compromised or weak admin credential is the realistic entry point.

### Log and IOC review

- Search traffic, NetFlow and firewall logs for management-plane connections from the vendor-listed IPs `66.42.72[.]14`, `208.83.239[.]114` and `149.248.47[.]234` (defanged here; source: [PAN advisory FAQ][pan]).
- Review **System** and **Configuration** logs for admin logins from unexpected sources or at unexpected times, new or changed admin accounts, unexpected commits, and changes to permitted IPs or management profiles. Where decryption of management traffic is configured, check Threat logs for **Threat ID 510046/510047**.
- Forward logs off the device. Root-level code execution could tamper with logs stored on the device. Finding no on-device evidence does not establish that no compromise occurred, and the vendor has published no host-level IOCs.

## Remediation

1. Upgrade each firewall and Panorama to the minimum fixed build for its branch (table above) or later. For 11.2.14 and 11.2.15 the only fix is **11.2.16** (published 2026-10-15). Follow Palo Alto Networks' upgrade path and compatibility notes. For HA pairs and Panorama-managed fleets, plan the upgrade order and take a configuration backup first; follow Palo Alto Networks' upgrade documentation for the order in which to upgrade Panorama and the devices it manages.
2. **Restrict the management interface now**, whatever the patch status: allow only trusted internal IPs or a dedicated jump box, remove management services from internet-facing dataplane interfaces, and follow the vendor's [management-access best practices][pan-bp].
3. Optional, partial mitigation: enable Threat IDs 510046/510047 (content 9159-10287+) on management traffic routed through a dataplane port with SSL decryption. Palo Alto Networks calls this coverage limited and says there are **no workarounds**.
4. Reduce the number of administrator accounts, enforce MFA or external authentication for admins, and rotate admin credentials and API keys if you have any doubt about them.
5. Rollback caution: downgrading below the fixed build reintroduces the vulnerability. Keep the pre-upgrade configuration export, not a vulnerable image, as your rollback artifact.

## Verification

- After upgrading, re-run `show system info` and confirm `sw-version` is at or above the fixed build. Do the same on both HA peers and on Panorama, and confirm the HA and Panorama connection status is healthy.
- From an approved internal administrative host, confirm that permitted administrators can still log in. From an untrusted network segment, confirm the management interface is unreachable. Do not run exploit code or authenticated injection tests against production.
- Confirm that log forwarding still works for the System, Config and Threat logs listed above.

## Compromise response

Root-level code execution on a firewall or Panorama means the device itself cannot be trusted. If IOCs or suspicious admin activity appear, isolate management access, preserve the tech-support file and logs held off the device, and engage Palo Alto Networks support. The advisory does not give a device-specific recovery procedure for this CVE, so ask support whether a factory reset or reimage is needed rather than only upgrading in place. Rotate everything stored on or passing through the device: local and external admin credentials, API keys, LDAP/RADIUS bind credentials, IPsec pre-shared keys, GlobalProtect and SSL decryption certificates and keys, and any secrets in the configuration. On Panorama, audit configuration pushed to managed firewalls during the exposure window. CISA marks this KEV entry as requiring forensic triage under BOD 26-04 for covered agencies. [KEV JSON][kev]

## Sources

- [Palo Alto Networks advisory][pan] and [CVE-JSON from the vendor][pan-json]: affected and fixed builds, scores, Panorama scope, exploitation status, Threat IDs, IOC IPs, 2026-10-15 update.
- [Palo Alto Networks CNA record][cve]: publication timestamps, CISA ADP SSVC.
- [NVD][nvd]: NVD CVSS 3.1 7.2; vendor CVSS 4.0 8.6.
- [CISA KEV JSON feed][kev]: `dateAdded`, `dueDate`, `requiredAction`.
- [Management access best practices][pan-bp]: exposure guidance referenced by the vendor.

[pan]: https://security.paloaltonetworks.com/CVE-2026-0322
[pan-json]: https://security.paloaltonetworks.com/json/CVE-2026-0322
[pan-bp]: https://live.paloaltonetworks.com/t5/community-blogs/tips-amp-tricks-how-to-secure-the-management-access-of-your-palo/ba-p/464431
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-0322
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-0322
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
