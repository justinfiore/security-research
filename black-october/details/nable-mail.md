# N-able: someone reached a server behind Mail Assure and SpamExperts

**Last updated:** 2026-11-21 (America/New_York)

[Main summary](../black-october-2026.md#n-able-someone-reached-a-server-behind-mail-assure-and-spamexperts) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Mail Assure and SpamExperts Hosted Cloud filter email for N-able's customers. On November 18 N-able said someone had unauthorized access to one server in that cloud. Mail still flows and is still filtered. The management portal, the API, quarantine, and logging are still offline.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** N-able's status page, incident 202672, says the investigation is ongoing and that, at 03:05 UTC on November 18, it did not have evidence that customer data was compromised, including access to tenants' mailboxes. The same update says this is unrelated to the [N-central](../black-october-2026.md#n-central-critical-vulnerabilities-hotfix-20264126) incident. N-able has not said how the server was reached or what was done on it. The latest update, 17:45:37 UTC on November 20, says remediation has advanced and N-able is preparing to restore the service. The portal and API stay disabled until restoration begins. Mail filtering is still running.

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
| Customers told of a disruption | 2026-11-16; time unknown | N-able's November 18 update says it informed customers that day. [Status][status] |
| Status page opens | 2026-11-17 03:00:00 UTC | Incident 202672. Dashboard access affected. Mail filtering still running. |
| First explanation | 2026-11-17 13:33:42 UTC | Traced to platform configuration and service dependencies. |
| **Security incident** | **2026-11-18 03:05:09 UTC** | Unauthorized access to one server. No evidence then of compromised customer data. Unrelated to N-central. |
| Status | 2026-11-20 04:00:24 UTC | Portal and API still disabled. Mail filtering still running. |
| **Last update read** | **2026-11-20 17:45:37 UTC** | Remediation has advanced. Restoration has not started. Portal and API stay disabled. |
| **Last updated** | **2026-11-21 (America/New_York)** | N-able is preparing to restore the service. There is still nothing to install. |

## Detection

1. A customer of Mail Assure or SpamExperts Hosted Cloud, in the Americas, APAC, or Europe, is in the incident. N-able lists all six services as affected.
2. The status page is the only public record. N-able says it emailed partners with information relevant to their environment and whether action is required. Not receiving that email is not a clearance: the page says to contact N-able Technical Support.
3. Mail arriving does not show that the portal is healthy. N-able says filtering kept running while the portal, API, quarantine, and logs stayed offline.

## Remediation

1. There is no customer-side patch. N-able says it mitigated the threat and is hardening the service. A customer cannot apply that.
2. Read the partner email. If it did not arrive, contact N-able Technical Support rather than assuming no action is required.
3. While the portal and API are disabled, do not queue changes that assume they will apply. Quarantined mail cannot be reviewed or released from the portal until N-able brings it back.

## Verification

- The incident page still says the portal and API are disabled, and that mail filtering is running. That is N-able's statement, not a check a customer can run.
- Do not probe the hosted service to see whether the server is reachable.

## Compromise response

N-able's statement from 03:05 UTC on November 18 is that it had no evidence then of compromised customer data, including tenant mailboxes. The 17:45 UTC update on November 20 says remediation has advanced and does not say the investigation is finished, so that statement is not a final clearance. A message that sat in quarantine during the outage is not readable from the portal until the service returns. This incident is not the N-central compromise, and the checks for that one do not apply here.

## Sources

- [N-able status, incident 202672][status] — read 2026-11-21. Unauthorized access to one server, disclosed 2026-11-18 03:05:09 UTC. At 2026-11-20 17:45:37 UTC N-able said it is preparing to restore the service and that the portal and API stay disabled until then.
- [CISA KEV JSON][kev] — catalog 2026.11.18, checked 2026-11-20. No CVE to match.

[status]: https://uptime.n-able.com/event/202672
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
