# Kyverno: a namespace tenant can change the cluster

**Last updated:** 2026-11-08 (America/New_York)

[Back to Kyverno summary](../black-october-2026.md#kyverno-a-namespace-tenant-can-change-the-cluster) · [Changelog](../../CHANGELOG.md)

**VulnCheck (CNA) rates seven flaws Critical, published 2026-11-05.** Six are CVSS 3.1 9.8 or 9.9 and CVSS 4.0 9.3 or 9.4. The seventh, [CVE-2026-122321](https://www.cve.org/CVERecord?id=CVE-2026-122321), is CVSS 3.1 9.1 Critical and CVSS 4.0 8.5 High. NVD has not scored them. GitHub's own advisories for the same fixes rate most of them Critical and one High, and several of those pages still say no CVE is known. The fix for all seven is Kyverno **1.19.2**, released 2026-10-20. The CVE records are the public announcement.

A tenant who can create a namespaced Kyverno policy can make Kyverno's own controllers read or write outside that namespace, including cluster-scoped objects, using the controller's ServiceAccount. The ranges differ. [CVE-2026-122310](https://www.cve.org/CVERecord?id=CVE-2026-122310) exists only in 1.19.1: it is an incomplete fix of an earlier clamp. [CVE record][cve-122313] [Release][rel]

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08). Neither VulnCheck nor Kyverno reports exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [What each CVE covers](#what-each-cve-covers)
- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## What each CVE covers

| CVE | VulnCheck score | Affected | What it takes |
|---|---|---|---|
| [CVE-2026-122302](https://www.cve.org/CVERecord?id=CVE-2026-122302) | CVSS 4.0 9.3, CVSS 3.1 9.8, both Critical | before 1.19.2 | A namespaced Policy's generate rule is checked against the controller's permissions, not the author's. [GHSA-q62c-r9v2-cf64][ghsa-q62c] |
| [CVE-2026-122303](https://www.cve.org/CVERecord?id=CVE-2026-122303) | CVSS 4.0 9.4, CVSS 3.1 9.9, both Critical | 1.17.0 before 1.19.2 | A NamespacedMutatingPolicy returns a target in another namespace, and the background controller overwrites it. [GHSA-jcw5-3wcg-fqx5][ghsa-jcw5] |
| [CVE-2026-122304](https://www.cve.org/CVERecord?id=CVE-2026-122304) | CVSS 4.0 9.4, CVSS 3.1 9.9, both Critical | 1.17.0 before 1.19.2 | The cleanup controller builds its context loader with no policy, so a namespaced CleanupPolicy reads across namespaces. [GHSA-p58h-r4j3-h5vx][ghsa-p58h] |
| [CVE-2026-122310](https://www.cve.org/CVERecord?id=CVE-2026-122310) | CVSS 4.0 9.4, CVSS 3.1 9.9, both Critical | 1.19.1 before 1.19.2 | A Policy hides `../` in an apiCall path behind `#` or `?`. 1.19.1 cleaned the path it checked and sent the raw path. [GHSA-3xfv-vq8x-qhg4][ghsa-3xfv] |
| [CVE-2026-124440](https://www.cve.org/CVERecord?id=CVE-2026-124440) | CVSS 4.0 9.4, CVSS 3.1 9.9, both Critical | 1.19.1 before 1.19.2 | A malformed percent-escape such as `?a=%` makes the 1.19.1 namespace clamp decode one path and send another. The project rates the same advisory Critical, CVSS 3.1 9.9, and says 1.19.2 is the patched release. [GHSA-39w8-hv5g-f73w][ghsa-39w8] |
| [CVE-2026-122311](https://www.cve.org/CVERecord?id=CVE-2026-122311) | CVSS 4.0 9.4, CVSS 3.1 9.9, both Critical | 1.16.0 before 1.19.2 | `resource.get()` and `resource.post()` in a namespaced CEL policy accept `..` and leave the namespace. [GHSA-4pqm-wqq6-h9q2][ghsa-4pqm] |
| [CVE-2026-122313](https://www.cve.org/CVERecord?id=CVE-2026-122313) | CVSS 4.0 9.4, CVSS 3.1 9.9, both Critical | 1.17.0 before 1.19.2 | A NamespacedMutatingPolicy names another tenant's RoleBinding, and the background controller edits it. [GHSA-f96w-622v-rqpq][ghsa-f96w] |
| [CVE-2026-122321](https://www.cve.org/CVERecord?id=CVE-2026-122321) | CVSS 3.1 9.1 Critical, CVSS 4.0 8.5 High | 1.18.0 before 1.19.2 | verifyImages caches a pass by image tag. Moving the tag afterward admits the new digest without a new signature check. [GHSA-2r43-6962-xcw5][ghsa-2r43] |

The CNA's lower bound and the GitHub advisory's lower bound do not always match. [GHSA-jcw5-3wcg-fqx5][ghsa-jcw5] says the confirmed lower bound is 1.18.0 and that reachability on 1.17.x was not proven. The CVE record says 1.17.0. [GHSA-4pqm-wqq6-h9q2][ghsa-4pqm] says through 1.19.0; the CVE record says before 1.19.2. Trust the wider range for patching: 1.19.2 is the only patched release the vendor names.

The same 1.19.2 release fixes more advisories. VulnCheck published fourteen more CVE records for them on 2026-11-05, all High on CVSS 4.0. GitHub's pages for the same fixes still say no CVE is known. The fix is still only 1.19.2. No 1.17 or 1.18 patch was published. [Release][rel]

| CVE | VulnCheck score | Affected | What it takes |
|---|---|---|---|
| [CVE-2026-122305](https://www.cve.org/CVERecord?id=CVE-2026-122305) | CVSS 4.0 8.3, CVSS 3.1 7.7, both High | before 1.19.2 | A self-referential variable substitution hangs the admission webhook. |
| [CVE-2026-122306](https://www.cve.org/CVERecord?id=CVE-2026-122306) | CVSS 4.0 8.3, CVSS 3.1 7.7, both High | before 1.19.2 | A namespaced policy author submits a wildcard that burns admission-controller CPU. |
| [CVE-2026-122307](https://www.cve.org/CVERecord?id=CVE-2026-122307) | CVSS 4.0 8.3, CVSS 3.1 7.7, both High | before 1.19.2 | The admission-policy generator folds a PolicyException into a generated policy and the check is skipped. |
| [CVE-2026-122308](https://www.cve.org/CVERecord?id=CVE-2026-122308) | CVSS 4.0 8.4, CVSS 3.1 8.5, both High | before 1.19.2 | A user who can create or update a resource triggers a generate policy and spoofs a label. |
| [CVE-2026-122309](https://www.cve.org/CVERecord?id=CVE-2026-122309) | CVSS 4.0 8.2 High, CVSS 3.1 6.2 Medium | before 1.19.2 | A namespaced CEL policy is evaluated with no cost limit. |
| [CVE-2026-122312](https://www.cve.org/CVERecord?id=CVE-2026-122312) | CVSS 4.0 8.3, CVSS 3.1 7.7, both High | 1.19.1 before 1.19.2 | An APICall path hides `..` behind `?`. 1.19.1 only. |
| [CVE-2026-122314](https://www.cve.org/CVERecord?id=CVE-2026-122314) | CVSS 4.0 8.7, CVSS 3.1 7.5, both High | before 1.19.2 | A shallow variable substitution panics the policy engine. |
| [CVE-2026-122315](https://www.cve.org/CVERecord?id=CVE-2026-122315) | CVSS 4.0 8.7, CVSS 3.1 7.5, both High | before 1.19.2 | A crafted image attestation panics the policy engine. The record says no authentication. |
| [CVE-2026-122316](https://www.cve.org/CVERecord?id=CVE-2026-122316) | CVSS 4.0 8.4, CVSS 3.1 8.5, both High | 1.17.0 before 1.19.2 | A namespaced mutate-existing rule writes outside its namespace. |
| [CVE-2026-122318](https://www.cve.org/CVERecord?id=CVE-2026-122318) | CVSS 4.0 7.2, CVSS 3.1 7.7, both High | before 1.19.2 | verifyImages skips the subject check when the signing certificate has no Subject Alternative Name. |
| [CVE-2026-122319](https://www.cve.org/CVERecord?id=CVE-2026-122319) | CVSS 4.0 8.7, CVSS 3.1 7.5, both High | before 1.19.2 | An In or NotIn operator panics the policy engine. |
| [CVE-2026-122320](https://www.cve.org/CVERecord?id=CVE-2026-122320) | CVSS 4.0 8.3, CVSS 3.1 7.7, both High | before 1.19.2 | A namespaced generate.clone reads a resource in another namespace. |
| [CVE-2026-122322](https://www.cve.org/CVERecord?id=CVE-2026-122322) | CVSS 4.0 8.7, CVSS 3.1 7.5, both High | 1.11.0 before 1.19.2 | A compressed Notary attestation expands without a limit. |
| [CVE-2026-122323](https://www.cve.org/CVERecord?id=CVE-2026-122323) | CVSS 4.0 8.7, CVSS 3.1 7.5, both High | 1.11.0 before 1.19.2 | A compressed Notary signature expands without a limit. |

CVE-2026-122317 is not a Kyverno record. The seven Critical records above this table are unchanged. NVD has not scored any of these.

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Fix released | 2026-10-20 23:50:19 UTC | Kyverno v1.19.2. The notes count 24 GitHub advisories: 9 Critical, 14 High, 1 Moderate. [Release][rel] |
| GitHub advisories | 2026-10-21; time unknown | The vendor published the advisories. Several still say no CVE is known. [GHSA-3xfv-vq8x-qhg4][ghsa-3xfv] |
| CVE records | 2026-11-05 02:25 UTC | VulnCheck. Seven records, all Critical on CVSS 3.1. [CVE-2026-122313][cve-122313] |
| CVE-2026-124440 | 2026-11-08 13:15 UTC | VulnCheck. The percent-escape bypass of the 1.19.1 clamp. The project published the advisory earlier and rates it Critical, CVSS 3.1 9.9. Patched in 1.19.2. [GHSA-39w8-hv5g-f73w][ghsa-39w8] |
| **Last updated** | **2026-11-08 (America/New_York)** | Added CVE-2026-124440. The fix is still 1.19.2. |

## Detection

1. Read the running image, not a Helm chart that was never applied. `kubectl -n kyverno get deploy -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.template.spec.containers[*].image}{"\n"}{end}'` prints the controller images. 1.19.2 is the fix. 1.19.1 is still affected, and it is the only version affected by [CVE-2026-122310](https://www.cve.org/CVERecord?id=CVE-2026-122310).
2. A cluster where nobody but cluster admins can create `Policy`, `CleanupPolicy`, `NamespacedMutatingPolicy`, or `NamespacedValidatingPolicy` objects is outside the condition these records describe. Kyverno's own documentation treats namespaced policies as a delegation feature, so a cluster that hands that permission to namespace admins is inside it.
3. [CVE-2026-122321](https://www.cve.org/CVERecord?id=CVE-2026-122321) matters where a verifyImages rule checks an image tag that someone other than the cluster admin can move. A rule that pins a digest is outside that one flaw. It is not outside the other six.
4. There is no log line that proves a tenant did not do this. A policy in a tenant namespace that names another namespace is worth reading. Its absence proves nothing.

## Remediation

1. Upgrade Kyverno to **1.19.2 or later** and roll the controllers. The release notes name no other patched version, and Nirmata's write-up says no 1.18.x or 1.17.x patch was published. [Release][rel] [Nirmata][nirmata]
2. The Helm chart for this release is 3.9.2. Upgrading the chart without rolling the pods leaves the old controllers running.
3. There is no configuration switch in the advisories. Removing the permission to create namespaced policies closes the condition, and it also removes the feature those policies exist for.
4. The upgrade does not revert an object a controller already wrote.

## Verification

- The running controller images are 1.19.2 or later. A chart version of 3.9.2 with pods still on 1.19.1 is not the fix.
- After the roll, create a harmless namespaced policy in a test namespace and confirm Kyverno still admits ordinary workloads. Do not send a policy that names another namespace.
- A cluster that was on 1.19.1 needs the same check. That version fixed an earlier apiCall bug and left [CVE-2026-122310](https://www.cve.org/CVERecord?id=CVE-2026-122310) open.

## Compromise response

- Review namespaced `Policy`, `CleanupPolicy`, `NamespacedMutatingPolicy`, and `NamespacedValidatingPolicy` objects for targets outside their own namespace, and review `UpdateRequest` history for writes into namespaces the policy author does not administer.
- If one exists, treat the controller's ServiceAccount as having acted for that tenant. Rotate credentials that ServiceAccount could read, and review webhook configurations and RoleBindings created in that window.
- The upgrade stops the path. It does not undo a write that already landed.

## Sources

- [Kyverno v1.19.2 release][rel] — 2026-10-20 23:50:19 UTC. Lists the 24 advisories and says 1.19.2 is the fix.
- [CVE-2026-122302](https://www.cve.org/CVERecord?id=CVE-2026-122302), [CVE-2026-122303](https://www.cve.org/CVERecord?id=CVE-2026-122303), [CVE-2026-122304](https://www.cve.org/CVERecord?id=CVE-2026-122304), [CVE-2026-122310](https://www.cve.org/CVERecord?id=CVE-2026-122310), [CVE-2026-122311](https://www.cve.org/CVERecord?id=CVE-2026-122311), [CVE-2026-122313][cve-122313], [CVE-2026-122321](https://www.cve.org/CVERecord?id=CVE-2026-122321) — VulnCheck, published 2026-11-05.
- [GHSA-q62c-r9v2-cf64][ghsa-q62c] — generate-rule permission check. GitHub rates it High and names no CVE.
- [GHSA-jcw5-3wcg-fqx5][ghsa-jcw5] — cross-namespace overwrite. GitHub rates it Critical, CVSS 3.1 9.9, affected `>= 1.18.0`, patched 1.19.2.
- [GHSA-3xfv-vq8x-qhg4][ghsa-3xfv] — apiCall fragment bypass of the 1.19.1 fix. GitHub rates it Critical, CVSS 3.1 9.9.
- [GHSA-39w8-hv5g-f73w][ghsa-39w8] — the project. Critical, CVSS 3.1 9.9. Affected `>= 1.19.1`, patched 1.19.2. A malformed percent-escape defeats the 1.19.1 clamp. The page says this is present on 1.19.1 and on `main` at `dc45a66`, and the reproduction was on 1.19.1.
- [CVE-2026-124440][cve-124440] — VulnCheck, published 2026-11-08 13:15 UTC. CVSS 4.0 9.4 and CVSS 3.1 9.9. 1.19.1 before 1.19.2.
- [GHSA-4pqm-wqq6-h9q2][ghsa-4pqm], [GHSA-p58h-r4j3-h5vx][ghsa-p58h], [GHSA-f96w-622v-rqpq][ghsa-f96w], [GHSA-2r43-6962-xcw5][ghsa-2r43] — the other four.
- [Nirmata, October 23, 2026][nirmata] — says no 1.18.x or 1.17.x patch was published and that CVE IDs had been requested.
- [CISA KEV JSON feed][kev] — catalog 2026.11.06, checked 2026-11-08. None of these CVEs is listed.

[rel]: https://github.com/kyverno/kyverno/releases/tag/v1.19.2
[cve-122313]: https://www.cve.org/CVERecord?id=CVE-2026-122313
[ghsa-q62c]: https://github.com/kyverno/kyverno/security/advisories/GHSA-q62c-r9v2-cf64
[ghsa-jcw5]: https://github.com/kyverno/kyverno/security/advisories/GHSA-jcw5-3wcg-fqx5
[ghsa-p58h]: https://github.com/kyverno/kyverno/security/advisories/GHSA-p58h-r4j3-h5vx
[ghsa-3xfv]: https://github.com/kyverno/kyverno/security/advisories/GHSA-3xfv-vq8x-qhg4
[ghsa-39w8]: https://github.com/kyverno/kyverno/security/advisories/GHSA-39w8-hv5g-f73w
[cve-124440]: https://www.cve.org/CVERecord?id=CVE-2026-124440
[ghsa-4pqm]: https://github.com/kyverno/kyverno/security/advisories/GHSA-4pqm-wqq6-h9q2
[ghsa-f96w]: https://github.com/kyverno/kyverno/security/advisories/GHSA-f96w-622v-rqpq
[ghsa-2r43]: https://github.com/kyverno/kyverno/security/advisories/GHSA-2r43-6962-xcw5
[nirmata]: https://nirmata.com/2026/10/23/kyverno-1-19-2-security-release-26-advisories-fixed/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
