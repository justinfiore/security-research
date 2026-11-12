# GPUStack: a loopback request is the administrator

**Last updated:** 2026-11-11 (America/New_York)

[Back to GPUStack summary](../black-october-2026.md#gpustack-a-loopback-request-is-the-administrator) · [Changelog](../../CHANGELOG.md)

GPUStack is an open-source manager for GPU clusters that serve AI models. **GitHub, the CNA, rates [CVE-2026-102895](https://www.cve.org/CVERecord?id=CVE-2026-102895) CVSS 3.1 9.8 Critical** (`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`). Before 2.2.0, with `force_auth_localhost` left at its default of false, a request whose source looks like loopback is the built-in administrator. Two ways produce that source with no credentials: GPUStack sitting behind a same-host reverse proxy, so every remote request arrives from `127.0.0.1`, or a client-supplied `X-GPUStack-Real-IP: 127.0.0.1` header. The advisory says that access includes creating an administrator API key and running code on a worker through `POST /v2/inference-backends/from-yaml`. The project says it was exploited against a 2.1.1 deployment. **2.2.0 is not the release to install.** Two more flaws, fixed only in 2.2.2, affect 2.2.0 and 2.2.1. **2.3.0 is not the release to install either.** GPUStack 2.3.1, published 2026-11-11, fixes two more. [GHSA-gjf9-3p3r-9h9c](https://github.com/gpustack/gpustack/security/advisories/GHSA-gjf9-3p3r-9h9c) is Critical, CVSS 3.1 9.1, and has no CVE: from 2.0.0 before 2.3.1, inspecting a model repository can run Python the repository supplies, with the server process's permissions. [GHSA-mv55-58pg-4xgf](https://github.com/gpustack/gpustack/security/advisories/GHSA-mv55-58pg-4xgf) is High, CVSS 3.1 8.8: on 2.2.2 through 2.3.0, a non-owner member of the organization that owns a Kubernetes cluster can write through the cluster proxy. Neither advisory reports exploitation.

**CISA KEV:** [CVE-2026-102895](https://www.cve.org/CVERecord?id=CVE-2026-102895) listed — added 2026-11-09, federal due date 2026-11-12. Ransomware use Unknown. [CVE-2026-102894](https://www.cve.org/CVERecord?id=CVE-2026-102894) and [CVE-2026-103002](https://www.cve.org/CVERecord?id=CVE-2026-103002) are not listed (catalog 2026.11.09, checked 2026-11-09). [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| GPUStack 2.2.0 | 2026-06-18 15:54 UTC | Removes the loopback auto-admin path. The release notes do not name the flaw. |
| GPUStack 2.2.2 | 2026-07-24 14:47 UTC | Fixes the SAML callback and the cluster API proxy. The notes say CVE assignment is pending. |
| Loopback advisory | 2026-07-31; time/TZ unknown | [GHSA-gj9m-f8ph-pmhr][loop]. Exploitation against a 2.1.1 deployment, reported by Javier Sixto. |
| SAML advisory | 2026-09-30; time/TZ unknown | [GHSA-62m9-f875-rqw6][saml]. |
| Cluster-proxy advisory | 2026-10-01; time/TZ unknown | [GHSA-3hch-x692-6qj3][proxy]. |
| CVE records | 2026-11-04; time/TZ unknown | GitHub published all three. |
| **CISA KEV** | **2026-11-09** | Catalog 2026.11.09, released 16:16:16 UTC. CVE-2026-102895 only. Due 2026-11-12. |
| GPUStack 2.3.1 | 2026-11-11; time/TZ unknown | Fixes GHSA-gjf9-3p3r-9h9c (Critical 9.1, no CVE) and GHSA-mv55-58pg-4xgf (High 8.8). [Advisory][repo-python] |
| **Last updated** | **2026-11-11 (America/New_York)** | 2.3.1 is the release to install. |

## Detection

1. **The running server is below 2.2.2.** `pip show gpustack` prints the installed version. A container's image tag is the other place to look. 2.2.0 and 2.2.1 still have the SAML and cluster-proxy flaws. A version below 2.2.0 has all three.
2. **The API is reachable.** The loopback flaw needs either a reverse proxy on the same host that forwards to `127.0.0.1`, or a path that delivers the `X-GPUStack-Real-IP` header. A server bound only to localhost, with no proxy in front, is not the first case.
3. **A login is not required for the first two.** The cluster-proxy flaw needs an account that is not an administrator, and a Kubernetes cluster with a reachable worker.

A version string on a stopped container is not the version that was serving traffic. Read the running process.

## Remediation

1. **Upgrade the server and every worker to 2.3.1 or later and restart both.** 2.2.2 fixes the three CVEs. 2.3.0, released 2026-10-23, also fixes a High flaw with no CVE: an inference-only API key can reach worker management endpoints through 2.2.3. 2.3.1, published 2026-11-11, fixes the repository-Python flaw (2.0.0 through 2.3.0) and the organization-member proxy bypass (2.2.2 through 2.3.0). Updating only the server leaves a worker on the old code.
2. **Until the upgrade, set `force_auth_localhost=true`.** That closes the loopback path. It does not close the SAML callback. The SAML advisory says disabling SAML does not help, because the callback runs anyway. Block `/auth/saml/callback` at the proxy until 2.2.2 or later is running.
3. **Strip `X-GPUStack-Real-IP` at the edge** so a client cannot supply it. The 2.2.0 fix is what removes the trust; stripping the header is not a substitute for the upgrade.
4. **A Kubernetes deployment** should also restrict who can reach the API until 2.2.2 is running. The cluster proxy forwards a logged-in non-administrator's request with a worker's ServiceAccount.
5. The upgrade does not delete an administrator key already created, and it does not remove a backend an attacker added.

## Verification

- The running server and every worker report **2.3.1 or later**. 2.3.0 leaves the repository-Python flaw and the organization-member proxy bypass. 2.2.2 is the floor for the three CVEs and leaves the worker-management flaw in place.
- `force_auth_localhost` is true on any server you have not upgraded yet.
- A request that is not authenticated does not come back as the built-in administrator. Do not send a forged header to confirm that; read the version instead.
- An administrator API key you did not create is still valid after the upgrade. Finding one is a compromise, not a failed upgrade.

## Compromise response

- The project says a 2.1.1 deployment was exploited, with attacker-created custom backends running reverse shells. That report does not name the date, the operator, or how many servers. A deployment below 2.2.0 that was reachable is in the condition that report describes.
- Look for administrator accounts, API keys, and inference backends you did not create, and for worker processes you cannot account for. The advisory names `POST /v2/inference-backends/from-yaml` as the code-execution route.
- The SAML flaw can mint a session for an existing administrator, or create a new non-administrator, with no SAML configured. A new user you did not add is the sign to look for. The upgrade does not end a session already issued.
- Rotate worker credentials, cloud-provider secrets, and any administrator API key that existed before the upgrade. A key with scope `["*"]` stays valid from any address until you revoke it.
- On a Kubernetes cluster, review workloads created through the GPUStack worker's ServiceAccount. The proxy flaw can create one. The upgrade does not delete it.

## Sources

- [GHSA-gj9m-f8ph-pmhr][loop] — published 2026-07-31. CVSS 3.1 9.8. Fixed in 2.2.0. Exploited against a 2.1.1 deployment, reported by Javier Sixto. `force_auth_localhost=true` is the workaround.
- [GPUStack 2.2.0][r220] — released 2026-06-18 15:54 UTC. The notes do not name this flaw.
- [GHSA-62m9-f875-rqw6][saml] — published 2026-09-30. CVSS 3.1 9.1. Fixed in 2.2.2. SAML does not have to be configured. A captured signed response can still be replayed inside its validity window after the fix.
- [GHSA-3hch-x692-6qj3][proxy] — published 2026-10-01. CVSS 3.1 8.8. Fixed in 2.2.2. Needs a logged-in non-administrator and a Kubernetes worker.
- [GPUStack 2.2.2][r222] — released 2026-07-24 14:47 UTC. Names both flaws and says CVE assignment is pending.
- [GHSA-3r33-m53h-p2rw][worker] — published 2026-10-26. CVSS 3.1 7.6 High. No CVE. Fixed in 2.3.0. Through 2.2.3, an inference-only API key reaches worker management.
- [GHSA-gjf9-3p3r-9h9c][repo-python] — published 2026-11-11. CVSS 3.1 9.1 Critical. No CVE. Affected from 2.0.0 before 2.3.1. Model-repository Python runs during configuration inspection.
- [GHSA-mv55-58pg-4xgf][org-proxy] — published 2026-11-11. CVSS 3.1 8.8 High. Affected from 2.2.2 through 2.3.0. A non-owner organization member writes through the cluster proxy. Fixed in 2.3.1.
- [CVE-2026-102895][cve895], [CVE-2026-102894][cve894], [CVE-2026-103002][cve002] — GitHub, published 2026-11-04.
- [CISA KEV JSON feed][kev] — CVE-2026-102895 added 2026-11-09, due 2026-11-12 (catalog 2026.11.09, released 16:16:16 UTC). The other two are not listed.

[loop]: https://github.com/gpustack/gpustack/security/advisories/GHSA-gj9m-f8ph-pmhr
[saml]: https://github.com/gpustack/gpustack/security/advisories/GHSA-62m9-f875-rqw6
[proxy]: https://github.com/gpustack/gpustack/security/advisories/GHSA-3hch-x692-6qj3
[worker]: https://github.com/gpustack/gpustack/security/advisories/GHSA-3r33-m53h-p2rw
[repo-python]: https://github.com/gpustack/gpustack/security/advisories/GHSA-gjf9-3p3r-9h9c
[org-proxy]: https://github.com/gpustack/gpustack/security/advisories/GHSA-mv55-58pg-4xgf
[r220]: https://github.com/gpustack/gpustack/releases/tag/v2.2.0
[r222]: https://github.com/gpustack/gpustack/releases/tag/v2.2.2
[cve895]: https://www.cve.org/CVERecord?id=CVE-2026-102895
[cve894]: https://www.cve.org/CVERecord?id=CVE-2026-102894
[cve002]: https://www.cve.org/CVERecord?id=CVE-2026-103002
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
