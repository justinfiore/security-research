# Telegram clients: rlottie sticker code execution and Desktop one-click file theft

**Last updated:** 2026-10-30 (America/New_York)

[Main Telegram summary](../black-october-2026.md#telegram-clients-rlottie-sticker-code-execution-and-desktop-one-click-file-theft) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

This item covers two High-rated Telegram client flaws with different platforms, conditions and fixes, plus related unscored research.

| Issue | Rating | Affected / fixed | Conditions |
|---|---|---|---|
| [CVE-2026-111105](https://www.cve.org/CVERecord?id=CVE-2026-111105): rlottie animated-sticker numeric truncation → code execution | ZDI (CNA) CVSS 3.0 **7.0** High (`AV:L/AC:H/PR:N/UI:R/S:U/C:H/I:H/A:H`); NVD "Awaiting Analysis" | CNA lists Telegram 6.6.2 as affected (no platform named; other versions unknown). **No vendor fix statement**; see [patch status](#patch-status-by-client). | ZDI: the target must open a malicious file or visit a malicious page. |
| [CVE-2026-107181](https://www.cve.org/CVERecord?id=CVE-2026-107181): Telegram Desktop IPC record-separator injection → local file exfiltration and account takeover | VulnCheck (CNA) CVSS 4.0 **8.6** High; CVSS 3.1 8.1 High | Telegram Desktop **before 7.2.9**; fixed in **7.2.9** | One click on an external link that redirects to a crafted `tg://` link. The researcher's chain also relies on Desktop auto-downloading a file received in a group. |

**CVE-2026-111105 (stickers).** ZDI reports a numeric-truncation flaw in rlottie, the library Telegram clients have used to render animated (TGS) stickers. Malformed input can write before the start of an allocated buffer and execute code in the Telegram process. ZDI published it as a **0-day** after Telegram said on 2026-03-31 that server-side sticker validation mitigated it.

**CVE-2026-107181 (Desktop).** Telegram Desktop passes externally opened links to its running instance over a local socket without escaping the record separator. A crafted link can inject commands that reach the internal `interpret:` scheme. That scheme uploads an attacker-chosen local file, including `tdata` session files, to an attacker's chat, enabling account takeover. Telegram fixed it in 7.2.9 without an advisory; the changelog mentions only a rendering fix.

**Related unscored research (no CVE, no score; not the basis for this item):**
- *Sticker zero-click.* At OffensiveCon Tokyo on 2026-10-28, Saifeldeen Aziz presented what his abstract describes as new zero-click rlottie bugs plus bypasses of Telegram's sticker validation, chained to code execution in Telegram for iOS. He acknowledged limitations of that exploit. No details, CVE or score have been published.
- *Android voice calls.* On 2026-10-29, NebuSec disclosed that a Telegram Android call flaw let a caller run code once the victim answered, saying it was "Fixed in Telegram Android 12.10.4 (7099)". It was demonstrated in a video, with no write-up, CVE or score.

**Worst case:** code running in the Telegram app, or theft of the Desktop session files. Either gives an attacker the victim's Telegram account and everything the app can reach.

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). CISA ADP SSVC records exploitation as "none" for CVE-2026-111105 and "poc" for CVE-2026-107181, where a public write-up exists. No reviewed primary source reports in-the-wild exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Patch status by client](#patch-status-by-client)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| rlottie flaw reported to Telegram | 2026-03-26; time/TZ unknown | ZDI-CAN-30207. Telegram replied on 2026-03-31 that server-side validation mitigated it, and on 2026-04-14 asked for a full RCE chain. [ZDI][zdi] |
| Desktop IPC flaw reported | 2026-06-25; time/TZ unknown | Reported through ZDI. [Write-up][beaksec] |
| Android source switches to tlottie | 2026-08-22 06:52 UTC (source commit) | Android 12.10.0 (7031); 12.9.2 still used rlottie. [Android source][android-tlottie] |
| Desktop source switches to tlottie | 2026-09-07 12:53 UTC (lib_lottie commit) | First included in Desktop **7.2.7** (release 2026-09-07 19:09 UTC). [lib_lottie][desktop-tlottie] [7.2.7][desktop-727] |
| iOS source adds tlottie behind a killswitch | 2026-09-11 16:31 UTC (source commit) | Added alongside rlottie; the server can roll it back (`ios_killswitch_disable_tlottie`). [iOS commit][ios-commit] |
| Desktop IPC fix | 2026-09-16 17:42 UTC (commit) | "Remove legacy interpret path helper". [Commit][desktop-fix] |
| Desktop 7.2.9 published | 2026-09-17 09:31 UTC | First version unaffected by CVE-2026-107181. [7.2.9][desktop-729] |
| Android 12.10.4 (7099) | 2026-09-24 12:17 UTC (source commit) | NebuSec names this as the fix for its call flaw. [Android source][android-12104] |
| Desktop write-up | 2026-10-03; time/TZ unknown | Public technical disclosure. [Write-up][beaksec] |
| CVE-2026-107181 published | 2026-10-07 13:35 UTC | VulnCheck CNA. [CVE record][cve-desktop] [VulnCheck][vulncheck] |
| ZDI 0-day advisory and CVE-2026-111105 published | 2026-10-15 17:42 UTC (CVE record) | ZDI-26-757. [ZDI][zdi] [CVE record][cve-sticker] |
| Sticker zero-click research presented | 2026-10-28; time/TZ unknown | OffensiveCon Tokyo. [Abstract][talk] |
| Telegram statement on rlottie | 2026-10-28 20:50 (X display time; TZ not established) | "It was a flaw in the rLottie library itself… already been fixed with tLottie." [Telegram on X][telegram-x] |
| NebuSec Android call-flaw disclosure | 2026-10-29 00:26 (X display time; TZ not established) | [NebuSec on X][nebusec] |

## Patch status by client

Telegram has published **no security advisory** for any issue in this item. For CVE-2026-111105, the evidence below comes from Telegram's public client source. A renderer change in source is not a vendor-confirmed CVE fix.

| Client | Minimum version to run | Basis |
|---|---|---|
| Desktop (Windows, macOS, Linux) | **7.2.9+** | Fixes CVE-2026-107181 (CNA record). It also includes the tlottie switch (from 7.2.7). Current at review: 7.3.4 (2026-10-29). |
| Android | **12.10.4+** | 12.10.0+ renders with tlottie instead of rlottie. NebuSec names 12.10.4 as the fix for its unscored call flaw. |
| iOS / macOS (Swift app) | Current release; **fix unconfirmed** | The iOS source still includes rlottie, and the server can switch rendering back to it. This guide did not review the separate macOS client. |
| Third-party clients and other rlottie users | Check each vendor | Telegram says the flaw is in rLottie itself, so its client changes do not cover them. |

## Detection

1. Inventory Telegram installs through MDM or software inventory, including portable Desktop builds, unofficial clients and other apps that bundle rlottie.
2. Flag Desktop **< 7.2.9** and Android **< 12.10.4**. For iOS/macOS, a version number cannot show which sticker renderer is active.
3. For CVE-2026-107181, look on Desktop endpoints for unexpected `.txt` "instruction" files that were auto-downloaded from groups into the download folder. Also check the Telegram account for sessions or messages that sent `tdata` or other local files to unfamiliar channels. Finding nothing proves little: no IOCs are published for any of these issues.

## Remediation

1. Update Desktop to **7.2.9 or later** and Android to **12.10.4 or later** (current releases preferred), then restart the app.
2. On iOS/macOS, stay on the current release and watch for a Telegram statement. No fix version is established there.
3. Until Desktop is updated, apply the researcher's interim mitigations: enable **Ask where to save each file**, which stops automatic downloads, and allow only contacts to add you to groups.
4. High-risk users can also limit who can message and call them under **Settings → Privacy and Security** and decline calls from unknown accounts. These are mitigations, not patches.

## Verification

- Confirm the full version in **Settings** (Android: bottom of the page; Desktop: Settings → About or the version line) or in MDM inventory.
- Check ordinary trusted links, stickers and calls. Do not use proof-of-concept links, stickers or calls.

## Compromise response

If a Desktop install older than 7.2.9 may have been targeted, assume its session files were stolen. From a trusted device, terminate all other sessions (**Settings → Devices**), then set or rotate the two-step verification password and review the account's chats and channels. For suspected sticker or call exploitation, preserve crash logs and the chat or call involved, and assess the device with endpoint or mobile incident-response tooling. Code execution inside the app does not by itself establish compromise of the whole device.

## Sources

- [ZDI-26-757][zdi] and [CVE-2026-111105][cve-sticker] / [NVD][nvd-sticker] — rlottie flaw, score, conditions, vendor responses, NVD status.
- [CVE-2026-107181][cve-desktop], [VulnCheck advisory][vulncheck], [researcher write-up][beaksec], [fix commit][desktop-fix], [7.2.9 release][desktop-729] — Desktop flaw, scores, affected/fixed versions, timeline, mitigations.
- [OffensiveCon abstract][talk], [Telegram on X][telegram-x], [NebuSec on X][nebusec] — unscored research and vendor statement.
- Telegram source: [Android 12.10.0][android-tlottie], [Android 12.10.4][android-12104], [Desktop lib_lottie][desktop-tlottie], [Desktop 7.2.7][desktop-727], [iOS tlottie killswitch][ios-commit].
- [CISA KEV JSON feed][kev] — catalog 2026.10.29 status.

[zdi]: https://www.zerodayinitiative.com/advisories/ZDI-26-757/
[cve-sticker]: https://www.cve.org/CVERecord?id=CVE-2026-111105
[nvd-sticker]: https://nvd.nist.gov/vuln/detail/CVE-2026-111105
[cve-desktop]: https://www.cve.org/CVERecord?id=CVE-2026-107181
[vulncheck]: https://www.vulncheck.com/advisories/telegram-desktop-before-7.2.9-ipc-record-injection-file-exfiltration-via-interpret-scheme
[beaksec]: https://beaksec.github.io/posts/telegram-desktop-one-click-account-takeover/
[desktop-fix]: https://github.com/telegramdesktop/tdesktop/commit/db3405699f8fc3ae28a58d2348b7d13a43c0590a
[desktop-729]: https://github.com/telegramdesktop/tdesktop/releases/tag/v7.2.9
[desktop-727]: https://github.com/telegramdesktop/tdesktop/releases/tag/v7.2.7
[desktop-tlottie]: https://github.com/desktop-app/lib_lottie/commit/46e0f003a13a29402a80e19bc88eabcbd4f8d65d
[android-tlottie]: https://github.com/DrKLO/Telegram/commit/4e1a61eca6c9b6ee3aa9c35cf8c70554750f2439
[android-12104]: https://github.com/DrKLO/Telegram/commit/c84801762fd5f936c8296ecf09a14a48ebfc4fe4
[ios-commit]: https://github.com/TelegramMessenger/Telegram-iOS/commit/d61fff0fdc968f686fe9b29e91705ce04bddcd23
[talk]: https://www.offensivecon.jp/speakers/2026/saifeldeen-aziz.html
[telegram-x]: https://x.com/telegram/status/2115546860764963218
[nebusec]: https://x.com/nebusecurity/status/2115601122727702634
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
