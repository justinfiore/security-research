# Juniper Session Smart Router: pre-onboarding administrator access

**Last updated:** 2026-10-30 (America/New_York)

[Main summary](../black-october-2026.md#juniper-session-smart-router-pre-onboarding-administrator-access) · [Main TOC](../black-october-2026.md#table-of-contents)

**[CVE-2026-103409](https://www.cve.org/CVERecord?id=CVE-2026-103409): Juniper CNA CVSS 3.1 9.8 Critical.** A crafted parameter can reach an insecure endpoint that runs as root and give an unauthenticated network attacker administrator privileges before the device is onboarded to Mist/Conductor.

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). No exploitation is reported by the Juniper CNA record. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Public CVE | 2026-10-28; time/TZ unknown | Juniper CNA record. |
| Fixed releases | 2026-10-28; time/TZ unknown | 7.0.5, 7.1.7 and 7.2.3. |

## Detection
Inventory Session Smart Router version, management reachability and onboarding state. Affected ranges are before 7.0.5, 7.1.0–7.1.6 and 7.2.0–7.2.2. The CNA says an already Mist/Conductor-onboarded device is not exploitable through this endpoint; verify that state through trusted management records rather than public exposure tests.

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
