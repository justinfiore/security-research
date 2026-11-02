# Gitea 28.3.0: Actions secret theft, archived-repo writes, and stored XSS

**Last updated:** 2026-11-01 (America/New_York)

[Back to Gitea 28.3.0 summary](../black-october-2026.md#gitea-actions-secret-theft-archived-repo-writes-and-stored-xss) · [Changelog](../../CHANGELOG.md)

Gitea 28.3.0, released 2026-11-01, fixes three High flaws that affect **28.2.0 and earlier**. They are not the built-in SSH authentication bypass ([CVE-2026-103059](https://www.cve.org/CVERecord?id=CVE-2026-103059)), which 28.0.0 already fixed. A host that stopped at 28.0.0, 28.1.0, or 28.2.0 is still exposed to these three. The same tag also fixes seven Medium flaws. They are not a second upgrade.

| CVE | Score | Who can do it | Result |
| --- | --- | --- | --- |
| [CVE-2026-118386](https://www.cve.org/CVERecord?id=CVE-2026-118386) | GitHub advisory CVSS 3.1 **8.1 High**. No CNA score in the record checked. | A user with **read** access, a runner, and one same-repository pull request. | Their workflow runs as the repository's own: no approval, the repository's and owner's Actions secrets, and a `GITEA_TOKEN` that can commit. |
| [CVE-2026-116296](https://www.cve.org/CVERecord?id=CVE-2026-116296) | GitHub advisory CVSS 3.1 **8.1 High**. | A user with ordinary **write** access to an **archived** repository. | Replace release binaries at the same tag and URL, delete releases, and edit milestones and labels. The archived-repository guard is missing on those routes. |
| [CVE-2026-113429](https://www.cve.org/CVERecord?id=CVE-2026-113429) | GitHub advisory CVSS 3.1 **8.7 High**. | A user who can run one Actions job. The download URL needs only Actions read, so it is anonymous on a public repository. | Stored XSS on the Gitea origin. The victim must open the direct artifact URL. Chromium renders `video/mp4,text/html` as HTML after Gitea drops the sandbox CSP. |

The same 28.3.0 tag also fixes seven Medium flaws, all patched in 28.3.0, published 2026-11-01 09:42 UTC. They do not change the upgrade. GitHub labels each Medium. Where the advisory has a CVSS 3.1 number, it is below:

| CVE | Score | What it does |
| --- | --- | --- |
| [CVE-2026-116474](https://www.cve.org/CVERecord?id=CVE-2026-116474) | Medium; no numeric score on the advisory | An Actions token can spoof an instance-signed commit by adding a GPG key. |
| [CVE-2026-112887](https://www.cve.org/CVERecord?id=CVE-2026-112887) | 6.5 | An Actions task token can call the REST API with no token scope. |
| [CVE-2026-119533](https://www.cve.org/CVERecord?id=CVE-2026-119533) | 5.3 | A public project board can show a private pull request's title. |
| [CVE-2026-118394](https://www.cve.org/CVERecord?id=CVE-2026-118394) | 4.3 | OIDC userinfo skips the public-only scope when the token is a query parameter. |
| [CVE-2026-119627](https://www.cve.org/CVERecord?id=CVE-2026-119627) | 4.3 | Profile and feed routes bypass the public-only scope. |
| [CVE-2026-118504](https://www.cve.org/CVERecord?id=CVE-2026-118504) | 6.5 | The API issue-archive restriction can be bypassed. |
| [CVE-2026-114199](https://www.cve.org/CVERecord?id=CVE-2026-114199) | 4.3 | A contribution heatmap leaks private-repository counts to a public-only token. |

The v28.3.0 release notes do not list these seven. The numbers are GitHub's CVSS 3.1 scores. CVE-2026-116474's advisory has no vector.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-01) for CVE-2026-118386, CVE-2026-116296, or CVE-2026-113429. No exploitation report was found. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| 2026-11-01 09:42 UTC | GitHub publishes the three advisories. Each says patched in **28.3.0**. [CVE-2026-118386][a1], [CVE-2026-116296][a2], [CVE-2026-113429][a3] |
| 2026-11-01 09:55 UTC | Gitea tags **v28.3.0**. [Release][rel] |
| Customer action | Upgrade. 28.2.0 is inside every affected range. |

**Evidence limits:** The advisories do not name a reporter date. CVE-2026-118386's range starts at 1.19.0; the other two say `<= 28.2.0` and do not name a first affected release. The XSS advisory says it was tested in Chromium only. NVD had not scored these records when checked.

## Detection

1. Read the running version from `gitea --version` or `/api/v1/version` on every instance, including replicas. **28.2.0 and earlier are affected.** 28.3.0 is the first listed fix.
2. **Actions secret theft** needs read access, a runner for that repository, and one pull request whose head branch is in the repository itself (open or merged). Disabling forks does not remove it: the advisory says a fork pull request or a push to `refs/for/main/<topic>` also needs only read access.
3. **Archived writes** need an archived repository and a collaborator or token with write access. Look for release assets, milestones, or labels that changed after the repository was archived.
4. **XSS** needs one job the attacker could run, then a victim opening `/{owner}/{repo}/actions/runs/{run_id}/artifacts/{name}`. The in-page artifact preview stays sandboxed; the direct URL does not.

## Remediation

1. Upgrade to **Gitea 28.3.0 or later** and restart. Back up first. This is the same upgrade that covers the [built-in SSH bypass](gitea.md#remediation) if you have not installed 28.0.0 yet.
2. There is no configuration workaround in the advisories for the Actions secret theft. Until 28.3.0 is running, do not treat a read-only account as unable to start a trusted workflow.
3. For the archived-repository gap, removing write collaborators is the only reduction the advisory supports, and it does not fix the missing check.
4. For the XSS, do not send users direct artifact links from untrusted runs until the upgrade is in place.

## Verification

- `/api/v1/version` reports 28.3.0 or later on every instance.
- After the upgrade, a review whose `commit_id` is not the pull request's head must not start a workflow with `IsForkPullRequest = false`. The advisory's fix is that check; do not post an exploit payload to confirm it.
- An archived repository must reject release, milestone, and label changes from a write collaborator.

## Compromise response

- **Actions:** If a read-only user could open reviews, treat Actions secrets on repositories that had a same-repository pull request as exposed, and rotate them. Also review commits made with `GITEA_TOKEN` from runs you did not approve.
- **Releases:** If an archived repository had write collaborators, compare release asset hashes with a copy from before the archive. The download URL staying the same is the point of the flaw.
- **XSS:** A user who opened a direct artifact link may have run JavaScript as themselves. For an admin, the advisory says that means control of the instance: review admin actions and rotate session secrets.

## Sources

- [GHSA-32h8-5xqg-h466 / CVE-2026-118386](https://github.com/go-gitea/gitea/security/advisories/GHSA-32h8-5xqg-h466)
- [GHSA-6h2f-c8jm-84hc / CVE-2026-116296](https://github.com/go-gitea/gitea/security/advisories/GHSA-6h2f-c8jm-84hc)
- [GHSA-9v6p-xpcp-7488 / CVE-2026-113429](https://github.com/go-gitea/gitea/security/advisories/GHSA-9v6p-xpcp-7488)
- [Gitea v28.3.0](https://github.com/go-gitea/gitea/releases/tag/v28.3.0)

[a1]: https://github.com/go-gitea/gitea/security/advisories/GHSA-32h8-5xqg-h466
[a2]: https://github.com/go-gitea/gitea/security/advisories/GHSA-6h2f-c8jm-84hc
[a3]: https://github.com/go-gitea/gitea/security/advisories/GHSA-9v6p-xpcp-7488
[rel]: https://github.com/go-gitea/gitea/releases/tag/v28.3.0
