# Octopus Deploy: a role editor grants itself a deployment

**Last updated:** 2026-11-16 (America/New_York)

[Main Octopus summary](../black-october-2026.md#octopus-deploy-a-role-editor-grants-itself-a-deployment) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

[CVE-2026-116288](https://www.cve.org/CVERecord?id=CVE-2026-116288) is in Octopus Server. A user who can edit team-scoped roles can grant themselves permission to deploy to projects and environments they were not given. Octopus Deploy rates it **High** and **CVSS 4.0 8.6**. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`. Octopus is the CNA.

Affected: every 2019 through 2025 release, every 2026 release before **2026.2.13526**, and every 2026.3 release before **2026.3.15909**. The patch shipped on 2026-10-09. Octopus recommends the current release, **2026.3.16117**. Octopus Cloud was already moved and needs nothing. There is no workaround. Octopus says it knows of no public announcement of attacks and no malicious use.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-16). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported | 2026-10-02; time/TZ unknown | OriGabriel, through Bugcrowd. [Octopus advisory][adv] |
| Patch released | 2026-10-09; time/TZ unknown | 2026.2.13526 and 2026.3.15909. [Octopus advisory][adv] |
| **Public announcement** | **2026-11-16; time/TZ unknown** | Security Advisory 2026-28. The advisory page shows the date and no time. |
| **Last updated** | **2026-11-16 (America/New_York)** | New item. Upgrade Octopus Server. |

## Detection

In the Octopus web portal, open Configuration, then Diagnostics, and read the server version. A self-hosted server below 2026.2.13526, or a 2026.3 server below 2026.3.15909, is affected. Octopus Cloud is already patched.

The account that matters is one that can edit team-scoped roles and should not be able to deploy. The advisory does not name an audit event for the extra grant.

## Remediation

1. Upgrade a self-hosted Octopus Server to **2026.3.16117**. A server that cannot move that far goes to **2026.2.13526** or later, and a 2026.3 server goes to **2026.3.15909** or later.
2. Octopus Cloud needs no action.
3. There is no workaround. The upgrade does not remove a deployment permission that was already granted.

## Verification

The diagnostics page shows 2026.2.13526 or later, or 2026.3.15909 or later. Do not try to grant a deployment permission to test it.

## Compromise response

Octopus reports no malicious use. If an account that edits roles should not deploy, review deployments and role changes since October 9. A deployment by that account is a lead, not proof. Remove the permission after the upgrade.

## Sources

- [Octopus Deploy Security Advisory 2026-28][adv] — published 2026-11-16. High, CVSS 4.0 8.6. Discovered 2026-10-02, patched 2026-10-09. Fixed in 2026.2.13526 and 2026.3.15909. Recommended 2026.3.16117. No mitigation. Found by OriGabriel.
- [CVE-2026-116288](https://www.cve.org/CVERecord?id=CVE-2026-116288) — the CVE record, published 2026-11-16.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, read 2026-11-16. CVE-2026-116288 is not in it.

[adv]: https://advisories.octopus.com/post/2026/sa2026-28/
