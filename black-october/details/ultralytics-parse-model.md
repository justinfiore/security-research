# Ultralytics: parse_model code injection through an untrusted model file

**Last updated:** 2026-10-29 (America/New_York)

[Main Ultralytics summary](../black-october-2026.md#ultralytics-parse_model-code-injection-through-an-untrusted-model-file) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-118618](https://www.cve.org/CVERecord?id=CVE-2026-118618) — ZDI CVSS 3.0 7.8 High (`AV:L/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`).** ZDI reports that Ultralytics `parse_model` does not validate a user-supplied string before executing it as Python code. Exploitation requires a user to visit a malicious page or open a malicious file; code runs with the current user's permissions. The disclosed record identifies version 8.4.65 as affected but does not establish a vendor fixed version.

**CISA KEV:** Not listed (catalog 2026.10.28, checked 2026-10-29). No active exploitation is reported by the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Report to vendor | 2026-06-18; time/TZ unknown | ZDI says it submitted the report to the vendor's GitHub account. [ZDI][zdi] |
| Public advisory and CVE record | 2026-10-28; time/TZ unknown | ZDI coordinated public release; ZDI is the CNA. [ZDI][zdi] [CVE record][cve] |

## Detection

1. Inventory Python environments, containers and application bundles that include the `ultralytics` package; record the installed version without importing untrusted models.
2. Treat deployments using **8.4.65** as affected according to the CNA record. The published record does not define a complete affected range, so other versions are unknown until the vendor publishes one.
3. Review whether users, automated pipelines or services load model definitions or model files from untrusted sources. Loading an untrusted file is a prerequisite in ZDI's description; package presence alone does not establish reachability.

## Remediation

1. Do not load model files, configurations or artifacts from untrusted sources. Require provenance review and isolated processing for externally supplied models while a vendor fixed-version statement is unavailable.
2. Run model-conversion or inspection workloads under a dedicated low-privilege account or isolated environment, without credentials, production mounts or network paths that are not needed for the task.
3. Monitor the Ultralytics project and the CVE record for an official fixed-version range. Do not infer that a newer package release fixes this CVE without vendor or CNA confirmation.

## Verification

- Confirm affected workflows reject or quarantine untrusted model artifacts before `parse_model` can process them.
- Validate ordinary trusted-model workflows in an isolated test environment after applying provenance controls. Do not open malicious model files to test this issue.
- Record the package version and artifact provenance for each deployment; unknown version or source remains unknown exposure.

## Compromise response

If an untrusted model was opened by an affected environment, investigate it as code execution in that environment's user context. Preserve the artifact and relevant process, shell, package-install and credential-access logs; rotate credentials available to that context and rebuild the environment from trusted dependencies if integrity is uncertain.

## Sources

- [ZDI-26-817][zdi] — disclosure date, CVSS score, user-interaction requirement and vulnerability description.
- [ZDI CNA CVE record][cve] — CVE identity, affected 8.4.65 version and score.
- [CISA KEV JSON feed][kev] — catalog 2026.10.28 status.

[zdi]: https://zerodayinitiative.com/advisories/ZDI-CAN-30121/
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-118618
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
