# Rackspace Spot: leaked credentials read Kubernetes secrets

**Last updated:** 2026-11-22 (America/New_York)

[Main summary](../black-october-2026.md#rackspace-spot-leaked-credentials-read-kubernetes-secrets) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Rackspace Spot is a Kubernetes platform. BleepingComputer's November 21 report quotes a notice Rackspace sent to affected customers. The notice says an unauthorized party used leaked credentials to access parts of the platform on November 17, 2026, between about 00:20 and 22:00 UTC, and could act as a legitimate user in some customer organizations. In those organizations the party could create pods, read Kubernetes Secrets, and list nodes and volumes. Rackspace says it has revoked the affected tokens and sessions and removed the unauthorized pods. A customer who was notified still has to reissue tokens and rotate the secrets that were readable. This guide did not read Rackspace's own notice; the claims below are what BleepingComputer attributes to it.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** This is an incident at the platform, not a flaw in an application you patch.

BleepingComputer says Rackspace learned of the intrusion on November 18 after a customer report and confirmed that recipient the same day. The quoted sentence is: "On 17 November 2026 (about 00:20–22:00 UTC), an unauthorized party used leaked credentials to access parts of Rackspace Spot." Rackspace warned that the party could have read any Secret stored in an affected user's clusters, and any Spot API token or refresh token that user held. It says it rotated keys and strengthened access controls and monitoring. It has not said how many customers were affected or whether data was stolen; BleepingComputer says Rackspace did not answer those questions.

The notice tells an affected customer to reissue Spot API tokens, replace refresh tokens used in automation, download fresh Kubernetes configuration files, and rotate credentials stored in cluster Secrets. It also says to review logs for databases, container registries, Git repositories, cloud storage, and third-party services from November 17 for use of those credentials. The indicators it shared are the address 23.224.79.106, the range 23.224.0.0/15, and Kubernetes pod and object name prefixes `i1`, `glm-`, and `probe`.

The administration console was down while Rackspace took the platform offline. Sirish Raghuram, co-founder of Platform9, which co-developed Spot, wrote on Reddit that the team shut all access down and sanitized the environment. BleepingComputer says Rackspace announced on November 21, in a Reddit post, that service was fully restored.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Access window | 2026-11-17, about 00:20–22:00 UTC | Leaked credentials. Quoted from Rackspace's notice by BleepingComputer. [BleepingComputer][bc] |
| Rackspace notified | 2026-11-18; time unknown | A customer report. The recipient was confirmed the same day. |
| **Public report** | **2026-11-21 17:59; timezone not stated on the page** | BleepingComputer. The page prints 05:59 PM and no zone. |
| Service restored | 2026-11-21; time unknown | Rackspace's Reddit announcement, as reported. |
| **Last updated** | **2026-11-22 (America/New_York)** | New item. Reissue tokens and rotate secrets. |

## Detection

1. Read the notice Rackspace sent the account, if one arrived. The public report does not list the affected organizations.
2. In an affected cluster, look for pods and objects whose names start with `i1`, `glm-`, or `probe`. Rackspace says it removed the unauthorized pods; a name that is still there is a lead, and a name that is gone is not proof nothing was read.
3. Review audit logs from November 17 for calls from 23.224.79.106 and from 23.224.0.0/15. A log that does not show those addresses does not show that a secret was not read.
4. Review the downstream logs Rackspace names, from November 17: databases, container registries, Git repositories, cloud storage, and third-party services whose credentials were in a Secret.

## Remediation

There is no customer-side patch.

1. If Rackspace notified the account, reissue the Spot API tokens, replace refresh tokens used in automation, and download fresh Kubernetes configuration files. Rackspace says it revoked the old ones.
2. Rotate every credential that was stored in a Secret in an affected cluster. Treat a secret that was readable as exposed from November 17, not from the date of the notice.
3. A cluster that was not notified has no action from this report. Absence of a notice is what Rackspace says it sent, and this guide cannot confirm delivery.

## Verification

- Tokens and configuration files for a notified account have been reissued, and credentials that were in those clusters' Secrets have been rotated.
- Automation that held a refresh token has the replacement, not the revoked one.
- Do not probe the addresses above. They are indicators, not a check you run against the platform.

## Compromise response

A secret that was readable on November 17 should be treated as exposed even if the pod that read it is gone. Rackspace has not said whether data was stolen, so a rotated credential is the response, not a confirmation that nothing was copied. The console outage delayed that rotation for customers who could not reach the platform; a rotation done after the November 21 restoration still leaves the window from November 17.

## Sources

- [BleepingComputer, November 21, 2026][bc] — quotes Rackspace's customer notice. Access window, what the party could do, the customer instructions, and the indicators. Says Rackspace did not answer how many customers were affected or whether data was stolen.
- [CISA KEV JSON][kev] — catalog 2026.11.20, checked 2026-11-22. No CVE to match.

[bc]: https://www.bleepingcomputer.com/news/security/rackspace-spot-breach-let-hackers-access-customer-kubernetes-secrets/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
