# Gitea: built-in SSH server authentication bypass

**Last updated:** 2026-10-26 (America/New_York)

[Main Gitea summary](../black-october-2026.md#gitea-built-in-ssh-server-authentication-bypass-cve-2026-103059) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-103059](https://www.cve.org/CVERecord?id=CVE-2026-103059): no score in the Gitea CNA record. CISA ADP CVSS 3.1 9.1 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N). NVD shows only the CISA ADP score and has added none of its own.** Gitea's GitHub advisory shows the same 9.1 Critical vector, but its own text says "This is why severity is high rather than critical", so the vendor's view is inconsistent. [CNA][cve] [NVD][nvd] [GHSA][ghsa]

**What it is:** when **Gitea's built-in SSH server** is on (`START_SSH_SERVER = true`), Gitea looked up the presented public key with a SQL `LIKE` match on the key's text. On **SQLite**, `LIKE` ignores ASCII case. The attack works like this:

1. The attacker downloads a victim's RSA public key, which Gitea publishes without authentication at `/{username}.keys`.
2. They flip the case of base64 letters until the altered modulus is prime (about 1 in 1,100 tries for a 3072-bit key).
3. They derive a working private key for that look-alike key.
4. Gitea matches the look-alike key to the victim's account.

The victim's real private key is never involved. [GHSA][ghsa]

**Worst case:** an **unauthenticated remote** attacker gets git-over-SSH read and write access as **any user with a registered RSA key**. That covers every private, organization and collaborator repository the victim can reach, including pushes and `git-lfs-authenticate` tokens. The server log shows an ordinary successful key login. Write access to repositories can also change CI workflows (our inference; see [Compromise response](#compromise-response)). [GHSA][ghsa]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). CISA ADP SSVC: Exploitation "none", Automatable "yes", Technical impact "total" (2026-10-07). No exploitation reports were found. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means). [KEV][kev] [CNA ADP][cve]

**Versioning:** Gitea dropped the `1.` prefix. **28.0.0 is the release that follows 1.27.x**; it is not a jump past unseen versions. Affected: **≤ 1.27.3** (GHSA and CNA); NVD's CPE says before 28.0.0. Fixed: **28.0.0**, and later 28.1.0 and 28.2.0. No 1.27.x patch release exists among the GitHub releases checked. [Gitea 28.0.0 blog][blog] [GHSA][ghsa] [Releases][releases] [NVD][nvd]

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Built-in SSH server versus OpenSSH](#built-in-ssh-server-versus-openssh)
  - [Read-only inventory](#read-only-inventory)
  - [Logs and indicators](#logs-and-indicators)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Reporter credited as @carlini; no report date published. [GHSA][ghsa] |
| Fix merged to `main` (PR #39423, "fetch ssh key by fingerprint") | 2026-09-25 13:22:05 UTC | The fix was public in the repository before the advisory. [PR #39423][pr] |
| Gitea 28.0.0 tagged on GitHub | 2026-09-29 23:25:53 UTC | Release notes list "Fix(ssh): identify presented public keys by fingerprint" under SECURITY. [Release v28.0.0][rel] |
| Gitea 28.0.0 release blog | 2026-09-30; time/TZ unknown | The blog now names CVE-2026-103059. The CVE was reserved on 2026-10-04, so the blog text was edited after publication. What the original post said is not established. [Blog][blog] [CNA][cve] |
| CVE ID reserved | 2026-10-04 21:57:35 UTC | [CNA][cve] |
| **Public announcement**: GHSA-8pwg-hcgm-54cp | **2026-10-06 19:16:31 UTC** | The first publication of vulnerability details. [GHSA][ghsa] [GHSA API][ghsa-api] |
| CVE record published | 2026-10-06 19:22:57 UTC | Gitea CNA; no CVSS in the CNA container. [CNA][cve] |
| Gitea 28.1.0 released | 2026-10-06 20:14:45 UTC | [Releases][releases] |
| CISA ADP CVSS and SSVC added | 2026-10-07 14:17 UTC | 9.1 Critical; Exploitation "none". [CNA ADP][cve] |
| NVD analysis | By 2026-10-15 | Status "Analyzed". CPE: Gitea versions before 28.0.0. [NVD][nvd] |
| Gitea 28.2.0 released | 2026-10-18 18:25:03 UTC | [Releases][releases] |
| Exploitation in the wild | None reported | [CNA ADP][cve] |
| CISA KEV addition | Not listed | Catalog 2026.10.23, checked 2026-10-26. [KEV][kev] |

## Detection

### Built-in SSH server versus OpenSSH

| Deployment | Status per the advisory |
|---|---|
| `START_SSH_SERVER = true` (Gitea's built-in Go SSH server) with **SQLite** | **Affected** |
| **Official rootless container image** | **Affected with no configuration changes**: it hard-wires the built-in SSH server and SQLite |
| Built-in SSH server with **PostgreSQL** | Not affected (`LIKE` is case-sensitive there) |
| Built-in SSH server with **MySQL/MariaDB or MSSQL** | **Not addressed by the advisory.** The CVE says the lookup is case-insensitive on "some databases", and case behavior depends on collation (our inference). Treat as possibly affected. |
| **OpenSSH front-end** (the system `sshd` with `authorized_keys`, the `AuthorizedKeysCommand`, or the root container's SSH passthrough) | Not affected: sshd compares raw key blobs |
| SSH certificate login; HTTP signature auth | Not affected (exact-match lookups) |
| Users with only non-RSA keys | The advisory describes the attack against **RSA** keys only |

[GHSA][ghsa] [CNA][cve]

Whether deploy keys are affected is not addressed by the advisory; treat them as possibly affected. Gitea Cloud instances are upgraded automatically during their maintenance windows, according to Gitea's release notes. [Release v28.0.0][rel]

### Read-only inventory

These commands were not exercised on a real Gitea deployment. Run them on the Gitea host as a user who can read `app.ini`, or inside the container with `docker exec`. Placeholders are in capitals. Nothing is changed.

```sh
# Version (binary or container)
gitea --version            # or: docker exec CONTAINER gitea --version
curl -s https://GITEA_HOST/api/v1/version    # your own instance only; may require a token if the API is restricted

# SSH mode and database type (default config path differs by install, e.g. /etc/gitea/app.ini or /data/gitea/conf/app.ini)
grep -n -E '^\s*(START_SSH_SERVER|DISABLE_SSH|SSH_PORT|SSH_LISTEN_PORT|BUILTIN_SSH_SERVER_USER)\s*=' /PATH/TO/app.ini
grep -n -E '^\s*DB_TYPE\s*=' /PATH/TO/app.ini

# Which image runs (rootless images carry "rootless" in the tag)
docker ps --format '{{.ID}} {{.Image}}' | grep -i gitea
```

In the rootless image, the advisory says the built-in server and SQLite are hard-wired even if `app.ini` lines are absent. Confirm against the image's own configuration. [GHSA][ghsa]

### Logs and indicators

No IOCs have been published. The advisory says a forged login looks like an ordinary successful key login. Useful checks:

- **SSH access by source.** List successful SSH key authentications per user and source IP from Gitea logs or network logs for the SSH port. Look for logins from addresses that user has never used, especially for administrators and maintainers of sensitive repositories.
- **Fingerprint mismatch.** The forged key differs from the registered key, so its fingerprint differs too. If your logging records the presented key's fingerprint, compare it with `ssh-keygen -lf` output for the user's registered keys (from `/{username}.keys`). A mismatch tied to an account is a strong signal. Whether your Gitea version logs presented fingerprints was not established.
- **Unexpected Git activity over SSH:** pushes, new branches or tags, force-pushes, changes to `.gitea/workflows/` or `.github/workflows/`, and LFS activity.

No matches does not establish that the instance is clean.

## Remediation

1. **Upgrade to Gitea 28.0.0 or later.** Prefer the current 28.x release, since 28.1.0 and 28.2.0 have shipped. Back up first, then replace the binary or container and restart. [Blog][blog]
   - 28.0.0 contains **breaking changes**: Git 2.25 or newer is required, Git network operations go through a new egress proxy (review allow and block lists before upgrading), self-registration is off by default, and `[server] DOMAIN` is ignored. Read the release notes before upgrading production. [Blog][blog]
   - **Rollback caution:** downgrading to 1.27.x reintroduces the flaw, and the database may not support a downgrade.
2. **If you cannot upgrade immediately,** remove the affected configuration. Gitea has published no workaround; these options follow from the advisory's "not affected" list:
   - Disable the built-in server (`START_SSH_SERVER = false`) and serve SSH through OpenSSH, or
   - Disable SSH entirely (`DISABLE_SSH = true`) and use HTTPS with tokens, or
   - Block the built-in SSH port from untrusted networks. This only narrows exposure.

   Switching the database to PostgreSQL also removes the condition, but it is a migration, not a quick fix. [GHSA][ghsa]
3. Remember that RSA public keys are already public at `/{username}.keys`. Hiding them does not fix the flaw.

## Verification

- `gitea --version` or `/api/v1/version` shows 28.0.0 or later on every instance, including replicas and test or staging copies.
- `app.ini` and the image show the SSH mode you intended.
- Benign control: an existing user can still clone and push over SSH with their own key after the upgrade.
- Do **not** attempt the case-variant key forgery against production. If needed, reproduce it only on a disposable lab instance.

## Compromise response

If an affected instance (built-in SSH server with SQLite or an unconfirmed database, on 1.27.3 or earlier) was reachable by untrusted networks:

1. **Preserve** Gitea logs, SSH-port network logs and repository backups.
2. **Review repository history** pushed over SSH during the exposure window: unexpected commits, branches, tags and force-pushes. Compare against backups or mirrors.
3. **Review CI workflow changes,** in `.gitea/workflows/` and any external CI triggered by pushes. Write access to a repository can be used to run code on runners and read repository or organization secrets (our inference). Rotate those secrets if workflows changed unexpectedly.
4. **Rotate deploy credentials** stored in repositories, and treat **private repository contents as disclosed** for affected users.
5. Ask affected users to review their keys. Their real private keys are **not** exposed by this flaw, so rotating them is a precaution, not a fix.

## Sources

- [Gitea advisory GHSA-8pwg-hcgm-54cp][ghsa] ([API metadata][ghsa-api]): conditions, impact, affected and fixed versions, credits.
- [Gitea CNA record][cve] (with CISA ADP CVSS and SSVC); [NVD][nvd]; [CISA KEV feed][kev].
- [Gitea 28.0.0 release blog][blog], [GitHub release v28.0.0][rel], [Gitea releases][releases], [PR #39423][pr].

[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-103059
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-103059
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[ghsa]: https://github.com/go-gitea/gitea/security/advisories/GHSA-8pwg-hcgm-54cp
[ghsa-api]: https://api.github.com/repos/go-gitea/gitea/security-advisories/GHSA-8pwg-hcgm-54cp
[blog]: https://blog.gitea.com/release-of-28.0.0/
[rel]: https://github.com/go-gitea/gitea/releases/tag/v28.0.0
[releases]: https://github.com/go-gitea/gitea/releases
[pr]: https://github.com/go-gitea/gitea/pull/39423
