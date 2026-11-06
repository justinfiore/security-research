# Kubeflow Pipelines: shared upload skips authorization

**Last updated:** 2026-11-06 (America/New_York)

[Main Kubeflow Pipelines summary](../black-october-2026.md#kubeflow-pipelines-shared-upload-skips-authorization) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

In multi-user mode, Kubeflow Pipelines before **2.18.0** does not check permission on a shared pipeline upload. The HTTP endpoints `POST /apis/v2beta1/pipelines/upload` and `POST /apis/v2beta1/pipelines/upload_version` call `canUploadVersionedPipeline`, which returns without a `SubjectAccessReview` when the target namespace is empty. An empty namespace is how the API addresses a cluster-wide pipeline, and it is what a caller gets by omitting the `namespace` parameter, because `REQUIRE_NAMESPACE_FOR_PIPELINES` defaults to false. GitHub rates [CVE-2026-77596][cve] **CVSS 3.1 9.6 Critical**. NVD has not scored it. [Advisory][ghsa]

A low-privilege tenant can create a shared pipeline or add a version to one that already exists. An unpinned recurring run that follows the latest version can then run that version in another tenant's namespace, as that run's service account. A run pinned to a version, or one that carries its own specification, does not pick the new version up. The advisory says the upload bypass was reproduced against the API server, and that the automatic execution path was checked by reading the 2.17.2 source. It says an end-to-end scheduled run was not performed. If the API server is reachable with no authenticating proxy, the same upload works with no identity header. The scored case is the authenticated tenant.

The gRPC path for the same write does authorize. It remaps the empty namespace to the system namespace and checks permission there. The advisory says that shows the HTTP skip is an omission.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-06). The advisory does not report in-the-wild use. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix merged | 2026-09-09; time/TZ unknown | Pull request 14352, commit `62516d8`. The advisory gives the date and does not give a time. [Advisory][ghsa] |
| 2.18.0 released | 2026-10-28 01:31:46 UTC | First fixed release. The notes say shared uploads receive additional authorization checks and do not name the CVE. [Release][rel] |
| Advisory published | 2026-10-28; time/TZ unknown | GHSA-rjr3-43j3-4q8g, Critical 9.6. Affected through 2.17.3. [Advisory][ghsa] |
| CVE record published | 2026-11-05; time/TZ unknown | GitHub CNA. Affected before 2.18.0, which matches the advisory's ceiling of 2.17.3. [CVE][cve] |

## Detection

1. Read the API server image you run, `ghcr.io/kubeflow/kfp-api-server`, or the release tag. **2.17.3 and earlier** are affected. 2.18.0 and later are the fix.
2. You are in the described path when the API server is in multi-user mode and `REQUIRE_NAMESPACE_FOR_PIPELINES` is unset or false. A single-user install returns before the check and is outside the scored case.
3. A multi-user install that already sets `REQUIRE_NAMESPACE_FOR_PIPELINES=true` rejects an empty namespace before the upload. That is the interim control the advisory names, not a patched server.

## Remediation

1. Upgrade the API server and its manifests to **2.18.0 or later**. The 2.18 [RBAC and client migration guide][rbac] is part of that release. Roll the server. Related scheduling changes do not replace this check and do not remove a version already uploaded.
2. After the upgrade, a shared upload needs `create` on the `pipelines` resource in the `pipelines.kubeflow.org` API group, in the KFP system namespace. Do not grant that to every tenant to keep old scripts working. The advisory says a Python SDK upload has to pass the namespace explicitly: `client.upload_pipeline("pipeline.yaml", namespace="my-namespace")`. Setting `Client(namespace=...)` does not fill that argument.
3. If you cannot upgrade yet, set `REQUIRE_NAMESPACE_FOR_PIPELINES=true`. That rejects every empty-namespace pipeline operation, including a shared upload you still want. It does not remove a version already stored.

## Verification

- The running API server image is 2.18.0 or later.
- A tenant who should not write shared pipelines gets a denial on `POST /apis/v2beta1/pipelines/upload` with no `namespace` parameter. Do not upload a pipeline you do not trust in order to test the other direction.

## Compromise response

The upgrade does not delete a pipeline version that was uploaded before it, and it does not change a recurring run that already points at one.

- List shared pipeline versions created or changed while the server was below 2.18.0, and compare them with a version you uploaded.
- Find recurring runs that follow the latest version of a shared pipeline. Pin each one to a version you have read, or point it at a namespaced pipeline.
- A run that already executed an injected version ran as that run's service account. Review that account's API activity and the data mounted into that namespace. The advisory says this does not, by itself, give cluster-admin.

## Sources

- [GHSA-rjr3-43j3-4q8g][ghsa] — GitHub, CVSS 3.1 9.6, published 2026-10-28. Affected through 2.17.3. Patched in 2.18.0.
- [CVE-2026-77596][cve] — GitHub CNA, published 2026-11-05. Affected before 2.18.0.
- [2.18.0][rel] — published 2026-10-28 01:31:46 UTC.
- [Pull request 14352][pr] — the fix, merged 2026-09-09.
- [CISA KEV JSON feed][kev] — catalog 2026.11.04, not listed.

[ghsa]: https://github.com/kubeflow/pipelines/security/advisories/GHSA-rjr3-43j3-4q8g
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-77596
[rel]: https://github.com/kubeflow/pipelines/releases/tag/2.18.0
[pr]: https://github.com/kubeflow/pipelines/pull/14352
[rbac]: https://github.com/kubeflow/pipelines/blob/2.18.0/docs/operator-guides/rbac-migration-2.18.md
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
