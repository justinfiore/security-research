# Signal calling (RingRTC): hang-up may not end a flooded call

**Last updated:** 2026-10-26 (America/New_York)

[Main Signal summary](../black-october-2026.md#signal-calling-ringrtc-hang-up-may-not-end-a-flooded-call) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-113380](https://www.cve.org/CVERecord?id=CVE-2026-113380): MITRE (CNA) CVSS 4.0 9.3 Critical (CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:P/VC:H/VI:H/VA:N/SC:H/SI:N/SA:N/S:P). NVD has not added its own score; the record is "Awaiting Analysis". Signal has published no advisory or score of its own.** RingRTC is the open-source calling library in Signal's Android, iOS and Desktop apps. Before 2.72.0, a call peer that saturates the call's finite-state-machine (FSM) event queue "can interfere with the ability of a local hangup to tear the call (with its audio and perhaps also video track) down". [CVE record][cve] Signal's fix commit is titled "Ensure calls terminate completely in corner cases". [Fix commit][fix]

**Attack conditions:** The attacker must be a participant in a call with the victim, which the CVSS vector reflects as passive user interaction (UI:P). No other privileges are needed. **Worst case:** the victim taps hang-up and believes the call has ended, but their microphone audio, and possibly camera video, keeps reaching the other participant. This is a call-teardown flaw. Neither the CVE record nor the fix describes any weakness in Signal's message or call encryption. [CVE record][cve] [Researcher notes][notes]

**Exploitation:** No exploitation reports were found. CISA's ADP SSVC enrichment on the CVE record (2026-10-20) marks Exploitation "none", Automatable "no" and Technical Impact "total". [CVE record][cve]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory client versions](#inventory-client-versions)
  - [Signs of abuse](#signs-of-abuse)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | No primary source establishes who found it or when. |
| Fix committed to RingRTC | 2026-09-04 20:15:36 UTC | Commit `4b1b6fa`, "Ensure calls terminate completely in corner cases", in the public repository. The fix was visible here but not identified as a security issue. [Fix commit][fix] |
| RingRTC 2.72.0 tagged | 2026-09-04 22:55:10 UTC | Version-bump commit `a1d2ffe` for tag `v2.72.0`. [Compare v2.71.0...v2.72.0][compare] |
| Signal Android 8.27.0 tagged | 2026-09-10 00:17:33 UTC | First Android tag bundling `ringrtc-android:2.72.0` (8.26.4 had 2.71.0). The Play Store rollout date is not established. [Android tag][android] |
| Signal iOS 8.30.0.1882 tagged | 2026-09-22 18:57:58 UTC | First release-numbered iOS tag with `SignalRingRTC (2.72.0)` (8.29.0.1866 had 2.71.0). The App Store date is not established. [iOS tag][ios] |
| Signal Desktop 8.29.0 released | 2026-10-01 21:20:34 UTC | GitHub release with `@signalapp/ringrtc` 2.72.0 (8.28.0 had 2.71.0). [Desktop release][desktop] |
| CVE published (public announcement) | 2026-10-20 04:25:10 UTC | MITRE as CNA. This is the first public identification as a vulnerability. [CVE record][cve] |
| Researcher write-up | 2026-10-20 05:31:37 UTC | Commit time of the notes and a synthetic, offline `poc.py` queue model, which the author says is "no exploit". [Researcher notes][notes] |
| NVD publication | 2026-10-20 05:16:54 UTC | Awaiting Analysis. [NVD][nvd] |
| CISA KEV | Not listed (catalog 2026.10.23) | Checked 2026-10-26. [KEV][kev] |

## Detection

### Inventory client versions

The fix is in RingRTC **2.72.0**. These are the first client builds that bundle it, verified from each client's dependency manifest at the tag:

| Client | First fixed build | Last build checked with 2.71.0 |
|---|---|---|
| Signal Android | **8.27.0** | 8.26.4 |
| Signal iOS | **8.30.0** (build 8.30.0.1882) | 8.29.0 (8.29.0.1866) |
| Signal Desktop (Windows, macOS, Linux) | **8.29.0** | 8.28.0 |

Third-party apps that embed RingRTC (for example, Desktop forks or builds from source) need RingRTC 2.72.0 or later. Check their own dependency manifests.

The commands below are **read-only**. They report installed versions and change nothing. They were not run against real devices.

```sh
# Linux Desktop (Debian/Ubuntu package from Signal's repository), any user:
dpkg-query -W -f='${Version}\n' signal-desktop

# macOS Desktop, any user (adjust the path if Signal is installed elsewhere):
defaults read /Applications/Signal.app/Contents/Info.plist CFBundleShortVersionString

# Android, from a workstation with adb and a device where USB debugging is authorized:
adb shell dumpsys package org.thoughtcrime.securesms | grep versionName
```

On Windows, check **Help → About** in Signal Desktop, or your software inventory or MDM data. On iOS, check the version under **Settings → Help** in Signal, or MDM inventory. For a fleet, use MDM or endpoint inventory, and remember that personal devices may sit outside it.

### Signs of abuse

There are no published indicators of compromise. The flaw sits in local call state, so organizations have no server-side log to check. User reports are the main signal. Look for:

- the call screen, or the OS microphone or camera indicator, staying active after hang-up;
- a call that does not end until the app is force-closed or the device goes offline;
- calls with unknown or untrusted contacts just before such behavior.

None of these proves exploitation, and their absence proves nothing either.

## Remediation

1. Update Signal through the official channel (Google Play or Signal's APK, the App Store, or Signal's Desktop download or package repository) to **Android 8.27.0+, iOS 8.30.0+, or Desktop 8.29.0+**.
2. Restart the app after updating, so the old process with the vulnerable library is no longer running.
3. **Until updated:** avoid accepting calls from unknown or untrusted contacts. After hanging up, confirm that the call screen and the OS microphone and camera indicators are gone before speaking. If they are not, force-close Signal, or turn off network access. The researcher notes give similar advice. [Researcher notes][notes]
4. Developers embedding RingRTC should move to 2.72.0 or later, rebuild and redistribute. [Compare v2.71.0...v2.72.0][compare]

## Verification

- Re-run the inventory above and confirm every device reports a fixed version. Compare against your MDM data rather than relying on users' word.
- As a benign functional control, place a call between two of your own updated devices, hang up from one, and confirm both sides end the call and the OS indicators turn off. Do not try to flood a call's event queue.

## Compromise response

- If a user reports a call that stayed live after hang-up, treat what was said or shown afterwards as potentially disclosed to the other participant. Assess the sensitivity of that material and notify the people affected.
- Record the contact, time and device version, then update the device.
- The flaw, as described, does not grant code execution or access to messages, so device reimaging is not indicated by this CVE alone.

## Sources

- [CVE record (MITRE CNA)][cve]: description, CVSS 4.0 score and vector, affected range, CISA ADP SSVC values.
- [RingRTC fix commit][fix] and [v2.71.0...v2.72.0 comparison][compare]: fix content and dates.
- Signal client tags and manifests: [Android v8.27.0][android], [iOS 8.30.0.1882][ios], [Desktop v8.29.0][desktop].
- [Researcher notes][notes] (third-party explanation; their simplified pseudocode is illustrative and has not been verified against Signal's source).
- [NVD][nvd]; [CISA KEV feed][kev].
- Secondary: [SecurityWeek][sw], [The Register][reg].

[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-113380
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-113380
[fix]: https://github.com/signalapp/ringrtc/commit/4b1b6fa53c9f30c87c8ea78e44675d4a13e1e4d3
[compare]: https://github.com/signalapp/ringrtc/compare/v2.71.0...v2.72.0
[android]: https://github.com/signalapp/Signal-Android/releases/tag/v8.27.0
[ios]: https://github.com/signalapp/Signal-iOS/releases/tag/8.30.0.1882
[desktop]: https://github.com/signalapp/Signal-Desktop/releases/tag/v8.29.0
[notes]: https://github.com/Imahian/Notes/tree/main/docs/CVEs/CVE-2026-113380
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[sw]: https://www.securityweek.com/signal-vulnerability-lets-malicious-callers-block-hang-ups
[reg]: https://www.theregister.com/security/2026/10/21/signal-bug-could-keep-your-mic-and-camera-on-after-hangup/5304528
