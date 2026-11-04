# Airbyte: Connector Builder runs attacker-chosen code

**Last updated:** 2026-11-04 (America/New_York)

[Main Airbyte summary](../black-october-2026.md#airbyte-connector-builder-runs-attacker-chosen-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**No CVE is assigned.** Airbyte rates [GHSA-g35w-6r6v-h4r7][ghsa] CVSS 3.1 9.9 Critical (`CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`). JPCERT/CC scores the same flaw CVSS 3.0 8.8 and CVSS 4.0 8.7, and labels the advisory Critical. Versions before 2.2.0 let a Connector Builder manifest name a Python class that is already installed, and the server loads it. That runs a command in the Connector Builder or Manifest Server container even when `AIRBYTE_ENABLE_UNSAFE_CODE` is off. JPCERT/CC says exploitation in the wild is confirmed. Airbyte's advisory does not. [GHSA][ghsa] [JVN][jvn]

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. JPCERT/CC's November 4 note is the exploitation claim. It does not name the attacker or a count of systems. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | Airbyte credits GitHub user schecthellraiser606. JVN credits Takeyasu Hyodo of ZOZO, Inc. The two credits are not the same page. [GHSA][ghsa] [JVN][jvn] |
| Airbyte 2.2.0 | 2026-08-10; time/TZ unknown | Release notes date. The GHSA says this release ships `airbyte/manifest-server` 7.23.7 and rejects custom components unless unsafe code is turned on. [Release notes][notes] |
| GitHub advisory | 2026-10-17; time/TZ unknown | Published by pablo-airbyte. No CVE. Airbyte Cloud needs no action. 1.x gets no fix. [GHSA][ghsa] |
| JVN#12040144 | 2026-11-04; time/TZ unknown | Says the flaw "has been confirmed to be exploited in the wild." Scores 8.8 and 8.7, not 9.9. The CVE field is empty. [JVN][jvn] |

## Detection

Read the running Airbyte version and the manifest-server image. Do not submit a manifest to test the flaw.

```sh
helm list -A
kubectl get deploy -A -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{" "}{range .spec.template.spec.containers[*]}{.image}{" "}{end}{"\n"}{end}' | grep -i manifest-server
```

| Deployment | Vulnerable | Fixed |
|---|---|---|
| Airbyte 2.x | below 2.2.0 | 2.2.0 or later, with manifest-server **7.23.7** |
| Airbyte 1.x | every 1.x release | no fix; move to 2.2.0 or later |
| Airbyte Cloud | not this flaw | no action |

A version string you cannot read is **unknown**, not safe. On 2.x before 2.2.0, Airbyte says the caller needs Workspace Reader or Organization Reader, or a higher role. On 1.x with the legacy Helm chart, the Connector Builder service did not inherit `global.auth.enabled`, so anyone who can reach that service can call it with no login.

Airbyte 2.3 (2026-09-15) and 2.4 (2026-10-09) are later than 2.2.0. The GHSA's fixed floor is 2.2.0. Those later notes do not say they reopened this flaw.

## Remediation

1. Upgrade self-managed Airbyte to **2.2.0 or later**. The fixed release ships `airbyte/manifest-server` **7.23.7**. If you mirror images, make that tag available before the upgrade or the pods will not start.

2. The 2.2.0 upgrade is one-way. The migrations drop tables that 2.1.x needs, and nothing dropped is recoverable. Take a database backup first. Rolling back to 2.1.x is not supported. Read the release notes before changing Helm values: `global.jobs.resources` and `global.workloads.resources.replication.*` start taking effect in 2.2.0.

3. Airbyte 1.x will not receive a fix. Plan the move to 2.2.0. Until then, allow only the Airbyte server to reach the Connector Builder service.

4. If you cannot upgrade a 2.x deployment yet, allow only the Airbyte server to reach the Manifest Server, and limit Workspace Reader and Organization Reader to people you trust. Setting `AIRBYTE_ENABLE_UNSAFE_CODE=true` turns custom code back on. Do that only when every user with workspace access is trusted.

5. Airbyte Cloud customers do not need to take any action. Self-Managed Enterprise should not upgrade to 2.2; Airbyte says to talk to a representative about a Cloud plan.

## Verification

- The running platform version is 2.2.0 or later, and the manifest-server image tag is 7.23.7 or a later tag that the chart for that version pins.
- `AIRBYTE_ENABLE_UNSAFE_CODE` is not `true` unless you meant to allow custom code.
- A Connector Builder test that uses a custom component class is rejected. Do not send a class name that loads code to prove the old behavior.
- Airbyte Cloud has nothing to verify for this flaw.

## Compromise response

JPCERT/CC says exploitation is confirmed and does not say how to recognize it. Airbyte's advisory does not mention exploitation.

- Treat secrets that the Connector Builder or Manifest Server container could read as exposed if a deployment below 2.2.0 was reachable by someone you do not trust. Rotate those credentials at the issuer. Upgrading does not expire them.
- Review workspace membership for Reader roles you did not grant, and review container logs for command execution you did not start. Absence of a log line is not a clean bill.
- On 1.x, anyone who could reach the Connector Builder port is in scope, not only logged-in users.

## Sources

- [GHSA-g35w-6r6v-h4r7][ghsa] — published 2026-10-17. CVSS 3.1 9.9 Critical. No CVE. Fixed in 2.2.0 / manifest-server 7.23.7. 1.x will not be fixed. Cloud is out of scope.
- [Airbyte 2.2 release notes][notes] — released 2026-08-10. One-way migration. Manifest-server tag 7.23.7.
- [JVN#12040144][jvn] — published 2026-11-04. Critical. CVSS 3.0 8.8 and CVSS 4.0 8.7. Says exploitation in the wild is confirmed. CVE field empty.
- [CISA KEV JSON feed][kev] — catalog 2026.11.03. No CVE to list.

[ghsa]: https://github.com/airbytehq/airbyte/security/advisories/GHSA-g35w-6r6v-h4r7
[notes]: https://docs.airbyte.com/release_notes/self-managed/v-2.2
[jvn]: https://jvn.jp/en/jp/JVN12040144/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
