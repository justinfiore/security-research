# Elecbrakes: a phone in Bluetooth range applies the trailer brakes

**Last updated:** 2026-11-21 (America/New_York)

[Main Elecbrakes summary](../black-october-2026.md#elecbrakes-a-phone-in-bluetooth-range-applies-the-trailer-brakes) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Elecbrakes makes trailer brake controllers sold in Australia and New Zealand. The controller talks to a phone over Bluetooth Low Energy and applies the trailer's brakes. [ICSA-26-323-02][icsa], released November 19, 2026, covers three flaws. CISA ICS-CERT is the CNA. Patrick Forck and Jeremy McCarthy of Element Digital reported them.

**CISA rates [CVE-2026-96805](https://www.cve.org/CVERecord?id=CVE-2026-96805) CVSS 3.1 9.6 Critical and CVSS 4.0 8.5 High.** The CVSS 3.1 vector is `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:C/C:L/I:H/A:H`. The CVSS 4.0 vector is `CVSS:4.0/AV:A/AC:L/AT:N/PR:N/UI:N/VC:L/VI:H/VA:H/SC:N/SI:H/SA:H/S:P`. A Bluetooth Low Energy device in range writes the brake-control characteristic with no pairing and no PIN, and CISA says that can influence braking. The attack is adjacent, not over the internet.

**CISA rates [CVE-2026-125273](https://www.cve.org/CVERecord?id=CVE-2026-125273) CVSS 3.1 9.6 Critical and CVSS 4.0 8.5 High.** The CVSS 3.1 vector is `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:C/C:L/I:H/A:H`. The CVSS 4.0 vector is `CVSS:4.0/AV:A/AC:L/AT:N/PR:N/UI:N/VC:L/VI:H/VA:H/SC:L/SI:H/SA:H/S:P`. Commands have no sequence number, nonce, or session token, so a captured command can be replayed, and the last command stays on the device across sessions.

**CISA rates [CVE-2026-124281](https://www.cve.org/CVERecord?id=CVE-2026-124281) CVSS 3.1 6.1 Medium and CVSS 4.0 5.3 Medium.** The firmware-update channel is not protected, and CISA says that may allow an unauthorized firmware change. Element Digital says the image is checked with CRC32 and that the decryption key ships in the app. Elecbrakes told the researchers that a controller on the fixed firmware only enters update mode over an authenticated, bonded connection. The image itself is still unsigned.

The advisory's header table lists CVSS v3 9.6 for the EB2. Affected versions are **EB2 3.0.4.2.0 and earlier**, **VM1 before 1.3.4.2.1**, and **every ELBC2000**. The fixes are **EB2 3.0.4.4.3** and **VM1 1.3.4.2.1**. There is no fix for the ELBC2000, which is no longer sold. CISA says the vendor is determining how to address it. Element Digital says Elecbrakes confirmed the ELBC2000 has the same flaw at the end of October, and that the update does not install itself: the owner opens the app and starts it. Elecbrakes told the researchers it knows of no reported damage or injury.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-21) for any of the three. CISA's advisory says no known public exploitation specifically targeting these vulnerabilities has been reported to CISA. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to Elecbrakes | 2026-05-18; time/TZ unknown | Element Digital. [Write-up][element] |
| Fixed firmware | 2026-07-06; time/TZ unknown | EB2 3.0.4.4.3 and VM1 1.3.4.2.1. The owner starts the update in the app. [Element Digital][element] |
| ELBC2000 confirmed | 2026-10-30; time/TZ unknown | Elecbrakes told the researchers it is affected and has no fix. [Element Digital][element] |
| **Public announcement** | **2026-11-19; time/TZ unknown** | ICSA-26-323-02, initial release. [CISA][icsa] |
| **Last updated** | **2026-11-21 (America/New_York)** | New item. Update the EB2 and VM1. The ELBC2000 has no fix. |

## Detection

Read the model from the controller or from the Elecbrakes app, and the firmware version from the app. The advisory covers:

- EB2 at **3.0.4.2.0 or earlier**
- VM1 **before 1.3.4.2.1**
- every **ELBC2000**

A controller that is none of those three models is outside this advisory. Element Digital puts the radio range at roughly 10 to 100 metres, and says the brakes release 2 to 5 seconds after the attacker's Bluetooth connection drops. That is the researchers' measurement, not a figure in the CISA advisory. The controller has to be powered for the radio to answer.

## Remediation

1. On an EB2, open the Elecbrakes app and install firmware **3.0.4.4.3 or later**. On a VM1, install **1.3.4.2.1 or later**. The update does not install itself.
2. The ELBC2000 has no firmware. CISA says the vendor is still determining how to address it. Until one exists, the controller answers brake commands from any device in Bluetooth range while it is powered. Elecbrakes' advice, as the researchers record it, is to check the app for an ELBC2000 update and to contact Elecbrakes.
3. CISA's general advice is to keep control devices off the internet. These flaws are Bluetooth, so unplugging a network cable does not close them.

## Verification

- The app shows EB2 firmware **3.0.4.4.3 or later**, or VM1 firmware **1.3.4.2.1 or later**.
- An ELBC2000 still shows no update. Do not treat a missing prompt as a fix.
- Do not send brake commands from another phone to test the old firmware.

## Compromise response

CISA and Elecbrakes publish no indicator. Element Digital says a brake application ends when the attacker's connection drops, so a controller that was used before the update may show nothing. The firmware update does not record whether a command was sent. Elecbrakes told the researchers it knows of no reported damage or injury.

## Sources

- [ICSA-26-323-02][icsa] — CISA, initial release November 19, 2026. CVE-2026-96805 and CVE-2026-125273 are CVSS 3.1 9.6 Critical and CVSS 4.0 8.5 High. CVE-2026-124281 is CVSS 3.1 6.1 Medium. EB2 through 3.0.4.2.0, VM1 before 1.3.4.2.1, and every ELBC2000. Fixes are EB2 3.0.4.4.3 and VM1 1.3.4.2.1. No fix for the ELBC2000. No known exploitation reported to CISA.
- [Element Digital, Brake Check][element] — published November 19, 2026. Reports the May 18 disclosure, the July 6 firmware, the October 30 ELBC2000 confirmation, a 2 to 5 second release after disconnect, and that the firmware image is still unsigned.
- [CVE-2026-96805](https://www.cve.org/CVERecord?id=CVE-2026-96805), [CVE-2026-125273](https://www.cve.org/CVERecord?id=CVE-2026-125273), and [CVE-2026-124281](https://www.cve.org/CVERecord?id=CVE-2026-124281) — CISA ICS-CERT CNA.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-21. None of the three is listed.

[icsa]: https://www.cisa.gov/news-events/ics-advisories/icsa-26-323-02
[element]: https://elementdigital.com.au/blog/brake-check-trailer-brakes-over-bluetooth/
