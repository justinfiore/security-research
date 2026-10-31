# LiteLLM Enterprise proxy: unauthenticated file read leaks the master key

**Last updated:** 2026-10-31 (America/New_York)

[Main LiteLLM Enterprise summary](../black-october-2026.md#litellm-enterprise-proxy-unauthenticated-file-read-leaks-the-master-key) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**No CVE is assigned.** LiteLLM rates [GHSA-w4c7-34wj-hqm8](https://github.com/BerriAI/litellm/security/advisories/GHSA-w4c7-34wj-hqm8) **CVSS 3.1 10.0 Critical** (`AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`). An unauthenticated request to any LLM route on a proxy with an Enterprise license loaded can make the proxy read a local file and send it to an attacker-chosen URL. A file such as `/proc/self/environ` exposes `LITELLM_MASTER_KEY` and provider API keys. The vendor says some configurations then allow arbitrary Python as root. Open-source deployments without a license do not load the affected code. This is separate from the [1.107.0 malicious release](litellm.md).

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. The advisory does not report observed exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Public advisory | 2026-10-27; time/TZ unknown | LiteLLM published GHSA-w4c7-34wj-hqm8. Fixed releases are 1.103.10, 1.104.8, 1.105.6 and 1.106.5. [Advisory][ghsa] |

The advisory does not give a private-report date. Finders credited are Dylan Ong (Karmasec) and Cyrill Bannwart (Compass Security).

## Detection

1. On a trusted host, read the installed version without importing the package: `python3 -I -S python-package-inventory.py /path/to/site-packages`, or read the `Version:` line in the installed `litellm` distribution metadata. Affected releases are everything before **1.103.10**, before **1.104.8**, before **1.105.6**, and before **1.106.5** on those lines.
2. The flaw applies only when an Enterprise license is loaded. A proxy with no license does not run the affected code. Do not treat "we use the open-source image" as proof no license file is mounted.
3. A version at or above the fixed release for its line is the patch check. It does not show whether an earlier request already read the environment.

## Remediation

1. Upgrade an Enterprise-licensed proxy to **1.106.5**, or stay on the fixed build for the line you run: **1.105.6, 1.104.8 or 1.103.10**. Restart the proxy after the upgrade.
2. Until then, reject or strip POST bodies that contain `standard_callback_dynamic_params`, `gcs_path_service_account`, `callbacks`, `success_callback` or `failure_callback`. Also limit the proxy's outbound connections to the LLM provider endpoints you configured. The vendor says the exploit has to POST the file to an attacker URL, so an egress allowlist stops that step even if the request arrives.
3. Those version numbers are also later than the malicious 1.107.0 release. Upgrading does not remove a stealer that already ran. Follow the [1.107.0 recovery](litellm.md#remediation) if that release was installed.

## Verification

- Confirm the running process is the upgraded build, not an older container that is still serving traffic.
- Do not send a request that names a local file or an external URL to test this on a production proxy.

## Compromise response

If the proxy was reachable from an untrusted network before the upgrade, treat `LITELLM_MASTER_KEY` and provider keys in the process environment as exposed and rotate them from a clean host. Also check for unexpected admin keys and model routes created after 2026-10-27. The advisory does not publish log signatures or say that exploitation has been observed.

## Sources

- [GHSA-w4c7-34wj-hqm8][ghsa] — affected and fixed versions, the Enterprise-license condition, CVSS 3.1 10.0, and the temporary filters.

[ghsa]: https://github.com/BerriAI/litellm/security/advisories/GHSA-w4c7-34wj-hqm8
