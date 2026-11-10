# Apple: an iMessage group accepts an outsider, and a nearby Bluetooth device corrupts memory

**Last updated:** 2026-11-10 (America/New_York)

[Back to Apple summary](../black-october-2026.md#apple-an-imessage-group-accepts-an-outsider-and-a-nearby-bluetooth-device-corrupts-memory) · [Changelog](../../CHANGELOG.md)

Apple released security updates on November 9. Two of the flaws in them have a High score. Apple publishes no score of its own.

**CISA-ADP scores [CVE-2026-113961](https://www.cve.org/CVERecord?id=CVE-2026-113961) CVSS 3.1 7.5 High.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N`. Apple's description is an authorization issue in Messages: a remote attacker may be able to join an iMessage group chat and receive its messages. The ADP record, timestamped 2026-11-09 21:02:34 UTC, says Exploitation none, Automatable yes, and Technical Impact partial. Apple's record has no score, and NVD has added none of its own. The score above is CISA-ADP's, not Apple's.

**CISA-ADP scores [CVE-2026-113970](https://www.cve.org/CVERecord?id=CVE-2026-113970) CVSS 3.1 8.8 High.** The vector is `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Apple's description is a use after free in Bluetooth: an attacker in Bluetooth range may be able to corrupt process memory. The ADP record says Exploitation none, Automatable no, and Technical Impact total. Apple's record has no score.

The same updates fix seven more issues. None of those reaches 7.0. [CVE-2026-113960](https://www.cve.org/CVERecord?id=CVE-2026-113960) lets someone newly added to a group read messages sent before they joined, and it has no score. [CVE-2026-113964](https://www.cve.org/CVERecord?id=CVE-2026-113964) and [CVE-2026-113965](https://www.cve.org/CVERecord?id=CVE-2026-113965) are 5.4: a device in Bluetooth range can pair without the user. [CVE-2026-113968](https://www.cve.org/CVERecord?id=CVE-2026-113968) is 5.4, an AirPlay pairing-code limit. [CVE-2026-113963](https://www.cve.org/CVERecord?id=CVE-2026-113963) is 5.5, an app reading sensitive data. [CVE-2026-113969](https://www.cve.org/CVERecord?id=CVE-2026-113969) has no score. iOS 27.2.1 also lists [CVE-2026-111497](https://www.cve.org/CVERecord?id=CVE-2026-111497), the Brotli decoder flaw already tracked [separately](brotli.md).

**CISA KEV:** Not listed (catalog 2026.11.09, checked 2026-11-10). Neither High CVE is in the feed, and neither is any of the other seven. CISA-ADP records Exploitation none for both High CVEs. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fixes** | **2026-11-09; time/TZ unknown** | Apple's security releases page dates every update November 9. The page does not give a time. [Releases][releases] |
| CVE records published | 2026-11-09 20:27:59–20:28:01 UTC | Apple CNA. No CVSS score in either record. [CVE-2026-113961][cve961] [CVE-2026-113970][cve970] |
| CISA-ADP scores | 2026-11-09 21:02:34 UTC | 7.5 High for the iMessage flaw, 8.8 High for the Bluetooth flaw. Exploitation none for both. |
| **Last updated** | **2026-11-10 (America/New_York)** | New item. Install the November 9 update. |

## Detection

1. Read the installed version. On an iPhone or iPad, Settings, General, About, iOS Version or iPadOS Version. On a Mac, Apple menu, About This Mac. On Apple Watch, the Watch app, General, About. On Apple Vision Pro, Settings, General, About.
2. The iMessage flaw, CVE-2026-113961, is fixed below these versions: iOS and iPadOS **26.7.3** and **27.2.1**, macOS Sequoia **15.8.3**, macOS Tahoe **26.7.3**, macOS Golden Gate **27.2.1**, visionOS **27.2.1**, and watchOS **27.2.1**. The CVE record does not list iOS 18, and the [iOS 18.7.12 notes][ios18] do not list this CVE. An iPhone XS, XS Max, or XR on 18.7.12 is still inside the range the record calls affected for this flaw.
3. The Bluetooth flaw, CVE-2026-113970, adds one more line: iOS and iPadOS **18.7.12**. The same notes list it. watchOS **26.6.1** is also a fix line for this flaw only.
4. A version number does not show whether a group was joined or whether a nearby device corrupted memory. Apple names no log line.

## Remediation

Install the November 9 update for the device's line, then restart.

| Device | Install |
|---|---|
| iPhone 11 and later, and the iPads listed for 27 | iOS or iPadOS **27.2.1** ([notes][ios27]) |
| iPhone 11 and later, and the iPads listed for 26, that stay on 26 | iOS or iPadOS **26.7.3** ([notes][ios26]) |
| iPhone XS, XS Max, XR, iPad 7th generation | iOS or iPadOS **18.7.12** ([notes][ios18]). This closes the Bluetooth flaw. It does not list the iMessage flaw. |
| Mac | macOS Sequoia **15.8.3**, macOS Tahoe **26.7.3**, or macOS Golden Gate **27.2.1** |
| Apple Watch | watchOS **27.2.1**, or **26.6.1** for the Bluetooth flaw |
| Apple Vision Pro | visionOS **27.2.1** |

Apple publishes no workaround. The update does not show whether a group was already joined or whether a nearby device already corrupted memory.

## Verification

- The version in Settings is one of the builds in the table, or later.
- Check each device on its own. An updated iPhone does not update a Mac signed into the same Apple Account.
- An iPhone on 18.7.12 has the Bluetooth fix and does not have the iMessage fix. The CVE record gives no 18.x build for that one.

## Compromise response

CISA-ADP says Exploitation none for both flaws, and Apple's notes do not mention attacks. If a group shows a member nobody added, or messages arrived for someone who was not in it, treat that as a lead and not as proof this CVE was used. Remove the member, and review what that group exchanged. The update does not remove a message already received.

## Sources

- [Apple security releases][releases] — iOS 27.2.1, iOS 26.7.3, iOS 18.7.12, macOS Golden Gate 27.2.1, macOS Sequoia 15.8.3, and the other November 9 updates, each dated 09 Nov 2026 with no time.
- [iOS 27.2.1 and iPadOS 27.2.1][ios27] — nine entries. Messages CVE-2026-113961 and CVE-2026-113960, Bluetooth CVE-2026-113970, CoreUtils CVE-2026-113964 and CVE-2026-113965, AirPlay CVE-2026-113968, rapportd CVE-2026-113969, App Intents CVE-2026-113963, and brotli CVE-2026-111497. Published Date November 09, 2026.
- [iOS 18.7.12 and iPadOS 18.7.12][ios18] — lists CVE-2026-113970 and does not list CVE-2026-113961.
- [CVE-2026-113961][cve961] — Apple CNA. Published 2026-11-09 20:27:59 UTC. No CNA score. CISA-ADP CVSS 3.1 7.5 High, timestamp 2026-11-09 21:02:34 UTC. Exploitation none, Automatable yes, Technical Impact partial.
- [CVE-2026-113970][cve970] — Apple CNA. Published 2026-11-09 20:28:01 UTC. No CNA score. CISA-ADP CVSS 3.1 8.8 High. Exploitation none, Automatable no, Technical Impact total.
- [CISA KEV JSON feed][kev] — neither CVE is listed (catalog 2026.11.09, checked 2026-11-10).

[releases]: https://support.apple.com/en-us/100100
[ios27]: https://support.apple.com/en-us/149715
[ios26]: https://support.apple.com/en-us/149716
[ios18]: https://support.apple.com/en-us/149717
[cve961]: https://www.cve.org/CVERecord?id=CVE-2026-113961
[cve970]: https://www.cve.org/CVERecord?id=CVE-2026-113970
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
