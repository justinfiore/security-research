# Opengear console servers: unauthenticated web buffer overflow

**Last updated:** 2026-10-31 (America/New_York)

[Main Opengear summary](../black-october-2026.md#opengear-console-servers-unauthenticated-web-buffer-overflow) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-102212](https://www.cve.org/CVERecord?id=CVE-2026-102212) — Digi / Opengear (CNA) CVSS 4.0 8.4 High** (`AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H/E:U/S:P/AU:Y/RE:L/U:Red`). NVD has not published its own score. Opengear's notice calls the same issue critical and says an unauthenticated attacker with network access to the management interface can execute arbitrary code. The CNA description is narrower: a crafted multipart POST with an overlong `Content-Disposition` name crashes `index.cgi`. Both statements are from the vendor. Exploit maturity in the vector is Unreported.

Affected firmware is **4.8.0 through 5.5.2** on **IM7200, CM7100, and ACM7000**. Opengear says Lighthouse, and the OM1200, OM1300, OM2200, CM8000, and CM8100 series, are not affected. The fix is firmware **5.5.3**.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-10-31). Opengear does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Report | Unknown | Opengear says a third-party researcher reported it. No name or date. |
| Vendor notice and CVE | 2026-10-31; notice "First Published" date only, time/TZ unknown. CVE record 2026-10-31 16:01:56 UTC | [Opengear notice][notice] [CVE][cve] |
| Fixed firmware | 5.5.3; release-note time not read | Opengear says 5.5.3 is on the customer portal. The release-notification page was not separately fetched. |

## Detection

1. Read the firmware version on the appliance, or from the management platform's inventory, for IM7200, CM7100, and ACM7000 units. 4.8.0 through 5.5.2 is affected. 5.5.3 or later is the fixed release Opengear names.
2. Confirm the model. Lighthouse and the OM1200, OM1300, OM2200, CM8000, and CM8100 series are not affected, per the notice.
3. The attack needs network access to the web management interface. An interface you cannot confirm is unreachable from untrusted networks is unknown, not safe.

## Remediation

1. Upgrade affected appliances to firmware **5.5.3** from Opengear's customer portal, then confirm the running version.
2. Until that firmware is running, restrict the web management interface to trusted networks and do not expose it to the internet. Opengear states that containment explicitly. It is not a substitute for 5.5.3.

## Verification

- The appliance reports 5.5.3 or later, and an administrator can still open the management UI from the trusted network.
- Do not send an overlong multipart request to a production appliance to test the crash.

## Compromise response

If the web interface was reachable on 4.8.0–5.5.2, preserve logs and the configuration before cleanup. Look for unexpected admin accounts, changed serial-port or VPN settings, and new outbound connections from the appliance. Upgrading closes the overflow Opengear describes; it does not show whether code already ran. Treat a console server that may have been reached as a foothold into the devices behind it, and review those sessions.

## Sources

- [Opengear notice][notice] — first published 2026-10-31: affected series, unaffected series, code execution, firmware 5.5.3, and the network restriction.
- [CVE-2026-102212][cve] — Digi CNA, published 2026-10-31 16:01:56 UTC, CVSS 4.0 8.4 High. The record's description is a crash of `index.cgi`, not the code-execution wording in the notice.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.30).

[notice]: https://portal.opengear.com/customerservice/s/article/CVE-2026-102212-Opengear-Console-Server-Buffer-Overflow-to-RCE
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-102212
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
