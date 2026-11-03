# Rancher: Fleet gives an ordinary user cluster-admin

**Last updated:** 2026-11-02 (America/New_York)

[Main Rancher summary](../black-october-2026.md#rancher-fleet-gives-an-ordinary-user-cluster-admin) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Fleet's agent controller runs on the Rancher management cluster with cluster-admin rights. It did not restrict which kubeconfig secret a Fleet `Cluster` could reference. A user with only the default `user` global role, and with no bindings on the `local` cluster, could point a Fleet cluster in a namespace they control at the management cluster's own admin kubeconfig. The controller then ran that user's Fleet content there. SUSE scores **[CVE-2026-94290](https://www.cve.org/CVERecord?id=CVE-2026-94290) CVSS 3.1 9.1 Critical**. The GitHub advisory's CVSS 4.0 score is **9.4 Critical**. NVD has not scored it. Fleet is on by default, and ordinary users creating Fleet workspaces is documented behavior. [Fleet advisory][fleet] [CVE][cve]

The same Rancher releases fix a second flaw. The meta proxy forwarded the caller's own Rancher session or API token to a cloud provider when the UI looked up regions, sizes, or images. SUSE's CNA scores **[CVE-2026-88811](https://www.cve.org/CVERecord?id=CVE-2026-88811) CVSS 3.1 9.1 Critical**. The GitHub advisory labels it **High** and scores CVSS 4.0 **8.8**. Both scores are SUSE's. A default install is affected as soon as someone opens one of those provisioning forms. [Rancher advisory][rancher]

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03). Neither advisory reports in-the-wild use. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private reports | Unknown | Fleet: Kenzie Cuttler, Tulip Interfaces. Meta proxy: pmatseykanets. [Fleet][fleet] [Rancher][rancher] |
| Fleet fixes tagged | 2026-10-23 11:15–11:19 UTC | v0.16.3, v0.15.8, v0.14.12, v0.13.17. [Fleet releases][freleases] |
| Rancher fixes tagged | 2026-10-29 13:53–15:51 UTC | v2.15.3, v2.14.7, v2.13.11, v2.12.15, v2.11.19. [Rancher v2.15.3][r215] |
| Advisories published | 2026-10-29 17:26 UTC | Both GitHub advisories. CVE records reached NVD on 2026-11-02. [Fleet][fleet] [Rancher][rancher] |

## Detection

1. Read the Rancher version (`rancher --version`, or the image tag of the `rancher` pod). Affected Fleet lines are 0.16.0–0.16.2, 0.15.0–0.15.7, 0.14.0–0.14.11, and 0.13.0–0.13.16. Older than 0.13 is "possible" in the CNA text and is not a confirmed range.
2. Affected Rancher lines for the meta proxy are 2.15.0–2.15.2, 2.14.0–2.14.6, 2.13.0–2.13.10, 2.12.0–2.12.14, and 2.11.0–2.11.18.
3. Fleet workspace self-service is the default. A custom global role that already removed `create` on `fleetworkspaces` reduces exposure. It is not the fix.

## Remediation

1. Upgrade Rancher and its bundled Fleet together: **2.15.3, 2.14.7, 2.13.11, 2.12.15, or 2.11.19**, which ship Fleet **0.16.3, 0.15.8, 0.14.12, or 0.13.17**. The Fleet fix is what stops the privilege escalation. The Rancher change labels kubeconfig secrets so existing workspace clusters keep working.
2. After the upgrade, a Fleet `Cluster` that references a kubeconfig secret in another namespace is not imported until that secret has the label `fleet.cattle.io/kubeconfig-referenceable-from` set to the Cluster's namespace. Agents already deployed stay in place. The Helm value `allowUnlabeledKubeConfigSecretNamespaces: true` accepts unlabeled secrets in Fleet's own namespaces. It weakens the fix. Use it only until those secrets are labeled.
3. There is no Fleet setting that fully prevents this on an affected version. Removing workspace self-service and restricting who can write `fleet.cattle.io` clusters reduces exposure until the upgrade.

## Verification

- The running Rancher image is one of the patched releases, and the Fleet chart version matches.
- A cluster that should still be imported shows `Imported` after its secret is labeled. Do not create a Fleet cluster pointed at the management kubeconfig to test this.

## Compromise response

The meta proxy exposure is silent. It happens when someone opens a provisioning form, with no attacker action against Rancher required for the credential to leave.

- Rotate or delete long-lived Rancher API tokens that were used against the meta proxy, and invalidate existing user sessions so people sign in again.
- On the `local` cluster, look for Fleet agent namespaces and deployments you did not create, and for `ClusterRoleBinding` objects granting `cluster-admin` that you did not create.
- Downstream cluster credentials live on the management cluster. If the Fleet path was used, treat those as exposed too.

## Sources

- [GHSA-qfmw-gw96-ffcr][fleet] — Fleet, published 2026-10-29. CVSS 4.0 9.4. Patched Fleet and Rancher versions.
- [CVE-2026-94290][cve] — SUSE CNA, CVSS 3.1 9.1. NVD published 2026-11-02.
- [GHSA-x82x-2qj6-5rm2][rancher] — meta proxy, published 2026-10-29. CVSS 4.0 8.8 High. SUSE CNA CVSS 3.1 is 9.1.
- [CVE-2026-88811][cve2] — SUSE CNA.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30, neither CVE listed.

[fleet]: https://github.com/rancher/fleet/security/advisories/GHSA-qfmw-gw96-ffcr
[rancher]: https://github.com/rancher/rancher/security/advisories/GHSA-x82x-2qj6-5rm2
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-94290
[cve2]: https://www.cve.org/CVERecord?id=CVE-2026-88811
[freleases]: https://github.com/rancher/fleet/releases
[r215]: https://github.com/rancher/rancher/releases/tag/v2.15.3
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
