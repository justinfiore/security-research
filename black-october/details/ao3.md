# AO3: possible exposure of hashed passwords

**Last updated:** 2026-11-01 (America/New_York)

[Back to AO3 summary](../black-october-2026.md#ao3-possible-exposure-of-hashed-passwords) · [Changelog](../../CHANGELOG.md)

The Organization for Transformative Works (OTW) took Archive of Our Own (AO3) offline after detecting a security incident. OTW does not believe the user database was stolen and cannot rule it out. **This is a site-side incident, not a local package vulnerability.** There is no CVE, no CVSS score, and no software for readers to install. OTW's instruction is to change any password reused from AO3 on other sites.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. This is a site-side incident; OTW's status page is the instruction to change reused passwords. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

Times below are UTC, taken from OTW's status page. The page does not say when unauthorized access began.

| Date | Event and evidence |
| --- | --- |
| 2026-10-29 07:13 | Status: "AO3 is down for maintenance." Not yet described as a security incident. [Status][status] |
| 2026-10-29 09:03 | Identified: maintenance expected to take at least 12 hours. [Status][status] |
| 2026-10-29 17:41 | Restoration estimate of about 2 weeks, up to 4, with a possible degraded return. [Status][status] |
| 2026-10-30 01:27 | OTW says it detected a security incident, works were not deleted, and it cannot rule out theft of the user database. It recommends changing passwords reused from AO3 on other sites. Expected downtime is at least two weeks and could be four. [Status][status] |
| Local software patch | Not applicable. There is no AO3 release for readers to install. |

**Evidence limits:** OTW has not said how the incident happened, whether any account row was copied, or how long access lasted. "Unable to rule it out" is not a finding that the database was stolen. Donor records are a separate system and are not linked to AO3 accounts, according to OTW. OTW's news post of the same day repeats the status text and does not add a root cause.

## Detection

1. List accounts where the password is the same as the AO3 password, including older accounts you no longer use. AO3 itself is offline, so you cannot change the AO3 password until the site returns.
2. The database fields OTW names are username, email address, IP address, and a hashed password. AO3 does not collect real names. A match on another site is the reused password, not a copied session.
3. There is no local package, file, or log on a reader's computer that shows whether OTW's database was copied. Absence of a phishing email is not evidence the hash was not taken.

## Remediation

1. On every other site that used the AO3 password, change that password now and do not reuse the new one. OTW says hashing does not fully protect a weak or reused password from being cracked.
2. Do not wait for AO3 to come back. The other sites are the ones an attacker could try with a cracked password while AO3 is down.
3. When AO3 returns, set a new unique password there as well. OTW has not yet said it will force a reset.
4. There is no software update. Fanlore, the OTW journal, and the main OTW website are not the archive and are not part of this status incident.

## Verification

- Confirm each reused password no longer works on the other site, using a failed login rather than pasting the old password into a note or a ticket.
- Keep the list of sites you changed. OTW may post a later update that changes what else to do; the status page is the place to check.
- A site that already required its own unique password needs no change for this incident.

## Compromise response

- If another site shows a login you do not recognize, treat that account as compromised: revoke its sessions, rotate credentials it can reach, and do not assume the AO3 outage is the only cause.
- OTW says it may not answer individual user questions during the investigation. Use its official outlets rather than sending the old password to anyone claiming to be support.
- Password reuse is the action OTW asked for. The status page does not say to rotate unrelated API keys or to wipe a computer.

## Sources

- [OTW status: AO3 Down for Maintenance](https://www.otwstatus.org/incidents/g12jnxck9g6h)
- [OTW news: Update on AO3 Downtime, October 30, 2026](https://www.transformativeworks.org/update-on-ao3-downtime-october-30-2026/)

[status]: https://www.otwstatus.org/incidents/g12jnxck9g6h
