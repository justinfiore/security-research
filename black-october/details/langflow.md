# Langflow: authenticated RCE via MCP stdio server configuration

**Last updated:** 2026-10-26 (America/New_York)

[Main Langflow summary](../black-october-2026.md#langflow-authenticated-rce-via-mcp-stdio-server-configuration) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Two related Langflow advisories cover the same root problem. Both are rated GitHub CNA CVSS 3.1 9.9 Critical (CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H). NVD has not scored either one (status: Awaiting Analysis).** [CNA 105740][cve40] [CNA 105697][cve97] [NVD 105740][nvd40] [NVD 105697][nvd97]

- **[CVE-2026-105740](https://www.cve.org/CVERecord?id=CVE-2026-105740) / GHSA-7w94-79vh-5mr2.** Any authenticated user, including a non-admin, can add an MCP server with the **stdio** transport through `POST /api/v2/mcp/servers/{server_name}`.
  - Langflow passes the `command` field to `bash -c "exec {command}"` with no validation, and the `env` field allows `LD_PRELOAD` and `PATH` injection.
  - The command runs when the server list is fetched (`GET /api/v2/mcp/servers?action_count=true`), and again every time anyone opens the MCP settings page.
  - The CNA says versions **before 1.9.0** are affected and **1.9.0** fixes it. [GHSA-7w94][ghsa40] [CNA][cve40]
- **[CVE-2026-105697](https://www.cve.org/CVERecord?id=CVE-2026-105697) / GHSA-w794-rj3p-xv45.** This covers the same execution sink more broadly.
  - **1.9.0 blocked only the REST "Add MCP Server" route.** Through **1.10.2**, MCP stdio configurations embedded in flows or passed as tweaks still reached `bash -c` unchecked.
  - The full fix is in **Langflow 1.10.3** (with langflow-base 0.10.3 and lfx 1.10.3). Affected versions: `langflow` 1.1.2 up to (not including) 1.10.3, `langflow-base` 0.1.2 up to 0.10.3, and `lfx` before 1.10.3.
  - With **`LANGFLOW_AUTO_LOGIN=true`**, `GET /api/v1/auto_login` hands out a token without credentials. The advisory calls this the default, which makes the flaw reachable **without an account** on exposed instances. [GHSA-w794][ghsa97] [CNA][cve97]

**Worst case:** OS command execution as the Langflow process user. That gives full server compromise, theft of environment secrets (LLM and API keys, database credentials, `LANGFLOW_SECRET_KEY`), access to the internal network and cloud metadata, and a persistent backdoor stored in MCP server settings that ordinary flow review does not show. [GHSA-7w94][ghsa40]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Five other Langflow CVEs are in KEV (added between 2025-05-05 and 2026-07-21), so Langflow is a repeat target. [What KEV means](../black-october-2026.md#what-cisa-kev-means). [KEV][kev] Absence from KEV is not evidence that exploitation has not occurred.

**Exploitation evidence comes from one third party only.** Previdian, a honeypot-sensor vendor, reports exploitation attempts it attributes to CVE-2026-105740:

- First observed **2026-09-19 03:14 UTC**.
- **4,896 attempts from 34 IPs in 17 countries**, all seen by **one sensor**, as of its 2026-10-26 page.
- The sequence included a version check, an `auto_login` attempt (disabled in the honeypot), a **login with a common username and password**, and then the MCP server endpoint.

Previdian says these are attempts, not proof of success. Neither Langflow advisory reports exploitation. CISA's SSVC entry lists 105740 as "poc" and 105697 as "none". [Previdian][prev] [The Hacker News (secondary)][thn] [CNA ADP][cve40]

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Which versions and settings matter](#which-versions-and-settings-matter)
  - [Read-only inventory](#read-only-inventory)
  - [Logs and indicators](#logs-and-indicators)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Credited reporters: AbdrrahimDahmani (GHSA-7w94) and MosesOX (GHSA-w794). No report dates were published. [GHSA-7w94][ghsa40] [GHSA-w794][ghsa97] |
| Langflow 1.9.0 released (REST-route fix, PR #12290) | 2026-04-14 22:39:46 UTC | GitHub release. The fix shipped five months before the advisory. [Release v1.9.0][rel190] [GHSA-w794][ghsa97] |
| Langflow 1.11.0 released | 2026-07-23 01:58:39 UTC | GHSA-w794 calls 1.11.0 and later fixed. [Releases][releases] [GHSA-w794][ghsa97] |
| Langflow 1.10.3 released (sink fix, PR #14036) | 2026-07-23 16:08:25 UTC | The complete fix for both CVEs. [Release v1.10.3][rel1103] [GHSA-w794][ghsa97] |
| **Public announcement**: GHSA-7w94-79vh-5mr2 | **2026-09-10 15:38:54 UTC** | Published with a working PoC. The advisory's machine-readable affected field reads only "1.8.3"; the CNA record says "< 1.9.0". [GHSA-7w94 API][ghsa40api] |
| First exploitation attempts observed (Previdian) | 2026-09-19 03:14 UTC | Third-party honeypot telemetry. [Previdian][prev] |
| GHSA-w794-rj3p-xv45 published | 2026-09-28 17:26:49 UTC | [GHSA-w794 API][ghsa97api] |
| CVE IDs reserved | 2026-10-05 17:48:58 UTC (105697); 19:11:07 UTC (105740) | [CNA 105697][cve97] [CNA 105740][cve40] |
| CVE records published | 2026-10-05 20:16:58 UTC (105697); 20:46:18 UTC (105740) | GitHub CNA. [CNA 105697][cve97] [CNA 105740][cve40] |
| CISA ADP SSVC | 2026-10-06 | 105740: Exploitation "poc". 105697: "none". [CNA 105740][cve40] [CNA 105697][cve97] |
| Previdian records in-the-wild attempts; activity ramps up | 2026-10-11 (record 17:42 UTC) | 333 attempts that day, according to The Hacker News. [Previdian][prev] [THN][thn] |
| The Hacker News report | 2026-10-15 | 1,423 attempts from 27 IPs, later updated to 1,706 attempts from 28 IPs. These figures are superseded by Previdian's live counts. [THN][thn] |
| Langflow 1.13.0 released | 2026-10-22 21:20:30 UTC | Official packages and images now default to `LANGFLOW_AUTO_LOGIN=false`, a breaking change. [Releases][releases] [Langflow auth docs][auth] |
| Previdian live count | As of 2026-10-26 | 4,896 attempts, 34 IPs, 17 countries, one sensor. [Previdian][prev] |
| CISA KEV addition | Not listed | Catalog 2026.10.23, checked 2026-10-26. [KEV][kev] |

## Detection

### Which versions and settings matter

| Langflow version | REST "Add MCP Server" route (CVE-2026-105740) | Flow or tweak-embedded MCP stdio config (CVE-2026-105697) |
|---|---|---|
| 1.1.2 – 1.4.x | No such API (MCP Stdio component only) | **Vulnerable** |
| 1.5.0 – 1.8.x | **Vulnerable** | **Vulnerable** |
| 1.9.0 – 1.10.2 | Allowlisted | **Still vulnerable** |
| 1.10.3+ (and 1.11.0+) | Fixed | Fixed |

The table follows GHSA-w794's version breakdown. [GHSA-w794][ghsa97]

Exposure factors:

- **Auto-login.** GHSA-w794 describes `LANGFLOW_AUTO_LOGIN=true` as the default for vulnerable releases. With it on, `GET /api/v1/auto_login` hands out a superuser token without credentials. From 1.13, official packages, tagged archives and Docker images default to `false`. An explicit `LANGFLOW_AUTO_LOGIN=true` in an environment or `.env` file still overrides that default. [GHSA-w794][ghsa97] [Langflow auth docs][auth]
- **Weak or default credentials.** The observed attacks logged in with a common username and password. Langflow's default superuser name is `langflow`, and its docs call the password `langflow` a "legacy default" that current startup refuses. Older deployments may still use it. [THN][thn] [Langflow auth docs][auth]
- **Any account is enough.** With auto-login off, any authenticated non-admin user can exploit either flaw. Open account registration (the GHSA-7w94 PoC starts by registering a regular user) and shared accounts widen exposure. [GHSA-w794][ghsa97]
- **Network reachability.** Langflow listens on port 7860 by default (per the advisory PoCs). GHSA-w794's reporter found several vulnerable internet-facing servers. [GHSA-w794][ghsa97]

### Read-only inventory

These commands were not exercised on a real deployment. Run them as a user who can read the environment or container metadata. Placeholders are in capitals. Nothing is changed and Langflow is not imported.

```sh
# Python installs: read package metadata from the deployed site-packages, without importing Langflow
python3 -I -S -c 'import sys
from importlib.metadata import distributions
for d in distributions(path=[sys.argv[1]]):
    n = (d.metadata["Name"] or "").lower()
    if n in ("langflow", "langflow-base", "lfx"): print(n, d.version)' /PATH/TO/site-packages

# Containers: images and auth-related settings (prints names only, never the password value)
docker ps --format '{{.ID}} {{.Image}}' | grep -i langflow
docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' CONTAINER_ID \
  | grep -E '^LANGFLOW_(AUTO_LOGIN|SKIP_AUTH_AUTO_LOGIN|SUPERUSER)='

# .env files used to start Langflow (shows only the auto-login lines)
grep -n -E '^\s*LANGFLOW_(AUTO_LOGIN|SKIP_AUTH_AUTO_LOGIN)\s*=' /PATH/TO/.env
```

Treat an unset value as the default of the version you run. Also inventory the Langflow URLs that are reachable from the internet, using your own asset or exposure data.

### Logs and indicators

Review reverse-proxy, load-balancer or Langflow access logs for:

- `GET /api/v1/auto_login` from unexpected sources.
- Bursts of `/api/v1/login`, which may be password guessing.
- `POST` or `PATCH /api/v2/mcp/servers/` requests.
- `GET /api/v2/mcp/servers?action_count=true`.

[Previdian][prev] (via [THN][thn]) recommends reviewing authentication logs and requests to `/api/v2/mcp/servers/`. THN, quoting Previdian, reports:

- Payloads that try to send `LANGFLOW_SECRET_KEY` and `LANGFLOW_SUPERUSER_PASSWORD` to `146.70.211[.]112:18764`.
- Docker commands that read the host's `/etc/passwd`.
- `id` and `whoami` probes.
- Heavy activity from `192.255.229[.]92`.

These are secondary-sourced indicators. Previdian keeps its full IOC list behind a paywall, so the list is incomplete. [THN][thn]

The command below only reads files; `ACCESS_LOGS` is a placeholder for your log paths.

```sh
grep -n -E '/api/v1/auto_login|/api/v2/mcp/servers|146\.70\.211\.112|192\.255\.229\.92' ACCESS_LOGS
```

**Stored MCP server configurations persist.** Do **not** open the MCP Servers settings page on an unpatched instance to check them: loading the list runs every stored stdio command again. [GHSA-7w94][ghsa40] Inspect them after upgrading or isolating the instance (see [Compromise response](#compromise-response)). Also look on the host for unexpected child processes of the Langflow process (`bash -c exec …`), outbound connections, and Docker socket use. A missing indicator does not establish that the instance is clean.

## Remediation

1. **Upgrade to Langflow 1.10.3 or later**, with matching `langflow-base` 0.10.3+ and `lfx` 1.10.3+. Prefer the current release. **1.9.0 is not enough**: it fixes only CVE-2026-105740's REST route. [GHSA-w794][ghsa97]
2. **Turn off auto-login:** set `LANGFLOW_AUTO_LOGIN=false` and a strong, unique `LANGFLOW_SUPERUSER_PASSWORD`. Never use `langflow`. Remove any explicit `LANGFLOW_AUTO_LOGIN=true` override.
   - 1.13 makes `false` the default and refuses to start without a password. **Prepare the existing account before upgrading**, following the Langflow migration steps, so you keep access to flows.
   - Disabling auto-login does not revoke sessions or API keys already issued.

   [Langflow auth docs][auth] [GHSA-w794][ghsa97]
3. **Reduce exposure:** do not expose Langflow directly to untrusted networks. Put it behind an authenticating reverse proxy or VPN, give accounts only to trusted users, and limit who can create new accounts. [GHSA-w794][ghsa97] [Langflow auth docs][auth]
4. **On multi-tenant 1.10.3+ deployments, also apply the advisory's hardening:** [GHSA-w794][ghsa97]
   - `LANGFLOW_MCP_SERVER_ALLOWED_PACKAGES`: the exact packages `npx` and `uvx` may run.
   - `LANGFLOW_MCP_SERVER_INTERPRETER_HARDENING=true` and `LANGFLOW_MCP_SERVER_DOCKER_HARDENING=true`.
   - On 1.11.1+, restrict custom code with `LANGFLOW_ALLOW_CUSTOM_COMPONENTS=false`, `LANGFLOW_CUSTOM_COMPONENT_ADMIN_ONLY=true` or `LANGFLOW_BLOCK_CODE_INTERPRETER_COMPONENTS=true`. Each of these also limits MCP stdio servers to superusers.

   The allowlist still lets `npx` and `uvx` run any package by default.
5. **Restart or redeploy** every worker or container, then confirm the old image is gone. **Rollback caution:** rolling back below 1.10.3 reopens both CVEs.

## Verification

- Package metadata from the deployed environment shows `langflow` 1.10.3 or later, with matching `langflow-base` and `lfx`, in **every** running instance.
- `LANGFLOW_AUTO_LOGIN` resolves to `false`. As a benign control on your own instance, `GET /api/v1/auto_login` from an unauthenticated client should not return a token.
- Do **not** run the advisory PoC on production. GHSA-w794 describes the expected rejection message on 1.10.3+ if you test in a disposable lab. [GHSA-w794][ghsa97]

## Compromise response

Treat an instance as possibly compromised if it ran a vulnerable version and was reachable by untrusted users or the internet, especially with auto-login on or weak credentials.

1. **Isolate and preserve first.** Snapshot the host or container, the Langflow database, and access logs.
2. **Upgrade before you open the MCP Servers page.** On vulnerable versions, listing the servers re-runs stored commands. On 1.10.3+, the execution path validates commands before spawning them. [GHSA-7w94][ghsa40] [GHSA-w794][ghsa97]
3. **Review, as an admin, every user's MCP server configurations** and flows for stdio servers you do not recognize. Remove them.
4. **Rotate everything the process could read:**
   - `LANGFLOW_SECRET_KEY` and the superuser password.
   - LLM and API provider keys, and global variables or credentials stored in Langflow.
   - Database credentials and cloud credentials reachable from metadata.

   Revoke Langflow API keys and sessions. [GHSA-7w94][ghsa40] [Langflow auth docs][auth]
5. **Check for persistence and lateral movement:** cron jobs, new SSH keys, unexpected containers (if the Docker socket was mounted), and connections from the host to internal systems.
6. **Rebuild** from a clean image if command execution is confirmed.

## Sources

- [GHSA-7w94-79vh-5mr2][ghsa40] ([API metadata][ghsa40api]): CVE-2026-105740 details, PoC, publication timestamp.
- [GHSA-w794-rj3p-xv45][ghsa97] ([API metadata][ghsa97api]): CVE-2026-105697, the version breakdown, auto-login default, workarounds and hardening.
- CNA records: [CVE-2026-105740][cve40], [CVE-2026-105697][cve97]. NVD: [105740][nvd40], [105697][nvd97]. [CISA KEV feed][kev].
- [Langflow releases][releases], [v1.9.0][rel190], [v1.10.3][rel1103], [authentication docs][auth].
- Exploitation evidence (third party): [Previdian CVE-2026-105740][prev]. Secondary: [The Hacker News][thn].

[cve40]: https://cveawg.mitre.org/api/cve/CVE-2026-105740
[cve97]: https://cveawg.mitre.org/api/cve/CVE-2026-105697
[nvd40]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-105740
[nvd97]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-105697
[ghsa40]: https://github.com/langflow-ai/langflow/security/advisories/GHSA-7w94-79vh-5mr2
[ghsa40api]: https://api.github.com/repos/langflow-ai/langflow/security-advisories/GHSA-7w94-79vh-5mr2
[ghsa97]: https://github.com/langflow-ai/langflow/security/advisories/GHSA-w794-rj3p-xv45
[ghsa97api]: https://api.github.com/repos/langflow-ai/langflow/security-advisories/GHSA-w794-rj3p-xv45
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[releases]: https://github.com/langflow-ai/langflow/releases
[rel190]: https://github.com/langflow-ai/langflow/releases/tag/v1.9.0
[rel1103]: https://github.com/langflow-ai/langflow/releases/tag/v1.10.3
[auth]: https://github.com/langflow-ai/langflow/blob/main/docs/docs/Develop/api-keys-and-authentication.mdx
[prev]: https://previdian.com/CVE-2026-105740
[thn]: https://thehackernews.com/2026/10/langflows-critical-authenticated-rce.html
