# Lenovo XClarity Controller: a factory reset restores the OpenBMC root password

**Last updated:** 2026-11-13 (America/New_York)

[Back to Lenovo summary](../black-october-2026.md#lenovo-xclarity-controller-a-factory-reset-restores-the-openbmc-root-password) · [Changelog](../../CHANGELOG.md)

ThinkSystem v4 servers use XClarity Controller 3, Lenovo's baseboard management controller. [CVE-2026-81936](https://www.cve.org/CVERecord?id=CVE-2026-81936) puts the default OpenBMC root password back after a reset to defaults.

**Lenovo rates CVE-2026-81936 CVSS 4.0 7.1 High and CVSS 3.1 6.8 Medium.** The 4.0 vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:H/UI:A/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:H/UI:R/S:U/C:H/I:H/A:H`. Both are on the same Lenovo record, published November 11. A regression in firmware (2.51) IHX432Y through (2.56) IHX436K reintroduces the default OpenBMC root password when someone runs an XCC Reset to Default. Lenovo says that credential then reaches the enabled administrative interfaces, and also the controller's own operating system, which is not normally reachable. The attack needs high privileges and a user action, and the 4.0 vector adds an attack precondition.

Lenovo says only those versions are affected and that they are no longer available for download. The CVE record names no fixed version and points only at a [product page](https://lenovopress.lenovo.com/lp2273-lenovo-xclarity-controller-3-xcc3). [LEN-226771](https://pcsupport.lenovo.com/us/en/product_security/LEN-226771), revision 1 dated 2026-10-13, says to update to **2.97 (IHX438R) or later**, and its product table sets IHX438R as the minimum fixed firmware for the listed ThinkSystem and ThinkAgile V4 models.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-12). The record does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Advisory LEN-226771 | 2026-10-13; time unknown | Lenovo's advisory index lists it as first published and last updated that day. [Index][index] |
| **Public CVE record** | **2026-11-11; time unknown** | Lenovo CNA. CVSS 4.0 7.1 and CVSS 3.1 6.8. [Record][cve] |
| **Last updated** | **2026-11-13 (America/New_York)** | LEN-226771 names firmware 2.97 (IHX438R). |

## Detection

1. **Which controller.** This is XClarity Controller 3 on ThinkSystem v4. An older XCC is not this flaw.
2. **Firmware.** Affected builds are (2.51) IHX432Y through (2.56) IHX436K. Lenovo says only those versions are affected.
3. **Whether a reset happened.** The password comes back only after an XCC Reset to Default. A controller on one of those builds that was never reset still has the password it had.

## Remediation

1. Update to **2.97 (IHX438R) or later**. LEN-226771 names that build as the minimum fixed firmware for the listed ThinkSystem and ThinkAgile V4 models. The CVE record still names no fixed build and only says the affected versions are no longer available for download, so use the advisory rather than the record when you pick the file.
2. After any Reset to Default on a controller that was inside that range, change the root password before the controller is reachable again. Lenovo does not publish the default password in this record, and this guide does not repeat one.
3. The firmware change does not show whether the default password was already used.

## Verification

- The controller reports **2.97 (IHX438R) or later**, and the root password is not the default.
- Do not test the default password against a controller that is reachable.

## Compromise response

The record publishes no indicator.

- If a controller in that range was reset and then reachable, review who signed in to the administrative interfaces and to the controller's own operating system.
- Change the root password. A password set after the reset is the one that matters; the firmware change does not expire a session that already used the default.

## Sources

- [CVE-2026-81936][cve] — Lenovo CNA, published 2026-11-11. CVSS 4.0 7.1 and CVSS 3.1 6.8. Affected (2.51) IHX432Y through (2.56) IHX436K. The record names no fixed version.
- [LEN-226771](https://pcsupport.lenovo.com/us/en/product_security/LEN-226771) — revision 1, 2026-10-13. Update to 2.97 (IHX438R) or later. The advisory body was read from Lenovo's content API on 2026-11-13; the support HTML page returned 403.
- [Lenovo Press, XCC3](https://lenovopress.lenovo.com/lp2273-lenovo-xclarity-controller-3-xcc3) — the only reference on the CVE record. A product page, not a remediation note.
- [Lenovo advisory index][index] — LEN-226771, "Lenovo XClarity Controller 3 Reset to Default Vulnerability," first published 2026-10-13.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-12. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-81936
[index]: https://support.lenovo.com/us/en/product_security/ps500001
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
