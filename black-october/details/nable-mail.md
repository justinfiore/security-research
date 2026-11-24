# N-able: someone reached a server behind Mail Assure and SpamExperts

**Last updated:** 2026-11-23 (America/New_York)

[Main summary](../black-october-2026.md#n-able-someone-reached-a-server-behind-mail-assure-and-spamexperts) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Mail Assure and SpamExperts Hosted Cloud filter email for N-able's customers. On November 18 N-able said someone had unauthorized access to one server in that cloud. Mail still flows and is still filtered. At 23:44:43 UTC on November 21 N-able said the dashboard and the API had been restored, and that services were coming back in phases while it monitored the platform for about an hour. The page header still says the dashboard, API, and quarantine remain offline. The two statements are on the same page, and the timeline entry is the newer one. The incident is still marked Active, status Monitoring, with no end time.

**N-able rates [CVE-2026-134624](https://www.cve.org/CVERecord?id=CVE-2026-134624) CVSS 4.0 9.3 Critical.** N-able is the CNA. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:N/SC:H/SI:H/SA:N`. MailAssure (SpamExperts) before **20261121.1943** does not restrict where the LDAP synchronisation connection check connects when a relay is configured. An API user with high privileges can point the server at any internal host and port, see which answer, and send data to them. The record does not say this runs code. N-able's November 22 update says it remediated the vulnerability, restored the dashboard and API as of November 21 at 23:45 UTC, and has found no exploitation beyond the one hosted server from the original investigation. It does not say the flaw was how that server was reached. A root-cause analysis is due within two weeks of that update. The status page, incident 202672, still says that at 03:05 UTC on November 18 it did not have evidence that customer data was compromised, including tenants' mailboxes, and that this is unrelated to the [N-central](../black-october-2026.md#n-central-critical-vulnerabilities-hotfix-20264126) incident. The incident statements describe Hosted Cloud. SpamExperts Local Cloud runs on the customer's hardware, and those operators should confirm the server is on **20261121.1943**.

**CISA KEV:** Listed — [CVE-2026-134624](https://www.cve.org/CVERecord?id=CVE-2026-134624) added 2026-11-23, federal due date 2026-11-26. Ransomware use Unknown. Forensic triage is required. Catalog 2026.11.23, released 2026-11-23T19:43:55.7979Z. CISA's listing is the known-exploitation evidence. N-able still says it has found no exploitation beyond the one hosted server, and it does not say the flaw was how that server was reached. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Status | 2026-11-20 17:45:37 UTC | Remediation has advanced. Restoration has not started. Portal and API stay disabled. |
| Status | 2026-11-21 17:15:45 UTC | Restoration work continuing. Portal and API still disabled. |
| **Dashboard restored** | **2026-11-21 23:44:43 UTC** | N-able says the dashboard and API are back, in phases, under monitoring. The page header still says they are offline. [Status][status] |
| **CVE published** | **2026-11-22; time/TZ unknown** | CVE-2026-134624, CVSS 4.0 9.3. Fixed before 20261121.1943. N-able does not say it was the way in. [CVE](https://www.cve.org/CVERecord?id=CVE-2026-134624) |
| **CISA KEV** | **2026-11-23; time/TZ unknown** | Added. Federal due date 2026-11-26. Ransomware use Unknown. Forensic triage required. [KEV][kev] |

## Detection

1. A customer of Mail Assure or SpamExperts Hosted Cloud, in the Americas, APAC, or Europe, is in the incident. N-able lists all six services as affected.
2. The status page is the only public record. N-able says it emailed partners with information relevant to their environment and whether action is required. Not receiving that email is not a clearance: the page says to contact N-able Technical Support.
3. Mail arriving does not show that the portal is healthy. N-able says filtering kept running through the outage. The 23:44 UTC update says the dashboard and API are back, and the page header still says they are offline, so a failed login is not by itself a sign the restoration was reversed.

## Remediation

1. Hosted Cloud is already on the fixed build, N-able says. There is nothing for a hosted customer to install. API tokens and OAuth tokens were revoked, so reconnect integrations with the credentials in the partner email.
2. SpamExperts Local Cloud runs on customer hardware. Confirm it is **20261121.1943 or later**.
3. Read the partner email. If it did not arrive, contact N-able Technical Support rather than assuming no action is required.
4. Quarantine is named in the page header, which still says access is offline, and is not named in the restoration update. Do not assume a quarantine release works until it does. The fix does not show what the one reached server did.

## Verification

- The newest timeline entry is the 23:44:43 UTC restoration, and the incident is still Active. That is N-able's statement, not a check a customer can run.
- Do not probe the hosted service to see whether the server is reachable.

## Compromise response

N-able's statement from 03:05 UTC on November 18 is that it had no evidence then of compromised customer data, including tenant mailboxes. The 23:44 UTC update on November 21 says the dashboard is back and that the investigation's further details will come by customer communication. It does not say the investigation is finished, so the November 18 statement is not a final clearance. A message that sat in quarantine during the outage has to be checked in the portal now that N-able says it is reachable. This incident is not the N-central compromise, and the checks for that one do not apply here.

## Sources

- [N-able status, incident 202672][status] — read 2026-11-22. Unauthorized access to one server, disclosed 2026-11-18 03:05:09 UTC. At 2026-11-21 23:44:43 UTC N-able said the dashboard and API are restored and under monitoring. The page header still says they are offline.
- [CVE-2026-134624](https://www.cve.org/CVERecord?id=CVE-2026-134624) — N-able, published 2026-11-22. CVSS 4.0 9.3. MailAssure before 20261121.1943. An authenticated API user points the LDAP connection check at any internal host.
- [Mail Assure incident update](https://www.n-able.com/blog/mail-assure-incident-update) — November 22, 2026, 2:30 pm EST. Vulnerability remediated. No exploitation found beyond the one hosted server. Root-cause analysis due within two weeks. N-able does not say the flaw was the way in.
- [CISA KEV JSON][kev] — catalog 2026.11.23, released 2026-11-23T19:43:55.7979Z, checked 2026-11-23. CVE-2026-134624 added 2026-11-23, due 2026-11-26. Ransomware use Unknown. Forensic triage Yes.

[status]: https://uptime.n-able.com/event/202672
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
