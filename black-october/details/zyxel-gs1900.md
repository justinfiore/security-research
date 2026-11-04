# Zyxel GS1900: unauthenticated command execution from the LAN

**Last updated:** 2026-11-04 (America/New_York)

[Back to Zyxel GS1900 summary](../black-october-2026.md#zyxel-gs1900-unauthenticated-command-execution-from-the-lan) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-107441](https://www.cve.org/CVERecord?id=CVE-2026-107441): Zyxel (CNA) rates it CVSS 3.1 8.8 High.** An out-of-bounds write in the CGI program of GS1900 series firmware can let a LAN-based attacker with no login run operating-system commands through a crafted HTTP request. The vector is `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`: adjacent network, not the internet. Zyxel's advisory, dated 2026-11-03, lists ten models and a patched build for each. The CVE record's description names only the GS1900-24E ceiling; the record's product list matches the advisory's ten models. NVD has not scored it. CISA-ADP records Exploitation "none." [Advisory][adv]

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
| CVE record published | 2026-11-03 01:41:52 UTC | Zyxel CNA. CVSS 3.1 8.8. Record updated 2026-11-04 04:56:27 UTC; the product list still matches the advisory. [Record][cve] |
| Advisory | 2026-11-03; time/TZ unknown | Revision history: "2026-11-3: Initial release." Patches for ten models still in the vulnerability support period. [Advisory][adv] |
| **Last updated** | **2026-11-04 (America/New_York)** | New item. |

## Detection

The flaw is in the switch firmware's CGI program. It is reachable from the LAN, without a login. It is not an internet-facing flaw unless someone has bridged the management interface out.

Zyxel says on-market products not in this table are not affected. Read the firmware string from the running switch.

| Model | Affected | Install |
|---|---|---|
| GS1900-8 | 2.90(AAHH.2)C0 and earlier | 2.90(AAHH.3)C0 |
| GS1900-8HP | 2.90(AAHI.2)C0 and earlier | 2.90(AAHI.3)C0 |
| GS1900-10HP | 2.90(AAZI.2)C0 and earlier | 2.90(AAZI.3)C0 |
| GS1900-16 | 2.90(AAHJ.2)C0 and earlier | 2.90(AAHJ.3)C0 |
| GS1900-24 | 2.90(AAHL.2)C0 and earlier | 2.90(AAHL.3)C0 |
| GS1900-24E | 2.90(AAHK.2)C0 and earlier | 2.90(AAHK.3)C0 |
| GS1900-24EP | 2.90(ABTO.2)C0 and earlier | 2.90(ABTO.3)C0 |
| GS1900-24HPv2 | 2.90(ABTP.2)C0 and earlier | 2.90(ABTP.3)C0 |
| GS1900-48 | 2.90(AAHN.2)C0 and earlier | 2.90(AAHN.3)C0 |
| GS1900-48HPv2 | 2.90(ABTQ.2)C0 and earlier | 2.90(ABTQ.3)C0 |

The CVE record prints the 24HPv2 product name as `GS1900-HPv2`. The advisory's model name is GS1900-24HPv2, and both use the build code ABTP. Treat ABTP as that model.

Zyxel publishes no indicators. A switch whose management interface answers HTTP from the LAN is in the condition the advisory describes. Absence of a logged request is not a clean bill.

## Remediation

1. Install the build in the table for that model. The patched build is the same 2.90 train with the third letter bumped (`.2` to `.3`). A newer-looking string from a different model does not apply.
2. Zyxel does not list a workaround. Keeping the management interface off untrusted LAN segments reduces who can send the request. It does not fix the CGI program.
3. Models Zyxel says are outside the vulnerability support period are not in the table and get no patch on this page. The advisory says on-market products not listed are not affected. It does not say an older, unsupported GS1900 is unaffected; it says those models were not given a patch here. If you run one, confirm with Zyxel rather than treating silence as a fix.

## Verification

- The running firmware string matches the "Install" column for that model, not merely a 2.90 build. `2.90(AAHK.2)C0` is still affected on the GS1900-24E.
- The string is from the switch that is forwarding traffic, not from a firmware file staged for later.
- A model not in the table is not cleared by installing some other model's `.3` build.

## Compromise response

- The result Zyxel names is operating-system command execution on the switch, with no login, from the LAN. A switch that was reachable from a LAN you do not trust may already have had its configuration read or changed.
- Installing the patch does not restore a configuration an attacker changed and does not remove an administrative credential they added. Review the admin accounts and the running configuration after the upgrade.
- Zyxel reports no exploitation. Do not treat that as proof a given switch was not touched.

## Sources

- [Zyxel GS1900 advisory][adv] — 2026-11-03 initial release. Ten models, affected ceilings, and the patched build for each. LAN-based, unauthenticated, OS commands through a crafted HTTP request.
- [CVE-2026-107441][cve] — published 2026-11-03 01:41:52 UTC, updated 2026-11-04 04:56:27 UTC. CVSS 3.1 8.8, Zyxel CNA. Description names GS1900-24E; the product list has all ten.
- [NVD CVE-2026-107441][nvd] — NVD has no score of its own. Shows the CNA 8.8.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.03, checked 2026-11-04). CISA-ADP Exploitation "none."

[adv]: https://www.zyxel.com/global/en/support/security-advisories/zyxel-security-advisory-for-out-of-bounds-write-vulnerability-in-gs1900-series-switches-11-03-2026
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-107441
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-107441
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
