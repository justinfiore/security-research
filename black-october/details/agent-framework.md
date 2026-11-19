# PyPI: agent-framework 1.26.1 and 1.26.2 steal credentials

**Last updated:** 2026-11-19 (America/New_York)

[Main summary](../black-october-2026.md#pypi-agent-framework-1261-and-1262-steal-credentials) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

`agent-framework` is the Python package for Microsoft Agent Framework. On November 17 two releases that are not in the project's repository were uploaded to PyPI. GitHub's advisory database lists them as malware, severity **critical**, with no numeric CVSS score. There is no CVE.

**GitHub advisory [GHSA-764m-3ppc-5m73](https://github.com/advisories/GHSA-764m-3ppc-5m73), published 2026-11-18 00:31 UTC, says versions 1.26.1 and 1.26.2 add a credential stealer that is not in 1.26.0.** 1.26.1 went up at 20:35 UTC as a wheel only. 1.26.2 went up at 21:08 UTC. Both have been removed from PyPI. A wheel that is already in a pip cache, a CI cache, or an internal mirror can still install. The last clean release is **1.26.0**. GitHub lists no patched version, because the malicious versions were removed rather than replaced.

Each wheel adds a `.pth` file. Python runs `.pth` files at every interpreter start, so the code runs without anyone importing the package. In 1.26.1 the files are `agent_framework_meta.pth` and `agent_framework_meta/_telemetry.py`. In 1.26.2 they are `af_runtime_diag.pth` and `af_runtime_diag.py`. The helper detaches and collects environment variables whose names contain strings such as `TOKEN`, `SECRET`, `PASSWORD`, `KEY`, `AZURE`, `AWS`, and `GITHUB`, the environments of other processes, and credential files including `~/.azure`, `.npmrc`, `.netrc`, `.git-credentials`, and `.docker/config.json`. It also requests Azure managed-identity tokens from the instance metadata service. 1.26.2 adds GitHub Actions OIDC tokens. The data is compressed and posted to `https://webhook.site/d381fd80-ec62-42ad-8f5c-d1b15103c9bb`. The rest of the wheel matches 1.26.0, and it still depends on `agent-framework-core[all]==1.26.0`.

Microsoft's issue, opened by Upwind, says the upload was outside the release pipeline and that whether the upload credential has been revoked is unconfirmed. Wiz says there is no `python-1.26.1` tag in `microsoft/agent-framework` and that the main branch does not contain the code. This run did not find a statement from Microsoft confirming the credential was revoked.

Wiz updated the same post on November 18 at 14:00 UTC. It says the attacker used a client certificate and private key for Microsoft's Engineering System Release Pipeline, the service that signs and publishes this package. A first publish from AWS was rejected by that service's IP filter. A second attempt from Microsoft-owned address space succeeded. Wiz says how the certificate was obtained is not known. The same update says the webhook token was on the free tier, which stores at most 50 requests, and that 17 of those are three unique cases where victim data left. A stored request is not a count of every install.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. A cache that still holds the wheel can still install it.

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
| Clean release | 2026-11-12 18:25 UTC | 1.26.0, wheel and sdist. [Wiz][wiz] |
| **Malicious 1.26.1** | **2026-11-17 20:35:20 UTC** | Wheel only. [Microsoft issue][issue] |
| Malicious 1.26.2 | 2026-11-17 21:08:39 UTC | Uploaded after 1.26.1 was removed. [Microsoft issue][issue] |
| Removed from PyPI | 2026-11-17, by about 21:30 UTC | Wiz. A cache can still install either wheel. |
| GitHub advisory | 2026-11-18 00:31:26 UTC | Critical malware. No patched version. [GHSA][ghsa] |
| Wiz update | 2026-11-18 14:00 UTC | ESRP client certificate. Three unique exfiltrations in the 50 stored requests. [Wiz][wiz] |
| **Last updated** | **2026-11-19 (America/New_York)** | Root cause and the stored-request count. Pin 1.26.0 and rotate what a malicious install could read. |

## Detection

1. **Installed version.** `pip index versions agent-framework` and the environment's `pip show agent-framework`. 1.26.1 and 1.26.2 are the two malicious versions. 1.26.0 and earlier are the ones GitHub says are clean.
2. **Files.** A site-packages tree that contains `agent_framework_meta.pth`, `af_runtime_diag.pth`, `agent_framework_meta/_telemetry.py`, or `af_runtime_diag.py` had one of the two wheels. Those names are not in 1.26.0.
3. **Caches.** A lockfile that pins `==1.26.1` or `==1.26.2`, a wheel cache, or an internal mirror can reinstall after PyPI removed them. `agent-framework-core` 1.26.0 is not the malicious package.
4. Absence of the files now does not show that the wheel never ran. The `.pth` runs at interpreter start.

## Remediation

1. Pin `agent-framework==1.26.0`. Do not run `pip install -U agent-framework` and trust "latest": the upload credential's revocation is unconfirmed, and a later upload could repeat this.
2. Delete cached wheels of 1.26.1 and 1.26.2 from pip caches, CI caches, and internal mirrors. Removing the package from the environment does not clear a cache.
3. Rebuild the environment from the pin. A process that already started under the malicious wheel keeps running until it is restarted from the clean environment.
4. Rotate the credentials that environment could read. The list is in Compromise response. Reinstalling does not expire a token that already left.

## Verification

- `pip show agent-framework` reports 1.26.0, and the lockfile pins it.
- The site-packages tree has none of the four file names above.
- Do not install 1.26.1 or 1.26.2 to confirm the behavior.

## Compromise response

GitHub's instruction is to treat an environment that installed either version as exposed and rotate the credentials reachable from it, including CI and GitHub Actions secrets.

That includes Azure tokens requested from the instance metadata service, Azure DevOps tokens, GitHub Actions OIDC tokens on 1.26.2, and anything in the credential files the advisory names. The posted data went to `webhook.site`. Wiz says that host stored 50 requests on the free tier and that 17 of them are three unique cases of victim data. A request the free tier did not store is not in that count. The advisory publishes no further indicator.

## Sources

- [GHSA-764m-3ppc-5m73][ghsa] — GitHub Advisory Database, published 2026-11-18 00:31:26 UTC. Malware, critical, no CVSS number. Affected `= 1.26.1` and `= 1.26.2`. No patched version. Removed from PyPI. Wheel hashes and the webhook host.
- [microsoft/agent-framework issue 10411][issue] — opened 2026-11-17 by Lidor Machluf, Upwind. Upload times, the second version, and the note that credential revocation is unconfirmed. Pin 1.26.0.
- [Wiz][wiz] — November 17, 2026, updated 2026-11-18 14:00 UTC. No matching tag in the repository. Both versions gone from PyPI by about 21:30 UTC. The November 18 update says an ESRP client certificate was used, a publish from AWS was rejected, and a publish from Microsoft-owned address space succeeded. Of 50 stored webhook requests, 17 are three unique cases of victim data.
- [OpenSSF malicious-packages, MAL-2026-20101](https://github.com/ossf/malicious-packages/blob/5f547b67f2daa8aa50d74a937b4c2077cccc495b/osv/malicious/pypi/agent-framework/MAL-2026-20101.json) — the OSV record GitHub cites.

[ghsa]: https://github.com/advisories/GHSA-764m-3ppc-5m73
[issue]: https://github.com/microsoft/agent-framework/issues/10411
[wiz]: https://www.wiz.io/blog/malicious-version-of-microsofts-agent-framework-published-to-pypi
