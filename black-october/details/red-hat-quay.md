# Red Hat Quay: an anonymous token installs a signing key

**Last updated:** 2026-11-12 (America/New_York)

[Back to Red Hat Quay summary](../black-october-2026.md#red-hat-quay-an-anonymous-token-installs-a-signing-key) · [Changelog](../../CHANGELOG.md)

Red Hat Quay is a container registry. Two Critical flaws were published on November 11. [CVE-2026-123710](https://www.cve.org/CVERecord?id=CVE-2026-123710) lets a caller with no account install a signing key. [CVE-2026-110697](https://www.cve.org/CVERecord?id=CVE-2026-110697) lets an account list another tenant's robot tokens.

**Red Hat rates CVE-2026-123710 CVSS 3.1 9.8 Critical** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`). Key rotation checks that a JWT is signed by an already approved service key and carries the expected audience and issuer. It does not check that the token was issued for rotation. An anonymous token from `/v2/auth`, with an audience the caller chooses, passes. The installed key is approved and can have no expiry, and registry tokens signed with it are accepted for any repository. Red Hat says deployments where `/keys` is reachable by untrusted clients are affected. The CVE record says Red Hat Quay 3 and Red Hat Quay 5 are affected and names no fixed version.

**Red Hat rates CVE-2026-110697 CVSS 3.1 9.9 Critical** (`CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`). The robot-account listing builds a SQL `LIKE` pattern from the namespace name and does not escape the underscore, so an underscore matches one character. An account that creates a namespace containing an underscore can list robot accounts, and their decrypted tokens, from a namespace the pattern matches. Red Hat says this breaks tenant isolation and that no elevated privilege is required. The record says Red Hat Quay 3 and Red Hat Quay 5 are affected, and that Red Hat OpenShift Update Service is not.

Dave O'Connor of Red Hat found both. Red Hat's pages do not report exploitation.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-12) for either CVE. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-11 14:00:00 UTC** | Red Hat's public date for CVE-2026-123710. Both CVE records were published 2026-11-11. [Red Hat][rh123710] |
| **Last updated** | **2026-11-12 (America/New_York)** | New item. |

## Detection

1. **Which Quay.** Quay.io is Red Hat's hosted registry. Red Hat says it is already fixed for CVE-2026-110697. A registry you run yourself is the one these builds apply to. The record also lists Quay 5, and Red Hat names no fixed build for Quay 5.
2. **Version.** For CVE-2026-110697, Red Hat names 3.9.28, 3.10.28, 3.12.24, 3.14.10, 3.15.9, 3.16.7, 3.17.7, and 3.18.3. A build below the one for its line is inside that flaw. Red Hat names no build for CVE-2026-123710, so a build on that list is not, on Red Hat's own page, a fix for the signing-key flaw.
3. **Who can reach `/keys`.** If the service-key endpoint answers a request from outside the registry's own components, the deployment is the one Red Hat says is affected by CVE-2026-123710.

## Remediation

1. Upgrade to the fixed build for the line you run: **3.9.28, 3.10.28, 3.12.24, 3.14.10, 3.15.9, 3.16.7, 3.17.7, or 3.18.3**. Red Hat names those for CVE-2026-110697. RHSA-2026:99027 ships 3.12.24 and RHSA-2026:99024 ships 3.14.10, and both list CVE-2026-123710. That is an erratum, not the CVE page, so do not treat the version list as Red Hat's statement of the fix for the signing-key flaw.
2. Restrict `/keys` at the proxy or load balancer so only trusted internal components can reach it. Red Hat gives that step for CVE-2026-123710 and names no other workaround. Turning off anonymous access does not close it: [solution 7149923](https://access.redhat.com/solutions/7149923), added to the CVE record on November 12, says anonymous access is on by default and that any valid Quay account can still install a key. The rest of that solution is behind a subscription.
3. Review audit logs for `service_key_rotate` and `service_key_delete` events with a null expiration, and remove a key you do not recognize. Red Hat says deleting a rogue key is not durable until a fixed build is deployed, because the request can install a new one.
4. For CVE-2026-110697, Red Hat says there is no complete workaround. Restricting who can create a namespace that contains an underscore, and rotating robot tokens for a namespace that collides with one, reduces exposure and does not fix it.
5. Quay.io needs nothing from you for CVE-2026-110697. Red Hat says it is already fixed. Quay 5 has no named fix on either page.
6. The upgrade does not show whether a key was already installed or a robot token was already copied.

## Verification

- The running registry reports one of the builds above, and `/keys` does not answer from outside the registry's own components.
- A repository that should be private still requires its own credentials. Do not try to install a key.

## Compromise response

Neither Red Hat page publishes an indicator beyond the audit events.

- Look for `service_key_rotate` events you did not run, and for an approved service key with no expiry that you do not recognize.
- If you find one, remove it and then deploy a fixed build. Removing it first is not durable.
- Rotate robot tokens for a namespace whose name collides with one that contains an underscore.
- A token copied before the rotation still works until you rotate it. The upgrade does not expire it.
- Resetting passwords or regenerating robot tokens does not revoke a signing key that was already installed. Solution 7149923 says so. The key can also delete the keys Quay uses.

## Sources

- [Red Hat CVE-2026-123710][rh123710] — read 2026-11-12. CVSS 3.1 9.8, public date 2026-11-11 14:00:00 UTC. No fixed version. Mitigation is to restrict `/keys` and review null-expiration key events.
- [Red Hat CVE JSON for CVE-2026-123710](https://access.redhat.com/hydra/rest/securitydata/cve/CVE-2026-123710.json) — Quay 3 and Quay 5 listed as Affected, with no released package.
- [Red Hat CVE-2026-110697][rh110697] — CVSS 3.1 9.9. Fixed builds 3.9.28, 3.10.28, 3.12.24, 3.14.10, 3.15.9, 3.16.7, 3.17.7, and 3.18.3. Quay.io already fixed.
- [CVE-2026-123710](https://www.cve.org/CVERecord?id=CVE-2026-123710) and [CVE-2026-110697](https://www.cve.org/CVERecord?id=CVE-2026-110697) — Red Hat CNA, published 2026-11-11. Same scores.
- [RHSA-2026:99027](https://access.redhat.com/errata/RHSA-2026:99027) — Quay 3.12.24, issued 2026-11-11, lists CVE-2026-123710.
- [RHSA-2026:99024](https://access.redhat.com/errata/RHSA-2026:99024) — Quay 3.14.10, issued 2026-11-11, lists CVE-2026-123710.
- [Solution 7149923](https://access.redhat.com/solutions/7149923) — public portion read 2026-11-12. Turning off anonymous access does not stop CVE-2026-123710, and resetting passwords or robot tokens does not revoke an installed key. The remediation steps below that line need a subscription and were not read.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-12. Neither CVE is listed.

[rh123710]: https://access.redhat.com/security/cve/cve-2026-123710
[rh110697]: https://access.redhat.com/security/cve/cve-2026-110697
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
