# LiteLLM: a custom-code guardrail runs code

**Last updated:** 2026-11-18 (America/New_York)

[Main LiteLLM summary](../black-october-2026.md#litellm-a-custom-code-guardrail-runs-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-40217](https://www.cve.org/CVERecord?id=CVE-2026-40217) is a sandbox escape in LiteLLM's custom-code guardrail. `POST /guardrails/test_custom_code` runs caller-supplied Python, and rewriting the bytecode gets past the filter that was supposed to block it. MITRE, the CNA, rates it **CVSS 3.1 8.8 High**, `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. NVD has not scored it. The proxy process is root in the default Docker image.

This is not the [1.107.0 malicious release](litellm.md) and not the [Enterprise file read](litellm-enterprise-file-read.md).

**CISA KEV:** Listed — added 2026-11-18, federal due date 2026-12-02. Ransomware use Unknown. Forensic triage is not required. Catalog 2026.11.18, released 2026-11-18T19:17:41.0354Z. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| X41 identified the flaw | 2026-02-13; time unknown | Bytecode rewrite of `/guardrails/test_custom_code`. [X41][x41] |
| Vendor acknowledged | 2026-02-18; time unknown | X41's timeline. [X41][x41] |
| Admin check on the compile endpoints | 2026-02-25 12:53:05 UTC | Pull request 22095 merged. A non-admin no longer reaches the endpoint. [GitHub][pr22095] |
| X41 public advisory | 2026-04-08; time unknown | X41-2026-001. X41 rates it CVSS 4.0 8.7 and says no patch existed that day. [X41][x41] |
| CVE record published | 2026-04-10; time unknown | MITRE. 8.8 High. Affected version is one image digest. [CVE][cve] |
| RestrictedPython replaces the sandbox | 2026-04-15 23:50:10 UTC | Pull request 25818 merged. [GitHub][pr25818] |
| v1.83.10-stable | 2026-04-27 17:01:01 UTC | First stable tag after that merge. The vendor advisory names 1.83.11, and that tag does not exist. [Release][rel] |
| Vendor advisory published | 2026-05-07; time unknown | GHSA-wxxx-gvqv-xp7p. GitHub's database scores it CVSS 4.0 7.5; the vendor page scores the same advisory 5.9. [GHSA][ghsa] |
| **CISA KEV** | **2026-11-18; time/TZ unknown** | Added. Federal due date 2026-12-02. Catalog 2026.11.18. [KEV][kev] |
| **Last updated** | **2026-11-18 (America/New_York)** | New item. Upgrade the proxy. |

## Detection

Read the installed version without importing the package. Do not run this inside an environment you suspect already executed attacker code; read the metadata from a snapshot.

```sh
python3 -I -S python-package-inventory.py /path/to/site-packages
```

| Source | Affected | Fixed |
|---|---|---|
| GitHub advisory, package range | `litellm` 1.81.8 through 1.83.9 | 1.83.10 |
| Vendor advisory text | Same range | 1.83.11 or later. No 1.83.11 tag exists. |
| MITRE CVE record | One image digest, through 2026-04-08 | Not named |
| X41, April 8 | `ghcr.io/berriai/litellm:main-latest` at digest `bb063970…` | None on that date |

The endpoint needs a credential. The vendor advisory says a proxy-admin credential in the default configuration. X41's proof uses the master key. A proxy that does not expose the management port is still affected if an administrator can reach it.

Two related flaws are not this CVE. Obsidian tracks an `allowed_routes` bypass as CVE-2026-47101 and a role change as CVE-2026-47102, and says the whole chain is closed in **v1.83.14-stable**, released 2026-05-02. Neither is in KEV. VulnCheck assigned those two; MITRE did not.

## Remediation

1. Upgrade the proxy to **v1.83.14-stable or later** and restart it. That is the first release Obsidian says contains the rest of the chain, and it is after the RestrictedPython change. v1.83.10-stable already contains the sandbox replacement for this CVE.
2. Until the restart, deny `POST /guardrails/test_custom_code` at the reverse proxy. That does not close `/guardrails` itself.
3. Do not leave the management port on an untrusted network.
4. The default image runs as root. A non-root user limits what the process can do and is not a fix.

## Verification

- The running image tag or the installed distribution is v1.83.14-stable or later.
- A request to `/guardrails/test_custom_code` from outside the proxy returns the proxy's deny, not a guardrail result. Do not send code to test the sandbox.

## Compromise response

CISA does not require forensic triage for this listing. A proxy that was reachable with an admin or master credential before the upgrade can have run code as the proxy user. Rotate `LITELLM_MASTER_KEY`, provider keys, and the database credential if you cannot show the endpoint was unreachable. Review custom-code guardrails for one you did not add. The upgrade does not remove a process that is already running.

## Sources

- [GHSA-wxxx-gvqv-xp7p][ghsa] — published 2026-05-07. Affected `litellm` 1.81.8 up to but not including 1.83.10. The description says fixed in 1.83.11. GitHub's database scores CVSS 4.0 7.5; the vendor page scores 5.9.
- [X41-2026-001][x41] — April 8, 2026. CVSS 4.0 8.7. The proof runs `id` as root. No patch on that date.
- [CVE-2026-40217][cve] — MITRE, published 2026-04-10. CVSS 3.1 8.8 High.
- [v1.83.10-stable][rel] — published 2026-04-27. First stable tag after pull request 25818.
- [Pull request 25818][pr25818] — merged 2026-04-15. Replaces the sandbox with RestrictedPython.
- [Obsidian Security](https://www.obsidiansecurity.com/blog/litellm-privilege-escalation-rce) — June 11, 2026, updated September 7. Says v1.83.14-stable, released 2026-04-25, closes CVE-2026-47101 and CVE-2026-47102 with this one. The tag was published 2026-05-02.
- [CISA KEV JSON feed][kev] — catalog 2026.11.18, released 2026-11-18T19:17:41.0354Z. Added 2026-11-18, due 2026-12-02. Ransomware use Unknown. Forensic triage No.

[x41]: https://www.x41-dsec.de/lab/advisories/x41-2026-001-litellm/
[ghsa]: https://github.com/BerriAI/litellm/security/advisories/GHSA-wxxx-gvqv-xp7p
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-40217
[rel]: https://github.com/BerriAI/litellm/releases/tag/v1.83.10-stable
[pr25818]: https://github.com/BerriAI/litellm/pull/25818
[pr22095]: https://github.com/BerriAI/litellm/pull/22095
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
