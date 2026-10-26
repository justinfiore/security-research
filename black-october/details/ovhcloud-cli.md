# OVHcloud CLI: hijacked GitHub release binaries steal secrets

**Last updated:** 2026-10-26 (America/New_York)

[Main OVHcloud CLI summary](../black-october-2026.md#ovhcloud-cli-hijacked-github-release-binaries-steal-secrets) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**GHSA-862f-55f5-vmvw: severity High, set by OVHcloud on its GitHub advisory. No CVE and no CVSS vector are assigned; GitHub lists "No known CVE".** This is a malicious-release incident. On **2026-10-19 between 14:47 and 16:21 UTC+2 (12:47–14:21 UTC)**, someone using a compromised OVHcloud developer's GitHub account replaced the release binaries of `ovhcloud-cli` **v0.11.0 through v0.15.0** with malicious builds. The builds were the real CLI recompiled with a secret stealer. OVHcloud counted about **250 downloads** during the 1 h 33 min window. Source code and the build pipeline were not affected. [OVHcloud advisory][adv]

**Affected:** binaries for Darwin arm64 and x86_64, Linux arm64 and x86_64, and Windows x86_64 (`ovhcloud.exe`) **downloaded during the window**. Copies of v0.11.0–v0.15.0 downloaded before the window are unaffected; v0.10.0 and earlier, and v0.16.0 and later, are unaffected. [OVHcloud advisory][adv]

**Worst case:** each run copies cloud credentials (AWS, Google Cloud, Azure, DigitalOcean), Docker and Kubernetes configuration, SSH keys, Terraform credentials, `.netrc`, npm and Git configuration, and AI-assistant and editor histories, then sends them to the attacker. Anyone who ran an affected binary should treat **every secret on that machine as compromised**. [OVHcloud advisory][adv]

**Root cause, per OVHcloud:** the developer installed the extension `color-picker-universal 2.8.91` on a personal MacBook on 2025-10-20. OVHcloud links the extension's Solana wallet to the GlassWorm threat actor. Stolen keys were later used to replace the binaries; the swap did not come from the MacBook itself. The repository did not enforce immutable releases at the time. [OVHcloud advisory][adv]

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. OVHcloud confirmed that malicious binaries were served for about 1 h 33 min and downloaded about 250 times. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory](#inventory)
  - [Hash and artifact checks (read-only)](#hash-and-artifact-checks-read-only)
  - [Network indicators](#network-indicators)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

OVHcloud's timeline uses UTC+2. UTC equivalents are added in the notes.

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Developer's personal machine infected | 2025-10-20; time/TZ unknown | Extension `color-picker-universal 2.8.91`. Several of the developer's personal repositories were also compromised in March 2026. [OVHcloud advisory][adv] |
| Malicious build of the source prepared | Unknown | The malicious Linux binary records commit `5ead8ef9` from 2026-10-13 08:35:05 UTC and a modified ("dirty") working tree. That is the commit time, not proof of when the build was made. [OVHcloud advisory][adv] |
| v0.15.0 Darwin binary replaced | 2026-10-19 14:47 UTC+2 (12:47 UTC) | Window opens. [OVHcloud advisory][adv] |
| All v0.15.0 binaries replaced | 2026-10-19 14:57 UTC+2 (12:57 UTC) | [OVHcloud advisory][adv] |
| v0.11.0–v0.15.0 binaries replaced | 2026-10-19 15:30 UTC+2 (13:30 UTC) | [OVHcloud advisory][adv] |
| Customer reports it publicly (issue #300) | 2026-10-19 15:50 UTC+2; GitHub records 13:50:09 UTC | Reporter: alink-tothepast. Private discovery by OVHcloud is not separately established; this public issue was the first report. [OVHcloud advisory][adv] [Issue #300][issue] |
| Malicious binaries removed | 2026-10-19 16:21 UTC+2 (14:21 UTC) | Window closes. [OVHcloud advisory][adv] |
| **Public announcement**: OVHcloud post on X | 2026-10-19 18:52 UTC+2 (16:52 UTC) | Time as stated in the advisory; the post itself was not reviewed. [OVHcloud advisory][adv] |
| Clean v0.16.0 released | 2026-10-19 19:16 UTC+2; GitHub records 17:16:54 UTC | Signed tag. The GitHub release is marked immutable. [OVHcloud advisory][adv] [Release v0.16.0][rel] |
| GitHub advisory GHSA-862f-55f5-vmvw published | 2026-10-20 12:49:39 UTC | Severity High; no CVE. [OVHcloud advisory][adv] |
| CVE | None assigned | GitHub advisory: "No known CVE". [OVHcloud advisory][adv] |
| CISA KEV | Not applicable | Not applicable without a CVE. |
| Later check | 2026-10-26 | The Darwin, Linux arm64 and x86_64, and Windows x86_64 assets are no longer attached to v0.11.0–v0.15.0 on GitHub. Only other platforms remain. Observed through the GitHub API. [Releases][rels] |

## Detection

### Inventory

1. List every machine and CI runner with an `ovhcloud` or `ovhcloud.exe` binary, including copies in containers, home directories and tool caches.
2. Find out when each copy was downloaded. Check CI logs, install-script logs, browser download history, package or tool manager logs, and file creation times. OVHcloud's advisory covers downloads from GitHub release assets. It does not list package-manager channels, so check whether your installer fetched from GitHub during the window.
3. **Do not run a suspect binary**, not even `ovhcloud version`. Running it is what triggers the theft. [OVHcloud advisory][adv]

### Hash and artifact checks (read-only)

OVHcloud's way of telling securely whether you are affected is to compare MD5 hashes with its list. [OVHcloud advisory][adv]

| Platform | Malicious MD5 |
|---|---|
| Darwin arm64 | `6f2f086239f3d88eb2750e871901927d` |
| Darwin x86_64 | `347e65eb7f2d78d1c6872690272a6cc3` |
| Linux arm64 | `01f57206d37c28cf711677f612052913` |
| Linux x86_64 | `301bff0b51980b9e76c93633e7cfd3bd` |
| Windows x86_64 | `6a3cf153338c416169cda2fe704c8848` |

These commands only read files and do not execute the binary. They have not been run against a real malicious sample. Run them as the user that owns the binary, or as an administrator. Replace `PATH_TO_BINARY` with the binary's path.

```sh
# Linux
md5sum PATH_TO_BINARY
# macOS
md5 -q PATH_TO_BINARY
# Stealer working folders, never deleted by the malware (Linux/macOS)
ls -ld "${TMPDIR:-/tmp}"/envchecker-* 2>/dev/null
```

```powershell
# Windows PowerShell
Get-FileHash -Algorithm MD5 PATH_TO_BINARY
Get-ChildItem -Path $env:TEMP -Directory -Filter 'envchecker-*'
```

- An `envchecker-` folder followed by 9–10 digits is created on **each run** of a malicious binary and never deleted. It holds copies of the stolen files, so treat it as sensitive evidence. Check the temporary folder of every user that might have run the CLI. [OVHcloud advisory][adv]
- If a Go toolchain is available, `go version -m PATH_TO_BINARY` reads build metadata **without running the binary**. OVHcloud's malicious Linux sample reported module version `v0.15.1-0.20261013083505-5ead8ef9b43d+dirty` and `vcs.modified=true`. Other platforms may differ, so this is a hint, not a substitute for the hash check. [OVHcloud advisory][adv]
- No hash match and no folder does not prove a machine was safe if the binary was deleted, temp folders were cleaned, or another user ran it.

### Network indicators

Search proxy, firewall, EDR and DNS logs from 2026-10-19 onward for: [OVHcloud advisory][adv]

- Exfiltration: `45.32.148[.]174` on port 443 (`hxxps://45.32.148[.]174/upload`). OVHcloud warns that the attacker can change this address at any time.
- Solana RPC endpoints used by the malware: `solana.drpc[.]org`, `solana-rpc.publicnode[.]com`, `solana.api.pocket[.]network`, `api.mainnet-beta.solana[.]com`, `solana.api.onfinality[.]io/public`. These are public services, so a match from a developer machine that does not use Solana is suspicious, not conclusive.
- Solana wallet used by the stealer: `BHaDaVbdCYFNaKZGn7yLXFneWoJHZgLiBYkHxVrjyALF`.

## Remediation

1. **Do not run** any v0.11.0–v0.15.0 binary obtained on 2026-10-19 until its hash has been checked. [OVHcloud advisory][adv]
2. **If affected:** rotate or deactivate every secret on that machine for all relevant services (see [Compromise response](#compromise-response)), delete the malicious binary, and install **v0.16.0** or later. [OVHcloud advisory][adv]
3. **If not affected:** upgrade to v0.16.0 or later anyway. The affected platforms' v0.11.0–v0.15.0 assets have been removed from GitHub, so you cannot reinstall those versions from there. [Releases][rels]
4. Pin CLI downloads in CI by version **and** checksum, so a replaced asset fails the install instead of running.

## Verification

- `md5sum` (or the platform equivalent) of every installed `ovhcloud` binary does not match any value in the table above.
- Before extracting it, check that the downloaded v0.16.0 **archive** (`.tar.gz` or `.zip`) matches its SHA-256 line in `ovhcloud-cli_0.16.0_checksums.txt` from the [v0.16.0 release][rel], for example with `sha256sum -c --ignore-missing ovhcloud-cli_0.16.0_checksums.txt` in the download directory. The file lists hashes of the archives, not of the extracted binary. That release is marked immutable on GitHub, but its checksum file comes from the same GitHub project, so it is not independent of a future account compromise.
- After rotation, the old cloud keys, SSH keys, tokens and kubeconfig credentials are rejected by their issuers.
- No further connections to the exfiltration IP appear.

## Compromise response

OVHcloud's FAQ says that if you downloaded or updated the CLI in the window and ran it, the secrets stored on that computer should be considered compromised. [OVHcloud advisory][adv]

- Preserve the binary, the `envchecker-*` folders and relevant logs. Keep them in restricted storage because the folders contain your secrets.
- From a clean machine, rotate at the issuer: AWS access keys and S3 credentials, Google Cloud credentials and tokens, Azure tokens, DigitalOcean (`doctl`) tokens, OVHcloud API credentials, Kubernetes credentials, Docker registry credentials, npm tokens, Terraform Cloud tokens, `.netrc` passwords, Git credentials, and SSH keys. Remove old public keys from `authorized_keys` files and Git hosting accounts.
- Treat AI-assistant and editor histories (VS Code, Cursor, Continue, Cody, OpenCode, Hermes, Claude) as disclosed. Rotate any secrets pasted into them.
- Review cloud audit logs, such as CloudTrail, GCP and Azure activity logs, and Kubernetes audit logs, for use of the stolen credentials from 2026-10-19 12:47 UTC onward.
- If a CI runner ran the binary, also rotate the runner's secrets and review the pipelines and artifacts it produced.

## Sources

- [OVHcloud advisory GHSA-862f-55f5-vmvw][adv]: timeline, affected builds, stolen files, IOCs, hashes, root cause and FAQ.
- [Issue #300][issue]: the public customer report.
- [GitHub releases][rels] and [v0.16.0 release][rel]: release metadata, immutability and the remaining assets (checked 2026-10-26).
- Not reviewed: OVHcloud's X post, and the Open Source Malware write-up that the advisory references.

[adv]: https://github.com/ovh/ovhcloud-cli/security/advisories/GHSA-862f-55f5-vmvw
[issue]: https://github.com/ovh/ovhcloud-cli/issues/300
[rels]: https://github.com/ovh/ovhcloud-cli/releases
[rel]: https://github.com/ovh/ovhcloud-cli/releases/tag/v0.16.0
