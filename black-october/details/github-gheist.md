# GitHub Actions: Gheist - stolen tokens plant secret-dumping workflows

**Last updated:** 2026-10-26 (America/New_York)

[Main Gheist summary](../black-october-2026.md#github-actions-gheist---stolen-tokens-plant-secret-dumping-workflows) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Related supply-chain incident: no CVE and no vendor or CNA severity rating.** This is not a vulnerability in GitHub. It is a campaign that abuses GitHub personal access tokens (and other user and automation-account tokens) stolen elsewhere, so it is tracked like the [OVHcloud CLI](ovhcloud-cli.md) and [LiteLLM](litellm.md) incidents rather than under the High/Critical admission rule. Wiz Research named it **Gheist** after the `gheist` user agent on its API requests. Wiz has tracked it since **2026-09-15** and published on **2026-10-25**. [Wiz][wiz]

**What happens:** for every repository a stolen token can write to, an automated tool creates a branch named `ci-sync-` plus six random characters and commits `.github/workflows/sync-check.yml` with the message `ci: sync config`. The commit is unsigned and authored as the token's owner. The push triggers the workflow, which prints the job environment and `toJSON(secrets)` **base32-encoded**, so GitHub's log masking (which only redacts verbatim secret values) does not hide them. Where the repository has deployment environments, the tool adds an environment matrix so environment-scoped secrets, often production credentials, are printed too. The tool downloads the run log through the GitHub API and deletes the run seconds later. There is no attacker domain or outbound connection to block. [Wiz][wiz]

**Scale and exploitation:** Wiz recovered **more than 13,500 planted branches from more than 850 compromised accounts**, from personal projects to enterprise organizations' private repositories. As of 2026-10-24 the campaign was ongoing and evolving, and roughly two-thirds of the implicated accounts were no longer available on GitHub, which Wiz reads as likely response activity after it reported the campaign to GitHub. Wiz observed **successful secret dumping and follow-on activity in private repositories and GitHub Enterprise environments**, including, hours later, cloud credentials from the same organization used to enumerate AWS Secrets Manager. [Wiz][wiz]

**What limited it:** since 2026-07-28, GitHub holds potentially malicious workflow runs **in public repositories on github.com** until a collaborator with write access approves them. Every public Gheist run Wiz checked was held at `action_required`, so the payload never ran there. GitHub's changelog says the hold applies **only to public repositories on github.com**, so private repositories are not covered, and GitHub Enterprise Server does not add it. [GitHub changelog][hold] [Wiz][wiz]

**Worst case:** every repository, organization and environment secret available to an affected repository is exposed, plus anything the workflow can reach. On repositories with a **self-hosted runner**, a later variant (seen from 2026-10-19) adds a `sync-host` job that searches the runner host for 31 token formats, private keys, `.env` files, Terraform state and shell history, reads every process's environment, uses the Docker socket to mount the host's root filesystem, and collects AWS instance-role credentials, runner credential files and the Kubernetes service-account token. Wiz notes this job is buggy (wrong runner key file, broken URL-credential regex, no GCP or Azure token collection), but treats such hosts as compromised. Where workflows use OIDC, an attacker branch can also trigger your own workflows' cloud role assumptions. [Wiz][wiz]

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. Wiz reports active abuse since 2026-09-15, with successful secret dumping in private repositories and GitHub Enterprise environments and follow-on cloud activity. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Am I in scope?](#am-i-in-scope)
  - [Planted branches (read-only API queries)](#planted-branches-read-only-api-queries)
  - [Branch check script](#branch-check-script)
  - [Audit log queries](#audit-log-queries)
  - [Cloud and runner evidence](#cloud-and-runner-evidence)
  - [Indicators of compromise](#indicators-of-compromise)
  - [What a negative result cannot prove](#what-a-negative-result-cannot-prove)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| GitHub starts holding potentially malicious workflow runs | 2026-07-28 (time/TZ unknown) | Public repositories on github.com only; not GitHub Enterprise Server. [GitHub changelog][hold] |
| Private discovery: Wiz starts tracking | 2026-09-15 (time/TZ unknown) | "Since September 15, 2026, Wiz Research has been tracking Gheist." When the campaign itself began is not established. [Wiz][wiz] |
| Tool B variant first runs | 2026-09-28 (time/TZ unknown) | Base36 branch suffix; within hours added `timeout-minutes: 6` and the environment matrix. Tool A (hexadecimal suffix, plain payload) runs in parallel. [Wiz][wiz] |
| Lure-repository renames on overlapping accounts | 2026-10-06 (time/TZ unknown) | 391 accounts renamed about 1,461 repositories to cracked-software lures, wiping 610 `ci-sync` branches. Wiz treats this as other actors using the same stolen-credential pool. [Wiz][wiz] |
| Cryptomining attempt on overlapping accounts | 2026-10-18 (time/TZ unknown) | 25 Gheist accounts created a "Windows RDP Runner" repository within nine minutes. [Wiz][wiz] |
| Separator and self-hosted runner job added | 2026-10-19 (time/TZ unknown) | Tool B prints `LAFA====` between dumps; hours later pushes the `sync-host` job (`runs-on: self-hosted`). [Wiz][wiz] |
| PolinRider re-pushes on some victims | 2026-10-19 to 2026-10-20 (time/TZ unknown) | Three victims re-pushed their Gheist commits with a loader appended to `vite.config.js`. [Wiz][wiz] |
| Status snapshot | 2026-10-24 (time/TZ unknown) | Attack ongoing and evolving; about two-thirds of implicated accounts no longer available on GitHub. [Wiz][wiz] |
| **Public announcement: Wiz Research blog** | **2026-10-25 13:55:33 UTC−04:00 (17:55:33 UTC)** | Page metadata `article:published_time`. Includes IOCs and hunting guidance. [Wiz][wiz] |
| News coverage | 2026-10-25 onward | For example The Hacker News. [THN][thn] |
| Patch | Not applicable | No software fix exists or is needed: the entry point is stolen tokens. GitHub's hold is a platform mitigation for public repositories only. |
| CISA KEV | Not applicable (no CVE) | |

## Detection

### Am I in scope?

You are in scope if any token able to write to your repositories could have been stolen: personal access tokens (classic or fine-grained), OAuth tokens and automation-account tokens, including tokens on developer machines infected by infostealers. Wiz traced credential sources to infostealer logs and to tokens exposed in earlier supply-chain compromises such as the Trivy compromise in March. [Wiz][wiz]

The highest risk is **private and internal repositories on github.com and all repositories on GitHub Enterprise Server**, where GitHub's approval hold does not apply, and repositories whose workflows have access to secrets, deployment environments, OIDC cloud roles or self-hosted runners. Public repositories were protected by the hold in every case Wiz checked, but a held run still means a token with write access was used against you. [GitHub changelog][hold] [Wiz][wiz]

### Planted branches (read-only API queries)

These GitHub CLI calls only read. Replace `OWNER/REPO` with your repository. For GitHub Enterprise Server, set `GH_HOST` to your server's hostname first.

```sh
# Branches whose names start with ci-sync- (one request per repository).
gh api repos/OWNER/REPO/git/matching-refs/heads/ci-sync- --jq '.[] | [.ref, .object.sha] | @tsv'

# For a match: commit message, changed files and their blob SHAs, signature status.
gh api repos/OWNER/REPO/commits/SHA \
  --jq '{message: .commit.message, verified: .commit.verification.verified, author: .commit.author, files: [.files[] | {filename, sha}]}'

# Workflow runs still listed on that branch (held runs show conclusion "action_required").
gh api 'repos/OWNER/REPO/actions/runs?branch=ci-sync-XXXXXX' \
  --jq '.workflow_runs[] | [.id, .name, .status, .conclusion, .created_at] | @tsv'
```

A branch matching `^ci-sync-[0-9a-z]{6}$` whose only change is a new `.github/workflows/sync-check.yml` with message `ci: sync config` matches Wiz's description. Compare the workflow file's blob SHA with the [published SHAs](#indicators-of-compromise); environment-matrix variants differ per repository, so a different SHA does not clear the branch. Gheist deletes its runs, so an empty run list is expected and does not mean the workflow never ran.

### Branch check script

[gheist-branch-check.sh](../gheist-branch-check.sh) runs the queries above across every repository an organization or user owner returns to your token, or across named repositories. For each branch beginning with `ci-sync-` it reports whether the name matches the six-character pattern, whether the head commit matches the published message and file, whether the workflow blob is one of Wiz's four SHAs, and which workflow runs are still listed.

```sh
# Placeholders: your organization or user login, or OWNER/REPO.
sh gheist-branch-check.sh YOUR-ORG
sh gheist-branch-check.sh --no-runs YOUR-ORG/repo-one YOUR-ORG/repo-two
GH_HOST=github.example.com sh gheist-branch-check.sh YOUR-ORG   # GitHub Enterprise Server
```

- **Platform and requirements:** POSIX `sh`, `grep` and the GitHub CLI `gh`, already authenticated (`gh auth login`, or `GH_TOKEN` / `GH_ENTERPRISE_TOKEN` in the environment; the script never prints them). Any working directory. For private repositories the token needs read access to contents, metadata and Actions (classic `repo` scope, or fine-grained Contents, Metadata and Actions read-only). Use a clean machine and a token you trust, not one suspected of being stolen.
- **Safety:** it only sends GET requests (`gh repo list` and `gh api` without fields). It does not delete branches, approve or re-run workflows, check out code or change anything.
- **Output:** `INDICATOR` lines (pattern-named branches, with whether the head commit matches), `REVIEW` lines (other `ci-sync-` branches that may be legitimate), `RUN` lines (runs still listed), `UNKNOWN` lines (repositories, branches or commits the token could not read) and `INFO` lines.
- **Exit status:** `0` no `ci-sync-` branches in any repository checked (**not** proof of no compromise); `1` at least one `INDICATOR` or `REVIEW` line; `2` unknown (bad arguments, `gh` missing, an owner that could not be listed, or any repository that could not be read). `1` takes precedence over `2`.
- **Limits:** it sees only repositories the token can list and read, and an owner target covers only repositories owned by that login, not every repository the stolen token could reach. It finds branches that still exist: branches deleted by the attacker, by you or as a side effect of renames (Wiz saw 610 wiped this way) are invisible. It inspects only the branch head commit, so later pushes on top of the planted commit are reported as "differs" for review. It makes one request per repository plus up to two per matching branch, so large organizations can hit API rate limits; rate-limited repositories are reported as `UNKNOWN`. It was tested only with a mocked `gh` and disposable fixtures, plus a negative run against two real public repositories, not against a real affected organization.

### Audit log queries

GitHub audit logs carry the strongest evidence, because the runs themselves are deleted. Wiz looks for **workflow runs on `ci-sync-*` branches deleted within a minute of completing**, and **any activity from the user agent `gheist`**. [Wiz][wiz]

- **Where to look:** organization audit log (organization owners; 180 days of web events), enterprise audit log, or your audit log stream/SIEM. The REST API and JSON exports are available on GitHub Enterprise Cloud; `workflows.completed_workflow_run` and `workflows.created_workflow_run` appear only in the REST API, streams and JSON/CSV exports, not in the web interface. [Audit log docs][auditlog] [Audit log events][auditevents]
- **Run lifecycle (read-only REST query, Enterprise Cloud; needs `read:audit_log`):**

  ```sh
  # Replace YOUR-ORG. --method GET keeps -f values as query parameters.
  for a in workflows.completed_workflow_run workflows.delete_workflow_run; do
    gh api --method GET --paginate orgs/YOUR-ORG/audit-log \
      -f phrase="action:$a created:>=2026-09-15" -f per_page=100 \
      --jq '.[] | select((.head_branch // "") | startswith("ci-sync-"))
            | [.action, .created_at, .repo, .head_branch, .workflow_run_id, .actor, (.user_agent // ""), (.token_id // "" | tostring)] | @tsv'
  done
  ```

  Both events carry `head_branch` and `workflow_run_id`. A completed run on a `ci-sync-` branch followed within about a minute by a deletion of the same run is Wiz's hunting signal. `created_at` is milliseconds since the epoch. [Audit log events][auditevents]
- **User agent and token:** GitHub lists `user_agent`, `hashed_token`, `token_id` and `programmatic_access_type` among the fields included in most audit log events. Search JSON exports or streamed events for the `gheist` user agent, for example `jq -c 'select((.user_agent // "") | test("gheist"; "i"))' audit-export.json`, and use `hashed_token`/`token_id` on matches to identify which token to revoke. An event without a `user_agent` value is unknown, not negative. [Audit log events][auditevents]
- **Git events:** `git.push` events are retained for only **seven days** and exclude pushes made through the web interface or the REST or GraphQL APIs, so they may not show the planted commits at all. [Audit log docs][auditlog]
- **GitHub Enterprise Server:** use the enterprise audit log or your log forwarding with the same action names and branch pattern. The approval hold does not exist there. [GitHub changelog][hold]

### Cloud and runner evidence

- **OIDC role assumptions:** if your workflows authenticate to a cloud with GitHub OIDC, look in cloud audit logs for role assumptions or token exchanges whose subject contains a `ci-sync-` branch (GitHub's default subject format includes `ref:refs/heads/<branch>`). In AWS CloudTrail, check `AssumeRoleWithWebIdentity` events from `token.actions.githubusercontent.com`. Wiz notes this finds Gheist even without GitHub logs, because it proves Actions ran on an attacker branch. [Wiz][wiz] [GitHub OIDC][oidc]
- **Use of dumped secrets:** review the issuers' logs (cloud providers, package registries, SaaS APIs) for use of any secret available to an affected repository since its branch was created. Wiz saw cloud credentials used to enumerate AWS Secrets Manager hours later. [Wiz][wiz]
- **Self-hosted runners:** look for the files `.gdmp_pat`, `.gdmp_patg` and `.gdmp_sweep`, and the string `gdmp-pivot` in job logs, without executing anything from the runner's work directories. [Wiz][wiz]

### Indicators of compromise

All from Wiz Research. [Wiz][wiz]

- User agent `gheist`.
- Branch `ci-sync-` plus six characters, matching `^ci-sync-[0-9a-z]{6}$` (Tool A: hexadecimal suffix; Tool B: base36).
- Commit message `ci: sync config` adding only `.github/workflows/sync-check.yml`; unsigned; authored as the token owner.
- Workflow `name: sync-check`, `on: [push]`, `permissions: {}`; markers `toJSON(secrets) }}' | base32 -w 120` and `===== gdmp-pivot:`; separator output `LAFA====`; second job `sync-host` with `runs-on: self-hosted`.
- Files `.gdmp_pat`, `.gdmp_patg`, `.gdmp_sweep` on self-hosted runners.
- Workflow blob SHAs: `f3da2b8b357dcda02fd455d314be2a95007516a6` (plain), `d09535857a741bbb976bdc084a9a021713133291` (timeout), `1dc5af9cce950aad1eb1546ecce8565b117540c4` (separator), `c665b778b2d822453293003e7ca0bbb2cb08e39d` (self-hosted job). Environment-matrix variants differ per repository.

Gheist is distinct from GhostAction, which uses different workflow files and an external exfiltration address. [Wiz][wiz]

### What a negative result cannot prove

- Runs are deleted within seconds, and branches may be deleted or wiped by later repository renames. No `ci-sync-` branch today does not mean none existed.
- A stolen token may reach repositories outside the owners you checked, including other organizations and personal accounts of the token's owner.
- Audit log retention, plan level (REST API and exports require Enterprise Cloud) and the seven-day Git event window limit what you can still see.
- The campaign is evolving; new variants may change branch names, file names or messages.

## Remediation

There is no patch. Contain the stolen tokens and the exposed secrets.

1. **Do not approve held `sync-check` runs, and do not run or check out code from `ci-sync` branches.** [Wiz][wiz]
2. **Rotate every repository, organization and environment secret available to an affected repository**, at its issuer. Deleting the run or the branch does not undo the exposure. [Wiz][wiz]
3. **Revoke the tokens that pushed the commits** (the commit author identifies the account, not which token), and check their owners' devices for infostealers before issuing new credentials. Organization owners can review and revoke fine-grained token access to the organization; each user must revoke classic tokens on their own account. [Wiz][wiz] [Revoking tokens][patrevoke]
4. **Preserve evidence, then delete planted branches:** record branch names, commit SHAs and audit log entries (the [script](#branch-check-script) output is a useful record) before deleting.
5. **Harden**, following Wiz's recommendations: require reviewers on environments that hold production secrets; scope OIDC trust policies to protected branches or environments so a new branch cannot assume a role; prefer GitHub Apps or short-lived fine-grained tokens over personal access tokens (organizations can restrict classic PAT access and require approval for fine-grained tokens); and run self-hosted runners as ephemeral hosts without Docker-socket or unrestricted cloud-metadata access. [Wiz][wiz] [PAT policy][patpolicy] [GitHub OIDC][oidc] Each of these **changes state** and can break existing automation; test on one repository first.

## Verification

- Re-run the [branch check script](#branch-check-script) or the [API queries](#planted-branches-read-only-api-queries): no remaining `ci-sync-` branches you did not create.
- Confirm that the revoked tokens fail (their owners see them removed from **Settings → Developer settings**) and that rotated secrets no longer work at their issuers, while normal workflows still pass with the new values.
- For OIDC, confirm the cloud trust policy's subject condition names only the intended branches or environments, by reading the policy, not by pushing a test branch to production.
- Do not reproduce the payload in a repository that holds real secrets.

## Compromise response

- Treat every secret an affected repository could read as disclosed, including environment-scoped secrets, and hunt for their use at each issuer since the branch's creation date.
- If a `ci-sync` branch ran on a **self-hosted runner**, treat the host and its instance role as compromised: isolate and rebuild it, rotate the runner registration, and rotate anything reachable from the host, its containers and its cloud metadata. [Wiz][wiz]
- Review the token owners' other access. Wiz found the same accounts used by other campaigns: lure-repository renames, cryptomining runners, PolinRider loaders appended to `vite.config.js` and `package.json`-run scripts, and the earlier Megalodon campaign. Check affected repositories for force-pushed or back-dated commits and unexpected repository renames. [Wiz][wiz]
- In enterprise organizations, check for private repositories cloned by the same accounts shortly before the planting; Wiz saw that pattern. [Wiz][wiz]

## Sources

- [Wiz Research, "Gheist: Attempted Scaled Abuse of Stolen GitHub Tokens Stumbles"][wiz] — published 2026-10-25 13:55:33 UTC−04:00 (page metadata); mechanics, variants, scale, timeline, overlaps, hunting and response guidance, IOCs.
- [GitHub changelog, 2026-07-28][hold] — approval hold for potentially malicious workflow runs; public repositories on github.com only, not GitHub Enterprise Server.
- GitHub documentation: [reviewing the organization audit log][auditlog], [audit log events][auditevents], [OIDC][oidc], [personal access token policy][patpolicy] and [reviewing and revoking tokens][patrevoke].
- [The Hacker News][thn] — secondary coverage repeating Wiz's findings.

[wiz]: https://www.wiz.io/blog/gheist-attempted-scaled-abuse-of-stolen-github-tokens-stumbles
[hold]: https://github.blog/changelog/2026-07-28-github-actions-holds-potentially-malicious-workflows-for-approval/
[auditlog]: https://docs.github.com/en/enterprise-cloud@latest/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/reviewing-the-audit-log-for-your-organization
[auditevents]: https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/audit-log-events-for-your-organization
[oidc]: https://docs.github.com/en/actions/concepts/security/openid-connect
[patpolicy]: https://docs.github.com/en/organizations/managing-programmatic-access-to-your-organization/setting-a-personal-access-token-policy-for-your-organization
[patrevoke]: https://docs.github.com/en/organizations/managing-programmatic-access-to-your-organization/reviewing-and-revoking-personal-access-tokens-in-your-organization
[thn]: https://thehackernews.com/2026/10/gheist-uses-stolen-github-tokens-to.html
