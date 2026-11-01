# Beta9: workspace token reaches the worker filesystem

**Last updated:** 2026-11-01 (America/New_York)

[Back to Beta9 summary](../black-october-2026.md#beta9-workspace-token-reaches-the-worker-filesystem) · [Changelog](../../CHANGELOG.md)

JFrog published three Critical flaws in self-hosted Beta9 on 2026-11-01. All three are fixed in the same 2026-09-15 releases: gateway **0.1.776** and worker **0.1.756** (pull request 1897, commit `a28bf12`). beam-cloud did not file a GitHub security advisory with that pull request. Each score is JFrog's **CVSS 3.1 9.9 Critical** (`AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`). NVD had not scored them when checked. A workspace token is required for all three.

| CVE | Component | What a workspace token can do |
| --- | --- | --- |
| [CVE-2026-120306](https://www.cve.org/CVERecord?id=CVE-2026-120306) | Worker before 0.1.756 | One image build runs as root in the worker pod's namespaces. The CNA's read-only proof saw the worker's `runc` binary. The worker's service-account token and host mounts are on that filesystem. |
| [CVE-2026-120307](https://www.cve.org/CVERecord?id=CVE-2026-120307) | Worker before 0.1.756 | The sandbox file API opens a path on the worker, not in the container. The CNA's read-only proof downloaded the worker pod's Kubernetes service-account token. Shipped remote-node manifests bind that account to `cluster-admin`. |
| [CVE-2026-120308](https://www.cve.org/CVERecord?id=CVE-2026-120308) | Gateway before 0.1.776 and worker before 0.1.756 | A volume identifier with parent-directory segments bind-mounts the worker's filesystem into the sandbox, read-write unless the volume was marked read-only. Confirmed on gateway 0.1.769 and worker 0.1.745. |

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-01). The CNA does not report in-the-wild exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Date | Event and evidence |
| --- | --- |
| 2026-09-07 02:47 UTC | CNA timeline for CVE-2026-120308: confirmed affected releases worker-0.1.745 and gateway-0.1.769 are current. [CVE-2026-120308][cve308] |
| 2026-09-15 04:03 UTC | Pull request 1897 merged as commit `a28bf12`. It validates volume identifiers, confines sandbox file APIs with `os.OpenRoot`, and runs Buildah steps under OCI isolation. [Pull request][pr] |
| 2026-09-15 04:03 UTC | worker-0.1.756 published. [Release][worker] |
| 2026-09-15 04:04 UTC | gateway-0.1.776 published. [Release][gateway] |
| 2026-11-01 12:49:05 UTC | JFrog publishes CVE-2026-120306. [Record][cve306] |
| 2026-11-01 12:49:51 UTC | JFrog publishes CVE-2026-120307. [Record][cve307] |
| 2026-11-01 12:51:50 UTC | JFrog publishes CVE-2026-120308. [Record][cve308] |
| Customer action | Upgrade both components. The image-build and file-API flaws are fixed in the worker only. The volume flaw needs both. |

**Evidence limits:** The pull request title is "Handle sandbox edge cases." The three CVE records describe the volume mount, the sandbox file API, and Buildah isolation. This guide did not re-audit the diff. beam-cloud's public [security advisories][advisories] page listed none of these CVEs when checked. The CNA's proofs are described as read-only; this guide did not repeat them.

## Detection

1. On every self-hosted gateway and worker, read the running version. Gateway builds **before 0.1.776** are inside the volume-mount range. Worker builds **before 0.1.756** are inside all three. The release tags are `gateway-0.1.776` and `worker-0.1.756`.
2. Each flaw needs a workspace token. The volume flaw also needs a deploy that attaches a volume. The file-API flaw needs one running sandbox. The image-build flaw needs one image build; the CNA says clip v2 layered builds are the default.
3. Look for volume identifiers that contain `/` or `..`, file-API paths with long runs of `..`, and image builds from workspaces that should not have been able to touch the worker. A clean log does not prove the path was never opened.

## Remediation

1. Upgrade the **worker to 0.1.756 or later** and the **gateway to 0.1.776 or later**, then restart both. The worker fix covers the image build and the file API. The volume flaw needs the gateway check as well, and the CNA says stubs stored before that check are validated when a fixed worker launches them.
2. There is no configuration workaround in the CVE records. Until the worker is 0.1.756 or later, do not treat a workspace token as unable to read the worker.
3. Hosted beam.cloud, if you do not run the gateway and worker yourself, is the operator's to upgrade. Ask them which builds are in production; the public records do not say.

## Verification

- The running worker is 0.1.756 or later and the running gateway is 0.1.776 or later, on every node, not only in the image tag you intended to deploy.
- After the upgrade, a volume identifier the workspace does not own, or one that contains a slash or `..`, must be rejected before a mount is built. A sandbox file path that leaves the container root must fail closed. Do not send a traversal payload to confirm either check.
- A stub saved before 2026-09-15 must hit the volume check when it is launched.

## Compromise response

- A workspace token that could deploy, open the file API, or start an image build before the worker upgrade is enough, under the CNA descriptions, to read and write that worker's files. The file-API record says the shipped remote-node service account is `cluster-admin`. Treat that token, other tenants' volumes, and host mounts on an unpatched worker as exposed, and rotate them at their issuers.
- Review worker files and other tenants' volumes for writes you cannot attribute. Replacing the binaries does not undo a file that was already changed.
- Revoke workspace tokens and the worker's Kubernetes service-account token that were valid on the unpatched cluster.

## Sources

- [CVE-2026-120306][cve306] — JFrog CNA, published 2026-11-01 12:49:05 UTC. Buildah chroot isolation.
- [CVE-2026-120307][cve307] — JFrog CNA, published 2026-11-01 12:49:51 UTC. Sandbox file API.
- [CVE-2026-120308][cve308] — JFrog CNA, published 2026-11-01 12:51:50 UTC. Volume identifier.
- [Pull request 1897][pr] — merged 2026-09-15 as commit `a28bf12`.
- [gateway-0.1.776][gateway] and [worker-0.1.756][worker] — fixed releases, 2026-09-15.
- [beam-cloud/beta9 security advisories][advisories] — none of these CVEs listed when checked.
- [CISA KEV JSON feed][kev] — none of the three listed (catalog 2026.10.30).

[cve306]: https://www.cve.org/CVERecord?id=CVE-2026-120306
[cve307]: https://www.cve.org/CVERecord?id=CVE-2026-120307
[cve308]: https://www.cve.org/CVERecord?id=CVE-2026-120308
[pr]: https://github.com/beam-cloud/beta9/pull/1897
[gateway]: https://github.com/beam-cloud/beta9/releases/tag/gateway-0.1.776
[worker]: https://github.com/beam-cloud/beta9/releases/tag/worker-0.1.756
[advisories]: https://github.com/beam-cloud/beta9/security/advisories
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
