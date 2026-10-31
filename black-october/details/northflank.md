# Northflank: environment variables treated as decrypted

**Last updated:** 2026-10-31 (America/New_York)

[Back to Northflank summary](../black-october-2026.md#northflank-environment-secret-exposure) · [Changelog](../../CHANGELOG.md)

Northflank told every customer to assume environment variables stored on the platform were decrypted and to rotate them. Users then reported unauthorized use of AI API keys they had supplied to the platform. **This is a platform-side secret exposure, not a local package vulnerability.** There is no CVE, no CVSS score, and no customer-side software patch. Northflank has not published a root cause, a count of affected customers, or a statement that the attacker is gone.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. This is a platform-side incident; the vendor's status page is the instruction to rotate. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

Times below are UTC, taken from Northflank's status page. The page does not say when unauthorized access began, only when Northflank started responding.

| Date | Event and evidence |
| --- | --- |
| 2026-10-30 11:43 | Wiz sent a threat alert. Northflank engineers reviewed it at 11:44. [Status][status] |
| 2026-10-30 12:02; 12:50; 13:05 | Northflank deployed an initial network-policy patch, then additional patches. At 13:00 it requested Wiz CIRT support. These are containment steps, not a published root cause. [Status][status] |
| 2026-10-30 13:40 | Public status incident opened: "Rotate environment variables immediately." [Status][status] |
| 2026-10-30 13:58 | Status moved to Identified: "Assume all environment variables have been decrypted. Disable/rotate all keys." [Status][status] |
| 2026-10-30 15:12 | Secret rotation for Postgres and MongoDB enabled for all users. Northflank recommended disabling public expose on addons. It listed secrets on workloads, secret groups and global secrets, and said multiple users were confirming that their AI keys had been used. [Status][status] |
| 2026-10-30 19:28 | Investigation still ongoing, with no further confirmed findings. Guidance unchanged: assume all environment variables are compromised and rotate secrets in workloads, secret groups and global secrets. [Status][status] |
| 2026-10-30 23:38 | Users reported unauthorized use of AI API keys supplied to the platform. Northflank said the reports may match the pattern in Wiz's same-day article and pointed at that article's IP addresses. It did not publish its own indicator list. [Status][status] [Wiz][wiz] |
| 2026-10-31 01:04 | Audit logs enabled for all customers, including free users. The incident remained Identified, not resolved. [Status][status] |
| 2026-10-30 | Wiz listed Northflank as the ninth AI developer platform to disclose an incident in October, alongside Railway and others. Wiz says the incidents share a pattern of hunting stored environment variables for AI access, and that there is no single vulnerability linking them. [Wiz][wiz] |

**Evidence limits:** Northflank has not said how variables were decrypted, whether every customer was affected, how long exposure lasted, or whether Bring Your Own Cloud deployments are included. "Assume decrypted" is the vendor's instruction, not a published per-customer finding. Wiz's IP table is for testing stolen keys and resale; Wiz says it does not have evidence that those addresses carried out the platform compromises themselves.

## Detection

1. From a clean browser session, list every Northflank project, service, addon, secret group and global secret. Include preview environments and secrets reused outside Northflank. Record **names and nonsecret identifiers** only. Do not export or print values.
2. Treat any still-valid secret that was stored on Northflank on or before 2026-10-30 13:40 UTC as in scope. If you cannot tell whether a secret was present then, include it.
3. Review AI-provider usage and billing from at least 2026-10-30 11:43 UTC until each key is revoked. Unexpected inference spend is what Northflank's users reported. Absence of a billing spike does not prove a key was not read.
4. Wiz published addresses used to **test** stolen keys (not proven to be the Northflank intrusion itself): `23.106.46.239`, `38.246.114.118`, `104.243.32.50` and `31.57.201.201`. Search provider logs for those, and for the hosting pools Wiz names (PEG TECH, Alibaba US, Scloud, Sharktech, Level 3). A match is a lead, not proof this incident used that address.
5. Northflank enabled audit logs for every customer at 2026-10-31 01:04 UTC. Logs from before that time may not exist. A gap is **unknown**, not clean. There is no local package check that can rule this out.

## Remediation

1. Revoke each in-scope credential at its **issuing provider**, then create a replacement. Editing the value in Northflank does not revoke the old key.
2. Update the replacement in the workload, secret group or global secret that held it, then redeploy or restart every consumer so the new value is what is running.
3. For Postgres and MongoDB addons, use the secret rotation Northflank enabled on 2026-10-30, and disable public expose where it was turned on. Changing a connection string without rotating the database user leaves the old password valid.
4. Do not place a replacement secret on Northflank and treat the incident as finished while the status page still says Identified. Northflank has not said the attacker is gone. If a replacement was stored before containment is confirmed, plan to rotate it again once Northflank says the incident is resolved.
5. There is no Northflank software version to install. Platform patches on the status timeline are Northflank's, not a customer release.

## Verification

- Keep a ledger: secret name, issuer, consumers, time the issuer revoked the old credential, time the replacement was deployed, and who checked it. Close a row only when the old credential fails at the issuer.
- Confirm AI-provider billing after revocation shows no further use of the old key. New abuse of a replacement is a separate event.
- Confirm addons that should be private are not publicly exposed, and that applications still reach them on the private path.
- Audit logs enabled on October 31 do not reconstruct activity from before they existed.

## Compromise response

- **AI provider keys:** Revoke at the provider, review usage and invoices, and report unexpected use to Northflank support and the provider, as Northflank asked. A revoked key does not refund usage that already happened.
- **Cloud, registry and source-control tokens:** Revoke at the issuer and check for new keys, changed grants, unexpected image pushes and repository changes. Rotating the Northflank copy does not remove a key the attacker created with it.
- **Databases:** Rotate the database user, then look for new users, grants and exports. Public expose on an addon is an additional path; closing it is not a substitute for the password change.
- Wiz describes downstream resale of stolen AI credentials from this wave of platform incidents. Treat a key that was valid on Northflank on October 30 as exposed even when your own logs are empty.

## Sources

- [Northflank status: Security incident](https://status.northflank.com/cmvv0rn5a092f14rutwccodpp)
- [Wiz, "Black October" for AI Developer Platforms, 2026-10-30](https://www.wiz.io/blog/black-october-for-ai-developer-platforms)

[status]: https://status.northflank.com/cmvv0rn5a092f14rutwccodpp
[wiz]: https://www.wiz.io/blog/black-october-for-ai-developer-platforms
