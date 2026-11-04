# Zyxel access points: LAN buffer overflow in zdp_wtp

**Last updated:** 2026-11-04 (America/New_York)

[Back to Zyxel access points summary](../black-october-2026.md#zyxel-access-points-lan-buffer-overflow-in-zdp_wtp) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-76955](https://www.cve.org/CVERecord?id=CVE-2026-76955): Zyxel (CNA) rates it CVSS 3.1 8.8 High.** A buffer overflow in the `zdp_wtp` binary lets a LAN-based attacker escalate privileges on affected access points, FWA7 units, and one security router. The vector is `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`: adjacent network, no login, no user interaction. The CVE record's description and product list name only NWA110AX through 7.12(ABTG.0)C0. Zyxel's advisory, dated 2026-11-03, names 42 access-point models, three FWA7 models, and the USG LITE 60AX. NVD has not scored it. CISA-ADP records Exploitation "none." [Advisory][adv]

**CISA KEV:** Not listed (catalog 2026.11.03, checked 2026-11-04). Zyxel does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| CVE record published | 2026-11-03 01:54:55 UTC | Zyxel CNA. CVSS 3.1 8.8. Names only NWA110AX. Updated 2026-11-04 04:56:27 UTC; still one product. [Record][cve] |
| Advisory | 2026-11-03; time/TZ unknown | Revision history: "2026-11-3: Initial release." The model table is wider than the CVE record. [Advisory][adv] |
| **Last updated** | **2026-11-04 (America/New_York)** | New item. |

## Detection

This is a LAN flaw in `zdp_wtp`, not a flaw in the wireless network itself. An attacker needs to reach the device from the local network. Zyxel says on-market products not listed are not affected.

The CVE record names one model. Use the advisory's table for the rest. Read the firmware from the running device.

**Access points.** Two firmware trains. The 7.12 models move from `.0` to `.1`. The 7.40 models move from `.1` to `.2`.

| Model | Affected | Install |
|---|---|---|
| IAP500BE | 7.40(ACPJ.1)C0 and earlier | 7.40(ACPJ.2)C0 |
| NWA110AX | 7.12(ABTG.0)C0 and earlier | 7.12(ABTG.1)C0 |
| NWA110BE | 7.40(ACLZ.1)C0 and earlier | 7.40(ACLZ.2)C0 |
| NWA130BE | 7.40(ACIL.1)C0 and earlier | 7.40(ACIL.2)C0 |
| NWA210AX | 7.12(ABTD.0)C0 and earlier | 7.12(ABTD.1)C0 |
| NWA210AXv2 | 7.40(ACSR.1)C0 and earlier | 7.40(ACSR.2)C0 |
| NWA210BE | 7.40(ACLY.1)C0 and earlier | 7.40(ACLY.2)C0 |
| NWA220AX-6E | 7.12(ACCO.0)C0 and earlier | 7.12(ACCO.1)C0 |
| NWA240BE | 7.40(ACQG.1)C0 and earlier | 7.40(ACQG.2)C0 |
| NWA30BE | 7.40(ACPI.1)C0 and earlier | 7.40(ACPI.2)C0 |
| NWA50AX | 7.12(ABYW.0)C0 and earlier | 7.12(ABYW.1)C0 |
| NWA50AX PRO | 7.12(ACGE.0)C0 and earlier | 7.12(ACGE.1)C0 |
| NWA50BE | 7.40(ACPB.1)C0 and earlier | 7.40(ACPB.2)C0 |
| NWA50BE MAX | 7.40(ACTP.1)C0 and earlier | 7.40(ACTP.2)C0 |
| NWA50BE PRO | 7.40(ACPC.1)C0 and earlier | 7.40(ACPC.2)C0 |
| NWA55AX PRO | 7.12(ACSP.0)C0 and earlier | 7.12(ACSP.1)C0 |
| NWA55AX PTP | 7.12(ACSQ.0)C0 and earlier | 7.12(ACSQ.1)C0 |
| NWA55AXE | 7.12(ABZL.0)C0 and earlier | 7.12(ABZL.1)C0 |
| NWA55BE | 7.40(ACPH.1)C0 and earlier | 7.40(ACPH.2)C0 |
| NWA90AX | 7.12(ACCV.0)C0 and earlier | 7.12(ACCV.1)C0 |
| NWA90AX PRO | 7.12(ACGF.0)C0 and earlier | 7.12(ACGF.1)C0 |
| NWA90BE | 7.40(ACPD.1)C0 and earlier | 7.40(ACPD.2)C0 |
| NWA90BE MAX | 7.40(ACTQ.1)C0 and earlier | 7.40(ACTQ.2)C0 |
| NWA90BE PRO | 7.40(ACPE.1)C0 and earlier | 7.40(ACPE.2)C0 |
| WAC500H | 6.70(ABWA.7)C0 and earlier | Hotfix on request |
| WAX300H | 7.12(ACHF.0)C0 and earlier | 7.12(ACHF.1)C0 |
| WAX510D | 7.12(ABTF.0)C0 and earlier | 7.12(ABTF.1)C0 |
| WAX610D | 7.12(ABTE.0)C0 and earlier | 7.12(ABTE.1)C0 |
| WAX620D-6E | 7.12(ACCN.0)C0 and earlier | 7.12(ACCN.1)C0 |
| WAX630S | 7.12(ABZD.0)C0 and earlier | 7.12(ABZD.1)C0 |
| WAX640S-6E | 7.12(ACCM.0)C0 and earlier | 7.12(ACCM.1)C0 |
| WAX650S | 7.12(ABRM.0)C0 and earlier | 7.12(ABRM.1)C0 |
| WAX655E | 7.12(ACDO.0)C0 and earlier | 7.12(ACDO.1)C0 |
| WBE510D | 7.40(ACLX.1)C0 and earlier | 7.40(ACLX.2)C0 |
| WBE530 | 7.40(ACLE.1)C0 and earlier | 7.40(ACLE.2)C0 |
| WBE630S | 7.40(ACLW.1)C0 and earlier | 7.40(ACLW.2)C0 |
| WBE660S | 7.40(ACGG.1)C0 and earlier | 7.40(ACGG.2)C0 |
| WBE665S | 7.40(ACQJ.1)C0 and earlier | 7.40(ACQJ.2)C0 |

**FWA7**

| Model | Affected | Install |
|---|---|---|
| FWA7 Leaf Plus | 7.40(ACQL.1)C0 and earlier | 7.40(ACQL.2)C0 |
| FWA7 Root | 7.40(ACUJ.1)C0 and earlier | 7.40(ACUJ.2)C0 |
| FWA7 Root Plus | 7.40(ACQK.1)C0 and earlier | 7.40(ACQK.2)C0 |

**Security router**

| Model | Affected | Install |
|---|---|---|
| USG LITE 60AX | V2.00(ACIP.0)C0 through V2.30(ACIP.1)C0 | V2.40(ACIP.0)C0, updated by cloud |

WAC500H has no public build. Zyxel says the hotfix is available on request from local support. USG LITE 60AX below V2.00(ACIP.0)C0 is outside the range Zyxel printed.

Nebula-managed devices still run this firmware. A cloud-managed access point is not exempt unless its running string is the patched one. Zyxel marks only the USG LITE 60AX fix as "updated by cloud."

## Remediation

1. Install the build in the table for that model. Match the build code in parentheses, not just the 7.12 or 7.40 prefix.
2. For WAC500H, ask Zyxel support for the hotfix. The advisory does not publish a filename.
3. For USG LITE 60AX, confirm the cloud update has moved the device to V2.40(ACIP.0)C0. Do not assume a cloud-connected router has already rebooted into it.
4. Zyxel lists no workaround. Restricting management to a trusted VLAN reduces who can send the request. It does not fix `zdp_wtp`.

## Verification

- The running firmware matches the Install column, including the parenthetical build code. `7.12(ABTG.0)C0` on an NWA110AX is still affected.
- WAC500H shows the hotfix support supplied, not 6.70(ABWA.7)C0.
- USG LITE 60AX shows V2.40(ACIP.0)C0. A device still on V2.30(ACIP.1)C0 has not taken the cloud update.
- A model the advisory does not list is not cleared by a neighbour's firmware.

## Compromise response

- Zyxel says the result is privilege escalation on the device. It does not say the attacker can cross from the LAN onto the wireless clients, and it does not publish indicators.
- Installing the patch does not remove an administrative credential or a configuration change made before the upgrade. Review both after the reboot.
- Zyxel and CISA-ADP report no exploitation. That is not a per-device clean bill.

## Sources

- [Zyxel AP, FWA7, and security-router advisory][adv] — 2026-11-03 initial release. Buffer overflow in `zdp_wtp`. LAN-based privilege escalation. Full model table, including the WAC500H hotfix and the cloud-updated USG LITE 60AX.
- [CVE-2026-76955][cve] — published 2026-11-03 01:54:55 UTC, updated 2026-11-04 04:56:27 UTC. CVSS 3.1 8.8, Zyxel CNA. Names only NWA110AX through 7.12(ABTG.0)C0.
- [NVD CVE-2026-76955][nvd] — NVD has no score of its own.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.03, checked 2026-11-04). CISA-ADP Exploitation "none."

[adv]: https://www.zyxel.com/global/en/support/security-advisories/zyxel-security-advisory-for-buffer-overflow-vulnerability-in-certain-aps-fwa7-and-security-routers-11-03-2026
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-76955
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-76955
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
