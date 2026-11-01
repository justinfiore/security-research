# Prefab UI: Pyodide sandbox reaches the host

**Last updated:** 2026-11-01 (America/New_York)

[Back to Prefab UI summary](../black-october-2026.md#prefab-ui-pyodide-sandbox-reaches-the-host) · [Changelog](../../CHANGELOG.md)

JFrog published [CVE-2026-120338](https://www.cve.org/CVERecord?id=CVE-2026-120338) on 2026-11-01. Prefab UI's Generative UI sandbox runs caller-supplied Python inside Pyodide, in a Deno subprocess. From **prefab-ui 0.14.0 through 0.20.2** that process starts with unrestricted filesystem and network permission, and the Python can call Deno on the host. JFrog scores the unauthenticated case **CVSS 3.1 10.0 Critical** and the authenticated-tool-caller case **9.9 Critical**. NVD had not scored it when checked. The fix is **0.21.0**, released 2026-10-26; PyPI's current release is 0.21.1. PrefectHQ's GitHub advisory is still a draft and returned HTTP 404 when checked.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-01). The CNA does not report in-the-wild exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Date | Event and evidence |
| --- | --- |
| 2026-03-24 17:21 UTC | Sandbox added with `--allow-read`, `--allow-write`, and `--allow-net` (commit `fc4362f3`, pull request 334). [CVE record][cve] |
| 2026-03-27 02:36 UTC | prefab-ui 0.14.0 published on PyPI, the first release that includes the sandbox. [PyPI][pypi] |
| 2026-06-03 02:13 UTC | prefab-ui 0.20.2 published. JFrog confirmed the flaw on this release. [PyPI 0.20.2][pypi202] |
| 2026-08-05 16:12 UTC | Reported to PrefectHQ as GHSA-595q-jv4r-q7j9. The advisory was still unpublished when checked (HTTP 404). [CVE record][cve] |
| 2026-10-25 18:48 UTC | Fix merged in pull request 538, commit `030f074`. The runner revokes read, write, and network permission before accepting code. [Commit][commit] |
| 2026-10-26 19:00 UTC | prefab-ui 0.21.0 published on PyPI. The release notes do not mention this CVE. [Release][rel] [PyPI 0.21.0][pypi210] |
| 2026-11-01 15:24:54 UTC | JFrog publishes CVE-2026-120338. [Record][cve] |
| Customer action | Upgrade to 0.21.0 or later and restart. Until then, do not register `GenerativeUI` where an untrusted client can reach it. |

**Evidence limits:** JFrog describes a read of `/etc/passwd` and a write of a `.pth` file on 0.20.2. This guide did not repeat those steps. Servers that never run untrusted code in this sandbox, and hosts without Deno, are outside the described path.

## Detection

1. Find every environment that installed `prefab-ui`, including FastMCP apps that call `GenerativeUI`. Read the installed version without importing the package: `python3 python-package-inventory.py` from `black-october/`, or `pip index versions prefab-ui` against the environment you actually run. **0.14.0 through 0.20.2** are inside the range. **0.21.0 and 0.21.1** include the fix. A version below 0.14.0 does not ship this sandbox.
2. The remote path is FastMCP's `generate_prefab_ui` tool. It is exposed only if the server registers `GenerativeUI` and Deno is installed. A server that never executes caller-supplied code in this sandbox is not on the described path.
3. JFrog published no indicators of compromise. A successful call can read or write files as the server OS user, including a `.pth` file under the server virtualenv's `site-packages`. Unexpected files there, or a Deno child of the server, are worth investigating. Their absence does not prove the tool was never called.

## Remediation

1. Upgrade `prefab-ui` to **0.21.0 or later** (0.21.1 is current on PyPI) and restart every process that loaded it. FastMCP servers that register `GenerativeUI` pick up the fix by running that release.
2. Until that restart, do not register `GenerativeUI` on a server an untrusted client can reach. Removing Deno from `PATH` also stops the sandbox from starting; that is an availability change, not a patch.
3. The 0.21.0 runner revokes filesystem read, filesystem write, and network permission after startup, starts Deno with `--no-prompt`, and limits bootstrap network access to `cdn.jsdelivr.net:443`. Do not re-enable those permissions to "make the sandbox work."

## Verification

- The running environment reports `prefab-ui` 0.21.0 or later, and the process start time is after that install.
- On 0.21.0 or later, a sandbox read or write of a host path fails with a Deno permission error. Do not send JFrog's proof against production to confirm that.
- A server that does not register `GenerativeUI` does not expose `generate_prefab_ui`. Confirm that from the server's own tool list, not from the package version alone.

## Compromise response

- A client who could call `generate_prefab_ui` on an affected server could read and write files as that server's OS user. Treat files that user could read, and anything written into its virtualenv, as exposed.
- Look for unexpected `.pth` files and modules under `site-packages`. Replacing `prefab-ui` does not remove one.
- Rotate credentials that process could read, and restart from a clean environment if you cannot account for those files.

## Sources

- [CVE-2026-120338][cve] — JFrog CNA, published 2026-11-01 15:24:54 UTC. CVSS 3.1 10.0 and 9.9, affected 0.14.0 before 0.21.0.
- [JFrog JFSA-2026-001699278][jfrog] — same facts, plus the FastMCP path and the 0.20.2 confirmation.
- [Pull request 538][pr] and [commit 030f074][commit] — permission revocation, merged 2026-10-25.
- [v0.21.0][rel] — released 2026-10-26. The notes do not name this CVE.
- [prefab-ui on PyPI][pypi] — 0.14.0 (2026-03-27), 0.20.2 (2026-06-03), 0.21.0 and 0.21.1 (2026-10-26).
- [GHSA-595q-jv4r-q7j9][ghsa] — still unpublished (HTTP 404) when checked.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.30).

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-120338
[jfrog]: https://research.jfrog.com/vulnerabilities/prefab-ui-is-vulnerable-to-remote-code-execution-via-a-pyodide-js-bridge-to-deno-cve-2026-120338-jfsa-2026-001699278
[pr]: https://github.com/PrefectHQ/prefab/pull/538
[commit]: https://github.com/PrefectHQ/prefab/commit/030f074f85e0b1be0dd44b0283185aecb26337a2
[rel]: https://github.com/PrefectHQ/prefab/releases/tag/v0.21.0
[pypi]: https://pypi.org/project/prefab-ui/
[pypi202]: https://pypi.org/project/prefab-ui/0.20.2/
[pypi210]: https://pypi.org/project/prefab-ui/0.21.0/
[ghsa]: https://github.com/PrefectHQ/prefab/security/advisories/GHSA-595q-jv4r-q7j9
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
