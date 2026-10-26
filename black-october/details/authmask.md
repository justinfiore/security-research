# AuthMask: Microsoft Authenticator for Android token theft

**Last updated:** 2026-10-26 (America/New_York)

[Main AuthMask summary](../black-october-2026.md#authmask-microsoft-authenticator-for-android-token-theft) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-80097](https://www.cve.org/CVERecord?id=CVE-2026-80097) — Microsoft CVSS 3.1: 8.6 High; vendor severity: Important.** A malicious app on the same Android device can exploit improper caller authentication in the Authenticator broker to obtain tokens for the signed-in work account. The researcher demonstrated delegated access to mail, files and calendars, plus scopes for changing authentication methods/passkeys. This is **local privilege escalation and account-token disclosure**, not unauthenticated internet RCE or a general break of MFA.

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). No exploitation reported in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Establish the affected device and app profile](#establish-the-affected-device-and-app-profile)
  - [Preserve the interaction disagreement](#preserve-the-interaction-disagreement)
  - [Investigate account activity, not only app permissions](#investigate-account-activity-not-only-app-permissions)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Initial discovery/private report | Unknown | Enclave says it reported to MSRC; no exact dates in the publication. [Research][research] |
| Fixed Android build available | 2026-07; day/time/TZ unknown | Cyber Security News reports July availability of **6.2606.4246**; exact rollout date was not established in the reviewed primary sources. [Reporting][news] |
| Microsoft public disclosure | 2026-09-08 14:00 UTC | CNA `datePublic`; MSRC page dates the advisory September 8. [CVE JSON][cve] [MSRC][msrc] |
| CVE record published | 2026-09-08 17:13:54 UTC | Record metadata; not the initial discovery or app-release time. [CVE JSON][cve] |
| Fixed-build correction | 2026-09-15; time/TZ unknown | MSRC revision 1.1: “Corrected fix build number. Informational change only.” [MSRC][msrc] |
| Public AuthMask technical research | 2026-10-23; time/TZ unknown | Enclave publication. This explains inclusion in October despite the older fix/advisory. [Research][research] |
| User-supplied news lead | 2026-10-26; time/TZ unknown | News article and linked X post; not a new patch or original disclosure. [Reporting][news] [X lead][lead] |

## Detection

### Establish the affected device and app profile

1. Inventory **Microsoft Authenticator for Android**, package `com.azure.authenticator`, on each phone/tablet and each personal/work profile. The [Microsoft CNA record][cve] lists **6.0.0 through versions before 6.2606.4246** as affected; versions outside that stated range are not automatically cleared by this guide.
2. On the device, use Android **Settings → Apps → Microsoft Authenticator → App info** (labels vary by OEM) to record the installed version. Managed fleets should use current Intune/EMM app inventory and its last check-in time. A Play Store listing or update policy is not proof the installed profile updated.
3. Determine whether a **work account is signed into the broker** and whether an untrusted app ran on the same profile/device during the vulnerable period. The demonstrated chain impersonates an installed Microsoft first-party app; inspect Teams and other broker consumers, not only requested Android permissions.
4. If ADB is already authorized for your own device, this optional read-only command narrows the package output to its version. Run from a trusted host with Android platform-tools, replacing `DEVICE_SERIAL`; do not enable broad debugging solely to run a check:

   ```sh
   adb -s DEVICE_SERIAL shell dumpsys package com.azure.authenticator | grep 'versionName='
   ```

   Missing output, inaccessible profiles, offline devices, or an ADB error mean **unknown**, not unaffected. Version metadata is inventory evidence, not proof of artifact integrity or prior nonexploitation. No Android device was available to exercise this command in this review.
5. The repository's existing host/Python scripts do not inspect Android apps. This issue's confirmed product scope is Android; do not apply its fix-build threshold to iOS or confuse it with TOTP seed extraction from every authenticator app.

### Preserve the interaction disagreement

Microsoft's CVSS vector includes **UI:R**, and its FAQ says the attacker installs/runs a malicious app and convinces the user to complete an Authenticator authentication flow. Enclave reports **no further user approval** in its tests once the broker holds a signed-in work account. Preserve both statements: “zero Android permissions” does **not** mean remote exploitation without a malicious local app. Do not treat absence of a remembered prompt as clearance. [MSRC][msrc] [Research][research]

### Investigate account activity, not only app permissions

- Retain app installation/update history, EMM/MTD alerts, relevant device evidence and Entra sign-in/audit logs. Record nonsecret app IDs, device IDs and time windows; do not export access/refresh tokens into tickets or this guide.
- Correlate unfamiliar resource access or sign-ins with first-party Microsoft client identities, device/app history, mailbox changes, sent mail, file access, and calendar modifications. The broker can issue tokens under the **impersonated legitimate client**, so filtering only for a new malicious OAuth app or consent event can miss the demonstrated path.
- Review authentication-method/passkey additions and deletions, MFA registrations, mailbox forwarding/rules and app-specific sessions. Investigate anomalies in context; a legitimate Teams token or normal passkey enrollment is not itself an IOC.
- No generic package/permission check proves historical safety. Missing cloud logs, short retention or no interactive sign-in can leave token abuse unknown. MSRC's “Exploited: No” assessment is explicitly at original publication, **not a current proof of no attacks**.

## Remediation

1. Update Microsoft Authenticator through the official Google Play/managed-app channel to **6.2606.4246 or a later supported release**, and verify the installed version in every affected profile. Avoid third-party APK download sites or build numbers quoted before MSRC's September 15 correction.
2. For devices that cannot update, restrict access to work resources using an administrator-approved device/Conditional Access policy while resolving support. Preserve a known-good recovery method before changing MFA enrollment; do not lock yourself out by deleting Authenticator indiscriminately.
3. Remove/quarantine untrusted applications using trusted device-management tooling. Restrict sideloading and enforce updates as additional controls; ordinary app-permission review is insufficient for a broker flaw demonstrated with zero declared permissions.
4. If compromise is suspected, isolate the device and preserve evidence before an approved clean reset/re-enrollment. The app update prevents the entry path but does not revoke tokens already issued or remove attacker-added authentication methods.
5. Coordinate account recovery from a **clean device** with the tenant administrator. Do not use the suspect phone to approve replacement credentials or recovery actions.

## Verification

- Confirm the installed Authenticator package in all profiles is at least the corrected fixed build, from the expected publisher; reconcile EMM check-in and update time with the actual device.
- Test a normal approved work-account sign-in and broker-dependent application after updating. Do not install the research proof of concept, call its exported activity with crafted intents, or request victim tokens to test production exposure.
- Confirm intended enrollment and recovery methods remain available, and that device compliance/application policies apply to the actual user/profile.
- For incident response, verify revoked refresh tokens and removed rogue methods through tenant controls, then check application-specific sessions and resource audit trails. A successful app upgrade or user password change alone does not prove all access ceased.

## Compromise response

Use [Microsoft's revoke-access procedure][revoke] with appropriately privileged administrators. Where abuse is active, block sign-in and disable the affected device as warranted, revoke refresh-token sessions, and recover the account from a trusted system. Review and remove unauthorized authentication methods/passkeys and attacker-created persistence.

**Revocation is not always instantaneous:** existing access tokens may remain usable until expiry or resource-side/Continuous Access Evaluation enforcement; applications can maintain their own session cookies. Coordinate resource-specific session invalidation and verify actual denial of old access rather than assuming one Entra action ends every session. Investigate mailbox/file disclosure and account changes separately from device repair. [Microsoft guidance][revoke]

## Sources

- [Microsoft advisory and September 15 correction][msrc] — severity, interaction prerequisite, original exploitability assessment.
- [Microsoft CNA record][cve] — affected range, fixed boundary and publication timestamps.
- [Enclave AuthMask research][research] — October disclosure, tested token scopes and contrasting interaction description.
- [Cyber Security News][news] and [user-provided X lead][lead] — discovery lead and attributed July release claim.
- [Microsoft Entra access/session revocation][revoke] — recovery controls and enforcement delays.

[msrc]: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-80097
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-80097
[research]: https://enclave.ai/blog/authmask-we-made-microsoft-authenticator-hand-over-tokens
[news]: https://cybersecuritynews.com/microsoft-authenticator-flaw/
[lead]: https://x.com/The_Cyber_News/status/2114630691896127947
[revoke]: https://learn.microsoft.com/en-us/entra/identity/users/users-revoke-access
