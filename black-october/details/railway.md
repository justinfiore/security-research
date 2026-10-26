# Railway: exposed environment secrets and recovery

**Last updated:** 2026-10-26 (America/New_York)

[Back to Railway summary](../black-october-2026.md#railway) · [Changelog](../../CHANGELOG.md)

Railway reports unauthorized access to internal systems and decryption of a subset of customers' stored environment variables. **This is a platform-side secret exposure, not a local dependency vulnerability.** Follow its precautionary recommendation to revoke and replace sensitive variables stored before October 21, including database/API secrets and private registry credentials; investigate the services those credentials authorize.

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

Times below are UTC. The October 22 report is preliminary; the initial October 21 disclosure did not describe the full earlier attack window.

| Date | Event and evidence |
| --- | --- |
| 2026-10-20 13:58 | Earliest event in Railway's reported attack window: abnormal latency paged engineering and investigation began. This is the first reported internal detection, not proof of the attacker's first-ever access. |
| 2026-10-20 14:03–16:51; 17:03 | Railway identified attempted privilege escalation and halted builds; a public service-status incident was declared at 17:03. That was not yet the security disclosure. |
| 2026-10-20 18:05–19:53 | First exploit mitigation was validated, but additional evidence at 19:53 showed broader escalation. Do not treat this initial fix as final containment. |
| 2026-10-21 04:24–05:23 | Investigators identified encrypted-secret theft, initially without demonstrated decryption. Subsequent CI credential access enabled further compromise. |
| 2026-10-21 07:25–09:18 | Database evidence showed unauthorized encrypted-variable queries and decryption of a subset using compromised credentials. Exact per-secret decryption times remain **unknown**. |
| 2026-10-21 around 09:25 | Providers were asked to revoke potentially exposed keys. The timeline and report body say 09:25; its FAQ says 09:35. The unresolved ten-minute discrepancy is not a reason to delay rotation. |
| 2026-10-21 20:19–22:10 | Railway announced session invalidation, published the security disclosure/customer guidance, and notified users about credential rotation. The report body does not specify the publication time; the disclosure page's `datePublished` metadata (and blog RSS) gives **2026-10-21 20:44:02 UTC**. |
| 2026-10-22 00:43–00:47 | Provider-specific recovery guides (database rotation, cloud/GitHub/AI-provider usage checks) published, per blog RSS. |
| 2026-10-22 03:32 | Railway's reported point of confirming the attacker no longer had internal access; not a customer-by-customer credential recovery completion time. |
| 2026-10-22 03:32–06:29; 17:00–22:49 | Hardened systems began returning with new credentials; later, API and deployments across all tiers were reported restored. Existing customer workloads had remained online. |
| 2026-10-22 23:31:37 | Preliminary incident report published, per page `datePublished` metadata and blog RSS. |
| 2026-10-23 16:30; 17:01–17:02 | Deployment and login recovery guides published (RSS); the preliminary report and initial disclosure pages carry `dateModified` metadata of 17:01:00 and 17:02:29, respectively. The changed passages are not identified. |
| As of 2026-10-26 | Final forensic report, full exploit details, definitive source-code-access findings, and precise affected-variable list were **not available in the reviewed sources**. |

**Evidence limits:** Railway estimates at most **1.85% of workspaces (about 100,000)** had some environment variables potentially compromised. This is the vendor's preliminary estimate, not an independently verified count or the number of every precautionary revocation. Its report says individual Railway accounts were not logged into, but does not rule out source-code access. Claims about AI-assisted attacks and motive are preliminary vendor assessments, not necessary premises for recovery.

## Detection

1. From a clean browser/session, inventory every workspace, project, service, environment, shared/reference variable, and registry integration used before October 21. Include preview/staging environments, inactive services, and secrets reused outside Railway.
2. Record **names and nonsecret identifiers**, owners, creation/history records, permissions, issuing service, and deployment consumers. Do not bulk-export values or print variables to logs. If a still-valid secret's historical presence is uncertain, include it in precautionary rotation.
3. Review Railway notices and direct provider messages through known official channels. A provider revocation email does **not** prove your key was stolen: Railway sent all stored keys to some vendors out of caution. No email does not prove safety either.
4. Prioritize high-impact credentials: cloud IAM, GitHub/GitLab, registry push access, database administrators, payment APIs, signing/session secrets, and AI-provider keys. Railway identified large variable sets and many AI keys as higher-risk targeting patterns, not exclusive affected categories.
5. Review each issuing provider's audit and usage records from at least October 20 through final revocation, expanding earlier if evidence requires. Search for unfamiliar IPs/regions, unusual inference spending, new tokens/users, repository changes, registry pushes, bucket access, and database queries or exports.
6. Correlate provider key IDs and service accounts with deployment history. If logging was disabled, unavailable, or too short-lived, record the gap explicitly. A Python package inventory or clean application image cannot rule out this server-side disclosure.

**Impact assessment:** A decrypted secret grants its actual permissions, potentially across systems outside Railway. Read-only API access, production database administration, registry publishing, and token-signing keys have very different consequences. Encryption at rest did not prevent this incident; editing a Railway variable does not revoke the underlying credential at its issuer.

## Remediation

1. Preserve notices, relevant provider logs, deployment IDs, and nonsecret configuration history. Revoke actively abused credentials immediately and restrict affected identities/networks; do not wait for a perfect inventory or final vendor report.
2. Verify current platform recovery status through Railway's official status page before placing replacement secrets there. The vendor says it rerolled internal credentials after eviction; if you installed replacements while access persisted, assess them for repeat rotation rather than assuming the first change was safe.
3. Remove unnecessary public database access and use Railway's private networking where appropriate. Coordinate client migration before removing an endpoint needed by legitimate workloads. Network isolation reduces abuse opportunities but does not revoke a stolen password.
4. Rotate at the **issuing service** first or in a tightly controlled dual-key cutover: create a least-privileged replacement, update all authorized consumers, verify service health, and revoke the old key promptly. If abuse is active, revoke first and accept necessary downtime. Do not leave indefinite overlapping credentials.
5. Update shared and environment-specific variable references, CI secrets, external workers, and private registry credentials. Redeploy/restart every consumer so it actually loads the new value; changing dashboard configuration alone is not a running-process update.
6. For databases, change the real database user's password or create a replacement role with appropriate grants, then update connection URLs and all clients. Changing only `DATABASE_URL` or a container's initialization variable may leave the database credential unchanged. Address existing authenticated sessions separately.
7. Reconnect GitHub account/repository integration and confirm the Railway GitHub App has only required repository access. Recreate revoked CLI/CI credentials (`RAILWAY_TOKEN` or `RAILWAY_API_TOKEN`) from a clean administrative environment with the narrowest needed scope.
8. Trigger deployment of the intended reviewed commit: Railway says commits pushed while deployments were paused **were not queued**. Confirm the latest safe revision actually deployed; a passing recovery build can otherwise leave the old workload running.
9. If evidence shows repository, image, host, or application compromise, isolate and rebuild that scope from independently verified sources. Merely storing secrets on Railway does not itself prove every customer container was modified or require indiscriminate data restoration.

## Verification

- Maintain a rotation ledger: credential ID/provider, scope, affected consumers, issuer-side revocation time, replacement deployment ID, test result, and owner. Close entries only after every consumer and old credential is accounted for.
- Confirm old keys are disabled/revoked at their issuer and old sessions are terminated where applicable. Use provider status or a safe negative authentication check without logging the secret; a changed variable value is not revocation evidence.
- Check that new deployments use the intended source revision and replacement credentials, including background workers, jobs, preview environments, and external integrations. Exercise a low-risk authenticated operation and verify health without revealing the credential.
- Confirm databases reject old credentials and no unauthorized sessions/users/grants remain. Validate intended private connectivity and removal of unwanted public access independently of password changes.
- Review GitHub/GitLab app grants, registry activity, cloud policies, new API keys, webhook destinations, and AI-provider billing after cutover. Revoke attacker-created credentials: they do not disappear when the initially stolen key is rotated.
- Verify deployment permissions and registry pulls work with replacements. A successful application response from the last pre-incident deployment is not evidence that the recovery deployment succeeded.
- Record coverage limits for inaccessible audit logs, historical variables, and unknown decryption scope. Platform restoration, absence of billing spikes, and no direct notice do not prove that your secrets were never disclosed.

## Compromise response

- **Cloud identities:** Revoke persistent keys, restrict affected roles/service accounts, and use provider-specific session revocation controls for temporary tokens. Audit IAM grants, new principals, compute jobs, and storage access; key rotation alone may not terminate issued sessions.
- **Source and registries:** Revoke OAuth/PAT/deploy tokens and registry credentials, inspect repository/branch/workflow changes and newly pushed images, and redeploy only verified artifacts. Review provenance independently of mutable tags.
- **Databases:** Investigate anomalous authentication, queries, exports, new users, grants, and backups. End unauthorized sessions and assess confidentiality/integrity impact before restoring service. Password rotation cannot recover exfiltrated records.
- **AI/payment/API services:** Replace exposed keys and inspect usage, spend, requests, webhooks, and account changes. Set appropriate limits and report suspected abuse to providers; do not assume only AI keys were exposed because those were the reported target.
- **Session/signing/encryption secrets:** Invalidate sessions or signed tokens accepted under exposed keys. Replace signing keys and review their consumers. If data-encryption keys were disclosed, evaluate ciphertext exposure and re-encryption separately; deleting a variable cannot undo decryption of previously stolen data.
- **Communication:** Escalate confirmed misuse to incident responders and affected service owners; preserve evidence for contractual/regulatory notification assessment. Ask Railway support about your workspace-specific notice using project/service IDs, never by emailing the secret values.

## Sources

- [October 21 initial security disclosure](https://blog.railway.com/p/security-disclosure-wednesday-october-21st): original precautionary rotation guidance, including private registry credentials.
- [October 22 preliminary report](https://blog.railway.com/p/preliminary-report-october-security-incident): expanded timeline, scope estimate, limitations, containment, and provider revocations.
- [October 23 failing-deployment recovery guide](https://blog.railway.com/p/security-disclosure-recommendation-recover-failing-deploys): unqueued commits, GitHub reconnection, and revoked CLI/CI tokens.
- [Railway engineering recovery-guide index](https://blog.railway.com/engineering), [blog RSS feed](https://blog.railway.com/rss.xml) (publication timestamps; no posts after October 23 at this review) and [official status](https://status.railway.com/): provider-specific follow-up guides and the place to verify current service availability. No live availability guarantee is made here.

Incident reports and the recovery guide/index were freshly read on the update date. No customer variables, Railway administration, provider audit logs, or revocation systems were accessible for verification; no final report was found in the reviewed vendor index. The actions above are operational guidance, not evidence that any particular customer's recovery is complete.
