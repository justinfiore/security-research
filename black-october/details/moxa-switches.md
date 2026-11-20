# Moxa Ethernet switches: one shared key, and firmware is not signed

**Last updated:** 2026-11-20 (America/New_York)

[Main Moxa summary](../black-october-2026.md#moxa-ethernet-switches-one-shared-key-and-firmware-is-not-signed) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Moxa makes managed Ethernet switches used on factory, rail, and power networks. [MPSA-268140][mpsa], version 1.0, released November 20, 2026, covers two flaws. Moxa is the CNA for both. Neither has a firmware fix. The advisory says every listed series is affected on all firmware versions, and the solution column says "Please refer to Mitigations."

**Moxa rates [CVE-2026-130493](https://www.cve.org/CVERecord?id=CVE-2026-130493) CVSS 4.0 7.7 High.** The vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:P/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. Moxa's table marks unauthenticated remote exploitation as Yes. By default the switch uses an RSA-1024 private key that is embedded in firmware Moxa publishes, and it uses that key to issue its own self-signed certificate. Someone who has the firmware can impersonate a switch. Moxa says that can compromise the confidentiality and integrity of the communication. The "under certain conditions" qualifier is Moxa's, and the advisory does not say what those conditions are.

**Moxa rates [CVE-2026-130494](https://www.cve.org/CVERecord?id=CVE-2026-130494) CVSS 4.0 8.6 High.** The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. An administrator can install firmware the switch does not check a signature on, and Moxa says that can run code. Moxa's table marks unauthenticated remote exploitation as No.

Chadi Charkaoui reported both. CERT-FR's November 20 notice, CERTFR-2026-AVI-1589, says no fix is available for either and points readers at Moxa's mitigations.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-20) for either CVE. Moxa does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-20; time/TZ unknown** | MPSA-268140 version 1.0. Both flaws High. No firmware fix. [Moxa][mpsa] |
| CERT-FR notice | 2026-11-20; time/TZ unknown | Says no fix exists for either CVE. [CERTFR-2026-AVI-1589][certfr] |
| **Last updated** | **2026-11-20 (America/New_York)** | New item. Replace the shared key. There is no firmware to install. |

## Detection

Read the model from the switch label or its web interface, and the firmware from the same page. The advisory lists these series, all firmware versions:

- EDS-E: EDS-510E, EDS-518E, EDS-528E, EDS-G508E, EDS-G512E, EDS-G516E, EDS-P506E
- IKS: IKS-6726A, IKS-6728A, IKS-G6524A, IKS-G6824A
- ICS: ICS-G7526A, ICS-G7528A, ICS-G7748A, ICS-G7750A, ICS-G7752A, ICS-G7826A, ICS-G7828A, ICS-G7848A, ICS-G7850A, ICS-G7852A
- PT: PT-G7728, PT-G7828
- EDS-A: EDS-405A, EDS-408A, EDS-505A, EDS-508A, EDS-510A, EDS-516A, EDS-518A, EDS-608, EDS-611, EDS-616, EDS-619, EDS-G509, EDS-P510A
- SDS: SDS-3006, SDS-3008, SDS-3010, SDS-3016, SDS-G3006, SDS-G3008, SDS-G3010, SDS-G3016
- TWS: TWS-3010-APL, TWS-3010-SPE
- TN: TN-4500A, TN-5500A, TN-G4500, TN-G6500

A Moxa switch that is not on that list is outside this advisory. The advisory does not say a newer firmware takes a listed model out of it.

## Remediation

There is no firmware fix. Moxa's mitigations are:

1. For CVE-2026-130493, regenerate the SSL certificate and the SSH key before the switch is commissioned, and renew both often. The factory key is the one in the published firmware. Replacing it is the step that takes that key out of use. Moxa points at the user manual for each series for the procedure.
2. For CVE-2026-130494, check the SHA-512 checksum on Moxa's product page before installing a firmware file. That checks the file you downloaded. It does not stop an administrator session from installing a different file.
3. Keep the management interface off the internet, and limit who can reach it. Moxa lists that under general recommendations, not as a fix for either flaw.

## Verification

- The switch presents a certificate you generated, not the factory certificate. Compare it with the one you issued.
- SSH to the switch accepts the key you generated.
- The management interface is not reachable from the internet.
- Do not try to present the factory key, and do not install a firmware file to test the signature check.

## Compromise response

Moxa publishes no indicator. A switch that was commissioned with the factory certificate and key, and whose management interface was reachable, is the one the advisory describes. Replacing the key does not show whether someone already used the old one. Review the switch configuration for an account or a management route you did not add.

## Sources

- [MPSA-268140][mpsa] — Moxa, version 1.0, released November 20, 2026. CVE-2026-130493 is CVSS 4.0 7.7, a shared RSA-1024 key, unauthenticated. CVE-2026-130494 is CVSS 4.0 8.6, unsigned firmware, needs an administrator. Every listed series is affected on all firmware versions. No firmware fix.
- [CVE-2026-130493](https://www.cve.org/CVERecord?id=CVE-2026-130493) and [CVE-2026-130494](https://www.cve.org/CVERecord?id=CVE-2026-130494) — Moxa CNA, published 2026-11-20. Same scores.
- [CERTFR-2026-AVI-1589][certfr] — CERT-FR, November 20, 2026. Says no fix is available for either CVE.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-20. Neither CVE is listed.

[mpsa]: https://moxa.com/en/support/product-support/security-advisory/mpsa-268140-cve-2026-130493,-cve-2026-130494-multiple-vulnerabilities-in-ethernet-switches
[certfr]: https://www.cert.cyber.gouv.fr/avis/CERTFR-2026-AVI-1589
