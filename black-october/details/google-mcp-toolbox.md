# Google MCP Toolbox for Databases: Cloud Storage tools exfiltrate host files and overwrite local files

**Last updated:** 2026-10-26 (America/New_York)

[Main MCP Toolbox summary](../black-october-2026.md#google-mcp-toolbox-for-databases-cloud-storage-tools-exfiltrate-host-files-and-overwrite-local-files) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-93328](https://www.cve.org/CVERecord?id=CVE-2026-93328) (GHSA-2gc9-c85v-5vwr) — Google Cloud (CNA) CVSS 4.0: 9.3 Critical (CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:L/SI:L/SA:L/U:Amber); CWE-862 Missing Authorization and CWE-22 Path Traversal; NVD has not scored it (status "Received"); not in CISA KEV.** The CNA record says path traversal and missing authorization in the **`cloud-storage` source** of MCP Toolbox for Databases (`googleapis/mcp-toolbox`, formerly `googleapis/genai-toolbox`) **1.2.0 through 1.4.0** let "an unauthenticated remote attacker" **exfiltrate host files to external Google Cloud Storage buckets and overwrite arbitrary local files** via crafted tool invocation parameters. The affected range is 1.2.0 up to, but not including, **1.5.0**. GitHub's global advisory GHSA-2gc9-c85v-5vwr copies the CNA score; it is **unreviewed** and lists no affected package. [CNA][cve] [GHSA][ghsa] [NVD][nvd]

**Affected components:** the `cloud-storage-upload-object` tool reads any absolute path the Toolbox server process can read and uploads it to a caller-chosen bucket; `cloud-storage-download-object` writes a caller-chosen object to any absolute path the process can write (overwriting it when `overwrite` is true). Before 1.5.0 there was no way to limit either the buckets or the local paths. Both tools are in the prebuilt `cloud-storage` configuration (`--prebuilt cloud-storage`, tool names `upload_object` and `download_object`) as well as in custom `tools.yaml` files. Versions before 1.2.0 have no Cloud Storage source and are not affected. [Source docs][srcdoc] [Upload tool][upload] [Download tool][download] [Prebuilt config][prebuilt] [1.2.0 release][r120]

**Attack conditions:** an attacker must be able to invoke these tools, either by reaching the Toolbox HTTP endpoint or through an MCP client or AI agent that passes attacker-influenced parameters. Toolbox listens on `127.0.0.1:5000` by default, so exposure depends on `--address`, container port publishing or a cloud deployment. The upload direction needs only credentials that can write to the attacker's bucket, for example one the attacker has made writable. The agent and prompt-injection path is this guide's inference from how the tools work, not a statement in the CNA record. [Flags (v1.4.0)][flags]

**Worst case:** an attacker copies secrets from the host (service-account keys, `.env` files, database passwords in `tools.yaml`, SSH keys) into a bucket they control, then overwrites files the Toolbox process can write, such as configuration, scripts or `authorized_keys`, to gain persistence or code execution. Code execution is this guide's inference from arbitrary file overwrite, not a CNA claim. Running Toolbox as root makes every file reachable.

**The 1.5.0 fix is opt-in.** Pull request #3454 added two source settings, `allowedBuckets` and `allowedLocalRoots`; per the pull request and documentation, **if they are omitted, all buckets and all paths remain allowed**. Upgrading alone does not change behavior. The prebuilt `cloud-storage` configuration on the main branch (checked 2026-10-26) sets neither field. The CNA's solution is to upgrade **and** configure both settings, run Toolbox as an unprivileged user and restrict its IAM permissions. [PR #3454][pr3454] [Source docs][srcdoc] [CNA][cve]

**Related bypass:** [CVE-2026-102242](https://www.cve.org/CVERecord?id=CVE-2026-102242) (GHSA-3gp8-hjh6-xf3r) — Google (CNA) CVSS 4.0: **8.6 High** (CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N). In **1.2.0 through 1.9.0**, `allowedLocalRoots` checked paths lexically, so a symbolic link inside an allowed root could read or overwrite files outside it; the tool-level `destination_dir` had the same flaw. Pull request #3810 resolves symlinks, released in **1.10.0**. So a 1.5.0–1.9.x deployment that relies on `allowedLocalRoots` is still bypassable. The CNA scores this one as requiring an authenticated attacker with tool-execution permission. [CVE-2026-102242 record][cve2] [PR #3810][pr3810] [1.10.0 release][r1100]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26); [CVE-2026-102242](https://www.cve.org/CVERecord?id=CVE-2026-102242) is not listed either. No exploitation or public exploit was reported in the reviewed sources through 2026-10-26, and CISA's ADP assessment of CVE-2026-102242 says Exploitation "none" (CVE-2026-93328 has no ADP assessment yet). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory and affected versions](#inventory-and-affected-versions)
  - [Configuration and exposure](#configuration-and-exposure)
  - [Log and file review](#log-and-file-review)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| 1.2.0 released (first affected) | 2026-05-07 19:18:34 UTC | GitHub release time. Adds the Cloud Storage source and object tools; the 1.2.0 source tree contains the upload and download tools. [1.2.0 release][r120] |
| 1.4.0 released (last affected) | 2026-06-04 21:59:39 UTC | GitHub release time. [Releases][releases] |
| Private report | Unknown | The CNA credits reporter He Wei (gikaku), discovery "EXTERNAL". Pull request #3454 says "Reported by: HE WEI". No report date is published. [CNA][cve] [PR #3454][pr3454] |
| Fix pull request #3454 opened | 2026-06-16 14:12:45 UTC | "feat(source/cloud-storage): restrict bucket and local path access", public on GitHub. [PR #3454][pr3454] |
| Fix merged | 2026-06-18 01:38:50 UTC | Merge commit `2c3ca5d`. "Defaults to allow all." [PR #3454][pr3454] |
| **1.5.0 released (fix available)** | **2026-06-18 23:34:23 UTC** | GitHub release time. Listed as a feature ("Restrict bucket and local path access"), with no security notice. [1.5.0 release][r150] |
| Symlink fix #3810 merged | 2026-08-20 08:03:18 UTC | Resolves symlinks for `allowedLocalRoots` and `destination_dir`. [PR #3810][pr3810] |
| 1.10.0 released (symlink fix) | 2026-08-27 23:37:54 UTC | GitHub release time. [1.10.0 release][r1100] |
| CVE-2026-93328 reserved | 2026-09-17 17:27:06 UTC | CNA metadata. [CNA][cve] |
| CVE-2026-102242 published | 2026-09-29 17:47:16 UTC | Google CNA; affected 1.2.0–1.9.0. [CVE-2026-102242 record][cve2] |
| Latest release 1.15.0 | 2026-10-23 00:14:18 UTC | GitHub release time. [1.15.0 release][r1150] |
| **Public announcement: CVE-2026-93328 published** | **2026-10-26 14:24:09 UTC** | Google Cloud CNA record, about four months after the fix shipped. [CNA][cve] |
| NVD publication | 2026-10-26 15:16:45 UTC | NVD API; status "Received"; shows only the CNA score. [NVD][nvd] |
| GHSA-2gc9-c85v-5vwr published | 2026-10-26 15:34:48 UTC | Unreviewed global advisory, severity Critical, no affected package listed. No repository security advisory is linked, and the repository's published-advisories API returned none on 2026-10-26. [GHSA][ghsa] |
| CISA KEV | Not listed as of catalog 2026.10.23 (checked 2026-10-26) | [KEV JSON][kev] |

## Detection

### Inventory and affected versions

Find every Toolbox installation: local developer setups launched by IDEs or MCP clients, containers, Cloud Run or Kubernetes services, and Go programs that embed the module. Read-only ways to get the version (placeholders in capitals):

```sh
toolbox --version                                   # binary on PATH (Cobra version flag)
brew list --versions mcp-toolbox                    # Homebrew install
docker image ls us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox   # image tags in use
go list -m github.com/googleapis/mcp-toolbox        # run in a Go project that embeds it
```

| Version | CVE-2026-93328 | CVE-2026-102242 |
|---|---|---|
| Before 1.2.0 | Not affected (no Cloud Storage source) | Not affected |
| 1.2.0–1.4.x | **Affected**; no way to restrict buckets or paths | Not applicable (no `allowedLocalRoots` yet) but listed in the CNA range |
| 1.5.0–1.9.x | Fixed **only if** `allowedBuckets` and `allowedLocalRoots` are configured | **Affected** if you rely on `allowedLocalRoots` or `destination_dir` |
| 1.10.0 and later (latest 1.15.0) | Fixed **only if** both settings are configured | Fixed (hard links and race conditions remain documented limits) |

The version a container or IDE actually runs can differ from the binary on your PATH. Check the image tag or the binary each MCP client configuration launches. The npm wrapper (`npx @toolbox-sdk/server`) downloads a Toolbox binary; confirm the binary's version rather than assuming it from the package. Because GHSA-2gc9-c85v-5vwr is unreviewed and names no affected package, and OSV had no record for CVE-2026-93328 on 2026-10-26, Dependabot and `govulncheck`-style scanners may not flag it yet. [GHSA][ghsa]

### Configuration and exposure

1. **Is the Cloud Storage source in use?** Search each configuration and launch command (read-only):

   ```sh
   grep -RnE 'type: *"?cloud-storage|cloud-storage-(upload|download)-object|allowedBuckets|allowedLocalRoots|destination_dir' /PATH/TO/CONFIG/DIR
   ps -eo user,args | grep -E '[t]oolbox'             # look for --prebuilt cloud-storage, --address, --stdio, --config
   ```

   A source with `type: cloud-storage` and no `allowedBuckets`/`allowedLocalRoots`, or `--prebuilt cloud-storage`, is unrestricted on every version. Tools of type `cloud-storage-upload-object` or `cloud-storage-download-object` are the file-transfer paths. [Source docs][srcdoc]
2. **Who can call it?** Check the listen address and port (`ss -ltnp 'sport = :5000'` on Linux, or the port you set). `127.0.0.1` or `--stdio` limits direct access to local processes; `0.0.0.0`, published container ports and load balancers widen it. For Cloud Run, check whether the service allows unauthenticated invocation (`gcloud run services get-iam-policy SERVICE --region REGION`, looking for `allUsers` with `roles/run.invoker`). Also consider which AI agents and MCP clients can call the tools and whether they process untrusted content.
3. **What can it reach?** Note the OS user Toolbox runs as and the IAM roles of the identity behind its Application Default Credentials. `roles/storage.objectUser` or broader lets uploads and downloads succeed; the docs say read-only deployments need only `roles/storage.objectViewer`. [Source docs][srcdoc]

### Log and file review

Google published **no indicators of compromise** or log patterns.

- Review any record of MCP tool calls your deployment keeps (Toolbox logs, OpenTelemetry traces exported with `--telemetry-otlp` or `--telemetry-gcp`, an MCP gateway, or agent transcripts) for upload and download calls with buckets you do not own, or with local paths outside the directory you intended. Whether Toolbox records tool parameters depends on version and log settings; this guide has not verified what it logs.
- Cloud Audit Logs for Cloud Storage are written in the project that **owns the bucket**. Uploads to an attacker's bucket will generally not appear in your projects' logs. Downloads from it will not either, so the file-overwrite direction may only be visible on the host. Egress logs show traffic to `storage.googleapis.com`, which is not distinctive.
- On the host, look for recently modified files the Toolbox user could write, especially startup scripts, configuration, crontabs and SSH `authorized_keys`, and compare them with known-good copies.

A clean review does not prove the server was not abused: logs may not include parameters, and exfiltration to an external bucket leaves little trace in your own accounts.

## Remediation

1. **Upgrade to the latest release (1.15.0 as of 2026-10-26), and at least 1.10.0.** The CNA names 1.5.0 as the fix, but 1.5.0–1.9.x are still subject to the CVE-2026-102242 symlink bypass of `allowedLocalRoots`. Download from the GitHub release, which lists SHA-256 hashes, or pull the versioned image. [CNA][cve] [CVE-2026-102242 record][cve2] [1.15.0 release][r1150]
2. **Configure the boundaries on every `cloud-storage` source**; upgrading alone leaves them open:

   ```yaml
   kind: source
   name: my-gcs-source
   type: "cloud-storage"
   project: "my-project-id"
   allowedBuckets:
     - "my-app-bucket"
   allowedLocalRoots:
     - "/srv/toolbox/transfer"   # a dedicated directory holding no secrets
   ```

   The prebuilt `cloud-storage` configuration does not set these fields, so replace `--prebuilt cloud-storage` with a custom configuration if you need the transfer tools. From 1.6.0, tool-level `bucket` and `destination_dir` settings can pin individual tools further. [Source docs][srcdoc] [Download tool][download] [1.6.0 release][r160]
3. **Remove the upload and download tools if you do not need them**, keeping only the list and read tools.
4. **Apply least privilege**, as the CNA recommends: run Toolbox as an unprivileged OS user that can read and write only the transfer directory, and give its Google identity only the Cloud Storage roles it needs on your own buckets. Keep the listener on `127.0.0.1` or use `--stdio` unless remote access is required, and require authentication (for example Cloud Run IAM) when it is. Organizations using VPC Service Controls can additionally keep Toolbox's project inside a perimeter that blocks access to buckets outside it; this is general hardening, not vendor guidance for this CVE. Changing IAM, listeners or perimeters **changes state** and can break existing agents. [CNA][cve] [Source docs][srcdoc]
5. **Restart or redeploy** each server and every IDE or MCP client launch configuration so the new binary and configuration are what actually run. Keep the previous version available for rollback, but do not roll back to an affected version while the tools are exposed.

## Verification

- Confirm the running version (`toolbox --version` for the binary each client launches, or the deployed image tag) is 1.10.0 or later on every instance.
- Confirm by reading the effective configuration that every `cloud-storage` source has `allowedBuckets` and `allowedLocalRoots`, and that no unrestricted `--prebuilt cloud-storage` launch remains.
- Benign functional control on a **non-production** instance: call `list_objects` on a bucket you own that is not in `allowedBuckets`, and expect the error "bucket … is not allowed by source …". Call `download_object` with a harmless test object and a destination outside the allowed root, and expect "local path … is not under any allowed local roots". Then confirm a normal call inside the boundaries works. Do not upload real host files or overwrite files to "test" production. [Source code][srccode]

## Compromise response

- If an affected, unrestricted server was reachable by untrusted callers or by agents that processed untrusted content, treat every file the Toolbox user could read as disclosed. Rotate the credentials behind its Application Default Credentials, database passwords and connection strings in its configuration and environment, and any keys or `.env` files on the host.
- Compare files the Toolbox user could write with known-good copies, especially its own configuration and binaries, startup scripts, crontabs, shell profiles and SSH `authorized_keys`. Rebuild the host or container from a trusted image if you cannot establish integrity.
- Review your own buckets for unexpected objects or changes made by the Toolbox identity (Cloud Audit Logs Data Access logs, if enabled), and the identity's IAM bindings for broader access than intended.
- Preserve logs and host snapshots before cleaning up.

## Sources

- [CVE-2026-93328 record (Google Cloud CNA)][cve] — description, affected range 1.2.0 to before 1.5.0, CVSS 4.0 9.3 vector, CWEs, solution, reporter credit, reserved and published times.
- [GHSA-2gc9-c85v-5vwr][ghsa] — unreviewed GitHub global advisory; Critical; no affected package; published 2026-10-26 15:34:48 UTC.
- [NVD][nvd] — status "Received"; CNA score shown as secondary.
- [Pull request #3454][pr3454] and [1.5.0 release notes][r150] — the fix, its "allow all" default, merge and release times.
- [Cloud Storage source documentation][srcdoc], [upload tool][upload], [download tool][download], [prebuilt configuration][prebuilt] and [source code][srccode] — tool behavior, `allowedBuckets`/`allowedLocalRoots` semantics and limits, IAM roles, error messages.
- [CVE-2026-102242 record][cve2], [pull request #3810][pr3810] and [1.10.0 release notes][r1100] — the symlink bypass and its fix.
- [Releases][releases] ([1.2.0][r120], [1.6.0][r160], [1.15.0][r1150]) and [server flags at v1.4.0][flags] — release times, tool introduction, default listen address.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.23).

[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-93328
[ghsa]: https://github.com/advisories/GHSA-2gc9-c85v-5vwr
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-93328
[cve2]: https://cveawg.mitre.org/api/cve/CVE-2026-102242
[pr3454]: https://github.com/googleapis/mcp-toolbox/pull/3454
[pr3810]: https://github.com/googleapis/mcp-toolbox/pull/3810
[releases]: https://github.com/googleapis/mcp-toolbox/releases
[r120]: https://github.com/googleapis/mcp-toolbox/releases/tag/v1.2.0
[r150]: https://github.com/googleapis/mcp-toolbox/releases/tag/v1.5.0
[r160]: https://github.com/googleapis/mcp-toolbox/releases/tag/v1.6.0
[r1100]: https://github.com/googleapis/mcp-toolbox/releases/tag/v1.10.0
[r1150]: https://github.com/googleapis/mcp-toolbox/releases/tag/v1.15.0
[srcdoc]: https://github.com/googleapis/mcp-toolbox/blob/main/docs/en/integrations/cloud-storage/source.md
[upload]: https://github.com/googleapis/mcp-toolbox/blob/main/docs/en/integrations/cloud-storage/tools/cloud-storage-upload-object.md
[download]: https://github.com/googleapis/mcp-toolbox/blob/main/docs/en/integrations/cloud-storage/tools/cloud-storage-download-object.md
[prebuilt]: https://github.com/googleapis/mcp-toolbox/blob/main/internal/prebuiltconfigs/tools/cloud-storage.yaml
[srccode]: https://github.com/googleapis/mcp-toolbox/blob/main/internal/sources/cloudstorage/cloudstorage.go
[flags]: https://github.com/googleapis/mcp-toolbox/blob/v1.4.0/cmd/internal/flags.go
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
