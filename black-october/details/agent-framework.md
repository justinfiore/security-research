# PyPI: agent-framework 1.26.1 and 1.26.2 steal credentials

**Last updated:** 2026-11-17 (America/New_York)

[Main summary](../black-october-2026.md#pypi-agent-framework-1261-and-1262-steal-credentials) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

`agent-framework` is the Python package for Microsoft Agent Framework. On November 17 two releases that are not in the project's repository were uploaded to PyPI. GitHub's advisory database lists them as malware, severity **critical**, with no numeric CVSS score. There is no CVE.

**GitHub advisory [GHSA-764m-3ppc-5m73](https://github.com/advisories/GHSA-764m-3ppc-5m73), published 2026-11-18 00:31 UTC, says versions 1.26.1 and 1.26.2 add a credential stealer that is not in 1.26.0.** 1.26.1 went up at 20:35 UTC as a wheel only. 1.26.2 went up at 21:08 UTC. Both have been removed from PyPI. A wheel that is already in a pip cache, a CI cache, or an internal mirror can still install. The last clean release is **1.26.0**. GitHub lists no patched version, because the malicious versions were removed rather than replaced.

Each wheel adds a `.pth` file. Python runs `.pth` files at every interpreter start, so the code runs without anyone importing the package. In 1.26.1 the files are `agent_framework_meta.pth` and `agent_framework_meta/_telemetry.py`. In 1.26.2 they are `af_runtime_diag.pth` and `af_runtime_diag.py`. The helper detaches and collects environment variables whose names contain strings such as `TOKEN`, `SECRET`, `PASSWORD`, `KEY`, `AZURE`, `AWS`, and `GITHUB`, the environments of other processes, and credential files including `~/.azure`, `.npmrc`, `.netrc`, `.git-credentials`, and `.docker/config.json`. It also requests Azure managed-identity tokens from the instance metadata service. 1.26.2 adds GitHub Actions OIDC tokens. The data is compressed and posted to `https://webhook.site/d381fd80-ec62-42ad-8f5c-d1b15103c9bb`. The rest of the wheel matches 1.26.0, and it still depends on `agent-framework-core[all]==1.26.0`.

Microsoft's issue, opened by Upwind, says the upload was outside the release pipeline and that whether the upload credential has been revoked is unconfirmed. Wiz says there is no `python-1.26.1` tag in `microsoft/agent-framework` and that the main branch does not contain the code. This run did not find a statement from Microsoft confirming the credential was revoked.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. GitHub and the reporters do not report a confirmed install count. A cache that still holds the wheel can still install it.

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
| **Last updated** | **2026-11-17 (America/New_York)** | New item. Pin 1.26.0 and rotate what a malicious install could read. |

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

That includes Azure tokens requested from the instance metadata service, Azure DevOps tokens, GitHub Actions OIDC tokens on 1.26.2, and anything in the credential files the advisory names. The posted data went to `webhook.site`. The advisory publishes no further indicator. This run did not confirm how many installs resolved to either version.

## Sources

- [GHSA-764m-3ppc-5m73][ghsa] — GitHub Advisory Database, published 2026-11-18 00:31:26 UTC. Malware, critical, no CVSS number. Affected `= 1.26.1` and `= 1.26.2`. No patched version. Removed from PyPI. Wheel hashes and the webhook host.
- [microsoft/agent-framework issue 10411][issue] — opened 2026-11-17 by Lidor Machluf, Upwind. Upload times, the second version, and the note that credential revocation is unconfirmed. Pin 1.26.0.
- [Wiz][wiz] — November 17, 2026. No matching tag in the repository. Both versions gone from PyPI by about 21:30 UTC. About 41,000 downloads a week for the package, which is not a count of the malicious versions.
- [OpenSSF malicious-packages, MAL-2026-20101](https://github.com/ossf/malicious-packages/blob/5f547b67f2daa8aa50d74a937b4c2077cccc495b/osv/malicious/pypi/agent-framework/MAL-2026-20101.json) — the OSV record GitHub cites.

[ghsa]: https://github.com/advisories/GHSA-764m-3ppc-5m73
[issue]: https://github.com/microsoft/agent-framework/issues/10411
[wiz]: https://www.wiz.io/blog/malicious-version-of-microsofts-agent-framework-published-to-pypi
