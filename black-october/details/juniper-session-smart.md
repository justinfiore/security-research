# Juniper Session Smart Router: pre-onboarding administrator access

**Last updated:** 2026-11-25 (America/New_York)

[Main summary](../black-october-2026.md#juniper-session-smart-router-pre-onboarding-administrator-access) · [Main TOC](../black-october-2026.md#table-of-contents)

**[CVE-2026-103409](https://www.cve.org/CVERecord?id=CVE-2026-103409): Juniper CNA CVSS 3.1 9.8 Critical.** A crafted parameter can reach an insecure endpoint that runs as root and give an unauthenticated network attacker administrator privileges before the device is onboarded to Mist/Conductor.

**CISA KEV:** [CVE-2026-103406](https://www.cve.org/CVERecord?id=CVE-2026-103406) is listed — added 2026-11-25, federal due date 2026-11-28. Forensic triage is required. [CVE-2026-103409](https://www.cve.org/CVERecord?id=CVE-2026-103409), the pre-onboarding flaw this guide was written for, is not listed. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

**[CVE-2026-103406](https://www.cve.org/CVERecord?id=CVE-2026-103406): Juniper CNA CVSS 3.1 9.8 Critical.** A crafted salt minion ID reaches AutomatedProvisioner on Session Smart Conductor and runs a command as root, with no login. Juniper's record, updated 2026-11-24, says at least one instance of malicious exploitation was reported to Juniper SIRT, and that there is no workaround. Affected ranges are before 7.0.5, 7.1.0 before 7.1.7, and 7.2.0 before 7.2.3. The fixes are the same three releases as CVE-2026-103409. The CVE record names Conductor. CISA's catalog entry also names Session Smart Router. JSA112183 is the advisory for both and is behind a login, so this guide did not read it.

## Table of contents
- [Timeline](#timeline)
- [CVE-2026-103406](#cve-2026-103406)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline
| Event | Date and time (timezone) | Notes |
|---|---|---|
| Public CVE | 2026-10-28; time/TZ unknown | Juniper CNA record for CVE-2026-103409. CVE-2026-103406 was published the same day. |
| Fixed releases | 2026-10-28; time/TZ unknown | 7.0.5, 7.1.7 and 7.2.3, for both CVEs. |
| Exploitation reported | 2026-11-24; time/TZ unknown | Juniper's CVE-2026-103406 record says at least one malicious exploitation was reported to Juniper SIRT. |
| **CISA KEV** | **2026-11-25; time unknown** | CVE-2026-103406 added. Due 2026-11-28. Forensic triage required. CVE-2026-103409 is not listed. |

## CVE-2026-103406

This is a different flaw in the same bulletin, on Session Smart Conductor rather than on a router that has not been onboarded. The version check is the same: before 7.0.5, 7.1.0 through 7.1.6, and 7.2.0 through 7.2.2. Onboarding does not close it. Juniper says there is no workaround, so a Conductor that can be reached from a network you do not trust stays exposed until it is on 7.0.5, 7.1.7, or 7.2.3.

## Detection
Inventory Session Smart Router and Conductor version, management reachability, and onboarding state. Affected ranges for both CVEs are before 7.0.5, 7.1.0–7.1.6, and 7.2.0–7.2.2. For CVE-2026-103409, the CNA says an already Mist/Conductor-onboarded device is not exploitable through this endpoint; verify that state through trusted management records rather than public exposure tests. That statement does not cover CVE-2026-103406.

## Remediation
Upgrade to **7.0.5**, **7.1.7**, **7.2.3**, or a later supported release. Restrict management interfaces to trusted provisioning networks during rollout and complete supported Mist/Conductor onboarding; neither control substitutes for patching.

## Verification
Confirm each deployed router’s running version and managed onboarding state, then perform normal approved routing and management-plane health checks. Do not send crafted URL parameters.

## Compromise response
For exposed pre-onboarding devices, preserve management logs and configuration, review unexpected administrator accounts and configuration changes, rotate device and controller credentials, and reimage or reset devices where privileged compromise cannot be excluded.

## Sources
- [CVE record](https://www.cve.org/CVERecord?id=CVE-2026-103409)
- [Juniper JSA112183](https://supportportal.juniper.net/JSA112183)
- [CISA KEV feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json)
