# LiteLLM 1.107.0: malicious release and credential recovery

**Last updated:** 2026-10-26 (America/New_York)

[Back to LiteLLM summary](../black-october-2026.md#litellm) · [Changelog](../../CHANGELOG.md)

All seven `litellm==1.107.0` PyPI wheels and affected public container images carried a credential stealer and remote-code loader. **Do not run ordinary Python, `pip`, or the LiteLLM CLI in a suspected environment.** Startup hooks can execute without importing LiteLLM. Quarantine, investigate from a clean host, rebuild, and recover credentials; an in-place version downgrade is not sufficient.

## Timeline

All times below are UTC. Publication/removal windows describe vendor registries, not the last possible execution of a cached copy.

| Date | Event and evidence |
| --- | --- |
| 2026-05-27 18:53:14 | An Agent Platform master key was committed publicly. The commit was overwritten, but the key was not revoked. Exact private discovery time of that exposure is **unknown** in the postmortem. |
| 2026-10-10 21:13–21:28 | Attacker accessed the Agent Platform API; an organization owner's GitHub CLI OAuth token was returned at 21:27:10. Further CI-secret theft occurred October 10 and 12. |
| 2026-10-21 11:39:51–11:40:13 | Seven malicious wheels published to PyPI. Container images published at 11:46:56. |
| 2026-10-21 12:06:41 | Researcher opened public issue #47826. Any earlier private researcher notification is **unknown**; the vendor narrative says awareness shortly before 13:00 and response began at 13:02. |
| 2026-10-21 by 13:23; by 13:51 | PyPI quarantined 1.107.0; affected GHCR tags became unavailable, respectively. |
| 2026-10-21 14:19; 14:20 | Vendor removed GitHub permissions after identifying release-workflow compromise; Docker Hub affected tags were removed or repointed, respectively. |
| 2026-10-21 18:20 | Vendor incident post published. Response guidance designated **1.106.2** as a clean rollback target, not a malware-removal patch. Exact first publication time of rollback advice is **unknown**. |
| 2026-10-23 21:00 | Canonical attack-chain postmortem published; it supersedes earlier entry-point theories. |
| 2026-10-24 | Vendor issue comment confirmed legitimacy of accessible public images, including 1.103.7, 1.104.5, 1.105.3, and 1.106.2, and reiterated the corrected entry point. |

**Corrected finding:** The initial token came from an exposed, unrevoked Agent Platform master key, not Claude Code response logs, a demonstrated gateway vulnerability, or compromised IDE extensions. Owner-level OAuth access bypassed branch protections; other stolen tokens approved the release and deleted logs. Signing by the official release pipeline did not make the attacker-selected source trustworthy.

## Detection

1. Inventory historical installations and executions across developer machines, notebooks, CI runners, proxy servers, virtual environments, image build jobs, and private mirrors. Preserve install logs, deployment IDs, image indexes **and platform manifests**, lockfiles, and caches before replacing them.
2. Check all public image variants: `ghcr.io/berriai/litellm`, `litellm-database`, `litellm-non_root`, and `docker.io/litellm/litellm`. Tags `v1.107.0`, `latest`, `main-latest`, and `main-stable` were affected. Today's tag value cannot establish what ran earlier.
3. One confirmed malicious image index is `sha256:1bbcb1443bc962e45f5aad53fe3d2c30600e0379715fb6c664cdd3ac126c339e`; the database/non-root indexes differ. Use the vendor incident post and researcher issue for the full variant/platform mapping and seven wheel hashes. Do not match one digest and clear every other variant.
4. From a clean analysis host, mount a preserved snapshot read-only. Use the **clean host's trusted interpreter and trusted copy of the separate inventory script**, not executables, hooks, or scripts from the snapshot:

   ```sh
   /usr/bin/python3 -I -S /trusted/black-october/python-package-inventory.py \
     /mnt/snapshot/app/.venv/lib/python3.13/site-packages
   ```

   Replace the interpreter/script/package paths with verified local paths. Supply every relevant package directory; `-I -S` avoids ordinary startup hooks and environment-based import paths but does not make a compromised interpreter safe.
5. On the snapshot, inspect site-packages roots for `cook.pth`, `cook.py`, `sitecustomize.py`, matching bytecode, and `litellm-1.107.0.dist-info`. A `sitecustomize.py` name alone can be legitimate; compare contents/hashes with the report without importing it.
6. Correlate `/tmp/.pc_once_72129118c59f5636c0bb`, `/tmp/remote_code_loader.lock`, `/tmp/.pc_sq_*`, `/tmp/.pc_e_*`, and orphaned Python processes with endpoint telemetry. The reported once-marker is evidence of a successful exfiltration POST, but absence is not clearance: cleanup and the loader's marker-free variant undermine negative findings.
7. Search existing DNS/proxy/firewall logs for `www.litellm.dev` and `/healthcheck`, and GitHub raw-content requests to `letters9813/pythonclient-test/main/domain.txt`. These are investigation indicators, **not URLs to visit**. The legitimate project uses `litellm.ai`; avoid blocking that domain by typo.

**Impact assessment:** The payload targeted readable process environments, cloud metadata credentials, SSH/browser/package-manager/AI-tool secrets, mounted secrets, and the proxy database's `LiteLLM_CredentialsTable` and `LiteLLM_ProxyModelTable` when `DATABASE_URL` was set. Container privileges, mounts, database permissions, and metadata access determine the blast radius—not the package's directory alone. The vendor excludes its private enterprise release, not every public image used by an enterprise customer.

Treat an affected installation with outbound access conservatively as successful exfiltration, per vendor guidance. A dormant remote-code stage did not stop the independent stealer. A cached artifact executed after registry removal remains dangerous. Metadata identifies candidates, not integrity or execution; a fetched-but-never-executed artifact is distinct from confirmed execution, but build and Python-startup history must support that conclusion.

## Remediation

1. Isolate affected workloads through trusted orchestration/network controls and suspend jobs that could recreate them. Preserve snapshots, logs, artifact hashes, and available volatile evidence under incident-response procedures; do not execute the malware to test it.
2. Block observed exfiltration/dead-drop access as temporary containment and enforce network-layer egress restrictions. Application configuration flags cannot constrain malicious Python code. Do not assume domain blocking removes the loader or recovers stolen credentials.
3. Stop affected instances and detached loaders using trusted management tooling. Removing only a venv or container is inadequate if the process could modify the host, shared mounts, credentials, or other runners; expand isolation/rebuild scope accordingly.
4. Rebuild hosts/runners where integrity is uncertain and recreate images/venvs from verified clean inputs. Pin the vendor-identified **1.106.2** rollback artifact by verified hash/digest, or a subsequently verified supported clean release. Keep the separate eMudhra trust remediation in scope; rollback is not evidence that every unrelated fix is present.
5. Exclude poisoned wheels, build layers, mirrors, and caches from future builds after evidence preservation. Do not reuse a compromised image as a new base or copy its site-packages into the replacement.
6. If emergency file cleanup is necessary, follow the vendor's hook/bytecode removal and detached-process guidance only after isolation and evidence capture. Treat it as containment, not proof of host integrity or permission to keep using the environment.
7. Recover secrets from a clean administrative system and deliver replacements only to rebuilt, contained workloads. Deny/revoke actively abused credentials immediately rather than waiting for a complete availability-preserving migration.

## Verification

- Check deployed image digests, wheel hashes, provenance source **and** expected builder/revision against approved clean artifacts. The attack used a signed official pipeline with the lookalike source `Berri-AI/litellm`; signature verification alone would not have rejected it.
- Re-run isolated metadata inventory on the replacement's package directories and compare complete image contents with the clean baseline. Confirm hooks/bytecode and detached loader processes are absent; missing three files alone does not rule out second-stage persistence.
- Confirm no jobs, floating tags, saved manifests, or autoscaling templates can restore malicious artifacts. Check currently running instances, not just the desired deployment configuration.
- Confirm replacement credentials work with least privilege and old credentials are revoked at each issuing service. Test revocation only through a safe authenticated check/provider status; do not put secrets in shell history, logs, or this report.
- Review post-cutover egress and provider audit/billing logs. Investigate access from unexpected networks, new keys/users, role-policy changes, registry writes, and suspicious model usage. Log gaps remain unknown, not a clean bill of health.

## Compromise response

- Build a credential ledger of provider, nonsecret key ID, permissions, last possible exposure, owner, revocation status, replacement consumers, and verification evidence. Include credentials reachable indirectly through databases or secret managers.
- Revoke every reachable upstream AI-provider key, LiteLLM master/virtual keys, database password, and mounted/environment secret. Review proxy configuration, added users, and model routes for attacker changes before restoring them.
- For AWS/GCP/Azure and Kubernetes, revoke persistent credentials, restrict compromised identities, and address already issued temporary sessions using provider-specific controls. Replacing a long-lived key or restarting a pod does not automatically invalidate every previously issued token.
- For developer hosts and CI runners, include GitHub OAuth/PATs, registry/package publishing tokens, SSH keys, browser sessions, and cloud/AI-tool credentials. Review organization members, deploy keys, workflows, branch-protection overrides, and artifact publication, not merely account passwords.
- Revoke or reissue accessible TLS/code-signing keys if exposed; remove attacker-created keys and sessions. Review downstream services for data access or tampered releases and notify relevant owners/providers as needed.
- The researcher recommends looking for AWS STS `GetCallerIdentity` around execution and subsequent role use. Search whatever CloudTrail/STS records were actually collected; lack of an event is not proof of no credential theft.

## Sources

- [Canonical October 23 attack-chain postmortem](https://docs.litellm.ai/blog/security-incident-oct-21-2026-attack-chain): authoritative corrected entry point and timeline.
- [Vendor incident and response post](https://docs.litellm.ai/blog/security-incident-oct-21-2026): affected artifacts, registry windows, private-registry exception, and rollback advice. Its retained early root-cause theories are explicitly superseded; this guide does **not** follow its unsafe `pip show` suggestion on suspected hosts.
- [Researcher issue #47826 and later vendor comments](https://github.com/BerriAI/litellm/issues/47826): payload evidence, hashes, image mappings, updated marker behavior, and October 24 clarifications. The 1.107.0 sdist had tampered build metadata even though it lacked the payload files; do not treat it as a safe fallback.

Sources freshly read on the update date. No malicious artifacts were downloaded or executed, no attacker endpoints were contacted, and no customer snapshots or audit logs were available. No universal later “cleanup version” or final completion time for every vendor credential revocation was established.
